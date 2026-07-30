--[[
    PHONE ID VIEWER v4.0 - AUTO-DOWNLOAD MODULAR
    Main.lua - Framework yang auto-download semua modul dari GitHub.
    Cukup upload file ini + folder Applications + folder Icons ke repo.
    Dibuat oleh: Alfread
    Repo: github.com/AlfreadRorw/CloneBunker
]]

-- ===================== KONFIGURASI =====================
local REPO_URL = "https://raw.githubusercontent.com/AlfreadRorw/CloneBunker/main/PhoneIDViewer"

-- ===================== SERVICES =====================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ===================== MODULE LOADER =====================
local moduleCache = {}

local function fetchModule(path)
    -- Cek cache dulu
    if moduleCache[path] then
        return moduleCache[path]
    end
    
    -- Coba download dari GitHub
    local url = REPO_URL .. "/" .. path
    local ok, result = pcall(function()
        local code = game:HttpGet(url)
        local fn, err = loadstring(code)
        if not fn then
            warn("[PhoneIDViewer] Gagal compile: " .. path .. " - " .. tostring(err))
            return nil
        end
        return fn()
    end)
    
    if ok and result then
        moduleCache[path] = result
        return result
    end
    
    warn("[PhoneIDViewer] Gagal fetch: " .. path)
    return nil
end

-- ===================== THEME =====================
local T = {
    BG = Color3.fromRGB(6,6,6),
    Card = Color3.fromRGB(18,18,18),
    Card2 = Color3.fromRGB(28,28,28),
    Accent = Color3.fromRGB(255,255,255),
    OnAccent = Color3.fromRGB(10,10,10),
    Green = Color3.fromRGB(150,220,170),
    Red = Color3.fromRGB(235,110,120),
    Gold = Color3.fromRGB(230,190,110),
    Text = Color3.fromRGB(248,248,248),
    Text2 = Color3.fromRGB(145,145,145),
    Border = Color3.fromRGB(50,50,50),
}

local THEME_PRESETS = {
    {Name="Putih", Accent=Color3.fromRGB(255,255,255), OnAccent=Color3.fromRGB(10,10,10)},
    {Name="Ungu", Accent=Color3.fromRGB(150,100,255), OnAccent=Color3.fromRGB(10,10,15)},
    {Name="Biru", Accent=Color3.fromRGB(90,190,255), OnAccent=Color3.fromRGB(8,15,20)},
    {Name="Merah", Accent=Color3.fromRGB(240,80,90), OnAccent=Color3.fromRGB(20,8,8)},
    {Name="Emas", Accent=Color3.fromRGB(230,190,100), OnAccent=Color3.fromRGB(20,15,5)},
    {Name="Hijau", Accent=Color3.fromRGB(120,230,150), OnAccent=Color3.fromRGB(8,15,10)},
}

-- ===================== UTILITY =====================
local function corner(obj, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 10); c.Parent = obj; return c
end
local function stroke(obj, c, t, tr)
    local s = Instance.new("UIStroke"); s.Color = c or T.Border; s.Thickness = t or 1
    s.Transparency = tr or 0; s.Parent = obj; return s
end
local function gradient(obj, seq, rot)
    local g = Instance.new("UIGradient"); g.Color = seq; g.Rotation = rot or 90; g.Parent = obj; return g
end
local function tween(obj, props, tm, style)
    TweenService:Create(obj, TweenInfo.new(tm or 0.25, style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end
local function pressFX(btn)
    local orig = btn.Size
    btn.MouseButton1Down:Connect(function()
        tween(btn, {Size=UDim2.new(orig.X.Scale*0.95, orig.X.Offset*0.95, orig.Y.Scale*0.92, orig.Y.Offset*0.92)}, 0.08)
    end)
    btn.MouseButton1Up:Connect(function() tween(btn, {Size=orig}, 0.15, Enum.EasingStyle.Back) end)
    btn.MouseLeave:Connect(function() tween(btn, {Size=orig}, 0.15, Enum.EasingStyle.Back) end)
end
local function copyToClipboard(text)
    pcall(function() setclipboard(text) end)
    pcall(function() toclipboard(text) end)
end

-- ===================== STORAGE =====================
local function saveJSON(filename, data)
    pcall(function() if writefile then writefile(filename, HttpService:JSONEncode(data)) end end)
end
local function loadJSON(filename)
    local d = {}
    pcall(function() if isfile and isfile(filename) then d = HttpService:JSONDecode(readfile(filename)) end end)
    return d
end

local PRESET_FILE = "PhoneIDViewer_Presets.json"
local FAV_FILE = "PhoneIDViewer_FavPlayers.json"
local SETTINGS_FILE = "PhoneIDViewer_Settings.json"

local presets = loadJSON(PRESET_FILE)
local favPlayerIds = loadJSON(FAV_FILE)
local favPlayerSet = {}
for _, id in ipairs(favPlayerIds) do favPlayerSet[tostring(id)] = true end
local function persistFav() saveJSON(FAV_FILE, favPlayerIds) end

local appSettings = loadJSON(SETTINGS_FILE)
if not appSettings.themeIndex then
    appSettings = {
        wallpaperUrl = "",
        widgetUrl = "",
        themeIndex = 1,
        glowEnabled = true,
    }
end
local function persistSettings() saveJSON(SETTINGS_FILE, appSettings) end

if appSettings.themeIndex and THEME_PRESETS[appSettings.themeIndex] then
    T.Accent = THEME_PRESETS[appSettings.themeIndex].Accent
    T.OnAccent = THEME_PRESETS[appSettings.themeIndex].OnAccent
end

-- ===================== CUSTOM ASSET =====================
local function getCustomAsset(path)
    local ok, result = pcall(function() return getcustomasset(path) end)
    if ok and result then return result end
    return nil
end

local function downloadAndCache(url, localPath)
    if isfile and isfile(localPath) then
        local cached = getCustomAsset(localPath)
        if cached then return cached end
    end
    local ok, data = pcall(function() return game:HttpGet(url) end)
    if not ok or not data then return nil end
    pcall(function() if writefile then writefile(localPath, data) end end)
    return getCustomAsset(localPath)
end

-- ===================== ITEM READER =====================
local ACCESSORY_ORDER = {Waist=1, Back=2, Front=3, Shoulders=4, Neck=5, FaceAccessory=6, Hair=7, Hat=8}

local function getItems(player)
    local char = player.Character; if not char then return {} end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return {} end
    local ok, desc = pcall(function() return hum:GetAppliedDescription() end)
    if not ok then return {} end
    local items = {}
    local bodies = {
        {"Head",desc.Head},{"Torso",desc.Torso},{"LeftArm",desc.LeftArm},{"RightArm",desc.RightArm},
        {"LeftLeg",desc.LeftLeg},{"RightLeg",desc.RightLeg},{"Shirt",desc.Shirt},{"Pants",desc.Pants},
        {"Face",desc.Face},{"GraphicTShirt",desc.GraphicTShirt},
    }
    for _,b in ipairs(bodies) do
        if b[2] and b[2]~="" and b[2]~="0" then
            table.insert(items, {Label=b[1], Value=tostring(b[2]), Type="BODY"})
        end
    end
    local ok2, accs = pcall(function() return desc:GetAccessories(true) end)
    if ok2 and accs then
        local srt = {}
        for _,a in ipairs(accs) do table.insert(srt, a) end
        table.sort(srt, function(a,b) return (ACCESSORY_ORDER[a.AccessoryType.Name] or 99) < (ACCESSORY_ORDER[b.AccessoryType.Name] or 99) end)
        for _,sa in ipairs(srt) do
            table.insert(items, {Label=sa.AccessoryType.Name, Value=tostring(sa.AssetId), Type="ACC"})
        end
    end
    return items
end

-- ===================== STATE =====================
local selectedTargetPlayer = nil

-- ===================== TOOL =====================
local function ensureTool()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if not bp then return nil end
    if bp:FindFirstChild("Phone") then return bp.Phone end
    local tool = Instance.new("Tool")
    tool.Name = "Phone"; tool.RequiresHandle = false
    tool.CanBeDropped = false; tool.TextureId = "rbxassetid://17382859935"
    tool.Parent = bp
    return tool
end

-- ===================== GUI ROOT =====================
local gui = Instance.new("ScreenGui")
gui.Name = "PhoneGUI"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true
gui.DisplayOrder = 998; gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = game:GetService("CoreGui")

local phone = Instance.new("Frame", gui)
phone.Size = UDim2.new(0,0,0,0); phone.Position = UDim2.new(0.5,0,0.52,0)
phone.AnchorPoint = Vector2.new(0.5,0.5); phone.BackgroundColor3 = T.BG
phone.BorderSizePixel = 0; phone.Visible = false; phone.ClipsDescendants = true
corner(phone, 38)
local phoneStroke = stroke(phone, T.Accent, 2, appSettings.glowEnabled and 0.5 or 0.15)
gradient(phone, ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(16,16,16)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(4,4,4)),
}, 100)

local PHONE_SIZE = UDim2.new(0,320,0,560)

local function updatePhoneLayout()
    local cam = workspace.CurrentCamera; if not cam then return end
    local vp = cam.ViewportSize; if vp.X<=0 then return end
    local land = vp.X > vp.Y
    if land then
        phone.AnchorPoint = Vector2.new(1,1); phone.Position = UDim2.new(1,-14,1,-14)
        PHONE_SIZE = UDim2.new(0,190,0,330)
    else
        phone.AnchorPoint = Vector2.new(0.5,0.5); phone.Position = UDim2.new(0.5,0,0.52,0)
        PHONE_SIZE = UDim2.new(0,320,0,560)
    end
end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updatePhoneLayout)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updatePhoneLayout)
    updatePhoneLayout()
end)
updatePhoneLayout()

-- Layar dalam
local screen = Instance.new("Frame", phone)
screen.Size = UDim2.new(1,-16,1,-16); screen.Position = UDim2.new(0,8,0,8)
screen.BackgroundColor3 = T.BG; screen.BorderSizePixel = 0; screen.ClipsDescendants = true
corner(screen, 30)

-- ===================== STATUS BAR =====================
local statusBar = Instance.new("Frame", screen)
statusBar.Size = UDim2.new(1,0,0,34); statusBar.BackgroundTransparency = 1

local clockLbl = Instance.new("TextLabel", statusBar)
clockLbl.Size = UDim2.new(0,110,1,0); clockLbl.Position = UDim2.new(0,16,0,0)
clockLbl.BackgroundTransparency = 1; clockLbl.Text = os.date("%H:%M").." WIB"
clockLbl.TextColor3 = T.Text; clockLbl.Font = Enum.Font.GothamBold; clockLbl.TextSize = 13
clockLbl.TextXAlignment = Enum.TextXAlignment.Left
task.spawn(function() while clockLbl.Parent do clockLbl.Text = os.date("%H:%M").." WIB"; task.wait(10) end end)

local sig = Instance.new("Frame", statusBar)
sig.Size = UDim2.new(0,24,0,10); sig.Position = UDim2.new(1,-60,0.5,-5); sig.BackgroundTransparency = 1
for i=1,4 do
    local b = Instance.new("Frame", sig); b.Size=UDim2.new(0,3,0,3+i*2)
    b.Position=UDim2.new(0,(i-1)*6,1,-(3+i*2)); b.BackgroundColor3=T.Text; corner(b,1)
end

local batt = Instance.new("Frame", statusBar)
batt.Size=UDim2.new(0,22,0,11); batt.Position=UDim2.new(1,-30,0.5,-5.5); batt.BackgroundTransparency=1
corner(batt,3); stroke(batt,T.Text,1,0)
local fill = Instance.new("Frame", batt); fill.Size=UDim2.new(0.8,0,1,-4)
fill.Position=UDim2.new(0,2,0,2); fill.BackgroundColor3=T.Text; corner(fill,2)
local tip = Instance.new("Frame", statusBar); tip.Size=UDim2.new(0,2,0,5)
tip.Position=UDim2.new(1,-8,0.5,-2.5); tip.BackgroundColor3=T.Text; corner(tip,1)

-- ===================== DYNAMIC ISLAND =====================
local island = Instance.new("Frame", screen)
island.Size = UDim2.new(0,90,0,24); island.Position = UDim2.new(0.5,-45,0,4)
island.BackgroundColor3 = Color3.new(0,0,0); island.ZIndex=40; corner(island,100)

local islandIndicator = Instance.new("Frame", island)
islandIndicator.Size = UDim2.new(0,8,0,8); islandIndicator.Position = UDim2.new(0,8,0.5,-4)
islandIndicator.BackgroundColor3 = Color3.fromRGB(40,40,45); islandIndicator.ZIndex=41
corner(islandIndicator, 100)

local islandLbl = Instance.new("TextLabel", island)
islandLbl.Size = UDim2.new(1,-24,1,0); islandLbl.Position = UDim2.new(0,20,0,0)
islandLbl.BackgroundTransparency=1; islandLbl.Text=""; islandLbl.TextColor3=Color3.new(1,1,1)
islandLbl.Font=Enum.Font.GothamBold; islandLbl.TextSize=12; islandLbl.TextXAlignment=Enum.TextXAlignment.Left
islandLbl.TextTruncate=Enum.TextTruncate.AtEnd; islandLbl.ZIndex=41

local islandBtn = Instance.new("TextButton", island)
islandBtn.Size=UDim2.new(1,0,1,0); islandBtn.BackgroundTransparency=1; islandBtn.Text=""; islandBtn.ZIndex=42

local islandBusy = 0
local function pulseIsland(text, isError)
    islandBusy = islandBusy + 1; local id = islandBusy
    islandLbl.Text = text
    islandIndicator.BackgroundColor3 = isError and T.Red or T.Green
    tween(island, {Size=UDim2.new(0,200,0,34), Position=UDim2.new(0.5,-100,0,2)}, 0.28, Enum.EasingStyle.Back)
    task.delay(2.0, function()
        if islandBusy==id then
            tween(island, {Size=UDim2.new(0,90,0,24), Position=UDim2.new(0.5,-45,0,4)}, 0.28)
            task.delay(0.28, function()
                if islandBusy==id then
                    islandLbl.Text = ""
                    islandIndicator.BackgroundColor3 = Color3.fromRGB(40,40,45)
                end
            end)
        end
    end)
end

-- ===================== NAVIGATION =====================
local screensHolder = Instance.new("Frame", screen)
screensHolder.Size = UDim2.new(1,0,1,-60); screensHolder.Position = UDim2.new(0,0,0,34)
screensHolder.BackgroundTransparency = 1; screensHolder.ClipsDescendants = true

local homeScreen = Instance.new("Frame", screensHolder)
homeScreen.Size = UDim2.new(1,0,1,0); homeScreen.BackgroundTransparency=1; homeScreen.ClipsDescendants=true

local wallpaperImg = Instance.new("ImageLabel", homeScreen)
wallpaperImg.Size=UDim2.new(1,0,1,0); wallpaperImg.BackgroundColor3=T.BG; wallpaperImg.Image=""
wallpaperImg.ScaleType=Enum.ScaleType.Crop; wallpaperImg.ZIndex=0

local function applyWallpaper()
    if appSettings.wallpaperUrl and appSettings.wallpaperUrl ~= "" then
        local asset = downloadAndCache(appSettings.wallpaperUrl, "PhoneIDViewer/wallpaper.png")
        if asset then wallpaperImg.Image = asset; wallpaperImg.BackgroundTransparency = 0
        else wallpaperImg.Image = "" end
    else wallpaperImg.Image = "" end
end
applyWallpaper()

local widget = Instance.new("Frame", homeScreen)
widget.Size = UDim2.new(1,-32,0,56); widget.Position = UDim2.new(0,16,0,16)
widget.BackgroundColor3 = Color3.fromRGB(0,0,0); widget.BackgroundTransparency = 0.35
corner(widget, 14); widget.ClipsDescendants = true

local widgetBg = Instance.new("ImageLabel", widget)
widgetBg.Size = UDim2.new(1,0,1,0); widgetBg.BackgroundTransparency=1; widgetBg.Image=""
widgetBg.ScaleType=Enum.ScaleType.Crop; widgetBg.ZIndex=0

local widgetTime = Instance.new("TextLabel", widget)
widgetTime.Size=UDim2.new(0.6,0,0,26); widgetTime.Position=UDim2.new(0,12,0,12)
widgetTime.BackgroundTransparency=1; widgetTime.Text=""; widgetTime.TextColor3=Color3.new(1,1,1)
widgetTime.Font=Enum.Font.GothamBlack; widgetTime.TextSize=22; widgetTime.TextXAlignment=Enum.TextXAlignment.Left
widgetTime.ZIndex=1

local widgetDate = Instance.new("TextLabel", widget)
widgetDate.Size=UDim2.new(0.6,0,0,14); widgetDate.Position=UDim2.new(0,12,0,38)
widgetDate.BackgroundTransparency=1; widgetDate.TextColor3=Color3.new(0.8,0.8,0.8)
widgetDate.Font=Enum.Font.Gotham; widgetDate.TextSize=10; widgetDate.TextXAlignment=Enum.TextXAlignment.Left
widgetDate.ZIndex=1

local function applyWidget()
    if appSettings.widgetUrl and appSettings.widgetUrl ~= "" then
        local asset = downloadAndCache(appSettings.widgetUrl, "PhoneIDViewer/widget.png")
        if asset then widgetBg.Image = asset; widgetBg.BackgroundTransparency = 0
        else widgetBg.Image = ""; widgetBg.BackgroundTransparency = 1 end
    else widgetBg.Image = ""; widgetBg.BackgroundTransparency = 1 end
end
applyWidget()

task.spawn(function()
    while widget.Parent do
        widgetTime.Text = os.date("%H:%M")
        widgetDate.Text = os.date("%A, %d %B %Y")
        task.wait(30)
    end
end)

local appScreen = Instance.new("Frame", screensHolder)
appScreen.Size = UDim2.new(1,0,1,0); appScreen.Position = UDim2.new(1,0,0,0)
appScreen.BackgroundTransparency=1; appScreen.ClipsDescendants=true

local appHeader = Instance.new("Frame", appScreen)
appHeader.Size = UDim2.new(1,-16,0,40); appHeader.Position = UDim2.new(0,8,0,0); appHeader.BackgroundTransparency=1

local backBtn = Instance.new("TextButton", appHeader)
backBtn.Size = UDim2.new(0,60,0,32); backBtn.Position=UDim2.new(0,0,0,4)
backBtn.BackgroundColor3 = T.Card; backBtn.Text = "< Back"; backBtn.TextColor3 = T.Text
backBtn.Font=Enum.Font.GothamBold; backBtn.TextSize=12; backBtn.AutoButtonColor=false
corner(backBtn,8); stroke(backBtn,T.Border,1,0.3); pressFX(backBtn)

local appTitle = Instance.new("TextLabel", appHeader)
appTitle.Size = UDim2.new(1,-140,0,32); appTitle.Position=UDim2.new(0,68,0,4)
appTitle.BackgroundTransparency=1; appTitle.TextColor3=T.Text; appTitle.Font=Enum.Font.GothamBlack
appTitle.TextSize=15; appTitle.TextXAlignment=Enum.TextXAlignment.Left

local appContent = Instance.new("ScrollingFrame", appScreen)
appContent.Size = UDim2.new(1,-16,1,-50); appContent.Position=UDim2.new(0,8,0,46)
appContent.BackgroundTransparency=1; appContent.ScrollBarThickness=3
appContent.ScrollBarImageColor3 = T.Accent
appContent.CanvasSize=UDim2.new(0,0,0,0); appContent.AutomaticCanvasSize=Enum.AutomaticSize.Y
Instance.new("UIListLayout", appContent).Padding = UDim.new(0,8)

local currentAppFunc = nil
local function clearApp()
    for _,v in ipairs(appContent:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end
end

local function goHome()
    tween(appScreen, {Position=UDim2.new(1,0,0,0)}, 0.28)
    tween(homeScreen, {Position=UDim2.new(0,0,0,0)}, 0.28)
end

backBtn.MouseButton1Click:Connect(goHome)
islandBtn.MouseButton1Click:Connect(function()
    if appScreen.Position.X.Scale == 0 then goHome() end
end)

local function openApp(title, appFunc)
    appTitle.Text = title
    clearApp()
    currentAppFunc = appFunc
    appFunc(appContent, shared)
    appScreen.Position = UDim2.new(1,0,0,0)
    tween(appScreen, {Position=UDim2.new(0,0,0,0)}, 0.28)
    tween(homeScreen, {Position=UDim2.new(-1,0,0,0)}, 0.28)
    pulseIsland(title)
end

local function refreshCurrentApp()
    if currentAppFunc then
        clearApp()
        currentAppFunc(appContent, shared)
    end
end

local homeIndicator = Instance.new("Frame", screen)
homeIndicator.Size = UDim2.new(0,90,0,4); homeIndicator.Position = UDim2.new(0.5,-45,1,-14)
homeIndicator.BackgroundColor3 = T.Text2; corner(homeIndicator, 100)

-- ===================== SHARED OBJECT =====================
local shared = {
    T = T,
    THEME_PRESETS = THEME_PRESETS,
    appSettings = appSettings,
    presets = presets,
    favPlayerSet = favPlayerSet,
    selectedTargetPlayer = selectedTargetPlayer,
    getItems = getItems,
    copyToClipboard = copyToClipboard,
    saveJSON = saveJSON,
    loadJSON = loadJSON,
    persistFav = persistFav,
    persistSettings = persistSettings,
    corner = corner,
    stroke = stroke,
    gradient = gradient,
    tween = tween,
    pressFX = pressFX,
    pulseIsland = pulseIsland,
    refreshCurrentApp = refreshCurrentApp,
    applyWallpaper = applyWallpaper,
    applyWidget = applyWidget,
    downloadAndCache = downloadAndCache,
}

-- ===================== LOAD MODULES DARI GITHUB =====================
local appModuleNames = {"Players", "Clone", "Body", "Accessories", "Preset", "Favorite", "Setting"}
local appModules = {}
local iconData = {}

-- Fetch semua aplikasi
for _, name in ipairs(appModuleNames) do
    local mod = fetchModule("Applications/" .. name .. ".lua")
    if mod and type(mod) == "function" then
        appModules[name] = mod
    end
end

-- Fetch semua icon
for _, name in ipairs(appModuleNames) do
    local mod = fetchModule("Icons/" .. name .. ".lua")
    if mod and type(mod) == "table" then
        iconData[name] = mod
    elseif mod and type(mod) == "function" then
        iconData[name] = {Builder = mod, Color = Color3.fromRGB(255,255,255)}
    end
end

-- ===================== BANGUN HOME SCREEN =====================
local appGrid = Instance.new("Frame", homeScreen)
appGrid.Size = UDim2.new(1,-16,1,-20); appGrid.Position = UDim2.new(0,8,0,8)
appGrid.BackgroundTransparency = 1

local appGridLayout = Instance.new("UIGridLayout", appGrid)
appGridLayout.CellSize = UDim2.new(0,82,0,96)
appGridLayout.CellPadding = UDim2.new(0,10,0,12)
appGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
appGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local i = 0
for _, name in ipairs(appModuleNames) do
    if appModules[name] then
        i = i + 1
        local icon = iconData[name]
        local color = icon and icon.Color or Color3.fromRGB(255,255,255)
        local builder = icon and (icon.Builder or icon) or nil
        
        local holder = Instance.new("Frame", appGrid)
        holder.Size = UDim2.new(0,82,0,96); holder.BackgroundTransparency = 1; holder.LayoutOrder = i
        
        local iconBtn = Instance.new("TextButton", holder)
        iconBtn.Size = UDim2.new(0,66,0,66); iconBtn.Position = UDim2.new(0.5,-33,0,0)
        iconBtn.BackgroundColor3 = color; iconBtn.Text = ""
        iconBtn.AutoButtonColor = false
        corner(iconBtn, 18)
        stroke(iconBtn, T.Border, 1, 0.4)
        pressFX(iconBtn)
        
        if builder then
            local ok, err = pcall(function() builder(iconBtn, Color3.new(1,1,1)) end)
            if not ok then
                local lbl = Instance.new("TextLabel", iconBtn)
                lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1
                lbl.Text = name:sub(1,1); lbl.TextColor3 = Color3.new(1,1,1)
                lbl.Font = Enum.Font.GothamBlack; lbl.TextSize = 28
            end
        else
            local lbl = Instance.new("TextLabel", iconBtn)
            lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1
            lbl.Text = name:sub(1,1); lbl.TextColor3 = Color3.new(1,1,1)
            lbl.Font = Enum.Font.GothamBlack; lbl.TextSize = 28
        end
        
        local label = Instance.new("TextLabel", holder)
        label.Size = UDim2.new(1,0,0,22); label.Position = UDim2.new(0,0,0,70)
        label.BackgroundTransparency = 1; label.Text = name
        label.TextColor3 = T.Text; label.Font = Enum.Font.Gotham; label.TextSize = 11
        label.TextWrapped = true
        
        local appFunc = appModules[name]
        iconBtn.MouseButton1Click:Connect(function()
            openApp(name, appFunc)
        end)
    end
end

-- ===================== DRAG =====================
do
    local dragging, dragStart, startPos
    statusBar.Active = true
    statusBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = phone.Position
        end
    end)
    statusBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            phone.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ===================== OPEN / CLOSE =====================
local function openPhone()
    phone.Visible = true
    phone.Size = UDim2.new(0,0,0,0)
    tween(phone, {Size=PHONE_SIZE}, 0.32, Enum.EasingStyle.Back)
    goHome()
end

local function closePhone()
    tween(phone, {Size=UDim2.new(0,0,0,0)}, 0.22)
    task.delay(0.22, function() phone.Visible = false end)
end

local phoneTool = ensureTool()
if phoneTool then
    phoneTool.Equipped:Connect(openPhone)
    phoneTool.Unequipped:Connect(closePhone)
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    ensureTool()
end)

print("[PhoneIDViewer v4.0] Auto-download ready. " .. i .. " aplikasi termuat.")