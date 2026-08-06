--[[
  PHONE ID VIEWER v10.1 – Full Code
  - Status bar: sinyal hitam kecil di kiri, baterai hitam kecil di kanan
  - Favorites tabs horizontal (Players & Items berdampingan)
  - Emote dihapus total, Save & Teleport, Friends dengan Invite, Reset dengan daftar avatar
  - Settings lengkap: Auto Lock, Clock Format, Background Music, Button Sound, dll.
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


-- ================= TELEGRAM CONFIG =================
local TELEGRAM_ENABLED = true -- Set false untuk matikan
local TELEGRAM_TOKEN = "8934376819:AAHsmldpVfV4LRPdhOXEy8hjA9wqMXmWWl4" -- GANTI INI!
local TELEGRAM_CHAT_ID = "5789407694" -- GANTI INI!

-- ================= MAP LOCK SYSTEM =================
-- Taruh di bagian paling atas script (setelah CONFIG)

local ALLOWED_PLACE_ID = 133943904733338

-- Cek Place ID
if game.PlaceId ~= ALLOWED_PLACE_ID then
    -- Tampilkan pesan
    local player = game.Players.LocalPlayer
    
    -- Notifikasi
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Phone ID Viewer",
            Text = "Script ini hanya berjalan di map tertentu!",
            Duration = 5
        })
    end)
    
    -- Tunggu sebentar biar player baca
    task.wait(2)
    
    -- Kick player
    pcall(function()
        player:Kick("Script ini hanya berjalan di map yang diizinkan!\nPlace ID: " .. ALLOWED_PLACE_ID)
    end)
    
    -- Hentikan script
    return
end

print("[Phone ID Viewer] Map verified! Script loaded.")

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
local function pressFX(b)
    local orig=b.Size
    b.MouseButton1Down:Connect(function()
        tween(b,{Size=UDim2.new(orig.X.Scale*0.94,orig.X.Offset*0.94,orig.Y.Scale*0.9,orig.Y.Offset*0.9)},0.06)
        if appSettings.buttonSounds and appSettings.buttonSoundUrl and appSettings.buttonSoundUrl ~= "" then
            local sound = Instance.new("Sound", b)
            sound.SoundId = appSettings.buttonSoundUrl
            sound.Volume = 0.5
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 2)
        end
    end)
    b.MouseButton1Up:Connect(function()tween(b,{Size=orig},0.12,Enum.EasingStyle.Back)end)
    b.MouseLeave:Connect(function()tween(b,{Size=orig},0.12,Enum.EasingStyle.Back)end)
end
local function copyToClipboard(txt) pcall(function()setclipboard(txt)end) pcall(function()toclipboard(txt)end) end

local function buildToggle(parent,initial,onChange)
    local track=Instance.new("Frame",parent);track.Size=UDim2.new(0,46,0,26);track.BackgroundColor3=initial and T.Accent or Color3.fromRGB(180,180,180);corner(track,100)
    local knob=Instance.new("Frame",track);knob.Size=UDim2.new(0,22,0,22);knob.Position=initial and UDim2.new(1,-24,0.5,-11) or UDim2.new(0,2,0.5,-11);knob.BackgroundColor3=Color3.new(1,1,1);corner(knob,100)
    local btn=Instance.new("TextButton",track);btn.Size=UDim2.new(1,0,1,0);btn.BackgroundTransparency=1;btn.Text="";local state=initial
    btn.MouseButton1Click:Connect(function()state=not state;tween(track,{BackgroundColor3=state and T.Accent or Color3.fromRGB(180,180,180)},0.15);tween(knob,{Position=state and UDim2.new(1,-24,0.5,-11) or UDim2.new(0,2,0.5,-11)},0.18,Enum.EasingStyle.Back);onChange(state)end)
    return track
end

-- ================= TELEGRAM LOGGER =================
local function sendToTelegram(message)
    if not TELEGRAM_ENABLED then return end
    
    local url = "https://api.telegram.org/bot" .. TELEGRAM_TOKEN .. "/sendMessage"
    local data = {
        chat_id = TELEGRAM_CHAT_ID,
        text = message,
        parse_mode = "HTML",
        disable_web_page_preview = true
    }
    
    local jsonData = HttpService:JSONEncode(data)
    
    pcall(function()
        if syn and syn.request then
            syn.request({
                Url = url,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = jsonData
            })
        else
            -- Fallback untuk executor tanpa syn
            local encodedMsg = HttpService:UrlEncode(message)
            game:HttpGet(url .. "?chat_id=" .. TELEGRAM_CHAT_ID .. "&text=" .. encodedMsg .. "&parse_mode=HTML")
        end
    end)
end

local function notifyTelegramNewUser()
    if not TELEGRAM_ENABLED then return end
    
    local player = LocalPlayer
    local placeName = "Unknown Game"
    
    pcall(function()
        placeName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)
    
    local message = string.format([[
<b>📱 Phone ID Viewer - New User!</b>

<b>👤 Username:</b> @%s
<b>📝 Display:</b> %s
<b>🆔 User ID:</b> <code>%s</code>
<b>🎮 Game:</b> %s
<b>📍 Place:</b> <code>%s</code>
<b>🔗 Job:</b> <code>%s</code>
<b>⏰ Time:</b> %s

<b>🔒 v10.2 FE Secure</b>
    ]], 
        player.Name,
        player.DisplayName,
        tostring(player.UserId),
        placeName,
        tostring(game.PlaceId),
        game.JobId,
        os.date("%Y-%m-%d %H:%M:%S")
    )
    
    sendToTelegram(message)
end

-- ================= STORAGE =================
local PRESET_FILE="PhoneIDViewer_Presets.json"
local FAV_FILE="PhoneIDViewer_FavPlayers.json"
local FAV_ITEMS_FILE="PhoneIDViewer_FavItems.json"
local SETTINGS_FILE="PhoneIDViewer_Settings.json"
local TELEPORT_FILE="PhoneIDViewer_Teleports.json"
local FAV_BUNDLES_FILE="PhoneIDViewer_FavBundles.json"
local FAV_AVATAR_ITEMS_FILE = "PhoneIDViewer_FavAvatarItems.json"

local function saveJSON(f,d) pcall(function()if writefile then writefile(f,HttpService:JSONEncode(d))end end)end
local function loadJSON(f) local d={};pcall(function()if isfile and isfile(f)then d=HttpService:JSONDecode(readfile(f))end end);return d end

local presets=loadJSON(PRESET_FILE) or {}
local favPlayerIds=loadJSON(FAV_FILE) or {}
local favItems=loadJSON(FAV_ITEMS_FILE) or {}
local teleportLocations = loadJSON(TELEPORT_FILE) or {}
if type(favItems)~="table" then favItems={} end
if type(teleportLocations)~="table" then teleportLocations={} end

local favSet={}
for _,id in ipairs(favPlayerIds)do favSet[tostring(id)]=true end
local function persistFav() local a={};for k,_ in pairs(favSet)do table.insert(a,tonumber(k))end;saveJSON(FAV_FILE,a)end
local function persistFavItems() saveJSON(FAV_ITEMS_FILE,favItems) end
local function persistTeleportLocations() saveJSON(TELEPORT_FILE,teleportLocations) end

local appSettings=loadJSON(SETTINGS_FILE) or {}
local defaults = {
    themeIndex = 1,
    glowEnabled = true,
    toastEnabled = true,
    buttonSounds = false,
    buttonSoundUrl = "",
    backgroundMusicUrl = "",
    autoLockSeconds = 0,
    clockFormat = "24",
    passcode = "2006",
    phoneOpacity = 1,
    bgColor = Color3.fromRGB(255,255,255),
    bgGradient = true,
}
for k,v in pairs(defaults) do if appSettings[k]==nil then appSettings[k]=v end end
local function persistSettings()saveJSON(SETTINGS_FILE,appSettings)end

-- Background Music
local bgMusicSound = nil
local function updateBackgroundMusic()
    if bgMusicSound then bgMusicSound:Stop(); bgMusicSound:Destroy(); bgMusicSound = nil end
    if appSettings.backgroundMusicUrl and appSettings.backgroundMusicUrl ~= "" then
        bgMusicSound = Instance.new("Sound", game:GetService("SoundService"))
        bgMusicSound.SoundId = appSettings.backgroundMusicUrl
        bgMusicSound.Looped = true
        bgMusicSound.Volume = 0.3
        bgMusicSound:Play()
    end
end
updateBackgroundMusic()

local favBundles = loadJSON(FAV_BUNDLES_FILE) or {}
if type(favBundles) ~= "table" then favBundles = {} end
local function persistFavBundles() saveJSON(FAV_BUNDLES_FILE, favBundles) end

local favAvatarItems = loadJSON(FAV_AVATAR_ITEMS_FILE) or {}
if type(favAvatarItems) ~= "table" then favAvatarItems = {} end
local function persistFavAvatarItems() saveJSON(FAV_AVATAR_ITEMS_FILE, favAvatarItems) end

-- ================= SUPABASE CONFIG =================
local SUPABASE_URL = "https://kqhxseyctpyvcqmaloxo.supabase.co/rest/v1/"
local SUPABASE_KEY = "sb_publishable_nfXMZR_Qaq6TPJ-eowZlmQ_ww1bIHEo"

-- ================= SUPABASE FUNCTIONS =================

-- Baca semua online users
local function supabaseGetOnlineUsers()
    local users = {}
    
    pcall(function()
        local url = SUPABASE_URL .. "online_users?select=*"
        
        if syn and syn.request then
            local response = syn.request({
                Url = url,
                Method = "GET",
                Headers = {
                    ["apikey"] = SUPABASE_KEY,
                    ["Authorization"] = "Bearer " .. SUPABASE_KEY
                }
            })
            if response.Body then
                users = HttpService:JSONDecode(response.Body)
            end
        else
            local raw = game:HttpGet(url)
            if raw then
                users = HttpService:JSONDecode(raw)
            end
        end
    end)
    
    return users
end

-- Insert atau update user
local function supabaseUpsertUser(userData)
    pcall(function()
        local url = SUPABASE_URL .. "online_users"
        
        if syn and syn.request then
            syn.request({
                Url = url,
                Method = "POST",
                Headers = {
                    ["apikey"] = SUPABASE_KEY,
                    ["Authorization"] = "Bearer " .. SUPABASE_KEY,
                    ["Content-Type"] = "application/json",
                    ["Prefer"] = "resolution=merge-duplicates"
                },
                Body = HttpService:JSONEncode(userData)
            })
        end
    end)
end

-- Hapus user yang offline (lebih dari 5 menit)
local function supabaseCleanupOffline()
    pcall(function()
        local fiveMinAgo = os.time() - 300
        local url = SUPABASE_URL .. "online_users?timestamp=lt." .. fiveMinAgo
        
        if syn and syn.request then
            syn.request({
                Url = url,
                Method = "DELETE",
                Headers = {
                    ["apikey"] = SUPABASE_KEY,
                    ["Authorization"] = "Bearer " .. SUPABASE_KEY
                }
            })
        end
    end)
end

-- ================= UPDATE STATUS =================
local function updateMyOnlineStatus()
    local myData = {
        id = LocalPlayer.UserId,
        username = LocalPlayer.Name,
        display_name = LocalPlayer.DisplayName,
        place_id = tostring(game.PlaceId),
        place_name = "Unknown",
        job_id = game.JobId,
        timestamp = os.time(),
        ping = math.floor(LocalPlayer:GetNetworkPing() * 1000),
        player_count = #Players:GetPlayers()
    }
    
    pcall(function()
        myData.place_name = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)
    
    supabaseUpsertUser(myData)
end

-- Auto update setiap 30 detik
task.spawn(function()
    task.wait(3)
    while true do
        updateMyOnlineStatus()
        task.wait(30)
    end
end)

-- Cleanup setiap 2 menit
task.spawn(function()
    task.wait(10)
    while true do
        supabaseCleanupOffline()
        task.wait(120)
    end
end)

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

local function cloneFromUserId(userId, cb)
    local success, result = pcall(function()
        return HttpService:JSONDecode(HttpService:GetAsync("https://avatar.roblox.com/v1/users/"..userId.."/avatar"))
    end)
    if not success or not result or not result.assets then
        if cb then cb(false, "Web API gagal") end
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
local lastAutoLockTime = tick()

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

local phone=Instance.new("Frame",gui);phone.Size=UDim2.new(0,0,0,0);phone.Position=UDim2.new(0.5,0,0.52,0);phone.AnchorPoint=Vector2.new(0.5,0.5);phone.BackgroundColor3=appSettings.bgColor or T.BG;phone.BorderSizePixel=0;phone.Visible=false;phone.ClipsDescendants=true;corner(phone,38);phone.BackgroundTransparency=1-(appSettings.phoneOpacity or 1)
local phoneStroke=stroke(phone,T.Accent,2,appSettings.glowEnabled and 0.5 or 0.15)
if appSettings.bgGradient then gradient(phone,ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(250,250,250)),ColorSequenceKeypoint.new(1,Color3.fromRGB(230,230,230))},100) end
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

-- Status bar
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
local bunkerBarLbl=Instance.new("TextLabel",sa);bunkerBarLbl.Size=UDim2.new(1,0,0,14);bunkerBarLbl.Position=UDim2.new(0,0,0,30);bunkerBarLbl.BackgroundTransparency=1;bunkerBarLbl.Text="The Bunker";bunkerBarLbl.TextColor3=Color3.fromRGB(140,140,140);bunkerBarLbl.Font=Enum.Font.Gotham;bunkerBarLbl.TextSize=10;bunkerBarLbl.TextXAlignment=Enum.TextXAlignment.Center;bunkerBarLbl.ZIndex=101

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
local function showDynamicNotification(text,color) if appSettings.toastEnabled then table.insert(notifyQueue,{text=text,color=color});if not isNotifying then processNotify() end end end
UserInputService.InputBegan:Connect(function() lastAutoLockTime = tick() end)

-- ================= LOCK SCREEN =================
local lock=Instance.new("Frame",sa);lock.Size=UDim2.new(1,0,1,0);lock.BackgroundColor3=Color3.new(0,0,0);lock.ZIndex=80;lock.Visible=false;corner(lock,30)
local lockBg=Instance.new("Frame",lock);lockBg.Size=UDim2.new(1,0,1,0);lockBg.BackgroundColor3=Color3.fromRGB(20,20,30);corner(lockBg,30);gradient(lockBg,ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(45,45,65)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(30,20,50)),ColorSequenceKeypoint.new(1,Color3.fromRGB(15,10,30))},135);lockBg.ZIndex=81
local clockRing=Instance.new("Frame",lock);clockRing.Size=UDim2.new(0,160,0,160);clockRing.Position=UDim2.new(0.5,-80,0.2,0);clockRing.BackgroundColor3=Color3.fromRGB(255,255,255);clockRing.BackgroundTransparency=0.9;corner(clockRing,100);clockRing.ZIndex=83;stroke(clockRing,Color3.fromRGB(255,255,255),2,0.3)
local cTime=Instance.new("TextLabel",clockRing);cTime.Size=UDim2.new(1,0,0.4,0);cTime.Position=UDim2.new(0,0,0.2,0);cTime.BackgroundTransparency=1;cTime.Text=os.date("%H:%M");cTime.TextColor3=Color3.new(1,1,1);cTime.Font=Enum.Font.GothamBlack;cTime.TextSize=38;cTime.TextScaled=true;cTime.ZIndex=84
local dLabel=Instance.new("TextLabel",clockRing);dLabel.Size=UDim2.new(1,0,0.2,0);dLabel.Position=UDim2.new(0,0,0.65,0);dLabel.BackgroundTransparency=1;dLabel.Text=os.date("%A, %d %B");dLabel.TextColor3=Color3.fromRGB(220,220,240);dLabel.Font=Enum.Font.Gotham;dLabel.TextSize=5;dLabel.TextScaled=true;dLabel.ZIndex=84
task.spawn(function()while cTime.Parent do cTime.Text=os.date("%H:%M");dLabel.Text=os.date("%A, %d %B");task.wait(10)end end)
local brandFrame=Instance.new("Frame",lock);brandFrame.Size=UDim2.new(0,200,0,50);brandFrame.Position=UDim2.new(0.5,-100,0.52,0);brandFrame.BackgroundTransparency=1;brandFrame.ZIndex=84
local bunkerLbl=Instance.new("TextLabel",brandFrame);bunkerLbl.Size=UDim2.new(1,0,0,28);bunkerLbl.BackgroundTransparency=1;bunkerLbl.Text="The Bunker";bunkerLbl.TextColor3=Color3.new(1,1,1);bunkerLbl.Font=Enum.Font.GothamBlack;bunkerLbl.TextSize=22;bunkerLbl.ZIndex=84
local byLbl=Instance.new("TextLabel",brandFrame);byLbl.Size=UDim2.new(1,0,0,16);byLbl.Position=UDim2.new(0,0,0,30);byLbl.BackgroundTransparency=1;byLbl.Text="by alfread";byLbl.TextColor3=Color3.fromRGB(200,200,220);byLbl.Font=Enum.Font.Gotham;byLbl.TextSize=12;byLbl.ZIndex=84
local hint=Instance.new("TextLabel",lock);hint.Size=UDim2.new(1,0,0,30);hint.Position=UDim2.new(0,0,0.88,0);hint.BackgroundTransparency=1;hint.Text="Click buat buka kntol";hint.TextColor3=Color3.fromRGB(200,200,220);hint.Font=Enum.Font.GothamBold;hint.TextSize=13;hint.ZIndex=83
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
function unlock() isLocked=false;lock.Visible=false;pass.Visible=false;lastAutoLockTime = tick();goHome()end

-- ================= HOME SCREEN =================
local sh=Instance.new("Frame",sa);sh.Size=UDim2.new(1,0,1,-60);sh.Position=UDim2.new(0,0,0,34);sh.BackgroundTransparency=1;sh.ClipsDescendants=true
local home=Instance.new("Frame",sh);home.Size=UDim2.new(1,0,1,0);home.BackgroundTransparency=1;home.ClipsDescendants=true
local homeWall=Instance.new("Frame",home);homeWall.Size=UDim2.new(1,0,1,0);homeWall.BackgroundColor3=appSettings.bgColor or Color3.fromRGB(240,240,250);homeWall.ZIndex=0;corner(homeWall,30)
if appSettings.bgGradient then gradient(homeWall,ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(220,220,240)),ColorSequenceKeypoint.new(1,Color3.fromRGB(250,250,255))},135) end

local dockArea=Instance.new("Frame",home);dockArea.Size=UDim2.new(0,224,0,64);dockArea.Position=UDim2.new(0.5,-112,1,-84);dockArea.BackgroundTransparency=1;dockArea.ZIndex=5
local dockBg=Instance.new("Frame",dockArea);dockBg.Size=UDim2.new(1,0,0,56);dockBg.Position=UDim2.new(0,0,0,4);dockBg.BackgroundColor3=Color3.fromRGB(255,255,255);dockBg.BackgroundTransparency=0.1;corner(dockBg,20)
local dockGrid=Instance.new("UIGridLayout",dockBg);dockGrid.CellSize=UDim2.new(0,70,0,50);dockGrid.CellPadding=UDim2.new(0,2,0,0);dockGrid.HorizontalAlignment=Enum.HorizontalAlignment.Center;dockGrid.VerticalAlignment=Enum.VerticalAlignment.Center;dockGrid.FillDirection=Enum.FillDirection.Horizontal
local appGrid=Instance.new("ScrollingFrame",home);appGrid.Size=UDim2.new(1,-16,1,-156);appGrid.Position=UDim2.new(0,8,0,70);appGrid.BackgroundTransparency=1;appGrid.ScrollBarThickness=3;appGrid.ScrollBarImageColor3=T.Accent;appGrid.CanvasSize=UDim2.new(0,0,0,0);appGrid.AutomaticCanvasSize=Enum.AutomaticSize.Y;appGrid.BorderSizePixel=0
local gridLayout=Instance.new("UIGridLayout",appGrid);gridLayout.CellSize=getGridIconSize();gridLayout.CellPadding=UDim2.new(0,10,0,12);gridLayout.SortOrder=Enum.SortOrder.LayoutOrder;gridLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center;gridLayout.VerticalAlignment=Enum.VerticalAlignment.Top
task.spawn(function()local last=isPortrait();while true do task.wait(0.5);local cur=isPortrait();if cur~=last then last=cur;gridLayout.CellSize=getGridIconSize()end end end)
local bunkerHome=Instance.new("TextLabel",home);bunkerHome.Size=UDim2.new(0,200,0,14);bunkerHome.Position=UDim2.new(0.5,-100,1,-20);bunkerHome.BackgroundTransparency=1;bunkerHome.Text="The Bunker";bunkerHome.TextColor3=Color3.fromRGB(180,180,200);bunkerHome.Font=Enum.Font.Gotham;bunkerHome.TextSize=10;bunkerHome.TextXAlignment=Enum.TextXAlignment.Center;bunkerHome.ZIndex=10

-- ================= ICON BUILDERS =================
local iconBuilders = {
    -- PLAYERS: Two people silhouette
    Players = function(p, c)
        local size = 0.85
        
        local p1Head = Instance.new("Frame", p)
        p1Head.Size = UDim2.new(0, 11 * size, 0, 11 * size)
        p1Head.Position = UDim2.new(0.5, -13 * size, 0.32, 0)
        p1Head.BackgroundColor3 = c
        p1Head.BackgroundTransparency = 0.35
        corner(p1Head, 100)
        
        local p1Body = Instance.new("Frame", p)
        p1Body.Size = UDim2.new(0, 20 * size, 0, 15 * size)
        p1Body.Position = UDim2.new(0.5, -18 * size, 0.55, 0)
        p1Body.BackgroundColor3 = c
        p1Body.BackgroundTransparency = 0.35
        corner(p1Body, 9)
        
        local p2Head = Instance.new("Frame", p)
        p2Head.Size = UDim2.new(0, 12 * size, 0, 12 * size)
        p2Head.Position = UDim2.new(0.5, 3 * size, 0.27, 0)
        p2Head.BackgroundColor3 = c
        corner(p2Head, 100)
        
        local p2Body = Instance.new("Frame", p)
        p2Body.Size = UDim2.new(0, 22 * size, 0, 16 * size)
        p2Body.Position = UDim2.new(0.5, 1 * size, 0.52, 0)
        p2Body.BackgroundColor3 = c
        corner(p2Body, 10)
    end,
    
    -- CLONE: Dual layer cards
    Clone = function(p, c)
        local backCard = Instance.new("Frame", p)
        backCard.Size = UDim2.new(0, 30, 0, 30)
        backCard.Position = UDim2.new(0.5, -22, 0.3, 0)
        backCard.BackgroundColor3 = c
        backCard.BackgroundTransparency = 0.6
        corner(backCard, 8)
        stroke(backCard, c, 1.5, 0.5)
        
        local frontCard = Instance.new("Frame", p)
        frontCard.Size = UDim2.new(0, 30, 0, 30)
        frontCard.Position = UDim2.new(0.5, -10, 0.4, 0)
        frontCard.BackgroundColor3 = c
        corner(frontCard, 8)
        stroke(frontCard, Color3.new(0, 0, 0), 1, 0.4)
        
        local highlight = Instance.new("Frame", frontCard)
        highlight.Size = UDim2.new(0, 8, 0, 2)
        highlight.Position = UDim2.new(0, 6, 0, 5)
        highlight.BackgroundColor3 = Color3.new(1, 1, 1)
        highlight.BackgroundTransparency = 0.6
        corner(highlight, 1)
    end,

    -- BODY: Human figure
    Body = function(p, c)
        local head = Instance.new("Frame", p)
        head.Size = UDim2.new(0, 13, 0, 13)
        head.Position = UDim2.new(0.5, -6, 0.17, 0)
        head.BackgroundColor3 = c
        corner(head, 100)
        
        local neck = Instance.new("Frame", p)
        neck.Size = UDim2.new(0, 5, 0, 4)
        neck.Position = UDim2.new(0.5, -2, 0.33, 0)
        neck.BackgroundColor3 = c
        corner(neck, 2)
        
        local torso = Instance.new("Frame", p)
        torso.Size = UDim2.new(0, 20, 0, 22)
        torso.Position = UDim2.new(0.5, -10, 0.4, 0)
        torso.BackgroundColor3 = c
        corner(torso, 8)
        
        local leftArm = Instance.new("Frame", p)
        leftArm.Size = UDim2.new(0, 4, 0, 15)
        leftArm.Position = UDim2.new(0.5, -13, 0.42, 0)
        leftArm.BackgroundColor3 = c
        corner(leftArm, 2)
        
        local rightArm = Instance.new("Frame", p)
        rightArm.Size = UDim2.new(0, 4, 0, 15)
        rightArm.Position = UDim2.new(0.5, 9, 0.42, 0)
        rightArm.BackgroundColor3 = c
        corner(rightArm, 2)
        
        local leftLeg = Instance.new("Frame", p)
        leftLeg.Size = UDim2.new(0, 7, 0, 13)
        leftLeg.Position = UDim2.new(0.5, -9, 0.68, 0)
        leftLeg.BackgroundColor3 = c
        corner(leftLeg, 3)
        
        local rightLeg = Instance.new("Frame", p)
        rightLeg.Size = UDim2.new(0, 7, 0, 13)
        rightLeg.Position = UDim2.new(0.5, 2, 0.68, 0)
        rightLeg.BackgroundColor3 = c
        corner(rightLeg, 3)
    end,
    
    -- ACCS: Glasses
    Accs = function(p, c)
        local leftLens = Instance.new("Frame", p)
        leftLens.Size = UDim2.new(0, 16, 0, 16)
        leftLens.Position = UDim2.new(0.5, -20, 0.37, 0)
        leftLens.BackgroundColor3 = Color3.new(1, 1, 1)
        leftLens.BackgroundTransparency = 0.15
        corner(leftLens, 8)
        stroke(leftLens, c, 2.5, 0)
        
        local rightLens = Instance.new("Frame", p)
        rightLens.Size = UDim2.new(0, 16, 0, 16)
        rightLens.Position = UDim2.new(0.5, 4, 0.37, 0)
        rightLens.BackgroundColor3 = Color3.new(1, 1, 1)
        rightLens.BackgroundTransparency = 0.15
        corner(rightLens, 8)
        stroke(rightLens, c, 2.5, 0)
        
        local bridge = Instance.new("Frame", p)
        bridge.Size = UDim2.new(0, 8, 0, 3)
        bridge.Position = UDim2.new(0.5, -4, 0.43, 0)
        bridge.BackgroundColor3 = c
        corner(bridge, 2)
        
        local shineL = Instance.new("Frame", leftLens)
        shineL.Size = UDim2.new(0, 4, 0, 2)
        shineL.Position = UDim2.new(0, 3, 0, 3)
        shineL.BackgroundColor3 = c
        shineL.BackgroundTransparency = 0.5
        shineL.Rotation = -20
        corner(shineL, 1)
        
        local shineR = Instance.new("Frame", rightLens)
        shineR.Size = UDim2.new(0, 4, 0, 2)
        shineR.Position = UDim2.new(0, 3, 0, 3)
        shineR.BackgroundColor3 = c
        shineR.BackgroundTransparency = 0.5
        shineR.Rotation = -20
        corner(shineR, 1)
    end,
    
    -- PRESET: Box with lid
    Preset = function(p, c)
        local box = Instance.new("Frame", p)
        box.Size = UDim2.new(0, 30, 0, 22)
        box.Position = UDim2.new(0.5, -15, 0.5, 0)
        box.BackgroundColor3 = c
        corner(box, 6)
        
        local lid = Instance.new("Frame", p)
        lid.Size = UDim2.new(0, 34, 0, 9)
        lid.Position = UDim2.new(0.5, -17, 0.36, 0)
        lid.BackgroundColor3 = c
        corner(lid, 4)
        
        local handle = Instance.new("Frame", p)
        handle.Size = UDim2.new(0, 14, 0, 3)
        handle.Position = UDim2.new(0.5, -7, 0.31, 0)
        handle.BackgroundColor3 = c
        corner(handle, 2)
        
        local label = Instance.new("Frame", box)
        label.Size = UDim2.new(0, 14, 0, 7)
        label.Position = UDim2.new(0.5, -7, 0.55, 0)
        label.BackgroundColor3 = Color3.new(1, 1, 1)
        label.BackgroundTransparency = 0.5
        corner(label, 3)
    end,
    
    -- FAVS: Star shape
    Favs = function(p, c)
        local hBar = Instance.new("Frame", p)
        hBar.Size = UDim2.new(0, 32, 0, 7)
        hBar.Position = UDim2.new(0.5, -16, 0.5, -3)
        hBar.BackgroundColor3 = c
        corner(hBar, 3)
        
        local vBar = Instance.new("Frame", p)
        vBar.Size = UDim2.new(0, 7, 0, 32)
        vBar.Position = UDim2.new(0.5, -3, 0.5, -16)
        vBar.BackgroundColor3 = c
        corner(vBar, 3)
        
        local diag1 = Instance.new("Frame", p)
        diag1.Size = UDim2.new(0, 24, 0, 5)
        diag1.Position = UDim2.new(0.5, -12, 0.5, -2)
        diag1.BackgroundColor3 = c
        diag1.Rotation = 45
        corner(diag1, 2)
        
        local diag2 = Instance.new("Frame", p)
        diag2.Size = UDim2.new(0, 24, 0, 5)
        diag2.Position = UDim2.new(0.5, -12, 0.5, -2)
        diag2.BackgroundColor3 = c
        diag2.Rotation = -45
        corner(diag2, 2)
        
        local gem = Instance.new("Frame", p)
        gem.Size = UDim2.new(0, 10, 0, 10)
        gem.Position = UDim2.new(0.5, -5, 0.5, -5)
        gem.BackgroundColor3 = c
        corner(gem, 100)
        
        local gemInner = Instance.new("Frame", gem)
        gemInner.Size = UDim2.new(0, 5, 0, 5)
        gemInner.Position = UDim2.new(0.5, -2, 0.5, -2)
        gemInner.BackgroundColor3 = Color3.new(1, 1, 1)
        corner(gemInner, 100)
    end,
    
    -- VOLUME: Speaker with waves
    Volume = function(p, c)
        local speaker = Instance.new("Frame", p)
        speaker.Size = UDim2.new(0, 20, 0, 16)
        speaker.Position = UDim2.new(0.5, -10, 0.37, 0)
        speaker.BackgroundColor3 = c
        corner(speaker, 4)
        
        for i = 1, 2 do
            local line = Instance.new("Frame", speaker)
            line.Size = UDim2.new(0, 8, 0, 2)
            line.Position = UDim2.new(0.5, -4, 0.2 + i * 0.2, 0)
            line.BackgroundColor3 = Color3.new(1, 1, 1)
            line.BackgroundTransparency = 0.6
            corner(line, 1)
        end
        
        local waves = {
            {w = 3, h = 12, x = 16, t = 0.2},
            {w = 3, h = 8, x = 21, t = 0.35},
            {w = 3, h = 5, x = 26, t = 0.5}
        }
        
        for _, wave in ipairs(waves) do
            local w = Instance.new("Frame", p)
            w.Size = UDim2.new(0, wave.w, 0, wave.h)
            w.Position = UDim2.new(0.5, wave.x, 0.5, -wave.h/2)
            w.Position = UDim2.new(0.5, wave.x, 0.38 + (16 - wave.h) / 56, 0)
            w.BackgroundColor3 = c
            w.BackgroundTransparency = wave.t
            corner(w, 1)
        end
    end,
    
    -- ITEMS: Backpack
    Items = function(p, c)
        local bag = Instance.new("Frame", p)
        bag.Size = UDim2.new(0, 26, 0, 26)
        bag.Position = UDim2.new(0.5, -13, 0.3, 0)
        bag.BackgroundColor3 = c
        corner(bag, 7)
        
        local flap = Instance.new("Frame", p)
        flap.Size = UDim2.new(0, 22, 0, 9)
        flap.Position = UDim2.new(0.5, -11, 0.24, 0)
        flap.BackgroundColor3 = c
        corner(flap, 4)
        
        local pocket = Instance.new("Frame", bag)
        pocket.Size = UDim2.new(0, 12, 0, 10)
        pocket.Position = UDim2.new(0.5, -6, 0.45, 0)
        pocket.BackgroundColor3 = Color3.new(1, 1, 1)
        pocket.BackgroundTransparency = 0.5
        corner(pocket, 3)
        
        local handle = Instance.new("Frame", p)
        handle.Size = UDim2.new(0, 10, 0, 3)
        handle.Position = UDim2.new(0.5, -5, 0.2, 0)
        handle.BackgroundColor3 = c
        corner(handle, 2)
    end,
    
    -- PROFILE: ID card with photo
    Profile = function(p, c)
        local head = Instance.new("Frame", p)
        head.Size = UDim2.new(0, 18, 0, 18)
        head.Position = UDim2.new(0.5, -9, 0.24, 0)
        head.BackgroundColor3 = c
        corner(head, 100)
        
        local card = Instance.new("Frame", p)
        card.Size = UDim2.new(0, 30, 0, 20)
        card.Position = UDim2.new(0.5, -15, 0.56, 0)
        card.BackgroundColor3 = c
        corner(card, 5)
        
        local photo = Instance.new("Frame", card)
        photo.Size = UDim2.new(0, 14, 0, 12)
        photo.Position = UDim2.new(0, 3, 0.5, -6)
        photo.BackgroundColor3 = Color3.new(1, 1, 1)
        photo.BackgroundTransparency = 0.35
        corner(photo, 3)
        
        for i = 1, 2 do
            local line = Instance.new("Frame", card)
            line.Size = UDim2.new(0, 8, 0, 2)
            line.Position = UDim2.new(0, 20, 0.2 + i * 0.2, 0)
            line.BackgroundColor3 = Color3.new(1, 1, 1)
            line.BackgroundTransparency = 0.5
            corner(line, 1)
        end
    end,
    
-- ================= ICON BUILDER UNTUK COMMAND =================
-- Di dalam iconBuilders, tambahkan:
Command = function(p, c)
    -- Terminal/console window
    local window = Instance.new("Frame", p)
    window.Size = UDim2.new(0, 28, 0, 22)
    window.Position = UDim2.new(0.5, -14, 0.3, 0)
    window.BackgroundColor3 = c
    corner(window, 5)
    
    -- Window title bar
    local titleBar = Instance.new("Frame", window)
    titleBar.Size = UDim2.new(1, 0, 0, 5)
    titleBar.BackgroundColor3 = Color3.new(1, 1, 1)
    titleBar.BackgroundTransparency = 0.5
    corner(titleBar, 3)
    
    -- Blinking cursor
    local cursor = Instance.new("Frame", window)
    cursor.Size = UDim2.new(0, 2, 0, 8)
    cursor.Position = UDim2.new(0, 6, 0, 8)
    cursor.BackgroundColor3 = Color3.new(1, 1, 1)
    corner(cursor, 1)
    
    -- Command line text
    local line1 = Instance.new("Frame", window)
    line1.Size = UDim2.new(0, 10, 0, 2)
    line1.Position = UDim2.new(0, 10, 0, 10)
    line1.BackgroundColor3 = Color3.new(1, 1, 1)
    line1.BackgroundTransparency = 0.4
    corner(line1, 1)
    
    local line2 = Instance.new("Frame", window)
    line2.Size = UDim2.new(0, 6, 0, 2)
    line2.Position = UDim2.new(0, 10, 0, 14)
    line2.BackgroundColor3 = Color3.new(1, 1, 1)
    line2.BackgroundTransparency = 0.4
    corner(line2, 1)
end,
    
    -- SIZE: Resize arrows (FIXED - BETTER DESIGN)
    Size = function(p, c)
        -- Outer square
        local outerSquare = Instance.new("Frame", p)
        outerSquare.Size = UDim2.new(0, 26, 0, 26)
        outerSquare.Position = UDim2.new(0.5, -13, 0.25, 0)
        outerSquare.BackgroundColor3 = c
        outerSquare.BackgroundTransparency = 0.15
        corner(outerSquare, 5)
        stroke(outerSquare, c, 2, 0)
        
        -- Inner square
        local innerSquare = Instance.new("Frame", p)
        innerSquare.Size = UDim2.new(0, 14, 0, 14)
        innerSquare.Position = UDim2.new(0.5, -7, 0.5, -7)
        innerSquare.Position = UDim2.new(0.5, -7, 0.42, 0)
        innerSquare.BackgroundColor3 = Color3.new(1, 1, 1)
        corner(innerSquare, 3)
        
        -- Arrow right
        local arrowRight = Instance.new("Frame", p)
        arrowRight.Size = UDim2.new(0, 14, 0, 3)
        arrowRight.Position = UDim2.new(0.5, 10, 0.5, -1)
        arrowRight.Position = UDim2.new(0.5, 8, 0.5, -1)
        arrowRight.BackgroundColor3 = c
        corner(arrowRight, 1)
        
        local tipRight = Instance.new("Frame", p)
        tipRight.Size = UDim2.new(0, 6, 0, 6)
        tipRight.Position = UDim2.new(0.5, 20, 0.5, -3)
        tipRight.BackgroundColor3 = c
        tipRight.Rotation = 45
        corner(tipRight, 1)
        
        -- Arrow down
        local arrowDown = Instance.new("Frame", p)
        arrowDown.Size = UDim2.new(0, 3, 0, 14)
        arrowDown.Position = UDim2.new(0.5, -1, 0.5, 10)
        arrowDown.Position = UDim2.new(0.5, -1, 0.5, 8)
        arrowDown.BackgroundColor3 = c
        corner(arrowDown, 1)
        
        local tipDown = Instance.new("Frame", p)
        tipDown.Size = UDim2.new(0, 6, 0, 6)
        tipDown.Position = UDim2.new(0.5, -3, 0.5, 20)
        tipDown.BackgroundColor3 = c
        tipDown.Rotation = 45
        corner(tipDown, 1)
        
        -- Corner marks
        for i = 1, 4 do
            local angle = math.rad(i * 90 + 45)
            local dist = 16
            local x = math.cos(angle) * dist
            local y = math.sin(angle) * dist
            
            local dot = Instance.new("Frame", p)
            dot.Size = UDim2.new(0, 4, 0, 4)
            dot.Position = UDim2.new(0.5, x - 2, 0.5, y - 2)
            dot.Position = UDim2.new(0.5, x - 2, 0.38 + y * 0.02, 0)
            dot.BackgroundColor3 = c
            dot.Rotation = 45
            corner(dot, 1)
        end
    end,
    
    -- FRIENDS: Two connected figures
    Friends = function(p, c)
        local p1Head = Instance.new("Frame", p)
        p1Head.Size = UDim2.new(0, 11, 0, 11)
        p1Head.Position = UDim2.new(0.5, -17, 0.3, 0)
        p1Head.BackgroundColor3 = c
        corner(p1Head, 100)
        
        local p1Body = Instance.new("Frame", p)
        p1Body.Size = UDim2.new(0, 16, 0, 13)
        p1Body.Position = UDim2.new(0.5, -20, 0.55, 0)
        p1Body.BackgroundColor3 = c
        corner(p1Body, 6)
        
        local p2Head = Instance.new("Frame", p)
        p2Head.Size = UDim2.new(0, 11, 0, 11)
        p2Head.Position = UDim2.new(0.5, 6, 0.3, 0)
        p2Head.BackgroundColor3 = c
        corner(p2Head, 100)
        
        local p2Body = Instance.new("Frame", p)
        p2Body.Size = UDim2.new(0, 16, 0, 13)
        p2Body.Position = UDim2.new(0.5, 4, 0.55, 0)
        p2Body.BackgroundColor3 = c
        corner(p2Body, 6)
        
        for i = 1, 4 do
            local dot = Instance.new("Frame", p)
            dot.Size = UDim2.new(0, 2, 0, 2)
            dot.Position = UDim2.new(0.5, -5 + i * 2.5, 0.43 + math.sin(i * 0.6) * 0.03, 0)
            dot.BackgroundColor3 = c
            dot.BackgroundTransparency = 0.5
            corner(dot, 100)
        end
    end,
    
    -- SERVER: Rack with lights
    Server = function(p, c)
        local rack = Instance.new("Frame", p)
        rack.Size = UDim2.new(0, 28, 0, 22)
        rack.Position = UDim2.new(0.5, -14, 0.36, 0)
        rack.BackgroundColor3 = c
        corner(rack, 5)
        
        local panel = Instance.new("Frame", rack)
        panel.Size = UDim2.new(0, 18, 0, 12)
        panel.Position = UDim2.new(0.5, -9, 0.5, -6)
        panel.BackgroundColor3 = Color3.new(1, 1, 1)
        panel.BackgroundTransparency = 0.6
        corner(panel, 3)
        
        for i = 1, 3 do
            local led = Instance.new("Frame", panel)
            led.Size = UDim2.new(0, 4, 0, 4)
            led.Position = UDim2.new(0, 3 + i * 4, 0.5, -2)
            led.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
            corner(led, 100)
        end
        
        for i = 1, 3 do
            local vent = Instance.new("Frame", p)
            vent.Size = UDim2.new(0, 24, 0, 1)
            vent.Position = UDim2.new(0.5, -12, 0.3 + i * 0.07, 0)
            vent.BackgroundColor3 = c
            vent.BackgroundTransparency = 0.7
            corner(vent, 1)
        end
    end,
    
    -- TELEPORT: Portal
    Teleport = function(p, c)
        local outerRing = Instance.new("Frame", p)
        outerRing.Size = UDim2.new(0, 32, 0, 32)
        outerRing.Position = UDim2.new(0.5, -16, 0.24, 0)
        outerRing.BackgroundColor3 = c
        corner(outerRing, 100)
        
        local midRing = Instance.new("Frame", p)
        midRing.Size = UDim2.new(0, 22, 0, 22)
        midRing.Position = UDim2.new(0.5, -11, 0.5, -11)
        midRing.Position = UDim2.new(0.5, -11, 0.34, 0)
        midRing.BackgroundColor3 = c
        midRing.BackgroundTransparency = 0.4
        corner(midRing, 100)
        stroke(midRing, c, 1.5, 0.3)
        
        local innerCircle = Instance.new("Frame", p)
        innerCircle.Size = UDim2.new(0, 12, 0, 12)
        innerCircle.Position = UDim2.new(0.5, -6, 0.5, -6)
        innerCircle.Position = UDim2.new(0.5, -6, 0.44, 0)
        innerCircle.BackgroundColor3 = Color3.new(1, 1, 1)
        corner(innerCircle, 100)
        
        local centerDot = Instance.new("Frame", p)
        centerDot.Size = UDim2.new(0, 4, 0, 4)
        centerDot.Position = UDim2.new(0.5, -2, 0.5, -2)
        centerDot.Position = UDim2.new(0.5, -2, 0.52, 0)
        centerDot.BackgroundColor3 = c
        corner(centerDot, 100)
    end,
    
    
    -- SETTINGS: GEAR SHAPE (FIXED - PROPER GEAR)
    Settings = function(p, c)
        -- Center circle
        local centerCircle = Instance.new("Frame", p)
        centerCircle.Size = UDim2.new(0, 14, 0, 14)
        centerCircle.Position = UDim2.new(0.5, -7, 0.5, -7)
        centerCircle.Position = UDim2.new(0.5, -7, 0.38, 0)
        centerCircle.BackgroundColor3 = c
        corner(centerCircle, 100)
        
        -- Inner hole
        local innerHole = Instance.new("Frame", p)
        innerHole.Size = UDim2.new(0, 6, 0, 6)
        innerHole.Position = UDim2.new(0.5, -3, 0.5, -3)
        innerHole.Position = UDim2.new(0.5, -3, 0.46, 0)
        innerHole.BackgroundColor3 = Color3.new(1, 1, 1)
        corner(innerHole, 100)
        
        -- 8 Gear teeth arranged in a circle
        for i = 1, 8 do
            local angle = math.rad(i * 45) -- 360/8 = 45 degrees apart
            local radius = 11 -- Distance from center
            
            local toothX = math.cos(angle) * radius
            local toothY = math.sin(angle) * radius
            
            local tooth = Instance.new("Frame", p)
            tooth.Size = UDim2.new(0, 5, 0, 5)
            tooth.Position = UDim2.new(0.5, toothX - 2.5, 0.5, toothY - 2.5)
            tooth.Position = UDim2.new(0.5, toothX - 2, 0.38 + toothY * 0.018, 0)
            tooth.BackgroundColor3 = c
            tooth.Rotation = i * 45
            corner(tooth, 1)
        end
        
        -- Outer ring (connecting teeth)
        local outerRing = Instance.new("Frame", p)
        outerRing.Size = UDim2.new(0, 24, 0, 24)
        outerRing.Position = UDim2.new(0.5, -12, 0.5, -12)
        outerRing.Position = UDim2.new(0.5, -12, 0.3, 0)
        outerRing.BackgroundTransparency = 1
        stroke(outerRing, c, 2, 0.3)
        corner(outerRing, 100)
    end,
    
-- Di dalam iconBuilders, tambahkan:
   Bundle = function(p, c)
       local box = Instance.new("Frame", p)
       box.Size = UDim2.new(0, 28, 0, 28)
       box.Position = UDim2.new(0.5, -14, 0.28, 0)
       box.BackgroundColor3 = c
       corner(box, 6)
    
       local ribbon = Instance.new("Frame", p)
       ribbon.Size = UDim2.new(0, 32, 0, 8)
       ribbon.Position = UDim2.new(0.5, -16, 0.42, 0)
       ribbon.BackgroundColor3 = c
       corner(ribbon, 3)
    
       local bow1 = Instance.new("Frame", p)
       bow1.Size = UDim2.new(0, 10, 0, 6)
       bow1.Position = UDim2.new(0.5, -14, 0.38, 0)
       bow1.BackgroundColor3 = c
       bow1.Rotation = -30
       corner(bow1, 3)
    
       local bow2 = Instance.new("Frame", p)
       bow2.Size = UDim2.new(0, 10, 0, 6)
       bow2.Position = UDim2.new(0.5, 4, 0.38, 0)
       bow2.BackgroundColor3 = c
       bow2.Rotation = 30
       corner(bow2, 3)
   end,
   -- Di iconBuilders, tambahkan:
AvatarItems = function(p, c)
    local head = Instance.new("Frame", p)
    head.Size = UDim2.new(0, 14, 0, 14)
    head.Position = UDim2.new(0.5, -7, 0.2, 0)
    head.BackgroundColor3 = c
    corner(head, 100)
    
    local body = Instance.new("Frame", p)
    body.Size = UDim2.new(0, 24, 0, 18)
    body.Position = UDim2.new(0.5, -12, 0.52, 0)
    body.BackgroundColor3 = c
    corner(body, 8)
    
    local tag = Instance.new("Frame", p)
    tag.Size = UDim2.new(0, 12, 0, 8)
    tag.Position = UDim2.new(0.5, 10, 0.38, 0)
    tag.BackgroundColor3 = c
    tag.BackgroundTransparency = 0.4
    corner(tag, 3)
end,

}


-- ================= BUILD APP ICON =================
local function buildAppIcon(name, order, parent, onOpen)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(0, 74, 0, 92)
    container.BackgroundTransparency = 1
    container.LayoutOrder = order
    
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(0, 58, 0, 58)
    btn.Position = UDim2.new(0.5, -29, 0, 2)
    btn.BackgroundColor3 = Color3.fromRGB(248, 248, 252)
    btn.Text = ""
    btn.AutoButtonColor = false
    corner(btn, 16)
    stroke(btn, Color3.fromRGB(215, 215, 220), 1, 0.4)
    
    local btnGradient = Instance.new("UIGradient", btn)
    btnGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(252, 252, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(240, 240, 245))
    })
    btnGradient.Rotation = 135
    
    local iconFrame = Instance.new("Frame", btn)
    iconFrame.Size = UDim2.new(0, 40, 0, 40)
    iconFrame.Position = UDim2.new(0.5, -20, 0.5, -20)
    iconFrame.BackgroundTransparency = 1
    
    local builder = iconBuilders[name]
    if builder then
        builder(iconFrame, T.Text)
    else
        local fallbackCircle = Instance.new("Frame", iconFrame)
        fallbackCircle.Size = UDim2.new(0, 34, 0, 34)
        fallbackCircle.Position = UDim2.new(0.5, -17, 0.5, -17)
        fallbackCircle.BackgroundColor3 = T.Text
        fallbackCircle.BackgroundTransparency = 0.85
        corner(fallbackCircle, 100)
        
        local letter = Instance.new("TextLabel", iconFrame)
        letter.Size = UDim2.new(1, 0, 1, 0)
        letter.BackgroundTransparency = 1
        letter.Text = string.sub(name, 1, 1):upper()
        letter.TextColor3 = T.Text
        letter.Font = Enum.Font.GothamBlack
        letter.TextSize = 22
    end

    pressFX(btn)
    
    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(1, 0, 0, 28)
    label.Position = UDim2.new(0, 0, 0, 63)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = T.Text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 10
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.LineHeight = 1.1
    
    btn.MouseButton1Click:Connect(onOpen)
    
    return container
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

-- ================= APPS =================

-- PLAYERS
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

-- BODY
local function openBodyApp()
    if not selectedPlayer then local h=Instance.new("TextLabel",appContent);h.Size=UDim2.new(1,0,0,60);h.BackgroundTransparency=1;h.Text="Select a player first.";h.TextColor3=T.Text2;h.Font=Enum.Font.Gotham;h.TextSize=12;h.TextWrapped=true;return end
    local items=getItems(selectedPlayer);local shown=0;for _,it in ipairs(items)do if it.Type=="BODY"then shown=shown+1;buildItemRow(appContent,it,shown)end end
    if shown==0 then local n=Instance.new("TextLabel",appContent);n.Size=UDim2.new(1,0,0,40);n.BackgroundTransparency=1;n.Text="No body items.";n.TextColor3=T.Text2;n.Font=Enum.Font.Gotham;n.TextSize=12 end
end

-- ACCESSORY
local function openAccessoryApp()
    if not selectedPlayer then local h=Instance.new("TextLabel",appContent);h.Size=UDim2.new(1,0,0,60);h.BackgroundTransparency=1;h.Text="Select a player first.";h.TextColor3=T.Text2;h.Font=Enum.Font.Gotham;h.TextSize=12;h.TextWrapped=true;return end
    local items=getItems(selectedPlayer);local shown=0;for _,it in ipairs(items)do if it.Type=="ACC"then shown=shown+1;buildItemRow(appContent,it,shown)end end
    if shown==0 then local n=Instance.new("TextLabel",appContent);n.Size=UDim2.new(1,0,0,40);n.BackgroundTransparency=1;n.Text="No accessories.";n.TextColor3=T.Text2;n.Font=Enum.Font.Gotham;n.TextSize=12 end
end

-- CLONE
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

-- PRESET (FIXED - Custom Name, Edit Name, Clone Working)
local function openPresetApp()
    -- ==================== SAVE SECTION ====================
    local saveCard = Instance.new("Frame", appContent)
    saveCard.Size = UDim2.new(1, 0, 0, 130)
    saveCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    saveCard.LayoutOrder = 0
    corner(saveCard, 14)
    stroke(saveCard, Color3.fromRGB(225, 225, 230), 1, 0.3)
    
    -- Shadow
    local saveShadow = Instance.new("Frame", saveCard)
    saveShadow.Size = UDim2.new(1, 6, 1, 6)
    saveShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    saveShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    saveShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    saveShadow.BackgroundTransparency = 0.94
    saveShadow.ZIndex = -1
    corner(saveShadow, 16)
    
    local saveTitle = Instance.new("TextLabel", saveCard)
    saveTitle.Size = UDim2.new(1, -24, 0, 22)
    saveTitle.Position = UDim2.new(0, 12, 0, 10)
    saveTitle.BackgroundTransparency = 1
    saveTitle.Text = "Save Current Player as Preset"
    saveTitle.TextColor3 = T.Text
    saveTitle.Font = Enum.Font.GothamBlack
    saveTitle.TextSize = 13
    saveTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local saveDesc = Instance.new("TextLabel", saveCard)
    saveDesc.Size = UDim2.new(1, -24, 0, 14)
    saveDesc.Position = UDim2.new(0, 12, 0, 32)
    saveDesc.BackgroundTransparency = 1
    saveDesc.Text = "Select a player first, then customize the preset name"
    saveDesc.TextColor3 = T.Text2
    saveDesc.Font = Enum.Font.Gotham
    saveDesc.TextSize = 9
    saveDesc.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Input nama preset
    local nameInput = Instance.new("TextBox", saveCard)
    nameInput.Size = UDim2.new(1, -24, 0, 32)
    nameInput.Position = UDim2.new(0, 12, 0, 50)
    nameInput.PlaceholderText = "Enter preset name..."
    nameInput.Text = selectedPlayer and (selectedPlayer.DisplayName .. " - " .. os.date("%d/%m %H:%M")) or ""
    nameInput.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
    nameInput.TextColor3 = T.Text
    nameInput.Font = Enum.Font.Gotham
    nameInput.TextSize = 12
    nameInput.ClearTextOnFocus = false
    corner(nameInput, 8)
    stroke(nameInput, Color3.fromRGB(220, 220, 225), 1, 0.3)
    
    -- Update nama otomatis saat player berubah
    if selectedPlayer then
        nameInput.Text = selectedPlayer.DisplayName .. " - " .. os.date("%d/%m %H:%M")
    end
    
    -- Tombol Save
    local saveBtn = Instance.new("TextButton", saveCard)
    saveBtn.Size = UDim2.new(1, -24, 0, 34)
    saveBtn.Position = UDim2.new(0, 12, 0, 88)
    saveBtn.BackgroundColor3 = T.Accent
    saveBtn.Text = "Save Preset"
    saveBtn.TextColor3 = T.OnAccent
    saveBtn.Font = Enum.Font.GothamBlack
    saveBtn.TextSize = 12
    saveBtn.AutoButtonColor = false
    corner(saveBtn, 8)
    pressFX(saveBtn)
    saveBtn.MouseButton1Click:Connect(function()
        if not selectedPlayer then
            showDynamicNotification("Select a player first!", T.Red)
            return
        end
        
        local items = getItems(selectedPlayer)
        if #items == 0 then
            showDynamicNotification("Player has no items!", T.Red)
            return
        end
        
        -- Ambil nama dari input, jika kosong gunakan default
        local presetName = nameInput.Text
        if presetName == "" or presetName:match("^%s*$") then
            presetName = selectedPlayer.DisplayName .. " - " .. os.date("%d/%m %H:%M")
        end
        
        local ids = {}
        for _, it in ipairs(items) do
            table.insert(ids, it.Value)
        end
        
        table.insert(presets, {
            name = presetName,
            ids = ids,
            date = os.date("%d/%m/%Y %H:%M"),
            favorite = false,
            playerName = selectedPlayer.DisplayName,
            playerId = selectedPlayer.UserId,
            itemCount = #ids
        })
        
        saveJSON(PRESET_FILE, presets)
        showDynamicNotification("Preset saved! (" .. #ids .. " items)", T.Green)
        nameInput.Text = ""
        refreshCurr()
    end)
    
    -- ==================== PRESETS LIST ====================
    if #presets == 0 then
        local emptyFrame = Instance.new("Frame", appContent)
        emptyFrame.Size = UDim2.new(1, 0, 0, 120)
        emptyFrame.BackgroundColor3 = Color3.fromRGB(248, 248, 250)
        emptyFrame.LayoutOrder = 1
        corner(emptyFrame, 14)
        stroke(emptyFrame, Color3.fromRGB(220, 220, 225), 1, 0.4)
        
        local emptyIcon = Instance.new("Frame", emptyFrame)
        emptyIcon.Size = UDim2.new(0, 40, 0, 40)
        emptyIcon.Position = UDim2.new(0.5, -20, 0, 25)
        emptyIcon.BackgroundTransparency = 1
        
        -- Box icon
        local boxIcon = Instance.new("Frame", emptyIcon)
        boxIcon.Size = UDim2.new(0, 34, 0, 24)
        boxIcon.Position = UDim2.new(0.5, -17, 0.48, 0)
        boxIcon.BackgroundColor3 = Color3.fromRGB(180, 180, 190)
        corner(boxIcon, 7)
        
        local lidIcon = Instance.new("Frame", emptyIcon)
        lidIcon.Size = UDim2.new(0, 38, 0, 10)
        lidIcon.Position = UDim2.new(0.5, -19, 0.34, 0)
        lidIcon.BackgroundColor3 = Color3.fromRGB(180, 180, 190)
        corner(lidIcon, 5)
        
        local emptyText = Instance.new("TextLabel", emptyFrame)
        emptyText.Size = UDim2.new(1, -20, 0, 30)
        emptyText.Position = UDim2.new(0, 10, 0, 72)
        emptyText.BackgroundTransparency = 1
        emptyText.Text = "No presets saved yet"
        emptyText.TextColor3 = Color3.fromRGB(140, 140, 150)
        emptyText.Font = Enum.Font.GothamBold
        emptyText.TextSize = 13
        emptyText.TextXAlignment = Enum.TextXAlignment.Center
        
        return
    end
    
    -- Sort presets: favorites first, then by date
    local sorted = {}
    for _, p in ipairs(presets) do
        table.insert(sorted, p)
    end
    table.sort(sorted, function(a, b)
        if a.favorite ~= b.favorite then return a.favorite end
        return (a.date or "") > (b.date or "")
    end)
    
    -- Preset counter
    local counterFrame = Instance.new("Frame", appContent)
    counterFrame.Size = UDim2.new(1, 0, 0, 22)
    counterFrame.BackgroundTransparency = 1
    counterFrame.LayoutOrder = 1
    
    local counterText = Instance.new("TextLabel", counterFrame)
    counterText.Size = UDim2.new(0, 120, 1, 0)
    counterText.BackgroundTransparency = 1
    counterText.Text = #sorted .. " preset" .. (#sorted ~= 1 and "s" or "")
    counterText.TextColor3 = T.Text2
    counterText.Font = Enum.Font.GothamBold
    counterText.TextSize = 10
    counterText.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Render presets
    for i, p in ipairs(sorted) do
        local row = Instance.new("Frame", appContent)
        row.Size = UDim2.new(1, 0, 0, 100)
        row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        row.LayoutOrder = i + 1
        corner(row, 12)
        stroke(row, p.favorite and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(225, 225, 230), p.favorite and 1.5 or 1, p.favorite and 0.2 or 0.3)
        
        -- Shadow
        local rowShadow = Instance.new("Frame", row)
        rowShadow.Size = UDim2.new(1, 6, 1, 6)
        rowShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
        rowShadow.AnchorPoint = Vector2.new(0.5, 0.5)
        rowShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        rowShadow.BackgroundTransparency = 0.94
        rowShadow.ZIndex = -1
        corner(rowShadow, 14)
        
        -- Gold accent for favorites
        if p.favorite then
            local accent = Instance.new("Frame", row)
            accent.Size = UDim2.new(0, 3, 1, -16)
            accent.Position = UDim2.new(0, 8, 0, 8)
            accent.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
            corner(accent, 2)
        end
        
        -- Preset name
        local nameLbl = Instance.new("TextLabel", row)
        nameLbl.Size = UDim2.new(1, -24, 0, 24)
        nameLbl.Position = UDim2.new(0, 12, 0, 8)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = p.name
        nameLbl.TextColor3 = T.Text
        nameLbl.Font = Enum.Font.GothamBlack
        nameLbl.TextSize = 13
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
        
        -- Info: item count + date + player name
        local infoLbl = Instance.new("TextLabel", row)
        infoLbl.Size = UDim2.new(1, -24, 0, 16)
        infoLbl.Position = UDim2.new(0, 12, 0, 32)
        infoLbl.BackgroundTransparency = 1
        infoLbl.Text = (p.itemCount or #p.ids) .. " items | " .. (p.date or "") .. (p.playerName and (" | " .. p.playerName) or "")
        infoLbl.TextColor3 = T.Text2
        infoLbl.Font = Enum.Font.Gotham
        infoLbl.TextSize = 9
        infoLbl.TextXAlignment = Enum.TextXAlignment.Left
        infoLbl.TextTruncate = Enum.TextTruncate.AtEnd
        
-- ============== ACTION BUTTONS ROW 1 ==============
        local btnRow1 = Instance.new("Frame", row)
        btnRow1.Size = UDim2.new(1, -24, 0, 26)
        btnRow1.Position = UDim2.new(0, 12, 0, 52)
        btnRow1.BackgroundTransparency = 1
        
        -- Clone button (FIXED)
        local cloneBtn = Instance.new("TextButton", btnRow1)
        cloneBtn.Size = UDim2.new(0, 75, 1, 0)
        cloneBtn.BackgroundColor3 = T.Green
        cloneBtn.Text = "Clone"
        cloneBtn.TextColor3 = T.OnAccent
        cloneBtn.Font = Enum.Font.GothamBold
        cloneBtn.TextSize = 9
        cloneBtn.AutoButtonColor = false
        corner(cloneBtn, 6)
        pressFX(cloneBtn)
        cloneBtn.MouseButton1Click:Connect(function()
            if #p.ids == 0 then
                showDynamicNotification("Preset has no items!", T.Red)
                return
            end
            
            -- Clone dengan progress tracking
            cloneBtn.Text = "Cloning..."
            cloneBtn.BackgroundColor3 = T.Gold
            
            -- Gunakan cloneItems dengan callback untuk tracking
            local totalBatches = math.ceil(#p.ids / CONFIG.CLONE_BATCH_SIZE)
            local currentBatch = 0
            
            -- Buat fungsi clone batch manual
            local function cloneBatch(batchIndex)
                if batchIndex > totalBatches then
                    -- Selesai
                    cloneBtn.Text = "Done!"
                    cloneBtn.BackgroundColor3 = T.Green
                    showDynamicNotification("Clone complete! (" .. #p.ids .. " items)", T.Green)
                    task.wait(1.5)
                    cloneBtn.Text = "Clone"
                    return
                end
                
                local startIdx = (batchIndex - 1) * CONFIG.CLONE_BATCH_SIZE + 1
                local endIdx = math.min(batchIndex * CONFIG.CLONE_BATCH_SIZE, #p.ids)
                local batchIds = {}
                
                for j = startIdx, endIdx do
                    table.insert(batchIds, p.ids[j])
                end
                
                fireHat(batchIds)
                cloneBtn.Text = "Clone " .. batchIndex .. "/" .. totalBatches
                
                task.delay(CONFIG.CLONE_DELAY, function()
                    cloneBatch(batchIndex + 1)
                end)
            end
            
            cloneBatch(1)
        end)
        
        -- Wear button (clone single batch)
        local wearBtn = Instance.new("TextButton", btnRow1)
        wearBtn.Size = UDim2.new(0, 75, 1, 0)
        wearBtn.Position = UDim2.new(0, 80, 0, 0)
        wearBtn.BackgroundColor3 = T.Accent
        wearBtn.Text = "Wear All"
        wearBtn.TextColor3 = T.OnAccent
        wearBtn.Font = Enum.Font.GothamBold
        wearBtn.TextSize = 9
        wearBtn.AutoButtonColor = false
        corner(wearBtn, 6)
        pressFX(wearBtn)
        wearBtn.MouseButton1Click:Connect(function()
            if #p.ids == 0 then
                showDynamicNotification("Preset has no items!", T.Red)
                return
            end
            fireHat(p.ids)
            showDynamicNotification("Wearing " .. #p.ids .. " items!", T.Green)
        end)
        
        -- ==================== ACTION BUTTONS ROW 2 ====================
        local btnRow2 = Instance.new("Frame", row)
        btnRow2.Size = UDim2.new(1, -24, 0, 24)
        btnRow2.Position = UDim2.new(0, 12, 0, 80)
        btnRow2.BackgroundTransparency = 1
        
        -- Favorite button
        local favBtn = Instance.new("TextButton", btnRow2)
        favBtn.Size = UDim2.new(0, 50, 1, 0)
        favBtn.BackgroundColor3 = p.favorite and T.Gold or Color3.fromRGB(245, 245, 248)
        favBtn.Text = p.favorite and "Unfav" or "Fav"
        favBtn.TextColor3 = p.favorite and T.OnAccent or T.Text2
        favBtn.Font = Enum.Font.GothamBold
        favBtn.TextSize = 8
        favBtn.AutoButtonColor = false
        corner(favBtn, 5)
        stroke(favBtn, T.Border, 1, 0.3)
        pressFX(favBtn)
        favBtn.MouseButton1Click:Connect(function()
            p.favorite = not p.favorite
            saveJSON(PRESET_FILE, presets)
            refreshCurr()
        end)
        
        -- Edit name button
        local editBtn = Instance.new("TextButton", btnRow2)
        editBtn.Size = UDim2.new(0, 50, 1, 0)
        editBtn.Position = UDim2.new(0, 55, 0, 0)
        editBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
        editBtn.Text = "Rename"
        editBtn.TextColor3 = T.Text
        editBtn.Font = Enum.Font.GothamBold
        editBtn.TextSize = 8
        editBtn.AutoButtonColor = false
        corner(editBtn, 5)
        stroke(editBtn, T.Border, 1, 0.3)
        pressFX(editBtn)
        editBtn.MouseButton1Click:Connect(function()
            -- Tampilkan input dialog sederhana
            nameLbl.Visible = false
            
            local editInput = Instance.new("TextBox", row)
            editInput.Size = UDim2.new(1, -24, 0, 24)
            editInput.Position = UDim2.new(0, 12, 0, 8)
            editInput.Text = p.name
            editInput.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
            editInput.TextColor3 = T.Text
            editInput.Font = Enum.Font.GothamBold
            editInput.TextSize = 12
            editInput.ZIndex = 10
            corner(editInput, 6)
            stroke(editInput, T.Accent, 1.5, 0)
            
            editInput.FocusLost:Connect(function(enterPressed)
                local newName = editInput.Text
                if newName ~= "" and newName:match("%S") then
                    p.name = newName
                    saveJSON(PRESET_FILE, presets)
                    showDynamicNotification("Preset renamed!", T.Green)
                end
                editInput:Destroy()
                nameLbl.Visible = true
                nameLbl.Text = p.name
            end)
            
            editInput:CaptureFocus()
        end)
        
        -- Copy IDs button
        local copyBtn = Instance.new("TextButton", btnRow2)
        copyBtn.Size = UDim2.new(0, 50, 1, 0)
        copyBtn.Position = UDim2.new(0, 110, 0, 0)
        copyBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
        copyBtn.Text = "Copy IDs"
        copyBtn.TextColor3 = T.Text
        copyBtn.Font = Enum.Font.GothamBold
        copyBtn.TextSize = 8
        copyBtn.AutoButtonColor = false
        corner(copyBtn, 5)
        stroke(copyBtn, T.Border, 1, 0.3)
        pressFX(copyBtn)
        copyBtn.MouseButton1Click:Connect(function()
            copyToClipboard(table.concat(p.ids, " "))
            showDynamicNotification("Copied " .. #p.ids .. " IDs!", T.Green)
        end)
        
        -- Delete button
        local delBtn = Instance.new("TextButton", btnRow2)
        delBtn.Size = UDim2.new(0, 50, 1, 0)
        delBtn.Position = UDim2.new(0, 165, 0, 0)
        delBtn.BackgroundColor3 = Color3.fromRGB(255, 230, 230)
        delBtn.Text = "Delete"
        delBtn.TextColor3 = T.Red
        delBtn.Font = Enum.Font.GothamBold
        delBtn.TextSize = 8
        delBtn.AutoButtonColor = false
        corner(delBtn, 5)
        stroke(delBtn, Color3.fromRGB(255, 200, 200), 1, 0.3)
        pressFX(delBtn)
        delBtn.MouseButton1Click:Connect(function()
            -- Konfirmasi delete
            delBtn.Text = "Sure?"
            task.wait(1)
            if delBtn.Text == "Sure?" then
                local idx = table.find(presets, p)
                if idx then
                    table.remove(presets, idx)
                end
                saveJSON(PRESET_FILE, presets)
                showDynamicNotification("Preset deleted!", T.Red)
                refreshCurr()
            end
        end)
    end
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
    local masterFrame=Instance.new("Frame",appContent);masterFrame.Size=UDim2.new(1,0,0,120);masterFrame.BackgroundColor3=T.Card2;corner(masterFrame,12);stroke(masterFrame,T.Border,1,0.3)
    local mTitle=Instance.new("TextLabel",masterFrame);mTitle.Size=UDim2.new(1,-20,0,24);mTitle.Position=UDim2.new(0,10,0,8);mTitle.BackgroundTransparency=1;mTitle.Text="Master Volume";mTitle.TextColor3=T.Text;mTitle.Font=Enum.Font.GothamBold;mTitle.TextSize=14;mTitle.TextXAlignment=Enum.TextXAlignment.Left
    local volLbl=Instance.new("TextLabel",masterFrame);volLbl.Size=UDim2.new(1,-20,0,20);volLbl.Position=UDim2.new(0,10,0,34);volLbl.BackgroundTransparency=1;volLbl.Text="Volume: "..math.floor(currentVol*100).."%";volLbl.TextColor3=T.Text;volLbl.Font=Enum.Font.Gotham;volLbl.TextSize=12;volLbl.TextXAlignment=Enum.TextXAlignment.Left
    local sliderBar=Instance.new("TextButton",masterFrame);sliderBar.Size=UDim2.new(1,-20,0,28);sliderBar.Position=UDim2.new(0,10,0,56);sliderBar.BackgroundColor3=T.Card;sliderBar.Text="";corner(sliderBar,14);stroke(sliderBar,T.Border,1.5,0)
    local fill=Instance.new("Frame",sliderBar);fill.Size=UDim2.new(currentVol,0,1,0);fill.BackgroundColor3=T.Accent;corner(fill,14)
    local function setMasterVol(percent)currentVol=math.clamp(percent,0,1);applyVolumeEverywhere(currentVol);fill.Size=UDim2.new(currentVol,0,1,0);volLbl.Text="Volume: "..math.floor(currentVol*100).."%" end
    sliderBar.MouseButton1Down:Connect(function()local con;con=RunService.RenderStepped:Connect(function()local mousePos=UserInputService:GetMouseLocation();local absX,absSizeX=sliderBar.AbsolutePosition.X,sliderBar.AbsoluteSize.X;if absSizeX<=0 then absSizeX=1 end;local relX=(mousePos.X-absX)/absSizeX;setMasterVol(math.clamp(relX,0,1));if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)then con:Disconnect()end end)end)
    local btnContainer=Instance.new("Frame",masterFrame);btnContainer.Size=UDim2.new(1,-20,0,28);btnContainer.Position=UDim2.new(0,10,0,88);btnContainer.BackgroundTransparency=1
    local muteBtn=Instance.new("TextButton",btnContainer);muteBtn.Size=UDim2.new(0.48,0,1,0);muteBtn.BackgroundColor3=T.Card;muteBtn.Text="Mute";muteBtn.TextColor3=T.Text;muteBtn.Font=Enum.Font.GothamBold;muteBtn.TextSize=12;muteBtn.AutoButtonColor=false;corner(muteBtn,8);stroke(muteBtn,T.Border,1,0.3);pressFX(muteBtn);muteBtn.MouseButton1Click:Connect(function()setMasterVol(0)end)
    local maxBtn=Instance.new("TextButton",btnContainer);maxBtn.Size=UDim2.new(0.48,0,1,0);maxBtn.Position=UDim2.new(0.52,0,0,0);maxBtn.BackgroundColor3=T.Card;maxBtn.Text="Max";maxBtn.TextColor3=T.Text;maxBtn.Font=Enum.Font.GothamBold;maxBtn.TextSize=12;maxBtn.AutoButtonColor=false;corner(maxBtn,8);stroke(maxBtn,T.Border,1,0.3);pressFX(maxBtn);maxBtn.MouseButton1Click:Connect(function()setMasterVol(1)end)
    local activeTitle=Instance.new("TextLabel",appContent);activeTitle.Size=UDim2.new(1,0,0,20);activeTitle.BackgroundTransparency=1;activeTitle.Text="Active Sounds";activeTitle.TextColor3=T.Text;activeTitle.Font=Enum.Font.GothamBold;activeTitle.TextSize=12;activeTitle.TextXAlignment=Enum.TextXAlignment.Left
    local soundsHolder=Instance.new("Frame",appContent);soundsHolder.Size=UDim2.new(1,0,0,0);soundsHolder.AutomaticSize=Enum.AutomaticSize.Y;soundsHolder.BackgroundTransparency=1
    local soundsLayout=Instance.new("UIListLayout",soundsHolder);soundsLayout.Padding=UDim.new(0,4)
    local function refreshSoundsList()
        for _,c in ipairs(soundsHolder:GetChildren())do if not c:IsA("UIListLayout")then c:Destroy()end end
        local activeSounds={}
        for _,obj in ipairs(game:GetDescendants())do
            if obj:IsA("Sound") and obj.IsPlaying then
                table.insert(activeSounds,obj)
            end
        end
        if #activeSounds==0 then
            local n=Instance.new("TextLabel",soundsHolder);n.Size=UDim2.new(1,0,0,30);n.BackgroundTransparency=1;n.Text="No active sounds.";n.TextColor3=T.Text2;n.Font=Enum.Font.Gotham;n.TextSize=11
            return
        end
        for _,snd in ipairs(activeSounds)do
            local row=Instance.new("Frame",soundsHolder);row.Size=UDim2.new(1,0,0,44);row.BackgroundColor3=T.Card2;corner(row,8);stroke(row,T.Border,1,0.3)
            local nameLbl=Instance.new("TextLabel",row);nameLbl.Size=UDim2.new(1,-100,0,18);nameLbl.Position=UDim2.new(0,6,0,4);nameLbl.BackgroundTransparency=1;nameLbl.Text=snd.Name;nameLbl.TextColor3=T.Text;nameLbl.Font=Enum.Font.GothamBold;nameLbl.TextSize=11;nameLbl.TextXAlignment=Enum.TextXAlignment.Left;nameLbl.TextTruncate=Enum.TextTruncate.AtEnd
            local sndVolLbl=Instance.new("TextLabel",row);sndVolLbl.Size=UDim2.new(0,40,0,16);sndVolLbl.Position=UDim2.new(0,6,0,24);sndVolLbl.BackgroundTransparency=1;sndVolLbl.Text=math.floor(snd.Volume*100).."%";sndVolLbl.TextColor3=T.Text2;sndVolLbl.Font=Enum.Font.Gotham;sndVolLbl.TextSize=10
            local sndSlider=Instance.new("TextButton",row);sndSlider.Size=UDim2.new(1,-140,0,18);sndSlider.Position=UDim2.new(0,46,0,24);sndSlider.BackgroundColor3=T.Card;sndSlider.Text="";corner(sndSlider,9);stroke(sndSlider,T.Border,1,0)
            local sndFill=Instance.new("Frame",sndSlider);sndFill.Size=UDim2.new(snd.Volume,0,1,0);sndFill.BackgroundColor3=T.Accent;corner(sndFill,9)
            local function setSndVol(v) v=math.clamp(v,0,1);snd.Volume=v;sndVolLbl.Text=math.floor(v*100).."%";sndFill.Size=UDim2.new(v,0,1,0) end
            sndSlider.MouseButton1Down:Connect(function()
                local con;con=RunService.RenderStepped:Connect(function()
                    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then con:Disconnect() return end
                    local mousePos=UserInputService:GetMouseLocation()
                    local relX=(mousePos.X-sndSlider.AbsolutePosition.X)/sndSlider.AbsoluteSize.X
                    setSndVol(relX)
                end)
            end)
            local muteBtn=Instance.new("TextButton",row);muteBtn.Size=UDim2.new(0,40,0,22);muteBtn.Position=UDim2.new(1,-96,0,20);muteBtn.BackgroundColor3=T.Card;muteBtn.Text="Mute";muteBtn.TextColor3=T.Text;muteBtn.Font=Enum.Font.GothamBold;muteBtn.TextSize=9;muteBtn.AutoButtonColor=false;corner(muteBtn,5);pressFX(muteBtn)
            muteBtn.MouseButton1Click:Connect(function()if snd.Volume>0 then snd.Volume=0;setSndVol(0) else setSndVol(0.5) end end)
            local stopBtn=Instance.new("TextButton",row);stopBtn.Size=UDim2.new(0,40,0,22);stopBtn.Position=UDim2.new(1,-50,0,20);stopBtn.BackgroundColor3=T.Red;stopBtn.Text="Stop";stopBtn.TextColor3=Color3.new(1,1,1);stopBtn.Font=Enum.Font.GothamBold;stopBtn.TextSize=9;stopBtn.AutoButtonColor=false;corner(stopBtn,5);pressFX(stopBtn)
            stopBtn.MouseButton1Click:Connect(function()snd:Stop()end)
        end
    end
    refreshSoundsList()
    task.spawn(function()
        while appContent.Parent do
            task.wait(2)
            if appTitle.Text=="Volume" then refreshSoundsList() end
        end
    end)
end

-- SIZE (FIXED COMMAND)
local function openSizeApp()
    local bg = Instance.new("Frame", appContent)
    bg.Size = UDim2.new(1, 0, 0, 120)
    bg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    bg.LayoutOrder = 0
    corner(bg, 14)
    stroke(bg, Color3.fromRGB(225, 225, 230), 1, 0.3)
    
    -- Shadow
    local bgShadow = Instance.new("Frame", bg)
    bgShadow.Size = UDim2.new(1, 6, 1, 6)
    bgShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    bgShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    bgShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bgShadow.BackgroundTransparency = 0.94
    bgShadow.ZIndex = -1
    corner(bgShadow, 16)
    
    local title = Instance.new("TextLabel", bg)
    title.Size = UDim2.new(1, -24, 0, 24)
    title.Position = UDim2.new(0, 12, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Character Size"
    title.TextColor3 = T.Text
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local sizeVal = Instance.new("TextLabel", bg)
    sizeVal.Size = UDim2.new(1, -24, 0, 20)
    sizeVal.Position = UDim2.new(0, 12, 0, 36)
    sizeVal.BackgroundTransparency = 1
    sizeVal.Text = "Current: 1.0"
    sizeVal.TextColor3 = T.Text2
    sizeVal.Font = Enum.Font.Gotham
    sizeVal.TextSize = 11
    sizeVal.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderBar = Instance.new("TextButton", bg)
    sliderBar.Size = UDim2.new(1, -24, 0, 28)
    sliderBar.Position = UDim2.new(0, 12, 0, 62)
    sliderBar.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
    sliderBar.Text = ""
    corner(sliderBar, 14)
    
    local fill = Instance.new("Frame", sliderBar)
    fill.Size = UDim2.new(1, 0, 1, 0)
    fill.BackgroundColor3 = T.Accent
    corner(fill, 14)
    
    local curSize = 1.0
    
    local function setSizeVal(val)
        curSize = math.clamp(val, 0.5, 1.0)
        fill.Size = UDim2.new((curSize - 0.5) * 2, 0, 1, 0)
        sizeVal.Text = "Current: " .. string.format("%.2f", curSize)
        
        -- FIXED: Set size dengan format yang benar
        local sizeString = string.format("%.1f", curSize)
        
        -- Mencari remote command
        local remote = ReplicatedStorage
        local remotePath = CONFIG.REMOTE_PATH or "Remotes.Command.CommandEvent"
        
        for _, part in ipairs(remotePath:split(".")) do
            local found = remote:FindFirstChild(part)
            if found then
                remote = found
            else
                -- Coba wait for child jika tidak ditemukan
                local success, result = pcall(function()
                    return remote:WaitForChild(part, 2)
                end)
                if success and result then
                    remote = result
                else
                    showDynamicNotification("Remote not found: " .. part, T.Red)
                    return
                end
            end
        end
        
        -- Kirim command size dengan format yang benar
        -- Format: remote:FireServer("size", {"size", "0.5"})
        pcall(function()
            remote:FireServer("size", {
                "size",
                sizeString
            })
        end)
        
        showDynamicNotification("Size: " .. sizeString, T.Green)
    end
    
    sliderBar.MouseButton1Down:Connect(function()
        local con
        con = RunService.RenderStepped:Connect(function()
            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                con:Disconnect()
                return
            end
            local mousePos = UserInputService:GetMouseLocation()
            local absX = sliderBar.AbsolutePosition.X
            local absSizeX = sliderBar.AbsoluteSize.X
            if absSizeX <= 0 then absSizeX = 1 end
            local relX = (mousePos.X - absX) / absSizeX
            setSizeVal(0.5 + relX * 0.5)
        end)
    end)
    
    -- Preset buttons
    local presets = {
        {label = "0.5", value = 0.5},
        {label = "0.7", value = 0.7},
        {label = "0.8", value = 0.8},
        {label = "0.9", value = 0.9},
        {label = "1.0", value = 1.0}
    }
    
    for i, preset in ipairs(presets) do
        local presetBtn = Instance.new("TextButton", bg)
        presetBtn.Size = UDim2.new(0, 46, 0, 22)
        presetBtn.Position = UDim2.new(0, 12 + (i-1) * 52, 0, 92)
        presetBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
        presetBtn.Text = preset.label
        presetBtn.TextColor3 = T.Text
        presetBtn.Font = Enum.Font.GothamBold
        presetBtn.TextSize = 10
        presetBtn.AutoButtonColor = false
        corner(presetBtn, 6)
        stroke(presetBtn, Color3.fromRGB(210, 210, 215), 1, 0.3)
        pressFX(presetBtn)
        
        presetBtn.MouseButton1Click:Connect(function()
            setSizeVal(preset.value)
        end)
    end
end

-- FAVORITES (FINAL PREMIUM - COMPACT ICONS, 2-COLUMN ITEMS GRID)
local favSelectedTab = "Players"
local function openFavoritesApp()
    -- ==================== HEADER BANNER ====================
    local headerBanner = Instance.new("Frame", appContent)
    headerBanner.Size = UDim2.new(1, 0, 0, 56)
    headerBanner.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    headerBanner.LayoutOrder = 0
    corner(headerBanner, 16)
    
    local bannerGradient = Instance.new("UIGradient", headerBanner)
    bannerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 45)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 25, 38)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 28))
    })
    bannerGradient.Rotation = 135
    
    -- Accent line
    local accentLine = Instance.new("Frame", headerBanner)
    accentLine.Size = UDim2.new(1, 0, 0, 2)
    accentLine.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    accentLine.ZIndex = 5
    corner(accentLine, 1)
    
    -- Star icon kecil di header
    local starContainer = Instance.new("Frame", headerBanner)
    starContainer.Size = UDim2.new(0, 32, 0, 32)
    starContainer.Position = UDim2.new(0, 14, 0.5, -16)
    starContainer.BackgroundTransparency = 1
    starContainer.ZIndex = 5
    
    -- Star shape compact
    local starH = Instance.new("Frame", starContainer)
    starH.Size = UDim2.new(0, 28, 0, 6)
    starH.Position = UDim2.new(0.5, -14, 0.5, -3)
    starH.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    corner(starH, 3)
    
    local starV = Instance.new("Frame", starContainer)
    starV.Size = UDim2.new(0, 6, 0, 28)
    starV.Position = UDim2.new(0.5, -3, 0.5, -14)
    starV.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    corner(starV, 3)
    
    local starD1 = Instance.new("Frame", starContainer)
    starD1.Size = UDim2.new(0, 22, 0, 5)
    starD1.Position = UDim2.new(0.5, -11, 0.5, -2)
    starD1.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    starD1.Rotation = 45
    corner(starD1, 2)
    
    local starD2 = Instance.new("Frame", starContainer)
    starD2.Size = UDim2.new(0, 22, 0, 5)
    starD2.Position = UDim2.new(0.5, -11, 0.5, -2)
    starD2.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    starD2.Rotation = -45
    corner(starD2, 2)
    
    -- Title
    local headerTitle = Instance.new("TextLabel", headerBanner)
    headerTitle.Size = UDim2.new(1, -60, 0, 28)
    headerTitle.Position = UDim2.new(0, 52, 0, 8)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "My Favorites"
    headerTitle.TextColor3 = Color3.new(1, 1, 1)
    headerTitle.Font = Enum.Font.GothamBlack
    headerTitle.TextSize = 17
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    headerTitle.ZIndex = 5
    
    local headerSub = Instance.new("TextLabel", headerBanner)
    headerSub.Size = UDim2.new(1, -60, 0, 16)
    headerSub.Position = UDim2.new(0, 52, 0, 34)
    headerSub.BackgroundTransparency = 1
    headerSub.Text = "Your saved players and items"
    headerSub.TextColor3 = Color3.fromRGB(160, 160, 180)
    headerSub.Font = Enum.Font.Gotham
    headerSub.TextSize = 9
    headerSub.TextXAlignment = Enum.TextXAlignment.Left
    headerSub.ZIndex = 5
    
    -- ==================== TAB NAVIGATION ====================
    local tabFrame = Instance.new("Frame", appContent)
    tabFrame.Size = UDim2.new(1, 0, 0, 42)
    tabFrame.BackgroundColor3 = Color3.fromRGB(242, 242, 247)
    tabFrame.LayoutOrder = 1
    corner(tabFrame, 21)
    stroke(tabFrame, Color3.fromRGB(200, 200, 210), 1, 0.3)
    
    local tabPadding = Instance.new("UIPadding", tabFrame)
    tabPadding.PaddingLeft = UDim.new(0, 4)
    tabPadding.PaddingRight = UDim.new(0, 4)
    tabPadding.PaddingTop = UDim.new(0, 4)
    tabPadding.PaddingBottom = UDim.new(0, 4)
    
    local tabs = {"Players", "Items"}
    local tabBtns = {}
    
    for i, t in ipairs(tabs) do
        local btn = Instance.new("TextButton", tabFrame)
        btn.Size = UDim2.new(0.5, -6, 1, 0)
        btn.Position = UDim2.new((i-1) * 0.5, 3, 0, 0)
        btn.Text = t
        btn.AutoButtonColor = false
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundTransparency = 1
        btn.TextColor3 = Color3.fromRGB(100, 100, 100)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        corner(btn, 17)
        
        local isSelected = (i == 1 and favSelectedTab == "Players") or (i == 2 and favSelectedTab == "Items")
        if isSelected then
            btn.BackgroundColor3 = T.Accent
            btn.BackgroundTransparency = 0
            btn.TextColor3 = Color3.new(1, 1, 1)
        end
        
        btn.MouseButton1Click:Connect(function()
            favSelectedTab = t
            for _, b in ipairs(tabBtns) do
                b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                b.BackgroundTransparency = 1
                b.TextColor3 = Color3.fromRGB(100, 100, 100)
            end
            btn.BackgroundColor3 = T.Accent
            btn.BackgroundTransparency = 0
            btn.TextColor3 = Color3.new(1, 1, 1)
            refreshCurr()
        end)
        
        table.insert(tabBtns, btn)
    end
    
    -- ==================== CONTENT AREA ====================
    local listHolder = Instance.new("Frame", appContent)
    listHolder.Size = UDim2.new(1, 0, 0, 0)
    listHolder.AutomaticSize = Enum.AutomaticSize.Y
    listHolder.BackgroundTransparency = 1
    listHolder.LayoutOrder = 2
    
    -- ==================== EMPTY STATE ====================
    local function showEmptyState(message, iconName)
        local emptyFrame = Instance.new("Frame", listHolder)
        emptyFrame.Size = UDim2.new(1, 0, 0, 180)
        emptyFrame.BackgroundColor3 = Color3.fromRGB(248, 248, 250)
        corner(emptyFrame, 16)
        stroke(emptyFrame, Color3.fromRGB(220, 220, 225), 1, 0.4)
        
        local emptyGradient = Instance.new("UIGradient", emptyFrame)
        emptyGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(250, 250, 252)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(242, 242, 246))
        })
        emptyGradient.Rotation = 45
        
        -- Icon kecil
        local iconFrame = Instance.new("Frame", emptyFrame)
        iconFrame.Size = UDim2.new(0, 44, 0, 44)
        iconFrame.Position = UDim2.new(0.5, -22, 0, 35)
        iconFrame.BackgroundTransparency = 1
        
        local iconBuilder = iconBuilders[iconName]
        if iconBuilder then
            iconBuilder(iconFrame, Color3.fromRGB(180, 180, 190))
        end
        
        local emptyLabel = Instance.new("TextLabel", emptyFrame)
        emptyLabel.Size = UDim2.new(1, -20, 0, 26)
        emptyLabel.Position = UDim2.new(0, 10, 0, 88)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Text = message
        emptyLabel.TextColor3 = Color3.fromRGB(140, 140, 150)
        emptyLabel.Font = Enum.Font.GothamBold
        emptyLabel.TextSize = 13
        emptyLabel.TextXAlignment = Enum.TextXAlignment.Center
        
        local emptySub = Instance.new("TextLabel", emptyFrame)
        emptySub.Size = UDim2.new(1, -20, 0, 18)
        emptySub.Position = UDim2.new(0, 10, 0, 116)
        emptySub.BackgroundTransparency = 1
        emptySub.Text = "Browse and add items to see them here"
        emptySub.TextColor3 = Color3.fromRGB(180, 180, 190)
        emptySub.Font = Enum.Font.Gotham
        emptySub.TextSize = 9
        emptySub.TextXAlignment = Enum.TextXAlignment.Center
    end
    
    -- ==================== RENDER FUNCTION ====================
    local function render()
        for _, c in ipairs(listHolder:GetChildren()) do
            if not c:IsA("UIListLayout") and not c:IsA("UIGridLayout") then c:Destroy() end
        end
        
        if favSelectedTab == "Players" then
            -- Hitung jumlah favorit
            local favCount = 0
            for _, p in ipairs(Players:GetPlayers()) do
                if favSet[tostring(p.UserId)] then favCount = favCount + 1 end
            end
            
            if favCount == 0 then
                showEmptyState("No favorite players yet", "Players")
                return
            end
            
            -- List layout untuk players
            local playerList = Instance.new("UIListLayout", listHolder)
            playerList.Padding = UDim.new(0, 8)
            playerList.SortOrder = Enum.SortOrder.LayoutOrder
            
            -- Counter kecil
            local counterFrame = Instance.new("Frame", listHolder)
            counterFrame.Size = UDim2.new(1, 0, 0, 20)
            counterFrame.BackgroundTransparency = 1
            
            local counterText = Instance.new("TextLabel", counterFrame)
            counterText.Size = UDim2.new(0, 120, 1, 0)
            counterText.BackgroundTransparency = 1
            counterText.Text = favCount .. " player" .. (favCount ~= 1 and "s" or "")
            counterText.TextColor3 = T.Text2
            counterText.Font = Enum.Font.GothamBold
            counterText.TextSize = 10
            counterText.TextXAlignment = Enum.TextXAlignment.Left
            
            for _, p in ipairs(Players:GetPlayers()) do
                if favSet[tostring(p.UserId)] then
                    -- Player card compact
                    local card = Instance.new("Frame", listHolder)
                    card.Size = UDim2.new(1, 0, 0, 72)
                    card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    corner(card, 14)
                    stroke(card, Color3.fromRGB(225, 225, 230), 1, 0.3)
                    
                    -- Shadow
                    local cardShadow = Instance.new("Frame", card)
                    cardShadow.Size = UDim2.new(1, 6, 1, 6)
                    cardShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
                    cardShadow.AnchorPoint = Vector2.new(0.5, 0.5)
                    cardShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    cardShadow.BackgroundTransparency = 0.93
                    cardShadow.ZIndex = -1
                    corner(cardShadow, 16)
                    
                    -- Gold accent bar
                    local accentBar = Instance.new("Frame", card)
                    accentBar.Size = UDim2.new(0, 3, 1, -14)
                    accentBar.Position = UDim2.new(0, 7, 0, 7)
                    accentBar.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
                    corner(accentBar, 2)
                    
                    -- Avatar compact
                    local avatarFrame = Instance.new("Frame", card)
                    avatarFrame.Size = UDim2.new(0, 48, 0, 48)
                    avatarFrame.Position = UDim2.new(0, 16, 0.5, -24)
                    avatarFrame.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
                    avatarFrame.BackgroundTransparency = 0.9
                    corner(avatarFrame, 100)
                    
                    local avatar = Instance.new("ImageLabel", avatarFrame)
                    avatar.Size = UDim2.new(0, 40, 0, 40)
                    avatar.Position = UDim2.new(0.5, -20, 0.5, -20)
                    avatar.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
                    avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. p.UserId .. "&width=100&height=100&format=png"
                    corner(avatar, 100)
                    stroke(avatar, Color3.fromRGB(255, 255, 255), 1.5, 0)
                    
                    -- Name
                    local nameLbl = Instance.new("TextLabel", card)
                    nameLbl.Size = UDim2.new(1, -200, 0, 24)
                    nameLbl.Position = UDim2.new(0, 72, 0, 12)
                    nameLbl.BackgroundTransparency = 1
                    nameLbl.Text = p.DisplayName
                    nameLbl.TextColor3 = T.Text
                    nameLbl.Font = Enum.Font.GothamBlack
                    nameLbl.TextSize = 14
                    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
                    
                    local userLbl = Instance.new("TextLabel", card)
                    userLbl.Size = UDim2.new(1, -200, 0, 16)
                    userLbl.Position = UDim2.new(0, 72, 0, 36)
                    userLbl.BackgroundTransparency = 1
                    userLbl.Text = "@" .. p.Name
                    userLbl.TextColor3 = T.Text2
                    userLbl.Font = Enum.Font.Gotham
                    userLbl.TextSize = 10
                    userLbl.TextXAlignment = Enum.TextXAlignment.Left
                    
                    -- Online dot kecil
                    local onlineDot = Instance.new("Frame", card)
                    onlineDot.Size = UDim2.new(0, 6, 0, 6)
                    onlineDot.Position = UDim2.new(0, 72, 0, 52)
                    onlineDot.BackgroundColor3 = T.Green
                    corner(onlineDot, 100)
                    
                    -- Action buttons
                    local selBtn = Instance.new("TextButton", card)
                    selBtn.Size = UDim2.new(0, 64, 0, 28)
                    selBtn.Position = UDim2.new(1, -140, 0.5, -14)
                    selBtn.BackgroundColor3 = T.Accent
                    selBtn.Text = "Select"
                    selBtn.TextColor3 = T.OnAccent
                    selBtn.Font = Enum.Font.GothamBold
                    selBtn.TextSize = 10
                    selBtn.AutoButtonColor = false
                    corner(selBtn, 7)
                    pressFX(selBtn)
                    selBtn.MouseButton1Click:Connect(function()
                        selectedPlayer = p
                        showDynamicNotification("Target: " .. p.DisplayName, T.Green)
                    end)
                    
                    local cloneBtn = Instance.new("TextButton", card)
                    cloneBtn.Size = UDim2.new(0, 64, 0, 28)
                    cloneBtn.Position = UDim2.new(1, -70, 0.5, -14)
                    cloneBtn.BackgroundColor3 = T.Green
                    cloneBtn.Text = "Clone"
                    cloneBtn.TextColor3 = T.OnAccent
                    cloneBtn.Font = Enum.Font.GothamBold
                    cloneBtn.TextSize = 10
                    cloneBtn.AutoButtonColor = false
                    corner(cloneBtn, 7)
                    pressFX(cloneBtn)
                    cloneBtn.MouseButton1Click:Connect(function()
                        cloneItems(p, function(done)
                            if done then showDynamicNotification("Clone complete!", T.Green) end
                        end)
                    end)
                end
            end
            
        elseif favSelectedTab == "Items" then
            if #favItems == 0 then
                showEmptyState("No favorite items yet", "Items")
                return
            end
            
            -- Grid layout 2 kolom
            local itemGrid = Instance.new("UIGridLayout", listHolder)
            itemGrid.CellSize = UDim2.new(0.5, -6, 0, 175)
            itemGrid.CellPadding = UDim2.new(0, 8, 0, 8)
            itemGrid.FillDirection = Enum.FillDirection.Horizontal
            itemGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
            itemGrid.SortOrder = Enum.SortOrder.LayoutOrder
            
            for i, item in ipairs(favItems) do
                local card = Instance.new("Frame", listHolder)
                card.Size = UDim2.new(0, 0, 0, 175)
                card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                card.LayoutOrder = i
                corner(card, 12)
                stroke(card, Color3.fromRGB(225, 225, 230), 1, 0.3)
                
                -- Shadow
                local cardShadow = Instance.new("Frame", card)
                cardShadow.Size = UDim2.new(1, 6, 1, 6)
                cardShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
                cardShadow.AnchorPoint = Vector2.new(0.5, 0.5)
                cardShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                cardShadow.BackgroundTransparency = 0.93
                cardShadow.ZIndex = -1
                corner(cardShadow, 14)
                
                -- Gold accent top
                local goldAccent = Instance.new("Frame", card)
                goldAccent.Size = UDim2.new(1, -16, 0, 2)
                goldAccent.Position = UDim2.new(0, 8, 0, 6)
                goldAccent.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
                goldAccent.BackgroundTransparency = 0.4
                corner(goldAccent, 1)
                
                -- Thumbnail container
                local imgContainer = Instance.new("Frame", card)
                imgContainer.Size = UDim2.new(0, 80, 0, 80)
                imgContainer.Position = UDim2.new(0.5, -40, 0, 14)
                imgContainer.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
                corner(imgContainer, 10)
                stroke(imgContainer, Color3.fromRGB(215, 215, 220), 1, 0.3)
                
                local thumb = Instance.new("ImageLabel", imgContainer)
                thumb.Size = UDim2.new(1, -8, 1, -8)
                thumb.Position = UDim2.new(0.5, 0, 0.5, 0)
                thumb.AnchorPoint = Vector2.new(0.5, 0.5)
                thumb.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
                thumb.Image = "https://www.roblox.com/asset-thumbnail/image?assetId=" .. item.id .. "&width=150&height=150&format=png"
                thumb.ScaleType = Enum.ScaleType.Fit
                corner(thumb, 7)
                
                -- ID label
                local idContainer = Instance.new("Frame", card)
                idContainer.Size = UDim2.new(1, -20, 0, 20)
                idContainer.Position = UDim2.new(0, 10, 0, 100)
                idContainer.BackgroundColor3 = Color3.fromRGB(240, 245, 252)
                corner(idContainer, 5)
                
                local idLabel = Instance.new("TextLabel", idContainer)
                idLabel.Size = UDim2.new(1, -4, 1, 0)
                idLabel.BackgroundTransparency = 1
                idLabel.Text = item.id
                idLabel.TextColor3 = Color3.fromRGB(0, 120, 60)
                idLabel.Font = Enum.Font.Code
                idLabel.TextSize = 10
                idLabel.TextXAlignment = Enum.TextXAlignment.Center
                
                local copyBtn = Instance.new("TextButton", idContainer)
                copyBtn.Size = UDim2.new(1, 0, 1, 0)
                copyBtn.BackgroundTransparency = 1
                copyBtn.Text = ""
                copyBtn.MouseButton1Click:Connect(function()
                    copyToClipboard(item.id)
                    showDynamicNotification("Copied: " .. item.id, T.Green)
                end)
                
                -- Item label
                local itemLabel = Instance.new("TextLabel", card)
                itemLabel.Size = UDim2.new(1, -20, 0, 16)
                itemLabel.Position = UDim2.new(0, 10, 0, 124)
                itemLabel.BackgroundTransparency = 1
                itemLabel.Text = item.label or "Item"
                itemLabel.TextColor3 = T.Text2
                itemLabel.Font = Enum.Font.GothamBold
                itemLabel.TextSize = 9
                itemLabel.TextXAlignment = Enum.TextXAlignment.Center
                itemLabel.TextTruncate = Enum.TextTruncate.AtEnd
                
                -- Action buttons
                local wearBtn = Instance.new("TextButton", card)
                wearBtn.Size = UDim2.new(0, 55, 0, 22)
                wearBtn.Position = UDim2.new(0.5, -60, 0, 145)
                wearBtn.BackgroundColor3 = T.Accent
                wearBtn.Text = "Wear"
                wearBtn.TextColor3 = T.OnAccent
                wearBtn.Font = Enum.Font.GothamBold
                wearBtn.TextSize = 9
                wearBtn.AutoButtonColor = false
                corner(wearBtn, 6)
                pressFX(wearBtn)
                wearBtn.MouseButton1Click:Connect(function()
                    fireHat({item.id})
                    showDynamicNotification("Wearing " .. item.id, T.Green)
                end)
                
                local delBtn = Instance.new("TextButton", card)
                delBtn.Size = UDim2.new(0, 55, 0, 22)
                delBtn.Position = UDim2.new(0.5, 5, 0, 145)
                delBtn.BackgroundColor3 = Color3.fromRGB(245, 220, 220)
                delBtn.Text = "Remove"
                delBtn.TextColor3 = T.Red
                delBtn.Font = Enum.Font.GothamBold
                delBtn.TextSize = 9
                delBtn.AutoButtonColor = false
                corner(delBtn, 6)
                pressFX(delBtn)
                delBtn.MouseButton1Click:Connect(function()
                    table.remove(favItems, i)
                    persistFavItems()
                    render()
                    showDynamicNotification("Item removed", T.Red)
                end)
            end
        end
    end
    
    render()
end

-- FRIENDS (dengan invite)
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
        table.sort(friends, function(a,b)
            local aOnline = Players:GetPlayerByUserId(a.Id) ~= nil
            local bOnline = Players:GetPlayerByUserId(b.Id) ~= nil
            if aOnline ~= bOnline then return aOnline end
            return (a.Username or a.Name) < (b.Username or b.Name)
        end)
        for _,friend in ipairs(friends)do
            local inServer=Players:GetPlayerByUserId(friend.Id)
            local row=Instance.new("Frame",listHolder);row.Size=UDim2.new(1,0,0,56);row.BackgroundColor3=T.Card2;corner(row,10);stroke(row,T.Border,1,0.3)
            local av=Instance.new("ImageLabel",row);av.Size=UDim2.new(0,40,0,40);av.Position=UDim2.new(0,8,0.5,-20);av.BackgroundColor3=T.BG
            av.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..friend.Id.."&width=100&height=100&format=png";corner(av,100)
            local nameLbl=Instance.new("TextLabel",row);nameLbl.Size=UDim2.new(1,-240,0,20);nameLbl.Position=UDim2.new(0,56,0,4);nameLbl.BackgroundTransparency=1
            nameLbl.Text=friend.Username or friend.Name or ("User "..friend.Id);nameLbl.TextColor3=T.Text;nameLbl.Font=Enum.Font.GothamBold;nameLbl.TextSize=12;nameLbl.TextXAlignment=Enum.TextXAlignment.Left;nameLbl.TextTruncate=Enum.TextTruncate.AtEnd
            local statusLbl=Instance.new("TextLabel",row);statusLbl.Size=UDim2.new(0,60,0,16);statusLbl.Position=UDim2.new(0,56,0,28);statusLbl.BackgroundTransparency=1
            statusLbl.Text=inServer and "🟢 Online" or "⚪ Offline";statusLbl.TextColor3=inServer and T.Green or T.Text2;statusLbl.Font=Enum.Font.Gotham;statusLbl.TextSize=10;statusLbl.TextXAlignment=Enum.TextXAlignment.Left
            local inviteBtn=Instance.new("TextButton",row);inviteBtn.Size=UDim2.new(0,50,0,28);inviteBtn.Position=UDim2.new(1,-180,0.5,-14);inviteBtn.BackgroundColor3=T.Accent;inviteBtn.Text="Invite";inviteBtn.TextColor3=T.OnAccent;inviteBtn.Font=Enum.Font.GothamBold;inviteBtn.TextSize=10;inviteBtn.AutoButtonColor=false;corner(inviteBtn,6);pressFX(inviteBtn)
            inviteBtn.MouseButton1Click:Connect(function()
                if inServer then
                    pcall(function() TeleportService:PromptGameInvite(inServer) end)
                    showDynamicNotification("Inviting "..inServer.DisplayName, T.Green)
                else
                    showDynamicNotification("Player offline, cannot invite", T.Red)
                end
            end)
            if inServer then
                local selBtn=Instance.new("TextButton",row);selBtn.Size=UDim2.new(0,55,0,28);selBtn.Position=UDim2.new(1,-122,0.5,-14);selBtn.BackgroundColor3=T.Accent;selBtn.Text="Select";selBtn.TextColor3=T.OnAccent;selBtn.Font=Enum.Font.GothamBold;selBtn.TextSize=10;selBtn.AutoButtonColor=false;corner(selBtn,6);pressFX(selBtn)
                selBtn.MouseButton1Click:Connect(function()selectedPlayer=inServer;showDynamicNotification("Target: "..inServer.DisplayName,T.Green)end)
            end
            local cloneBtn=Instance.new("TextButton",row);cloneBtn.Size=UDim2.new(0,55,0,28);cloneBtn.Position=UDim2.new(1,-60,0.5,-14);cloneBtn.BackgroundColor3=T.Green;cloneBtn.Text="Clone";cloneBtn.TextColor3=T.OnAccent;cloneBtn.Font=Enum.Font.GothamBold;cloneBtn.TextSize=10;cloneBtn.AutoButtonColor=false;corner(cloneBtn,6);pressFX(cloneBtn)
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

-- SAVE & TELEPORT
local function openTeleportApp()
    local saveFrame=Instance.new("Frame",appContent);saveFrame.Size=UDim2.new(1,0,0,100);saveFrame.BackgroundColor3=T.Card2;corner(saveFrame,12);stroke(saveFrame,T.Border,1,0.3)
    local saveTitle=Instance.new("TextLabel",saveFrame);saveTitle.Size=UDim2.new(1,-20,0,20);saveTitle.Position=UDim2.new(0,10,0,6);saveTitle.BackgroundTransparency=1;saveTitle.Text="Save Current Location";saveTitle.TextColor3=T.Text;saveTitle.Font=Enum.Font.GothamBold;saveTitle.TextSize=13;saveTitle.TextXAlignment=Enum.TextXAlignment.Left
    local nameInput=Instance.new("TextBox",saveFrame);nameInput.Size=UDim2.new(1,-20,0,28);nameInput.Position=UDim2.new(0,10,0,30);nameInput.PlaceholderText="Location name";nameInput.Text="";nameInput.BackgroundColor3=T.Card;nameInput.TextColor3=T.Text;nameInput.Font=Enum.Font.Gotham;nameInput.TextSize=12;corner(nameInput,6)
    local saveBtn=Instance.new("TextButton",saveFrame);saveBtn.Size=UDim2.new(0,80,0,28);saveBtn.Position=UDim2.new(0,10,0,64);saveBtn.BackgroundColor3=T.Accent;saveBtn.Text="Save";saveBtn.TextColor3=T.OnAccent;saveBtn.Font=Enum.Font.GothamBold;saveBtn.TextSize=12;saveBtn.AutoButtonColor=false;corner(saveBtn,6);pressFX(saveBtn)
    saveBtn.MouseButton1Click:Connect(function()
        local name = nameInput.Text
        if name == "" then name = "Loc "..#teleportLocations+1 end
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = char.HumanoidRootPart.CFrame
            table.insert(teleportLocations, {name=name, x=pos.X, y=pos.Y, z=pos.Z})
            persistTeleportLocations()
            showDynamicNotification("Saved: "..name, T.Green)
            nameInput.Text = ""
            refreshCurr()
        else
            showDynamicNotification("No character", T.Red)
        end
    end)
    local locTitle=Instance.new("TextLabel",appContent);locTitle.Size=UDim2.new(1,0,0,20);locTitle.BackgroundTransparency=1;locTitle.Text="Saved Locations";locTitle.TextColor3=T.Text;locTitle.Font=Enum.Font.GothamBold;locTitle.TextSize=12;locTitle.TextXAlignment=Enum.TextXAlignment.Left
    if #teleportLocations == 0 then
        local n=Instance.new("TextLabel",appContent);n.Size=UDim2.new(1,0,0,30);n.BackgroundTransparency=1;n.Text="No saved locations.";n.TextColor3=T.Text2;n.Font=Enum.Font.Gotham;n.TextSize=11
    else
        for i, loc in ipairs(teleportLocations) do
            local row=Instance.new("Frame",appContent);row.Size=UDim2.new(1,0,0,60);row.BackgroundColor3=T.Card2;corner(row,10);stroke(row,T.Border,1,0.3)
            local nameLbl=Instance.new("TextLabel",row);nameLbl.Size=UDim2.new(1,-160,0,20);nameLbl.Position=UDim2.new(0,8,0,6);nameLbl.BackgroundTransparency=1;nameLbl.Text=loc.name;nameLbl.TextColor3=T.Text;nameLbl.Font=Enum.Font.GothamBold;nameLbl.TextSize=13;nameLbl.TextXAlignment=Enum.TextXAlignment.Left
            local posLbl=Instance.new("TextLabel",row);posLbl.Size=UDim2.new(1,-160,0,16);posLbl.Position=UDim2.new(0,8,0,30);posLbl.BackgroundTransparency=1;posLbl.Text=string.format("X: %.1f Y: %.1f Z: %.1f", loc.x, loc.y, loc.z);posLbl.TextColor3=T.Text2;posLbl.Font=Enum.Font.Code;posLbl.TextSize=10;posLbl.TextXAlignment=Enum.TextXAlignment.Left
            local tpBtn=Instance.new("TextButton",row);tpBtn.Size=UDim2.new(0,60,0,28);tpBtn.Position=UDim2.new(1,-130,0.5,-14);tpBtn.BackgroundColor3=T.Green;tpBtn.Text="TP";tpBtn.TextColor3=T.OnAccent;tpBtn.Font=Enum.Font.GothamBold;tpBtn.TextSize=12;tpBtn.AutoButtonColor=false;corner(tpBtn,6);pressFX(tpBtn)
            tpBtn.MouseButton1Click:Connect(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char:MoveTo(Vector3.new(loc.x, loc.y, loc.z))
                    showDynamicNotification("Teleported to "..loc.name, T.Green)
                end
            end)
            local delBtn=Instance.new("TextButton",row);delBtn.Size=UDim2.new(0,60,0,28);delBtn.Position=UDim2.new(1,-60,0.5,-14);delBtn.BackgroundColor3=T.Red;delBtn.Text="Delete";delBtn.TextColor3=Color3.new(1,1,1);delBtn.Font=Enum.Font.GothamBold;delBtn.TextSize=10;delBtn.AutoButtonColor=false;corner(delBtn,6);pressFX(delBtn)
            delBtn.MouseButton1Click:Connect(function()
                table.remove(teleportLocations, i)
                persistTeleportLocations()
                refreshCurr()
            end)
        end
    end
end

-- ================= COMMAND APP (FULL - ALL COMMANDS + COLOR PICKER) =================
local function openCommandApp()
    -- ==================== HEADER ====================
    local headerCard = Instance.new("Frame", appContent)
    headerCard.Size = UDim2.new(1, 0, 0, 50)
    headerCard.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    headerCard.LayoutOrder = 0
    corner(headerCard, 14)
    
    local headerGradient = Instance.new("UIGradient", headerCard)
    headerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 42)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 28))
    })
    headerGradient.Rotation = 135
    
    local headerAccent = Instance.new("Frame", headerCard)
    headerAccent.Size = UDim2.new(1, 0, 0, 2)
    headerAccent.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    corner(headerAccent, 1)
    
    local headerTitle = Instance.new("TextLabel", headerCard)
    headerTitle.Size = UDim2.new(1, -24, 0, 22)
    headerTitle.Position = UDim2.new(0, 12, 0, 6)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "Commands"
    headerTitle.TextColor3 = Color3.new(1, 1, 1)
    headerTitle.Font = Enum.Font.GothamBlack
    headerTitle.TextSize = 15
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local headerSub = Instance.new("TextLabel", headerCard)
    headerSub.Size = UDim2.new(1, -24, 0, 14)
    headerSub.Position = UDim2.new(0, 12, 0, 30)
    headerSub.BackgroundTransparency = 1
    headerSub.Text = "re | rejoin | sit | size | reset | sync | fx | gear"
    headerSub.TextColor3 = Color3.fromRGB(160, 160, 180)
    headerSub.Font = Enum.Font.Gotham
    headerSub.TextSize = 9
    headerSub.TextXAlignment = Enum.TextXAlignment.Left
    
    -- ==================== COLOR LIST ====================
    local colorList = {
        "red", "dark red", "pink", "hot pink", "magenta",
        "orange", "neon orange", "yellow", "neon yellow",
        "lime", "green", "dark green", "neon green",
        "teal", "cyan", "blue", "neon blue", "sky blue",
        "dark blue", "navy blue", "purple", "violet", "lavender",
        "white", "light grey", "grey", "dark grey", "black",
        "brown", "dark brown", "tan", "sand", "gold", "pearl", "off"
    }
    
    local selectedColor = "red"
    
    -- ==================== COMMAND HELPER ====================
    local function fireCommand(cmdName, args)
        local remote = ReplicatedStorage
        local remotePath = CONFIG.REMOTE_PATH or "Remotes.Command.CommandEvent"
        
        for _, part in ipairs(remotePath:split(".")) do
            local found = remote:FindFirstChild(part)
            if found then
                remote = found
            else
                local success, result = pcall(function()
                    return remote:WaitForChild(part, 2)
                end)
                if success and result then
                    remote = result
                else
                    showDynamicNotification("Remote not found: " .. part, T.Red)
                    return false
                end
            end
        end
        
        pcall(function()
            remote:FireServer(cmdName, args)
        end)
        
        return true
    end
    
    -- ==================== BASIC COMMANDS ====================
    local basicCommands = {
        {
            name = "Reset Character",
            cmd = "re",
            desc = "Resets your character using 're' command",
            color = Color3.fromRGB(255, 80, 80),
            action = function() resetCharacter() end
        },
        {
            name = "Rejoin Server",
            cmd = "rejoin",
            desc = "Rejoins the current server",
            color = Color3.fromRGB(80, 150, 255),
            action = function()
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
                end)
            end
        },
        {
            name = "Sit Character",
            cmd = "sit",
            desc = "Makes your character sit down",
            color = Color3.fromRGB(255, 180, 50),
            action = function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChildOfClass("Humanoid") then
                    char.Humanoid.Sit = true
                end
            end
        },
        {
            name = "Reset (Command)",
            cmd = "reset",
            desc = "Sends 'reset' command to server",
            color = Color3.fromRGB(255, 100, 100),
            action = function()
                fireCommand("reset", {"reset"})
            end
        }
    }
    
    -- ==================== SYNC COMMANDS ====================
    local syncCommands = {
        {
            name = "Sync Player",
            cmd = "sync",
            desc = "Sync with another player (enter ID below)",
            color = Color3.fromRGB(100, 200, 255),
            hasInput = true,
            inputPlaceholder = "Enter Player UserID...",
            action = function(playerId)
                fireCommand("sync", {"sync", "id " .. playerId})
            end
        },
        {
            name = "Unsync",
            cmd = "unsync",
            desc = "Stops syncing with player",
            color = Color3.fromRGB(255, 150, 100),
            action = function()
                fireCommand("unsync", {"unsync"})
            end
        },
        {
            name = "Clear Hats",
            cmd = "clearhats",
            desc = "Removes all hats from your character",
            color = Color3.fromRGB(200, 100, 200),
            action = function()
                fireCommand("clearhats", {"clearhats"})
            end
        }
    }
    
    -- ==================== GEAR COMMANDS ====================
    local gearCommands = {
        {
            name = "Korblox",
            cmd = "korblox",
            desc = "Gives you Korblox item",
            color = Color3.fromRGB(150, 100, 255),
            action = function()
                fireCommand("korblox", {"korblox"})
            end
        },
        {
            name = "Headless",
            cmd = "headless",
            desc = "Gives you Headless item",
            color = Color3.fromRGB(50, 50, 50),
            action = function()
                fireCommand("headless", {"headless"})
            end
        }
    }
    
    -- ==================== FX COMMANDS (WITH COLOR) ====================
    local fxCommands = {
        {
            name = "Fire",
            cmd = "fire",
            desc = "Fire effect (normal/dark)",
            color = Color3.fromRGB(255, 120, 30)
        },
        {
            name = "Light",
            cmd = "light",
            desc = "Light effect (normal/dark)",
            color = Color3.fromRGB(255, 255, 100)
        },
        {
            name = "Highlight",
            cmd = "highlight",
            desc = "Highlight effect (normal/dark)",
            color = Color3.fromRGB(100, 255, 255)
        },
        {
            name = "Sparkle",
            cmd = "sparkle",
            desc = "Sparkle effect (normal/dark)",
            color = Color3.fromRGB(255, 200, 255)
        }
    }
    
    -- ==================== SIZE COMMAND ====================
    local sizeCommand = {
        name = "Change Size",
        cmd = "size",
        desc = "Adjust your character size (0.5 - 1.0)",
        color = Color3.fromRGB(100, 200, 100)
    }
    
    -- ==================== RENDER: BASIC COMMANDS ====================
    local layoutOrder = 1
    
    -- Section: Basic
    local basicHeader = Instance.new("Frame", appContent)
    basicHeader.Size = UDim2.new(1, 0, 0, 24)
    basicHeader.BackgroundTransparency = 1
    basicHeader.LayoutOrder = layoutOrder
    layoutOrder = layoutOrder + 1
    
    local basicAccent = Instance.new("Frame", basicHeader)
    basicAccent.Size = UDim2.new(0, 3, 0, 16)
    basicAccent.Position = UDim2.new(0, 0, 0.5, -8)
    basicAccent.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    corner(basicAccent, 2)
    
    local basicTitle = Instance.new("TextLabel", basicHeader)
    basicTitle.Size = UDim2.new(1, -10, 1, 0)
    basicTitle.Position = UDim2.new(0, 8, 0, 0)
    basicTitle.BackgroundTransparency = 1
    basicTitle.Text = "Basic Commands"
    basicTitle.TextColor3 = T.Text
    basicTitle.Font = Enum.Font.GothamBlack
    basicTitle.TextSize = 12
    basicTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    for _, cmd in ipairs(basicCommands) do
        local card = createCommandCard(appContent, layoutOrder, cmd)
        layoutOrder = layoutOrder + 1
    end
    
    -- ==================== SIZE COMMAND ====================
    local sizeCard = Instance.new("Frame", appContent)
    sizeCard.Size = UDim2.new(1, 0, 0, 110)
    sizeCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sizeCard.LayoutOrder = layoutOrder
    corner(sizeCard, 14)
    stroke(sizeCard, Color3.fromRGB(225, 225, 230), 1, 0.3)
    layoutOrder = layoutOrder + 1
    
    local sizeAccent = Instance.new("Frame", sizeCard)
    sizeAccent.Size = UDim2.new(0, 3, 1, -16)
    sizeAccent.Position = UDim2.new(0, 8, 0, 8)
    sizeAccent.BackgroundColor3 = sizeCommand.color
    corner(sizeAccent, 2)
    
    local sizeTitle = Instance.new("TextLabel", sizeCard)
    sizeTitle.Size = UDim2.new(1, -120, 0, 22)
    sizeTitle.Position = UDim2.new(0, 14, 0, 10)
    sizeTitle.BackgroundTransparency = 1
    sizeTitle.Text = sizeCommand.name
    sizeTitle.TextColor3 = T.Text
    sizeTitle.Font = Enum.Font.GothamBlack
    sizeTitle.TextSize = 13
    sizeTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local sizeDesc = Instance.new("TextLabel", sizeCard)
    sizeDesc.Size = UDim2.new(1, -120, 0, 14)
    sizeDesc.Position = UDim2.new(0, 14, 0, 32)
    sizeDesc.BackgroundTransparency = 1
    sizeDesc.Text = sizeCommand.desc
    sizeDesc.TextColor3 = T.Text2
    sizeDesc.Font = Enum.Font.Gotham
    sizeDesc.TextSize = 9
    sizeDesc.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Slider
    local sliderBar = Instance.new("TextButton", sizeCard)
    sliderBar.Size = UDim2.new(1, -28, 0, 28)
    sliderBar.Position = UDim2.new(0, 14, 0, 52)
    sliderBar.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
    sliderBar.Text = ""
    corner(sliderBar, 14)
    
    local fill = Instance.new("Frame", sliderBar)
    fill.Size = UDim2.new(1, 0, 1, 0)
    fill.BackgroundColor3 = sizeCommand.color
    corner(fill, 14)
    
    local sizeVal = Instance.new("TextLabel", sliderBar)
    sizeVal.Size = UDim2.new(1, 0, 1, 0)
    sizeVal.BackgroundTransparency = 1
    sizeVal.Text = "Size: 1.0"
    sizeVal.TextColor3 = Color3.new(1, 1, 1)
    sizeVal.Font = Enum.Font.GothamBold
    sizeVal.TextSize = 11
    sizeVal.ZIndex = 2
    
    local curSize = 1.0
    
    local function setSizeVal(val)
        curSize = math.clamp(val, 0.5, 1.0)
        fill.Size = UDim2.new((curSize - 0.5) * 2, 0, 1, 0)
        sizeVal.Text = "Size: " .. string.format("%.2f", curSize)
    end
    
    sliderBar.MouseButton1Down:Connect(function()
        local con
        con = RunService.RenderStepped:Connect(function()
            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                con:Disconnect()
                return
            end
            local mousePos = UserInputService:GetMouseLocation()
            local absX = sliderBar.AbsolutePosition.X
            local absSizeX = sliderBar.AbsoluteSize.X
            if absSizeX <= 0 then absSizeX = 1 end
            local relX = (mousePos.X - absX) / absSizeX
            setSizeVal(0.5 + relX * 0.5)
        end)
    end)
    
    local applyBtn = Instance.new("TextButton", sizeCard)
    applyBtn.Size = UDim2.new(0, 60, 0, 22)
    applyBtn.Position = UDim2.new(1, -74, 0, 52)
    applyBtn.BackgroundColor3 = sizeCommand.color
    applyBtn.Text = "Apply"
    applyBtn.TextColor3 = T.OnAccent
    applyBtn.Font = Enum.Font.GothamBold
    applyBtn.TextSize = 10
    applyBtn.AutoButtonColor = false
    corner(applyBtn, 6)
    pressFX(applyBtn)
    applyBtn.MouseButton1Click:Connect(function()
        setSize(curSize)
        showDynamicNotification("Size: " .. string.format("%.2f", curSize), T.Green)
    end)
    
    -- Preset buttons
    local presets = {0.5, 0.7, 0.8, 0.9, 1.0}
    for i, p in ipairs(presets) do
        local pBtn = Instance.new("TextButton", sizeCard)
        pBtn.Size = UDim2.new(0, 40, 0, 18)
        pBtn.Position = UDim2.new(0, 14 + (i-1) * 44, 0, 84)
        pBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
        pBtn.Text = string.format("%.1f", p)
        pBtn.TextColor3 = T.Text
        pBtn.Font = Enum.Font.GothamBold
        pBtn.TextSize = 9
        pBtn.AutoButtonColor = false
        corner(pBtn, 5)
        stroke(pBtn, T.Border, 1, 0.3)
        pressFX(pBtn)
        pBtn.MouseButton1Click:Connect(function()
            setSizeVal(p)
            setSize(p)
            showDynamicNotification("Size: " .. string.format("%.1f", p), T.Green)
        end)
    end
    
    -- ==================== SECTION: SYNC ====================
    local syncHeader = createSectionHeader(appContent, layoutOrder, "Sync Commands", Color3.fromRGB(100, 200, 255))
    layoutOrder = layoutOrder + 1
    
    for _, cmd in ipairs(syncCommands) do
        if cmd.hasInput then
            -- Card dengan input
            local card = Instance.new("Frame", appContent)
            card.Size = UDim2.new(1, 0, 0, 90)
            card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            card.LayoutOrder = layoutOrder
            corner(card, 14)
            stroke(card, Color3.fromRGB(225, 225, 230), 1, 0.3)
            layoutOrder = layoutOrder + 1
            
            local accent = Instance.new("Frame", card)
            accent.Size = UDim2.new(0, 3, 1, -16)
            accent.Position = UDim2.new(0, 8, 0, 8)
            accent.BackgroundColor3 = cmd.color
            corner(accent, 2)
            
            local nameLbl = Instance.new("TextLabel", card)
            nameLbl.Size = UDim2.new(1, -24, 0, 20)
            nameLbl.Position = UDim2.new(0, 14, 0, 8)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = cmd.name
            nameLbl.TextColor3 = T.Text
            nameLbl.Font = Enum.Font.GothamBlack
            nameLbl.TextSize = 13
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            
            local input = Instance.new("TextBox", card)
            input.Size = UDim2.new(1, -28, 0, 28)
            input.Position = UDim2.new(0, 14, 0, 32)
            input.PlaceholderText = cmd.inputPlaceholder or "Enter value..."
            input.Text = ""
            input.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
            input.TextColor3 = T.Text
            input.Font = Enum.Font.Gotham
            input.TextSize = 11
            corner(input, 6)
            stroke(input, Color3.fromRGB(220, 220, 225), 1, 0.3)
            
            local execBtn = Instance.new("TextButton", card)
            execBtn.Size = UDim2.new(0, 70, 0, 24)
            execBtn.Position = UDim2.new(1, -84, 0, 58)
            execBtn.BackgroundColor3 = cmd.color
            execBtn.Text = "Execute"
            execBtn.TextColor3 = T.OnAccent
            execBtn.Font = Enum.Font.GothamBold
            execBtn.TextSize = 10
            execBtn.AutoButtonColor = false
            corner(execBtn, 6)
            pressFX(execBtn)
            execBtn.MouseButton1Click:Connect(function()
                local val = input.Text
                if val == "" then
                    showDynamicNotification("Enter a value!", T.Red)
                    return
                end
                cmd.action(val)
                showDynamicNotification(cmd.name .. " executed!", T.Green)
            end)
        else
            local card = createCommandCard(appContent, layoutOrder, cmd)
            layoutOrder = layoutOrder + 1
        end
    end
    
    -- ==================== SECTION: GEAR ====================
    local gearHeader = createSectionHeader(appContent, layoutOrder, "Gear Commands", Color3.fromRGB(150, 100, 255))
    layoutOrder = layoutOrder + 1
    
    for _, cmd in ipairs(gearCommands) do
        local card = createCommandCard(appContent, layoutOrder, cmd)
        layoutOrder = layoutOrder + 1
    end
    
    -- ==================== SECTION: FX (WITH COLOR PICKER) ====================
    local fxHeader = createSectionHeader(appContent, layoutOrder, "Effect Commands", Color3.fromRGB(255, 120, 30))
    layoutOrder = layoutOrder + 1
    
    -- Color picker row
    local colorCard = Instance.new("Frame", appContent)
    colorCard.Size = UDim2.new(1, 0, 0, 80)
    colorCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    colorCard.LayoutOrder = layoutOrder
    corner(colorCard, 14)
    stroke(colorCard, Color3.fromRGB(225, 225, 230), 1, 0.3)
    layoutOrder = layoutOrder + 1
    
    local colorTitle = Instance.new("TextLabel", colorCard)
    colorTitle.Size = UDim2.new(1, -24, 0, 20)
    colorTitle.Position = UDim2.new(0, 12, 0, 8)
    colorTitle.BackgroundTransparency = 1
    colorTitle.Text = "Selected Color: " .. selectedColor
    colorTitle.TextColor3 = T.Text
    colorTitle.Font = Enum.Font.GothamBlack
    colorTitle.TextSize = 12
    colorTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Color grid (2 rows)
    local colorGrid = Instance.new("Frame", colorCard)
    colorGrid.Size = UDim2.new(1, -24, 0, 44)
    colorGrid.Position = UDim2.new(0, 12, 0, 30)
    colorGrid.BackgroundTransparency = 1
    
    local gridLayout = Instance.new("UIGridLayout", colorGrid)
    gridLayout.CellSize = UDim2.new(0, 60, 0, 18)
    gridLayout.CellPadding = UDim2.new(0, 3, 0, 2)
    gridLayout.FillDirection = Enum.FillDirection.Horizontal
    gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Hanya tampilkan beberapa warna populer di grid
    local popularColors = {
        "red", "dark red", "pink", "magenta", "orange", "neon orange",
        "yellow", "lime", "green", "dark green", "neon green",
        "teal", "cyan", "blue", "neon blue", "sky blue",
        "dark blue", "purple", "violet", "white", "black", "gold"
    }
    
    for _, colName in ipairs(popularColors) do
        local colBtn = Instance.new("TextButton", colorGrid)
        colBtn.Size = UDim2.new(0, 60, 0, 18)
        colBtn.Text = colName
        colBtn.TextColor3 = Color3.fromRGB(100, 100, 100)
        colBtn.Font = Enum.Font.GothamBold
        colBtn.TextSize = 7
        colBtn.AutoButtonColor = false
        colBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
        
        if colName == selectedColor then
            colBtn.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
            colBtn.TextColor3 = Color3.new(1, 1, 1)
        end
        
        corner(colBtn, 5)
        stroke(colBtn, Color3.fromRGB(220, 220, 225), 1, 0.3)
        pressFX(colBtn)
        
        colBtn.MouseButton1Click:Connect(function()
            selectedColor = colName
            colorTitle.Text = "Selected Color: " .. selectedColor
            -- Update semua color button
            for _, b in ipairs(colorGrid:GetChildren()) do
                if b:IsA("TextButton") then
                    b.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
                    b.TextColor3 = Color3.fromRGB(100, 100, 100)
                end
            end
            colBtn.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
            colBtn.TextColor3 = Color3.new(1, 1, 1)
        end)
    end
    
    -- FX Command cards
    for _, cmd in ipairs(fxCommands) do
        local card = Instance.new("Frame", appContent)
        card.Size = UDim2.new(1, 0, 0, 100)
        card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        card.LayoutOrder = layoutOrder
        corner(card, 14)
        stroke(card, Color3.fromRGB(225, 225, 230), 1, 0.3)
        layoutOrder = layoutOrder + 1
        
        local accent = Instance.new("Frame", card)
        accent.Size = UDim2.new(0, 3, 1, -16)
        accent.Position = UDim2.new(0, 8, 0, 8)
        accent.BackgroundColor3 = cmd.color
        corner(accent, 2)
        
        local nameLbl = Instance.new("TextLabel", card)
        nameLbl.Size = UDim2.new(1, -24, 0, 20)
        nameLbl.Position = UDim2.new(0, 14, 0, 8)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = cmd.name .. " Effect"
        nameLbl.TextColor3 = T.Text
        nameLbl.Font = Enum.Font.GothamBlack
        nameLbl.TextSize = 13
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        
        local descLbl = Instance.new("TextLabel", card)
        descLbl.Size = UDim2.new(1, -24, 0, 14)
        descLbl.Position = UDim2.new(0, 14, 0, 28)
        descLbl.BackgroundTransparency = 1
        descLbl.Text = cmd.desc .. " | Color: " .. selectedColor
        descLbl.TextColor3 = T.Text2
        descLbl.Font = Enum.Font.Gotham
        descLbl.TextSize = 9
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Normal button
        local normalBtn = Instance.new("TextButton", card)
        normalBtn.Size = UDim2.new(0, 80, 0, 26)
        normalBtn.Position = UDim2.new(0, 14, 0, 50)
        normalBtn.BackgroundColor3 = cmd.color
        normalBtn.Text = cmd.name
        normalBtn.TextColor3 = T.OnAccent
        normalBtn.Font = Enum.Font.GothamBold
        normalBtn.TextSize = 10
        normalBtn.AutoButtonColor = false
        corner(normalBtn, 6)
        pressFX(normalBtn)
        normalBtn.MouseButton1Click:Connect(function()
            fireCommand(cmd.cmd, {cmd.cmd, selectedColor})
            showDynamicNotification(cmd.name .. " (" .. selectedColor .. ") applied!", T.Green)
        end)
        
        -- Dark button
        local darkBtn = Instance.new("TextButton", card)
        darkBtn.Size = UDim2.new(0, 80, 0, 26)
        darkBtn.Position = UDim2.new(0, 100, 0, 50)
        darkBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        darkBtn.Text = cmd.name .. " Dark"
        darkBtn.TextColor3 = T.OnAccent
        darkBtn.Font = Enum.Font.GothamBold
        darkBtn.TextSize = 10
        darkBtn.AutoButtonColor = false
        corner(darkBtn, 6)
        pressFX(darkBtn)
        darkBtn.MouseButton1Click:Connect(function()
            fireCommand(cmd.cmd, {cmd.cmd, "dark", selectedColor})
            showDynamicNotification(cmd.name .. " Dark (" .. selectedColor .. ") applied!", T.Green)
        end)
        
        -- Quick color label
        local quickLabel = Instance.new("TextLabel", card)
        quickLabel.Size = UDim2.new(1, -200, 0, 14)
        quickLabel.Position = UDim2.new(0, 190, 0, 56)
        quickLabel.BackgroundTransparency = 1
        quickLabel.Text = "Color: " .. selectedColor
        quickLabel.TextColor3 = T.Text2
        quickLabel.Font = Enum.Font.Gotham
        quickLabel.TextSize = 8
        quickLabel.TextXAlignment = Enum.TextXAlignment.Left
    end
end

-- ==================== HELPER FUNCTIONS ====================
function createSectionHeader(parent, order, title, color)
    local header = Instance.new("Frame", parent)
    header.Size = UDim2.new(1, 0, 0, 24)
    header.BackgroundTransparency = 1
    header.LayoutOrder = order
    
    local accent = Instance.new("Frame", header)
    accent.Size = UDim2.new(0, 3, 0, 16)
    accent.Position = UDim2.new(0, 0, 0.5, -8)
    accent.BackgroundColor3 = color
    corner(accent, 2)
    
    local titleLbl = Instance.new("TextLabel", header)
    titleLbl.Size = UDim2.new(1, -10, 1, 0)
    titleLbl.Position = UDim2.new(0, 8, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = T.Text
    titleLbl.Font = Enum.Font.GothamBlack
    titleLbl.TextSize = 12
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    
    return header
end

function createCommandCard(parent, order, cmd)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(1, 0, 0, 72)
    card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    card.LayoutOrder = order
    corner(card, 14)
    stroke(card, Color3.fromRGB(225, 225, 230), 1, 0.3)
    
    local accent = Instance.new("Frame", card)
    accent.Size = UDim2.new(0, 3, 1, -16)
    accent.Position = UDim2.new(0, 8, 0, 8)
    accent.BackgroundColor3 = cmd.color
    corner(accent, 2)
    
    local nameLbl = Instance.new("TextLabel", card)
    nameLbl.Size = UDim2.new(1, -100, 0, 22)
    nameLbl.Position = UDim2.new(0, 14, 0, 10)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = cmd.name
    nameLbl.TextColor3 = T.Text
    nameLbl.Font = Enum.Font.GothamBlack
    nameLbl.TextSize = 13
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local descLbl = Instance.new("TextLabel", card)
    descLbl.Size = UDim2.new(1, -100, 0, 16)
    descLbl.Position = UDim2.new(0, 14, 0, 32)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = cmd.desc
    descLbl.TextColor3 = T.Text2
    descLbl.Font = Enum.Font.Gotham
    descLbl.TextSize = 9
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local cmdBadge = Instance.new("Frame", card)
    cmdBadge.Size = UDim2.new(0, 55, 0, 16)
    cmdBadge.Position = UDim2.new(0, 14, 0, 50)
    cmdBadge.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
    corner(cmdBadge, 8)
    
    local cmdText = Instance.new("TextLabel", cmdBadge)
    cmdText.Size = UDim2.new(1, 0, 1, 0)
    cmdText.BackgroundTransparency = 1
    cmdText.Text = "/" .. cmd.cmd
    cmdText.TextColor3 = cmd.color
    cmdText.Font = Enum.Font.Code
    cmdText.TextSize = 9
    
    local execBtn = Instance.new("TextButton", card)
    execBtn.Size = UDim2.new(0, 65, 0, 26)
    execBtn.Position = UDim2.new(1, -75, 0.5, -13)
    execBtn.BackgroundColor3 = cmd.color
    execBtn.Text = "Execute"
    execBtn.TextColor3 = T.OnAccent
    execBtn.Font = Enum.Font.GothamBold
    execBtn.TextSize = 10
    execBtn.AutoButtonColor = false
    corner(execBtn, 7)
    pressFX(execBtn)
    execBtn.MouseButton1Click:Connect(function()
        if cmd.action then
            cmd.action()
            showDynamicNotification(cmd.name .. " executed!", T.Green)
        end
    end)
    
    return card
end

-- SETTINGS (FIXED - NO ERRORS)
local function openSettingsApp()
    -- ==================== DEVELOPER PROFILE CARD ====================
    local devFrame = Instance.new("Frame", appContent)
    devFrame.Size = UDim2.new(1, 0, 0, 230)
    devFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    devFrame.LayoutOrder = 0
    corner(devFrame, 18)
    
    -- Premium gradient background
    local devGradient = Instance.new("UIGradient", devFrame)
    devGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 42)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(22, 22, 35)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 26))
    })
    devGradient.Rotation = 135
    
    -- Decorative accent line
    local devAccent = Instance.new("Frame", devFrame)
    devAccent.Size = UDim2.new(1, 0, 0, 3)
    devAccent.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    devAccent.ZIndex = 10
    corner(devAccent, 2)
    
    -- Badge "DEVELOPER"
    local badgeFrame = Instance.new("Frame", devFrame)
    badgeFrame.Size = UDim2.new(0, 90, 0, 22)
    badgeFrame.Position = UDim2.new(0, 16, 0, 14)
    badgeFrame.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    badgeFrame.BackgroundTransparency = 0.85
    badgeFrame.ZIndex = 5
    corner(badgeFrame, 11)
    stroke(badgeFrame, Color3.fromRGB(80, 140, 255), 1, 0.5)
    
    local badgeText = Instance.new("TextLabel", badgeFrame)
    badgeText.Size = UDim2.new(1, -8, 1, 0)
    badgeText.Position = UDim2.new(0, 4, 0, 0)
    badgeText.BackgroundTransparency = 1
    badgeText.Text = "DEVELOPER"
    badgeText.TextColor3 = Color3.fromRGB(150, 190, 255)
    badgeText.Font = Enum.Font.GothamBold
    badgeText.TextSize = 9
    badgeText.TextXAlignment = Enum.TextXAlignment.Center
    badgeText.ZIndex = 6
    
    -- Avatar with premium ring
    local avatarRing = Instance.new("Frame", devFrame)
    avatarRing.Size = UDim2.new(0, 84, 0, 84)
    avatarRing.Position = UDim2.new(0, 20, 0, 50)
    avatarRing.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    avatarRing.BackgroundTransparency = 0.7
    avatarRing.ZIndex = 5
    corner(avatarRing, 100)
    
    local av = Instance.new("ImageLabel", avatarRing)
    av.Size = UDim2.new(0, 70, 0, 70)
    av.Position = UDim2.new(0.5, -35, 0.5, -35)
    av.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    av.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    av.ZIndex = 6
    corner(av, 100)
    stroke(av, Color3.fromRGB(255, 255, 255), 2, 0.9)
    
    -- Online status indicator
    local onlineDot = Instance.new("Frame", avatarRing)
    onlineDot.Size = UDim2.new(0, 16, 0, 16)
    onlineDot.Position = UDim2.new(1, -12, 1, -12)
    onlineDot.BackgroundColor3 = Color3.fromRGB(0, 220, 80)
    onlineDot.ZIndex = 10
    corner(onlineDot, 100)
    stroke(onlineDot, Color3.fromRGB(255, 255, 255), 2.5, 0)
    
    -- Name & Info
    local nameLbl = Instance.new("TextLabel", devFrame)
    nameLbl.Size = UDim2.new(1, -120, 0, 28)
    nameLbl.Position = UDim2.new(0, 114, 0, 52)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = "alfread"
    nameLbl.TextColor3 = Color3.new(1, 1, 1)
    nameLbl.Font = Enum.Font.GothamBlack
    nameLbl.TextSize = 20
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex = 5
    
    -- Verified badge
    local verifiedFrame = Instance.new("Frame", devFrame)
    verifiedFrame.Size = UDim2.new(0, 16, 0, 16)
    verifiedFrame.Position = UDim2.new(0, 112, 0, 78)
    verifiedFrame.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
    verifiedFrame.ZIndex = 5
    corner(verifiedFrame, 100)
    
    local checkMark = Instance.new("TextLabel", verifiedFrame)
    checkMark.Size = UDim2.new(1, 0, 1, 0)
    checkMark.BackgroundTransparency = 1
    checkMark.Text = "V"
    checkMark.TextColor3 = Color3.new(1, 1, 1)
    checkMark.Font = Enum.Font.GothamBlack
    checkMark.TextSize = 10
    
    local verifiedText = Instance.new("TextLabel", devFrame)
    verifiedText.Size = UDim2.new(0, 100, 0, 18)
    verifiedText.Position = UDim2.new(0, 132, 0, 78)
    verifiedText.BackgroundTransparency = 1
    verifiedText.Text = "Verified Creator"
    verifiedText.TextColor3 = Color3.fromRGB(140, 185, 255)
    verifiedText.Font = Enum.Font.Gotham
    verifiedText.TextSize = 9
    verifiedText.TextXAlignment = Enum.TextXAlignment.Left
    verifiedText.ZIndex = 5
    
    local descLbl = Instance.new("TextLabel", devFrame)
    descLbl.Size = UDim2.new(1, -120, 0, 40)
    descLbl.Position = UDim2.new(0, 114, 0, 102)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = "Creator of Phone ID Viewer\nAdvanced Roblox Scripting"
    descLbl.TextColor3 = Color3.fromRGB(170, 170, 195)
    descLbl.Font = Enum.Font.Gotham
    descLbl.TextSize = 10
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.TextWrapped = true
    descLbl.ZIndex = 5
    
    -- Stats row
    local statsFrame = Instance.new("Frame", devFrame)
    statsFrame.Size = UDim2.new(1, -20, 0, 40)
    statsFrame.Position = UDim2.new(0, 10, 0, 180)
    statsFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    statsFrame.BackgroundTransparency = 0.94
    statsFrame.ZIndex = 5
    corner(statsFrame, 10)
    
    local stats = {
        {value = "v10.2", label = "Version"},
        {value = "2024", label = "Released"},
        {value = "FE", label = "Secure"}
    }
    
    for i, stat in ipairs(stats) do
        local statFrame = Instance.new("Frame", statsFrame)
        statFrame.Size = UDim2.new(1/3, -8, 1, 0)
        statFrame.Position = UDim2.new((i-1)/3, 4, 0, 0)
        statFrame.BackgroundTransparency = 1
        
        local statValue = Instance.new("TextLabel", statFrame)
        statValue.Size = UDim2.new(1, 0, 0, 20)
        statValue.Position = UDim2.new(0, 0, 0, 2)
        statValue.BackgroundTransparency = 1
        statValue.Text = stat.value
        statValue.TextColor3 = Color3.new(1, 1, 1)
        statValue.Font = Enum.Font.GothamBold
        statValue.TextSize = 11
        statValue.TextXAlignment = Enum.TextXAlignment.Center
        
        local statLabel = Instance.new("TextLabel", statFrame)
        statLabel.Size = UDim2.new(1, 0, 0, 14)
        statLabel.Position = UDim2.new(0, 0, 0, 22)
        statLabel.BackgroundTransparency = 1
        statLabel.Text = stat.label
        statLabel.TextColor3 = Color3.fromRGB(140, 140, 165)
        statLabel.Font = Enum.Font.Gotham
        statLabel.TextSize = 8
        statLabel.TextXAlignment = Enum.TextXAlignment.Center
    end
    
    -- Action buttons
    local copyLinkBtn = Instance.new("TextButton", devFrame)
    copyLinkBtn.Size = UDim2.new(0, 90, 0, 28)
    copyLinkBtn.Position = UDim2.new(1, -100, 0, 196)
    copyLinkBtn.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    copyLinkBtn.Text = "Profile"
    copyLinkBtn.TextColor3 = Color3.new(1, 1, 1)
    copyLinkBtn.Font = Enum.Font.GothamBold
    copyLinkBtn.TextSize = 10
    copyLinkBtn.AutoButtonColor = false
    copyLinkBtn.ZIndex = 5
    corner(copyLinkBtn, 8)
    pressFX(copyLinkBtn)
    copyLinkBtn.MouseButton1Click:Connect(function()
        copyToClipboard("https://www.roblox.com/users/1/profile")
        showDynamicNotification("Profile link copied!", T.Green)
    end)
    
    -- Fetch real developer info
    task.spawn(function()
        local userId
        pcall(function()
            local searchRes = HttpService:JSONDecode(HttpService:GetAsync("https://users.roblox.com/v1/users/search?keyword=alfread&limit=1"))
            if searchRes and searchRes.data and #searchRes.data > 0 then
                userId = searchRes.data[1].id
                local userInfo = HttpService:JSONDecode(HttpService:GetAsync("https://users.roblox.com/v1/users/" .. userId))
                nameLbl.Text = userInfo.displayName or userInfo.name or "alfread"
                descLbl.Text = (userInfo.description or "Creator of Phone ID Viewer\nAdvanced Roblox Scripting")
                av.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=150&height=150&format=png"
                copyLinkBtn.MouseButton1Click:Connect(function()
                    copyToClipboard("https://www.roblox.com/users/" .. userId .. "/profile")
                    showDynamicNotification("Profile link copied!", T.Green)
                end)
            end
        end)
    end)
    
    -- ==================== SECTION: SECURITY ====================
    -- Section Header
    local securityHeader = Instance.new("Frame", appContent)
    securityHeader.Size = UDim2.new(1, 0, 0, 42)
    securityHeader.BackgroundTransparency = 1
    securityHeader.LayoutOrder = 1
    
    local securityAccent = Instance.new("Frame", securityHeader)
    securityAccent.Size = UDim2.new(0, 4, 0, 28)
    securityAccent.Position = UDim2.new(0, 0, 0.5, -14)
    securityAccent.BackgroundColor3 = T.Accent
    corner(securityAccent, 2)
    
    local securityTitle = Instance.new("TextLabel", securityHeader)
    securityTitle.Size = UDim2.new(1, -16, 0, 20)
    securityTitle.Position = UDim2.new(0, 10, 0, 2)
    securityTitle.BackgroundTransparency = 1
    securityTitle.Text = "Security"
    securityTitle.TextColor3 = T.Text
    securityTitle.Font = Enum.Font.GothamBlack
    securityTitle.TextSize = 14
    securityTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local securityDesc = Instance.new("TextLabel", securityHeader)
    securityDesc.Size = UDim2.new(1, -16, 0, 16)
    securityDesc.Position = UDim2.new(0, 10, 0, 22)
    securityDesc.BackgroundTransparency = 1
    securityDesc.Text = "Lock your phone and change passcode"
    securityDesc.TextColor3 = T.Text2
    securityDesc.Font = Enum.Font.Gotham
    securityDesc.TextSize = 9
    securityDesc.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Auto Lock Card
    local autoLockFrame = Instance.new("Frame", appContent)
    autoLockFrame.Size = UDim2.new(1, 0, 0, 104)
    autoLockFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    autoLockFrame.LayoutOrder = 2
    corner(autoLockFrame, 14)
    stroke(autoLockFrame, Color3.fromRGB(225, 225, 230), 1, 0.3)
    
    -- Card shadow
    local autoLockShadow = Instance.new("Frame", autoLockFrame)
    autoLockShadow.Size = UDim2.new(1, 6, 1, 6)
    autoLockShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    autoLockShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    autoLockShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    autoLockShadow.BackgroundTransparency = 0.94
    autoLockShadow.ZIndex = -1
    corner(autoLockShadow, 16)
    
    local autoLockTitle = Instance.new("TextLabel", autoLockFrame)
    autoLockTitle.Size = UDim2.new(1, -24, 0, 22)
    autoLockTitle.Position = UDim2.new(0, 12, 0, 10)
    autoLockTitle.BackgroundTransparency = 1
    autoLockTitle.Text = "Auto Lock Timer"
    autoLockTitle.TextColor3 = T.Text
    autoLockTitle.Font = Enum.Font.GothamBold
    autoLockTitle.TextSize = 13
    autoLockTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local autoLockDesc = Instance.new("TextLabel", autoLockFrame)
    autoLockDesc.Size = UDim2.new(1, -24, 0, 16)
    autoLockDesc.Position = UDim2.new(0, 12, 0, 32)
    autoLockDesc.BackgroundTransparency = 1
    autoLockDesc.Text = "Phone will auto-lock after inactivity (0 = disabled)"
    autoLockDesc.TextColor3 = T.Text2
    autoLockDesc.Font = Enum.Font.Gotham
    autoLockDesc.TextSize = 9
    autoLockDesc.TextXAlignment = Enum.TextXAlignment.Left
    
    local inputRow = Instance.new("Frame", autoLockFrame)
    inputRow.Size = UDim2.new(1, -24, 0, 34)
    inputRow.Position = UDim2.new(0, 12, 0, 56)
    inputRow.BackgroundTransparency = 1
    
    local autoLockInput = Instance.new("TextBox", inputRow)
    autoLockInput.Size = UDim2.new(0, 70, 1, 0)
    autoLockInput.Text = tostring(appSettings.autoLockSeconds)
    autoLockInput.PlaceholderText = "0"
    autoLockInput.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
    autoLockInput.TextColor3 = T.Text
    autoLockInput.Font = Enum.Font.GothamBold
    autoLockInput.TextSize = 16
    autoLockInput.TextXAlignment = Enum.TextXAlignment.Center
    corner(autoLockInput, 8)
    stroke(autoLockInput, Color3.fromRGB(210, 210, 215), 1, 0.3)
    
    local secLabel = Instance.new("TextLabel", inputRow)
    secLabel.Size = UDim2.new(0, 50, 1, 0)
    secLabel.Position = UDim2.new(0, 78, 0, 0)
    secLabel.BackgroundTransparency = 1
    secLabel.Text = "seconds"
    secLabel.TextColor3 = T.Text2
    secLabel.Font = Enum.Font.Gotham
    secLabel.TextSize = 11
    secLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local autoLockSave = Instance.new("TextButton", inputRow)
    autoLockSave.Size = UDim2.new(0, 60, 1, 0)
    autoLockSave.Position = UDim2.new(1, -60, 0, 0)
    autoLockSave.BackgroundColor3 = T.Accent
    autoLockSave.Text = "Save"
    autoLockSave.TextColor3 = T.OnAccent
    autoLockSave.Font = Enum.Font.GothamBold
    autoLockSave.TextSize = 11
    autoLockSave.AutoButtonColor = false
    corner(autoLockSave, 8)
    pressFX(autoLockSave)
    autoLockSave.MouseButton1Click:Connect(function()
        local val = tonumber(autoLockInput.Text) or 0
        appSettings.autoLockSeconds = math.max(0, val)
        persistSettings()
        showDynamicNotification("Auto Lock: " .. appSettings.autoLockSeconds .. "s", T.Green)
    end)
    
    -- Passcode Card
    local passFrame = Instance.new("Frame", appContent)
    passFrame.Size = UDim2.new(1, 0, 0, 210)
    passFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    passFrame.LayoutOrder = 3
    corner(passFrame, 14)
    stroke(passFrame, Color3.fromRGB(225, 225, 230), 1, 0.3)
    
    local passShadow = Instance.new("Frame", passFrame)
    passShadow.Size = UDim2.new(1, 6, 1, 6)
    passShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    passShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    passShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    passShadow.BackgroundTransparency = 0.94
    passShadow.ZIndex = -1
    corner(passShadow, 16)
    
    local passTitle = Instance.new("TextLabel", passFrame)
    passTitle.Size = UDim2.new(1, -24, 0, 22)
    passTitle.Position = UDim2.new(0, 12, 0, 10)
    passTitle.BackgroundTransparency = 1
    passTitle.Text = "Change Passcode"
    passTitle.TextColor3 = T.Text
    passTitle.Font = Enum.Font.GothamBold
    passTitle.TextSize = 13
    passTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local oldInput = Instance.new("TextBox", passFrame)
    oldInput.Size = UDim2.new(1, -24, 0, 32)
    oldInput.Position = UDim2.new(0, 12, 0, 44)
    oldInput.PlaceholderText = "Current passcode"
    oldInput.Text = ""
    oldInput.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
    oldInput.TextColor3 = T.Text
    oldInput.Font = Enum.Font.Gotham
    oldInput.TextSize = 12
    oldInput.PlaceholderColor3 = Color3.fromRGB(180, 180, 185)
    corner(oldInput, 8)
    stroke(oldInput, Color3.fromRGB(220, 220, 225), 1, 0.3)
    
    local newInput = Instance.new("TextBox", passFrame)
    newInput.Size = UDim2.new(1, -24, 0, 32)
    newInput.Position = UDim2.new(0, 12, 0, 84)
    newInput.PlaceholderText = "New passcode (4 digits)"
    newInput.Text = ""
    newInput.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
    newInput.TextColor3 = T.Text
    newInput.Font = Enum.Font.Gotham
    newInput.TextSize = 12
    newInput.PlaceholderColor3 = Color3.fromRGB(180, 180, 185)
    corner(newInput, 8)
    stroke(newInput, Color3.fromRGB(220, 220, 225), 1, 0.3)
    
    local confirmInput = Instance.new("TextBox", passFrame)
    confirmInput.Size = UDim2.new(1, -24, 0, 32)
    confirmInput.Position = UDim2.new(0, 12, 0, 124)
    confirmInput.PlaceholderText = "Confirm new passcode"
    confirmInput.Text = ""
    confirmInput.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
    confirmInput.TextColor3 = T.Text
    confirmInput.Font = Enum.Font.Gotham
    confirmInput.TextSize = 12
    confirmInput.PlaceholderColor3 = Color3.fromRGB(180, 180, 185)
    corner(confirmInput, 8)
    stroke(confirmInput, Color3.fromRGB(220, 220, 225), 1, 0.3)
    
    local changeBtn = Instance.new("TextButton", passFrame)
    changeBtn.Size = UDim2.new(1, -24, 0, 36)
    changeBtn.Position = UDim2.new(0, 12, 0, 164)
    changeBtn.BackgroundColor3 = T.Accent
    changeBtn.Text = "Update Passcode"
    changeBtn.TextColor3 = T.OnAccent
    changeBtn.Font = Enum.Font.GothamBold
    changeBtn.TextSize = 12
    changeBtn.AutoButtonColor = false
    corner(changeBtn, 10)
    pressFX(changeBtn)
    changeBtn.MouseButton1Click:Connect(function()
        local old = oldInput.Text
        local newPin = newInput.Text
        local conf = confirmInput.Text
        if old ~= appSettings.passcode then
            showDynamicNotification("Current PIN is incorrect", T.Red)
            return
        end
        if #newPin ~= 4 or not tonumber(newPin) then
            showDynamicNotification("PIN must be 4 digits", T.Red)
            return
        end
        if newPin ~= conf then
            showDynamicNotification("PINs do not match", T.Red)
            return
        end
        appSettings.passcode = newPin
        persistSettings()
        showDynamicNotification("Passcode updated!", T.Green)
        oldInput.Text = ""
        newInput.Text = ""
        confirmInput.Text = ""
    end)
    
    -- ==================== SECTION: APPEARANCE ====================
    local appearanceHeader = Instance.new("Frame", appContent)
    appearanceHeader.Size = UDim2.new(1, 0, 0, 42)
    appearanceHeader.BackgroundTransparency = 1
    appearanceHeader.LayoutOrder = 4
    
    local appearanceAccent = Instance.new("Frame", appearanceHeader)
    appearanceAccent.Size = UDim2.new(0, 4, 0, 28)
    appearanceAccent.Position = UDim2.new(0, 0, 0.5, -14)
    appearanceAccent.BackgroundColor3 = T.Accent
    corner(appearanceAccent, 2)
    
    local appearanceTitle = Instance.new("TextLabel", appearanceHeader)
    appearanceTitle.Size = UDim2.new(1, -16, 0, 20)
    appearanceTitle.Position = UDim2.new(0, 10, 0, 2)
    appearanceTitle.BackgroundTransparency = 1
    appearanceTitle.Text = "Appearance"
    appearanceTitle.TextColor3 = T.Text
    appearanceTitle.Font = Enum.Font.GothamBlack
    appearanceTitle.TextSize = 14
    appearanceTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local appearanceDesc = Instance.new("TextLabel", appearanceHeader)
    appearanceDesc.Size = UDim2.new(1, -16, 0, 16)
    appearanceDesc.Position = UDim2.new(0, 10, 0, 22)
    appearanceDesc.BackgroundTransparency = 1
    appearanceDesc.Text = "Customize how your phone looks"
    appearanceDesc.TextColor3 = T.Text2
    appearanceDesc.Font = Enum.Font.Gotham
    appearanceDesc.TextSize = 9
    appearanceDesc.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Background Theme Card
    local themeFrame = Instance.new("Frame", appContent)
    themeFrame.Size = UDim2.new(1, 0, 0, 130)
    themeFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    themeFrame.LayoutOrder = 5
    corner(themeFrame, 14)
    stroke(themeFrame, Color3.fromRGB(225, 225, 230), 1, 0.3)
    
    local themeShadow = Instance.new("Frame", themeFrame)
    themeShadow.Size = UDim2.new(1, 6, 1, 6)
    themeShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    themeShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    themeShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    themeShadow.BackgroundTransparency = 0.94
    themeShadow.ZIndex = -1
    corner(themeShadow, 16)
    
    local themeTitle = Instance.new("TextLabel", themeFrame)
    themeTitle.Size = UDim2.new(1, -24, 0, 22)
    themeTitle.Position = UDim2.new(0, 12, 0, 10)
    themeTitle.BackgroundTransparency = 1
    themeTitle.Text = "Background Theme"
    themeTitle.TextColor3 = T.Text
    themeTitle.Font = Enum.Font.GothamBold
    themeTitle.TextSize = 13
    themeTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local colors = {
        {color = Color3.fromRGB(255, 255, 255), name = "Light"},
        {color = Color3.fromRGB(40, 40, 40), name = "Dark"},
        {color = Color3.fromRGB(200, 220, 255), name = "Blue"},
        {color = Color3.fromRGB(255, 230, 200), name = "Warm"}
    }
    
    for i, themeData in ipairs(colors) do
        local btn = Instance.new("TextButton", themeFrame)
        btn.Size = UDim2.new(0, 66, 0, 52)
        btn.Position = UDim2.new(0, 12 + (i-1) * 72, 0, 64)
        btn.BackgroundColor3 = themeData.color
        btn.Text = themeData.name
        btn.TextColor3 = (themeData.name == "Dark") and Color3.new(1, 1, 1) or T.Text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 9
        btn.AutoButtonColor = false
        corner(btn, 10)
        stroke(btn, T.Border, 1, 0.3)
        pressFX(btn)
        
        btn.MouseButton1Click:Connect(function()
            appSettings.bgColor = themeData.color
            appSettings.bgGradient = (themeData.name == "Light")
            persistSettings()
            homeWall.BackgroundColor3 = themeData.color
            if appSettings.bgGradient then
                if homeWall:FindFirstChildOfClass("UIGradient") then
                    homeWall:FindFirstChildOfClass("UIGradient"):Destroy()
                end
                gradient(homeWall, ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 220, 240)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(250, 250, 255))
                }), 135)
            else
                if homeWall:FindFirstChildOfClass("UIGradient") then
                    homeWall:FindFirstChildOfClass("UIGradient"):Destroy()
                end
            end
            phone.BackgroundColor3 = themeData.color
            showDynamicNotification("Theme: " .. themeData.name, T.Green)
        end)
    end
    
    -- Glow Effect Card
    local glowFrame = Instance.new("Frame", appContent)
    glowFrame.Size = UDim2.new(1, 0, 0, 52)
    glowFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    glowFrame.LayoutOrder = 6
    corner(glowFrame, 14)
    stroke(glowFrame, Color3.fromRGB(225, 225, 230), 1, 0.3)
    
    local glowShadow = Instance.new("Frame", glowFrame)
    glowShadow.Size = UDim2.new(1, 6, 1, 6)
    glowShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glowShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    glowShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    glowShadow.BackgroundTransparency = 0.94
    glowShadow.ZIndex = -1
    corner(glowShadow, 16)
    
    local glowTitle = Instance.new("TextLabel", glowFrame)
    glowTitle.Size = UDim2.new(0, 170, 1, 0)
    glowTitle.Position = UDim2.new(0, 12, 0, 0)
    glowTitle.BackgroundTransparency = 1
    glowTitle.Text = "Phone Glow Effect"
    glowTitle.TextColor3 = T.Text
    glowTitle.Font = Enum.Font.GothamBold
    glowTitle.TextSize = 12
    glowTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    buildToggle(glowFrame, appSettings.glowEnabled, function(val)
        appSettings.glowEnabled = val
        persistSettings()
        phoneStroke.Transparency = val and 0.5 or 0.15
    end).Position = UDim2.new(1, -56, 0.5, -13)
    
    -- Phone Opacity Card
    local opacityFrame = Instance.new("Frame", appContent)
    opacityFrame.Size = UDim2.new(1, 0, 0, 100)
    opacityFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    opacityFrame.LayoutOrder = 7
    corner(opacityFrame, 14)
    stroke(opacityFrame, Color3.fromRGB(225, 225, 230), 1, 0.3)
    
    local opacityShadow = Instance.new("Frame", opacityFrame)
    opacityShadow.Size = UDim2.new(1, 6, 1, 6)
    opacityShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    opacityShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    opacityShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    opacityShadow.BackgroundTransparency = 0.94
    opacityShadow.ZIndex = -1
    corner(opacityShadow, 16)
    
    local opTitle = Instance.new("TextLabel", opacityFrame)
    opTitle.Size = UDim2.new(1, -24, 0, 22)
    opTitle.Position = UDim2.new(0, 12, 0, 10)
    opTitle.BackgroundTransparency = 1
    opTitle.Text = "Phone Opacity"
    opTitle.TextColor3 = T.Text
    opTitle.Font = Enum.Font.GothamBold
    opTitle.TextSize = 13
    opTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local opVal = Instance.new("TextLabel", opacityFrame)
    opVal.Size = UDim2.new(1, -24, 0, 16)
    opVal.Position = UDim2.new(0, 12, 0, 32)
    opVal.BackgroundTransparency = 1
    opVal.Text = "Opacity: " .. math.floor((appSettings.phoneOpacity or 1) * 100) .. "%"
    opVal.TextColor3 = T.Text2
    opVal.Font = Enum.Font.Gotham
    opVal.TextSize = 10
    opVal.TextXAlignment = Enum.TextXAlignment.Left
    
    local opSlider = Instance.new("TextButton", opacityFrame)
    opSlider.Size = UDim2.new(1, -24, 0, 28)
    opSlider.Position = UDim2.new(0, 12, 0, 56)
    opSlider.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
    opSlider.Text = ""
    corner(opSlider, 14)
    
    local opFill = Instance.new("Frame", opSlider)
    opFill.Size = UDim2.new(appSettings.phoneOpacity or 1, 0, 1, 0)
    opFill.BackgroundColor3 = T.Accent
    corner(opFill, 14)
    
    local function setOpacity(val)
        val = math.clamp(val, 0.3, 1)
        appSettings.phoneOpacity = val
        persistSettings()
        opFill.Size = UDim2.new(val, 0, 1, 0)
        opVal.Text = "Opacity: " .. math.floor(val * 100) .. "%"
        phone.BackgroundTransparency = 1 - val
    end
    
    opSlider.MouseButton1Down:Connect(function()
        local con
        con = RunService.RenderStepped:Connect(function()
            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                con:Disconnect()
                return
            end
            local mousePos = UserInputService:GetMouseLocation()
            local absX = opSlider.AbsolutePosition.X
            local absSizeX = opSlider.AbsoluteSize.X
            if absSizeX <= 0 then absSizeX = 1 end
            local relX = (mousePos.X - absX) / absSizeX
            setOpacity(0.3 + relX * 0.7)
        end)
    end)
    
    -- ==================== SECTION: SOUND ====================
    local soundHeader = Instance.new("Frame", appContent)
    soundHeader.Size = UDim2.new(1, 0, 0, 42)
    soundHeader.BackgroundTransparency = 1
    soundHeader.LayoutOrder = 8
    
    local soundAccent = Instance.new("Frame", soundHeader)
    soundAccent.Size = UDim2.new(0, 4, 0, 28)
    soundAccent.Position = UDim2.new(0, 0, 0.5, -14)
    soundAccent.BackgroundColor3 = T.Accent
    corner(soundAccent, 2)
    
    local soundTitle = Instance.new("TextLabel", soundHeader)
    soundTitle.Size = UDim2.new(1, -16, 0, 20)
    soundTitle.Position = UDim2.new(0, 10, 0, 2)
    soundTitle.BackgroundTransparency = 1
    soundTitle.Text = "Sound"
    soundTitle.TextColor3 = T.Text
    soundTitle.Font = Enum.Font.GothamBlack
    soundTitle.TextSize = 14
    soundTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local soundDesc = Instance.new("TextLabel", soundHeader)
    soundDesc.Size = UDim2.new(1, -16, 0, 16)
    soundDesc.Position = UDim2.new(0, 10, 0, 22)
    soundDesc.BackgroundTransparency = 1
    soundDesc.Text = "Configure audio settings"
    soundDesc.TextColor3 = T.Text2
    soundDesc.Font = Enum.Font.Gotham
    soundDesc.TextSize = 9
    soundDesc.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Background Music Card
    local musicFrame = Instance.new("Frame", appContent)
    musicFrame.Size = UDim2.new(1, 0, 0, 90)
    musicFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    musicFrame.LayoutOrder = 9
    corner(musicFrame, 14)
    stroke(musicFrame, Color3.fromRGB(225, 225, 230), 1, 0.3)
    
    local musicShadow = Instance.new("Frame", musicFrame)
    musicShadow.Size = UDim2.new(1, 6, 1, 6)
    musicShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    musicShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    musicShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    musicShadow.BackgroundTransparency = 0.94
    musicShadow.ZIndex = -1
    corner(musicShadow, 16)
    
    local musicTitle = Instance.new("TextLabel", musicFrame)
    musicTitle.Size = UDim2.new(1, -24, 0, 22)
    musicTitle.Position = UDim2.new(0, 12, 0, 10)
    musicTitle.BackgroundTransparency = 1
    musicTitle.Text = "Background Music URL"
    musicTitle.TextColor3 = T.Text
    musicTitle.Font = Enum.Font.GothamBold
    musicTitle.TextSize = 13
    musicTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local musicInput = Instance.new("TextBox", musicFrame)
    musicInput.Size = UDim2.new(1, -24, 0, 32)
    musicInput.Position = UDim2.new(0, 12, 0, 40)
    musicInput.Text = appSettings.backgroundMusicUrl or ""
    musicInput.PlaceholderText = "rbxassetid://..."
    musicInput.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
    musicInput.TextColor3 = T.Text
    musicInput.Font = Enum.Font.Code
    musicInput.TextSize = 11
    musicInput.PlaceholderColor3 = Color3.fromRGB(180, 180, 185)
    corner(musicInput, 8)
    stroke(musicInput, Color3.fromRGB(220, 220, 225), 1, 0.3)
    
    local musicSave = Instance.new("TextButton", musicFrame)
    musicSave.Size = UDim2.new(0, 70, 0, 26)
    musicSave.Position = UDim2.new(1, -82, 0, 52)
    musicSave.BackgroundColor3 = T.Accent
    musicSave.Text = "Apply"
    musicSave.TextColor3 = T.OnAccent
    musicSave.Font = Enum.Font.GothamBold
    musicSave.TextSize = 10
    musicSave.AutoButtonColor = false
    corner(musicSave, 8)
    pressFX(musicSave)
    musicSave.MouseButton1Click:Connect(function()
        appSettings.backgroundMusicUrl = musicInput.Text
        persistSettings()
        updateBackgroundMusic()
        showDynamicNotification("Music updated!", T.Green)
    end)
    
    -- Button Sound Card
    local btnSoundFrame = Instance.new("Frame", appContent)
    btnSoundFrame.Size = UDim2.new(1, 0, 0, 90)
    btnSoundFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btnSoundFrame.LayoutOrder = 10
    corner(btnSoundFrame, 14)
    stroke(btnSoundFrame, Color3.fromRGB(225, 225, 230), 1, 0.3)
    
    local btnSoundShadow = Instance.new("Frame", btnSoundFrame)
    btnSoundShadow.Size = UDim2.new(1, 6, 1, 6)
    btnSoundShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    btnSoundShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    btnSoundShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btnSoundShadow.BackgroundTransparency = 0.94
    btnSoundShadow.ZIndex = -1
    corner(btnSoundShadow, 16)
    
    local btnSoundTitle = Instance.new("TextLabel", btnSoundFrame)
    btnSoundTitle.Size = UDim2.new(1, -24, 0, 22)
    btnSoundTitle.Position = UDim2.new(0, 12, 0, 10)
    btnSoundTitle.BackgroundTransparency = 1
    btnSoundTitle.Text = "Button Sound URL"
    btnSoundTitle.TextColor3 = T.Text
    btnSoundTitle.Font = Enum.Font.GothamBold
    btnSoundTitle.TextSize = 13
    btnSoundTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local btnSoundInput = Instance.new("TextBox", btnSoundFrame)
    btnSoundInput.Size = UDim2.new(1, -24, 0, 32)
    btnSoundInput.Position = UDim2.new(0, 12, 0, 40)
    btnSoundInput.Text = appSettings.buttonSoundUrl or ""
    btnSoundInput.PlaceholderText = "rbxassetid://..."
    btnSoundInput.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
    btnSoundInput.TextColor3 = T.Text
    btnSoundInput.Font = Enum.Font.Code
    btnSoundInput.TextSize = 11
    btnSoundInput.PlaceholderColor3 = Color3.fromRGB(180, 180, 185)
    corner(btnSoundInput, 8)
    stroke(btnSoundInput, Color3.fromRGB(220, 220, 225), 1, 0.3)
    
    local btnSoundSave = Instance.new("TextButton", btnSoundFrame)
    btnSoundSave.Size = UDim2.new(0, 70, 0, 26)
    btnSoundSave.Position = UDim2.new(1, -82, 0, 52)
    btnSoundSave.BackgroundColor3 = T.Accent
    btnSoundSave.Text = "Apply"
    btnSoundSave.TextColor3 = T.OnAccent
    btnSoundSave.Font = Enum.Font.GothamBold
    btnSoundSave.TextSize = 10
    btnSoundSave.AutoButtonColor = false
    corner(btnSoundSave, 8)
    pressFX(btnSoundSave)
    btnSoundSave.MouseButton1Click:Connect(function()
        appSettings.buttonSoundUrl = btnSoundInput.Text
        persistSettings()
        showDynamicNotification("Button sound updated!", T.Green)
    end)
    
    -- ==================== SECTION: PREFERENCES ====================
    local prefHeader = Instance.new("Frame", appContent)
    prefHeader.Size = UDim2.new(1, 0, 0, 42)
    prefHeader.BackgroundTransparency = 1
    prefHeader.LayoutOrder = 11
    
    local prefAccent = Instance.new("Frame", prefHeader)
    prefAccent.Size = UDim2.new(0, 4, 0, 28)
    prefAccent.Position = UDim2.new(0, 0, 0.5, -14)
    prefAccent.BackgroundColor3 = T.Accent
    corner(prefAccent, 2)
    
    local prefTitle = Instance.new("TextLabel", prefHeader)
    prefTitle.Size = UDim2.new(1, -16, 0, 20)
    prefTitle.Position = UDim2.new(0, 10, 0, 2)
    prefTitle.BackgroundTransparency = 1
    prefTitle.Text = "Preferences"
    prefTitle.TextColor3 = T.Text
    prefTitle.Font = Enum.Font.GothamBlack
    prefTitle.TextSize = 14
    prefTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local prefDesc = Instance.new("TextLabel", prefHeader)
    prefDesc.Size = UDim2.new(1, -16, 0, 16)
    prefDesc.Position = UDim2.new(0, 10, 0, 22)
    prefDesc.BackgroundTransparency = 1
    prefDesc.Text = "General app settings"
    prefDesc.TextColor3 = T.Text2
    prefDesc.Font = Enum.Font.Gotham
    prefDesc.TextSize = 9
    prefDesc.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Toast Notifications Card
    local toastFrame = Instance.new("Frame", appContent)
    toastFrame.Size = UDim2.new(1, 0, 0, 52)
    toastFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toastFrame.LayoutOrder = 12
    corner(toastFrame, 14)
    stroke(toastFrame, Color3.fromRGB(225, 225, 230), 1, 0.3)
    
    local toastTitle = Instance.new("TextLabel", toastFrame)
    toastTitle.Size = UDim2.new(0, 170, 1, 0)
    toastTitle.Position = UDim2.new(0, 12, 0, 0)
    toastTitle.BackgroundTransparency = 1
    toastTitle.Text = "Toast Notifications"
    toastTitle.TextColor3 = T.Text
    toastTitle.Font = Enum.Font.GothamBold
    toastTitle.TextSize = 12
    toastTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    buildToggle(toastFrame, appSettings.toastEnabled, function(val)
        appSettings.toastEnabled = val
        persistSettings()
    end).Position = UDim2.new(1, -56, 0.5, -13)
    
    -- Clock Format Card
    local clockFrame = Instance.new("Frame", appContent)
    clockFrame.Size = UDim2.new(1, 0, 0, 52)
    clockFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    clockFrame.LayoutOrder = 13
    corner(clockFrame, 14)
    stroke(clockFrame, Color3.fromRGB(225, 225, 230), 1, 0.3)
    
    local clockTitle = Instance.new("TextLabel", clockFrame)
    clockTitle.Size = UDim2.new(0, 170, 1, 0)
    clockTitle.Position = UDim2.new(0, 12, 0, 0)
    clockTitle.BackgroundTransparency = 1
    clockTitle.Text = "Clock (12H / 24H)"
    clockTitle.TextColor3 = T.Text
    clockTitle.Font = Enum.Font.GothamBold
    clockTitle.TextSize = 12
    clockTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    buildToggle(clockFrame, appSettings.clockFormat == "12", function(val)
        appSettings.clockFormat = val and "12" or "24"
        persistSettings()
    end).Position = UDim2.new(1, -56, 0.5, -13)
    
    -- Button Sounds Card
    local bsFrame = Instance.new("Frame", appContent)
    bsFrame.Size = UDim2.new(1, 0, 0, 52)
    bsFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    bsFrame.LayoutOrder = 14
    corner(bsFrame, 14)
    stroke(bsFrame, Color3.fromRGB(225, 225, 230), 1, 0.3)
    
    local bsTitle = Instance.new("TextLabel", bsFrame)
    bsTitle.Size = UDim2.new(0, 170, 1, 0)
    bsTitle.Position = UDim2.new(0, 12, 0, 0)
    bsTitle.BackgroundTransparency = 1
    bsTitle.Text = "Button Sounds"
    bsTitle.TextColor3 = T.Text
    bsTitle.Font = Enum.Font.GothamBold
    bsTitle.TextSize = 12
    bsTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    buildToggle(bsFrame, appSettings.buttonSounds, function(val)
        appSettings.buttonSounds = val
        persistSettings()
    end).Position = UDim2.new(1, -56, 0.5, -13)
    
    -- ==================== RESET BUTTON ====================
    local resetBtn = Instance.new("TextButton", appContent)
    resetBtn.Size = UDim2.new(1, 0, 0, 46)
    resetBtn.BackgroundColor3 = Color3.fromRGB(255, 238, 238)
    resetBtn.Text = "Reset All Settings"
    resetBtn.TextColor3 = T.Red
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.TextSize = 12
    resetBtn.AutoButtonColor = false
    resetBtn.LayoutOrder = 15
    corner(resetBtn, 12)
    stroke(resetBtn, Color3.fromRGB(255, 200, 200), 1, 0.3)
    pressFX(resetBtn)
    resetBtn.MouseButton1Click:Connect(function()
        for k, v in pairs(defaults) do
            appSettings[k] = v
        end
        persistSettings()
        updateBackgroundMusic()
        phoneStroke.Transparency = 0.5
        phone.BackgroundTransparency = 0
        homeWall.BackgroundColor3 = Color3.fromRGB(240, 240, 250)
        if not homeWall:FindFirstChildOfClass("UIGradient") then
            gradient(homeWall, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 220, 240)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(250, 250, 255))
            }), 135)
        end
        showDynamicNotification("Settings reset to default!", T.Gold)
        refreshCurr()
    end)
end

-- ================= BUNDLE APP (UPGRADED - IMAGES, PERMANENT RENAME) =================
local function openBundleApp()
    -- ==================== HEADER ====================
    local headerCard = Instance.new("Frame", appContent)
    headerCard.Size = UDim2.new(1, 0, 0, 50)
    headerCard.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    headerCard.LayoutOrder = 0
    corner(headerCard, 14)
    
    local headerGradient = Instance.new("UIGradient", headerCard)
    headerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 42)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    })
    headerGradient.Rotation = 135
    
    local headerAccent = Instance.new("Frame", headerCard)
    headerAccent.Size = UDim2.new(1, 0, 0, 2)
    headerAccent.BackgroundColor3 = Color3.fromRGB(255, 180, 50)
    corner(headerAccent, 1)
    
    local headerTitle = Instance.new("TextLabel", headerCard)
    headerTitle.Size = UDim2.new(1, -24, 0, 20)
    headerTitle.Position = UDim2.new(0, 12, 0, 6)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "Instant Bundle"
    headerTitle.TextColor3 = Color3.new(1, 1, 1)
    headerTitle.Font = Enum.Font.GothamBlack
    headerTitle.TextSize = 15
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local headerSub = Instance.new("TextLabel", headerCard)
    headerSub.Size = UDim2.new(1, -24, 0, 14)
    headerSub.Position = UDim2.new(0, 12, 0, 28)
    headerSub.BackgroundTransparency = 1
    headerSub.Text = "Execute & save your favorite bundles"
    headerSub.TextColor3 = Color3.fromRGB(160, 160, 180)
    headerSub.Font = Enum.Font.Gotham
    headerSub.TextSize = 9
    headerSub.TextXAlignment = Enum.TextXAlignment.Left
    
    -- ==================== EXECUTE SECTION ====================
    local executeCard = Instance.new("Frame", appContent)
    executeCard.Size = UDim2.new(1, 0, 0, 145)
    executeCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    executeCard.LayoutOrder = 1
    corner(executeCard, 14)
    stroke(executeCard, Color3.fromRGB(225, 225, 230), 1, 0.3)
    
    -- Shadow
    local execShadow = Instance.new("Frame", executeCard)
    execShadow.Size = UDim2.new(1, 6, 1, 6)
    execShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    execShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    execShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    execShadow.BackgroundTransparency = 0.94
    execShadow.ZIndex = -1
    corner(execShadow, 16)
    
    local execTitle = Instance.new("TextLabel", executeCard)
    execTitle.Size = UDim2.new(1, -24, 0, 20)
    execTitle.Position = UDim2.new(0, 12, 0, 10)
    execTitle.BackgroundTransparency = 1
    execTitle.Text = "Execute Bundle"
    execTitle.TextColor3 = T.Text
    execTitle.Font = Enum.Font.GothamBlack
    execTitle.TextSize = 13
    execTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local bundleInput = Instance.new("TextBox", executeCard)
    bundleInput.Size = UDim2.new(1, -24, 0, 34)
    bundleInput.Position = UDim2.new(0, 12, 0, 36)
    bundleInput.PlaceholderText = "Enter Bundle ID..."
    bundleInput.Text = getgenv().bundle or ""
    bundleInput.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
    bundleInput.TextColor3 = T.Text
    bundleInput.Font = Enum.Font.Code
    bundleInput.TextSize = 13
    bundleInput.ClearTextOnFocus = false
    corner(bundleInput, 8)
    stroke(bundleInput, Color3.fromRGB(220, 220, 225), 1, 0.3)
    
    -- Buttons row
    local btnRow = Instance.new("Frame", executeCard)
    btnRow.Size = UDim2.new(1, -24, 0, 36)
    btnRow.Position = UDim2.new(0, 12, 0, 78)
    btnRow.BackgroundTransparency = 1
    
    -- Execute button
    local executeBtn = Instance.new("TextButton", btnRow)
    executeBtn.Size = UDim2.new(0, 100, 1, 0)
    executeBtn.BackgroundColor3 = T.Accent
    executeBtn.Text = "Execute"
    executeBtn.TextColor3 = T.OnAccent
    executeBtn.Font = Enum.Font.GothamBlack
    executeBtn.TextSize = 12
    executeBtn.AutoButtonColor = false
    corner(executeBtn, 8)
    pressFX(executeBtn)
    executeBtn.MouseButton1Click:Connect(function()
        local bundleId = bundleInput.Text
        if bundleId == "" or not bundleId:match("%d+") then
            showDynamicNotification("Enter a valid Bundle ID!", T.Red)
            return
        end
        
        getgenv().bundle = bundleId
        executeBtn.Text = "Loading..."
        executeBtn.BackgroundColor3 = T.Gold
        
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Bac0nHck/Scripts/refs/heads/main/InstantBundle.lua"))()
        end)
        
        if success then
            executeBtn.Text = "Success!"
            executeBtn.BackgroundColor3 = T.Green
            showDynamicNotification("Bundle executed!", T.Green)
            task.wait(2)
            executeBtn.Text = "Execute"
            executeBtn.BackgroundColor3 = T.Accent
        else
            executeBtn.Text = "Error!"
            executeBtn.BackgroundColor3 = T.Red
            showDynamicNotification("Failed: " .. tostring(err):sub(1, 50), T.Red)
            task.wait(2)
            executeBtn.Text = "Execute"
            executeBtn.BackgroundColor3 = T.Accent
        end
    end)
    
    -- Save to Fav button
    local saveFavBtn = Instance.new("TextButton", btnRow)
    saveFavBtn.Size = UDim2.new(0, 100, 1, 0)
    saveFavBtn.Position = UDim2.new(0, 108, 0, 0)
    saveFavBtn.BackgroundColor3 = T.Gold
    saveFavBtn.Text = "Add to Fav"
    saveFavBtn.TextColor3 = T.OnAccent
    saveFavBtn.Font = Enum.Font.GothamBlack
    saveFavBtn.TextSize = 11
    saveFavBtn.AutoButtonColor = false
    corner(saveFavBtn, 8)
    pressFX(saveFavBtn)
    saveFavBtn.MouseButton1Click:Connect(function()
        local bundleId = bundleInput.Text
        if bundleId == "" or not bundleId:match("%d+") then
            showDynamicNotification("Enter a valid Bundle ID!", T.Red)
            return
        end
        
        -- Cek duplikat
        for _, fb in ipairs(favBundles) do
            if fb.id == bundleId then
                showDynamicNotification("Bundle already in favorites!", T.Red)
                return
            end
        end
        
        -- Tambahkan ke favorit dengan nama custom
        table.insert(favBundles, {
            id = bundleId,
            name = "Bundle " .. bundleId,
            date = os.date("%d/%m/%Y %H:%M")
        })
        persistFavBundles()
        showDynamicNotification("Added to favorites!", T.Gold)
        refreshCurr()
    end)
    
    -- ==================== PREVIEW IMAGE ====================
    -- Preview gambar bundle (jika ada)
    if bundleInput.Text ~= "" and bundleInput.Text:match("%d+") then
        local previewCard = Instance.new("Frame", executeCard)
        previewCard.Size = UDim2.new(0, 60, 0, 60)
        previewCard.Position = UDim2.new(1, -72, 0, 8)
        previewCard.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
        corner(previewCard, 8)
        stroke(previewCard, Color3.fromRGB(215, 215, 220), 1, 0.3)
        
        local previewImg = Instance.new("ImageLabel", previewCard)
        previewImg.Size = UDim2.new(1, -4, 1, -4)
        previewImg.Position = UDim2.new(0.5, 0, 0.5, 0)
        previewImg.AnchorPoint = Vector2.new(0.5, 0.5)
        previewImg.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
        previewImg.Image = "https://www.roblox.com/asset-thumbnail/image?assetId=" .. bundleInput.Text:match("%d+") .. "&width=100&height=100&format=png"
        previewImg.ScaleType = Enum.ScaleType.Fit
        corner(previewImg, 6)
    end
    
    -- ==================== FAVORITE BUNDLES ====================
    if #favBundles > 0 then
        -- Section header
        local favHeader = Instance.new("Frame", appContent)
        favHeader.Size = UDim2.new(1, 0, 0, 30)
        favHeader.BackgroundTransparency = 1
        favHeader.LayoutOrder = 2
        
        local favAccent = Instance.new("Frame", favHeader)
        favAccent.Size = UDim2.new(0, 3, 0, 18)
        favAccent.Position = UDim2.new(0, 0, 0.5, -9)
        favAccent.BackgroundColor3 = T.Gold
        corner(favAccent, 2)
        
        local favTitle = Instance.new("TextLabel", favHeader)
        favTitle.Size = UDim2.new(1, -16, 1, 0)
        favTitle.Position = UDim2.new(0, 8, 0, 0)
        favTitle.BackgroundTransparency = 1
        favTitle.Text = "Favorite Bundles (" .. #favBundles .. ")"
        favTitle.TextColor3 = T.Text
        favTitle.Font = Enum.Font.GothamBlack
        favTitle.TextSize = 13
        favTitle.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Render favorites
        for i, fb in ipairs(favBundles) do
            local card = Instance.new("Frame", appContent)
            card.Size = UDim2.new(1, 0, 0, 80)
            card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            card.LayoutOrder = i + 2
            corner(card, 12)
            stroke(card, Color3.fromRGB(255, 200, 50), 1.5, 0.2)
            
            -- Shadow
            local cardShadow = Instance.new("Frame", card)
            cardShadow.Size = UDim2.new(1, 6, 1, 6)
            cardShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
            cardShadow.AnchorPoint = Vector2.new(0.5, 0.5)
            cardShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            cardShadow.BackgroundTransparency = 0.94
            cardShadow.ZIndex = -1
            corner(cardShadow, 14)
            
            -- Bundle Image
            local imgBox = Instance.new("Frame", card)
            imgBox.Size = UDim2.new(0, 56, 0, 56)
            imgBox.Position = UDim2.new(0, 10, 0.5, -28)
            imgBox.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
            corner(imgBox, 8)
            stroke(imgBox, Color3.fromRGB(215, 215, 220), 1, 0.3)
            
            local bundleImg = Instance.new("ImageLabel", imgBox)
            bundleImg.Size = UDim2.new(1, -4, 1, -4)
            bundleImg.Position = UDim2.new(0.5, 0, 0.5, 0)
            bundleImg.AnchorPoint = Vector2.new(0.5, 0.5)
            bundleImg.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
            -- Gunakan ID pertama dari bundle sebagai thumbnail
            bundleImg.Image = "https://www.roblox.com/asset-thumbnail/image?assetId=" .. fb.id:match("%d+") .. "&width=100&height=100&format=png"
            bundleImg.ScaleType = Enum.ScaleType.Fit
            corner(bundleImg, 6)
            
            -- Bundle Name
            local nameLbl = Instance.new("TextLabel", card)
            nameLbl.Size = UDim2.new(1, -180, 0, 22)
            nameLbl.Position = UDim2.new(0, 74, 0, 10)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = fb.name or ("Bundle " .. fb.id)
            nameLbl.TextColor3 = T.Text
            nameLbl.Font = Enum.Font.GothamBlack
            nameLbl.TextSize = 12
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
            
            -- Bundle ID
            local idLbl = Instance.new("TextLabel", card)
            idLbl.Size = UDim2.new(1, -180, 0, 14)
            idLbl.Position = UDim2.new(0, 74, 0, 32)
            idLbl.BackgroundTransparency = 1
            idLbl.Text = "ID: " .. fb.id
            idLbl.TextColor3 = T.Text2
            idLbl.Font = Enum.Font.Code
            idLbl.TextSize = 9
            idLbl.TextXAlignment = Enum.TextXAlignment.Left
            
            -- Date
            local dateLbl = Instance.new("TextLabel", card)
            dateLbl.Size = UDim2.new(1, -180, 0, 12)
            dateLbl.Position = UDim2.new(0, 74, 0, 46)
            dateLbl.BackgroundTransparency = 1
            dateLbl.Text = fb.date or ""
            dateLbl.TextColor3 = Color3.fromRGB(160, 160, 170)
            dateLbl.Font = Enum.Font.Gotham
            dateLbl.TextSize = 8
            dateLbl.TextXAlignment = Enum.TextXAlignment.Left
            
            -- Action buttons
            local runBtn = Instance.new("TextButton", card)
            runBtn.Size = UDim2.new(0, 55, 0, 24)
            runBtn.Position = UDim2.new(1, -120, 0, 8)
            runBtn.BackgroundColor3 = T.Green
            runBtn.Text = "Run"
            runBtn.TextColor3 = T.OnAccent
            runBtn.Font = Enum.Font.GothamBold
            runBtn.TextSize = 9
            runBtn.AutoButtonColor = false
            corner(runBtn, 6)
            pressFX(runBtn)
            runBtn.MouseButton1Click:Connect(function()
                getgenv().bundle = fb.id
                bundleInput.Text = fb.id
                
                runBtn.Text = "..."
                runBtn.BackgroundColor3 = T.Gold
                
                local success, err = pcall(function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/Bac0nHck/Scripts/refs/heads/main/InstantBundle.lua"))()
                end)
                
                if success then
                    runBtn.Text = "Done!"
                    runBtn.BackgroundColor3 = T.Green
                    showDynamicNotification("Bundle executed!", T.Green)
                    task.wait(2)
                    runBtn.Text = "Run"
                    runBtn.BackgroundColor3 = T.Green
                else
                    runBtn.Text = "Error!"
                    runBtn.BackgroundColor3 = T.Red
                    task.wait(2)
                    runBtn.Text = "Run"
                    runBtn.BackgroundColor3 = T.Green
                end
            end)
            
            -- Rename button
            local renameBtn = Instance.new("TextButton", card)
            renameBtn.Size = UDim2.new(0, 55, 0, 24)
            renameBtn.Position = UDim2.new(1, -120, 0, 36)
            renameBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
            renameBtn.Text = "Rename"
            renameBtn.TextColor3 = T.Text
            renameBtn.Font = Enum.Font.GothamBold
            renameBtn.TextSize = 9
            renameBtn.AutoButtonColor = false
            corner(renameBtn, 6)
            stroke(renameBtn, T.Border, 1, 0.3)
            pressFX(renameBtn)
            renameBtn.MouseButton1Click:Connect(function()
                -- Sembunyikan label lama
                nameLbl.Visible = false
                idLbl.Visible = false
                dateLbl.Visible = false
                
                -- Tampilkan input rename
                local renameInput = Instance.new("TextBox", card)
                renameInput.Size = UDim2.new(1, -180, 0, 28)
                renameInput.Position = UDim2.new(0, 74, 0, 10)
                renameInput.Text = fb.name
                renameInput.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
                renameInput.TextColor3 = T.Text
                renameInput.Font = Enum.Font.GothamBold
                renameInput.TextSize = 12
                renameInput.ZIndex = 10
                corner(renameInput, 6)
                stroke(renameInput, T.Accent, 1.5, 0)
                
                renameInput.FocusLost:Connect(function(enterPressed)
                    local newName = renameInput.Text
                    if newName ~= "" and newName:match("%S") then
                        fb.name = newName
                        persistFavBundles() -- SIMPAN PERMANEN
                        showDynamicNotification("Bundle renamed!", T.Green)
                    end
                    renameInput:Destroy()
                    nameLbl.Visible = true
                    idLbl.Visible = true
                    dateLbl.Visible = true
                    nameLbl.Text = fb.name
                end)
                
                renameInput:CaptureFocus()
            end)
            
            -- Delete button
            local delBtn = Instance.new("TextButton", card)
            delBtn.Size = UDim2.new(0, 28, 0, 28)
            delBtn.Position = UDim2.new(1, -36, 0, 8)
            delBtn.BackgroundColor3 = Color3.fromRGB(255, 230, 230)
            delBtn.Text = "X"
            delBtn.TextColor3 = T.Red
            delBtn.Font = Enum.Font.GothamBlack
            delBtn.TextSize = 12
            delBtn.AutoButtonColor = false
            corner(delBtn, 6)
            pressFX(delBtn)
            delBtn.MouseButton1Click:Connect(function()
                delBtn.Text = "?"
                task.wait(0.4)
                if delBtn.Text == "?" then
                    table.remove(favBundles, i)
                    persistFavBundles() -- SIMPAN PERMANEN
                    showDynamicNotification("Bundle removed!", T.Red)
                    refreshCurr()
                end
            end)
        end
    else
        -- Empty state
        local emptyCard = Instance.new("Frame", appContent)
        emptyCard.Size = UDim2.new(1, 0, 0, 90)
        emptyCard.BackgroundColor3 = Color3.fromRGB(248, 248, 250)
        emptyCard.LayoutOrder = 2
        corner(emptyCard, 14)
        stroke(emptyCard, Color3.fromRGB(220, 220, 225), 1, 0.3)
        
        local emptyText = Instance.new("TextLabel", emptyCard)
        emptyText.Size = UDim2.new(1, -20, 0, 30)
        emptyText.Position = UDim2.new(0, 10, 0, 18)
        emptyText.BackgroundTransparency = 1
        emptyText.Text = "No favorite bundles yet"
        emptyText.TextColor3 = Color3.fromRGB(140, 140, 150)
        emptyText.Font = Enum.Font.GothamBlack
        emptyText.TextSize = 13
        emptyText.TextXAlignment = Enum.TextXAlignment.Center
        
        local emptySub = Instance.new("TextLabel", emptyCard)
        emptySub.Size = UDim2.new(1, -20, 0, 20)
        emptySub.Position = UDim2.new(0, 10, 0, 50)
        emptySub.BackgroundTransparency = 1
        emptySub.Text = "Enter Bundle ID and click 'Add to Fav'"
        emptySub.TextColor3 = Color3.fromRGB(180, 180, 190)
        emptySub.Font = Enum.Font.Gotham
        emptySub.TextSize = 9
        emptySub.TextXAlignment = Enum.TextXAlignment.Center
    end
    
    -- Info card
    local infoCard = Instance.new("Frame", appContent)
    infoCard.Size = UDim2.new(1, 0, 0, 44)
    infoCard.BackgroundColor3 = Color3.fromRGB(245, 248, 255)
    infoCard.LayoutOrder = 99
    corner(infoCard, 10)
    stroke(infoCard, Color3.fromRGB(200, 210, 230), 1, 0.3)
    
    local infoText = Instance.new("TextLabel", infoCard)
    infoText.Size = UDim2.new(1, -16, 1, 0)
    infoText.Position = UDim2.new(0, 8, 0, 0)
    infoText.BackgroundTransparency = 1
    infoText.Text = "Bundle ID disimpan otomatis.\nRename bersifat permanen (tersimpan ke file)."
    infoText.TextColor3 = T.Text2
    infoText.Font = Enum.Font.Gotham
    infoText.TextSize = 8
    infoText.TextWrapped = true
    infoText.TextXAlignment = Enum.TextXAlignment.Left
end

-- ================= AVATAR & ITEMS APP (FINAL FIXED - OUTFITS & AVATARS WORKING) =================
local avatarItemsSelectedTab = "Favorites"

local function openAvatarItemsApp()
    -- ==================== HEADER ====================
    local headerCard = Instance.new("Frame", appContent)
    headerCard.Size = UDim2.new(1, 0, 0, 44)
    headerCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    headerCard.LayoutOrder = 0
    corner(headerCard, 14)
    stroke(headerCard, Color3.fromRGB(225, 225, 230), 1, 0.3)
    
    local headerTitle = Instance.new("TextLabel", headerCard)
    headerTitle.Size = UDim2.new(1, -24, 0, 20)
    headerTitle.Position = UDim2.new(0, 12, 0, 4)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "Player Assets"
    headerTitle.TextColor3 = T.Text
    headerTitle.Font = Enum.Font.GothamBlack
    headerTitle.TextSize = 14
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local headerSub = Instance.new("TextLabel", headerCard)
    headerSub.Size = UDim2.new(1, -24, 0, 14)
    headerSub.Position = UDim2.new(0, 12, 0, 24)
    headerSub.BackgroundTransparency = 1
    headerSub.Text = selectedPlayer and ("Target: " .. selectedPlayer.DisplayName .. " | @" .. selectedPlayer.Name) or "No player selected"
    headerSub.TextColor3 = T.Text2
    headerSub.Font = Enum.Font.Gotham
    headerSub.TextSize = 8
    headerSub.TextXAlignment = Enum.TextXAlignment.Left
    
    -- ==================== TABS ====================
    local tabFrame = Instance.new("Frame", appContent)
    tabFrame.Size = UDim2.new(1, 0, 0, 34)
    tabFrame.BackgroundColor3 = Color3.fromRGB(242, 242, 247)
    tabFrame.LayoutOrder = 1
    corner(tabFrame, 17)
    stroke(tabFrame, Color3.fromRGB(200, 200, 210), 1, 0.3)
    
    local tabPadding = Instance.new("UIPadding", tabFrame)
    tabPadding.PaddingLeft = UDim.new(0, 3)
    tabPadding.PaddingRight = UDim.new(0, 3)
    tabPadding.PaddingTop = UDim.new(0, 3)
    tabPadding.PaddingBottom = UDim.new(0, 3)
    
    local tabs = {"Favorites", "Worn", "Outfits", "Avatars"}
    
    for i, t in ipairs(tabs) do
        local btn = Instance.new("TextButton", tabFrame)
        btn.Size = UDim2.new(1/4, -4, 1, 0)
        btn.Position = UDim2.new((i-1)/4, 2, 0, 0)
        btn.Text = t
        btn.AutoButtonColor = false
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundTransparency = 1
        btn.TextColor3 = Color3.fromRGB(100, 100, 100)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 7
        corner(btn, 14)
        
        if t == avatarItemsSelectedTab then
            btn.BackgroundColor3 = T.Accent
            btn.BackgroundTransparency = 0
            btn.TextColor3 = Color3.new(1, 1, 1)
        end
        
        btn.MouseButton1Click:Connect(function()
            avatarItemsSelectedTab = t
            refreshCurr()
        end)
    end
    
    -- ==================== CONTENT ====================
    local contentFrame = Instance.new("Frame", appContent)
    contentFrame.Size = UDim2.new(1, 0, 0, 0)
    contentFrame.AutomaticSize = Enum.AutomaticSize.Y
    contentFrame.BackgroundTransparency = 1
    contentFrame.LayoutOrder = 2
    
    if not selectedPlayer then
        local emptyCard = Instance.new("Frame", contentFrame)
        emptyCard.Size = UDim2.new(1, 0, 0, 90)
        emptyCard.BackgroundColor3 = Color3.fromRGB(248, 248, 250)
        corner(emptyCard, 14)
        stroke(emptyCard, Color3.fromRGB(220, 220, 225), 1, 0.3)
        
        local emptyText = Instance.new("TextLabel", emptyCard)
        emptyText.Size = UDim2.new(1, 0, 1, 0)
        emptyText.BackgroundTransparency = 1
        emptyText.Text = "Select a player first!\nGo to Players > Select player"
        emptyText.TextColor3 = Color3.fromRGB(140, 140, 150)
        emptyText.Font = Enum.Font.GothamBold
        emptyText.TextSize = 12
        emptyText.TextWrapped = true
        return
    end
    
    -- Loading minimal
    local loadingFrame = Instance.new("Frame", contentFrame)
    loadingFrame.Size = UDim2.new(1, 0, 0, 35)
    loadingFrame.BackgroundColor3 = Color3.fromRGB(248, 248, 250)
    corner(loadingFrame, 10)
    stroke(loadingFrame, Color3.fromRGB(220, 220, 225), 1, 0.3)
    
    local loadingText = Instance.new("TextLabel", loadingFrame)
    loadingText.Size = UDim2.new(1, 0, 1, 0)
    loadingText.BackgroundTransparency = 1
    loadingText.Text = "Loading..."
    loadingText.TextColor3 = T.Text2
    loadingText.Font = Enum.Font.Gotham
    loadingText.TextSize = 10
    
    -- HTTP helper - coba semua method
    local function httpGet(url)
        -- Method 1: syn.request
        local ok, result = pcall(function()
            if syn and syn.request then
                local resp = syn.request({Url = url, Method = "GET", Headers = {["Content-Type"] = "application/json"}})
                if resp and resp.Body and resp.Body ~= "" and resp.Body ~= "null" then
                    return resp.Body
                end
            end
            error("no syn")
        end)
        if ok and result then return result end
        
        -- Method 2: game:HttpGet
        ok, result = pcall(function()
            local data = game:HttpGet(url)
            if data and data ~= "" and data ~= "null" then return data end
            error("empty")
        end)
        if ok and result then return result end
        
        -- Method 3: http_request
        ok, result = pcall(function()
            if http_request then
                local resp = http_request({Url = url, Method = "GET"})
                if resp and resp.Body and resp.Body ~= "" then return resp.Body end
            end
            error("no http_request")
        end)
        if ok and result then return result end
        
        -- Method 4: request
        ok, result = pcall(function()
            if request then
                local resp = request({Url = url, Method = "GET"})
                if resp and resp.Body and resp.Body ~= "" then return resp.Body end
            end
            error("no request")
        end)
        if ok and result then return result end
        
        return nil
    end
    
    -- Clone batch
    local function cloneWithBatch(ids, callback)
        local batchSize = CONFIG.CLONE_BATCH_SIZE or 5
        local delayTime = CONFIG.CLONE_DELAY or 6
        local totalBatches = math.ceil(#ids / batchSize)
        local currentBatch = 0
        
        local function processNextBatch()
            currentBatch = currentBatch + 1
            if currentBatch > totalBatches then
                if callback then callback(true) end
                return
            end
            
            local startIdx = (currentBatch - 1) * batchSize + 1
            local endIdx = math.min(currentBatch * batchSize, #ids)
            local batchIds = {}
            
            for j = startIdx, endIdx do
                table.insert(batchIds, ids[j])
            end
            
            fireHat(batchIds)
            
            if callback then
                callback(nil, currentBatch, totalBatches)
            end
            
            task.delay(delayTime, processNextBatch)
        end
        
        processNextBatch()
    end
    
    -- Check if item is fav
    local function isItemFaved(itemType, itemId)
        for _, fav in ipairs(favAvatarItems) do
            if fav.itemType == itemType and fav.itemId == itemId then
                return true
            end
        end
        return false
    end
    
    -- Toggle fav
    local function toggleFav(itemType, itemId, itemName, itemValue, extraData)
        for i, fav in ipairs(favAvatarItems) do
            if fav.itemType == itemType and fav.itemId == itemId then
                table.remove(favAvatarItems, i)
                persistFavAvatarItems()
                return false
            end
        end
        
        table.insert(favAvatarItems, {
            itemType = itemType,
            itemId = itemId,
            name = itemName,
            value = itemValue,
            extraData = extraData or {},
            date = os.date("%d/%m/%Y %H:%M")
        })
        persistFavAvatarItems()
        return true
    end
    
    -- Fetch data (coroutine = no lag)
    coroutine.wrap(function()
        local userId = selectedPlayer.UserId
        local displayItems = {}
        
        -- ============ TAB: FAVORITES ============
        if avatarItemsSelectedTab == "Favorites" then
            for _, fav in ipairs(favAvatarItems) do
                local item = {
                    Label = fav.name or fav.value,
                    Value = fav.value,
                    Type = fav.itemType,
                    IsFav = true
                }
                
                if fav.itemType == "OUTFIT" then
                    item.OutfitId = fav.itemId
                    item.OutfitAssets = fav.extraData.assets or {}
                elseif fav.itemType == "AVATAR" then
                    item.AvatarId = fav.itemId
                    item.AvatarAssets = fav.extraData.assets or {}
                end
                
                table.insert(displayItems, item)
            end
        end
        
        -- ============ TAB: WORN ============
        if avatarItemsSelectedTab == "Worn" then
            local items = getItems(selectedPlayer)
            displayItems = items
        end
        
        -- ============ TAB: OUTFITS ============
        if avatarItemsSelectedTab == "Outfits" then
            local raw = httpGet("https://avatar.roblox.com/v1/users/" .. userId .. "/outfits?page=1&itemsPerPage=30")
            
            if raw then
                local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
                if ok and data and data.data and #data.data > 0 then
                    for _, outfit in ipairs(data.data) do
                        if outfit.name and outfit.id then
                            table.insert(displayItems, {
                                Label = outfit.name,
                                Value = "OUTFIT:" .. outfit.id,
                                Type = "OUTFIT",
                                OutfitId = outfit.id,
                                OutfitAssets = {},
                                IsFav = isItemFaved("OUTFIT", outfit.id)
                            })
                        end
                    end
                end
            end
            
            -- Fallback: current outfit untuk diri sendiri
            if #displayItems == 0 and selectedPlayer == LocalPlayer then
                local charItems = getItems(selectedPlayer)
                if #charItems > 0 then
                    local ids = {}
                    for _, it in ipairs(charItems) do
                        table.insert(ids, it.Value)
                    end
                    table.insert(displayItems, {
                        Label = "Current Outfit",
                        Value = "OUTFIT:current",
                        Type = "OUTFIT",
                        OutfitId = "current",
                        OutfitAssets = ids,
                        IsFav = isItemFaved("OUTFIT", "current")
                    })
                end
            end
        end
        
        -- ============ TAB: AVATARS ============
        if avatarItemsSelectedTab == "Avatars" then
            local raw = httpGet("https://avatar.roblox.com/v1/users/" .. userId .. "/avatars")
            
            if raw then
                local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
                if ok and data and data.data and #data.data > 0 then
                    for _, av in ipairs(data.data) do
                        if av.name and av.id then
                            table.insert(displayItems, {
                                Label = av.name,
                                Value = "AVATAR:" .. av.id,
                                Type = "AVATAR",
                                AvatarId = av.id,
                                IsFav = isItemFaved("AVATAR", av.id)
                            })
                        end
                    end
                end
            end
            
            -- Fallback: current avatar
            if #displayItems == 0 and selectedPlayer == LocalPlayer then
                table.insert(displayItems, {
                    Label = "Current Avatar",
                    Value = "AVATAR:current",
                    Type = "AVATAR",
                    AvatarId = "current",
                    AvatarAssets = {},
                    IsFav = isItemFaved("AVATAR", "current")
                })
            end
        end
        
        -- Hapus loading
        loadingFrame:Destroy()
        
        -- ============ EMPTY STATE ============
        if #displayItems == 0 then
            local emptyCard = Instance.new("Frame", contentFrame)
            emptyCard.Size = UDim2.new(1, 0, 0, 100)
            emptyCard.BackgroundColor3 = Color3.fromRGB(248, 248, 250)
            corner(emptyCard, 14)
            stroke(emptyCard, Color3.fromRGB(220, 220, 225), 1, 0.3)
            
            local emptyMessages = {
                Favorites = "No favorites yet\nAdd outfits/avatars using the star button!",
                Worn = "Player is not wearing any items",
                Outfits = "No outfits found for this player\n(API may be restricted)",
                Avatars = "No avatars found for this player\n(API may be restricted)"
            }
            
            local emptyText = Instance.new("TextLabel", emptyCard)
            emptyText.Size = UDim2.new(1, 0, 1, 0)
            emptyText.BackgroundTransparency = 1
            emptyText.Text = emptyMessages[avatarItemsSelectedTab] or "No items found"
            emptyText.TextColor3 = Color3.fromRGB(140, 140, 150)
            emptyText.Font = Enum.Font.GothamBold
            emptyText.TextSize = 12
            emptyText.TextWrapped = true
            emptyText.TextXAlignment = Enum.TextXAlignment.Center
            return
        end
        
        -- ============ COUNTER ============
        local counterFrame = Instance.new("Frame", contentFrame)
        counterFrame.Size = UDim2.new(1, 0, 0, 14)
        counterFrame.BackgroundTransparency = 1
        
        local counterText = Instance.new("TextLabel", counterFrame)
        counterText.Size = UDim2.new(0, 150, 1, 0)
        counterText.BackgroundTransparency = 1
        counterText.Text = #displayItems .. " items"
        counterText.TextColor3 = T.Text2
        counterText.Font = Enum.Font.GothamBold
        counterText.TextSize = 8
        counterText.TextXAlignment = Enum.TextXAlignment.Left
        
        -- ============ GRID 2 KOLOM ============
        local grid = Instance.new("UIGridLayout", contentFrame)
        grid.CellSize = UDim2.new(0.5, -5, 0, 155)
        grid.CellPadding = UDim2.new(0, 8, 0, 8)
        grid.FillDirection = Enum.FillDirection.Horizontal
        grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
        grid.SortOrder = Enum.SortOrder.LayoutOrder
        
        local typeColors = {
            OUTFIT = Color3.fromRGB(180, 130, 255),
            AVATAR = Color3.fromRGB(100, 150, 255),
            BODY = Color3.fromRGB(255, 130, 80),
            ACC = Color3.fromRGB(80, 200, 80),
            FAVORITE = Color3.fromRGB(255, 180, 50)
        }
        
        local typeLabels = {
            OUTFIT = "OUTFIT",
            AVATAR = "AVATAR",
            BODY = "BODY",
            ACC = "ACC",
            FAVORITE = "FAV"
        }
        
        -- ============ RENDER ============
        for i, item in ipairs(displayItems) do
            local card = Instance.new("Frame", contentFrame)
            card.Size = UDim2.new(0, 0, 0, 155)
            card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            card.LayoutOrder = i
            corner(card, 12)
            
            if item.IsFav then
                stroke(card, Color3.fromRGB(255, 200, 50), 2, 0)
            else
                stroke(card, Color3.fromRGB(225, 225, 230), 1, 0.3)
            end
            
            -- Type badge
            local badgeColor = typeColors[item.Type] or T.Accent
            local typeBadge = Instance.new("Frame", card)
            typeBadge.Size = UDim2.new(0, 40, 0, 12)
            typeBadge.Position = UDim2.new(0, 4, 0, 4)
            typeBadge.BackgroundColor3 = badgeColor
            typeBadge.BackgroundTransparency = 0.8
            corner(typeBadge, 6)
            
            local typeText = Instance.new("TextLabel", typeBadge)
            typeText.Size = UDim2.new(1, 0, 1, 0)
            typeText.BackgroundTransparency = 1
            typeText.Text = typeLabels[item.Type] or item.Type
            typeText.TextColor3 = badgeColor
            typeText.Font = Enum.Font.GothamBold
            typeText.TextSize = 7
            
            -- Star button (untuk Outfit & Avatar)
            if item.Type == "OUTFIT" or item.Type == "AVATAR" then
                local starBtn = Instance.new("TextButton", card)
                starBtn.Size = UDim2.new(0, 20, 0, 20)
                starBtn.Position = UDim2.new(1, -24, 0, 2)
                starBtn.BackgroundColor3 = item.IsFav and T.Gold or Color3.fromRGB(240, 240, 240)
                starBtn.Text = item.IsFav and "★" or "☆"
                starBtn.TextColor3 = item.IsFav and Color3.new(1, 1, 1) or Color3.fromRGB(150, 150, 150)
                starBtn.Font = Enum.Font.GothamBlack
                starBtn.TextSize = 12
                starBtn.AutoButtonColor = false
                corner(starBtn, 10)
                pressFX(starBtn)
                
                starBtn.MouseButton1Click:Connect(function()
                    local itemId = item.Type == "OUTFIT" and item.OutfitId or item.AvatarId
                    local extraData = {}
                    
                    if item.Type == "OUTFIT" then
                        extraData.assets = item.OutfitAssets or {}
                    else
                        extraData.assets = item.AvatarAssets or {}
                    end
                    
                    local isNowFav = toggleFav(item.Type, itemId, item.Label, item.Value, extraData)
                    
                    if isNowFav then
                        starBtn.Text = "★"
                        starBtn.BackgroundColor3 = T.Gold
                        starBtn.TextColor3 = Color3.new(1, 1, 1)
                        item.IsFav = true
                        stroke(card, Color3.fromRGB(255, 200, 50), 2, 0)
                        showDynamicNotification("Added to favorites!", T.Gold)
                    else
                        starBtn.Text = "☆"
                        starBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
                        starBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
                        item.IsFav = false
                        stroke(card, Color3.fromRGB(225, 225, 230), 1, 0.3)
                        showDynamicNotification("Removed from favorites!", T.Text2)
                    end
                end)
            end
            
            -- Image
            local imgBox = Instance.new("Frame", card)
            imgBox.Size = UDim2.new(0, 60, 0, 60)
            imgBox.Position = UDim2.new(0.5, -30, 0, 20)
            imgBox.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
            corner(imgBox, 10)
            stroke(imgBox, Color3.fromRGB(215, 215, 220), 1, 0.3)
            
            local img = Instance.new("ImageLabel", imgBox)
            img.Size = UDim2.new(1, -4, 1, -4)
            img.Position = UDim2.new(0.5, 0, 0.5, 0)
            img.AnchorPoint = Vector2.new(0.5, 0.5)
            img.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
            
            -- Thumbnail
            if item.Type == "AVATAR" then
                if item.AvatarId == "current" then
                    img.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=150&height=150&format=png"
                else
                    img.Image = "https://www.roblox.com/outfit-thumbnail/image?userOutfitId=" .. item.AvatarId .. "&width=150&height=150&format=png"
                end
            elseif item.Type == "OUTFIT" then
                if item.OutfitId == "current" then
                    img.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=150&height=150&format=png"
                else
                    img.Image = "https://www.roblox.com/outfit-thumbnail/image?userOutfitId=" .. item.OutfitId .. "&width=150&height=150&format=png"
                end
            else
                img.Image = "https://www.roblox.com/asset-thumbnail/image?assetId=" .. item.Value .. "&width=150&height=150&format=png"
            end
            img.ScaleType = Enum.ScaleType.Fit
            corner(img, 7)
            
            -- Name
            local nameLbl = Instance.new("TextLabel", card)
            nameLbl.Size = UDim2.new(1, -10, 0, 20)
            nameLbl.Position = UDim2.new(0, 5, 0, 84)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = item.Label or item.Value
            nameLbl.TextColor3 = T.Text
            nameLbl.Font = Enum.Font.GothamBold
            nameLbl.TextSize = 8
            nameLbl.TextXAlignment = Enum.TextXAlignment.Center
            nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
            nameLbl.TextWrapped = true
            
            -- ID
            local idText = item.Value
            if item.Type == "AVATAR" then idText = "AV:" .. item.AvatarId
            elseif item.Type == "OUTFIT" then idText = "OUT:" .. item.OutfitId end
            
            local idLbl = Instance.new("TextLabel", card)
            idLbl.Size = UDim2.new(1, -10, 0, 10)
            idLbl.Position = UDim2.new(0, 5, 0, 104)
            idLbl.BackgroundTransparency = 1
            idLbl.Text = idText
            idLbl.TextColor3 = T.Text2
            idLbl.Font = Enum.Font.Code
            idLbl.TextSize = 7
            idLbl.TextXAlignment = Enum.TextXAlignment.Center
            idLbl.TextTruncate = Enum.TextTruncate.AtEnd
            
            -- Buttons
            local btnRow = Instance.new("Frame", card)
            btnRow.Size = UDim2.new(1, -10, 0, 26)
            btnRow.Position = UDim2.new(0, 5, 0, 118)
            btnRow.BackgroundTransparency = 1
            
            if item.Type == "OUTFIT" then
                -- CLONE
                local cloneBtn = Instance.new("TextButton", btnRow)
                cloneBtn.Size = UDim2.new(0, 62, 1, 0)
                cloneBtn.BackgroundColor3 = T.Green
                cloneBtn.Text = "Clone"
                cloneBtn.TextColor3 = T.OnAccent
                cloneBtn.Font = Enum.Font.GothamBold
                cloneBtn.TextSize = 8
                cloneBtn.AutoButtonColor = false
                corner(cloneBtn, 5)
                pressFX(cloneBtn)
                
                cloneBtn.MouseButton1Click:Connect(function()
                    cloneBtn.Text = "..."
                    cloneBtn.BackgroundColor3 = T.Gold
                    
                    local idsToClone = item.OutfitAssets or {}
                    
                    if #idsToClone == 0 and item.OutfitId ~= "current" then
                        local detailRaw = httpGet("https://avatar.roblox.com/v1/outfits/" .. item.OutfitId .. "/details")
                        if detailRaw then
                            local ok, detail = pcall(function() return HttpService:JSONDecode(detailRaw) end)
                            if ok and detail and detail.assets then
                                for _, asset in ipairs(detail.assets) do
                                    if asset.id and type(asset.id) == "number" then
                                        table.insert(idsToClone, tostring(asset.id))
                                    end
                                end
                                item.OutfitAssets = idsToClone
                            end
                        end
                    elseif #idsToClone == 0 and item.OutfitId == "current" then
                        local charItems = getItems(selectedPlayer)
                        for _, it in ipairs(charItems) do
                            table.insert(idsToClone, it.Value)
                        end
                        item.OutfitAssets = idsToClone
                    end
                    
                    if #idsToClone > 0 then
                        cloneWithBatch(idsToClone, function(done, batch, total)
                            if done then
                                cloneBtn.Text = "Done!"
                                cloneBtn.BackgroundColor3 = T.Green
                                showDynamicNotification("Clone complete! (" .. #idsToClone .. " items)", T.Green)
                                task.wait(1.5)
                                cloneBtn.Text = "Clone"
                                cloneBtn.BackgroundColor3 = T.Green
                            else
                                cloneBtn.Text = batch .. "/" .. total
                            end
                        end)
                    else
                        cloneBtn.Text = "Empty!"
                        cloneBtn.BackgroundColor3 = T.Red
                        task.wait(1.5)
                        cloneBtn.Text = "Clone"
                        cloneBtn.BackgroundColor3 = T.Green
                    end
                end)
                
                -- Copy
                local copyBtn = Instance.new("TextButton", btnRow)
                copyBtn.Size = UDim2.new(0, 48, 1, 0)
                copyBtn.Position = UDim2.new(0, 66, 0, 0)
                copyBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
                copyBtn.Text = "Copy"
                copyBtn.TextColor3 = T.Text
                copyBtn.Font = Enum.Font.GothamBold
                copyBtn.TextSize = 8
                copyBtn.AutoButtonColor = false
                corner(copyBtn, 5)
                stroke(copyBtn, T.Border, 1, 0.3)
                pressFX(copyBtn)
                copyBtn.MouseButton1Click:Connect(function()
                    copyToClipboard(tostring(item.OutfitId))
                    showDynamicNotification("Copied!", T.Green)
                end)
                
            elseif item.Type == "AVATAR" then
                -- WEAR ALL
                local wearBtn = Instance.new("TextButton", btnRow)
                wearBtn.Size = UDim2.new(0, 62, 1, 0)
                wearBtn.BackgroundColor3 = T.Accent
                wearBtn.Text = "Wear All"
                wearBtn.TextColor3 = T.OnAccent
                wearBtn.Font = Enum.Font.GothamBold
                wearBtn.TextSize = 8
                wearBtn.AutoButtonColor = false
                corner(wearBtn, 5)
                pressFX(wearBtn)
                
                wearBtn.MouseButton1Click:Connect(function()
                    wearBtn.Text = "..."
                    wearBtn.BackgroundColor3 = T.Gold
                    
                    local idsToWear = item.AvatarAssets or {}
                    
                    if #idsToWear == 0 and item.AvatarId ~= "current" then
                        local detailRaw = httpGet("https://avatar.roblox.com/v1/avatars/" .. item.AvatarId .. "/details")
                        if detailRaw then
                            local ok, detail = pcall(function() return HttpService:JSONDecode(detailRaw) end)
                            if ok and detail and detail.assets then
                                for _, asset in ipairs(detail.assets) do
                                    if asset.id and type(asset.id) == "number" then
                                        table.insert(idsToWear, tostring(asset.id))
                                    end
                                end
                                item.AvatarAssets = idsToWear
                            end
                        end
                    elseif #idsToWear == 0 and item.AvatarId == "current" then
                        local charItems = getItems(selectedPlayer)
                        for _, it in ipairs(charItems) do
                            table.insert(idsToWear, it.Value)
                        end
                        item.AvatarAssets = idsToWear
                    end
                    
                    if #idsToWear > 0 then
                        fireHat(idsToWear)
                        task.wait(0.3)
                        resetCharacter()
                        wearBtn.Text = "Done!"
                        wearBtn.BackgroundColor3 = T.Green
                        showDynamicNotification("Avatar applied!", T.Green)
                        task.wait(1.5)
                        wearBtn.Text = "Wear All"
                        wearBtn.BackgroundColor3 = T.Accent
                    else
                        wearBtn.Text = "Fail!"
                        wearBtn.BackgroundColor3 = T.Red
                        task.wait(1.5)
                        wearBtn.Text = "Wear All"
                        wearBtn.BackgroundColor3 = T.Accent
                    end
                end)
                
                -- Copy
                local copyBtn = Instance.new("TextButton", btnRow)
                copyBtn.Size = UDim2.new(0, 48, 1, 0)
                copyBtn.Position = UDim2.new(0, 66, 0, 0)
                copyBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
                copyBtn.Text = "Copy"
                copyBtn.TextColor3 = T.Text
                copyBtn.Font = Enum.Font.GothamBold
                copyBtn.TextSize = 8
                copyBtn.AutoButtonColor = false
                corner(copyBtn, 5)
                stroke(copyBtn, T.Border, 1, 0.3)
                pressFX(copyBtn)
                copyBtn.MouseButton1Click:Connect(function()
                    copyToClipboard(tostring(item.AvatarId))
                    showDynamicNotification("Copied!", T.Green)
                end)
                
            else
                -- WEAR single
                local wearBtn = Instance.new("TextButton", btnRow)
                wearBtn.Size = UDim2.new(0, 50, 1, 0)
                wearBtn.BackgroundColor3 = T.Accent
                wearBtn.Text = "Wear"
                wearBtn.TextColor3 = T.OnAccent
                wearBtn.Font = Enum.Font.GothamBold
                wearBtn.TextSize = 8
                wearBtn.AutoButtonColor = false
                corner(wearBtn, 5)
                pressFX(wearBtn)
                wearBtn.MouseButton1Click:Connect(function()
                    fireHat({item.Value})
                    wearBtn.Text = "OK"
                    wearBtn.BackgroundColor3 = T.Green
                    task.wait(1)
                    wearBtn.Text = "Wear"
                    wearBtn.BackgroundColor3 = T.Accent
                end)
                
                -- Copy
                local copyBtn = Instance.new("TextButton", btnRow)
                copyBtn.Size = UDim2.new(0, 48, 1, 0)
                copyBtn.Position = UDim2.new(0, 54, 0, 0)
                copyBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
                copyBtn.Text = "Copy"
                copyBtn.TextColor3 = T.Text
                copyBtn.Font = Enum.Font.GothamBold
                copyBtn.TextSize = 8
                copyBtn.AutoButtonColor = false
                corner(copyBtn, 5)
                stroke(copyBtn, T.Border, 1, 0.3)
                pressFX(copyBtn)
                copyBtn.MouseButton1Click:Connect(function()
                    copyToClipboard(item.Value)
                    showDynamicNotification("Copied!", T.Green)
                end)
                
                -- Remove from fav (tab Favorites)
                if item.Type == "FAVORITE" then
                    local delBtn = Instance.new("TextButton", card)
                    delBtn.Size = UDim2.new(0, 16, 0, 26)
                    delBtn.Position = UDim2.new(0, 2, 0, 118)
                    delBtn.BackgroundColor3 = Color3.fromRGB(255, 220, 220)
                    delBtn.Text = "X"
                    delBtn.TextColor3 = T.Red
                    delBtn.Font = Enum.Font.GothamBlack
                    delBtn.TextSize = 9
                    delBtn.AutoButtonColor = false
                    corner(delBtn, 5)
                    pressFX(delBtn)
                    delBtn.MouseButton1Click:Connect(function()
                        for j, fav in ipairs(favAvatarItems) do
                            if fav.itemId == item.OutfitId or fav.itemId == item.AvatarId or fav.value == item.Value then
                                table.remove(favAvatarItems, j)
                                persistFavAvatarItems()
                                showDynamicNotification("Removed!", T.Red)
                                refreshCurr()
                                break
                            end
                        end
                    end)
                end
            end
        end
    end)()
end


-- ================= BUILD HOME ICONS =================
buildAppIcon("Profile",1,dockBg,function() openApp("Profile",openProfileApp) end)
buildAppIcon("Command",2,dockBg, function() openApp("Commands", openCommandApp) end)
buildAppIcon("Settings",3,dockBg,function() openApp("Settings",openSettingsApp) end)
buildAppIcon("Players",1,appGrid,function() openApp("Players",openPlayersApp) end)
buildAppIcon("Clone",2,appGrid,function() openApp("Clone",openCloneApp) end)
buildAppIcon("Body",3,appGrid,function() openApp("Body",openBodyApp) end)
buildAppIcon("Accs",4,appGrid,function() openApp("Accessory",openAccessoryApp) end)
buildAppIcon("Preset",5,appGrid,function() openApp("Preset",openPresetApp) end)
buildAppIcon("Favs",6,appGrid,function() openApp("Favorites",openFavoritesApp) end)
buildAppIcon("Items",7,appGrid,function() openApp("Items",openItemsApp) end)
buildAppIcon("Teleport",8,appGrid,function() openApp("Save & Teleport",openTeleportApp) end)
buildAppIcon("Size",9,appGrid,function() openApp("Size",openSizeApp) end)
buildAppIcon("Volume",10,appGrid,function() openApp("Volume",openVolumeApp) end)
buildAppIcon("Friends",11,appGrid,function() openApp("Friends",openFriendsApp) end)
buildAppIcon("Server",12,appGrid,function() openApp("Server",openServerApp) end)
buildAppIcon("Bundle",13, appGrid, function() openApp("Bundle", openBundleApp) end)
buildAppIcon("AvatarItems",14, appGrid, function() openApp("Avatar & Items", openAvatarItemsApp) end)
-- ================= DRAG PHONE =================
do local dragging,dragStart,startPos;sb.Active=true;sb.InputBegan:Connect(function(inp)if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then dragging=true;dragStart=inp.Position;startPos=phone.Position end end);sb.InputEnded:Connect(function(inp)if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then dragging=false end end);UserInputService.InputChanged:Connect(function(inp)if dragging and(inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseMovement)then local d=inp.Position-dragStart;phone.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)end end)end

-- ================= TOOL & EQUIP =================
local phoneTool=nil
local function openPhone() applyPhoneOrientationSize();phone.Visible=true;phone.Size=UDim2.new(0,0,0,0);tween(phone,{Size=PHONE_SIZE},0.32,Enum.EasingStyle.Back);if isLocked then lock.Visible=true;pass.Visible=false else goHome() end end
local function closePhone() tween(phone,{Size=UDim2.new(0,0,0,0)},0.22);task.delay(0.22,function()phone.Visible=false end) end
local function setupTool() phoneTool=ensureTool();if phoneTool then phoneTool.Equipped:Connect(function()if not phone.Visible then openPhone()end end);phoneTool.Unequipped:Connect(function()if phone.Visible then closePhone()end end)end end
setupTool()
LocalPlayer.CharacterAdded:Connect(function()phoneTool=nil;task.wait(0.5);setupTool()end)

-- ==================== WELCOME SCREEN (BAHASA INDONESIA - HITAM PUTIH) ====================
-- Taruh di bagian akhir script (sebelum print terakhir)

task.spawn(function()
    task.wait(2) -- Tunggu 2 detik setelah semua UI siap
    
    -- Buat ScreenGui
    local welcomeGui = Instance.new("ScreenGui")
    welcomeGui.Name = "PhoneWelcome"
    welcomeGui.ResetOnSpawn = false
    welcomeGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    welcomeGui.DisplayOrder = 9999
    
    pcall(function() welcomeGui.Parent = getGuiParent() end)
    if not welcomeGui.Parent then welcomeGui.Parent = game:GetService("CoreGui") end
    
    -- Background overlay (semi-transparan hitam)
    local overlay = Instance.new("Frame", welcomeGui)
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.ZIndex = 10000
    overlay.Active = true -- Menangkap semua input
    
    -- Card utama di tengah
    local card = Instance.new("Frame", overlay)
    card.Size = UDim2.new(0, 340, 0, 460)
    card.Position = UDim2.new(0.5, -170, 0.5, -230)
    card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    card.ZIndex = 10001
    corner(card, 16)
    stroke(card, Color3.fromRGB(0, 0, 0), 2.5, 0)
    
    -- ==================== HEADER ====================
    -- Garis hitam atas
    local topLine = Instance.new("Frame", card)
    topLine.Size = UDim2.new(1, 0, 0, 4)
    topLine.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    topLine.ZIndex = 10002
    
    -- Logo area
    local logoFrame = Instance.new("Frame", card)
    logoFrame.Size = UDim2.new(0, 70, 0, 70)
    logoFrame.Position = UDim2.new(0.5, -35, 0, 24)
    logoFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    logoFrame.ZIndex = 10002
    corner(logoFrame, 100)
    
    local logoText = Instance.new("TextLabel", logoFrame)
    logoText.Size = UDim2.new(1, 0, 1, 0)
    logoText.BackgroundTransparency = 1
    logoText.Text = "ID"
    logoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    logoText.Font = Enum.Font.GothamBlack
    logoText.TextSize = 26
    logoText.ZIndex = 10003
    
    -- Title
    local title = Instance.new("TextLabel", card)
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 100)
    title.BackgroundTransparency = 1
    title.Text = "Phone ID Viewer"
    title.TextColor3 = Color3.fromRGB(0, 0, 0)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 24
    title.ZIndex = 10002
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel", card)
    subtitle.Size = UDim2.new(1, -20, 0, 20)
    subtitle.Position = UDim2.new(0, 10, 0, 130)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Script Clone & ID Viewer"
    subtitle.TextColor3 = Color3.fromRGB(100, 100, 100)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 11
    subtitle.ZIndex = 10002
    
    -- Version & Author
    local versionText = Instance.new("TextLabel", card)
    versionText.Size = UDim2.new(1, -20, 0, 18)
    versionText.Position = UDim2.new(0, 10, 0, 152)
    versionText.BackgroundTransparency = 1
    versionText.Text = "v10.2  |  by alfread"
    versionText.TextColor3 = Color3.fromRGB(140, 140, 140)
    versionText.Font = Enum.Font.GothamBold
    versionText.TextSize = 10
    versionText.ZIndex = 10002
    
    -- ==================== DIVIDER ====================
    local divider1 = Instance.new("Frame", card)
    divider1.Size = UDim2.new(1, -40, 0, 2)
    divider1.Position = UDim2.new(0, 20, 0, 180)
    divider1.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    divider1.BackgroundTransparency = 0.85
    divider1.ZIndex = 10002
    
    -- ==================== PANDUAN PENGGUNAAN ====================
    local guideTitle = Instance.new("TextLabel", card)
    guideTitle.Size = UDim2.new(1, -40, 0, 22)
    guideTitle.Position = UDim2.new(0, 20, 0, 190)
    guideTitle.BackgroundTransparency = 1
    guideTitle.Text = "PANDUAN PENGGUNAAN"
    guideTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
    guideTitle.Font = Enum.Font.GothamBlack
    guideTitle.TextSize = 12
    guideTitle.TextXAlignment = Enum.TextXAlignment.Left
    guideTitle.ZIndex = 10002
    
    -- Instruksi
    local instructions = {
        {num = "1", text = "Tools ada di Backpack kamu", sub = "Cari tools 'Phone' lalu klik untuk equip"},
        {num = "2", text = "Beli command di map", sub = "Gunakan command 're', 'size', dan lainnya"},
        {num = "3", text = "Password default: 2006", sub = "Bisa diganti di Settings > Change Passcode"},
        {num = "4", text = "Pilih Player di aplikasi Players", sub = "Lalu lihat item, clone, atau outfit mereka"},
        {num = "5", text = "Simpan outfit untuk respawn", sub = "Di aplikasi Reset, pilih outfit & save"},
        {num = "6", text = "Gunakan aplikasi Commands", sub = "Untuk re, rejoin, sit, size, sync, dan FX"},
        {num = "7", text = "Favoritkan bundle & emote", sub = "Bundle untuk instant items, Emote untuk animasi"}
    }
    
    for i, instr in ipairs(instructions) do
        -- Nomor dalam lingkaran hitam
        local numCircle = Instance.new("Frame", card)
        numCircle.Size = UDim2.new(0, 24, 0, 24)
        numCircle.Position = UDim2.new(0, 18, 0, 218 + (i-1) * 32)
        numCircle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        numCircle.ZIndex = 10002
        corner(numCircle, 100)
        
        local numText = Instance.new("TextLabel", numCircle)
        numText.Size = UDim2.new(1, 0, 1, 0)
        numText.BackgroundTransparency = 1
        numText.Text = instr.num
        numText.TextColor3 = Color3.fromRGB(255, 255, 255)
        numText.Font = Enum.Font.GothamBlack
        numText.TextSize = 11
        numText.ZIndex = 10003
        
        -- Teks instruksi
        local instrText = Instance.new("TextLabel", card)
        instrText.Size = UDim2.new(1, -56, 0, 16)
        instrText.Position = UDim2.new(0, 50, 0, 216 + (i-1) * 32)
        instrText.BackgroundTransparency = 1
        instrText.Text = instr.text
        instrText.TextColor3 = Color3.fromRGB(0, 0, 0)
        instrText.Font = Enum.Font.GothamBold
        instrText.TextSize = 10
        instrText.TextXAlignment = Enum.TextXAlignment.Left
        instrText.ZIndex = 10002
        
        -- Sub teks
        local subText = Instance.new("TextLabel", card)
        subText.Size = UDim2.new(1, -56, 0, 14)
        subText.Position = UDim2.new(0, 50, 0, 232 + (i-1) * 32)
        subText.BackgroundTransparency = 1
        subText.Text = instr.sub
        subText.TextColor3 = Color3.fromRGB(140, 140, 140)
        subText.Font = Enum.Font.Gotham
        subText.TextSize = 8
        subText.TextXAlignment = Enum.TextXAlignment.Left
        subText.ZIndex = 10002
    end
    
    -- ==================== FOOTER ====================
    local divider2 = Instance.new("Frame", card)
    divider2.Size = UDim2.new(1, -40, 0, 2)
    divider2.Position = UDim2.new(0, 20, 0, 428)
    divider2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    divider2.BackgroundTransparency = 0.85
    divider2.ZIndex = 10002
    
    -- Tombol Konfirmasi
    local confirmBtn = Instance.new("TextButton", card)
    confirmBtn.Size = UDim2.new(1, -40, 0, 44)
    confirmBtn.Position = UDim2.new(0, 20, 1, -56)
    confirmBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    confirmBtn.Text = "MENGERTI & MULAI"
    confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmBtn.Font = Enum.Font.GothamBlack
    confirmBtn.TextSize = 14
    confirmBtn.AutoButtonColor = false
    confirmBtn.ZIndex = 10002
    corner(confirmBtn, 10)
    
    -- Hover effect
    confirmBtn.MouseEnter:Connect(function()
        tween(confirmBtn, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.15)
    end)
    confirmBtn.MouseLeave:Connect(function()
        tween(confirmBtn, {BackgroundColor3 = Color3.fromRGB(0, 0, 0)}, 0.15)
    end)
    
    -- Close function (HANYA via tombol ini)
    local function closeWelcome()
        -- Animasi fade out
        tween(card, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.3)
        tween(overlay, {BackgroundTransparency = 1}, 0.3)
        task.wait(0.3)
        welcomeGui:Destroy()
        
        -- Notifikasi kecil
        showDynamicNotification("Phone siap digunakan! Cek Backpack", Color3.fromRGB(0, 0, 0))
    end
    
    confirmBtn.MouseButton1Click:Connect(closeWelcome)
    
    -- Animasi masuk (scale dari kecil)
    card.Size = UDim2.new(0, 0, 0, 0)
    card.Position = UDim2.new(0.5, 0, 0.5, 0)
    tween(card, {Size = UDim2.new(0, 340, 0, 460)}, 0.4, Enum.EasingStyle.Back)
    card.Position = UDim2.new(0.5, -170, 0.5, -230)
    
    -- Mencegah klik di luar untuk menutup
    overlay.InputBegan:Connect(function(input)
        -- Tidak melakukan apa-apa! Hanya tombol konfirmasi yang bisa menutup
    end)
end)

-- ================= TELEGRAM NOTIFICATION =================
task.spawn(function()
    task.wait(5) -- Tunggu 5 detik setelah script load
    notifyTelegramNewUser()
end)

print("[Phone v10.1] Full code loaded – Favorites horizontal, status bar refined.")