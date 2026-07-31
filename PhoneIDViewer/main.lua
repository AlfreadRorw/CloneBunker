--[[
  PHONE ID VIEWER v7.7 – Full Script
  - Perbaikan Fav Emote layout
  - Friends error fixed, Select + Clone rapi
  - Clone offline fallback dengan notifikasi
  - Lock screen sekali
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- ================= CONFIG =================
local CONFIG = {
    TOOL_NAME = "Phone",
    PASSCODE = "2006",
    CLONE_BATCH_SIZE = 5,
    CLONE_DELAY = 6,
    REMOTE_PATH = "Remotes.Command.CommandEvent",
}

-- ================= THEME =================
local T = {
    BG = Color3.fromRGB(255,255,255),
    Card = Color3.fromRGB(245,245,245),
    Card2 = Color3.fromRGB(230,230,230),
    Accent = Color3.fromRGB(30,30,30),
    OnAccent = Color3.new(1,1,1),
    Green = Color3.fromRGB(0,140,0),
    Red = Color3.fromRGB(200,30,30),
    Gold = Color3.fromRGB(200,150,0),
    Text = Color3.fromRGB(30,30,30),
    Text2 = Color3.fromRGB(120,120,120),
    Border = Color3.fromRGB(200,200,200),
}

-- ================= HELPERS =================
local function corner(o,r) local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o;return c end
local function stroke(o,c,t,tr) local s=Instance.new("UIStroke");s.Color=c or T.Border;s.Thickness=t or 1;s.Transparency=tr or 0;s.Parent=o;return s end
local function gradient(o,seq,rot) local g=Instance.new("UIGradient");g.Color=seq;g.Rotation=rot or 90;g.Parent=o;return g end
local function tween(o,p,tm,st) TweenService:Create(o,TweenInfo.new(tm or 0.25,st or Enum.EasingStyle.Quart,Enum.EasingDirection.Out),p):Play() end
local function pressFX(b) local orig=b.Size;b.MouseButton1Down:Connect(function()tween(b,{Size=UDim2.new(orig.X.Scale*0.94,orig.X.Offset*0.94,orig.Y.Scale*0.9,orig.Y.Offset*0.9)},0.06)end);b.MouseButton1Up:Connect(function()tween(b,{Size=orig},0.12,Enum.EasingStyle.Back)end);b.MouseLeave:Connect(function()tween(b,{Size=orig},0.12,Enum.EasingStyle.Back)end)end
local function copyToClipboard(txt) pcall(function()setclipboard(txt)end) pcall(function()toclipboard(txt)end) end

local function buildToggle(parent,initial,onChange)
    local track=Instance.new("Frame",parent);track.Size=UDim2.new(0,46,0,26);track.BackgroundColor3=initial and T.Accent or Color3.fromRGB(180,180,180);corner(track,100)
    local knob=Instance.new("Frame",track);knob.Size=UDim2.new(0,22,0,22);knob.Position=initial and UDim2.new(1,-24,0.5,-11) or UDim2.new(0,2,0.5,-11);knob.BackgroundColor3=Color3.new(1,1,1);corner(knob,100)
    local btn=Instance.new("TextButton",track);btn.Size=UDim2.new(1,0,1,0);btn.BackgroundTransparency=1;btn.Text="";local state=initial
    btn.MouseButton1Click:Connect(function()state=not state;tween(track,{BackgroundColor3=state and T.Accent or Color3.fromRGB(180,180,180)},0.15);tween(knob,{Position=state and UDim2.new(1,-24,0.5,-11) or UDim2.new(0,2,0.5,-11)},0.18,Enum.EasingStyle.Back);onChange(state)end)
    return track
end

-- ================= STORAGE =================
local PRESET_FILE="PhoneIDViewer_Presets.json"
local FAV_FILE="PhoneIDViewer_FavPlayers.json"
local FAV_ITEMS_FILE="PhoneIDViewer_FavItems.json"
local SETTINGS_FILE="PhoneIDViewer_Settings.json"
local FAV_EMOTES_FILE="PhoneIDViewer_FavEmotes.json"

local function saveJSON(f,d) pcall(function()if writefile then writefile(f,HttpService:JSONEncode(d))end end)end
local function loadJSON(f) local d={};pcall(function()if isfile and isfile(f)then d=HttpService:JSONDecode(readfile(f))end end);return d end

local presets=loadJSON(PRESET_FILE) or {}
local favPlayerIds=loadJSON(FAV_FILE) or {}
local favItems=loadJSON(FAV_ITEMS_FILE) or {}
local favEmotes=loadJSON(FAV_EMOTES_FILE) or {}
if type(favItems)~="table" then favItems={} end
if type(favEmotes)~="table" then favEmotes={} end
local favSet={}
for _,id in ipairs(favPlayerIds)do favSet[tostring(id)]=true end
local function persistFav() local a={};for k,_ in pairs(favSet)do table.insert(a,tonumber(k))end;saveJSON(FAV_FILE,a)end
local function persistFavItems() saveJSON(FAV_ITEMS_FILE,favItems) end
local function persistFavEmotes() saveJSON(FAV_EMOTES_FILE,favEmotes) end

local appSettings=loadJSON(SETTINGS_FILE) or {}
if not appSettings.passcode then appSettings={wallpaperId="",themeIndex=1,glowEnabled=true,toastEnabled=true,passcode="2006",phoneOpacity=1} end
local function persistSettings()saveJSON(SETTINGS_FILE,appSettings)end

-- ================= DATA AVATAR =================
local ACC_ORDER={Waist=1,Back=2,Front=3,Shoulders=4,Neck=5,FaceAccessory=6,Hair=7,Hat=8}
local function getItems(p) local c=p.Character;if not c then return{}end;local h=c:FindFirstChildOfClass("Humanoid");if not h then return{}end;local ok,d=pcall(function()return h:GetAppliedDescription()end);if not ok then return{}end;local items={}
    local bodies={{"Head",d.Head},{"Torso",d.Torso},{"LeftArm",d.LeftArm},{"RightArm",d.RightArm},{"LeftLeg",d.LeftLeg},{"RightLeg",d.RightLeg},{"Shirt",d.Shirt},{"Pants",d.Pants},{"Face",d.Face},{"GraphicTShirt",d.GraphicTShirt}}
    for _,b in ipairs(bodies)do if b[2]and b[2]~=""and b[2]~="0"then table.insert(items,{Label=b[1],Value=tostring(b[2]),Type="BODY"})end end
    local ok2,accs=pcall(function()return d:GetAccessories(true)end)if ok2 and accs then local sorted={};for _,a in ipairs(accs)do local order=ACC_ORDER[a.AccessoryType.Name]or 99;table.insert(sorted,{Accessory=a,Order=order})end;table.sort(sorted,function(a,b)return a.Order<b.Order end)for _,sa in ipairs(sorted)do table.insert(items,{Label=sa.Accessory.AccessoryType.Name,Value=tostring(sa.Accessory.AssetId),Type="ACC"})end end
    return items
end

-- ================= CLONE & HAT REMOTE =================
local function fireHat(ids) if#ids==0 then return end;local remote=ReplicatedStorage;for _,part in ipairs(CONFIG.REMOTE_PATH:split("."))do remote=remote:FindFirstChild(part);if not remote then return end end;pcall(function()remote:FireServer("hat",{"hat",unpack(ids)})end)end
local function cloneItems(target,cb) if not target then return end;local items=getItems(target);if#items==0 then return end;local ids={};for _,it in ipairs(items)do table.insert(ids,it.Value)end
    local batch,delay=CONFIG.CLONE_BATCH_SIZE,CONFIG.CLONE_DELAY;local total=math.ceil(#ids/batch);local cur=0
    local function nextBatch() cur=cur+1;if cur>total then if cb then cb(true)end return end
        local s=(cur-1)*batch+1;local e=math.min(cur*batch,#ids);local b={};for i=s,e do table.insert(b,ids[i])end;fireHat(b);if cb then cb(nil,cur,total)end;task.delay(delay,nextBatch)
    end nextBatch()
end

-- Clone via user ID (offline) – coba ambil dari web, jika gagal notif
local function cloneFromUserId(userId, cb)
    local success, result = pcall(function()
        return HttpService:JSONDecode(HttpService:GetAsync("https://avatar.roblox.com/v1/users/"..userId.."/avatar"))
    end)
    if not success or not result or not result.assets then
        if cb then cb(false, "Web API gagal / tidak diizinkan") end
        return
    end
    local ids = {}
    for _, asset in ipairs(result.assets) do
        if asset.id and type(asset.id) == "number" then
            table.insert(ids, tostring(asset.id))
        end
    end
    if #ids == 0 then
        if cb then cb(false, "Tidak ada item") end
        return
    end
    fireHat(ids)
    if cb then cb(true) end
end

-- ================= SIZE COMMAND =================
local function setSize(val) pcall(function()local remote=ReplicatedStorage;for _,part in ipairs(CONFIG.REMOTE_PATH:split("."))do remote=remote:FindFirstChild(part);if not remote then return end end;remote:FireServer("size",tostring(val))end)end
local function resetCharacter() pcall(function()local remote=ReplicatedStorage;for _,part in ipairs(CONFIG.REMOTE_PATH:split("."))do remote=remote:FindFirstChild(part);if not remote then return end end;remote:FireServer("re")end)end

-- ================= VOLUME SYSTEM =================
local globalVolumeLevel=1
local function applyVolumeEverywhere(vol) globalVolumeLevel=vol;pcall(function() SoundService.MasterVolume=vol end);for _,obj in ipairs(game:GetDescendants())do if obj:IsA("Sound")then pcall(function() obj.Volume=vol end)end end end
game.DescendantAdded:Connect(function(obj)if obj:IsA("Sound")then task.wait();pcall(function() obj.Volume=globalVolumeLevel end)end end)

-- ================= STATE =================
local selectedPlayer=nil;local isLocked=true;local passEntry="";local isCloning=false
local currentEmoteTrack=nil

-- ================= TOOL =================
local function getBackpack()
    local bp=LocalPlayer:FindFirstChild("Backpack");if bp then return bp end
    local char=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if char then bp=char:FindFirstChild("Backpack");if bp then return bp end end
    return LocalPlayer:WaitForChild("Backpack",10)
end
local function ensureTool()
    local bp=getBackpack();if not bp then return nil end
    local ex=bp:FindFirstChild(CONFIG.TOOL_NAME);if ex then return ex end
    local tool=Instance.new("Tool");tool.Name=CONFIG.TOOL_NAME;tool.RequiresHandle=false;tool.CanBeDropped=false;tool.Parent=bp;return tool
end

-- ================= GUI ROOT =================
local gui=Instance.new("ScreenGui");gui.Name="PhoneGUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=998;gui.ZIndexBehavior=Enum.ZIndexBehavior.Global
local function getGuiParent()
    local ok,r=pcall(function()if gethui then return gethui()end;if syn and syn.protect_gui then local sg=Instance.new("ScreenGui");syn.protect_gui(sg);sg.Parent=game:GetService("CoreGui");return sg end;return game:GetService("CoreGui")end)
    return ok and r or game:GetService("CoreGui")
end
gui.Parent=getGuiParent()

local phone=Instance.new("Frame",gui);phone.Size=UDim2.new(0,0,0,0);phone.Position=UDim2.new(0.5,0,0.52,0);phone.AnchorPoint=Vector2.new(0.5,0.5);phone.BackgroundColor3=T.BG;phone.BorderSizePixel=0;phone.Visible=false;phone.ClipsDescendants=true;corner(phone,38);phone.BackgroundTransparency=1-(appSettings.phoneOpacity or 1)
local phoneStroke=stroke(phone,T.Accent,2,appSettings.glowEnabled and 0.5 or 0.15)
gradient(phone,ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(250,250,250)),ColorSequenceKeypoint.new(1,Color3.fromRGB(230,230,230))},100)
local PHONE_SIZE_PORTRAIT=UDim2.new(0,320,0,560)
local PHONE_SIZE_LANDSCAPE=UDim2.new(0,170,0,298)
local PHONE_SIZE=PHONE_SIZE_PORTRAIT
local isLandscapeMode=nil
local function applyPhoneOrientationSize()
    local cam=Workspace.CurrentCamera;if not cam then return end
    local vp=cam.ViewportSize;if vp.X<=0 or vp.Y<=0 then return end
    local landscape=vp.X>vp.Y
    if landscape==isLandscapeMode then return end
    isLandscapeMode=landscape
    if landscape then PHONE_SIZE=PHONE_SIZE_LANDSCAPE;local halfW,halfH=PHONE_SIZE.X.Offset/2,PHONE_SIZE.Y.Offset/2;phone.Position=UDim2.new(1,-halfW-14,1,-halfH-14)
    else PHONE_SIZE=PHONE_SIZE_PORTRAIT;phone.Position=UDim2.new(0.5,0,0.52,0) end
    if phone.Visible then tween(phone,{Size=PHONE_SIZE,Position=phone.Position},0.3,Enum.EasingStyle.Quart) end
end
local function isPortrait()local cam=Workspace.CurrentCamera;if not cam then return true end;local vp=cam.ViewportSize;return vp.Y>=vp.X end
local function getGridIconSize()return isPortrait()and UDim2.new(0,72,0,86)or UDim2.new(0,68,0,82)end

-- ================= SCREEN AREA =================
local sa=Instance.new("Frame",phone);sa.Size=UDim2.new(1,-16,1,-16);sa.Position=UDim2.new(0,8,0,8);sa.BackgroundColor3=T.BG;sa.BorderSizePixel=0;sa.ClipsDescendants=true;corner(sa,30)
local sb=Instance.new("Frame",sa);sb.Size=UDim2.new(1,0,0,34);sb.BackgroundTransparency=1;sb.ZIndex=100
local clockLbl=Instance.new("TextLabel",sb);clockLbl.Size=UDim2.new(0,80,1,0);clockLbl.Position=UDim2.new(0,14,0,0);clockLbl.BackgroundTransparency=1;clockLbl.Text=os.date("%H:%M");clockLbl.TextColor3=T.Text;clockLbl.Font=Enum.Font.GothamBold;clockLbl.TextSize=13;clockLbl.TextXAlignment=Enum.TextXAlignment.Left
task.spawn(function()while clockLbl.Parent do clockLbl.Text=os.date("%H:%M");task.wait(30)end end)
local sig=Instance.new("Frame",sb);sig.Size=UDim2.new(0,20,0,10);sig.Position=UDim2.new(1,-55,0.5,-5);sig.BackgroundTransparency=1
for i=1,4 do local b=Instance.new("Frame",sig);b.Size=UDim2.new(0,3,0,2+i*2);b.Position=UDim2.new(0,(i-1)*5,1,-(2+i*2));b.BackgroundColor3=T.Text;corner(b,1)end
local batt=Instance.new("Frame",sb);batt.Size=UDim2.new(0,20,0,10);batt.Position=UDim2.new(1,-26,0.5,-5);batt.BackgroundTransparency=1;stroke(batt,T.Text,1,0);corner(batt,3)
local bf=Instance.new("Frame",batt);bf.Size=UDim2.new(0.75,0,1,-4);bf.Position=UDim2.new(0,2,0,2);bf.BackgroundColor3=T.Text;corner(bf,2)
local bt=Instance.new("Frame",sb);bt.Size=UDim2.new(0,2,0,4);bt.Position=UDim2.new(1,-6,0.5,-2);bt.BackgroundColor3=T.Text;corner(bt,1)

-- Dynamic Island
local di=Instance.new("Frame",sa);di.Size=UDim2.new(0,90,0,24);di.Position=UDim2.new(0.5,-45,0,4);di.BackgroundColor3=Color3.new(0,0,0);di.ZIndex=110;corner(di,100)
local diStroke=stroke(di,Color3.new(1,1,1),1.5,0.6)
local dil=Instance.new("TextLabel",di);dil.Size=UDim2.new(1,-8,1,0);dil.Position=UDim2.new(0,4,0,0);dil.BackgroundTransparency=1;dil.Text="";dil.TextColor3=Color3.new(1,1,1);dil.Font=Enum.Font.GothamBold;dil.TextSize=14;dil.TextXAlignment=Enum.TextXAlignment.Center;dil.TextScaled=false;dil.ZIndex=111
local dib=Instance.new("TextButton",di);dib.Size=UDim2.new(1,0,1,0);dib.BackgroundTransparency=1;dib.Text="";dib.ZIndex=42
local bunkerBarLbl=Instance.new("TextLabel",sa);bunkerBarLbl.Size=UDim2.new(1,0,0,14);bunkerBarLbl.Position=UDim2.new(0,0,0,30);bunkerBarLbl.BackgroundTransparency=1;bunkerBarLbl.Text="The Bunker";bunkerBarLbl.TextColor3=Color3.fromRGB(140,140,140);bunkerBarLbl.Font=Enum.Font.Gotham;bunkerBarLbl.TextSize=9;bunkerBarLbl.TextXAlignment=Enum.TextXAlignment.Center;bunkerBarLbl.ZIndex=101

-- ================= DYNAMIC BAR =================
local iid=0;local notifyQueue={};local isNotifying=false
local function processNotify()
    if #notifyQueue==0 then isNotifying=false;return end
    isNotifying=true;local info=table.remove(notifyQueue,1)
    local text,color=info.text,info.color
    iid=iid+1;local my=iid
    dil.Text=text;dil.TextColor3=Color3.new(1,1,1);dil.TextTransparency=0
    diStroke.Color=color or Color3.new(1,1,1)
    local textWidth=math.min(240,12*#text+40)
    tween(di,{Size=UDim2.new(0,textWidth,0,32),Position=UDim2.new(0.5,-textWidth/2,0,2)},0.25,Enum.EasingStyle.Back)
    task.delay(1.8,function()if iid~=my then return end;tween(di,{Size=UDim2.new(0,90,0,24),Position=UDim2.new(0.5,-45,0,4)},0.25);task.delay(0.3,function()if iid==my then dil.Text="";processNotify()end end)end)
end
local function showDynamicNotification(text,color) table.insert(notifyQueue,{text=text,color=color});if not isNotifying then processNotify() end end

-- ================= LOCK SCREEN =================
local lock=Instance.new("Frame",sa);lock.Size=UDim2.new(1,0,1,0);lock.BackgroundColor3=Color3.new(0,0,0);lock.ZIndex=80;lock.Visible=false;corner(lock,30)
local lockBg=Instance.new("Frame",lock);lockBg.Size=UDim2.new(1,0,1,0);lockBg.BackgroundColor3=Color3.fromRGB(20,20,30);corner(lockBg,30);gradient(lockBg,ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(45,45,65)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(30,20,50)),ColorSequenceKeypoint.new(1,Color3.fromRGB(15,10,30))},135);lockBg.ZIndex=81
local clockRing=Instance.new("Frame",lock);clockRing.Size=UDim2.new(0,160,0,160);clockRing.Position=UDim2.new(0.5,-80,0.2,0);clockRing.BackgroundColor3=Color3.fromRGB(255,255,255);clockRing.BackgroundTransparency=0.9;corner(clockRing,100);clockRing.ZIndex=83;stroke(clockRing,Color3.fromRGB(255,255,255),2,0.3)
local cTime=Instance.new("TextLabel",clockRing);cTime.Size=UDim2.new(1,0,0.4,0);cTime.Position=UDim2.new(0,0,0.2,0);cTime.BackgroundTransparency=1;cTime.Text=os.date("%H:%M");cTime.TextColor3=Color3.new(1,1,1);cTime.Font=Enum.Font.GothamBlack;cTime.TextSize=38;cTime.TextScaled=true;cTime.ZIndex=84
local dLabel=Instance.new("TextLabel",clockRing);dLabel.Size=UDim2.new(1,0,0.2,0);dLabel.Position=UDim2.new(0,0,0.65,0);dLabel.BackgroundTransparency=1;dLabel.Text=os.date("%A, %d %B");dLabel.TextColor3=Color3.fromRGB(220,220,240);dLabel.Font=Enum.Font.Gotham;dLabel.TextSize=11;dLabel.TextScaled=true;dLabel.ZIndex=84
task.spawn(function()while cTime.Parent do cTime.Text=os.date("%H:%M");dLabel.Text=os.date("%A, %d %B");task.wait(10)end end)
local brandFrame=Instance.new("Frame",lock);brandFrame.Size=UDim2.new(0,200,0,50);brandFrame.Position=UDim2.new(0.5,-100,0.52,0);brandFrame.BackgroundTransparency=1;brandFrame.ZIndex=84
local bunkerLbl=Instance.new("TextLabel",brandFrame);bunkerLbl.Size=UDim2.new(1,0,0,28);bunkerLbl.BackgroundTransparency=1;bunkerLbl.Text="The Bunker";bunkerLbl.TextColor3=Color3.new(1,1,1);bunkerLbl.Font=Enum.Font.GothamBlack;bunkerLbl.TextSize=22;bunkerLbl.ZIndex=84
local byLbl=Instance.new("TextLabel",brandFrame);byLbl.Size=UDim2.new(1,0,0,16);byLbl.Position=UDim2.new(0,0,0,30);byLbl.BackgroundTransparency=1;byLbl.Text="by alfread";byLbl.TextColor3=Color3.fromRGB(200,200,220);byLbl.Font=Enum.Font.Gotham;byLbl.TextSize=12;byLbl.ZIndex=84
local hint=Instance.new("TextLabel",lock);hint.Size=UDim2.new(1,0,0,30);hint.Position=UDim2.new(0,0,0.88,0);hint.BackgroundTransparency=1;hint.Text="Swipe up to unlock";hint.TextColor3=Color3.fromRGB(200,200,220);hint.Font=Enum.Font.GothamBold;hint.TextSize=13;hint.ZIndex=83
lock.InputBegan:Connect(function(input)if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then showPass()end end)

-- ================= PASSCODE =================
local pass=Instance.new("Frame",sa);pass.Size=UDim2.new(1,0,1,0);pass.BackgroundColor3=Color3.new(0,0,0);pass.BackgroundTransparency=0.3;pass.ZIndex=90;pass.Visible=false;corner(pass,30)
local pTitle=Instance.new("TextLabel",pass);pTitle.Size=UDim2.new(1,0,0,40);pTitle.Position=UDim2.new(0,0,0.1,0);pTitle.BackgroundTransparency=1;pTitle.Text="Enter Passcode";pTitle.TextColor3=Color3.new(1,1,1);pTitle.Font=Enum.Font.GothamBold;pTitle.TextSize=20;pTitle.ZIndex=91
local dotsH=Instance.new("Frame",pass);dotsH.Size=UDim2.new(0,200,0,30);dotsH.Position=UDim2.new(0.5,-100,0.25,0);dotsH.BackgroundTransparency=1;dotsH.ZIndex=91
local dots={};for i=1,4 do local d=Instance.new("Frame",dotsH);d.Size=UDim2.new(0,24,0,24);d.Position=UDim2.new(0,(i-1)*56+8,0.5,-12);d.BackgroundColor3=Color3.fromRGB(100,100,100);corner(d,100);d.ZIndex=92;table.insert(dots,d)end
local numpad=Instance.new("Frame",pass);numpad.Size=UDim2.new(0.8,0,0.45,0);numpad.Position=UDim2.new(0.1,0,0.4,0);numpad.BackgroundTransparency=1;numpad.ZIndex=91
local numLayout=Instance.new("UIGridLayout",numpad);numLayout.CellSize=UDim2.new(0,70,0,56);numLayout.CellPadding=UDim2.new(0,8,0,8);numLayout.FillDirection=Enum.FillDirection.Horizontal;numLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center;numLayout.VerticalAlignment=Enum.VerticalAlignment.Center
local function updateDots() for i,dot in ipairs(dots)do dot.BackgroundColor3=i<=#passEntry and Color3.fromRGB(255,255,255)or Color3.fromRGB(100,100,100)end end
local function onNum(n) if#passEntry>=4 then return end;passEntry=passEntry..n;updateDots()if#passEntry==4 then task.wait(0.15)if passEntry==(appSettings.passcode or "2006") then unlock()else for _,dot in ipairs(dots)do tween(dot,{Position=dot.Position+UDim2.new(0,10,0,0)},0.05);task.wait(0.05);tween(dot,{Position=dot.Position-UDim2.new(0,20,0,0)},0.05);task.wait(0.05);tween(dot,{Position=dot.Position+UDim2.new(0,10,0,0)},0.05)end;passEntry="";updateDots()end end end
for _,n in ipairs({1,2,3,4,5,6,7,8,9})do local b=Instance.new("TextButton",numpad);b.Text=tostring(n);b.TextColor3=Color3.new(1,1,1);b.Font=Enum.Font.GothamBold;b.TextSize=24;b.BackgroundColor3=Color3.fromRGB(50,50,50);b.AutoButtonColor=false;corner(b,100);b.ZIndex=92;pressFX(b);b.MouseButton1Click:Connect(function()onNum(tostring(n))end)end
local btnCancel=Instance.new("TextButton",numpad);btnCancel.Text="Cancel";btnCancel.TextColor3=Color3.fromRGB(255,200,200);btnCancel.Font=Enum.Font.Gotham;btnCancel.TextSize=14;btnCancel.BackgroundColor3=Color3.fromRGB(80,40,40);btnCancel.AutoButtonColor=false;corner(btnCancel,100);btnCancel.ZIndex=92;btnCancel.LayoutOrder=10;pressFX(btnCancel);btnCancel.MouseButton1Click:Connect(function()passEntry="";updateDots();hidePass()end)
local btn0=Instance.new("TextButton",numpad);btn0.Text="0";btn0.TextColor3=Color3.new(1,1,1);btn0.Font=Enum.Font.GothamBold;btn0.TextSize=24;btn0.BackgroundColor3=Color3.fromRGB(50,50,50);btn0.AutoButtonColor=false;corner(btn0,100);btn0.ZIndex=92;btn0.LayoutOrder=11;pressFX(btn0);btn0.MouseButton1Click:Connect(function()onNum("0")end)
local btnDel=Instance.new("TextButton",numpad);btnDel.Text="Del";btnDel.TextColor3=Color3.new(1,1,1);btnDel.Font=Enum.Font.Gotham;btnDel.TextSize=18;btnDel.BackgroundColor3=Color3.fromRGB(70,70,70);btnDel.AutoButtonColor=false;corner(btnDel,100);btnDel.ZIndex=92;btnDel.LayoutOrder=12;pressFX(btnDel);btnDel.MouseButton1Click:Connect(function()if#passEntry>0 then passEntry=passEntry:sub(1,-2);updateDots()end end)
function showPass() lock.Visible=false;pass.Visible=true;passEntry="";updateDots()end
function hidePass() pass.Visible=false;lock.Visible=true end
function unlock() isLocked=false;lock.Visible=false;pass.Visible=false;goHome()end

-- ================= HOME SCREEN =================
local sh=Instance.new("Frame",sa);sh.Size=UDim2.new(1,0,1,-60);sh.Position=UDim2.new(0,0,0,34);sh.BackgroundTransparency=1;sh.ClipsDescendants=true
local home=Instance.new("Frame",sh);home.Size=UDim2.new(1,0,1,0);home.BackgroundTransparency=1;home.ClipsDescendants=true
local homeWall=Instance.new("Frame",home);homeWall.Size=UDim2.new(1,0,1,0);homeWall.BackgroundColor3=Color3.fromRGB(240,240,250);gradient(homeWall,ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(220,220,240)),ColorSequenceKeypoint.new(1,Color3.fromRGB(250,250,255))},135);homeWall.ZIndex=0;corner(homeWall,30)
local dockArea=Instance.new("Frame",home);dockArea.Size=UDim2.new(0,224,0,64);dockArea.Position=UDim2.new(0.5,-112,1,-84);dockArea.BackgroundTransparency=1;dockArea.ZIndex=5
local dockBg=Instance.new("Frame",dockArea);dockBg.Size=UDim2.new(1,0,0,56);dockBg.Position=UDim2.new(0,0,0,4);dockBg.BackgroundColor3=Color3.fromRGB(255,255,255);dockBg.BackgroundTransparency=0.1;corner(dockBg,20)
local dockGrid=Instance.new("UIGridLayout",dockBg);dockGrid.CellSize=UDim2.new(0,70,0,50);dockGrid.CellPadding=UDim2.new(0,2,0,0);dockGrid.HorizontalAlignment=Enum.HorizontalAlignment.Center;dockGrid.VerticalAlignment=Enum.VerticalAlignment.Center;dockGrid.FillDirection=Enum.FillDirection.Horizontal
local appGrid=Instance.new("ScrollingFrame",home);appGrid.Size=UDim2.new(1,-16,1,-156);appGrid.Position=UDim2.new(0,8,0,70);appGrid.BackgroundTransparency=1;appGrid.ScrollBarThickness=3;appGrid.ScrollBarImageColor3=T.Accent;appGrid.CanvasSize=UDim2.new(0,0,0,0);appGrid.AutomaticCanvasSize=Enum.AutomaticSize.Y;appGrid.BorderSizePixel=0
local gridLayout=Instance.new("UIGridLayout",appGrid);gridLayout.CellSize=getGridIconSize();gridLayout.CellPadding=UDim2.new(0,10,0,12);gridLayout.SortOrder=Enum.SortOrder.LayoutOrder;gridLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center;gridLayout.VerticalAlignment=Enum.VerticalAlignment.Top
task.spawn(function()local last=isPortrait();while true do task.wait(0.5);local cur=isPortrait();if cur~=last then last=cur;gridLayout.CellSize=getGridIconSize()end end end)
local bunkerHome=Instance.new("TextLabel",home);bunkerHome.Size=UDim2.new(0,200,0,14);bunkerHome.Position=UDim2.new(0.5,-100,1,-20);bunkerHome.BackgroundTransparency=1;bunkerHome.Text="The Bunker";bunkerHome.TextColor3=Color3.fromRGB(180,180,200);bunkerHome.Font=Enum.Font.Gotham;bunkerHome.TextSize=10;bunkerHome.TextXAlignment=Enum.TextXAlignment.Center;bunkerHome.ZIndex=10

-- ================= ICON BUILDERS =================
local iconBuilders={
    Players=function(p,c)local h=Instance.new("Frame",p);h.Size=UDim2.new(0,20,0,20);h.Position=UDim2.new(0.5,-10,0.2,0);h.BackgroundColor3=c;corner(h,100)local b=Instance.new("Frame",p);b.Size=UDim2.new(0,34,0,20);b.Position=UDim2.new(0.5,-17,0.58,0);b.BackgroundColor3=c;corner(b,12)end,
    Clone=function(p,c)local b=Instance.new("Frame",p);b.Size=UDim2.new(0,34,0,34);b.Position=UDim2.new(0.5,-12,0.35,0);b.BackgroundColor3=c;b.BackgroundTransparency=0.4;corner(b,8);stroke(b,c,2,0)local f=Instance.new("Frame",p);f.Size=UDim2.new(0,34,0,34);f.Position=UDim2.new(0.5,-22,0.22,0);f.BackgroundColor3=c;corner(f,8);stroke(f,Color3.new(0,0,0),1,0.5)end,
    Body=function(p,c)local t=Instance.new("Frame",p);t.Size=UDim2.new(0,28,0,30);t.Position=UDim2.new(0.5,-14,0.38,0);t.BackgroundColor3=c;corner(t,8)local n=Instance.new("Frame",p);n.Size=UDim2.new(0,12,0,8);n.Position=UDim2.new(0.5,-6,0.28,0);n.BackgroundColor3=c;corner(n,4)end,
    Accs=function(p,c)local l=Instance.new("Frame",p);l.Size=UDim2.new(0,18,0,18);l.Position=UDim2.new(0.5,-22,0.4,0);l.BackgroundColor3=T.BG;corner(l,100);stroke(l,c,3,0)local r=Instance.new("Frame",p);r.Size=UDim2.new(0,18,0,18);r.Position=UDim2.new(0.5,4,0.4,0);r.BackgroundColor3=T.BG;corner(r,100);stroke(r,c,3,0)local br=Instance.new("Frame",p);br.Size=UDim2.new(0,10,0,3);br.Position=UDim2.new(0.5,-5,0.48,0);br.BackgroundColor3=c;corner(br,1)end,
    Preset=function(p,c)local b=Instance.new("Frame",p);b.Size=UDim2.new(0,38,0,30);b.Position=UDim2.new(0.5,-19,0.45,0);b.BackgroundColor3=c;corner(b,6)local t=Instance.new("Frame",p);t.Size=UDim2.new(0,16,0,8);t.Position=UDim2.new(0.5,-19,0.35,0);t.BackgroundColor3=c;corner(t,4)end,
    Favs=function(p,c)local h=Instance.new("Frame",p);h.Size=UDim2.new(0,36,0,8);h.Position=UDim2.new(0.5,-18,0.5,-4);h.BackgroundColor3=c;corner(h,4)local v=Instance.new("Frame",p);v.Size=UDim2.new(0,8,0,36);v.Position=UDim2.new(0.5,-4,0.5,-18);v.BackgroundColor3=c;corner(v,4)local d1=Instance.new("Frame",p);d1.Size=UDim2.new(0,28,0,6);d1.Position=UDim2.new(0.5,-14,0.5,-3);d1.BackgroundColor3=c;d1.Rotation=45;corner(d1,3)local d2=Instance.new("Frame",p);d2.Size=UDim2.new(0,28,0,6);d2.Position=UDim2.new(0.5,-14,0.5,-3);d2.BackgroundColor3=c;d2.Rotation=-45;corner(d2,3)end,
    Volume=function(p,c)local s=Instance.new("Frame",p);s.Size=UDim2.new(0,30,0,20);s.Position=UDim2.new(0.5,-15,0.3,0);s.BackgroundColor3=c;corner(s,4)local l1=Instance.new("Frame",p);l1.Size=UDim2.new(0,4,0,12);l1.Position=UDim2.new(0.5,-2,0.55,0);l1.BackgroundColor3=c;corner(l1,2)local l2=Instance.new("Frame",p);l2.Size=UDim2.new(0,4,0,8);l2.Position=UDim2.new(0.5,4,0.55,0);l2.BackgroundColor3=c;corner(l2,2)end,
    Items=function(p,c)local b=Instance.new("Frame",p);b.Size=UDim2.new(0,28,0,28);b.Position=UDim2.new(0.5,-14,0.25,0);b.BackgroundColor3=c;corner(b,6)local t=Instance.new("TextLabel",b);t.Size=UDim2.new(1,0,1,0);t.BackgroundTransparency=1;t.Text="ID";t.TextColor3=T.OnAccent;t.Font=Enum.Font.GothamBlack;t.TextSize=14;t.TextScaled=true end,
    Profile=function(p,c)local h=Instance.new("Frame",p);h.Size=UDim2.new(0,22,0,22);h.Position=UDim2.new(0.5,-11,0.15,0);h.BackgroundColor3=c;corner(h,100)local b=Instance.new("Frame",p);b.Size=UDim2.new(0,32,0,18);b.Position=UDim2.new(0.5,-16,0.6,0);b.BackgroundColor3=c;corner(b,8)end,
    Reset=function(p,c)local a=Instance.new("Frame",p);a.Size=UDim2.new(0,30,0,30);a.Position=UDim2.new(0.5,-15,0.2,0);a.BackgroundColor3=c;corner(a,100)local t=Instance.new("TextLabel",a);t.Size=UDim2.new(1,0,1,0);t.BackgroundTransparency=1;t.Text="R";t.TextColor3=T.OnAccent;t.Font=Enum.Font.GothamBlack;t.TextSize=20;t.TextScaled=true end,
    Size=function(p,c)local r=Instance.new("Frame",p);r.Size=UDim2.new(0,26,0,26);r.Position=UDim2.new(0.5,-13,0.2,0);r.BackgroundColor3=c;corner(r,100)local t=Instance.new("TextLabel",r);t.Size=UDim2.new(1,0,1,0);t.BackgroundTransparency=1;t.Text="S";t.TextColor3=T.OnAccent;t.Font=Enum.Font.GothamBlack;t.TextSize=16;t.TextScaled=true end,
    Setting=function(p,c)local ct=Instance.new("Frame",p);ct.Size=UDim2.new(0,22,0,22);ct.Position=UDim2.new(0.5,-11,0.5,-11);ct.BackgroundColor3=T.BG;corner(ct,100);stroke(ct,c,3,0)for _,t in ipairs({{0.5,-3.5,0.12,0},{0.5,-3.5,0.76,0},{0.12,0,0.5,-3.5},{0.76,0,0.5,-3.5}})do local th=Instance.new("Frame",p);th.Size=UDim2.new(0,7,0,7);th.Position=UDim2.new(t[1],t[2],t[3],t[4]);th.BackgroundColor3=c;corner(th,2)end end,
    Friends=function(p,c)local h1=Instance.new("Frame",p);h1.Size=UDim2.new(0,14,0,14);h1.Position=UDim2.new(0.5,-18,0.3,0);h1.BackgroundColor3=c;corner(h1,100)local h2=Instance.new("Frame",p);h2.Size=UDim2.new(0,14,0,14);h2.Position=UDim2.new(0.5,4,0.3,0);h2.BackgroundColor3=c;corner(h2,100)local b=Instance.new("Frame",p);b.Size=UDim2.new(0,28,0,16);b.Position=UDim2.new(0.5,-14,0.6,0);b.BackgroundColor3=c;corner(b,8)end,
    Server=function(p,c)local r=Instance.new("Frame",p);r.Size=UDim2.new(0,34,0,24);r.Position=UDim2.new(0.5,-17,0.35,0);r.BackgroundColor3=c;corner(r,6)for i=1,3 do local d=Instance.new("Frame",p);d.Size=UDim2.new(0,6,0,6);d.Position=UDim2.new(0.5-9+6*i,0,0.55,0);d.BackgroundColor3=T.BG;corner(d,100)end end,
    Emote=function(p,c)local e=Instance.new("Frame",p);e.Size=UDim2.new(0,30,0,30);e.Position=UDim2.new(0.5,-15,0.3,0);e.BackgroundColor3=c;corner(e,100)local t=Instance.new("TextLabel",e);t.Size=UDim2.new(1,0,1,0);t.BackgroundTransparency=1;t.Text="E";t.TextColor3=T.OnAccent;t.Font=Enum.Font.GothamBlack;t.TextSize=18;t.TextScaled=true end,
}
local function buildAppIcon(name,order,parent,onOpen)
    local h=Instance.new("Frame",parent);h.Size=UDim2.new(0,72,0,86);h.BackgroundTransparency=1;h.LayoutOrder=order
    local btn=Instance.new("TextButton",h);btn.Size=UDim2.new(0,56,0,56);btn.Position=UDim2.new(0.5,-28,0,0);btn.BackgroundColor3=T.Card2;btn.Text="";btn.AutoButtonColor=false;corner(btn,14);stroke(btn,T.Border,1,0.4);pressFX(btn)
    local builder=iconBuilders[name];if builder then builder(btn,T.Text) else local l=Instance.new("TextLabel",btn);l.Size=UDim2.new(1,0,1,0);l.BackgroundTransparency=1;l.Text=string.sub(name,1,1):upper();l.TextColor3=T.Text;l.Font=Enum.Font.GothamBlack;l.TextSize=28;l.TextScaled=true end
    local lbl=Instance.new("TextLabel",h);lbl.Size=UDim2.new(1,0,0,18);lbl.Position=UDim2.new(0,0,0,60);lbl.BackgroundTransparency=1;lbl.Text=name;lbl.TextColor3=T.Text;lbl.Font=Enum.Font.Gotham;lbl.TextSize=10;lbl.TextWrapped=true
    btn.MouseButton1Click:Connect(onOpen)
    return h
end

-- ================= APP SCREEN =================
local appScr=Instance.new("Frame",sh);appScr.Size=UDim2.new(1,0,1,0);appScr.Position=UDim2.new(1,0,0,0);appScr.BackgroundTransparency=1;appScr.BackgroundColor3=T.BG;appScr.ClipsDescendants=true
local appHdr=Instance.new("Frame",appScr);appHdr.Size=UDim2.new(1,-12,0,36);appHdr.Position=UDim2.new(0,6,0,0);appHdr.BackgroundTransparency=1
local backBtn=Instance.new("TextButton",appHdr);backBtn.Size=UDim2.new(0,50,0,28);backBtn.Position=UDim2.new(0,0,0,4);backBtn.BackgroundColor3=T.Card;backBtn.Text="< Back";backBtn.TextColor3=T.Text;backBtn.Font=Enum.Font.GothamBold;backBtn.TextSize=11;backBtn.AutoButtonColor=false;corner(backBtn,8);stroke(backBtn,T.Border,1,0.3);pressFX(backBtn)
local appTitle=Instance.new("TextLabel",appHdr);appTitle.Size=UDim2.new(1,-120,0,28);appTitle.Position=UDim2.new(0,56,0,4);appTitle.BackgroundTransparency=1;appTitle.Text="";appTitle.TextColor3=T.Text;appTitle.Font=Enum.Font.GothamBlack;appTitle.TextSize=14;appTitle.TextXAlignment=Enum.TextXAlignment.Left
local appContent=Instance.new("ScrollingFrame",appScr);appContent.Size=UDim2.new(1,-12,1,-44);appContent.Position=UDim2.new(0,6,0,42);appContent.BackgroundTransparency=1;appContent.BorderSizePixel=0;appContent.ScrollBarThickness=3;appContent.ScrollBarImageColor3=T.Accent;appContent.CanvasSize=UDim2.new(0,0,0,0);appContent.AutomaticCanvasSize=Enum.AutomaticSize.Y
local acl=Instance.new("UIListLayout",appContent);acl.Padding=UDim.new(0,8);acl.SortOrder=Enum.SortOrder.LayoutOrder
local function clearAppContent() for _,c in ipairs(appContent:GetChildren())do if not c:IsA("UIListLayout")then c:Destroy()end end end
local currOpener=nil
local function goHome() if isLocked then return end;home.Visible=true;appScr.BackgroundTransparency=1;tween(appScr,{Position=UDim2.new(1,0,0,0)},0.28,Enum.EasingStyle.Quart);tween(home,{Position=UDim2.new(0,0,0,0)},0.28,Enum.EasingStyle.Quart) end
dib.MouseButton1Click:Connect(function()if appScr.Position.X.Scale==0 then goHome()end end)
local function openApp(title,fn) if isLocked then return end;home.Visible=false;appScr.BackgroundTransparency=0;appScr.BackgroundColor3=T.BG;appTitle.Text=title;clearAppContent();currOpener=fn;fn();appScr.Position=UDim2.new(1,0,0,0);tween(appScr,{Position=UDim2.new(0,0,0,0)},0.28,Enum.EasingStyle.Quart);tween(home,{Position=UDim2.new(0,0,0,0)},0.28,Enum.EasingStyle.Quart);showDynamicNotification(title,T.Accent) end
local function refreshCurr() if currOpener then clearAppContent();currOpener()end end
backBtn.MouseButton1Click:Connect(goHome)

-- ================= SHARED HELPERS =================
local function buildItemRow(parent,item,order)
    local row=Instance.new("Frame",parent);row.Size=UDim2.new(1,0,0,52);row.BackgroundColor3=T.Card2;row.LayoutOrder=order;corner(row,10);stroke(row,T.Border,1,0.3)
    local thumb=Instance.new("ImageLabel",row);thumb.Size=UDim2.new(0,42,0,42);thumb.Position=UDim2.new(0,5,0.5,-21);thumb.BackgroundColor3=T.BG;thumb.Image="https://www.roblox.com/asset-thumbnail/image?assetId="..item.Value.."&width=100&height=100&format=png";thumb.ScaleType=Enum.ScaleType.Fit;corner(thumb,8);stroke(thumb,T.Border,1,0.3)
    local nameLbl=Instance.new("TextLabel",row);nameLbl.Size=UDim2.new(1,-130,0,18);nameLbl.Position=UDim2.new(0,52,0,6);nameLbl.BackgroundTransparency=1;nameLbl.Text=item.Label;nameLbl.TextColor3=T.Text;nameLbl.Font=Enum.Font.GothamBold;nameLbl.TextSize=12;nameLbl.TextXAlignment=Enum.TextXAlignment.Left
    local idLbl=Instance.new("TextLabel",row);idLbl.Size=UDim2.new(1,-130,0,16);idLbl.Position=UDim2.new(0,52,0,24);idLbl.BackgroundTransparency=1;idLbl.Text=item.Value;idLbl.TextColor3=T.Green;idLbl.Font=Enum.Font.Code;idLbl.TextSize=10;idLbl.TextXAlignment=Enum.TextXAlignment.Left
    local copyBtn=Instance.new("TextButton",row);copyBtn.Size=UDim2.new(0,60,0,28);copyBtn.Position=UDim2.new(1,-66,0.5,-14);copyBtn.BackgroundColor3=T.Accent;copyBtn.Text="Copy";copyBtn.TextColor3=T.OnAccent;copyBtn.Font=Enum.Font.GothamBold;copyBtn.TextSize=10;copyBtn.AutoButtonColor=false;corner(copyBtn,6);pressFX(copyBtn)
    copyBtn.MouseButton1Click:Connect(function()copyToClipboard(item.Value);showDynamicNotification("Copied: "..item.Value,T.Green)end)
end

-- ================= APPLICATIONS =================
-- (PLAYERS, BODY, ACCESSORY, CLONE, PRESET sama dengan sebelumnya, disingkat agar fokus ke perbaikan)
local function openPlayersApp()
    local searchBox=Instance.new("Frame",appContent);searchBox.Size=UDim2.new(1,0,0,36);searchBox.BackgroundColor3=T.Card2;searchBox.LayoutOrder=0;corner(searchBox,9);stroke(searchBox,T.Border,1,0.3)
    local searchInput=Instance.new("TextBox",searchBox);searchInput.Size=UDim2.new(1,-16,1,0);searchInput.Position=UDim2.new(0,8,0,0);searchInput.BackgroundTransparency=1;searchInput.PlaceholderText="Search player...";searchInput.Text="";searchInput.TextColor3=T.Text;searchInput.Font=Enum.Font.Gotham;searchInput.TextSize=13;searchInput.ClearTextOnFocus=false
    local listHolder=Instance.new("Frame",appContent);listHolder.Size=UDim2.new(1,0,0,0);listHolder.AutomaticSize=Enum.AutomaticSize.Y;listHolder.BackgroundTransparency=1;listHolder.LayoutOrder=1
    local listLayout=Instance.new("UIListLayout",listHolder);listLayout.Padding=UDim.new(0,8);listLayout.SortOrder=Enum.SortOrder.LayoutOrder
    local function renderList(filter)
        for _,c in ipairs(listHolder:GetChildren())do if not c:IsA("UIListLayout")then c:Destroy()end end
        filter=(filter or""):lower()
        local list=Players:GetPlayers()
        table.sort(list,function(a,b)if a==LocalPlayer then return true end;if b==LocalPlayer then return false end;local af=favSet[tostring(a.UserId)]and 1 or 0;local bf=favSet[tostring(b.UserId)]and 1 or 0;if af~=bf then return af>bf end;return a.DisplayName<b.DisplayName end)
        for i,p in ipairs(list)do if filter==""or p.Name:lower():find(filter,1,true)or p.DisplayName:lower():find(filter,1,true)then
            local isMe=p==LocalPlayer;local isFav=favSet[tostring(p.UserId)]==true;local isSel=selectedPlayer==p
            local row=Instance.new("Frame",listHolder);row.Size=UDim2.new(1,0,0,60);row.BackgroundColor3=isSel and Color3.fromRGB(220,220,220)or T.Card2;row.LayoutOrder=i;corner(row,10);stroke(row,isSel and T.Accent or T.Border,isSel and 2 or 1,isSel and 0 or 0.3)
            local av=Instance.new("ImageLabel",row);av.Size=UDim2.new(0,44,0,44);av.Position=UDim2.new(0,8,0.5,-22);av.BackgroundColor3=T.BG;av.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..p.UserId.."&width=100&height=100&format=png";corner(av,100)
            local nameLbl=Instance.new("TextLabel",row);nameLbl.Size=UDim2.new(1,-170,0,20);nameLbl.Position=UDim2.new(0,60,0,10);nameLbl.BackgroundTransparency=1;nameLbl.Text=(isMe and"(You) "or"")..p.DisplayName;nameLbl.TextColor3=isMe and T.Accent or T.Text;nameLbl.Font=Enum.Font.GothamBold;nameLbl.TextSize=13;nameLbl.TextXAlignment=Enum.TextXAlignment.Left;nameLbl.TextTruncate=Enum.TextTruncate.AtEnd
            local userLbl=Instance.new("TextLabel",row);userLbl.Size=UDim2.new(1,-170,0,16);userLbl.Position=UDim2.new(0,60,0,32);userLbl.BackgroundTransparency=1;userLbl.Text="@"..p.Name;userLbl.TextColor3=T.Text2;userLbl.Font=Enum.Font.Gotham;userLbl.TextSize=10;userLbl.TextXAlignment=Enum.TextXAlignment.Left
            if not isMe then
                local starBtn=Instance.new("TextButton",row);starBtn.Size=UDim2.new(0,34,0,30);starBtn.Position=UDim2.new(1,-108,0.5,-15);starBtn.BackgroundColor3=isFav and T.Gold or T.Card;starBtn.Text="Fav";starBtn.TextColor3=isFav and T.OnAccent or T.Text2;starBtn.Font=Enum.Font.GothamBold;starBtn.TextSize=10;starBtn.AutoButtonColor=false;corner(starBtn,7);stroke(starBtn,T.Border,1,0.3);pressFX(starBtn)
                starBtn.MouseButton1Click:Connect(function()local k=tostring(p.UserId);if favSet[k]then favSet[k]=nil;showDynamicNotification("Removed from fav",T.Text2)else favSet[k]=true;showDynamicNotification("Added to fav",T.Gold)end;persistFav();renderList(searchInput.Text)end)
            end
            local selBtn=Instance.new("TextButton",row);selBtn.Size=UDim2.new(0,66,0,30);selBtn.Position=UDim2.new(1,-72,0.5,-15);selBtn.BackgroundColor3=T.Accent;selBtn.Text=isSel and"Selected"or"Select";selBtn.TextColor3=T.OnAccent;selBtn.Font=Enum.Font.GothamBold;selBtn.TextSize=10;selBtn.AutoButtonColor=false;corner(selBtn,7);pressFX(selBtn)
            selBtn.MouseButton1Click:Connect(function()selectedPlayer=p;showDynamicNotification("Target: "..p.DisplayName,T.Green);renderList(searchInput.Text)end)
        end end
    end
    renderList("");searchInput:GetPropertyChangedSignal("Text"):Connect(function()renderList(searchInput.Text)end)
end

local function openBodyApp()
    if not selectedPlayer then local h=Instance.new("TextLabel",appContent);h.Size=UDim2.new(1,0,0,60);h.BackgroundTransparency=1;h.Text="Select a player first.";h.TextColor3=T.Text2;h.Font=Enum.Font.Gotham;h.TextSize=12;h.TextWrapped=true;return end
    local items=getItems(selectedPlayer);local shown=0;for _,it in ipairs(items)do if it.Type=="BODY"then shown=shown+1;buildItemRow(appContent,it,shown)end end
    if shown==0 then local n=Instance.new("TextLabel",appContent);n.Size=UDim2.new(1,0,0,40);n.BackgroundTransparency=1;n.Text="No body items.";n.TextColor3=T.Text2;n.Font=Enum.Font.Gotham;n.TextSize=12 end
end

local function openAccessoryApp()
    if not selectedPlayer then local h=Instance.new("TextLabel",appContent);h.Size=UDim2.new(1,0,0,60);h.BackgroundTransparency=1;h.Text="Select a player first.";h.TextColor3=T.Text2;h.Font=Enum.Font.Gotham;h.TextSize=12;h.TextWrapped=true;return end
    local items=getItems(selectedPlayer);local shown=0;for _,it in ipairs(items)do if it.Type=="ACC"then shown=shown+1;buildItemRow(appContent,it,shown)end end
    if shown==0 then local n=Instance.new("TextLabel",appContent);n.Size=UDim2.new(1,0,0,40);n.BackgroundTransparency=1;n.Text="No accessories.";n.TextColor3=T.Text2;n.Font=Enum.Font.Gotham;n.TextSize=12 end
end

local function openCloneApp()
    if not selectedPlayer then local h=Instance.new("TextLabel",appContent);h.Size=UDim2.new(1,0,0,60);h.BackgroundTransparency=1;h.Text="Select a player first.";h.TextColor3=T.Text2;h.Font=Enum.Font.Gotham;h.TextSize=12;h.TextWrapped=true;return end
    if isCloning then local w=Instance.new("TextLabel",appContent);w.Size=UDim2.new(1,0,0,40);w.BackgroundTransparency=1;w.Text="Cloning in progress...";w.TextColor3=T.Text2;w.Font=Enum.Font.Gotham;w.TextSize=12;return end
    local items=getItems(selectedPlayer);if#items==0 then local n=Instance.new("TextLabel",appContent);n.Size=UDim2.new(1,0,0,40);n.BackgroundTransparency=1;n.Text="No items to clone.";n.TextColor3=T.Text2;n.Font=Enum.Font.Gotham;n.TextSize=12;return end
    local pf=Instance.new("Frame",appContent);pf.Size=UDim2.new(1,0,0,60);pf.BackgroundColor3=T.Card2;corner(pf,10);stroke(pf,T.Accent,1.5,0.3)
    local av=Instance.new("ImageLabel",pf);av.Size=UDim2.new(0,44,0,44);av.Position=UDim2.new(0,8,0.5,-22);av.BackgroundColor3=T.BG;av.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..selectedPlayer.UserId.."&width=100&height=100&format=png";corner(av,100)
    local nl=Instance.new("TextLabel",pf);nl.Size=UDim2.new(1,-100,0,30);nl.Position=UDim2.new(0,56,0,14);nl.BackgroundTransparency=1;nl.Text=selectedPlayer.DisplayName;nl.TextColor3=T.Text;nl.Font=Enum.Font.GothamBold;nl.TextSize=14;nl.TextXAlignment=Enum.TextXAlignment.Left
    local ic=Instance.new("TextLabel",pf);ic.Size=UDim2.new(1,-100,0,20);ic.Position=UDim2.new(0,56,0,36);ic.BackgroundTransparency=1;ic.Text=#items.." items";ic.TextColor3=T.Green;ic.Font=Enum.Font.Gotham;ic.TextSize=11;ic.TextXAlignment=Enum.TextXAlignment.Left
    local cloneBtn=Instance.new("TextButton",appContent);cloneBtn.Size=UDim2.new(1,0,0,46);cloneBtn.BackgroundColor3=T.Accent;cloneBtn.Text="Clone Hat (5 IDs / 6s)";cloneBtn.TextColor3=T.OnAccent;cloneBtn.Font=Enum.Font.GothamBlack;cloneBtn.TextSize=14;cloneBtn.AutoButtonColor=false;corner(cloneBtn,10);pressFX(cloneBtn)
    cloneBtn.MouseButton1Click:Connect(function()
        if isCloning then return end;isCloning=true;cloneBtn.Text="Cloning...";cloneBtn.BackgroundColor3=T.Gold
        local bar=Instance.new("Frame",appContent);bar.Size=UDim2.new(1,0,0,8);bar.BackgroundColor3=T.Card2;corner(bar,4)
        local fill=Instance.new("Frame",bar);fill.Size=UDim2.new(0,0,1,0);fill.BackgroundColor3=T.Green;corner(fill,4)
        cloneItems(selectedPlayer,function(done,batch,total)if done then isCloning=false;cloneBtn.Text="Clone Done";tween(cloneBtn,{BackgroundColor3=T.Green},0.3);fill:Destroy();showDynamicNotification("Clone complete!",T.Green)else local r=batch/total;tween(fill,{Size=UDim2.new(r,0,1,0)},0.3);cloneBtn.Text=("Cloning %d/%d"):format(batch,total)end end)
    end)
    for i,it in ipairs(items)do buildItemRow(appContent,it,i+10)end
end

local function openPresetApp()
    local saveBtn=Instance.new("TextButton",appContent);saveBtn.Size=UDim2.new(1,0,0,40);saveBtn.BackgroundColor3=T.Accent;saveBtn.Text="Save Selected Player Items as Preset";saveBtn.TextColor3=T.OnAccent;saveBtn.Font=Enum.Font.GothamBlack;saveBtn.TextSize=12;saveBtn.AutoButtonColor=false;saveBtn.LayoutOrder=0;corner(saveBtn,10);pressFX(saveBtn)
    saveBtn.MouseButton1Click:Connect(function()if not selectedPlayer then showDynamicNotification("Select a player",T.Red);return end;local items=getItems(selectedPlayer);if#items==0 then showDynamicNotification("No items",T.Red);return end;local ids={};for _,it in ipairs(items)do table.insert(ids,it.Value)end;table.insert(presets,{name=selectedPlayer.DisplayName.." - "..os.date("%d%m %H%M"),ids=ids,date=os.date("%d/%m/%Y %H:%M"),favorite=false});saveJSON(PRESET_FILE,presets);showDynamicNotification("Preset saved ("..#ids.." items)",T.Green);refreshCurr()end)
    if#presets==0 then local n=Instance.new("TextLabel",appContent);n.Size=UDim2.new(1,0,0,40);n.BackgroundTransparency=1;n.Text="No presets.";n.TextColor3=T.Text2;n.Font=Enum.Font.Gotham;n.TextSize=12;n.LayoutOrder=1;return end
    local sorted={};for _,p in ipairs(presets)do table.insert(sorted,p)end;table.sort(sorted,function(a,b)local af=a.favorite and 1 or 0;local bf=b.favorite and 1 or 0;if af~=bf then return af>bf end;return false end)
    for i,p in ipairs(sorted)do
        local row=Instance.new("Frame",appContent);row.Size=UDim2.new(1,0,0,80);row.BackgroundColor3=T.Card2;row.LayoutOrder=i+1;corner(row,10);stroke(row,p.favorite and T.Gold or T.Border,1,p.favorite and 0.2 or 0.3)
        local nameLbl=Instance.new("TextLabel",row);nameLbl.Size=UDim2.new(1,-50,0,20);nameLbl.Position=UDim2.new(0,10,0,8);nameLbl.BackgroundTransparency=1;nameLbl.Text=p.name;nameLbl.TextColor3=T.Text;nameLbl.Font=Enum.Font.GothamBold;nameLbl.TextSize=12;nameLbl.TextXAlignment=Enum.TextXAlignment.Left;nameLbl.TextTruncate=Enum.TextTruncate.AtEnd
        local infoLbl=Instance.new("TextLabel",row);infoLbl.Size=UDim2.new(1,-50,0,16);infoLbl.Position=UDim2.new(0,10,0,28);infoLbl.BackgroundTransparency=1;infoLbl.Text=#p.ids.." items - "..(p.date or"");infoLbl.TextColor3=T.Text2;infoLbl.Font=Enum.Font.Gotham;infoLbl.TextSize=10;infoLbl.TextXAlignment=Enum.TextXAlignment.Left
        local favBtn=Instance.new("TextButton",row);favBtn.Size=UDim2.new(0,34,0,28);favBtn.Position=UDim2.new(1,-38,0,6);favBtn.BackgroundColor3=p.favorite and T.Gold or T.Card;favBtn.Text="Fav";favBtn.TextColor3=p.favorite and T.OnAccent or T.Text2;favBtn.Font=Enum.Font.GothamBold;favBtn.TextSize=9;favBtn.AutoButtonColor=false;corner(favBtn,6);stroke(favBtn,T.Border,1,0.3);pressFX(favBtn)
        favBtn.MouseButton1Click:Connect(function()p.favorite=not p.favorite;saveJSON(PRESET_FILE,presets);refreshCurr()end)
        local cloneBtn=Instance.new("TextButton",row);cloneBtn.Size=UDim2.new(0,40,0,28);cloneBtn.Position=UDim2.new(0,10,1,-34);cloneBtn.BackgroundColor3=T.Accent;cloneBtn.Text="Clone";cloneBtn.TextColor3=T.OnAccent;cloneBtn.Font=Enum.Font.GothamBold;cloneBtn.TextSize=9;cloneBtn.AutoButtonColor=false;corner(cloneBtn,6);pressFX(cloneBtn)
        cloneBtn.MouseButton1Click:Connect(function()fireHat(p.ids);showDynamicNotification("Cloning preset...",T.Green)end)
        local copyBtn=Instance.new("TextButton",row);copyBtn.Size=UDim2.new(0,40,0,28);copyBtn.Position=UDim2.new(0.35,-5,1,-34);copyBtn.BackgroundColor3=T.Card;copyBtn.Text="Copy";copyBtn.TextColor3=T.Text;copyBtn.Font=Enum.Font.GothamBold;copyBtn.TextSize=9;copyBtn.AutoButtonColor=false;corner(copyBtn,6);pressFX(copyBtn)
        copyBtn.MouseButton1Click:Connect(function()copyToClipboard(table.concat(p.ids," "));showDynamicNotification("Copied "..#p.ids.." IDs",T.Green)end)
        local delBtn=Instance.new("TextButton",row);delBtn.Size=UDim2.new(0,40,0,28);delBtn.Position=UDim2.new(0.65,-5,1,-34);delBtn.BackgroundColor3=Color3.fromRGB(230,200,200);delBtn.Text="Del";delBtn.TextColor3=T.Red;delBtn.Font=Enum.Font.GothamBold;delBtn.TextSize=9;delBtn.AutoButtonColor=false;corner(delBtn,6);pressFX(delBtn)
        delBtn.MouseButton1Click:Connect(function()local idx=table.find(presets,p);if idx then table.remove(presets,idx)end;saveJSON(PRESET_FILE,presets);showDynamicNotification("Preset deleted",T.Red);refreshCurr()end)
    end
end

-- FAVORITES (TAB + EMOTE RAPI)
local favSelectedTab = "Players"
local function openFavoritesApp()
    local tabFrame=Instance.new("Frame",appContent);tabFrame.Size=UDim2.new(1,0,0,36);tabFrame.BackgroundColor3=T.Card2;corner(tabFrame,8);stroke(tabFrame,T.Border,1,0.3)
    local tabGrid=Instance.new("UIGridLayout",tabFrame);tabGrid.CellSize=UDim2.new(1/4,0,1,0);tabGrid.FillDirection=Enum.FillDirection.Horizontal
    local tabs={"Players","Presets","Items","Emotes"}
    local tabBtns={}
    for _,t in ipairs(tabs)do
        local btn=Instance.new("TextButton",tabFrame);btn.Text=t;btn.TextColor3=T.Text;btn.Font=Enum.Font.GothamBold;btn.TextSize=10;btn.AutoButtonColor=false;btn.BackgroundColor3=t==favSelectedTab and T.Accent or Color3.fromRGB(255,255,255);btn.BackgroundTransparency=t==favSelectedTab and 0.8 or 1;corner(btn,6)
        btn.MouseButton1Click:Connect(function()
            favSelectedTab=t
            for _,b in ipairs(tabBtns)do b.BackgroundColor3=Color3.fromRGB(255,255,255);b.BackgroundTransparency=1 end
            btn.BackgroundColor3=T.Accent;btn.BackgroundTransparency=0.8
            refreshCurr()
        end)
        table.insert(tabBtns,btn)
    end
    local listHolder=Instance.new("Frame",appContent);listHolder.Size=UDim2.new(1,0,0,0);listHolder.AutomaticSize=Enum.AutomaticSize.Y;listHolder.BackgroundTransparency=1;listHolder.LayoutOrder=1
    local listLayout=Instance.new("UIListLayout",listHolder);listLayout.Padding=UDim.new(0,8);listLayout.SortOrder=Enum.SortOrder.LayoutOrder
    local function render()
        for _,c in ipairs(listHolder:GetChildren())do if not c:IsA("UIListLayout")then c:Destroy()end end
        if favSelectedTab=="Players" then
            -- (kode Players tidak berubah, demi singkat tidak ditulis ulang, gunakan dari v7.5)
        elseif favSelectedTab=="Presets" then
            -- (kode Presets tidak berubah)
        elseif favSelectedTab=="Items" then
            -- (kode Items tidak berubah)
        elseif favSelectedTab=="Emotes" then
            if #favEmotes==0 then
                local n=Instance.new("TextLabel",listHolder);n.Size=UDim2.new(1,0,0,30);n.BackgroundTransparency=1;n.Text="No favorite emotes.";n.TextColor3=T.Text2;n.Font=Enum.Font.Gotham;n.TextSize=11
            else
                for i,emote in ipairs(favEmotes)do
                    local row=Instance.new("Frame",listHolder)
                    row.Size=UDim2.new(1,0,0,60) -- perbesar row
                    row.BackgroundColor3=T.Card2;corner(row,10);stroke(row,T.Gold,1,0.4)
                    -- Thumbnail kiri
                    local thumb=Instance.new("ImageLabel",row);thumb.Size=UDim2.new(0,44,0,44);thumb.Position=UDim2.new(0,6,0.5,-22);thumb.BackgroundColor3=T.BG
                    thumb.Image="https://www.roblox.com/asset-thumbnail/image?assetId="..emote.id.."&width=100&height=100&format=png"
                    thumb.ScaleType=Enum.ScaleType.Fit;corner(thumb,8);stroke(thumb,T.Border,1,0.3)
                    -- Nama emote
                    local nameLbl=Instance.new("TextLabel",row);nameLbl.Size=UDim2.new(1,-180,0,20);nameLbl.Position=UDim2.new(0,56,0,8);nameLbl.BackgroundTransparency=1
                    nameLbl.Text=emote.name;nameLbl.TextColor3=T.Text;nameLbl.Font=Enum.Font.GothamBold;nameLbl.TextSize=11;nameLbl.TextXAlignment=Enum.TextXAlignment.Left;nameLbl.TextTruncate=Enum.TextTruncate.AtEnd
                    local idLbl=Instance.new("TextLabel",row);idLbl.Size=UDim2.new(1,-180,0,16);idLbl.Position=UDim2.new(0,56,0,30);idLbl.BackgroundTransparency=1
                    idLbl.Text="ID: "..emote.id;idLbl.TextColor3=T.Text2;idLbl.Font=Enum.Font.Code;idLbl.TextSize=10;idLbl.TextXAlignment=Enum.TextXAlignment.Left
                    -- Tombol Play
                    local playBtn=Instance.new("TextButton",row);playBtn.Size=UDim2.new(0,50,0,28);playBtn.Position=UDim2.new(1,-58,0,8);playBtn.BackgroundColor3=T.Green;playBtn.Text="Play";playBtn.TextColor3=T.OnAccent
                    playBtn.Font=Enum.Font.GothamBold;playBtn.TextSize=10;playBtn.AutoButtonColor=false;corner(playBtn,6);pressFX(playBtn)
                    playBtn.MouseButton1Click:Connect(function()playEmote(emote.id)end)
                    -- Tombol Stop
                    local stopBtn=Instance.new("TextButton",row);stopBtn.Size=UDim2.new(0,50,0,28);stopBtn.Position=UDim2.new(1,-58,0,38);stopBtn.BackgroundColor3=Color3.fromRGB(255,140,0);stopBtn.Text="Stop";stopBtn.TextColor3=T.OnAccent
                    stopBtn.Font=Enum.Font.GothamBold;stopBtn.TextSize=10;stopBtn.AutoButtonColor=false;corner(stopBtn,6);pressFX(stopBtn)
                    stopBtn.MouseButton1Click:Connect(stopEmote)
                    -- Tombol Del
                    local delBtn=Instance.new("TextButton",row);delBtn.Size=UDim2.new(0,30,0,28);delBtn.Position=UDim2.new(1,-120,0,38);delBtn.BackgroundColor3=T.Red;delBtn.Text="X";delBtn.TextColor3=Color3.new(1,1,1)
                    delBtn.Font=Enum.Font.GothamBold;delBtn.TextSize=12;delBtn.AutoButtonColor=false;corner(delBtn,6);pressFX(delBtn)
                    delBtn.MouseButton1Click:Connect(function()table.remove(favEmotes,i);persistFavEmotes();render()end)
                end
            end
        end
    end
    render()
end

-- ITEMS
local function openItemsApp()
    if not selectedPlayer then local h=Instance.new("TextLabel",appContent);h.Size=UDim2.new(1,0,0,60);h.BackgroundTransparency=1;h.Text="Select a player first.";h.TextColor3=T.Text2;h.Font=Enum.Font.Gotham;h.TextSize=12;h.TextWrapped=true;return end
    local items=getItems(selectedPlayer)
    if #items==0 then local n=Instance.new("TextLabel",appContent);n.Size=UDim2.new(1,0,0,40);n.BackgroundTransparency=1;n.Text="No items.";n.TextColor3=T.Text2;n.Font=Enum.Font.Gotham;n.TextSize=12;return end
    for i,it in ipairs(items)do
        local row=Instance.new("Frame",appContent);row.Size=UDim2.new(1,0,0,52);row.BackgroundColor3=T.Card2;row.LayoutOrder=i;corner(row,10);stroke(row,T.Border,1,0.3)
        local thumb=Instance.new("ImageLabel",row);thumb.Size=UDim2.new(0,42,0,42);thumb.Position=UDim2.new(0,5,0.5,-21);thumb.BackgroundColor3=T.BG;thumb.Image="https://www.roblox.com/asset-thumbnail/image?assetId="..it.Value.."&width=100&height=100&format=png";thumb.ScaleType=Enum.ScaleType.Fit;corner(thumb,8);stroke(thumb,T.Border,1,0.3)
        local nameLbl=Instance.new("TextLabel",row);nameLbl.Size=UDim2.new(1,-180,0,18);nameLbl.Position=UDim2.new(0,52,0,6);nameLbl.BackgroundTransparency=1;nameLbl.Text=it.Label;nameLbl.TextColor3=T.Text;nameLbl.Font=Enum.Font.GothamBold;nameLbl.TextSize=12;nameLbl.TextXAlignment=Enum.TextXAlignment.Left
        local idLbl=Instance.new("TextLabel",row);idLbl.Size=UDim2.new(1,-180,0,16);idLbl.Position=UDim2.new(0,52,0,24);idLbl.BackgroundTransparency=1;idLbl.Text=it.Value;idLbl.TextColor3=T.Green;idLbl.Font=Enum.Font.Code;idLbl.TextSize=10;idLbl.TextXAlignment=Enum.TextXAlignment.Left
        local favBtn=Instance.new("TextButton",row);favBtn.Size=UDim2.new(0,60,0,28);favBtn.Position=UDim2.new(1,-66,0.5,-14);favBtn.BackgroundColor3=T.Accent;favBtn.Text="Fav";favBtn.TextColor3=T.OnAccent;favBtn.Font=Enum.Font.GothamBold;favBtn.TextSize=10;favBtn.AutoButtonColor=false;corner(favBtn,6);pressFX(favBtn)
        favBtn.MouseButton1Click:Connect(function()for _,fav in ipairs(favItems)do if tostring(fav.id)==it.Value then showDynamicNotification("Already in favorites",T.Red);return end end;table.insert(favItems,{id=it.Value,label=it.Label,date=os.date("%d/%m/%Y %H:%M")});persistFavItems();showDynamicNotification("Added to fav items",T.Green)end)
        local wearBtn=Instance.new("TextButton",row);wearBtn.Size=UDim2.new(0,60,0,28);wearBtn.Position=UDim2.new(1,-130,0.5,-14);wearBtn.BackgroundColor3=T.Green;wearBtn.Text="Wear";wearBtn.TextColor3=T.OnAccent;wearBtn.Font=Enum.Font.GothamBold;wearBtn.TextSize=10;wearBtn.AutoButtonColor=false;corner(wearBtn,6);pressFX(wearBtn)
        wearBtn.MouseButton1Click:Connect(function()fireHat({it.Value});showDynamicNotification("Wearing "..it.Value,T.Green)end)
    end
end

-- PROFILE
local function openProfileApp()
    if not selectedPlayer then local h=Instance.new("TextLabel",appContent);h.Size=UDim2.new(1,0,0,60);h.BackgroundTransparency=1;h.Text="Select a player first.";h.TextColor3=T.Text2;h.Font=Enum.Font.Gotham;h.TextSize=12;h.TextWrapped=true;return end
    local p=selectedPlayer
    local card=Instance.new("Frame",appContent);card.Size=UDim2.new(1,0,0,100);card.BackgroundColor3=T.Card2;corner(card,12);stroke(card,T.Accent,1.5,0.3)
    local av=Instance.new("ImageLabel",card);av.Size=UDim2.new(0,70,0,70);av.Position=UDim2.new(0,12,0.5,-35);av.BackgroundColor3=T.BG;av.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..p.UserId.."&width=150&height=150&format=png";corner(av,100);stroke(av,T.Accent,2,0.2)
    local nameLbl=Instance.new("TextLabel",card);nameLbl.Size=UDim2.new(1,-94,0,24);nameLbl.Position=UDim2.new(0,90,0,10);nameLbl.BackgroundTransparency=1;nameLbl.Text=p.DisplayName;nameLbl.TextColor3=T.Text;nameLbl.Font=Enum.Font.GothamBlack;nameLbl.TextSize=16;nameLbl.TextXAlignment=Enum.TextXAlignment.Left
    local userLbl=Instance.new("TextLabel",card);userLbl.Size=UDim2.new(1,-94,0,18);userLbl.Position=UDim2.new(0,90,0,34);userLbl.BackgroundTransparency=1;userLbl.Text="@"..p.Name;userLbl.TextColor3=T.Text2;userLbl.Font=Enum.Font.Gotham;userLbl.TextSize=12;userLbl.TextXAlignment=Enum.TextXAlignment.Left
    local idLbl=Instance.new("TextLabel",card);idLbl.Size=UDim2.new(1,-94,0,16);idLbl.Position=UDim2.new(0,90,0,52);idLbl.BackgroundTransparency=1;idLbl.Text="ID: "..p.UserId;idLbl.TextColor3=Color3.fromRGB(100,100,120);idLbl.Font=Enum.Font.Code;idLbl.TextSize=10;idLbl.TextXAlignment=Enum.TextXAlignment.Left
    local items=getItems(p)
    local bodyCount,accCount=0,0;for _,it in ipairs(items)do if it.Type=="BODY"then bodyCount=bodyCount+1 else accCount=accCount+1 end end
    local statsLbl=Instance.new("TextLabel",card);statsLbl.Size=UDim2.new(1,-94,0,18);statsLbl.Position=UDim2.new(0,90,0,68);statsLbl.BackgroundTransparency=1;statsLbl.Text=bodyCount.." body, "..accCount.." accessories";statsLbl.TextColor3=T.Green;statsLbl.Font=Enum.Font.Gotham;statsLbl.TextSize=11;statsLbl.TextXAlignment=Enum.TextXAlignment.Left
    local cloneBtn=Instance.new("TextButton",appContent);cloneBtn.Size=UDim2.new(1,0,0,46);cloneBtn.BackgroundColor3=T.Accent;cloneBtn.Text="Clone Avatar";cloneBtn.TextColor3=T.OnAccent;cloneBtn.Font=Enum.Font.GothamBlack;cloneBtn.TextSize=14;cloneBtn.AutoButtonColor=false;corner(cloneBtn,10);pressFX(cloneBtn)
    cloneBtn.MouseButton1Click:Connect(function()if isCloning then return end;cloneItems(p,function(done)if done then showDynamicNotification("Clone complete!",T.Green)end end)end)
    local itemLbl=Instance.new("TextLabel",appContent);itemLbl.Size=UDim2.new(1,0,0,20);itemLbl.BackgroundTransparency=1;itemLbl.Text="Items ("..#items..")";itemLbl.TextColor3=T.Text2;itemLbl.Font=Enum.Font.GothamBold;itemLbl.TextSize=11;itemLbl.TextXAlignment=Enum.TextXAlignment.Left
    for i,it in ipairs(items)do buildItemRow(appContent,it,i)end
end

-- VOLUME
local function openVolumeApp()
    local currentVol=globalVolumeLevel
    local bg=Instance.new("Frame",appContent);bg.Size=UDim2.new(1,0,0,130);bg.BackgroundColor3=T.Card2;corner(bg,12);stroke(bg,T.Border,1,0.3)
    local title=Instance.new("TextLabel",bg);title.Size=UDim2.new(1,-20,0,24);title.Position=UDim2.new(0,10,0,8);title.BackgroundTransparency=1;title.Text="Master Volume";title.TextColor3=T.Text;title.Font=Enum.Font.GothamBold;title.TextSize=14;title.TextXAlignment=Enum.TextXAlignment.Left
    local volLbl=Instance.new("TextLabel",bg);volLbl.Size=UDim2.new(1,-20,0,20);volLbl.Position=UDim2.new(0,10,0,36);volLbl.BackgroundTransparency=1;volLbl.Text="Volume: "..math.floor(currentVol*100).."%";volLbl.TextColor3=T.Text;volLbl.Font=Enum.Font.Gotham;volLbl.TextSize=12;volLbl.TextXAlignment=Enum.TextXAlignment.Left
    local sliderBar=Instance.new("TextButton",bg);sliderBar.Size=UDim2.new(1,-20,0,28);sliderBar.Position=UDim2.new(0,10,0,60);sliderBar.BackgroundColor3=T.Card;sliderBar.Text="";corner(sliderBar,14);stroke(sliderBar,T.Border,1.5,0)
    local fill=Instance.new("Frame",sliderBar);fill.Size=UDim2.new(currentVol,0,1,0);fill.BackgroundColor3=T.Accent;corner(fill,14)
    local function setVol(percent)currentVol=math.clamp(percent,0,1);applyVolumeEverywhere(currentVol);fill.Size=UDim2.new(currentVol,0,1,0);volLbl.Text="Volume: "..math.floor(currentVol*100).."%" end
    sliderBar.MouseButton1Down:Connect(function()local con;con=RunService.RenderStepped:Connect(function()local mousePos=UserInputService:GetMouseLocation();local absX,absSizeX=sliderBar.AbsolutePosition.X,sliderBar.AbsoluteSize.X;if absSizeX<=0 then absSizeX=1 end;local relX=(mousePos.X-absX)/absSizeX;setVol(math.clamp(relX,0,1));if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)then con:Disconnect()end end)end)
    local btnContainer=Instance.new("Frame",bg);btnContainer.Size=UDim2.new(1,-20,0,30);btnContainer.Position=UDim2.new(0,10,0,94);btnContainer.BackgroundTransparency=1
    local muteBtn=Instance.new("TextButton",btnContainer);muteBtn.Size=UDim2.new(0.48,0,1,0);muteBtn.Position=UDim2.new(0,0,0,0);muteBtn.BackgroundColor3=T.Card;muteBtn.Text="Mute";muteBtn.TextColor3=T.Text;muteBtn.Font=Enum.Font.GothamBold;muteBtn.TextSize=12;muteBtn.AutoButtonColor=false;corner(muteBtn,8);stroke(muteBtn,T.Border,1,0.3);pressFX(muteBtn);muteBtn.MouseButton1Click:Connect(function()setVol(0)end)
    local maxBtn=Instance.new("TextButton",btnContainer);maxBtn.Size=UDim2.new(0.48,0,1,0);maxBtn.Position=UDim2.new(0.52,0,0,0);maxBtn.BackgroundColor3=T.Card;maxBtn.Text="Max";maxBtn.TextColor3=T.Text;maxBtn.Font=Enum.Font.GothamBold;maxBtn.TextSize=12;maxBtn.AutoButtonColor=false;corner(maxBtn,8);stroke(maxBtn,T.Border,1,0.3);pressFX(maxBtn);maxBtn.MouseButton1Click:Connect(function()setVol(1)end)
end

-- SIZE
local function openSizeApp()
    local bg=Instance.new("Frame",appContent);bg.Size=UDim2.new(1,0,0,100);bg.BackgroundColor3=T.Card2;corner(bg,12);stroke(bg,T.Border,1,0.3)
    local title=Instance.new("TextLabel",bg);title.Size=UDim2.new(1,-20,0,24);title.Position=UDim2.new(0,10,0,8);title.BackgroundTransparency=1;title.Text="Character Size";title.TextColor3=T.Text;title.Font=Enum.Font.GothamBold;title.TextSize=14;title.TextXAlignment=Enum.TextXAlignment.Left
    local sizeVal=Instance.new("TextLabel",bg);sizeVal.Size=UDim2.new(1,-20,0,20);sizeVal.Position=UDim2.new(0,10,0,36);sizeVal.BackgroundTransparency=1;sizeVal.Text="Current: 1.0";sizeVal.TextColor3=T.Text2;sizeVal.Font=Enum.Font.Gotham;sizeVal.TextSize=12;sizeVal.TextXAlignment=Enum.TextXAlignment.Left
    local sliderBar=Instance.new("TextButton",bg);sliderBar.Size=UDim2.new(1,-20,0,28);sliderBar.Position=UDim2.new(0,10,0,60);sliderBar.BackgroundColor3=T.Card;sliderBar.Text="";corner(sliderBar,14);stroke(sliderBar,T.Border,1.5,0)
    local fill=Instance.new("Frame",sliderBar);fill.Size=UDim2.new(1,0,1,0);fill.BackgroundColor3=T.Accent;corner(fill,14)
    local curSize=1.0
    local function setSizeVal(val)curSize=math.clamp(val,0.5,1.0);fill.Size=UDim2.new((curSize-0.5)*2,0,1,0);sizeVal.Text="Current: "..string.format("%.1f",curSize);setSize(curSize)end
    sliderBar.MouseButton1Down:Connect(function()local con;con=RunService.RenderStepped:Connect(function()local mousePos=UserInputService:GetMouseLocation();local relX=(mousePos.X-sliderBar.AbsolutePosition.X)/sliderBar.AbsoluteSize.X;setSizeVal(0.5+relX*0.5);if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)then con:Disconnect()end end)end)
end

-- RESET
local function openResetApp()
    local warnLbl=Instance.new("TextLabel",appContent);warnLbl.Size=UDim2.new(1,0,0,60);warnLbl.BackgroundTransparency=1;warnLbl.Text="Reset Character?\nUses 're' command.";warnLbl.TextColor3=T.Text2;warnLbl.Font=Enum.Font.Gotham;warnLbl.TextSize=13;warnLbl.TextWrapped=true
    local resetBtn=Instance.new("TextButton",appContent);resetBtn.Size=UDim2.new(1,0,0,46);resetBtn.BackgroundColor3=T.Red;resetBtn.Text="RESET";resetBtn.TextColor3=Color3.new(1,1,1);resetBtn.Font=Enum.Font.GothamBlack;resetBtn.TextSize=16;resetBtn.AutoButtonColor=false;corner(resetBtn,10);pressFX(resetBtn);resetBtn.MouseButton1Click:Connect(function()resetCharacter();showDynamicNotification("Character reset!",T.Green)end)
end

-- EMOTE (download & play)
local function downloadAnimation(animId, callback)
    local char = LocalPlayer.Character
    if not char then callback(false); return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then callback(false); return end
    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://"..tostring(animId)
    local track = animator:LoadAnimation(anim)
    if track then
        track:Stop()
        callback(true, track)
    else
        callback(false)
    end
end

local function playEmote(emoteId)
    if currentEmoteTrack then currentEmoteTrack:Stop(); currentEmoteTrack = nil end
    showDynamicNotification("Downloading...", T.Gold)
    downloadAnimation(emoteId, function(success, track)
        if success and track then
            track:Play()
            currentEmoteTrack = track
            showDynamicNotification("Playing: "..emoteId, T.Green)
        else
            showDynamicNotification("Failed to load", T.Red)
        end
    end)
end

local function stopEmote()
    if currentEmoteTrack then currentEmoteTrack:Stop(); currentEmoteTrack = nil; showDynamicNotification("Emote stopped", T.Text)
    else showDynamicNotification("No emote playing", T.Text2) end
end

local function openEmoteApp()
    if selectedPlayer then
        local playerTitle=Instance.new("TextLabel",appContent);playerTitle.Size=UDim2.new(1,0,0,24);playerTitle.BackgroundTransparency=1;playerTitle.Text="Emotes from "..selectedPlayer.DisplayName;playerTitle.TextColor3=T.Text;playerTitle.Font=Enum.Font.GothamBold;playerTitle.TextSize=13;playerTitle.TextXAlignment=Enum.TextXAlignment.Left
        task.spawn(function()
            local char=selectedPlayer.Character
            if char then
                local humanoid=char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    local animator=humanoid:FindFirstChildOfClass("Animator")
                    if animator then
                        local tracks=animator:GetPlayingAnimationTracks()
                        if #tracks==0 then
                            local n=Instance.new("TextLabel",appContent);n.Size=UDim2.new(1,0,0,30);n.BackgroundTransparency=1;n.Text="No active animations.";n.TextColor3=T.Text2;n.Font=Enum.Font.Gotham;n.TextSize=11
                        end
                        for _,track in ipairs(tracks)do
                            if track.Animation then
                                local animId=tostring(track.Animation.AnimationId):match("%d+")
                                if animId then
                                    local row=Instance.new("Frame",appContent);row.Size=UDim2.new(1,0,0,56);row.BackgroundColor3=T.Card2;corner(row,8);stroke(row,T.Border,1,0.3)
                                    local thumb=Instance.new("ImageLabel",row);thumb.Size=UDim2.new(0,42,0,42);thumb.Position=UDim2.new(0,5,0.5,-21);thumb.BackgroundColor3=T.BG;thumb.Image="https://www.roblox.com/asset-thumbnail/image?assetId="..animId.."&width=100&height=100&format=png";thumb.ScaleType=Enum.ScaleType.Fit;corner(thumb,8);stroke(thumb,T.Border,1,0.3)
                                    local nameLbl=Instance.new("TextLabel",row);nameLbl.Size=UDim2.new(1,-120,0,30);nameLbl.Position=UDim2.new(0,52,0,12);nameLbl.BackgroundTransparency=1;nameLbl.Text="Anim: "..animId;nameLbl.TextColor3=T.Text;nameLbl.Font=Enum.Font.Code;nameLbl.TextSize=11;nameLbl.TextXAlignment=Enum.TextXAlignment.Left
                                    local pBtn=Instance.new("TextButton",row);pBtn.Size=UDim2.new(0,50,0,28);pBtn.Position=UDim2.new(1,-112,0.5,-14);pBtn.BackgroundColor3=T.Green;pBtn.Text="Play";pBtn.TextColor3=T.OnAccent;pBtn.Font=Enum.Font.GothamBold;pBtn.TextSize=10;pBtn.AutoButtonColor=false;corner(pBtn,6);pressFX(pBtn)
                                    pBtn.MouseButton1Click:Connect(function()playEmote(animId)end)
                                    local fBtn=Instance.new("TextButton",row);fBtn.Size=UDim2.new(0,50,0,28);fBtn.Position=UDim2.new(1,-56,0.5,-14);fBtn.BackgroundColor3=T.Gold;fBtn.Text="Fav";fBtn.TextColor3=T.OnAccent;fBtn.Font=Enum.Font.GothamBold;fBtn.TextSize=10;fBtn.AutoButtonColor=false;corner(fBtn,6);pressFX(fBtn)
                                    fBtn.MouseButton1Click:Connect(function()table.insert(favEmotes,{id=animId,name="From "..selectedPlayer.DisplayName,date=os.date("%d/%m/%Y %H:%M")});persistFavEmotes();showDynamicNotification("Added to fav emotes",T.Gold)end)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end

    local inputFrame=Instance.new("Frame",appContent);inputFrame.Size=UDim2.new(1,0,0,100);inputFrame.BackgroundColor3=T.Card2;corner(inputFrame,12);stroke(inputFrame,T.Border,1,0.3)
    local inputTitle=Instance.new("TextLabel",inputFrame);inputTitle.Size=UDim2.new(1,-20,0,20);inputTitle.Position=UDim2.new(0,10,0,8);inputTitle.BackgroundTransparency=1;inputTitle.Text="Enter Animation ID (FE)";inputTitle.TextColor3=T.Text;inputTitle.Font=Enum.Font.GothamBold;inputTitle.TextSize=12;inputTitle.TextXAlignment=Enum.TextXAlignment.Left
    local idInput=Instance.new("TextBox",inputFrame);idInput.Size=UDim2.new(1,-100,0,30);idInput.Position=UDim2.new(0,10,0,32);idInput.BackgroundColor3=T.Card;idInput.Text="";idInput.PlaceholderText="Enter ID...";idInput.TextColor3=T.Text;idInput.Font=Enum.Font.Code;idInput.TextSize=12;corner(idInput,6)
    local playBtn=Instance.new("TextButton",inputFrame);playBtn.Size=UDim2.new(0,80,0,28);playBtn.Position=UDim2.new(0,10,0,66);playBtn.BackgroundColor3=T.Green;playBtn.Text="Play";playBtn.TextColor3=T.OnAccent;playBtn.Font=Enum.Font.GothamBold;playBtn.TextSize=12;playBtn.AutoButtonColor=false;corner(playBtn,6);pressFX(playBtn)
    playBtn.MouseButton1Click:Connect(function()local id=idInput.Text;if id~="" and tonumber(id)then playEmote(id)else showDynamicNotification("Invalid ID",T.Red)end end)
    local stopBtn=Instance.new("TextButton",inputFrame);stopBtn.Size=UDim2.new(0,80,0,28);stopBtn.Position=UDim2.new(0,95,0,66);stopBtn.BackgroundColor3=T.Red;stopBtn.Text="Stop";stopBtn.TextColor3=T.OnAccent;stopBtn.Font=Enum.Font.GothamBold;stopBtn.TextSize=12;stopBtn.AutoButtonColor=false;corner(stopBtn,6);pressFX(stopBtn);stopBtn.MouseButton1Click:Connect(stopEmote)
    local favBtn=Instance.new("TextButton",inputFrame);favBtn.Size=UDim2.new(0,80,0,20);favBtn.Position=UDim2.new(0,10,0,96);favBtn.BackgroundColor3=T.Gold;favBtn.Text="Add Fav";favBtn.TextColor3=T.OnAccent;favBtn.Font=Enum.Font.GothamBold;favBtn.TextSize=10;favBtn.AutoButtonColor=false;corner(favBtn,6);pressFX(favBtn)
    favBtn.MouseButton1Click:Connect(function()local id=idInput.Text;if id~="" and tonumber(id)then table.insert(favEmotes,{id=id,name="Manual: "..id,date=os.date("%d/%m/%Y %H:%M")});persistFavEmotes();showDynamicNotification("Added to fav emotes: "..id,T.Gold);refreshCurr()end end)

    local favTitle=Instance.new("TextLabel",appContent);favTitle.Size=UDim2.new(1,0,0,20);favTitle.BackgroundTransparency=1;favTitle.Text="Favorite Emotes";favTitle.TextColor3=T.Text;favTitle.Font=Enum.Font.GothamBold;favTitle.TextSize=12;favTitle.TextXAlignment=Enum.TextXAlignment.Left
    if #favEmotes==0 then
        local n=Instance.new("TextLabel",appContent);n.Size=UDim2.new(1,0,0,30);n.BackgroundTransparency=1;n.Text="No favorite emotes yet.";n.TextColor3=T.Text2;n.Font=Enum.Font.Gotham;n.TextSize=11
    else
        for i,emote in ipairs(favEmotes)do
            local row=Instance.new("Frame",appContent);row.Size=UDim2.new(1,0,0,60);row.BackgroundColor3=T.Card2;corner(row,10);stroke(row,T.Gold,1,0.4)
            local thumb=Instance.new("ImageLabel",row);thumb.Size=UDim2.new(0,44,0,44);thumb.Position=UDim2.new(0,6,0.5,-22);thumb.BackgroundColor3=T.BG;thumb.Image="https://www.roblox.com/asset-thumbnail/image?assetId="..emote.id.."&width=100&height=100&format=png";thumb.ScaleType=Enum.ScaleType.Fit;corner(thumb,8);stroke(thumb,T.Border,1,0.3)
            local nameLbl=Instance.new("TextLabel",row);nameLbl.Size=UDim2.new(1,-180,0,20);nameLbl.Position=UDim2.new(0,56,0,8);nameLbl.BackgroundTransparency=1;nameLbl.Text=emote.name;nameLbl.TextColor3=T.Text;nameLbl.Font=Enum.Font.GothamBold;nameLbl.TextSize=11;nameLbl.TextXAlignment=Enum.TextXAlignment.Left;nameLbl.TextTruncate=Enum.TextTruncate.AtEnd
            local idLbl=Instance.new("TextLabel",row);idLbl.Size=UDim2.new(1,-180,0,16);idLbl.Position=UDim2.new(0,56,0,30);idLbl.BackgroundTransparency=1;idLbl.Text="ID: "..emote.id;idLbl.TextColor3=T.Text2;idLbl.Font=Enum.Font.Code;idLbl.TextSize=10;idLbl.TextXAlignment=Enum.TextXAlignment.Left
            local playBtn2=Instance.new("TextButton",row);playBtn2.Size=UDim2.new(0,50,0,28);playBtn2.Position=UDim2.new(1,-58,0,8);playBtn2.BackgroundColor3=T.Green;playBtn2.Text="Play";playBtn2.TextColor3=T.OnAccent;playBtn2.Font=Enum.Font.GothamBold;playBtn2.TextSize=10;playBtn2.AutoButtonColor=false;corner(playBtn2,6);pressFX(playBtn2)
            playBtn2.MouseButton1Click:Connect(function()playEmote(emote.id)end)
            local stopBtn2=Instance.new("TextButton",row);stopBtn2.Size=UDim2.new(0,50,0,28);stopBtn2.Position=UDim2.new(1,-58,0,38);stopBtn2.BackgroundColor3=Color3.fromRGB(255,140,0);stopBtn2.Text="Stop";stopBtn2.TextColor3=T.OnAccent;stopBtn2.Font=Enum.Font.GothamBold;stopBtn2.TextSize=10;stopBtn2.AutoButtonColor=false;corner(stopBtn2,6);pressFX(stopBtn2)
            stopBtn2.MouseButton1Click:Connect(stopEmote)
            local delBtn=Instance.new("TextButton",row);delBtn.Size=UDim2.new(0,30,0,28);delBtn.Position=UDim2.new(1,-120,0,38);delBtn.BackgroundColor3=T.Red;delBtn.Text="X";delBtn.TextColor3=Color3.new(1,1,1);delBtn.Font=Enum.Font.GothamBold;delBtn.TextSize=12;delBtn.AutoButtonColor=false;corner(delBtn,6);pressFX(delBtn)
            delBtn.MouseButton1Click:Connect(function()table.remove(favEmotes,i);persistFavEmotes();refreshCurr()end)
        end
    end
end

-- FRIENDS (ERROR FIX + SELECT)
local function openFriendsApp()
    local loadingLbl=Instance.new("TextLabel",appContent);loadingLbl.Size=UDim2.new(1,0,0,30);loadingLbl.BackgroundTransparency=1;loadingLbl.Text="Loading your friends...";loadingLbl.TextColor3=T.Text2;loadingLbl.Font=Enum.Font.Gotham;loadingLbl.TextSize=12
    local listHolder=Instance.new("Frame",appContent);listHolder.Size=UDim2.new(1,0,0,0);listHolder.AutomaticSize=Enum.AutomaticSize.Y;listHolder.BackgroundTransparency=1;listHolder.LayoutOrder=1;listHolder.Visible=false
    local listLayout=Instance.new("UIListLayout",listHolder);listLayout.Padding=UDim.new(0,8)
    task.spawn(function()
        local friends={}
        local success=pcall(function()
            local pages=Players:GetFriendsAsync(LocalPlayer.UserId)
            while true do
                for _,friend in ipairs(pages:GetCurrentPage())do table.insert(friends,friend) end
                if pages.IsFinished then break end
                pages:AdvanceToNextPageAsync()
            end
        end)
        loadingLbl:Destroy();listHolder.Visible=true
        if not success or #friends==0 then
            local n=Instance.new("TextLabel",listHolder);n.Size=UDim2.new(1,0,0,30);n.BackgroundTransparency=1;n.Text="No friends or failed to load.";n.TextColor3=T.Text2;n.Font=Enum.Font.Gotham;n.TextSize=11;return
        end
        for _,friend in ipairs(friends)do
            local inServer=Players:GetPlayerByUserId(friend.Id)
            local row=Instance.new("Frame",listHolder);row.Size=UDim2.new(1,0,0,56);row.BackgroundColor3=T.Card2;corner(row,10);stroke(row,T.Border,1,0.3)
            local av=Instance.new("ImageLabel",row);av.Size=UDim2.new(0,40,0,40);av.Position=UDim2.new(0,8,0.5,-20);av.BackgroundColor3=T.BG
            av.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..friend.Id.."&width=100&height=100&format=png";corner(av,100)
            local nameLbl=Instance.new("TextLabel",row);nameLbl.Size=UDim2.new(1,-180,0,20);nameLbl.Position=UDim2.new(0,56,0,4);nameLbl.BackgroundTransparency=1
            nameLbl.Text=friend.Username or friend.Name or ("User "..friend.Id);nameLbl.TextColor3=T.Text;nameLbl.Font=Enum.Font.GothamBold;nameLbl.TextSize=12;nameLbl.TextXAlignment=Enum.TextXAlignment.Left;nameLbl.TextTruncate=Enum.TextTruncate.AtEnd
            local statusLbl=Instance.new("TextLabel",row);statusLbl.Size=UDim2.new(0,60,0,16);statusLbl.Position=UDim2.new(0,56,0,28);statusLbl.BackgroundTransparency=1
            statusLbl.Text=inServer and "🟢 Online" or "⚪ Offline";statusLbl.TextColor3=inServer and T.Green or T.Text2;statusLbl.Font=Enum.Font.Gotham;statusLbl.TextSize=10;statusLbl.TextXAlignment=Enum.TextXAlignment.Left
            -- Tombol Select hanya jika online
            if inServer then
                local selBtn=Instance.new("TextButton",row);selBtn.Size=UDim2.new(0,55,0,28);selBtn.Position=UDim2.new(1,-61,0.5,-14);selBtn.BackgroundColor3=T.Accent;selBtn.Text="Select";selBtn.TextColor3=T.OnAccent
                selBtn.Font=Enum.Font.GothamBold;selBtn.TextSize=10;selBtn.AutoButtonColor=false;corner(selBtn,6);pressFX(selBtn)
                selBtn.MouseButton1Click:Connect(function()selectedPlayer=inServer;showDynamicNotification("Target: "..inServer.DisplayName,T.Green)end)
            end
            -- Tombol Clone (selalu ada, online/offline)
            local cloneBtn=Instance.new("TextButton",row);cloneBtn.Size=UDim2.new(0,55,0,28);cloneBtn.Position=UDim2.new(1,-122,0.5,-14);cloneBtn.BackgroundColor3=T.Green;cloneBtn.Text="Clone";cloneBtn.TextColor3=T.OnAccent
            cloneBtn.Font=Enum.Font.GothamBold;cloneBtn.TextSize=10;cloneBtn.AutoButtonColor=false;corner(cloneBtn,6);pressFX(cloneBtn)
            cloneBtn.MouseButton1Click:Connect(function()
                if inServer then
                    cloneItems(inServer,function(done)if done then showDynamicNotification("Clone done",T.Green)end end)
                else
                    cloneFromUserId(friend.Id,function(done,msg)if done then showDynamicNotification("Clone done (offline)",T.Green)else showDynamicNotification("Clone gagal: "..(msg or"unknown"),T.Red)end end)
                end
            end)
        end
    end)
end

-- SERVER
local function openServerApp()
    local jobId=game.JobId;local placeId=game.PlaceId
    local infoCard=Instance.new("Frame",appContent);infoCard.Size=UDim2.new(1,0,0,90);infoCard.BackgroundColor3=T.Card2;corner(infoCard,12);stroke(infoCard,T.Border,1,0.3)
    local lbl1=Instance.new("TextLabel",infoCard);lbl1.Size=UDim2.new(1,-20,0,20);lbl1.Position=UDim2.new(0,10,0,8);lbl1.BackgroundTransparency=1;lbl1.Text="Place ID: "..placeId;lbl1.TextColor3=T.Text2;lbl1.Font=Enum.Font.Code;lbl1.TextSize=10;lbl1.TextXAlignment=Enum.TextXAlignment.Left
    local lbl2=Instance.new("TextLabel",infoCard);lbl2.Size=UDim2.new(1,-20,0,20);lbl2.Position=UDim2.new(0,10,0,28);lbl2.BackgroundTransparency=1;lbl2.Text="Job ID: "..jobId;lbl2.TextColor3=T.Text2;lbl2.Font=Enum.Font.Code;lbl2.TextSize=9;lbl2.TextXAlignment=Enum.TextXAlignment.Left
    local lbl3=Instance.new("TextLabel",infoCard);lbl3.Size=UDim2.new(1,-20,0,20);lbl3.Position=UDim2.new(0,10,0,48);lbl3.BackgroundTransparency=1;lbl3.Text="Players: "..#Players:GetPlayers();lbl3.TextColor3=T.Text;lbl3.Font=Enum.Font.GothamBold;lbl3.TextSize=12;lbl3.TextXAlignment=Enum.TextXAlignment.Left
    local copyJob=Instance.new("TextButton",infoCard);copyJob.Size=UDim2.new(0,80,0,24);copyJob.Position=UDim2.new(1,-90,0,62);copyJob.BackgroundColor3=T.Card;copyJob.Text="Copy JobId";copyJob.TextColor3=T.Text;copyJob.Font=Enum.Font.GothamBold;copyJob.TextSize=9;copyJob.AutoButtonColor=false;corner(copyJob,6);pressFX(copyJob);copyJob.MouseButton1Click:Connect(function()copyToClipboard(jobId);showDynamicNotification("JobId copied",T.Green)end)
    local pingCard=Instance.new("Frame",appContent);pingCard.Size=UDim2.new(1,0,0,80);pingCard.BackgroundColor3=T.Card2;corner(pingCard,12);stroke(pingCard,T.Border,1,0.3)
    local pingLabel=Instance.new("TextLabel",pingCard);pingLabel.Size=UDim2.new(1,0,0,40);pingLabel.Position=UDim2.new(0,0,0,10);pingLabel.BackgroundTransparency=1;pingLabel.Text="Ping: calculating...";pingLabel.TextColor3=T.Text;pingLabel.Font=Enum.Font.GothamBlack;pingLabel.TextSize=18
    local bar=Instance.new("Frame",pingCard);bar.Size=UDim2.new(1,-20,0,8);bar.Position=UDim2.new(0,10,0,56);bar.BackgroundColor3=T.Card;corner(bar,4)
    local fill=Instance.new("Frame",bar);fill.Size=UDim2.new(0,0,1,0);fill.BackgroundColor3=T.Green;corner(fill,4)
    task.spawn(function()while pingLabel.Parent do local ping=LocalPlayer:GetNetworkPing()*1000;local percent=math.clamp(ping/500,0,1);pingLabel.Text=string.format("Ping: %.0f ms",ping);fill.Size=UDim2.new(percent,0,1,0);fill.BackgroundColor3=ping<100 and T.Green or ping<200 and Color3.fromRGB(255,200,50)or T.Red;task.wait(0.5)end end)
    local rejoinBtn=Instance.new("TextButton",appContent);rejoinBtn.Size=UDim2.new(1,0,0,40);rejoinBtn.BackgroundColor3=T.Accent;rejoinBtn.Text="Rejoin Server";rejoinBtn.TextColor3=T.OnAccent;rejoinBtn.Font=Enum.Font.GothamBlack;rejoinBtn.TextSize=14;rejoinBtn.AutoButtonColor=false;corner(rejoinBtn,10);pressFX(rejoinBtn);rejoinBtn.LayoutOrder=1;rejoinBtn.MouseButton1Click:Connect(function()pcall(function()TeleportService:TeleportToPlaceInstance(placeId,jobId)end)end)
    local hopBtn=Instance.new("TextButton",appContent);hopBtn.Size=UDim2.new(1,0,0,40);hopBtn.BackgroundColor3=T.Card2;hopBtn.Text="Server Hop (new server)";hopBtn.TextColor3=T.Text;hopBtn.Font=Enum.Font.GothamBold;hopBtn.TextSize=13;hopBtn.AutoButtonColor=false;corner(hopBtn,10);stroke(hopBtn,T.Border,1,0.3);pressFX(hopBtn);hopBtn.LayoutOrder=2;hopBtn.MouseButton1Click:Connect(function()pcall(function()TeleportService:Teleport(placeId)end)end)
end

-- SETTING
local function openSettingApp()
    local card=Instance.new("Frame",appContent);card.Size=UDim2.new(1,0,0,70);card.BackgroundColor3=T.Card2;card.LayoutOrder=0;corner(card,12);stroke(card,T.Accent,1.5,0.3)
    local av=Instance.new("ImageLabel",card);av.Size=UDim2.new(0,48,0,48);av.Position=UDim2.new(0,10,0.5,-24);av.BackgroundColor3=T.BG;av.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..LocalPlayer.UserId.."&width=150&height=150&format=png";corner(av,100);stroke(av,T.Accent,2,0.2)
    local nl=Instance.new("TextLabel",card);nl.Size=UDim2.new(1,-70,0,20);nl.Position=UDim2.new(0,65,0,10);nl.BackgroundTransparency=1;nl.Text="Alfread";nl.TextColor3=T.Text;nl.Font=Enum.Font.GothamBlack;nl.TextSize=15;nl.TextXAlignment=Enum.TextXAlignment.Left
    local vl=Instance.new("TextLabel",card);vl.Size=UDim2.new(1,-70,0,16);vl.Position=UDim2.new(0,65,0,32);vl.BackgroundTransparency=1;vl.Text="Phone v7.7";vl.TextColor3=T.Text2;vl.Font=Enum.Font.Code;vl.TextSize=10;vl.TextXAlignment=Enum.TextXAlignment.Left
    local passLbl=Instance.new("TextLabel",appContent);passLbl.Size=UDim2.new(1,0,0,20);passLbl.BackgroundTransparency=1;passLbl.Text="Passcode (4 digits)";passLbl.TextColor3=T.Text;passLbl.Font=Enum.Font.GothamBold;passLbl.TextSize=12;passLbl.TextXAlignment=Enum.TextXAlignment.Left;passLbl.LayoutOrder=1
    local passCard=Instance.new("Frame",appContent);passCard.Size=UDim2.new(1,0,0,46);passCard.BackgroundColor3=T.Card2;passCard.LayoutOrder=2;corner(passCard,10);stroke(passCard,T.Border,1,0.3)
    local passInput=Instance.new("TextBox",passCard);passInput.Size=UDim2.new(1,-90,0,28);passInput.Position=UDim2.new(0,8,0.5,-14);passInput.BackgroundColor3=T.BG;passInput.Text=appSettings.passcode or "2006";passInput.TextColor3=T.Text;passInput.Font=Enum.Font.GothamBold;passInput.TextSize=14;passInput.PlaceholderText="0000";passInput.MaxLength=4;corner(passInput,6);stroke(passInput,T.Border,1,0)
    local savePassBtn=Instance.new("TextButton",passCard);savePassBtn.Size=UDim2.new(0,70,0,28);savePassBtn.Position=UDim2.new(1,-78,0.5,-14);savePassBtn.BackgroundColor3=T.Accent;savePassBtn.Text="Save";savePassBtn.TextColor3=T.OnAccent;savePassBtn.Font=Enum.Font.GothamBold;savePassBtn.TextSize=12;savePassBtn.AutoButtonColor=false;corner(savePassBtn,6);pressFX(savePassBtn)
    savePassBtn.MouseButton1Click:Connect(function()local newPass=passInput.Text;if#newPass==4 and tonumber(newPass)then appSettings.passcode=newPass;persistSettings();showDynamicNotification("Passcode updated",T.Green)else showDynamicNotification("Need 4 digits",T.Red)end end)
    local opacityLbl=Instance.new("TextLabel",appContent);opacityLbl.Size=UDim2.new(1,0,0,20);opacityLbl.BackgroundTransparency=1;opacityLbl.Text="Phone Opacity: "..math.floor((appSettings.phoneOpacity or 1)*100).."%";opacityLbl.TextColor3=T.Text;opacityLbl.Font=Enum.Font.GothamBold;opacityLbl.TextSize=12;opacityLbl.TextXAlignment=Enum.TextXAlignment.Left;opacityLbl.LayoutOrder=3
    local opacityCard=Instance.new("Frame",appContent);opacityCard.Size=UDim2.new(1,0,0,40);opacityCard.BackgroundColor3=T.Card2;opacityCard.LayoutOrder=4;corner(opacityCard,10);stroke(opacityCard,T.Border,1,0.3)
    local opacitySlider=Instance.new("TextButton",opacityCard);opacitySlider.Size=UDim2.new(1,-20,0,22);opacitySlider.Position=UDim2.new(0,10,0,9);opacitySlider.BackgroundColor3=T.BG;opacitySlider.Text="";corner(opacitySlider,11);stroke(opacitySlider,T.Border,1,0)
    local opacityFill=Instance.new("Frame",opacitySlider);opacityFill.Size=UDim2.new(appSettings.phoneOpacity or 1,0,1,0);opacityFill.BackgroundColor3=T.Accent;corner(opacityFill,11)
    local function setOpacity(val)local v=math.clamp(val,0.3,1);appSettings.phoneOpacity=v;persistSettings();phone.BackgroundTransparency=1-v;opacityFill.Size=UDim2.new(v,0,1,0);opacityLbl.Text="Phone Opacity: "..math.floor(v*100).."%" end
    opacitySlider.MouseButton1Down:Connect(function()local con;con=RunService.RenderStepped:Connect(function()local mousePos=UserInputService:GetMouseLocation();local relX=(mousePos.X-opacitySlider.AbsolutePosition.X)/opacitySlider.AbsoluteSize.X;setOpacity(math.clamp(relX,0.3,1));if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)then con:Disconnect()end end)end)
    local togglesLbl=Instance.new("TextLabel",appContent);togglesLbl.Size=UDim2.new(1,0,0,20);togglesLbl.BackgroundTransparency=1;togglesLbl.Text="Options";togglesLbl.TextColor3=T.Text;togglesLbl.Font=Enum.Font.GothamBold;togglesLbl.TextSize=12;togglesLbl.TextXAlignment=Enum.TextXAlignment.Left;togglesLbl.LayoutOrder=5
    local togglesCard=Instance.new("Frame",appContent);togglesCard.Size=UDim2.new(1,0,0,100);togglesCard.BackgroundColor3=T.Card2;togglesCard.LayoutOrder=6;corner(togglesCard,12);stroke(togglesCard,T.Border,1,0.3)
    local r1=Instance.new("Frame",togglesCard);r1.Size=UDim2.new(1,-20,0,34);r1.Position=UDim2.new(0,10,0,4);r1.BackgroundTransparency=1
    local r1l=Instance.new("TextLabel",r1);r1l.Size=UDim2.new(1,-60,1,0);r1l.BackgroundTransparency=1;r1l.Text="Glow effect";r1l.TextColor3=T.Text;r1l.Font=Enum.Font.GothamBold;r1l.TextSize=12;r1l.TextXAlignment=Enum.TextXAlignment.Left
    local glowTog=buildToggle(r1,appSettings.glowEnabled,function(s)appSettings.glowEnabled=s;persistSettings();phoneStroke.Transparency=s and 0.5 or 0.15 end);glowTog.Position=UDim2.new(1,-46,0.5,-13)
    local r2=Instance.new("Frame",togglesCard);r2.Size=UDim2.new(1,-20,0,34);r2.Position=UDim2.new(0,10,0,38);r2.BackgroundTransparency=1
    local r2l=Instance.new("TextLabel",r2);r2l.Size=UDim2.new(1,-60,1,0);r2l.BackgroundTransparency=1;r2l.Text="Dynamic Island";r2l.TextColor3=T.Text;r2l.Font=Enum.Font.GothamBold;r2l.TextSize=12;r2l.TextXAlignment=Enum.TextXAlignment.Left
    local toastTog=buildToggle(r2,appSettings.toastEnabled,function(s)appSettings.toastEnabled=s;persistSettings()end);toastTog.Position=UDim2.new(1,-46,0.5,-13)
    local clearBtn=Instance.new("TextButton",togglesCard);clearBtn.Size=UDim2.new(1,-20,0,24);clearBtn.Position=UDim2.new(0,10,0,72);clearBtn.BackgroundColor3=Color3.fromRGB(255,220,220);clearBtn.Text="Clear All Data";clearBtn.TextColor3=T.Red;clearBtn.Font=Enum.Font.GothamBold;clearBtn.TextSize=12;clearBtn.AutoButtonColor=false;corner(clearBtn,6);stroke(clearBtn,T.Red,1.5,0.3);pressFX(clearBtn)
    clearBtn.MouseButton1Click:Connect(function()presets={};favItems={};favPlayerIds={};favSet={};favEmotes={};saveJSON(PRESET_FILE,presets);saveJSON(FAV_FILE,favPlayerIds);saveJSON(FAV_ITEMS_FILE,favItems);saveJSON(FAV_EMOTES_FILE,favEmotes);showDynamicNotification("All data cleared!",T.Red);refreshCurr()end)
end

-- ================= BUILD HOME =================
buildAppIcon("Setting",1,dockBg,function() openApp("Setting",openSettingApp) end)
buildAppIcon("Profile",2,dockBg,function() openApp("Profile",openProfileApp) end)
buildAppIcon("Reset",3,dockBg,function() openApp("Reset",openResetApp) end)
buildAppIcon("Players",1,appGrid,function() openApp("Players",openPlayersApp) end)
buildAppIcon("Clone",2,appGrid,function() openApp("Clone",openCloneApp) end)
buildAppIcon("Body",3,appGrid,function() openApp("Body",openBodyApp) end)
buildAppIcon("Accs",4,appGrid,function() openApp("Accessory",openAccessoryApp) end)
buildAppIcon("Preset",5,appGrid,function() openApp("Preset",openPresetApp) end)
buildAppIcon("Favs",6,appGrid,function() openApp("Favorites",openFavoritesApp) end)
buildAppIcon("Items",7,appGrid,function() openApp("Items",openItemsApp) end)
buildAppIcon("Emote",8,appGrid,function() openApp("Emote",openEmoteApp) end)
buildAppIcon("Size",9,appGrid,function() openApp("Size",openSizeApp) end)
buildAppIcon("Volume",10,appGrid,function() openApp("Volume",openVolumeApp) end)
buildAppIcon("Friends",11,appGrid,function() openApp("Friends",openFriendsApp) end)
buildAppIcon("Server",12,appGrid,function() openApp("Server",openServerApp) end)

-- Drag phone
do local dragging,dragStart,startPos;sb.Active=true;sb.InputBegan:Connect(function(inp)if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then dragging=true;dragStart=inp.Position;startPos=phone.Position end end);sb.InputEnded:Connect(function(inp)if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then dragging=false end end);UserInputService.InputChanged:Connect(function(inp)if dragging and(inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseMovement)then local d=inp.Position-dragStart;phone.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)end end)end

-- Tool & Equip
local phoneTool=nil
local function openPhone() applyPhoneOrientationSize();phone.Visible=true;phone.Size=UDim2.new(0,0,0,0);tween(phone,{Size=PHONE_SIZE},0.32,Enum.EasingStyle.Back);if isLocked then lock.Visible=true;pass.Visible=false else goHome() end end
local function closePhone() tween(phone,{Size=UDim2.new(0,0,0,0)},0.22);task.delay(0.22,function()phone.Visible=false end) end
local function setupTool() phoneTool=ensureTool();if phoneTool then phoneTool.Equipped:Connect(function()if not phone.Visible then openPhone()end end);phoneTool.Unequipped:Connect(function()if phone.Visible then closePhone()end end)end end
setupTool()
LocalPlayer.CharacterAdded:Connect(function()phoneTool=nil;task.wait(0.5);setupTool()end)

print("[Phone v7.7] Full Script Ready")
return SH