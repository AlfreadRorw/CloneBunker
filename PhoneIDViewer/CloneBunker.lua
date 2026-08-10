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

-- ================= MAP LOCK SYSTEM (MULTI-MAP) =================
-- Taruh di bagian paling atas script

local ALLOWED_PLACE_IDS = {
    133943904733338, -- Map 1
    7041939546,       -- Map 2
    -- Tambahkan Place ID lain di sini kalau perlu
}

-- Cek apakah Place ID saat ini diizinkan
local function isAllowed(placeId)
    for _, allowedId in ipairs(ALLOWED_PLACE_IDS) do
        if placeId == allowedId then
            return true
        end
    end
    return false
end

if not isAllowed(game.PlaceId) then
    local player = game.Players.LocalPlayer
    
    -- Notifikasi Roblox (atas kanan)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Phone ID Viewer",
            Text = "Script ini hanya untuk map tertentu!",
            Icon = "rbxassetid://0",
            Duration = 5
        })
    end)
    
    -- Chat message (jika game support chat)
    pcall(function()
        local chatRemote = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        if chatRemote then
            local sayMessage = chatRemote:FindFirstChild("SayMessageRequest")
            if sayMessage then
                sayMessage:FireServer("Phone ID Viewer: Script ini hanya untuk map tertentu!", "All")
            end
        end
    end)
    
    -- Tunggu sebentar
    task.wait(2)
    
    -- Kick player
    pcall(function()
        local allowedList = table.concat(ALLOWED_PLACE_IDS, ", ")
        player:Kick("Script ini hanya berjalan di Place ID: " .. allowedList .. "\nGunakan di map yang benar!")
    end)
    
    -- Hentikan script (jangan lanjut)
    return
end

print("[Phone ID Viewer] Map verified! Script loaded successfully.")

-- ================= FIREBASE CONFIG =================
local FIREBASE_URL = "https://phone-id-viewer-default-rtdb.asia-southeast1.firebasedatabase.app"
local FIREBASE_KEY = "AIzaSyCGYiMvdt8v4DP96dUny8xFDRD6w3T1c80"

-- ================= FIREBASE HELPERS =================
local function firebaseRequest(method, path, body)
    local url = FIREBASE_URL .. path .. ".json?auth=" .. FIREBASE_KEY
    local ok, result = pcall(function()
        if syn and syn.request then
            return syn.request({
                Url = url,
                Method = method,
                Headers = {["Content-Type"] = "application/json"},
                Body = body and HttpService:JSONEncode(body) or nil
            })
        elseif http_request then
            return http_request({
                Url = url,
                Method = method,
                Headers = {["Content-Type"] = "application/json"},
                Body = body and HttpService:JSONEncode(body) or nil
            })
        else
            return {Body = game:HttpGet(url)}
        end
    end)
    if ok and result and result.Body and result.Body ~= "" and result.Body ~= "null" then
        local dok, data = pcall(function() return HttpService:JSONDecode(result.Body) end)
        if dok then return data end
    end
    return nil
end

local function firebaseSet(path, data)
    firebaseRequest("PUT", path, data)
end

local function firebaseGet(path)
    return firebaseRequest("GET", path, nil)
end

local function firebaseDelete(path)
    firebaseRequest("DELETE", path, nil)
end

-- ================= DEV CHECK =================
local IS_DEV = (LocalPlayer.Name:lower() == "alfreadr0rw")

-- ================= PULL REQUEST SYSTEM =================
local PULL_CHECK_INTERVAL = 5

local function sendPullRequest(targetUserId, targetUsername)
    firebaseSet("/pull_requests/user_" .. tostring(targetUserId), {
        jobId       = game.JobId,
        placeId     = game.PlaceId,
        devName     = LocalPlayer.DisplayName,
        devUsername = LocalPlayer.Name,
        devUserId   = LocalPlayer.UserId,
        message     = "mengundang kamu ke servernya",
        timestamp   = os.time()
    })
end

local function sendPullResponse(devUserId, accepted, responderName)
    firebaseSet("/pull_responses/user_" .. tostring(devUserId), {
        accepted      = accepted,
        responderName = responderName,
        timestamp     = os.time()
    })
end

-- ================= CONFIG =================
local CONFIG = {
    TOOL_NAME = "Phone",
    PASSCODE = "2006",
    CLONE_BATCH_SIZE = 5,
    CLONE_DELAY = 6,
    REMOTE_PATH = "Remotes.Command.CommandEvent",
}

-- ================= TARGETS =================
local TARGETS = {
    -- Developer (Emas)
    {username = "AlfreadR0rw",        text = "DEV",    color = Color3.fromRGB(255, 200, 50)},

    -- Members (Biru)
    {username = "matchapii04",         text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "akbarfbrynn",         text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "BLAZEBUBz",           text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "LexxSugar7",          text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "Dap_Mahatir",         text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "Jv4n00X",             text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "Hx8shve3",            text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "Chinatsu0263",        text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "dimasbani_9",         text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "IronHuijsen",         text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "KooJagoo",            text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "rstuaj1",             text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "mouri01045",          text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "stevalone7",          text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "ziroadalahpokoknya",  text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "AlbernTheGreat7",     text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "SweetyCoconut3",      text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "neoo290904",          text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "pororo_iki",          text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "syahidhc",            text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "cyaa_floiyrine",      text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "DzyanV2",             text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "ManSpicy",            text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "Oruzukii",            text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "jeyocal",             text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "yellbubb",            text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "Xetan01",             text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "beychullo",            text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
    {username = "Grace_101253",            text = "MEMBER", color = Color3.fromRGB(80, 150, 255)},
}

-- ================= LAYOUT CONSTANTS =================
-- Semua posisi elemen dihitung dari titik referensi yang sama supaya gak numpuk / gak geser.

local BILLBOARD_SIZE   = UDim2.new(0, 90, 0, 90)
local STUDS_OFFSET      = Vector3.new(0, 6.5, 0)  -- naik dari 3.5 -> 6.5 biar jelas di atas kepala & nametag default
local PIN_SIZE          = 36
local TAIL_SIZE         = 16
local LABEL_WIDTH       = 76
local LABEL_HEIGHT      = 20

-- Urutan vertikal (dari atas billboard, Y = 0):
--   0                -> pin body top
--   PIN_SIZE - 8      -> tail top (overlap dikit ke body biar nyambung)
--   PIN_SIZE + 14     -> label top
local PIN_Y   = 0
local TAIL_Y  = PIN_SIZE - 8
local LABEL_Y = PIN_SIZE + 14

local BOUNCE_OFFSET = 5 -- seberapa tinggi pin "mantul" saat animasi

-- ================= INLINE HELPERS =================

local function addCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = instance
    return corner
end

local function addStroke(instance, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness or 1.5
    stroke.Transparency = transparency or 0
    stroke.Parent = instance
    return stroke
end

local function doTween(instance, props, duration)
    local info = TweenInfo.new(duration or 0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    TweenService:Create(instance, info, props):Play()
end

-- ================= FIND PLAYER =================

local function findTargetPlayer(target)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower() == target.username:lower() then
            return player
        end
    end
    return nil
end

-- ================= CREATE MAP PIN =================

local function createMapPin(player, target)
    if not player.Character then return end
    local char = player.Character
    local head = char:FindFirstChild("Head")
    if not head then return end

    -- Hapus lama jika ada
    local old = char:FindFirstChild("TeamMapPin")
    if old then old:Destroy() end

    -- BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "TeamMapPin"
    billboard.Size = BILLBOARD_SIZE
    billboard.StudsOffset = STUDS_OFFSET
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 2000
    billboard.LightInfluence = 0
    billboard.Parent = char

    -- ── PIN BODY (lingkaran atas) ──────────────────────────────────────────
    local pinBody = Instance.new("Frame")
    pinBody.Name = "PinBody"
    pinBody.Size = UDim2.new(0, PIN_SIZE, 0, PIN_SIZE)
    pinBody.Position = UDim2.new(0.5, -PIN_SIZE / 2, 0, PIN_Y)
    pinBody.BackgroundColor3 = target.color
    pinBody.BorderSizePixel = 0
    pinBody.ZIndex = 2
    pinBody.Parent = billboard
    addCorner(pinBody, 100)
    addStroke(pinBody, Color3.fromRGB(255, 255, 255), 2, 0)

    -- Dot putih di tengah lingkaran
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(0.5, -6, 0.5, -6)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.ZIndex = 3
    dot.Parent = pinBody
    addCorner(dot, 100)

    -- ── EKOR PIN (diamond ke bawah) ──────────────────────────────────────
    local tail = Instance.new("Frame")
    tail.Name = "PinTail"
    tail.Size = UDim2.new(0, TAIL_SIZE, 0, TAIL_SIZE)
    tail.Position = UDim2.new(0.5, -TAIL_SIZE / 2, 0, TAIL_Y)
    tail.BackgroundColor3 = target.color
    tail.BorderSizePixel = 0
    tail.Rotation = 45
    tail.ZIndex = 1
    tail.Parent = billboard

    -- ── LABEL NAMA/ROLE ───────────────────────────────────────────────────
    local labelBg = Instance.new("Frame")
    labelBg.Name = "LabelBg"
    labelBg.Size = UDim2.new(0, LABEL_WIDTH, 0, LABEL_HEIGHT)
    labelBg.Position = UDim2.new(0.5, -LABEL_WIDTH / 2, 0, LABEL_Y)
    labelBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    labelBg.BackgroundTransparency = 0.3
    labelBg.BorderSizePixel = 0
    labelBg.ZIndex = 4
    labelBg.Parent = billboard
    addCorner(labelBg, 6)
    addStroke(labelBg, target.color, 1.5, 0)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -6, 1, 0)
    label.Position = UDim2.new(0, 3, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = target.text
    label.TextColor3 = target.color
    label.Font = Enum.Font.GothamBold
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.ZIndex = 5
    label.Parent = labelBg

    -- ── ANIMASI BOUNCE PIN ────────────────────────────────────────────────
    -- Semua elemen ikut naik/turun bareng dengan jarak tetap, jadi gak ada yang "lepas" dari body pin.
    task.spawn(function()
        while billboard.Parent do
            doTween(pinBody, {Position = UDim2.new(0.5, -PIN_SIZE / 2, 0, PIN_Y - BOUNCE_OFFSET)}, 0.5)
            doTween(tail,    {Position = UDim2.new(0.5, -TAIL_SIZE / 2, 0, TAIL_Y - BOUNCE_OFFSET)}, 0.5)
            task.wait(0.5)
            doTween(pinBody, {Position = UDim2.new(0.5, -PIN_SIZE / 2, 0, PIN_Y)}, 0.5)
            doTween(tail,    {Position = UDim2.new(0.5, -TAIL_SIZE / 2, 0, TAIL_Y)}, 0.5)
            task.wait(0.5)
        end
    end)

    print("[TeamESP] Map pin created for: " .. player.Name .. " [" .. target.text .. "]")
end

-- ================= CLEANUP NON-TARGETS =================

local function cleanupPlayer(player)
    if player.Character then
        local pin = player.Character:FindFirstChild("TeamMapPin")
        if pin then pin:Destroy() end
    end
end

local function isTarget(player)
    for _, target in ipairs(TARGETS) do
        local tp = findTargetPlayer(target)
        if tp == player then return true, target end
    end
    return false, nil
end

-- ================= MAIN LOOP =================

task.spawn(function()
    task.wait(2)

    print("================================================")
    print("[TeamESP] Players in server:")
    for _, p in ipairs(Players:GetPlayers()) do
        print("  - " .. p.Name)
    end
    print("================================================")

    while true do
        task.wait(1.5)

        -- Tambah pin untuk target yang belum punya
        for _, target in ipairs(TARGETS) do
            local player = findTargetPlayer(target)
            if player and player.Character then
                if not player.Character:FindFirstChild("TeamMapPin") then
                    createMapPin(player, target)
                end
            end
        end

        -- Bersihkan pin dari non-target
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                local pin = player.Character:FindFirstChild("TeamMapPin")
                if pin then
                    local found, _ = isTarget(player)
                    if not found then pin:Destroy() end
                end
            end
        end
    end
end)

-- ================= HANDLE NEW PLAYERS =================

Players.PlayerAdded:Connect(function(player)
    for _, target in ipairs(TARGETS) do
        if player.Name:lower() == target.username:lower() then
            player.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                if char:FindFirstChild("Head") then
                    createMapPin(player, target)
                end
            end)
            if player.Character then
                task.wait(1)
                createMapPin(player, target)
            end
            break
        end
    end
end)

-- CharacterAdded untuk player yang sudah ada di server
for _, player in ipairs(Players:GetPlayers()) do
    for _, target in ipairs(TARGETS) do
        if player.Name:lower() == target.username:lower() then
            player.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                if char:FindFirstChild("Head") then
                    createMapPin(player, target)
                end
            end)
            break
        end
    end
end

print("[TeamESP] Ready! Monitoring " .. #TARGETS .. " members dengan Map Pin.")

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

-- ================= ONLINE TRACKER =================
local myFirebaseKey = "user_" .. tostring(LocalPlayer.UserId)

-- Ganti goOnline yang lama dengan ini
local function goOnline()
    local placeName = "Unknown"
    pcall(function()
        placeName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)
-- Jadi ini:
local isDev = (LocalPlayer.Name:lower() == "alfreadr0rw")
    
    firebaseSet("/online_players/" .. myFirebaseKey, {
        username    = LocalPlayer.Name,
        displayName = LocalPlayer.DisplayName,
        userId      = LocalPlayer.UserId,
        jobId       = game.JobId,
        placeId     = game.PlaceId,
        placeName   = placeName,
        timestamp   = os.time(),
        online      = true,
        isDev       = isDev  -- <-- tambahan
    })
end

local function goOffline()
    firebaseDelete("/online_players/" .. myFirebaseKey)
end

local function keepAlive()
    while true do
        task.wait(30)
        pcall(goOnline) -- update timestamp tiap 30 detik
    end
end

-- Jalankan
task.spawn(function()
    task.wait(3)
    pcall(goOnline)
    task.spawn(keepAlive)
end)

-- Cleanup saat karakter respawn / disconnect
LocalPlayer.CharacterRemoving:Connect(function()
    pcall(goOnline) -- tetap online, bukan offline
end)

game:GetService("Players").LocalPlayer.AncestryChanged:Connect(function()
    pcall(goOffline)
end)


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

-- ================= GUI ROOT =================
-- ==================== GUI ROOT ====================
local gui = Instance.new("ScreenGui")
gui.Name = "PhoneGUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 998
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local function getGuiParent()
    local ok, r = pcall(function()
        if gethui then return gethui() end
        if syn and syn.protect_gui then
            local sg = Instance.new("ScreenGui")
            syn.protect_gui(sg)
            sg.Parent = game:GetService("CoreGui")
            return sg
        end
        return game:GetService("CoreGui")
    end)
    return ok and r or game:GetService("CoreGui")
end
gui.Parent = getGuiParent()

-- ==================== PHONE FRAME ====================
local phone = Instance.new("Frame", gui)
phone.Size = UDim2.new(0, 0, 0, 0)
phone.Position = UDim2.new(0.5, 0, 0.52, 0)
phone.AnchorPoint = Vector2.new(0.5, 0.5)
phone.BackgroundColor3 = appSettings.bgColor or T.BG
phone.BorderSizePixel = 0
phone.Visible = false
phone.ClipsDescendants = true
corner(phone, 38)
phone.BackgroundTransparency = 1 - (appSettings.phoneOpacity or 1)

local phoneStroke = stroke(phone, T.Accent, 2, appSettings.glowEnabled and 0.5 or 0.15)
if appSettings.bgGradient then
    gradient(phone, ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(250, 250, 250)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 230, 230))
    }, 100)
end

-- ==================== ORIENTASI ====================
local PHONE_SIZE_PORTRAIT = UDim2.new(0, 320, 0, 560)
local PHONE_SIZE = PHONE_SIZE_PORTRAIT
local isLandscapeMode = false

local function applyPhoneOrientationSize()
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    if vp.X <= 0 or vp.Y <= 0 then return end
    
    local landscape = vp.X > vp.Y
    
    if landscape then
        local phoneWidth = math.floor(vp.X * 0.55)
        local phoneHeight = math.floor(vp.Y * 0.75)
        if phoneWidth > phoneHeight * 1.7 then phoneWidth = math.floor(phoneHeight * 1.7) end
        if phoneWidth < 250 then phoneWidth = 250 end
        if phoneHeight < 140 then phoneHeight = 140 end
        
        PHONE_SIZE = UDim2.new(0, phoneWidth, 0, phoneHeight)
        phone.Position = UDim2.new(0.5, 0, 0.5, 0)
        isLandscapeMode = true
    else
        PHONE_SIZE = PHONE_SIZE_PORTRAIT
        phone.Position = UDim2.new(0.5, 0, 0.52, 0)
        isLandscapeMode = false
    end
    
    -- Update screen area & home screen
    updateScreenAreaForOrientation()
    updateHomeForOrientation()
    
    if phone.Visible then
        tween(phone, {Size = PHONE_SIZE, Position = phone.Position}, 0.3, Enum.EasingStyle.Quart)
    end
end

local function isPortrait()
    local cam = Workspace.CurrentCamera
    if not cam then return true end
    return cam.ViewportSize.Y >= cam.ViewportSize.X
end

local function getGridIconSize()
    if isPortrait() then
        return UDim2.new(0, 72, 0, 86)
    else
        return UDim2.new(0, 68, 0, 78)
    end
end

-- ==================== SCREEN AREA ====================
local sa = Instance.new("Frame", phone)
sa.Size = UDim2.new(1, -16, 1, -16)
sa.Position = UDim2.new(0, 8, 0, 8)
sa.BackgroundColor3 = T.BG
sa.BorderSizePixel = 0
sa.ClipsDescendants = true
corner(sa, 30)

local sb = Instance.new("Frame", sa)
sb.Size = UDim2.new(1, 0, 0, 34)
sb.BackgroundTransparency = 1
sb.ZIndex = 100

local clockLbl = Instance.new("TextLabel", sb)
clockLbl.Size = UDim2.new(0, 80, 1, 0)
clockLbl.Position = UDim2.new(0, 14, 0, 0)
clockLbl.BackgroundTransparency = 1
clockLbl.Text = os.date("%H:%M")
clockLbl.TextColor3 = T.Text
clockLbl.Font = Enum.Font.GothamBold
clockLbl.TextSize = 13
clockLbl.TextXAlignment = Enum.TextXAlignment.Left

task.spawn(function()
    while clockLbl.Parent do
        clockLbl.Text = os.date("%H:%M")
        task.wait(30)
    end
end)
-- Signal bars di status bar tablet
local sbSignal = Instance.new("Frame", sb)
sbSignal.Size = UDim2.new(0, 20, 0, 14)
sbSignal.Position = UDim2.new(1, -80, 0.5, -7)
sbSignal.BackgroundTransparency = 1
sbSignal.ZIndex = 102

for i = 1, 4 do
    local bar = Instance.new("Frame", sbSignal)
    bar.Size = UDim2.new(0, 3, 0, 3 + i * 2)
    bar.Position = UDim2.new(0, (i-1) * 5, 1, 0)
    bar.AnchorPoint = Vector2.new(0, 1)
    bar.BackgroundColor3 = T.Text
    bar.BorderSizePixel = 0
    bar.ZIndex = 103
    corner(bar, 1)
end

-- Battery di status bar tablet
local sbBatFrame = Instance.new("Frame", sb)
sbBatFrame.Size = UDim2.new(0, 26, 0, 14)
sbBatFrame.Position = UDim2.new(1, -50, 0.5, -7)
sbBatFrame.BackgroundTransparency = 1
sbBatFrame.ZIndex = 102

local sbBatBody = Instance.new("Frame", sbBatFrame)
sbBatBody.Size = UDim2.new(0, 20, 0, 12)
sbBatBody.Position = UDim2.new(0, 0, 0.5, -6)
sbBatBody.BackgroundColor3 = T.Text
sbBatBody.BackgroundTransparency = 0.85
sbBatBody.BorderSizePixel = 0
sbBatBody.ZIndex = 103
corner(sbBatBody, 3)
stroke(sbBatBody, T.Text, 1, 0.3)

local sbBatFill = Instance.new("Frame", sbBatBody)
sbBatFill.Size = UDim2.new(0.75, -2, 1, -4)
sbBatFill.Position = UDim2.new(0, 1, 0, 2)
sbBatFill.BackgroundColor3 = T.Text
sbBatFill.BorderSizePixel = 0
sbBatFill.ZIndex = 104
corner(sbBatFill, 2)

local sbBatTip = Instance.new("Frame", sbBatFrame)
sbBatTip.Size = UDim2.new(0, 3, 0, 5)
sbBatTip.Position = UDim2.new(0, 21, 0.5, -2)
sbBatTip.BackgroundColor3 = T.Text
sbBatTip.BackgroundTransparency = 0.5
sbBatTip.BorderSizePixel = 0
sbBatTip.ZIndex = 103
corner(sbBatTip, 1)

-- Dynamic Island
local di = Instance.new("Frame", sa)
di.Size = UDim2.new(0, 90, 0, 24)
di.Position = UDim2.new(0.5, -45, 0, 4)
di.BackgroundColor3 = Color3.new(0, 0, 0)
di.ZIndex = 110
corner(di, 100)

local diStroke = stroke(di, Color3.new(1, 1, 1), 1.5, 0.6)
local dil = Instance.new("TextLabel", di)
dil.Size = UDim2.new(1, -8, 1, 0)
dil.Position = UDim2.new(0, 4, 0, 0)
dil.BackgroundTransparency = 1
dil.Text = ""
dil.TextColor3 = Color3.new(1, 1, 1)
dil.Font = Enum.Font.GothamBold
dil.TextSize = 14
dil.TextXAlignment = Enum.TextXAlignment.Center
dil.ZIndex = 111

local dib = Instance.new("TextButton", di)
dib.Size = UDim2.new(1, 0, 1, 0)
dib.BackgroundTransparency = 1
dib.Text = ""
dib.ZIndex = 42

local bunkerBarLbl = Instance.new("TextLabel", sa)
bunkerBarLbl.Size = UDim2.new(1, 0, 0, 14)
bunkerBarLbl.Position = UDim2.new(0, 0, 0, 30)
bunkerBarLbl.BackgroundTransparency = 1
bunkerBarLbl.Text = "The Bunker"
bunkerBarLbl.TextColor3 = Color3.fromRGB(140, 140, 140)
bunkerBarLbl.Font = Enum.Font.Gotham
bunkerBarLbl.TextSize = 9
bunkerBarLbl.TextXAlignment = Enum.TextXAlignment.Center
bunkerBarLbl.ZIndex = 101

-- ==================== UPDATE SCREEN AREA UNTUK LANDSCAPE ====================
local function updateScreenAreaForOrientation()
    local portrait = isPortrait()
    
    if portrait then
        sa.Size = UDim2.new(1, -16, 1, -16)
        sa.Position = UDim2.new(0, 8, 0, 8)
        corner(sa, 30)
        
        sb.Size = UDim2.new(1, 0, 0, 34)
        clockLbl.Size = UDim2.new(0, 80, 1, 0)
        clockLbl.Position = UDim2.new(0, 14, 0, 0)
        clockLbl.TextSize = 13
        
        di.Size = UDim2.new(0, 90, 0, 24)
        di.Position = UDim2.new(0.5, -45, 0, 4)
        bunkerBarLbl.Position = UDim2.new(0, 0, 0, 30)
        bunkerBarLbl.TextSize = 9
    else
        local padding = math.floor(PHONE_SIZE.X.Offset * 0.025)
        sa.Size = UDim2.new(1, -padding*2, 1, -padding*2)
        sa.Position = UDim2.new(0, padding, 0, padding)
        corner(sa, math.floor(PHONE_SIZE.X.Offset * 0.05))
        
        sb.Size = UDim2.new(1, 0, 0, 24)
        clockLbl.Size = UDim2.new(0, 50, 1, 0)
        clockLbl.Position = UDim2.new(0, 8, 0, 0)
        clockLbl.TextSize = 10
        
        local diW = math.floor(PHONE_SIZE.X.Offset * 0.18)
        di.Size = UDim2.new(0, diW, 0, math.floor(PHONE_SIZE.Y.Offset * 0.045))
        di.Position = UDim2.new(0.5, -diW/2, 0, padding)
        bunkerBarLbl.Position = UDim2.new(0, 0, 0, 20)
        bunkerBarLbl.TextSize = 7
    end
end

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

-- ================= PULL NOTIFICATION POPUP =================
local activePullNotif = nil

local function showPullNotification(devName, jobId, placeId, message, devUserId)
    if activePullNotif then
        pcall(function() activePullNotif:Destroy() end)
        activePullNotif = nil
    end

    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = "PullNotifGui"
    notifGui.ResetOnSpawn = false
    notifGui.IgnoreGuiInset = true
    notifGui.DisplayOrder = 9999
    notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    pcall(function() notifGui.Parent = game:GetService("CoreGui") end)
    if not notifGui.Parent then
        notifGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    activePullNotif = notifGui

    -- Backdrop
    local backdrop = Instance.new("Frame", notifGui)
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backdrop.BackgroundTransparency = 0.5
    backdrop.BorderSizePixel = 0
    backdrop.ZIndex = 9998

    -- Card
    local card = Instance.new("Frame", notifGui)
    card.Size = UDim2.new(0, 0, 0, 0)
    card.Position = UDim2.new(0.5, 0, 0.5, 0)
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    card.BorderSizePixel = 0
    card.ZIndex = 9999
    corner(card, 20)
    stroke(card, Color3.fromRGB(0, 220, 100), 2, 0)

    tween(card, {Size = UDim2.new(0, 280, 0, 210)}, 0.35, Enum.EasingStyle.Back)

    local cardGrad = Instance.new("UIGradient", card)
    cardGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 28, 42)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 16, 26))
    })
    cardGrad.Rotation = 135

    -- Glow line
    local glowLine = Instance.new("Frame", card)
    glowLine.Size = UDim2.new(1, 0, 0, 2)
    glowLine.BackgroundColor3 = Color3.fromRGB(0, 220, 100)
    glowLine.BorderSizePixel = 0
    glowLine.ZIndex = 10000
    corner(glowLine, 1)

    -- Avatar dev
    local devAvatarFrame = Instance.new("Frame", card)
    devAvatarFrame.Size = UDim2.new(0, 52, 0, 52)
    devAvatarFrame.Position = UDim2.new(0.5, -26, 0, 18)
    devAvatarFrame.BackgroundColor3 = Color3.fromRGB(0, 220, 100)
    devAvatarFrame.BackgroundTransparency = 0.8
    devAvatarFrame.ZIndex = 10000
    corner(devAvatarFrame, 100)
    stroke(devAvatarFrame, Color3.fromRGB(0, 220, 100), 2, 0.3)

    local devAvatar = Instance.new("ImageLabel", devAvatarFrame)
    devAvatar.Size = UDim2.new(0, 44, 0, 44)
    devAvatar.Position = UDim2.new(0.5, -22, 0.5, -22)
    devAvatar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    devAvatar.Image = devUserId and ("https://www.roblox.com/headshot-thumbnail/image?userId=" .. devUserId .. "&width=100&height=100&format=png") or ""
    devAvatar.ZIndex = 10001
    corner(devAvatar, 100)

    -- Badge DEV
    local devBadge = Instance.new("Frame", card)
    devBadge.Size = UDim2.new(0, 36, 0, 14)
    devBadge.Position = UDim2.new(0.5, -18, 0, 66)
    devBadge.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    devBadge.BackgroundTransparency = 0.2
    devBadge.ZIndex = 10000
    corner(devBadge, 7)

    local devBadgeText = Instance.new("TextLabel", devBadge)
    devBadgeText.Size = UDim2.new(1, 0, 1, 0)
    devBadgeText.BackgroundTransparency = 1
    devBadgeText.Text = "DEV"
    devBadgeText.TextColor3 = Color3.fromRGB(255, 220, 80)
    devBadgeText.Font = Enum.Font.GothamBlack
    devBadgeText.TextSize = 8
    devBadgeText.ZIndex = 10001

    -- Title
    local titleLbl = Instance.new("TextLabel", card)
    titleLbl.Size = UDim2.new(1, -24, 0, 22)
    titleLbl.Position = UDim2.new(0, 12, 0, 84)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = devName .. " mengundangmu!"
    titleLbl.TextColor3 = Color3.new(1, 1, 1)
    titleLbl.Font = Enum.Font.GothamBlack
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Center
    titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
    titleLbl.ZIndex = 10000

    -- Message
    local msgLbl = Instance.new("TextLabel", card)
    msgLbl.Size = UDim2.new(1, -24, 0, 28)
    msgLbl.Position = UDim2.new(0, 12, 0, 108)
    msgLbl.BackgroundTransparency = 1
    msgLbl.Text = message
    msgLbl.TextColor3 = Color3.fromRGB(160, 160, 185)
    msgLbl.Font = Enum.Font.Gotham
    msgLbl.TextSize = 10
    msgLbl.TextXAlignment = Enum.TextXAlignment.Center
    msgLbl.TextWrapped = true
    msgLbl.ZIndex = 10000

    -- Timer bar
    local timerBg = Instance.new("Frame", card)
    timerBg.Size = UDim2.new(1, -24, 0, 3)
    timerBg.Position = UDim2.new(0, 12, 0, 138)
    timerBg.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    timerBg.BorderSizePixel = 0
    timerBg.ZIndex = 10000
    corner(timerBg, 2)

    local timerFill = Instance.new("Frame", timerBg)
    timerFill.Size = UDim2.new(1, 0, 1, 0)
    timerFill.BackgroundColor3 = Color3.fromRGB(0, 220, 100)
    timerFill.BorderSizePixel = 0
    timerFill.ZIndex = 10001
    corner(timerFill, 2)

    -- Countdown label
    local countdownLbl = Instance.new("TextLabel", card)
    countdownLbl.Size = UDim2.new(1, -24, 0, 12)
    countdownLbl.Position = UDim2.new(0, 12, 0, 143)
    countdownLbl.BackgroundTransparency = 1
    countdownLbl.Text = "Auto decline dalam 30s"
    countdownLbl.TextColor3 = Color3.fromRGB(120, 120, 140)
    countdownLbl.Font = Enum.Font.Gotham
    countdownLbl.TextSize = 7
    countdownLbl.TextXAlignment = Enum.TextXAlignment.Center
    countdownLbl.ZIndex = 10000

    -- Accept button
    local acceptBtn = Instance.new("TextButton", card)
    acceptBtn.Size = UDim2.new(0, 110, 0, 34)
    acceptBtn.Position = UDim2.new(0, 14, 0, 160)
    acceptBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
    acceptBtn.Text = "✓ Join Server"
    acceptBtn.TextColor3 = Color3.new(1, 1, 1)
    acceptBtn.Font = Enum.Font.GothamBlack
    acceptBtn.TextSize = 11
    acceptBtn.AutoButtonColor = false
    acceptBtn.ZIndex = 10000
    corner(acceptBtn, 10)

    -- Pulse effect accept button
    task.spawn(function()
        while acceptBtn and acceptBtn.Parent do
            tween(acceptBtn, {BackgroundColor3 = Color3.fromRGB(0, 230, 100)}, 0.6)
            task.wait(0.6)
            tween(acceptBtn, {BackgroundColor3 = Color3.fromRGB(0, 180, 70)}, 0.6)
            task.wait(0.6)
        end
    end)

    -- Decline button
    local declineBtn = Instance.new("TextButton", card)
    declineBtn.Size = UDim2.new(0, 110, 0, 34)
    declineBtn.Position = UDim2.new(1, -124, 0, 160)
    declineBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    declineBtn.Text = "✗ Decline"
    declineBtn.TextColor3 = Color3.fromRGB(200, 100, 100)
    declineBtn.Font = Enum.Font.GothamBlack
    declineBtn.TextSize = 11
    declineBtn.AutoButtonColor = false
    declineBtn.ZIndex = 10000
    corner(declineBtn, 10)
    stroke(declineBtn, Color3.fromRGB(200, 80, 80), 1, 0.5)

    -- Countdown timer
    local timeLeft = 30
    local timerRunning = true

    task.spawn(function()
        while timerRunning and timeLeft > 0 do
            task.wait(1)
            timeLeft = timeLeft - 1
            if countdownLbl and countdownLbl.Parent then
                countdownLbl.Text = "Auto decline dalam " .. timeLeft .. "s"
            end
            tween(timerFill, {Size = UDim2.new(timeLeft / 30, 0, 1, 0)}, 1)
            if timeLeft <= 10 then
                timerFill.BackgroundColor3 = Color3.fromRGB(255, 100, 50)
                if countdownLbl and countdownLbl.Parent then
                    countdownLbl.TextColor3 = Color3.fromRGB(255, 100, 50)
                end
            end
        end
        if timerRunning then
            timerRunning = false
            pcall(function() sendPullResponse(devUserId, false, LocalPlayer.DisplayName .. " (timeout)") end)
            tween(card, {Size = UDim2.new(0, 0, 0, 0)}, 0.25)
            task.wait(0.3)
            pcall(function() notifGui:Destroy() end)
            activePullNotif = nil
        end
    end)

    -- Accept action
    acceptBtn.MouseButton1Click:Connect(function()
        timerRunning = false
        acceptBtn.Text = "Joining..."
        acceptBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
        declineBtn.Visible = false
        pcall(function() sendPullResponse(devUserId, true, LocalPlayer.DisplayName) end)
        task.wait(0.5)
        pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, jobId)
        end)
        task.wait(1.5)
        tween(card, {Size = UDim2.new(0, 0, 0, 0)}, 0.25)
        task.wait(0.3)
        pcall(function() notifGui:Destroy() end)
        activePullNotif = nil
    end)

    -- Decline action
    declineBtn.MouseButton1Click:Connect(function()
        timerRunning = false
        pcall(function() sendPullResponse(devUserId, false, LocalPlayer.DisplayName) end)
        tween(backdrop, {BackgroundTransparency = 1}, 0.2)
        tween(card, {Size = UDim2.new(0, 0, 0, 0)}, 0.25)
        task.wait(0.3)
        pcall(function() notifGui:Destroy() end)
        activePullNotif = nil
        showDynamicNotification("Invitation declined", Color3.fromRGB(200, 80, 80))
    end)
end

-- ================= PULL REQUEST CHECKER =================
local function checkPullRequest()
    while true do
        task.wait(PULL_CHECK_INTERVAL)
        local pullData = firebaseGet("/pull_requests/user_" .. tostring(LocalPlayer.UserId))
        if pullData and type(pullData) == "table" and pullData.jobId then
            firebaseDelete("/pull_requests/user_" .. tostring(LocalPlayer.UserId))
            if pullData.jobId ~= game.JobId then
                showPullNotification(
                    pullData.devName or "Developer",
                    pullData.jobId,
                    pullData.placeId or game.PlaceId,
                    pullData.message or "mengundang kamu ke servernya",
                    pullData.devUserId
                )
            end
        end
    end
end

-- ================= PULL RESPONSE CHECKER (DEV ONLY) =================
local function checkPullResponse()
    while true do
        task.wait(PULL_CHECK_INTERVAL)
        if not IS_DEV then break end
        local respData = firebaseGet("/pull_responses/user_" .. tostring(LocalPlayer.UserId))
        if respData and type(respData) == "table" and respData.responderName then
            firebaseDelete("/pull_responses/user_" .. tostring(LocalPlayer.UserId))
            if respData.accepted then
                showDynamicNotification(respData.responderName .. " accepted! ✅", Color3.fromRGB(0, 200, 80))
            else
                showDynamicNotification(respData.responderName .. " declined ❌", Color3.fromRGB(200, 60, 60))
            end
        end
    end
end

-- ================= ONLINE TRACKER =================
local myFirebaseKey = "user_" .. tostring(LocalPlayer.UserId)

local function goOnline()
    local placeName = "Unknown"
    pcall(function()
        placeName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)
    firebaseSet("/online_players/" .. myFirebaseKey, {
        username    = LocalPlayer.Name,
        displayName = LocalPlayer.DisplayName,
        userId      = LocalPlayer.UserId,
        jobId       = game.JobId,
        placeId     = game.PlaceId,
        placeName   = placeName,
        timestamp   = os.time(),
        online      = true,
        isDev       = IS_DEV
    })
end

local function goOffline()
    firebaseDelete("/online_players/" .. myFirebaseKey)
end

local function keepAlive()
    while true do
        task.wait(30)
        pcall(goOnline)
    end
end

-- Jalankan semua tracker
task.spawn(function()
    task.wait(3)
    pcall(goOnline)
    task.spawn(keepAlive)
    task.spawn(checkPullRequest)
    if IS_DEV then
        task.spawn(checkPullResponse)
    end
end)

game:GetService("Players").LocalPlayer.AncestryChanged:Connect(function()
    pcall(goOffline)
end)

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

-- ==================== HOME SCREEN ====================
local sh = Instance.new("Frame", sa)
sh.Size = UDim2.new(1, 0, 1, -60)
sh.Position = UDim2.new(0, 0, 0, 34)
sh.BackgroundTransparency = 1
sh.ClipsDescendants = true

local home = Instance.new("Frame", sh)
home.Size = UDim2.new(1, 0, 1, 0)
home.BackgroundTransparency = 1
home.ClipsDescendants = true

local homeWall = Instance.new("Frame", home)
homeWall.Size = UDim2.new(1, 0, 1, 0)
homeWall.BackgroundColor3 = appSettings.bgColor or Color3.fromRGB(240, 240, 250)
homeWall.ZIndex = 0
corner(homeWall, 30)
if appSettings.bgGradient then
    gradient(homeWall, ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 220, 240)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(250, 250, 255))
    }, 135)
end

-- Dock
local dockArea = Instance.new("Frame", home)
dockArea.Size = UDim2.new(0, 224, 0, 64)
dockArea.Position = UDim2.new(0.5, -112, 1, -84)
dockArea.BackgroundTransparency = 1
dockArea.ZIndex = 5

local dockBg = Instance.new("Frame", dockArea)
dockBg.Size = UDim2.new(1, 0, 0, 56)
dockBg.Position = UDim2.new(0, 0, 0, 4)
dockBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
dockBg.BackgroundTransparency = 0.1
corner(dockBg, 20)

local dockGrid = Instance.new("UIGridLayout", dockBg)
dockGrid.CellSize = UDim2.new(0, 70, 0, 50)
dockGrid.CellPadding = UDim2.new(0, 2, 0, 0)
dockGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
dockGrid.VerticalAlignment = Enum.VerticalAlignment.Center
dockGrid.FillDirection = Enum.FillDirection.Horizontal

-- App Grid
local appGrid = Instance.new("ScrollingFrame", home)
appGrid.Size = UDim2.new(1, -16, 1, -156)
appGrid.Position = UDim2.new(0, 8, 0, 70)
appGrid.BackgroundTransparency = 1
appGrid.ScrollBarThickness = 3
appGrid.ScrollBarImageColor3 = T.Accent
appGrid.CanvasSize = UDim2.new(0, 0, 0, 0)
appGrid.AutomaticCanvasSize = Enum.AutomaticSize.Y
appGrid.BorderSizePixel = 0

local gridLayout = Instance.new("UIGridLayout", appGrid)
gridLayout.CellSize = getGridIconSize()
gridLayout.CellPadding = UDim2.new(0, 10, 0, 12)
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
gridLayout.VerticalAlignment = Enum.VerticalAlignment.Top

-- Bunker text
local bunkerHome = Instance.new("TextLabel", home)
bunkerHome.Size = UDim2.new(0, 200, 0, 14)
bunkerHome.Position = UDim2.new(0.5, -100, 1, -20)
bunkerHome.BackgroundTransparency = 1
bunkerHome.Text = "The Bunker"
bunkerHome.TextColor3 = Color3.fromRGB(180, 180, 200)
bunkerHome.Font = Enum.Font.Gotham
bunkerHome.TextSize = 10
bunkerHome.TextXAlignment = Enum.TextXAlignment.Center
bunkerHome.ZIndex = 10

-- ==================== UPDATE HOME UNTUK LANDSCAPE ====================
local function updateHomeForOrientation()
    local portrait = isPortrait()
    
    if portrait then
        sh.Size = UDim2.new(1, 0, 1, -60)
        sh.Position = UDim2.new(0, 0, 0, 34)
        
        appGrid.Size = UDim2.new(1, -16, 1, -156)
        appGrid.Position = UDim2.new(0, 8, 0, 70)
        gridLayout.CellPadding = UDim2.new(0, 8, 0, 16)
        
        dockArea.Size = UDim2.new(0, 224, 0, 64)
        dockArea.Position = UDim2.new(0.5, -112, 1, -84)
        dockBg.Size = UDim2.new(1, 0, 0, 56)
        dockBg.Position = UDim2.new(0, 0, 0, 4)
        dockGrid.CellSize = UDim2.new(0, 70, 0, 50)
        
        bunkerHome.Size = UDim2.new(0, 200, 0, 14)
        bunkerHome.Position = UDim2.new(0.5, -100, 1, -20)
        bunkerHome.TextSize = 10
    else
        sh.Size = UDim2.new(1, 0, 1, -44)
        sh.Position = UDim2.new(0, 0, 0, 24)
        
        appGrid.Size = UDim2.new(1, -12, 1, -110)
        appGrid.Position = UDim2.new(0, 6, 0, 46)
        gridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
        
        local dockW = math.floor(PHONE_SIZE.X.Offset * 0.55)
        dockArea.Size = UDim2.new(0, dockW, 0, 46)
        dockArea.Position = UDim2.new(0.5, -dockW/2, 1, -54)
        dockBg.Size = UDim2.new(1, 0, 0, 40)
        dockBg.Position = UDim2.new(0, 0, 0, 3)
        dockGrid.CellSize = UDim2.new(0, math.floor(dockW/3.5), 0, 36)
        
        bunkerHome.Size = UDim2.new(0, 150, 0, 10)
        bunkerHome.Position = UDim2.new(0.5, -75, 1, -12)
        bunkerHome.TextSize = 7
    end
end

-- Monitor orientasi
task.spawn(function()
    local lastPortrait = nil
    while true do
        task.wait(0.3)
        local curPortrait = isPortrait()
        if curPortrait ~= lastPortrait then
            lastPortrait = curPortrait
            gridLayout.CellSize = getGridIconSize()
            updateHomeForOrientation()
        end
    end
end)

-- Monitor orientasi untuk phone size
task.spawn(function()
    local lastLandscape = nil
    while true do
        task.wait(0.3)
        local cam = Workspace.CurrentCamera
        if not cam then continue end
        local isLand = cam.ViewportSize.X > cam.ViewportSize.Y
        if isLand ~= lastLandscape then
            lastLandscape = isLand
            if phone.Visible then
                applyPhoneOrientationSize()
            end
        end
    end
end)

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

-- Di iconBuilders:
Lookup = function(p, c)
    -- Magnifying glass
    local circle = Instance.new("Frame", p)
    circle.Size = UDim2.new(0, 22, 0, 22)
    circle.Position = UDim2.new(0.5, -14, 0.25, 0)
    circle.BackgroundTransparency = 1
    stroke(circle, c, 3, 0)
    corner(circle, 100)
    
    local handle = Instance.new("Frame", p)
    handle.Size = UDim2.new(0, 3, 0, 12)
    handle.Position = UDim2.new(0.5, 6, 0.5, 2)
    handle.BackgroundColor3 = c
    handle.Rotation = 45
    corner(handle, 2)
end,

-- Di iconBuilders:
ServerJoiner = function(p, c)
    -- Server rack
    local rack = Instance.new("Frame", p)
    rack.Size = UDim2.new(0, 24, 0, 20)
    rack.Position = UDim2.new(0.5, -12, 0.3, 0)
    rack.BackgroundColor3 = c
    corner(rack, 5)
    
    -- Lights
    for i = 1, 2 do
        local light = Instance.new("Frame", p)
        light.Size = UDim2.new(0, 4, 0, 4)
        light.Position = UDim2.new(0.5 - 6 + i * 6, 0, 0.5, -2)
        light.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        corner(light, 100)
    end
    
    -- Arrow
    local arrow = Instance.new("Frame", p)
    arrow.Size = UDim2.new(0, 8, 0, 3)
    arrow.Position = UDim2.new(0.5, 10, 0.5, -1)
    arrow.BackgroundColor3 = c
    corner(arrow, 2)
end,

WhoOnline = function(p, c)
    -- Globe/earth (lingkaran)
    local globe = Instance.new("Frame", p)
    globe.Size = UDim2.new(0, 24, 0, 24)
    globe.Position = UDim2.new(0.5, -12, 0.22, 0)
    globe.BackgroundColor3 = c
    globe.BackgroundTransparency = 0.85
    corner(globe, 100)
    stroke(globe, c, 2.5, 0)
    
    -- Garis horizontal (equator)
    local equator = Instance.new("Frame", globe)
    equator.Size = UDim2.new(0, 18, 0, 1.5)
    equator.Position = UDim2.new(0.5, -9, 0.5, -0.75)
    equator.BackgroundColor3 = c
    equator.BackgroundTransparency = 0.5
    corner(equator, 1)
    
    -- Garis vertikal (meridian)
    local meridian = Instance.new("Frame", globe)
    meridian.Size = UDim2.new(0, 1.5, 0, 18)
    meridian.Position = UDim2.new(0.5, -0.75, 0.5, -9)
    meridian.BackgroundColor3 = c
    meridian.BackgroundTransparency = 0.5
    corner(meridian, 1)
    
    -- Garis diagonal
    local diag1 = Instance.new("Frame", globe)
    diag1.Size = UDim2.new(0, 12, 0, 1.5)
    diag1.Position = UDim2.new(0.5, -6, 0.5, -0.75)
    diag1.BackgroundColor3 = c
    diag1.BackgroundTransparency = 0.6
    diag1.Rotation = 45
    corner(diag1, 1)
    
    local diag2 = Instance.new("Frame", globe)
    diag2.Size = UDim2.new(0, 12, 0, 1.5)
    diag2.Position = UDim2.new(0.5, -6, 0.5, -0.75)
    diag2.BackgroundColor3 = c
    diag2.BackgroundTransparency = 0.6
    diag2.Rotation = -45
    corner(diag2, 1)
    
    -- 3 titik (mewakili user online)
    local dotColors = {
        Color3.fromRGB(0, 255, 100),
        Color3.fromRGB(0, 255, 100),
        Color3.fromRGB(0, 255, 100)
    }
    
    for i = 1, 3 do
        local dot = Instance.new("Frame", p)
        dot.Size = UDim2.new(0, 5, 0, 5)
        dot.Position = UDim2.new(0, 4 + (i-1)*9, 0, 65 + (i-1)*3)
        dot.Position = UDim2.new(0.5 - 8 + (i-1)*8, 0, 1, -10)
        dot.BackgroundColor3 = dotColors[i]
        dot.BackgroundTransparency = (i == 3) and 0.4 or 0
        corner(dot, 100)
    end
    
    -- Sinyal waves (seperti WiFi)
    for i = 1, 2 do
        local wave = Instance.new("Frame", p)
        wave.Size = UDim2.new(0, 5, 0, 5)
        wave.Position = UDim2.new(0, 2 + (i-1)*7, 0, 50 + (i-1)*8)
        wave.BackgroundTransparency = 1
        stroke(wave, c, 1.5, 0.3)
        corner(wave, 100)
    end
end,

-- Di dalam iconBuilders = { ... }
Message = function(p, c)
    -- Bubble chat utama
    local bubble = Instance.new("Frame", p)
    bubble.Size = UDim2.new(0, 26, 0, 20)
    bubble.Position = UDim2.new(0.5, -13, 0.28, 0)
    bubble.BackgroundColor3 = c
    corner(bubble, 7)
    
    -- Ekor bubble (segitiga kecil di bawah)
    local tail = Instance.new("Frame", p)
    tail.Size = UDim2.new(0, 6, 0, 6)
    tail.Position = UDim2.new(0.5, -10, 0, 48)
    tail.BackgroundColor3 = c
    tail.Rotation = 45
    
    -- 3 titik teks (simulasi isi pesan)
    for i = 1, 3 do
        local dot = Instance.new("Frame", bubble)
        dot.Size = UDim2.new(0, 3, 0, 3)
        dot.Position = UDim2.new(0, 4 + (i-1)*7, 0.5, -1.5)
        dot.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        dot.BackgroundTransparency = 0.5
        corner(dot, 100)
    end
end,

}


-- ================= BUILD APP ICON =================
local function buildAppIcon(name, order, parent, onOpen)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(0, 74, 0, 96)
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

-- ==================== SETTINGS APP (UPGRADED + ESP TOGGLE) ====================
local function openSettingsApp()

    -- ── Helper: buat section header elegan ────────────────────────────────────
    local function makeSection(parent, order, icon, title, desc)
        local header = Instance.new("Frame", parent)
        header.Size = UDim2.new(1, 0, 0, 48)
        header.BackgroundTransparency = 1
        header.LayoutOrder = order

        local iconLbl = Instance.new("TextLabel", header)
        iconLbl.Size = UDim2.new(0, 28, 0, 28)
        iconLbl.Position = UDim2.new(0, 0, 0.5, -14)
        iconLbl.BackgroundColor3 = T.Accent
        iconLbl.BackgroundTransparency = 0.88
        iconLbl.Text = icon
        iconLbl.TextColor3 = T.Accent
        iconLbl.Font = Enum.Font.GothamBold
        iconLbl.TextSize = 14
        iconLbl.ZIndex = 2
        corner(iconLbl, 8)

        local titleLbl = Instance.new("TextLabel", header)
        titleLbl.Size = UDim2.new(1, -40, 0, 18)
        titleLbl.Position = UDim2.new(0, 36, 0, 8)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = title
        titleLbl.TextColor3 = T.Text
        titleLbl.Font = Enum.Font.GothamBlack
        titleLbl.TextSize = 13
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left

        local descLbl = Instance.new("TextLabel", header)
        descLbl.Size = UDim2.new(1, -40, 0, 14)
        descLbl.Position = UDim2.new(0, 36, 0, 28)
        descLbl.BackgroundTransparency = 1
        descLbl.Text = desc
        descLbl.TextColor3 = T.Text2
        descLbl.Font = Enum.Font.Gotham
        descLbl.TextSize = 9
        descLbl.TextXAlignment = Enum.TextXAlignment.Left

        return header
    end

    -- ── Helper: card kontainer elegan ─────────────────────────────────────────
    local function makeCard(parent, order, height)
        local card = Instance.new("Frame", parent)
        card.Size = UDim2.new(1, 0, 0, height)
        card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        card.BackgroundTransparency = 0.03
        card.LayoutOrder = order
        corner(card, 14)
        stroke(card, Color3.fromRGB(230, 230, 238), 1, 0.2)
        return card
    end

    -- ── Helper: row toggle di dalam card ──────────────────────────────────────
    local function makeToggleRow(card, yPos, icon, title, subtitle, currentVal, callback)
        local row = Instance.new("Frame", card)
        row.Size = UDim2.new(1, -24, 0, 48)
        row.Position = UDim2.new(0, 12, 0, yPos)
        row.BackgroundTransparency = 1

        local iconBg = Instance.new("Frame", row)
        iconBg.Size = UDim2.new(0, 36, 0, 36)
        iconBg.Position = UDim2.new(0, 0, 0.5, -18)
        iconBg.BackgroundColor3 = T.Accent
        iconBg.BackgroundTransparency = 0.85
        corner(iconBg, 10)

        local iconLbl = Instance.new("TextLabel", iconBg)
        iconLbl.Size = UDim2.new(1, 0, 1, 0)
        iconLbl.BackgroundTransparency = 1
        iconLbl.Text = icon
        iconLbl.TextColor3 = T.Accent
        iconLbl.Font = Enum.Font.GothamBold
        iconLbl.TextSize = 16

        local titleLbl = Instance.new("TextLabel", row)
        titleLbl.Size = UDim2.new(1, -100, 0, 18)
        titleLbl.Position = UDim2.new(0, 44, 0, 6)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = title
        titleLbl.TextColor3 = T.Text
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 12
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left

        local subLbl = Instance.new("TextLabel", row)
        subLbl.Size = UDim2.new(1, -100, 0, 14)
        subLbl.Position = UDim2.new(0, 44, 0, 26)
        subLbl.BackgroundTransparency = 1
        subLbl.Text = subtitle
        subLbl.TextColor3 = T.Text2
        subLbl.Font = Enum.Font.Gotham
        subLbl.TextSize = 9
        subLbl.TextXAlignment = Enum.TextXAlignment.Left

        local toggle = buildToggle(row, currentVal, callback)
        toggle.Position = UDim2.new(1, -52, 0.5, -13)

        return row
    end

    -- ── Helper: divider tipis antar row ───────────────────────────────────────
    local function makeDivider(parent, yPos)
        local div = Instance.new("Frame", parent)
        div.Size = UDim2.new(1, -56, 0, 1)
        div.Position = UDim2.new(0, 44, 0, yPos)
        div.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
        div.BackgroundTransparency = 0.5
        div.BorderSizePixel = 0
        return div
    end

    -- ================================================================
    -- ① DEVELOPER PROFILE CARD (upgraded)
    -- ================================================================
    local devFrame = makeCard(appContent, 0, 220)
    devFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    devFrame.BackgroundTransparency = 0

    local devGradient = Instance.new("UIGradient", devFrame)
    devGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 48)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 14, 22))
    })
    devGradient.Rotation = 145

    -- Glow line atas
    local glowLine = Instance.new("Frame", devFrame)
    glowLine.Size = UDim2.new(1, 0, 0, 2)
    glowLine.BackgroundColor3 = T.Accent
    glowLine.BorderSizePixel = 0
    glowLine.ZIndex = 5

    local glowLineGrad = Instance.new("UIGradient", glowLine)
    glowLineGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 48)),
        ColorSequenceKeypoint.new(0.3, Color3.fromRGB(80, 140, 255)),
        ColorSequenceKeypoint.new(0.7, Color3.fromRGB(120, 80, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 48))
    })

    -- Badge DEV
    local badgeFrame = Instance.new("Frame", devFrame)
    badgeFrame.Size = UDim2.new(0, 80, 0, 20)
    badgeFrame.Position = UDim2.new(0, 14, 0, 14)
    badgeFrame.BackgroundColor3 = T.Accent
    badgeFrame.BackgroundTransparency = 0.8
    badgeFrame.ZIndex = 5
    corner(badgeFrame, 10)
    stroke(badgeFrame, T.Accent, 1, 0.5)

    local badgeText = Instance.new("TextLabel", badgeFrame)
    badgeText.Size = UDim2.new(1, 0, 1, 0)
    badgeText.BackgroundTransparency = 1
    badgeText.Text = "✦ DEVELOPER"
    badgeText.TextColor3 = Color3.fromRGB(160, 200, 255)
    badgeText.Font = Enum.Font.GothamBold
    badgeText.TextSize = 8
    badgeText.ZIndex = 6

    -- Avatar ring
    local avatarRing = Instance.new("Frame", devFrame)
    avatarRing.Size = UDim2.new(0, 80, 0, 80)
    avatarRing.Position = UDim2.new(0, 16, 0, 46)
    avatarRing.BackgroundColor3 = T.Accent
    avatarRing.BackgroundTransparency = 0.6
    avatarRing.ZIndex = 5
    corner(avatarRing, 100)

    local av = Instance.new("ImageLabel", avatarRing)
    av.Size = UDim2.new(0, 68, 0, 68)
    av.Position = UDim2.new(0.5, -34, 0.5, -34)
    av.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    av.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    av.ZIndex = 6
    corner(av, 100)

    local onlineDot = Instance.new("Frame", avatarRing)
    onlineDot.Size = UDim2.new(0, 14, 0, 14)
    onlineDot.Position = UDim2.new(1, -10, 1, -10)
    onlineDot.BackgroundColor3 = Color3.fromRGB(0, 220, 100)
    onlineDot.ZIndex = 10
    corner(onlineDot, 100)
    stroke(onlineDot, Color3.fromRGB(18, 18, 28), 2.5, 0)

    -- Nama & info
    local nameLbl = Instance.new("TextLabel", devFrame)
    nameLbl.Size = UDim2.new(1, -110, 0, 26)
    nameLbl.Position = UDim2.new(0, 106, 0, 48)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = "alfread"
    nameLbl.TextColor3 = Color3.new(1, 1, 1)
    nameLbl.Font = Enum.Font.GothamBlack
    nameLbl.TextSize = 19
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex = 5

    local verifiedBadge = Instance.new("Frame", devFrame)
    verifiedBadge.Size = UDim2.new(0, 90, 0, 16)
    verifiedBadge.Position = UDim2.new(0, 106, 0, 78)
    verifiedBadge.BackgroundTransparency = 1
    verifiedBadge.ZIndex = 5

    local checkIcon = Instance.new("TextLabel", verifiedBadge)
    checkIcon.Size = UDim2.new(0, 16, 1, 0)
    checkIcon.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
    checkIcon.Text = "✓"
    checkIcon.TextColor3 = Color3.new(1, 1, 1)
    checkIcon.Font = Enum.Font.GothamBlack
    checkIcon.TextSize = 9
    checkIcon.ZIndex = 6
    corner(checkIcon, 100)

    local verText = Instance.new("TextLabel", verifiedBadge)
    verText.Size = UDim2.new(1, -20, 1, 0)
    verText.Position = UDim2.new(0, 20, 0, 0)
    verText.BackgroundTransparency = 1
    verText.Text = "Verified Creator"
    verText.TextColor3 = Color3.fromRGB(140, 190, 255)
    verText.Font = Enum.Font.Gotham
    verText.TextSize = 9
    verText.TextXAlignment = Enum.TextXAlignment.Left
    verText.ZIndex = 5

    local descLbl = Instance.new("TextLabel", devFrame)
    descLbl.Size = UDim2.new(1, -110, 0, 36)
    descLbl.Position = UDim2.new(0, 106, 0, 100)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = "Creator of Phone ID Viewer\nAdvanced Roblox Scripting"
    descLbl.TextColor3 = Color3.fromRGB(160, 160, 185)
    descLbl.Font = Enum.Font.Gotham
    descLbl.TextSize = 10
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.TextWrapped = true
    descLbl.ZIndex = 5

    -- Stats bar
    local statsBar = Instance.new("Frame", devFrame)
    statsBar.Size = UDim2.new(1, -20, 0, 38)
    statsBar.Position = UDim2.new(0, 10, 0, 174)
    statsBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    statsBar.BackgroundTransparency = 0.93
    statsBar.ZIndex = 5
    corner(statsBar, 10)

    for i, stat in ipairs({{value="v10.2",label="Version"},{value="2024",label="Released"},{value="FE",label="Secure"}}) do
        local sf = Instance.new("Frame", statsBar)
        sf.Size = UDim2.new(1/3, 0, 1, 0)
        sf.Position = UDim2.new((i-1)/3, 0, 0, 0)
        sf.BackgroundTransparency = 1
        sf.ZIndex = 6

        if i > 1 then
            local sep = Instance.new("Frame", sf)
            sep.Size = UDim2.new(0, 1, 0.5, 0)
            sep.Position = UDim2.new(0, 0, 0.25, 0)
            sep.BackgroundColor3 = Color3.fromRGB(255,255,255)
            sep.BackgroundTransparency = 0.85
            sep.ZIndex = 6
        end

        local sv = Instance.new("TextLabel", sf)
        sv.Size = UDim2.new(1, 0, 0, 18); sv.Position = UDim2.new(0,0,0,4)
        sv.BackgroundTransparency=1; sv.Text=stat.value
        sv.TextColor3=Color3.new(1,1,1); sv.Font=Enum.Font.GothamBold; sv.TextSize=11
        sv.ZIndex=7

        local sl = Instance.new("TextLabel", sf)
        sl.Size = UDim2.new(1, 0, 0, 12); sl.Position = UDim2.new(0,0,0,22)
        sl.BackgroundTransparency=1; sl.Text=stat.label
        sl.TextColor3=Color3.fromRGB(130,130,155); sl.Font=Enum.Font.Gotham; sl.TextSize=8
        sl.ZIndex=7
    end

    local profileBtn = Instance.new("TextButton", devFrame)
    profileBtn.Size = UDim2.new(0, 80, 0, 26)
    profileBtn.Position = UDim2.new(1, -90, 0, 184)
    profileBtn.BackgroundColor3 = T.Accent
    profileBtn.Text = "Profile ↗"
    profileBtn.TextColor3 = Color3.new(1,1,1)
    profileBtn.Font = Enum.Font.GothamBold
    profileBtn.TextSize = 10
    profileBtn.AutoButtonColor = false
    profileBtn.ZIndex = 6
    corner(profileBtn, 8)
    pressFX(profileBtn)
    profileBtn.MouseButton1Click:Connect(function()
        copyToClipboard("https://www.roblox.com/users/1/profile")
        showDynamicNotification("Profile link copied!", T.Green)
    end)

    -- Fetch real info
    task.spawn(function()
        pcall(function()
            local res = HttpService:JSONDecode(HttpService:GetAsync("https://users.roblox.com/v1/users/search?keyword=alfread&limit=1"))
            if res and res.data and #res.data > 0 then
                local uid = res.data[1].id
                local info = HttpService:JSONDecode(HttpService:GetAsync("https://users.roblox.com/v1/users/" .. uid))
                nameLbl.Text = info.displayName or info.name or "alfread"
                descLbl.Text = info.description or "Creator of Phone ID Viewer\nAdvanced Roblox Scripting"
                av.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..uid.."&width=150&height=150&format=png"
                profileBtn.MouseButton1Click:Connect(function()
                    copyToClipboard("https://www.roblox.com/users/"..uid.."/profile")
                    showDynamicNotification("Profile link copied!", T.Green)
                end)
            end
        end)
    end)

    -- ================================================================
    -- ② SECTION: ESP & TEAM
    -- ================================================================
    makeSection(appContent, 1, "◉", "ESP & Team", "Visibility settings for team members")

    local espCard = makeCard(appContent, 2, 114)

    -- Row 1: ESP On/Off
    makeToggleRow(espCard, 4, "◉", "Team ESP", "Show map pin above team members",
        appSettings.espEnabled ~= false,
        function(val)
            appSettings.espEnabled = val
            persistSettings()
            -- Toggle visibility semua pin yang sudah ada
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    local pin = player.Character:FindFirstChild("TeamMapPin")
                    if pin then
                        pin.Enabled = val
                    end
                end
            end
            showDynamicNotification(val and "ESP aktif" or "ESP dimatikan",
                val and T.Green or T.Red)
        end
    )

    makeDivider(espCard, 58)

    -- Row 2: ESP hanya untuk diri sendiri
    makeToggleRow(espCard, 62, "◎", "Hide Self Pin", "Don't show pin on your own character",
        appSettings.espHideSelf ~= false,
        function(val)
            appSettings.espHideSelf = val
            persistSettings()
            local lp = Players.LocalPlayer
            if lp and lp.Character then
                local pin = lp.Character:FindFirstChild("TeamMapPin")
                if pin then pin.Enabled = not val end
            end
        end
    )

    -- ================================================================
    -- ③ SECTION: SECURITY
    -- ================================================================
    makeSection(appContent, 3, "🔒", "Security", "Lock your phone and change passcode")

    -- Auto Lock card
    local autoLockFrame = makeCard(appContent, 4, 104)

    local alTitle = Instance.new("TextLabel", autoLockFrame)
    alTitle.Size = UDim2.new(1,-24,0,20); alTitle.Position = UDim2.new(0,12,0,10)
    alTitle.BackgroundTransparency=1; alTitle.Text="Auto Lock Timer"
    alTitle.TextColor3=T.Text; alTitle.Font=Enum.Font.GothamBold; alTitle.TextSize=13
    alTitle.TextXAlignment=Enum.TextXAlignment.Left

    local alDesc = Instance.new("TextLabel", autoLockFrame)
    alDesc.Size = UDim2.new(1,-24,0,14); alDesc.Position = UDim2.new(0,12,0,32)
    alDesc.BackgroundTransparency=1; alDesc.Text="Auto-lock after inactivity (0 = disabled)"
    alDesc.TextColor3=T.Text2; alDesc.Font=Enum.Font.Gotham; alDesc.TextSize=9
    alDesc.TextXAlignment=Enum.TextXAlignment.Left

    local inputRow = Instance.new("Frame", autoLockFrame)
    inputRow.Size=UDim2.new(1,-24,0,34); inputRow.Position=UDim2.new(0,12,0,56)
    inputRow.BackgroundTransparency=1

    local autoLockInput = Instance.new("TextBox", inputRow)
    autoLockInput.Size=UDim2.new(0,70,1,0); autoLockInput.Text=tostring(appSettings.autoLockSeconds)
    autoLockInput.PlaceholderText="0"
    autoLockInput.BackgroundColor3=Color3.fromRGB(245,245,250)
    autoLockInput.TextColor3=T.Text; autoLockInput.Font=Enum.Font.GothamBold
    autoLockInput.TextSize=16; autoLockInput.TextXAlignment=Enum.TextXAlignment.Center
    corner(autoLockInput, 8); stroke(autoLockInput, Color3.fromRGB(215,215,222), 1, 0.2)

    local secLabel = Instance.new("TextLabel", inputRow)
    secLabel.Size=UDim2.new(0,50,1,0); secLabel.Position=UDim2.new(0,78,0,0)
    secLabel.BackgroundTransparency=1; secLabel.Text="seconds"
    secLabel.TextColor3=T.Text2; secLabel.Font=Enum.Font.Gotham; secLabel.TextSize=11
    secLabel.TextXAlignment=Enum.TextXAlignment.Left

    local alSave = Instance.new("TextButton", inputRow)
    alSave.Size=UDim2.new(0,60,1,0); alSave.Position=UDim2.new(1,-60,0,0)
    alSave.BackgroundColor3=T.Accent; alSave.Text="Save"
    alSave.TextColor3=T.OnAccent; alSave.Font=Enum.Font.GothamBold; alSave.TextSize=11
    alSave.AutoButtonColor=false; corner(alSave, 8); pressFX(alSave)
    alSave.MouseButton1Click:Connect(function()
        appSettings.autoLockSeconds = math.max(0, tonumber(autoLockInput.Text) or 0)
        persistSettings()
        showDynamicNotification("Auto Lock: "..appSettings.autoLockSeconds.."s", T.Green)
    end)

    -- Passcode card
    local passFrame = makeCard(appContent, 5, 210)

    local passTitle = Instance.new("TextLabel", passFrame)
    passTitle.Size=UDim2.new(1,-24,0,20); passTitle.Position=UDim2.new(0,12,0,10)
    passTitle.BackgroundTransparency=1; passTitle.Text="Change Passcode"
    passTitle.TextColor3=T.Text; passTitle.Font=Enum.Font.GothamBold; passTitle.TextSize=13
    passTitle.TextXAlignment=Enum.TextXAlignment.Left

    local function makePassInput(parent, yPos, placeholder)
        local tb = Instance.new("TextBox", parent)
        tb.Size=UDim2.new(1,-24,0,34); tb.Position=UDim2.new(0,12,0,yPos)
        tb.PlaceholderText=placeholder; tb.Text=""
        tb.BackgroundColor3=Color3.fromRGB(247,247,252)
        tb.TextColor3=T.Text; tb.Font=Enum.Font.Gotham; tb.TextSize=12
        tb.PlaceholderColor3=Color3.fromRGB(185,185,195)
        corner(tb, 9); stroke(tb, Color3.fromRGB(222,222,230), 1, 0.2)
        return tb
    end

    local oldInput     = makePassInput(passFrame, 44,  "Current passcode")
    local newInput     = makePassInput(passFrame, 86,  "New passcode (4 digits)")
    local confirmInput = makePassInput(passFrame, 128, "Confirm new passcode")

    local changeBtn = Instance.new("TextButton", passFrame)
    changeBtn.Size=UDim2.new(1,-24,0,36); changeBtn.Position=UDim2.new(0,12,0,170)
    changeBtn.BackgroundColor3=T.Accent; changeBtn.Text="Update Passcode"
    changeBtn.TextColor3=T.OnAccent; changeBtn.Font=Enum.Font.GothamBold; changeBtn.TextSize=12
    changeBtn.AutoButtonColor=false; corner(changeBtn, 10); pressFX(changeBtn)
    changeBtn.MouseButton1Click:Connect(function()
        if oldInput.Text ~= appSettings.passcode then
            showDynamicNotification("Current PIN incorrect", T.Red); return
        end
        if #newInput.Text ~= 4 or not tonumber(newInput.Text) then
            showDynamicNotification("PIN must be 4 digits", T.Red); return
        end
        if newInput.Text ~= confirmInput.Text then
            showDynamicNotification("PINs do not match", T.Red); return
        end
        appSettings.passcode = newInput.Text; persistSettings()
        showDynamicNotification("Passcode updated!", T.Green)
        oldInput.Text=""; newInput.Text=""; confirmInput.Text=""
    end)

    -- ================================================================
    -- ④ SECTION: APPEARANCE
    -- ================================================================
    makeSection(appContent, 6, "🎨", "Appearance", "Customize how your phone looks")

    -- Theme card
    local themeFrame = makeCard(appContent, 7, 130)

    local thTitle = Instance.new("TextLabel", themeFrame)
    thTitle.Size=UDim2.new(1,-24,0,20); thTitle.Position=UDim2.new(0,12,0,10)
    thTitle.BackgroundTransparency=1; thTitle.Text="Background Theme"
    thTitle.TextColor3=T.Text; thTitle.Font=Enum.Font.GothamBold; thTitle.TextSize=13
    thTitle.TextXAlignment=Enum.TextXAlignment.Left

    local colors = {
        {color=Color3.fromRGB(255,255,255), name="Light"},
        {color=Color3.fromRGB(30,30,42),    name="Dark"},
        {color=Color3.fromRGB(200,220,255), name="Blue"},
        {color=Color3.fromRGB(255,235,210), name="Warm"}
    }
    for i, td in ipairs(colors) do
        local btn = Instance.new("TextButton", themeFrame)
        btn.Size=UDim2.new(0,62,0,52); btn.Position=UDim2.new(0, 12+(i-1)*68, 0, 64)
        btn.BackgroundColor3=td.color
        btn.Text=td.name
        btn.TextColor3=(td.name=="Dark") and Color3.new(1,1,1) or T.Text
        btn.Font=Enum.Font.GothamBold; btn.TextSize=9
        btn.AutoButtonColor=false
        corner(btn, 10); stroke(btn, T.Border, 1, 0.2); pressFX(btn)
        btn.MouseButton1Click:Connect(function()
            appSettings.bgColor=td.color; appSettings.bgGradient=(td.name=="Light")
            persistSettings()
            homeWall.BackgroundColor3=td.color
            local existGrad = homeWall:FindFirstChildOfClass("UIGradient")
            if existGrad then existGrad:Destroy() end
            if appSettings.bgGradient then
                gradient(homeWall, ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(220,220,240)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(250,250,255))
                }), 135)
            end
            phone.BackgroundColor3=td.color
            showDynamicNotification("Theme: "..td.name, T.Green)
        end)
    end

    -- Toggles card: Glow + Opacity dalam satu card
    local appearCard = makeCard(appContent, 8, 160)

    makeToggleRow(appearCard, 4, "✦", "Phone Glow Effect", "Colored border around phone frame",
        appSettings.glowEnabled,
        function(val)
            appSettings.glowEnabled = val; persistSettings()
            phoneStroke.Transparency = val and 0.5 or 0.15
        end
    )

    makeDivider(appearCard, 58)

    -- Opacity slider dalam card yang sama
    local opTitle2 = Instance.new("TextLabel", appearCard)
    opTitle2.Size=UDim2.new(1,-24,0,16); opTitle2.Position=UDim2.new(0,12,0,66)
    opTitle2.BackgroundTransparency=1; opTitle2.Text="Phone Opacity"
    opTitle2.TextColor3=T.Text; opTitle2.Font=Enum.Font.GothamBold; opTitle2.TextSize=12
    opTitle2.TextXAlignment=Enum.TextXAlignment.Left

    local opVal2 = Instance.new("TextLabel", appearCard)
    opVal2.Size=UDim2.new(0,60,0,16); opVal2.Position=UDim2.new(1,-72,0,66)
    opVal2.BackgroundTransparency=1
    opVal2.Text=math.floor((appSettings.phoneOpacity or 1)*100).."%"
    opVal2.TextColor3=T.Accent; opVal2.Font=Enum.Font.GothamBold; opVal2.TextSize=12
    opVal2.TextXAlignment=Enum.TextXAlignment.Right

    local opTrack = Instance.new("TextButton", appearCard)
    opTrack.Size=UDim2.new(1,-24,0,24); opTrack.Position=UDim2.new(0,12,0,90)
    opTrack.BackgroundColor3=Color3.fromRGB(235,235,242); opTrack.Text=""
    opTrack.AutoButtonColor=false; corner(opTrack, 12)

    local opFill2 = Instance.new("Frame", opTrack)
    opFill2.Size=UDim2.new(appSettings.phoneOpacity or 1,0,1,0)
    opFill2.BackgroundColor3=T.Accent; corner(opFill2, 12)

    local opKnob = Instance.new("Frame", opTrack)
    opKnob.Size=UDim2.new(0,20,0,20); opKnob.AnchorPoint=Vector2.new(0.5,0.5)
    local kx = (appSettings.phoneOpacity or 1)
    opKnob.Position=UDim2.new(kx,0,0.5,0)
    opKnob.BackgroundColor3=Color3.new(1,1,1); corner(opKnob,100)
    stroke(opKnob, T.Accent, 2, 0)

    local function setOp(val)
        val=math.clamp(val,0.3,1)
        appSettings.phoneOpacity=val; persistSettings()
        opFill2.Size=UDim2.new(val,0,1,0)
        opKnob.Position=UDim2.new(val,0,0.5,0)
        opVal2.Text=math.floor(val*100).."%"
        phone.BackgroundTransparency=1-val
    end

    opTrack.MouseButton1Down:Connect(function()
        local con
        con=RunService.RenderStepped:Connect(function()
            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                con:Disconnect(); return
            end
            local mx=UserInputService:GetMouseLocation().X
            local ax=opTrack.AbsolutePosition.X; local aw=opTrack.AbsoluteSize.X
            if aw<=0 then aw=1 end
            setOp(0.3+(mx-ax)/aw*0.7)
        end)
    end)

    local opReminder = Instance.new("TextLabel", appearCard)
    opReminder.Size=UDim2.new(1,-24,0,14); opReminder.Position=UDim2.new(0,12,0,120)
    opReminder.BackgroundTransparency=1; opReminder.Text="Drag slider to adjust (30%–100%)"
    opReminder.TextColor3=T.Text2; opReminder.Font=Enum.Font.Gotham; opReminder.TextSize=8
    opReminder.TextXAlignment=Enum.TextXAlignment.Left


    -- ================================================================
    -- ⑥ SECTION: PREFERENCES
    -- ================================================================
    makeSection(appContent, 11, "⚙", "Preferences", "General app settings")

    local prefCard = makeCard(appContent, 12, 166)

    makeToggleRow(prefCard, 4,  "🔔", "Toast Notifications", "Show popup notifications",
        appSettings.toastEnabled,
        function(val) appSettings.toastEnabled=val; persistSettings() end
    )
    makeDivider(prefCard, 58)
    makeToggleRow(prefCard, 62, "🕐", "12H Clock Format",   "Toggle 12h / 24h time display",
        appSettings.clockFormat=="12",
        function(val) appSettings.clockFormat=val and"12"or"24"; persistSettings() end
    )
    makeDivider(prefCard, 116)
    makeToggleRow(prefCard, 120, "🔉", "Button Sounds",      "Play sound on button press",
        appSettings.buttonSounds,
        function(val) appSettings.buttonSounds=val; persistSettings() end
    )

    -- ================================================================
    -- ⑦ RESET BUTTON
    -- ================================================================
    local resetBtn = Instance.new("TextButton", appContent)
    resetBtn.Size=UDim2.new(1,0,0,46)
    resetBtn.BackgroundColor3=Color3.fromRGB(255,240,240)
    resetBtn.Text="↺  Reset All Settings"
    resetBtn.TextColor3=T.Red
    resetBtn.Font=Enum.Font.GothamBold; resetBtn.TextSize=12
    resetBtn.AutoButtonColor=false; resetBtn.LayoutOrder=13
    corner(resetBtn, 12); stroke(resetBtn, Color3.fromRGB(255,200,200), 1, 0.3)
    pressFX(resetBtn)
    resetBtn.MouseButton1Click:Connect(function()
        for k,v in pairs(defaults) do appSettings[k]=v end
        persistSettings(); updateBackgroundMusic()
        phoneStroke.Transparency=0.5; phone.BackgroundTransparency=0
        homeWall.BackgroundColor3=Color3.fromRGB(240,240,250)
        local g=homeWall:FindFirstChildOfClass("UIGradient")
        if not g then
            gradient(homeWall, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(220,220,240)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(250,250,255))
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

-- ================= PLAYER LOOKUP APP (FULL - WITH TABS) =================
local playerLookupData = {} -- Simpan data player yang dicari

local function openPlayerLookupApp()
    -- ==================== HEADER ====================
    local headerCard = Instance.new("Frame", appContent)
    headerCard.Size = UDim2.new(1, 0, 0, 46)
    headerCard.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
    headerCard.LayoutOrder = 0
    corner(headerCard, 14)
    
    local headerAccent = Instance.new("Frame", headerCard)
    headerAccent.Size = UDim2.new(1, 0, 0, 2)
    headerAccent.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
    corner(headerAccent, 1)
    
    local headerTitle = Instance.new("TextLabel", headerCard)
    headerTitle.Size = UDim2.new(1, -24, 0, 22)
    headerTitle.Position = UDim2.new(0, 12, 0, 4)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "Player Lookup"
    headerTitle.TextColor3 = Color3.new(1, 1, 1)
    headerTitle.Font = Enum.Font.GothamBlack
    headerTitle.TextSize = 14
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local headerSub = Instance.new("TextLabel", headerCard)
    headerSub.Size = UDim2.new(1, -24, 0, 14)
    headerSub.Position = UDim2.new(0, 12, 0, 26)
    headerSub.BackgroundTransparency = 1
    headerSub.Text = playerLookupData.username and ("Viewing: @" .. (playerLookupData.username or "")) or "Search any player"
    headerSub.TextColor3 = Color3.fromRGB(160, 160, 180)
    headerSub.Font = Enum.Font.Gotham
    headerSub.TextSize = 8
    headerSub.TextXAlignment = Enum.TextXAlignment.Left
    
    -- ==================== SEARCH BAR ====================
    local searchCard = Instance.new("Frame", appContent)
    searchCard.Size = UDim2.new(1, 0, 0, 52)
    searchCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    searchCard.LayoutOrder = 1
    corner(searchCard, 14)
    stroke(searchCard, Color3.fromRGB(225, 225, 230), 1, 0.3)
    
    local searchInput = Instance.new("TextBox", searchCard)
    searchInput.Size = UDim2.new(1, -100, 0, 32)
    searchInput.Position = UDim2.new(0, 10, 0, 10)
    searchInput.PlaceholderText = "Enter Roblox username..."
    searchInput.Text = playerLookupData.username or ""
    searchInput.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
    searchInput.TextColor3 = T.Text
    searchInput.Font = Enum.Font.Gotham
    searchInput.TextSize = 13
    searchInput.ClearTextOnFocus = false
    corner(searchInput, 8)
    stroke(searchInput, Color3.fromRGB(220, 220, 225), 1, 0.3)
    
    local searchBtn = Instance.new("TextButton", searchCard)
    searchBtn.Size = UDim2.new(0, 80, 0, 32)
    searchBtn.Position = UDim2.new(1, -90, 0, 10)
    searchBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
    searchBtn.Text = "Search"
    searchBtn.TextColor3 = Color3.new(1, 1, 1)
    searchBtn.Font = Enum.Font.GothamBlack
    searchBtn.TextSize = 12
    searchBtn.AutoButtonColor = false
    corner(searchBtn, 8)
    pressFX(searchBtn)
    
    -- ==================== TABS ====================
    local tabFrame = Instance.new("Frame", appContent)
    tabFrame.Size = UDim2.new(1, 0, 0, 36)
    tabFrame.BackgroundColor3 = Color3.fromRGB(242, 242, 247)
    tabFrame.LayoutOrder = 2
    corner(tabFrame, 18)
    stroke(tabFrame, Color3.fromRGB(200, 200, 210), 1, 0.3)
    
    local tabPadding = Instance.new("UIPadding", tabFrame)
    tabPadding.PaddingLeft = UDim.new(0, 3)
    tabPadding.PaddingRight = UDim.new(0, 3)
    tabPadding.PaddingTop = UDim.new(0, 3)
    tabPadding.PaddingBottom = UDim.new(0, 3)
    
    local lookupSelectedTab = playerLookupData.selectedTab or "Items"
    local tabs = {"Profile", "Items", "Outfits"}
    
    for i, t in ipairs(tabs) do
        local btn = Instance.new("TextButton", tabFrame)
        btn.Size = UDim2.new(1/3, -4, 1, 0)
        btn.Position = UDim2.new((i-1)/3, 2, 0, 0)
        btn.Text = t
        btn.AutoButtonColor = false
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundTransparency = 1
        btn.TextColor3 = Color3.fromRGB(100, 100, 100)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 8
        corner(btn, 14)
        
        if t == lookupSelectedTab then
            btn.BackgroundColor3 = T.Accent
            btn.BackgroundTransparency = 0
            btn.TextColor3 = Color3.new(1, 1, 1)
        end
        
        btn.MouseButton1Click:Connect(function()
            lookupSelectedTab = t
            playerLookupData.selectedTab = t
            refreshCurr()
        end)
    end
    
    -- ==================== CONTENT ====================
    local contentFrame = Instance.new("Frame", appContent)
    contentFrame.Size = UDim2.new(1, 0, 0, 0)
    contentFrame.AutomaticSize = Enum.AutomaticSize.Y
    contentFrame.BackgroundTransparency = 1
    contentFrame.LayoutOrder = 3
    
    -- ==================== HTTP HELPER ====================
    local function httpGet(url)
        local ok, result = pcall(function()
            if syn and syn.request then
                local resp = syn.request({Url = url, Method = "GET"})
                if resp and resp.Body and resp.Body ~= "" and resp.Body ~= "null" then return resp.Body end
            end
            error("no syn")
        end)
        if ok and result then return result end
        
        ok, result = pcall(function()
            local data = game:HttpGet(url)
            if data and data ~= "" and data ~= "null" then return data end
            error("empty")
        end)
        if ok and result then return result end
        
        return nil
    end
    
    -- ==================== SEARCH FUNCTION ====================
    local function searchPlayer(username)
        playerLookupData = {username = username, selectedTab = "Items"}
        
        -- Clear content
        for _, child in ipairs(contentFrame:GetChildren()) do
            if not child:IsA("UIListLayout") and not child:IsA("UIGridLayout") then
                child:Destroy()
            end
        end
        
        if username == "" or not username:match("%S") then
            showDynamicNotification("Enter a username!", T.Red)
            return
        end
        
        local loadingCard = Instance.new("Frame", contentFrame)
        loadingCard.Size = UDim2.new(1, 0, 0, 40)
        loadingCard.BackgroundColor3 = Color3.fromRGB(248, 248, 250)
        corner(loadingCard, 10)
        stroke(loadingCard, Color3.fromRGB(220, 220, 225), 1, 0.3)
        
        local loadingText = Instance.new("TextLabel", loadingCard)
        loadingText.Size = UDim2.new(1, 0, 1, 0)
        loadingText.BackgroundTransparency = 1
        loadingText.Text = "Searching..."
        loadingText.TextColor3 = T.Text2
        loadingText.Font = Enum.Font.Gotham
        loadingText.TextSize = 10
        
        task.spawn(function()
            local userId = nil
            local displayName = username
            
            -- Method 1: Search API
            local searchRaw = httpGet("https://users.roblox.com/v1/users/search?keyword=" .. HttpService:UrlEncode(username) .. "&limit=10")
            if searchRaw then
                local ok, data = pcall(function() return HttpService:JSONDecode(searchRaw) end)
                if ok and data and data.data and #data.data > 0 then
                    for _, user in ipairs(data.data) do
                        if user.name:lower() == username:lower() or (user.displayName and user.displayName:lower() == username:lower()) then
                            userId = user.id
                            displayName = user.displayName or user.name
                            break
                        end
                    end
                    if not userId then
                        userId = data.data[1].id
                        displayName = data.data[1].displayName or data.data[1].name
                    end
                end
            end
            
            -- Method 2: Direct API
            if not userId then
                local userRaw = httpGet("https://api.roblox.com/users/get-by-username?username=" .. HttpService:UrlEncode(username))
                if userRaw then
                    local ok, data = pcall(function() return HttpService:JSONDecode(userRaw) end)
                    if ok and data and data.Id and data.Id > 0 then
                        userId = data.Id
                        displayName = data.Username or username
                    end
                end
            end
            
            -- Method 3: POST API
            if not userId then
                local postRaw = nil
                pcall(function()
                    if syn and syn.request then
                        local resp = syn.request({
                            Url = "https://users.roblox.com/v1/usernames/users",
                            Method = "POST",
                            Headers = {["Content-Type"] = "application/json"},
                            Body = HttpService:JSONEncode({usernames = {username}})
                        })
                        if resp and resp.Body then postRaw = resp.Body end
                    end
                end)
                if postRaw then
                    local ok, data = pcall(function() return HttpService:JSONDecode(postRaw) end)
                    if ok and data and data.data and #data.data > 0 then
                        userId = data.data[1].id
                        displayName = data.data[1].displayName or data.data[1].name or username
                    end
                end
            end
            
            loadingCard:Destroy()
            
            if not userId then
                local notFoundCard = Instance.new("Frame", contentFrame)
                notFoundCard.Size = UDim2.new(1, 0, 0, 90)
                notFoundCard.BackgroundColor3 = Color3.fromRGB(248, 248, 250)
                corner(notFoundCard, 14)
                stroke(notFoundCard, Color3.fromRGB(220, 220, 225), 1, 0.3)
                
                local notFoundText = Instance.new("TextLabel", notFoundCard)
                notFoundText.Size = UDim2.new(1, 0, 1, 0)
                notFoundText.BackgroundTransparency = 1
                notFoundText.Text = "Player not found!\n@" .. username
                notFoundText.TextColor3 = Color3.fromRGB(140, 140, 150)
                notFoundText.Font = Enum.Font.GothamBlack
                notFoundText.TextSize = 13
                notFoundText.TextWrapped = true
                notFoundText.TextXAlignment = Enum.TextXAlignment.Center
                return
            end
            
            -- Simpan data
            playerLookupData.userId = userId
            playerLookupData.displayName = displayName
            playerLookupData.username = username
            
            showDynamicNotification("Found: " .. displayName, T.Green)
            refreshCurr()
        end)
    end
    
    -- ==================== RENDER PROFILE TAB ====================
    if lookupSelectedTab == "Profile" and playerLookupData.userId then
        local userId = playerLookupData.userId
        local displayName = playerLookupData.displayName
        
        -- Profile Card
        local profileCard = Instance.new("Frame", contentFrame)
        profileCard.Size = UDim2.new(1, 0, 0, 90)
        profileCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        corner(profileCard, 14)
        stroke(profileCard, Color3.fromRGB(80, 150, 255), 2, 0.3)
        
        local avatarImg = Instance.new("ImageLabel", profileCard)
        avatarImg.Size = UDim2.new(0, 64, 0, 64)
        avatarImg.Position = UDim2.new(0, 12, 0.5, -32)
        avatarImg.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
        avatarImg.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=150&height=150&format=png"
        corner(avatarImg, 100)
        stroke(avatarImg, Color3.fromRGB(80, 150, 255), 2, 0)
        
        local nameLbl = Instance.new("TextLabel", profileCard)
        nameLbl.Size = UDim2.new(1, -100, 0, 24)
        nameLbl.Position = UDim2.new(0, 84, 0, 10)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = displayName
        nameLbl.TextColor3 = T.Text
        nameLbl.Font = Enum.Font.GothamBlack
        nameLbl.TextSize = 17
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        
        local idLbl = Instance.new("TextLabel", profileCard)
        idLbl.Size = UDim2.new(1, -100, 0, 16)
        idLbl.Position = UDim2.new(0, 84, 0, 34)
        idLbl.BackgroundTransparency = 1
        idLbl.Text = "ID: " .. userId
        idLbl.TextColor3 = T.Text2
        idLbl.Font = Enum.Font.Code
        idLbl.TextSize = 10
        idLbl.TextXAlignment = Enum.TextXAlignment.Left
        
        local isOnline = Players:GetPlayerByUserId(userId) ~= nil
        local onlineDot = Instance.new("Frame", profileCard)
        onlineDot.Size = UDim2.new(0, 10, 0, 10)
        onlineDot.Position = UDim2.new(0, 84, 0, 54)
        onlineDot.BackgroundColor3 = isOnline and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(150, 150, 150)
        corner(onlineDot, 100)
        
        local onlineText = Instance.new("TextLabel", profileCard)
        onlineText.Size = UDim2.new(0, 60, 0, 14)
        onlineText.Position = UDim2.new(0, 98, 0, 52)
        onlineText.BackgroundTransparency = 1
        onlineText.Text = isOnline and "IN GAME" or "OFFLINE"
        onlineText.TextColor3 = isOnline and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(150, 150, 150)
        onlineText.Font = Enum.Font.GothamBold
        onlineText.TextSize = 9
        onlineText.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Quick buttons
        local quickRow = Instance.new("Frame", contentFrame)
        quickRow.Size = UDim2.new(1, 0, 0, 36)
        quickRow.BackgroundTransparency = 1
        
        local targetBtn = Instance.new("TextButton", quickRow)
        targetBtn.Size = UDim2.new(0, 85, 1, 0)
        targetBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
        targetBtn.Text = "Set Target"
        targetBtn.TextColor3 = T.OnAccent
        targetBtn.Font = Enum.Font.GothamBold
        targetBtn.TextSize = 10
        targetBtn.AutoButtonColor = false
        corner(targetBtn, 8)
        pressFX(targetBtn)
        targetBtn.MouseButton1Click:Connect(function()
            if isOnline then
                selectedPlayer = Players:GetPlayerByUserId(userId)
                showDynamicNotification("Target: " .. displayName, T.Green)
            else
                showDynamicNotification("Not in server!", T.Red)
            end
        end)
        
        local cloneBtn = Instance.new("TextButton", quickRow)
        cloneBtn.Size = UDim2.new(0, 85, 1, 0)
        cloneBtn.Position = UDim2.new(0, 93, 0, 0)
        cloneBtn.BackgroundColor3 = T.Green
        cloneBtn.Text = "Clone"
        cloneBtn.TextColor3 = T.OnAccent
        cloneBtn.Font = Enum.Font.GothamBold
        cloneBtn.TextSize = 10
        cloneBtn.AutoButtonColor = false
        corner(cloneBtn, 8)
        pressFX(cloneBtn)
        cloneBtn.MouseButton1Click:Connect(function()
            cloneBtn.Text = "..."
            cloneFromUserId(userId, function(done)
                if done then
                    cloneBtn.Text = "Done!"
                    showDynamicNotification("Clone complete!", T.Green)
                else
                    cloneBtn.Text = "Fail!"
                end
                task.wait(1.5)
                cloneBtn.Text = "Clone"
            end)
        end)
        
        local copyBtn = Instance.new("TextButton", quickRow)
        copyBtn.Size = UDim2.new(0, 85, 1, 0)
        copyBtn.Position = UDim2.new(0, 186, 0, 0)
        copyBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
        copyBtn.Text = "Copy ID"
        copyBtn.TextColor3 = T.Text
        copyBtn.Font = Enum.Font.GothamBold
        copyBtn.TextSize = 10
        copyBtn.AutoButtonColor = false
        corner(copyBtn, 8)
        stroke(copyBtn, T.Border, 1, 0.3)
        pressFX(copyBtn)
        copyBtn.MouseButton1Click:Connect(function()
            copyToClipboard(tostring(userId))
            showDynamicNotification("ID copied!", T.Green)
        end)
    end
    
    -- ==================== RENDER ITEMS TAB ====================
    if lookupSelectedTab == "Items" and playerLookupData.userId then
        local userId = playerLookupData.userId
        
        local loadingText = Instance.new("TextLabel", contentFrame)
        loadingText.Size = UDim2.new(1, 0, 0, 24)
        loadingText.BackgroundTransparency = 1
        loadingText.Text = "Loading items..."
        loadingText.TextColor3 = T.Text2
        loadingText.Font = Enum.Font.Gotham
        loadingText.TextSize = 10
        
        task.spawn(function()
            local allItems = {}
            
            -- Fetch avatar items
            local avatarRaw = httpGet("https://avatar.roblox.com/v1/users/" .. userId .. "/avatar")
            if avatarRaw then
                local ok, data = pcall(function() return HttpService:JSONDecode(avatarRaw) end)
                if ok and data and data.assets then
                    for _, asset in ipairs(data.assets) do
                        table.insert(allItems, {
                            id = asset.id,
                            name = asset.name or "Unknown",
                            itemType = "BODY",
                            typeColor = Color3.fromRGB(255, 130, 80)
                        })
                    end
                end
            end
            
            -- Fetch currently wearing
            local wearRaw = httpGet("https://avatar.roblox.com/v1/users/" .. userId .. "/currently-wearing")
            if wearRaw then
                local ok, data = pcall(function() return HttpService:JSONDecode(wearRaw) end)
                if ok and data and data.assetIds then
                    for _, assetId in ipairs(data.assetIds) do
                        local isDup = false
                        for _, existing in ipairs(allItems) do
                            if tonumber(existing.id) == assetId then
                                existing.itemType = "BODY/ACC"
                                existing.typeColor = Color3.fromRGB(80, 200, 80)
                                isDup = true
                                break
                            end
                        end
                        if not isDup then
                            table.insert(allItems, {
                                id = assetId,
                                name = "Acc " .. assetId,
                                itemType = "ACC",
                                typeColor = Color3.fromRGB(80, 200, 80)
                            })
                        end
                    end
                end
            end
            
            loadingText:Destroy()
            
            if #allItems == 0 then
                local emptyText = Instance.new("TextLabel", contentFrame)
                emptyText.Size = UDim2.new(1, 0, 0, 40)
                emptyText.BackgroundTransparency = 1
                emptyText.Text = "No items found"
                emptyText.TextColor3 = Color3.fromRGB(140, 140, 150)
                emptyText.Font = Enum.Font.GothamBold
                emptyText.TextSize = 12
                emptyText.TextXAlignment = Enum.TextXAlignment.Center
            else
                -- Counter
                local counter = Instance.new("TextLabel", contentFrame)
                counter.Size = UDim2.new(1, 0, 0, 18)
                counter.BackgroundTransparency = 1
                counter.Text = #allItems .. " items found | Click Wear to equip"
                counter.TextColor3 = T.Text2
                counter.Font = Enum.Font.GothamBold
                counter.TextSize = 9
                counter.TextXAlignment = Enum.TextXAlignment.Left
                
                -- List layout
                local listLayout = Instance.new("UIListLayout", contentFrame)
                listLayout.Padding = UDim.new(0, 6)
                listLayout.SortOrder = Enum.SortOrder.LayoutOrder
                
                -- Render items
                local maxShow = math.min(20, #allItems)
                for i = 1, maxShow do
                    local card = Instance.new("Frame", contentFrame)
                    card.Size = UDim2.new(1, 0, 0, 56)
                    card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    card.LayoutOrder = i
                    corner(card, 10)
                    stroke(card, Color3.fromRGB(225, 225, 230), 1, 0.3)
                    
                    local imgBox = Instance.new("Frame", card)
                    imgBox.Size = UDim2.new(0, 40, 0, 40)
                    imgBox.Position = UDim2.new(0, 8, 0.5, -20)
                    imgBox.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
                    corner(imgBox, 8)
                    stroke(imgBox, Color3.fromRGB(215, 215, 220), 1, 0.3)
                    
                    local img = Instance.new("ImageLabel", imgBox)
                    img.Size = UDim2.new(1, -4, 1, -4)
                    img.Position = UDim2.new(0.5, 0, 0.5, 0)
                    img.AnchorPoint = Vector2.new(0.5, 0.5)
                    img.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
                    img.Image = "https://www.roblox.com/asset-thumbnail/image?assetId=" .. allItems[i].id .. "&width=100&height=100&format=png"
                    img.ScaleType = Enum.ScaleType.Fit
                    corner(img, 6)
                    
                    local nameLbl = Instance.new("TextLabel", card)
                    nameLbl.Size = UDim2.new(1, -120, 0, 20)
                    nameLbl.Position = UDim2.new(0, 54, 0, 6)
                    nameLbl.BackgroundTransparency = 1
                    nameLbl.Text = allItems[i].name
                    nameLbl.TextColor3 = T.Text
                    nameLbl.Font = Enum.Font.GothamBlack
                    nameLbl.TextSize = 11
                    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
                    
                    local idLbl = Instance.new("TextLabel", card)
                    idLbl.Size = UDim2.new(1, -120, 0, 14)
                    idLbl.Position = UDim2.new(0, 54, 0, 26)
                    idLbl.BackgroundTransparency = 1
                    idLbl.Text = "ID: " .. allItems[i].id
                    idLbl.TextColor3 = T.Text2
                    idLbl.Font = Enum.Font.Code
                    idLbl.TextSize = 8
                    idLbl.TextXAlignment = Enum.TextXAlignment.Left
                    
                    local typeBadge = Instance.new("Frame", card)
                    typeBadge.Size = UDim2.new(0, 45, 0, 14)
                    typeBadge.Position = UDim2.new(0, 54, 0, 40)
                    typeBadge.BackgroundColor3 = allItems[i].typeColor
                    typeBadge.BackgroundTransparency = 0.82
                    corner(typeBadge, 7)
                    
                    local typeText = Instance.new("TextLabel", typeBadge)
                    typeText.Size = UDim2.new(1, 0, 1, 0)
                    typeText.BackgroundTransparency = 1
                    typeText.Text = allItems[i].itemType
                    typeText.TextColor3 = allItems[i].typeColor
                    typeText.Font = Enum.Font.GothamBold
                    typeText.TextSize = 7
                    
                    local wearBtn = Instance.new("TextButton", card)
                    wearBtn.Size = UDim2.new(0, 50, 0, 22)
                    wearBtn.Position = UDim2.new(1, -58, 0.5, -11)
                    wearBtn.BackgroundColor3 = T.Accent
                    wearBtn.Text = "Wear"
                    wearBtn.TextColor3 = T.OnAccent
                    wearBtn.Font = Enum.Font.GothamBold
                    wearBtn.TextSize = 8
                    wearBtn.AutoButtonColor = false
                    corner(wearBtn, 6)
                    pressFX(wearBtn)
                    wearBtn.MouseButton1Click:Connect(function()
                        fireHat({tostring(allItems[i].id)})
                        wearBtn.Text = "OK"
                        wearBtn.BackgroundColor3 = T.Green
                        task.wait(1)
                        wearBtn.Text = "Wear"
                        wearBtn.BackgroundColor3 = T.Accent
                    end)
                    
                    local copyBtn = Instance.new("TextButton", card)
                    copyBtn.Size = UDim2.new(0, 50, 0, 22)
                    copyBtn.Position = UDim2.new(1, -114, 0.5, -11)
                    copyBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
                    copyBtn.Text = "Copy"
                    copyBtn.TextColor3 = T.Text
                    copyBtn.Font = Enum.Font.GothamBold
                    copyBtn.TextSize = 8
                    copyBtn.AutoButtonColor = false
                    corner(copyBtn, 6)
                    stroke(copyBtn, T.Border, 1, 0.3)
                    pressFX(copyBtn)
                    copyBtn.MouseButton1Click:Connect(function()
                        copyToClipboard(tostring(allItems[i].id))
                        showDynamicNotification("Copied!", T.Green)
                    end)
                end
                
                -- Clone All button
                local cloneAllBtn = Instance.new("TextButton", contentFrame)
                cloneAllBtn.Size = UDim2.new(1, 0, 0, 34)
                cloneAllBtn.BackgroundColor3 = T.Green
                cloneAllBtn.Text = "CLONE ALL ITEMS (" .. #allItems .. ")"
                cloneAllBtn.TextColor3 = T.OnAccent
                cloneAllBtn.Font = Enum.Font.GothamBlack
                cloneAllBtn.TextSize = 11
                cloneAllBtn.AutoButtonColor = false
                cloneAllBtn.LayoutOrder = 999
                corner(cloneAllBtn, 8)
                pressFX(cloneAllBtn)
                cloneAllBtn.MouseButton1Click:Connect(function()
                    local ids = {}
                    for _, item in ipairs(allItems) do
                        table.insert(ids, tostring(item.id))
                    end
                    cloneAllBtn.Text = "Cloning..."
                    cloneAllBtn.BackgroundColor3 = T.Gold
                    
                    local batchSize = CONFIG.CLONE_BATCH_SIZE or 5
                    local delayTime = CONFIG.CLONE_DELAY or 6
                    local total = math.ceil(#ids / batchSize)
                    local cur = 0
                    
                    local function nextBatch()
                        cur = cur + 1
                        if cur > total then
                            cloneAllBtn.Text = "Done!"
                            cloneAllBtn.BackgroundColor3 = T.Green
                            task.wait(2)
                            cloneAllBtn.Text = "CLONE ALL ITEMS (" .. #allItems .. ")"
                            cloneAllBtn.BackgroundColor3 = T.Green
                            return
                        end
                        local s = (cur - 1) * batchSize + 1
                        local e = math.min(cur * batchSize, #ids)
                        local b = {}
                        for j = s, e do table.insert(b, ids[j]) end
                        fireHat(b)
                        cloneAllBtn.Text = "Clone " .. cur .. "/" .. total
                        task.delay(delayTime, nextBatch)
                    end
                    nextBatch()
                end)
            end
        end)
    end
    
-- ==================== RENDER OUTFITS TAB (FIXED - SAME API AS AVATARITEM) ====================
if lookupSelectedTab == "Outfits" and playerLookupData.userId then
    local userId = playerLookupData.userId
    local displayName = playerLookupData.displayName
    
    local loadingText = Instance.new("TextLabel", contentFrame)
    loadingText.Size = UDim2.new(1, 0, 0, 24)
    loadingText.BackgroundTransparency = 1
    loadingText.Text = "Loading outfits..."
    loadingText.TextColor3 = T.Text2
    loadingText.Font = Enum.Font.Gotham
    loadingText.TextSize = 10
    
    task.spawn(function()
        local allOutfits = {}
        
        -- ===== METHOD 1: Outfits API (sama seperti AvatarItem) =====
        local raw = httpGet("https://avatar.roblox.com/v1/users/" .. userId .. "/outfits?page=1&itemsPerPage=30")
        
        if raw then
            local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
            if ok and data and data.data and #data.data > 0 then
                for _, outfit in ipairs(data.data) do
                    if outfit.name and outfit.id then
                        table.insert(allOutfits, {
                            id = outfit.id,
                            name = outfit.name,
                            assets = {}
                        })
                    end
                end
            end
        end
        
        -- ===== METHOD 2: Currently Wearing (fallback) =====
        if #allOutfits == 0 then
            local wearRaw = httpGet("https://avatar.roblox.com/v1/users/" .. userId .. "/currently-wearing")
            
            if wearRaw then
                local ok, data = pcall(function() return HttpService:JSONDecode(wearRaw) end)
                if ok and data and data.assetIds and #data.assetIds > 0 then
                    table.insert(allOutfits, {
                        id = "current",
                        name = "Current Outfit",
                        assets = data.assetIds
                    })
                end
            end
        end
        
        -- ===== METHOD 3: Avatar API (last resort) =====
        if #allOutfits == 0 then
            local avatarRaw = httpGet("https://avatar.roblox.com/v1/users/" .. userId .. "/avatar")
            
            if avatarRaw then
                local ok, data = pcall(function() return HttpService:JSONDecode(avatarRaw) end)
                if ok and data and data.assets and #data.assets > 0 then
                    local ids = {}
                    for _, asset in ipairs(data.assets) do
                        if asset.id then table.insert(ids, tostring(asset.id)) end
                    end
                    if #ids > 0 then
                        table.insert(allOutfits, {
                            id = "current",
                            name = "Current Avatar",
                            assets = ids
                        })
                    end
                end
            end
        end
        
        loadingText:Destroy()
        
        if #allOutfits == 0 then
            local emptyCard = Instance.new("Frame", contentFrame)
            emptyCard.Size = UDim2.new(1, 0, 0, 120)
            emptyCard.BackgroundColor3 = Color3.fromRGB(248, 248, 250)
            corner(emptyCard, 14)
            stroke(emptyCard, Color3.fromRGB(220, 220, 225), 1, 0.3)
            
            local emptyText = Instance.new("TextLabel", emptyCard)
            emptyText.Size = UDim2.new(1, 0, 0, 50)
            emptyText.Position = UDim2.new(0, 0, 0, 20)
            emptyText.BackgroundTransparency = 1
            emptyText.Text = "No outfits found"
            emptyText.TextColor3 = Color3.fromRGB(140, 140, 150)
            emptyText.Font = Enum.Font.GothamBlack
            emptyText.TextSize = 13
            emptyText.TextXAlignment = Enum.TextXAlignment.Center
            
            local emptyMsg = Instance.new("TextLabel", emptyCard)
            emptyMsg.Size = UDim2.new(1, -20, 0, 30)
            emptyMsg.Position = UDim2.new(0, 10, 0, 72)
            emptyMsg.BackgroundTransparency = 1
            emptyMsg.Text = "This player may not have public outfits\nor API is restricted for this player"
            emptyMsg.TextColor3 = Color3.fromRGB(160, 160, 170)
            emptyMsg.Font = Enum.Font.Gotham
            emptyMsg.TextSize = 10
            emptyMsg.TextWrapped = true
            emptyMsg.TextXAlignment = Enum.TextXAlignment.Center
            return
        end
        
        -- Counter
        local counter = Instance.new("TextLabel", contentFrame)
        counter.Size = UDim2.new(1, 0, 0, 18)
        counter.BackgroundTransparency = 1
        counter.Text = #allOutfits .. " outfits found"
        counter.TextColor3 = T.Text2
        counter.Font = Enum.Font.GothamBold
        counter.TextSize = 9
        counter.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Grid 2 kolom
        local grid = Instance.new("UIGridLayout", contentFrame)
        grid.CellSize = UDim2.new(0.5, -5, 0, 170)
        grid.CellPadding = UDim2.new(0, 8, 0, 8)
        grid.FillDirection = Enum.FillDirection.Horizontal
        grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
        grid.SortOrder = Enum.SortOrder.LayoutOrder
        
        for i, outfit in ipairs(allOutfits) do
            local card = Instance.new("Frame", contentFrame)
            card.Size = UDim2.new(0, 0, 0, 170)
            card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            card.LayoutOrder = i
            corner(card, 12)
            stroke(card, Color3.fromRGB(225, 225, 230), 1, 0.3)
            
            -- Thumbnail
            local imgBox = Instance.new("Frame", card)
            imgBox.Size = UDim2.new(0, 75, 0, 75)
            imgBox.Position = UDim2.new(0.5, -37, 0, 8)
            imgBox.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
            corner(imgBox, 10)
            stroke(imgBox, Color3.fromRGB(215, 215, 220), 1, 0.3)
            
            local img = Instance.new("ImageLabel", imgBox)
            img.Size = UDim2.new(1, -4, 1, -4)
            img.Position = UDim2.new(0.5, 0, 0.5, 0)
            img.AnchorPoint = Vector2.new(0.5, 0.5)
            img.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
            
            -- Thumbnail based on type
            if outfit.id == "current" then
                img.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=150&height=150&format=png"
            else
                img.Image = "https://www.roblox.com/outfit-thumbnail/image?userOutfitId=" .. outfit.id .. "&width=150&height=150&format=png"
            end
            img.ScaleType = Enum.ScaleType.Fit
            corner(img, 7)
            
            -- Name
            local nameLbl = Instance.new("TextLabel", card)
            nameLbl.Size = UDim2.new(1, -14, 0, 28)
            nameLbl.Position = UDim2.new(0, 7, 0, 86)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = outfit.name
            nameLbl.TextColor3 = T.Text
            nameLbl.Font = Enum.Font.GothamBlack
            nameLbl.TextSize = 10
            nameLbl.TextXAlignment = Enum.TextXAlignment.Center
            nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
            nameLbl.TextWrapped = true
            
            -- ID
            local idText = outfit.id == "current" and "CURRENT" or "ID: " .. outfit.id
            local idLbl = Instance.new("TextLabel", card)
            idLbl.Size = UDim2.new(1, -14, 0, 14)
            idLbl.Position = UDim2.new(0, 7, 0, 114)
            idLbl.BackgroundTransparency = 1
            idLbl.Text = idText
            idLbl.TextColor3 = T.Text2
            idLbl.Font = Enum.Font.Code
            idLbl.TextSize = 8
            idLbl.TextXAlignment = Enum.TextXAlignment.Center
            
            -- Type badge
            if outfit.id == "current" then
                local badge = Instance.new("Frame", card)
                badge.Size = UDim2.new(0, 50, 0, 15)
                badge.Position = UDim2.new(0.5, -25, 0, 130)
                badge.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
                badge.BackgroundTransparency = 0.8
                corner(badge, 7)
                
                local badgeText = Instance.new("TextLabel", badge)
                badgeText.Size = UDim2.new(1, 0, 1, 0)
                badgeText.BackgroundTransparency = 1
                badgeText.Text = "CURRENT"
                badgeText.TextColor3 = Color3.fromRGB(80, 200, 80)
                badgeText.Font = Enum.Font.GothamBold
                badgeText.TextSize = 7
            end
            
            -- Buttons
            local btnRow = Instance.new("Frame", card)
            btnRow.Size = UDim2.new(1, -14, 0, 26)
            btnRow.Position = UDim2.new(0, 7, 0, 140)
            btnRow.BackgroundTransparency = 1
            
            -- Wear button
            local wearBtn = Instance.new("TextButton", btnRow)
            wearBtn.Size = UDim2.new(0, 65, 1, 0)
            wearBtn.BackgroundColor3 = Color3.fromRGB(180, 130, 255)
            wearBtn.Text = "Wear"
            wearBtn.TextColor3 = T.OnAccent
            wearBtn.Font = Enum.Font.GothamBold
            wearBtn.TextSize = 9
            wearBtn.AutoButtonColor = false
            corner(wearBtn, 6)
            pressFX(wearBtn)
            wearBtn.MouseButton1Click:Connect(function()
                wearBtn.Text = "..."
                wearBtn.BackgroundColor3 = T.Gold
                
                local idsToWear = {}
                
                -- Cek apakah outfit punya assets tersimpan
                if outfit.assets and #outfit.assets > 0 then
                    -- Konversi ke string jika perlu
                    for _, id in ipairs(outfit.assets) do
                        table.insert(idsToWear, tostring(id))
                    end
                elseif outfit.id == "current" then
                    -- Fallback: ambil dari currently-wearing
                    local wearRaw = httpGet("https://avatar.roblox.com/v1/users/" .. userId .. "/currently-wearing")
                    if wearRaw then
                        local ok, data = pcall(function() return HttpService:JSONDecode(wearRaw) end)
                        if ok and data and data.assetIds then
                            for _, id in ipairs(data.assetIds) do
                                table.insert(idsToWear, tostring(id))
                            end
                        end
                    end
                else
                    -- Fetch detail outfit
                    local detailRaw = httpGet("https://avatar.roblox.com/v1/outfits/" .. outfit.id .. "/details")
                    if detailRaw then
                        local ok, detail = pcall(function() return HttpService:JSONDecode(detailRaw) end)
                        if ok and detail and detail.assets then
                            for _, asset in ipairs(detail.assets) do
                                if asset.id then
                                    table.insert(idsToWear, tostring(asset.id))
                                end
                            end
                        end
                    end
                end
                
                if #idsToWear > 0 then
                    fireHat(idsToWear)
                    task.wait(0.3)
                    resetCharacter()
                    wearBtn.Text = "Done!"
                    wearBtn.BackgroundColor3 = T.Green
                    showDynamicNotification("Outfit applied!", T.Green)
                else
                    wearBtn.Text = "Empty!"
                    wearBtn.BackgroundColor3 = T.Red
                    showDynamicNotification("No items in outfit!", T.Red)
                end
                
                task.wait(1.5)
                wearBtn.Text = "Wear"
                wearBtn.BackgroundColor3 = Color3.fromRGB(180, 130, 255)
            end)
            
            -- Copy button
            local copyBtn = Instance.new("TextButton", btnRow)
            copyBtn.Size = UDim2.new(0, 55, 1, 0)
            copyBtn.Position = UDim2.new(0, 69, 0, 0)
            copyBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
            copyBtn.Text = "Copy"
            copyBtn.TextColor3 = T.Text
            copyBtn.Font = Enum.Font.GothamBold
            copyBtn.TextSize = 9
            copyBtn.AutoButtonColor = false
            corner(copyBtn, 6)
            stroke(copyBtn, T.Border, 1, 0.3)
            pressFX(copyBtn)
            copyBtn.MouseButton1Click:Connect(function()
                local copyId = outfit.id == "current" and tostring(userId) or tostring(outfit.id)
                copyToClipboard(copyId)
                showDynamicNotification("Copied!", T.Green)
            end)
        end
    end)
end
    
    -- ==================== NO DATA STATE ====================
    if not playerLookupData.userId then
        local emptyCard = Instance.new("Frame", contentFrame)
        emptyCard.Size = UDim2.new(1, 0, 0, 100)
        emptyCard.BackgroundColor3 = Color3.fromRGB(248, 248, 250)
        corner(emptyCard, 14)
        stroke(emptyCard, Color3.fromRGB(220, 220, 225), 1, 0.3)
        
        local emptyText = Instance.new("TextLabel", emptyCard)
        emptyText.Size = UDim2.new(1, 0, 1, 0)
        emptyText.BackgroundTransparency = 1
        emptyText.Text = "Search a player to get started!\n\nType a Roblox username above"
        emptyText.TextColor3 = Color3.fromRGB(140, 140, 150)
        emptyText.Font = Enum.Font.GothamBold
        emptyText.TextSize = 12
        emptyText.TextWrapped = true
    end
    
    -- ==================== EVENTS ====================
    searchBtn.MouseButton1Click:Connect(function()
        searchPlayer(searchInput.Text)
    end)
    
    searchInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            searchPlayer(searchInput.Text)
        end
    end)
end

-- ================= SERVER JOINER (ONLY ACTIVE SERVERS) =================
local function openServerJoinerApp()
    -- ==================== HEADER ====================
    local headerCard = Instance.new("Frame", appContent)
    headerCard.Size = UDim2.new(1, 0, 0, 46)
    headerCard.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
    headerCard.LayoutOrder = 0
    corner(headerCard, 14)
    
    local headerAccent = Instance.new("Frame", headerCard)
    headerAccent.Size = UDim2.new(1, 0, 0, 2)
    headerAccent.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
    corner(headerAccent, 1)
    
    local headerTitle = Instance.new("TextLabel", headerCard)
    headerTitle.Size = UDim2.new(1, -24, 0, 22)
    headerTitle.Position = UDim2.new(0, 12, 0, 6)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "Server Joiner"
    headerTitle.TextColor3 = Color3.new(1, 1, 1)
    headerTitle.Font = Enum.Font.GothamBlack
    headerTitle.TextSize = 14
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local headerSub = Instance.new("TextLabel", headerCard)
    headerSub.Size = UDim2.new(1, -24, 0, 14)
    headerSub.Position = UDim2.new(0, 12, 0, 28)
    headerSub.BackgroundTransparency = 1
    headerSub.Text = "Join server dengan 1 klik"
    headerSub.TextColor3 = Color3.fromRGB(160, 160, 180)
    headerSub.Font = Enum.Font.Gotham
    headerSub.TextSize = 8
    headerSub.TextXAlignment = Enum.TextXAlignment.Left
    
    -- ==================== CONTENT ====================
    local contentFrame = Instance.new("Frame", appContent)
    contentFrame.Size = UDim2.new(1, 0, 0, 0)
    contentFrame.AutomaticSize = Enum.AutomaticSize.Y
    contentFrame.BackgroundTransparency = 1
    contentFrame.LayoutOrder = 1

    -- FIX: UIListLayout supaya card tidak overlap
    local listLayout = Instance.new("UIListLayout", contentFrame)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.Padding = UDim.new(0, 8)
    
    -- ==================== UPDATE SERVER LIST ====================
    local servers = {
        {
            name = "Server Utama",
            jobId = "038b309b-1d52-4f8f-8b90-e9528a0f3bcf",
            color = Color3.fromRGB(0, 200, 100),
            icon = "1"
        },
        {
            name = "Server Kedua",
            jobId = "045e98bc-3964-4bba-ad9e-7907c5c4a605",
            color = Color3.fromRGB(80, 150, 255),
            icon = "2"
        },
        {
            name = "Server Ketiga",
            jobId = "b2fc3fec-ebdb-4044-adf7-c3e57280be99", -- GANTI dengan Job ID baru
            color = Color3.fromRGB(255, 150, 50),
            icon = "3"
        }
    }
    
    -- Filter hanya server yang JOB ID-nya valid (tidak kosong dan mengandung "-")
    local activeServers = {}
    for _, server in ipairs(servers) do
        if server.jobId and server.jobId ~= "" and server.jobId:find("-") then
            table.insert(activeServers, server)
        end
    end
    
    local currentJobId = game.JobId
    
    -- ==================== CURRENT SERVER INFO ====================
    local infoCard = Instance.new("Frame", contentFrame)
    infoCard.Size = UDim2.new(1, 0, 0, 40)
    infoCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    infoCard.LayoutOrder = 0  -- FIX: pastikan infoCard di atas
    corner(infoCard, 12)
    stroke(infoCard, Color3.fromRGB(225, 225, 230), 1, 0.3)
    
    -- Cek di server mana player berada
    local currentServerName = "Server Lain"
    local currentServerColor = Color3.fromRGB(150, 150, 150)
    
    for _, server in ipairs(activeServers) do
        if server.jobId == currentJobId then
            currentServerName = server.name
            currentServerColor = server.color
            break
        end
    end
    
    local infoTitle = Instance.new("TextLabel", infoCard)
    infoTitle.Size = UDim2.new(1, -20, 1, 0)
    infoTitle.Position = UDim2.new(0, 10, 0, 0)
    infoTitle.BackgroundTransparency = 1
    infoTitle.Text = "📍 " .. currentServerName
    infoTitle.TextColor3 = currentServerColor
    infoTitle.Font = Enum.Font.GothamBlack
    infoTitle.TextSize = 12
    infoTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    -- ==================== RENDER SERVERS ====================
    for i, server in ipairs(activeServers) do
        local isCurrentServer = (server.jobId == currentJobId)
        
        local card = Instance.new("Frame", contentFrame)
        card.Size = UDim2.new(1, 0, 0, 80)
        card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        card.LayoutOrder = i  -- FIX: LayoutOrder mulai dari 1, di bawah infoCard
        corner(card, 14)
        
        if isCurrentServer then
            stroke(card, Color3.fromRGB(0, 255, 100), 3, 0)
        else
            stroke(card, Color3.fromRGB(225, 225, 230), 1, 0.3)
        end
        
        -- Number badge
        local numBadge = Instance.new("Frame", card)
        numBadge.Size = UDim2.new(0, 40, 0, 40)
        numBadge.Position = UDim2.new(0, 16, 0.5, -20)
        numBadge.BackgroundColor3 = server.color
        numBadge.BackgroundTransparency = 0.85
        corner(numBadge, 100)
        
        local numText = Instance.new("TextLabel", numBadge)
        numText.Size = UDim2.new(1, 0, 1, 0)
        numText.BackgroundTransparency = 1
        numText.Text = server.icon
        numText.TextColor3 = server.color
        numText.Font = Enum.Font.GothamBlack
        numText.TextSize = 18
        
        -- Server name
        local nameLbl = Instance.new("TextLabel", card)
        nameLbl.Size = UDim2.new(1, -150, 0, 22)
        nameLbl.Position = UDim2.new(0, 64, 0, 12)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = server.name
        nameLbl.TextColor3 = T.Text
        nameLbl.Font = Enum.Font.GothamBlack
        nameLbl.TextSize = 14
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Status
        local statusLbl = Instance.new("TextLabel", card)
        statusLbl.Size = UDim2.new(1, -150, 0, 16)
        statusLbl.Position = UDim2.new(0, 64, 0, 36)
        statusLbl.BackgroundTransparency = 1
        statusLbl.Text = isCurrentServer and "✅ ANDA DISINI" or "🔹 Siap Join"
        statusLbl.TextColor3 = isCurrentServer and Color3.fromRGB(0, 255, 100) or server.color
        statusLbl.Font = Enum.Font.GothamBold
        statusLbl.TextSize = 9
        statusLbl.TextXAlignment = Enum.TextXAlignment.Left
        
        -- JOIN BUTTON
        if not isCurrentServer then
            local joinBtn = Instance.new("TextButton", card)
            joinBtn.Size = UDim2.new(0, 75, 0, 36)
            joinBtn.Position = UDim2.new(1, -88, 0.5, -18)
            joinBtn.BackgroundColor3 = server.color
            joinBtn.Text = "JOIN"
            joinBtn.TextColor3 = Color3.new(1, 1, 1)
            joinBtn.Font = Enum.Font.GothamBlack
            joinBtn.TextSize = 13
            joinBtn.AutoButtonColor = false
            corner(joinBtn, 9)
            pressFX(joinBtn)
            
            joinBtn.MouseButton1Click:Connect(function()
                joinBtn.Text = "..."
                joinBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
                
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.jobId)
                end)
                
                task.wait(1.5)
                joinBtn.Text = "JOIN"
                joinBtn.BackgroundColor3 = server.color
            end)
        end
    end
    
    -- Info update timestamp
    local infoUpdate = Instance.new("TextLabel", contentFrame)
    infoUpdate.Size = UDim2.new(1, 0, 0, 30)
    infoUpdate.BackgroundTransparency = 1
    infoUpdate.LayoutOrder = 99
    infoUpdate.Text = "Server diupdate: " .. os.date("%d/%m %H:%M")
    infoUpdate.TextColor3 = Color3.fromRGB(160, 160, 160)
    infoUpdate.Font = Enum.Font.Gotham
    infoUpdate.TextSize = 8
    infoUpdate.TextXAlignment = Enum.TextXAlignment.Center
end

-- ================= WHO'S ONLINE APP =================
local function openWhoOnlineApp()
    -- HEADER
    local headerCard = Instance.new("Frame", appContent)
    headerCard.Size = UDim2.new(1, 0, 0, 50)
    headerCard.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    headerCard.LayoutOrder = 0
    corner(headerCard, 14)

    local headerGradient = Instance.new("UIGradient", headerCard)
    headerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 42)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 24))
    })
    headerGradient.Rotation = 135

    local headerAccent = Instance.new("Frame", headerCard)
    headerAccent.Size = UDim2.new(1, 0, 0, 2)
    headerAccent.BackgroundColor3 = Color3.fromRGB(0, 220, 100)
    corner(headerAccent, 1)

    local headerTitle = Instance.new("TextLabel", headerCard)
    headerTitle.Size = UDim2.new(1, -24, 0, 22)
    headerTitle.Position = UDim2.new(0, 12, 0, 6)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "🟢 Who's Online"
    headerTitle.TextColor3 = Color3.new(1, 1, 1)
    headerTitle.Font = Enum.Font.GothamBlack
    headerTitle.TextSize = 14
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left

    local headerSub = Instance.new("TextLabel", headerCard)
    headerSub.Size = UDim2.new(1, -24, 0, 14)
    headerSub.Position = UDim2.new(0, 12, 0, 30)
    headerSub.BackgroundTransparency = 1
    headerSub.Text = IS_DEV and "DEV MODE — Pull member ke server kamu" or "Member yang sedang online"
    headerSub.TextColor3 = IS_DEV and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(160, 160, 180)
    headerSub.Font = Enum.Font.GothamBold
    headerSub.TextSize = 8
    headerSub.TextXAlignment = Enum.TextXAlignment.Left

    -- Refresh button
    local refreshBtn = Instance.new("TextButton", headerCard)
    refreshBtn.Size = UDim2.new(0, 64, 0, 24)
    refreshBtn.Position = UDim2.new(1, -76, 0.5, -12)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    refreshBtn.Text = "Refresh"
    refreshBtn.TextColor3 = Color3.new(1, 1, 1)
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.TextSize = 10
    refreshBtn.AutoButtonColor = false
    corner(refreshBtn, 8)
    pressFX(refreshBtn)

    -- DEV: Pull All button (hanya muncul kalau dev)
    local pullAllBtn = nil
    if IS_DEV then
        pullAllBtn = Instance.new("TextButton", appContent)
        pullAllBtn.Size = UDim2.new(1, 0, 0, 36)
        pullAllBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 20)
        pullAllBtn.Text = "📥 PULL ALL MEMBERS"
        pullAllBtn.TextColor3 = Color3.new(1, 1, 1)
        pullAllBtn.Font = Enum.Font.GothamBlack
        pullAllBtn.TextSize = 12
        pullAllBtn.AutoButtonColor = false
        pullAllBtn.LayoutOrder = 0
        corner(pullAllBtn, 10)
        pressFX(pullAllBtn)
    end

    -- List holder
    local listHolder = Instance.new("Frame", appContent)
    listHolder.Size = UDim2.new(1, 0, 0, 0)
    listHolder.AutomaticSize = Enum.AutomaticSize.Y
    listHolder.BackgroundTransparency = 1
    listHolder.LayoutOrder = 1

    local listLayout = Instance.new("UIListLayout", listHolder)
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Render function
    local function renderOnlinePlayers()
        for _, c in ipairs(listHolder:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end

        -- Loading
        local loadCard = Instance.new("Frame", listHolder)
        loadCard.Size = UDim2.new(1, 0, 0, 36)
        loadCard.BackgroundColor3 = Color3.fromRGB(248, 248, 250)
        loadCard.LayoutOrder = 0
        corner(loadCard, 10)

        local loadText = Instance.new("TextLabel", loadCard)
        loadText.Size = UDim2.new(1, 0, 1, 0)
        loadText.BackgroundTransparency = 1
        loadText.Text = "Fetching data..."
        loadText.TextColor3 = Color3.fromRGB(140, 140, 150)
        loadText.Font = Enum.Font.Gotham
        loadText.TextSize = 10

        task.spawn(function()
            local data = firebaseGet("/online_players")
            pcall(function() loadCard:Destroy() end)

            local now = os.time()
            local onlineList = {}

            if data and type(data) == "table" then
                for _, player in pairs(data) do
                    if player.timestamp and (now - player.timestamp) < 120 then
                        table.insert(onlineList, player)
                    end
                end
            end

            -- Sort: dev dulu, lalu alphabetical
            table.sort(onlineList, function(a, b)
                if a.isDev ~= b.isDev then return a.isDev end
                return (a.username or "") < (b.username or "")
            end)

            -- Counter
            local counterFrame = Instance.new("Frame", listHolder)
            counterFrame.Size = UDim2.new(1, 0, 0, 22)
            counterFrame.BackgroundTransparency = 1
            counterFrame.LayoutOrder = 0

            local counterText = Instance.new("TextLabel", counterFrame)
            counterText.Size = UDim2.new(1, 0, 1, 0)
            counterText.BackgroundTransparency = 1
            counterText.Text = #onlineList .. " member online sekarang"
            counterText.TextColor3 = Color3.fromRGB(0, 200, 80)
            counterText.Font = Enum.Font.GothamBold
            counterText.TextSize = 10
            counterText.TextXAlignment = Enum.TextXAlignment.Left

            -- Pull All handler
            if IS_DEV and pullAllBtn then
                pullAllBtn.MouseButton1Click:Connect(function()
                    local count = 0
                    for _, player in ipairs(onlineList) do
                        local isMe = tostring(player.userId) == tostring(LocalPlayer.UserId)
                        if not isMe then
                            pcall(function() sendPullRequest(player.userId, player.username) end)
                            count = count + 1
                            task.wait(0.3) -- jeda biar ga spam firebase
                        end
                    end
                    pullAllBtn.Text = "✅ Sent to " .. count .. " members"
                    pullAllBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
                    showDynamicNotification("Pull sent to " .. count .. " members!", Color3.fromRGB(255, 140, 20))
                    task.wait(3)
                    pullAllBtn.Text = "📥 PULL ALL MEMBERS"
                    pullAllBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 20)
                end)
            end

            -- Empty state
            if #onlineList == 0 then
                local emptyCard = Instance.new("Frame", listHolder)
                emptyCard.Size = UDim2.new(1, 0, 0, 90)
                emptyCard.BackgroundColor3 = Color3.fromRGB(248, 248, 250)
                emptyCard.LayoutOrder = 1
                corner(emptyCard, 14)
                stroke(emptyCard, Color3.fromRGB(220, 220, 225), 1, 0.3)

                local emptyText = Instance.new("TextLabel", emptyCard)
                emptyText.Size = UDim2.new(1, 0, 1, 0)
                emptyText.BackgroundTransparency = 1
                emptyText.Text = "Belum ada member online\nLoad script dulu di game!"
                emptyText.TextColor3 = Color3.fromRGB(140, 140, 150)
                emptyText.Font = Enum.Font.GothamBold
                emptyText.TextSize = 12
                emptyText.TextWrapped = true
                return
            end

            -- Render tiap player
            for i, player in ipairs(onlineList) do
                local isSameServer = (player.jobId == game.JobId)
                local isSamePlace = (tostring(player.placeId) == tostring(game.PlaceId))
                local isMe = (tostring(player.userId) == tostring(LocalPlayer.UserId))
                local isPlayerDev = player.isDev == true

                -- Tinggi card: dev punya PULL button jadi lebih tinggi
                local cardHeight = (IS_DEV and not isMe) and 100 or 86

                local card = Instance.new("Frame", listHolder)
                card.Size = UDim2.new(1, 0, 0, cardHeight)
                card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                card.LayoutOrder = i
                corner(card, 14)

                -- Border warna berdasarkan status
                if isMe then
                    stroke(card, Color3.fromRGB(80, 150, 255), 2, 0)
                elseif isSameServer then
                    stroke(card, Color3.fromRGB(0, 220, 100), 2, 0)
                elseif isPlayerDev then
                    stroke(card, Color3.fromRGB(255, 200, 50), 2, 0)
                else
                    stroke(card, Color3.fromRGB(225, 225, 230), 1, 0.3)
                end

                -- Avatar
                local avatarFrame = Instance.new("Frame", card)
                avatarFrame.Size = UDim2.new(0, 52, 0, 52)
                avatarFrame.Position = UDim2.new(0, 10, 0.5, -26)
                avatarFrame.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
                corner(avatarFrame, 100)

                local avatarImg = Instance.new("ImageLabel", avatarFrame)
                avatarImg.Size = UDim2.new(1, -4, 1, -4)
                avatarImg.Position = UDim2.new(0.5, 0, 0.5, 0)
                avatarImg.AnchorPoint = Vector2.new(0.5, 0.5)
                avatarImg.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
                avatarImg.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. (player.userId or 0) .. "&width=100&height=100&format=png"
                corner(avatarImg, 100)

                -- Online dot
                local dot = Instance.new("Frame", card)
                dot.Size = UDim2.new(0, 10, 0, 10)
                dot.Position = UDim2.new(0, 48, 0.5, 14)
                dot.BackgroundColor3 = Color3.fromRGB(0, 220, 100)
                corner(dot, 100)
                stroke(dot, Color3.fromRGB(255, 255, 255), 2, 0)

                -- DEV badge kecil di atas avatar
                if isPlayerDev then
                    local devTag = Instance.new("Frame", card)
                    devTag.Size = UDim2.new(0, 28, 0, 12)
                    devTag.Position = UDim2.new(0, 10, 0, 8)
                    devTag.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
                    devTag.BackgroundTransparency = 0.2
                    devTag.ZIndex = 5
                    corner(devTag, 6)

                    local devTagText = Instance.new("TextLabel", devTag)
                    devTagText.Size = UDim2.new(1, 0, 1, 0)
                    devTagText.BackgroundTransparency = 1
                    devTagText.Text = "DEV"
                    devTagText.TextColor3 = Color3.fromRGB(180, 120, 0)
                    devTagText.Font = Enum.Font.GothamBlack
                    devTagText.TextSize = 7
                    devTagText.ZIndex = 6
                end

                -- Name
                local nameLbl = Instance.new("TextLabel", card)
                nameLbl.Size = UDim2.new(1, -180, 0, 20)
                nameLbl.Position = UDim2.new(0, 70, 0, 10)
                nameLbl.BackgroundTransparency = 1
                nameLbl.Text = (isMe and "(You) " or "") .. (player.displayName or player.username or "Unknown")
                nameLbl.TextColor3 = Color3.fromRGB(30, 30, 30)
                nameLbl.Font = Enum.Font.GothamBlack
                nameLbl.TextSize = 13
                nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                nameLbl.TextTruncate = Enum.TextTruncate.AtEnd

                -- Username
                local userLbl = Instance.new("TextLabel", card)
                userLbl.Size = UDim2.new(1, -180, 0, 14)
                userLbl.Position = UDim2.new(0, 70, 0, 30)
                userLbl.BackgroundTransparency = 1
                userLbl.Text = "@" .. (player.username or "?")
                userLbl.TextColor3 = Color3.fromRGB(120, 120, 120)
                userLbl.Font = Enum.Font.Gotham
                userLbl.TextSize = 9
                userLbl.TextXAlignment = Enum.TextXAlignment.Left

                -- Server info
                local serverLbl = Instance.new("TextLabel", card)
                serverLbl.Size = UDim2.new(1, -180, 0, 14)
                serverLbl.Position = UDim2.new(0, 70, 0, 44)
                serverLbl.BackgroundTransparency = 1
                serverLbl.Text = isSameServer and "✅ Server sama!" or (isSamePlace and "🔹 Map sama, beda server" or "🌐 " .. (player.placeName or "Unknown map"))
                serverLbl.TextColor3 = isSameServer and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(100, 100, 120)
                serverLbl.Font = Enum.Font.GothamBold
                serverLbl.TextSize = 8
                serverLbl.TextXAlignment = Enum.TextXAlignment.Left

                -- Last seen
                local elapsed = now - (player.timestamp or now)
                local elapsedText = elapsed < 60 and (elapsed .. "s ago") or (math.floor(elapsed / 60) .. "m ago")
                local timeLbl = Instance.new("TextLabel", card)
                timeLbl.Size = UDim2.new(1, -180, 0, 12)
                timeLbl.Position = UDim2.new(0, 70, 0, 58)
                timeLbl.BackgroundTransparency = 1
                timeLbl.Text = "Updated: " .. elapsedText
                timeLbl.TextColor3 = Color3.fromRGB(160, 160, 160)
                timeLbl.Font = Enum.Font.Gotham
                timeLbl.TextSize = 7
                timeLbl.TextXAlignment = Enum.TextXAlignment.Left

                -- ===== BUTTONS =====
                if not isMe then
                    -- JOIN button (map sama, beda server)
                    if isSamePlace and not isSameServer then
                        local joinBtn = Instance.new("TextButton", card)
                        joinBtn.Size = UDim2.new(0, 65, 0, 28)
                        joinBtn.Position = UDim2.new(1, -76, 0, 10)
                        joinBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
                        joinBtn.Text = "JOIN"
                        joinBtn.TextColor3 = Color3.new(1, 1, 1)
                        joinBtn.Font = Enum.Font.GothamBlack
                        joinBtn.TextSize = 11
                        joinBtn.AutoButtonColor = false
                        corner(joinBtn, 8)
                        pressFX(joinBtn)
                        joinBtn.MouseButton1Click:Connect(function()
                            joinBtn.Text = "..."
                            joinBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
                            pcall(function()
                                TeleportService:TeleportToPlaceInstance(player.placeId, player.jobId)
                            end)
                            task.wait(1.5)
                            joinBtn.Text = "JOIN"
                            joinBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
                        end)

                    -- Beda map: label
                    else
                        local diffMap = Instance.new("TextLabel", card)
                        diffMap.Size = UDim2.new(0, 65, 0, 28)
                        diffMap.Position = UDim2.new(1, -76, 0, 10)
                        diffMap.BackgroundColor3 = Color3.fromRGB(245, 245, 248)
                        diffMap.Text = "Beda Map"
                        diffMap.TextColor3 = Color3.fromRGB(160, 160, 160)
                        diffMap.Font = Enum.Font.GothamBold
                        diffMap.TextSize = 8
                        corner(diffMap, 8)
                        stroke(diffMap, Color3.fromRGB(220, 220, 225), 1, 0.3)
                    end

                    -- PULL button (dev only, semua player kecuali diri sendiri)
                    if IS_DEV then
                        local pullBtn = Instance.new("TextButton", card)
                        pullBtn.Size = UDim2.new(0, 65, 0, 28)
                        pullBtn.Position = UDim2.new(1, -76, 0, 46)
                        pullBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 20)
                        pullBtn.Text = "📥 PULL"
                        pullBtn.TextColor3 = Color3.new(1, 1, 1)
                        pullBtn.Font = Enum.Font.GothamBlack
                        pullBtn.TextSize = 10
                        pullBtn.AutoButtonColor = false
                        corner(pullBtn, 8)
                        pressFX(pullBtn)
                        pullBtn.MouseButton1Click:Connect(function()
                            pullBtn.Text = "Sent!"
                            pullBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
                            pcall(function() sendPullRequest(player.userId, player.username) end)
                            showDynamicNotification("Pull sent to " .. (player.displayName or player.username or "?"), Color3.fromRGB(255, 140, 20))
                            task.wait(2)
                            pullBtn.Text = "📥 PULL"
                            pullBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 20)
                        end)
                    end
                end
            end

            -- Timestamp
            local stampFrame = Instance.new("Frame", listHolder)
            stampFrame.Size = UDim2.new(1, 0, 0, 20)
            stampFrame.BackgroundTransparency = 1
            stampFrame.LayoutOrder = 999

            local stampText = Instance.new("TextLabel", stampFrame)
            stampText.Size = UDim2.new(1, 0, 1, 0)
            stampText.BackgroundTransparency = 1
            stampText.Text = "Last refresh: " .. os.date("%H:%M:%S")
            stampText.TextColor3 = Color3.fromRGB(180, 180, 180)
            stampText.Font = Enum.Font.Gotham
            stampText.TextSize = 8
            stampText.TextXAlignment = Enum.TextXAlignment.Center
        end)
    end

    -- Auto refresh setiap 30 detik selama di app ini
    task.spawn(function()
        while appTitle.Text == "Who's Online" do
            renderOnlinePlayers()
            task.wait(30)
        end
    end)

    refreshBtn.MouseButton1Click:Connect(function()
        renderOnlinePlayers()
        showDynamicNotification("Refreshed!", Color3.fromRGB(0, 200, 80))
    end)
end

-- ================= MESSAGE SYSTEM (FIXED + MEMBER LIST + REAL CHAT) =================
-- Taruh setelah WhoOnline App

local activeMessageNotif = nil
local MESSAGE_CHECK_INTERVAL = 5
local openedConversation = nil -- userId lawan chat yang lagi dibuka, nil = di list
local chatMessageCache = {}     -- cache biar ga fetch ulang tiap keystroke
local chatAutoRefresh = false

-- ================= MEMBER LIST =================
local MEMBERS = {
    {username = "AlfreadR0rw", displayName = "alfread", role = "Developer", color = Color3.fromRGB(255, 200, 50)},
    {username = "matchapii04", displayName = "matchapii04", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "akbarfbrynn", displayName = "akbarfbrynn", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "BLAZEBUBz", displayName = "BLAZEBUBz", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "LexxSugar7", displayName = "LexxSugar7", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "Dap_Mahatir", displayName = "Dap_Mahatir", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "Jv4n00X", displayName = "Jv4n00X", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "Hx8shve3", displayName = "Hx8shve3", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "Chinatsu0263", displayName = "Chinatsu0263", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "dimasbani_9", displayName = "dimasbani_9", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "IronHuijsen", displayName = "IronHuijsen", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "KooJagoo", displayName = "KooJagoo", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "rstuaj1", displayName = "rstuaj1", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "mouri01045", displayName = "mouri01045", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "stevalone7", displayName = "stevalone7", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "ziroadalahpokoknya", displayName = "ziroadalahpokoknya", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "AlbernTheGreat7", displayName = "AlbernTheGreat7", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "SweetyCoconut3", displayName = "SweetyCoconut3", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "neoo290904", displayName = "neoo290904", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "pororo_iki", displayName = "pororo_iki", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "syahidhc", displayName = "syahidhc", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "cyaa_floiyrine", displayName = "cyaa_floiyrine", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "DzyanV2", displayName = "DzyanV2", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "ManSpicy", displayName = "ManSpicy", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "Oruzukii", displayName = "Oruzukii", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "jeyocal", displayName = "jeyocal", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "yellbubb", displayName = "yellbubb", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "Xetan01", displayName = "Xetan01", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "beychullo", displayName = "beychullo", role = "Member", color = Color3.fromRGB(80, 150, 255)},
    {username = "Grace_101253", displayName = "Grace_101253", role = "Member", color = Color3.fromRGB(80, 150, 255)},
}

-- ================= HELPER: cari member by userId =================
local function findMemberByUserId(userId)
    -- coba cari player yang online dulu buat dapetin username
    for _, p in pairs(Players:GetPlayers()) do
        if p.UserId == userId then
            for _, m in ipairs(MEMBERS) do
                if m.username:lower() == p.Name:lower() then
                    return m, p
                end
            end
            return {username = p.Name, displayName = p.DisplayName, color = Color3.fromRGB(80,150,255)}, p
        end
    end
    -- fallback: gak online, gak tau namanya, generic
    return {username = "User"..tostring(userId), displayName = "User "..tostring(userId), color = Color3.fromRGB(80,150,255)}, nil
end

-- ================= SEND MESSAGE =================
function sendMessage(toUserId, text)
    if not text or text:match("^%s*$") then return end
    local msgId = "msg_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999))

    -- simpan pesan di KEDUA sisi (biar kedua orang bisa lihat riwayat yang sama)
    local msgData = {
        from        = LocalPlayer.Name,
        fromDisplay = LocalPlayer.DisplayName,
        fromId      = LocalPlayer.UserId,
        toId        = toUserId,
        text        = text,
        timestamp   = os.time(),
        read        = false
    }

    -- convo key selalu urut biar konsisten (userId kecil dulu)
    local a, b = LocalPlayer.UserId, toUserId
    local convoKey = (a < b) and (a .. "_" .. b) or (b .. "_" .. a)

    firebaseSet("/conversations/" .. convoKey .. "/" .. msgId, msgData)

    firebaseSet("/message_notifs/" .. tostring(toUserId), {
        from        = LocalPlayer.Name,
        fromDisplay = LocalPlayer.DisplayName,
        fromId      = LocalPlayer.UserId,
        text        = text,
        timestamp   = os.time()
    })
end

-- ================= FETCH CONVERSATION =================
local function getConvoKey(userIdA, userIdB)
    local a, b = userIdA, userIdB
    return (a < b) and (a .. "_" .. b) or (b .. "_" .. a)
end

local function fetchConversation(otherUserId)
    local convoKey = getConvoKey(LocalPlayer.UserId, otherUserId)
    local raw = firebaseGet("/conversations/" .. convoKey) or {}
    local msgs = {}
    if type(raw) == "table" then
        for _, m in pairs(raw) do
            if type(m) == "table" and m.text then
                table.insert(msgs, m)
            end
        end
    end
    table.sort(msgs, function(x, y) return (x.timestamp or 0) < (y.timestamp or 0) end)
    return msgs
end

-- ================= MESSAGE NOTIFICATION (popup singkat) =================
function showMessageNotif(fromDisplay, fromId, text)
    if activeMessageNotif then
        pcall(function() activeMessageNotif:Destroy() end)
        activeMessageNotif = nil
    end

    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = "MessageNotif"
    notifGui.ResetOnSpawn = false
    notifGui.IgnoreGuiInset = true
    notifGui.DisplayOrder = 9998
    notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    pcall(function() notifGui.Parent = game:GetService("CoreGui") end)
    if not notifGui.Parent then notifGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    activeMessageNotif = notifGui

    local pill = Instance.new("Frame", notifGui)
    pill.Size = UDim2.new(0, 50, 0, 24)
    pill.Position = UDim2.new(0.5, -25, 0, 8)
    pill.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    pill.BorderSizePixel = 0
    pill.ZIndex = 9999
    corner(pill, 12)
    stroke(pill, Color3.fromRGB(40, 40, 45), 1, 0)

    tween(pill, {Size = UDim2.new(0, 280, 0, 28)}, 0.35, Enum.EasingStyle.Quart)
    task.wait(0.35)

    local nameLbl = Instance.new("TextLabel", pill)
    nameLbl.Size = UDim2.new(1, -16, 0, 14)
    nameLbl.Position = UDim2.new(0, 8, 0, 2)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = "💬 " .. fromDisplay
    nameLbl.TextColor3 = Color3.new(1, 1, 1)
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 10
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex = 10000

    local previewLbl = Instance.new("TextLabel", pill)
    previewLbl.Size = UDim2.new(1, -16, 0, 12)
    previewLbl.Position = UDim2.new(0, 8, 0, 16)
    previewLbl.BackgroundTransparency = 1
    previewLbl.Text = #text > 35 and text:sub(1, 35) .. "..." or text
    previewLbl.TextColor3 = Color3.fromRGB(150, 150, 155)
    previewLbl.Font = Enum.Font.Gotham
    previewLbl.TextSize = 9
    previewLbl.TextXAlignment = Enum.TextXAlignment.Left
    previewLbl.ZIndex = 10000

    local tapBtn = Instance.new("TextButton", pill)
    tapBtn.Size = UDim2.new(1, 0, 1, 0)
    tapBtn.BackgroundTransparency = 1
    tapBtn.Text = ""
    tapBtn.ZIndex = 10002

    tapBtn.MouseButton1Click:Connect(function()
        tween(pill, {Size = UDim2.new(0, 50, 0, 24)}, 0.25)
        task.wait(0.3)
        pcall(function() notifGui:Destroy() end)
        activeMessageNotif = nil
        openedConversation = fromId
        openApp("Messages", openMessageApp)
    end)

    task.delay(6, function()
        if notifGui.Parent then
            tween(pill, {Size = UDim2.new(0, 50, 0, 24)}, 0.25)
            task.wait(0.3)
            pcall(function() notifGui:Destroy() end)
            activeMessageNotif = nil
        end
    end)
end

-- ================= MESSAGE CHECKER =================
function checkMessageNotif()
    while true do
        task.wait(MESSAGE_CHECK_INTERVAL)
        local notif = firebaseGet("/message_notifs/" .. tostring(LocalPlayer.UserId))
        if notif and type(notif) == "table" and notif.from then
            if tostring(notif.fromId) ~= tostring(LocalPlayer.UserId) then
                firebaseDelete("/message_notifs/" .. tostring(LocalPlayer.UserId))
                showMessageNotif(notif.fromDisplay or notif.from, notif.fromId, notif.text)

                -- kalau lagi buka percakapan sama orang itu, auto refresh bubble-nya
                if appTitle.Text == "Messages" and openedConversation == notif.fromId then
                    refreshCurr()
                end
            end
        end
    end
end

-- ================= RENDER: HALAMAN CHAT (BUBBLE) =================
local function renderChatPage(otherUserId)
    local member, onlinePlayer = findMemberByUserId(otherUserId)

    -- Header dengan tombol back ke list
    local headerCard = Instance.new("Frame", appContent)
    headerCard.Size = UDim2.new(1, 0, 0, 46)
    headerCard.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    headerCard.LayoutOrder = 0
    corner(headerCard, 14)

    local backBtn2 = Instance.new("TextButton", headerCard)
    backBtn2.Size = UDim2.new(0, 40, 0, 32)
    backBtn2.Position = UDim2.new(0, 6, 0.5, -16)
    backBtn2.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    backBtn2.Text = "‹"
    backBtn2.TextColor3 = Color3.new(1, 1, 1)
    backBtn2.Font = Enum.Font.GothamBlack
    backBtn2.TextSize = 20
    backBtn2.AutoButtonColor = false
    corner(backBtn2, 8)
    pressFX(backBtn2)
    backBtn2.MouseButton1Click:Connect(function()
        openedConversation = nil
        refreshCurr()
    end)

    local avatar2 = Instance.new("ImageLabel", headerCard)
    avatar2.Size = UDim2.new(0, 32, 0, 32)
    avatar2.Position = UDim2.new(0, 52, 0.5, -16)
    avatar2.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    avatar2.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(otherUserId) .. "&width=100&height=100&format=png"
    corner(avatar2, 100)

    local headerName = Instance.new("TextLabel", headerCard)
    headerName.Size = UDim2.new(1, -170, 0, 20)
    headerName.Position = UDim2.new(0, 92, 0, 6)
    headerName.BackgroundTransparency = 1
    headerName.Text = member.displayName or member.username
    headerName.TextColor3 = Color3.new(1, 1, 1)
    headerName.Font = Enum.Font.GothamBlack
    headerName.TextSize = 13
    headerName.TextXAlignment = Enum.TextXAlignment.Left
    headerName.TextTruncate = Enum.TextTruncate.AtEnd

    local headerStatus = Instance.new("TextLabel", headerCard)
    headerStatus.Size = UDim2.new(1, -170, 0, 14)
    headerStatus.Position = UDim2.new(0, 92, 0, 24)
    headerStatus.BackgroundTransparency = 1
    headerStatus.Text = onlinePlayer and "Online di server ini" or "Offline"
    headerStatus.TextColor3 = onlinePlayer and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(140, 140, 140)
    headerStatus.Font = Enum.Font.Gotham
    headerStatus.TextSize = 9
    headerStatus.TextXAlignment = Enum.TextXAlignment.Left

    local refreshBtn2 = Instance.new("TextButton", headerCard)
    refreshBtn2.Size = UDim2.new(0, 32, 0, 32)
    refreshBtn2.Position = UDim2.new(1, -40, 0.5, -16)
    refreshBtn2.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    refreshBtn2.Text = "↻"
    refreshBtn2.TextColor3 = Color3.new(1, 1, 1)
    refreshBtn2.Font = Enum.Font.GothamBold
    refreshBtn2.TextSize = 16
    refreshBtn2.AutoButtonColor = false
    corner(refreshBtn2, 8)
    pressFX(refreshBtn2)
    refreshBtn2.MouseButton1Click:Connect(function()
        refreshCurr()
    end)

    -- Bubble area
    local chatScroll = Instance.new("ScrollingFrame", appContent)
    chatScroll.Size = UDim2.new(1, 0, 0, 320)
    chatScroll.BackgroundTransparency = 1
    chatScroll.BorderSizePixel = 0
    chatScroll.ScrollBarThickness = 3
    chatScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    chatScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    chatScroll.LayoutOrder = 1

    local bubbleLayout = Instance.new("UIListLayout", chatScroll)
    bubbleLayout.Padding = UDim.new(0, 6)
    bubbleLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local loadingLbl2 = Instance.new("TextLabel", chatScroll)
    loadingLbl2.Size = UDim2.new(1, 0, 0, 30)
    loadingLbl2.BackgroundTransparency = 1
    loadingLbl2.Text = "Memuat percakapan..."
    loadingLbl2.TextColor3 = T.Text2
    loadingLbl2.Font = Enum.Font.Gotham
    loadingLbl2.TextSize = 11

    task.spawn(function()
        local msgs = fetchConversation(otherUserId)
        pcall(function() loadingLbl2:Destroy() end)

        if not chatScroll.Parent then return end -- user udah pindah halaman

        if #msgs == 0 then
            local emptyLbl = Instance.new("TextLabel", chatScroll)
            emptyLbl.Size = UDim2.new(1, 0, 0, 60)
            emptyLbl.BackgroundTransparency = 1
            emptyLbl.Text = "Belum ada pesan.\nMulai chat sekarang!"
            emptyLbl.TextColor3 = T.Text2
            emptyLbl.Font = Enum.Font.Gotham
            emptyLbl.TextSize = 11
            emptyLbl.TextWrapped = true
        else
            for i, m in ipairs(msgs) do
                local isMine = tostring(m.fromId) == tostring(LocalPlayer.UserId)

                local row = Instance.new("Frame", chatScroll)
                row.Size = UDim2.new(1, 0, 0, 0)
                row.AutomaticSize = Enum.AutomaticSize.Y
                row.BackgroundTransparency = 1
                row.LayoutOrder = i

                local bubble = Instance.new("Frame", row)
                bubble.Size = UDim2.new(0, 0, 0, 0)
                bubble.AutomaticSize = Enum.AutomaticSize.XY
                bubble.BackgroundColor3 = isMine and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(230, 230, 235)
                bubble.Position = isMine and UDim2.new(1, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
                bubble.AnchorPoint = isMine and Vector2.new(1, 0) or Vector2.new(0, 0)
                corner(bubble, 12)

                local pad = Instance.new("UIPadding", bubble)
                pad.PaddingLeft = UDim.new(0, 10)
                pad.PaddingRight = UDim.new(0, 10)
                pad.PaddingTop = UDim.new(0, 6)
                pad.PaddingBottom = UDim.new(0, 6)

                local maxW = Instance.new("UISizeConstraint", bubble)
                maxW.MaxSize = Vector2.new(220, math.huge)

                local msgText = Instance.new("TextLabel", bubble)
                msgText.Size = UDim2.new(1, 0, 0, 0)
                msgText.AutomaticSize = Enum.AutomaticSize.Y
                msgText.BackgroundTransparency = 1
                msgText.Text = m.text
                msgText.TextColor3 = isMine and Color3.new(1, 1, 1) or Color3.fromRGB(30, 30, 30)
                msgText.Font = Enum.Font.Gotham
                msgText.TextSize = 12
                msgText.TextWrapped = true
                msgText.TextXAlignment = isMine and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left

                local timeLbl2 = Instance.new("TextLabel", row)
                timeLbl2.Size = UDim2.new(1, 0, 0, 12)
                timeLbl2.BackgroundTransparency = 1
                timeLbl2.Text = os.date("%H:%M", m.timestamp or os.time())
                timeLbl2.TextColor3 = Color3.fromRGB(160, 160, 160)
                timeLbl2.Font = Enum.Font.Gotham
                timeLbl2.TextSize = 8
                timeLbl2.TextXAlignment = isMine and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
                timeLbl2.Position = UDim2.new(0, 0, 0, 0)

                -- reposisi timeLbl di bawah bubble otomatis via layout order tambahan
                local spacer = Instance.new("Frame", row)
                spacer.Size = UDim2.new(1, 0, 0, 2)
                spacer.BackgroundTransparency = 1
                spacer.LayoutOrder = 2
            end
        end

        task.wait(0.05)
        chatScroll.CanvasPosition = Vector2.new(0, chatScroll.CanvasSize.Y.Offset)
    end)

    -- Input row
    local inputRow = Instance.new("Frame", appContent)
    inputRow.Size = UDim2.new(1, 0, 0, 44)
    inputRow.BackgroundTransparency = 1
    inputRow.LayoutOrder = 2

    local inputBox = Instance.new("TextBox", inputRow)
    inputBox.Size = UDim2.new(1, -54, 1, 0)
    inputBox.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
    inputBox.PlaceholderText = "Ketik pesan..."
    inputBox.Text = ""
    inputBox.TextColor3 = Color3.fromRGB(30, 30, 30)
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = 12
    inputBox.ClearTextOnFocus = false
    corner(inputBox, 20)
    stroke(inputBox, Color3.fromRGB(215, 215, 220), 1, 0.3)

    local ip = Instance.new("UIPadding", inputBox)
    ip.PaddingLeft = UDim.new(0, 14)
    ip.PaddingRight = UDim.new(0, 14)

    local sendBtn2 = Instance.new("TextButton", inputRow)
    sendBtn2.Size = UDim2.new(0, 44, 0, 44)
    sendBtn2.Position = UDim2.new(1, -44, 0, 0)
    sendBtn2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    sendBtn2.Text = "↑"
    sendBtn2.TextColor3 = Color3.new(1, 1, 1)
    sendBtn2.Font = Enum.Font.GothamBlack
    sendBtn2.TextSize = 18
    sendBtn2.AutoButtonColor = false
    corner(sendBtn2, 100)
    pressFX(sendBtn2)

    local function doChatSend()
        local txt = inputBox.Text
        if txt == "" or txt:match("^%s*$") then return end
        inputBox.Text = ""
        pcall(function() sendMessage(otherUserId, txt) end)
        refreshCurr()
    end

    sendBtn2.MouseButton1Click:Connect(doChatSend)
    inputBox.FocusLost:Connect(function(enter) if enter then doChatSend() end end)
end

-- ================= RENDER: LIST MEMBER (INSTANT, NO BLOCKING LOAD) =================
local function renderMemberList()
    -- Header
    local headerCard = Instance.new("Frame", appContent)
    headerCard.Size = UDim2.new(1, 0, 0, 46)
    headerCard.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    headerCard.LayoutOrder = 0
    corner(headerCard, 14)

    local headerTitle = Instance.new("TextLabel", headerCard)
    headerTitle.Size = UDim2.new(1, -24, 0, 22)
    headerTitle.Position = UDim2.new(0, 14, 0, 6)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "Messages"
    headerTitle.TextColor3 = Color3.new(1, 1, 1)
    headerTitle.Font = Enum.Font.GothamBlack
    headerTitle.TextSize = 16
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left

    local contentFrame = Instance.new("Frame", appContent)
    contentFrame.Size = UDim2.new(1, 0, 0, 0)
    contentFrame.AutomaticSize = Enum.AutomaticSize.Y
    contentFrame.BackgroundTransparency = 1
    contentFrame.LayoutOrder = 1

    local listLayout = Instance.new("UIListLayout", contentFrame)
    listLayout.Padding = UDim.new(0, 4)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Simpan reference card per username, biar bisa diupdate tanpa re-render total
    local cardRefs = {}

    -- Fungsi bikin 1 card
    local function buildMemberCard(member, order, isOnlineHere)
        local isMe = (LocalPlayer.Name:lower() == member.username:lower())

        local card = Instance.new("TextButton", contentFrame)
        card.Size = UDim2.new(1, 0, 0, 56)
        card.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
        card.AutoButtonColor = false
        card.Text = ""
        card.LayoutOrder = order
        corner(card, 12)

        local accent = Instance.new("Frame", card)
        accent.Size = UDim2.new(0, 3, 1, -12)
        accent.Position = UDim2.new(0, 6, 0, 6)
        accent.BackgroundColor3 = member.color
        corner(accent, 2)

        local avatar = Instance.new("ImageLabel", card)
        avatar.Size = UDim2.new(0, 36, 0, 36)
        avatar.Position = UDim2.new(0, 14, 0.5, -18)
        avatar.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
        avatar.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
        corner(avatar, 100)

        local onlineDot = Instance.new("Frame", card)
        onlineDot.Size = UDim2.new(0, 10, 0, 10)
        onlineDot.Position = UDim2.new(0, 40, 0.5, 10)
        onlineDot.BackgroundColor3 = isOnlineHere and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(120, 120, 120)
        corner(onlineDot, 100)
        stroke(onlineDot, Color3.fromRGB(20, 20, 26), 2, 0)

        local nameLbl = Instance.new("TextLabel", card)
        nameLbl.Size = UDim2.new(1, -130, 0, 20)
        nameLbl.Position = UDim2.new(0, 56, 0, 10)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = (isMe and "(You) " or "") .. member.displayName
        nameLbl.TextColor3 = isOnlineHere and Color3.new(1, 1, 1) or Color3.fromRGB(150, 150, 150)
        nameLbl.Font = Enum.Font.GothamBlack
        nameLbl.TextSize = 12
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left

        local userLbl = Instance.new("TextLabel", card)
        userLbl.Size = UDim2.new(1, -130, 0, 14)
        userLbl.Position = UDim2.new(0, 56, 0, 30)
        userLbl.BackgroundTransparency = 1
        userLbl.Text = "@" .. member.username .. " · " .. member.role
        userLbl.TextColor3 = isOnlineHere and Color3.fromRGB(120, 120, 130) or Color3.fromRGB(100, 100, 100)
        userLbl.Font = Enum.Font.Gotham
        userLbl.TextSize = 8
        userLbl.TextXAlignment = Enum.TextXAlignment.Left

        local badge = Instance.new("Frame", card)
        badge.Size = UDim2.new(0, 55, 0, 14)
        badge.Position = UDim2.new(0, 56, 0, 42)
        badge.BackgroundColor3 = isOnlineHere and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(80, 80, 80)
        badge.BackgroundTransparency = 0.85
        corner(badge, 7)

        local badgeText = Instance.new("TextLabel", badge)
        badgeText.Size = UDim2.new(1, 0, 1, 0)
        badgeText.BackgroundTransparency = 1
        badgeText.Text = isOnlineHere and "ONLINE" or "OFFLINE"
        badgeText.TextColor3 = isOnlineHere and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(150, 150, 150)
        badgeText.Font = Enum.Font.GothamBold
        badgeText.TextSize = 7

        if not isMe then
            local chatBtn = Instance.new("TextButton", card)
            chatBtn.Size = UDim2.new(0, 50, 0, 24)
            chatBtn.Position = UDim2.new(1, -58, 0.5, -12)
            chatBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            chatBtn.Text = "Chat"
            chatBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
            chatBtn.Font = Enum.Font.GothamBlack
            chatBtn.TextSize = 9
            chatBtn.AutoButtonColor = false
            corner(chatBtn, 6)
            pressFX(chatBtn)

            chatBtn.MouseButton1Click:Connect(function()
                -- Cari userId member ini: kalau online pakai UserId asli, kalau tidak, coba tebak dari username via API bisa gagal.
                -- Solusi aman: kalau online, pakai UserId player. Kalau offline, tetap izinkan chat pakai ID dummy hash username
                -- supaya conversation key konsisten walau target belum pernah punya UserId numerik pasti.
                local targetPlayer = nil
                for _, p in pairs(Players:GetPlayers()) do
                    if p.Name:lower() == member.username:lower() then
                        targetPlayer = p
                        break
                    end
                end

                if targetPlayer then
                    openedConversation = targetPlayer.UserId
                    refreshCurr()
                else
                    showDynamicNotification(member.displayName .. " sedang offline, chat tetap tersimpan saat dia online", Color3.fromRGB(255, 200, 50))
                    -- tidak bisa buka chat tanpa UserId pasti; skip membuka halaman chat
                end
            end)
        end

        return card, nameLbl, userLbl, onlineDot, badge, badgeText
    end

    -- ===== RENDER LANGSUNG SEMUA MEMBER (STATIS DULU, TANPA NUNGGU FIREBASE) =====
    -- Urutan awal: Developer dulu, lalu alphabetical (belum tau siapa online)
    local sortedInitial = {}
    for _, m in ipairs(MEMBERS) do table.insert(sortedInitial, m) end
    table.sort(sortedInitial, function(a, b)
        if a.role == "Developer" and b.role ~= "Developer" then return true end
        if b.role == "Developer" and a.role ~= "Developer" then return false end
        return a.username:lower() < b.username:lower()
    end)

    for i, member in ipairs(sortedInitial) do
        local isOnlineHere = false
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name:lower() == member.username:lower() then
                isOnlineHere = true
                break
            end
        end
        local card = buildMemberCard(member, i, isOnlineHere)
        cardRefs[member.username:lower()] = card
    end

    -- ===== BACKGROUND: re-sort naikin yang online ke atas, TANPA blocking UI =====
    task.spawn(function()
        -- kasih jeda dikit biar UI list awal udah kelihatan duluan
        task.wait(0.1)

        -- re-urutkan berdasarkan status online sekarang
        local sortedFinal = {}
        for _, m in ipairs(MEMBERS) do table.insert(sortedFinal, m) end
        table.sort(sortedFinal, function(a, b)
            if a.role == "Developer" and b.role ~= "Developer" then return true end
            if b.role == "Developer" and a.role ~= "Developer" then return false end

            local aOnline, bOnline = false, false
            for _, p in pairs(Players:GetPlayers()) do
                if p.Name:lower() == a.username:lower() then aOnline = true end
                if p.Name:lower() == b.username:lower() then bOnline = true end
            end

            if aOnline ~= bOnline then return aOnline end
            return a.username:lower() < b.username:lower()
        end)

        -- update LayoutOrder aja (gak destroy/recreate card = gak ada flicker/loading)
        for i, member in ipairs(sortedFinal) do
            local card = cardRefs[member.username:lower()]
            if card and card.Parent then
                card.LayoutOrder = i
            end
        end
    end)
end

-- ================= MESSAGE APP (ROUTER) =================
function openMessageApp()
    if openedConversation then
        renderChatPage(openedConversation)
    else
        renderMemberList()
    end
end

-- ================= JALANKAN =================
task.spawn(function()
    task.wait(5)
    checkMessageNotif()
end)

print("[Message System] Ready!")

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
buildAppIcon("Lookup",15,appGrid, function() openApp("Player Lookup", openPlayerLookupApp) end)
buildAppIcon("ServerJoiner",16,appGrid, function() openApp("Server Joiner", openServerJoinerApp) end)
buildAppIcon("Online",17,appGrid, function() openApp("Who's Online", openWhoOnlineApp) end)
buildAppIcon("Message",18,appGrid, function() openApp("Messages", openMessageApp) end)

-- ==================== FLOATING IPHONE ICON + TABLET MODE (FINAL FIXED) ====================
-- GANTI seluruh bagian TOOL & EQUIP dan DRAG PHONE dengan ini

-- ==================== VARIABLES ====================
local phoneIcon = nil
local mouseDown = false
local mouseMoved = false
local dragStart = nil
local iconStartPos = nil
local toolEquipped = true

-- ==================== ORIENTASI ====================
local PHONE_SIZE_PORTRAIT = UDim2.new(0, 320, 0, 560)
local PHONE_SIZE = PHONE_SIZE_PORTRAIT
local isLandscapeMode = false

local function isPortrait()
    local cam = Workspace.CurrentCamera
    if not cam then return true end
    return cam.ViewportSize.Y >= cam.ViewportSize.X
end

local function getGridIconSize()
    if isPortrait() then
        return UDim2.new(0, 72, 0, 86)
    else
        return UDim2.new(0, 68, 0, 78)
    end
end

local function applyPhoneOrientationSize()
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    if vp.X <= 0 or vp.Y <= 0 then return end
    
    local landscape = vp.X > vp.Y
    
    if landscape then
        local phoneW = math.min(vp.X - 10, 520)
        local phoneH = math.min(vp.Y - 10, 320)
        PHONE_SIZE = UDim2.new(0, phoneW, 0, phoneH)
        phone.Position = UDim2.new(0.5, 0, 0.5, 0)
        isLandscapeMode = true
    else
        PHONE_SIZE = PHONE_SIZE_PORTRAIT
        phone.Position = UDim2.new(0.5, 0, 0.52, 0)
        isLandscapeMode = false
    end
    
    if phone.Visible then
        tween(phone, {Size = PHONE_SIZE, Position = phone.Position}, 0.3, Enum.EasingStyle.Quart)
    end
end

-- ==================== CREATE FLOATING ICON ====================
local function createFloatingIcon()
    if phoneIcon then
        pcall(function() phoneIcon:Destroy() end)
        phoneIcon = nil
    end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "PhoneIcon"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 999
    gui.IgnoreGuiInset = true
    
    pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if not gui.Parent then
        pcall(function() gui.Parent = getGuiParent() end)
    end
    if not gui.Parent then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    local iconContainer = Instance.new("Frame", gui)
    iconContainer.Size = UDim2.new(0, 65, 0, 105)
    iconContainer.Position = UDim2.new(0, 15, 0.5, -52)
    iconContainer.BackgroundTransparency = 1
    iconContainer.ZIndex = 1000
    iconContainer.AnchorPoint = Vector2.new(0, 0)
    
    -- Body iPhone
    local phoneBody = Instance.new("Frame", iconContainer)
    phoneBody.Size = UDim2.new(0, 50, 0, 88)
    phoneBody.Position = UDim2.new(0.5, -25, 0.5, -44)
    phoneBody.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    phoneBody.ZIndex = 1001
    corner(phoneBody, 12)
    stroke(phoneBody, Color3.fromRGB(45, 45, 50), 2, 0)
    
    local bodyGrad = Instance.new("UIGradient", phoneBody)
    bodyGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 32)),
        ColorSequenceKeypoint.new(0.3, Color3.fromRGB(18, 18, 22)),
        ColorSequenceKeypoint.new(0.7, Color3.fromRGB(22, 22, 26)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 16))
    })
    bodyGrad.Rotation = 135
    
    -- Screen
    local screen = Instance.new("Frame", phoneBody)
    screen.Size = UDim2.new(1, -6, 1, -30)
    screen.Position = UDim2.new(0, 3, 0, 20)
    screen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    screen.ZIndex = 1002
    corner(screen, 8)
    
    -- Status Bar
    local statusBar = Instance.new("Frame", screen)
    statusBar.Size = UDim2.new(1, 0, 0, 12)
    statusBar.Position = UDim2.new(0, 0, 0, 2)
    statusBar.BackgroundTransparency = 1
    statusBar.ZIndex = 1010
    
    -- Signal
    local signalFrame = Instance.new("Frame", statusBar)
    signalFrame.Size = UDim2.new(0, 15, 0, 10)
    signalFrame.Position = UDim2.new(0, 3, 0.5, -5)
    signalFrame.BackgroundTransparency = 1
    signalFrame.ZIndex = 1011
    
    for i = 1, 4 do
        local bar = Instance.new("Frame", signalFrame)
        bar.Size = UDim2.new(0, 2.5, 0, 2 + i * 1.5)
        bar.Position = UDim2.new(0, (i-1) * 4, 1, 0)
        bar.AnchorPoint = Vector2.new(0, 1)
        bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        bar.BorderSizePixel = 0
        bar.ZIndex = 1011
        corner(bar, 1)
    end
    
    -- Time
    local timeLabel = Instance.new("TextLabel", statusBar)
    timeLabel.Size = UDim2.new(0, 24, 0, 12)
    timeLabel.Position = UDim2.new(0.5, -12, 0, 0)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = "9:41"
    timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    timeLabel.Font = Enum.Font.GothamBold
    timeLabel.TextSize = 7
    timeLabel.TextXAlignment = Enum.TextXAlignment.Center
    timeLabel.TextYAlignment = Enum.TextYAlignment.Center
    timeLabel.ZIndex = 1011
    
    -- Battery
    local batteryFrame = Instance.new("Frame", statusBar)
    batteryFrame.Size = UDim2.new(0, 18, 0, 10)
    batteryFrame.Position = UDim2.new(1, -20, 0.5, -5)
    batteryFrame.BackgroundTransparency = 1
    batteryFrame.ZIndex = 1011
    
    local batteryBody = Instance.new("Frame", batteryFrame)
    batteryBody.Size = UDim2.new(0, 14, 0, 8)
    batteryBody.Position = UDim2.new(0, 0, 0.5, -4)
    batteryBody.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    batteryBody.BackgroundTransparency = 0.9
    batteryBody.BorderSizePixel = 0
    batteryBody.ZIndex = 1011
    corner(batteryBody, 3)
    stroke(batteryBody, Color3.fromRGB(255, 255, 255), 1, 0.3)
    
    local batteryFill = Instance.new("Frame", batteryBody)
    batteryFill.Size = UDim2.new(0.7, -2, 1, -4)
    batteryFill.Position = UDim2.new(0, 1, 0, 2)
    batteryFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    batteryFill.BorderSizePixel = 0
    batteryFill.ZIndex = 1012
    corner(batteryFill, 2)
    
    local batteryTip = Instance.new("Frame", batteryFrame)
    batteryTip.Size = UDim2.new(0, 2.5, 0, 4)
    batteryTip.Position = UDim2.new(1, -1, 0.5, -2)
    batteryTip.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    batteryTip.BackgroundTransparency = 0.5
    batteryTip.BorderSizePixel = 0
    batteryTip.ZIndex = 1011
    corner(batteryTip, 1)
    
    -- Wallpaper
    local wallpaper = Instance.new("Frame", screen)
    wallpaper.Size = UDim2.new(1, -4, 1, -14)
    wallpaper.Position = UDim2.new(0.5, 0, 0, 13)
    wallpaper.AnchorPoint = Vector2.new(0.5, 0)
    wallpaper.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    wallpaper.ZIndex = 1003
    corner(wallpaper, 6)
    
    -- App Icons
    local iconPositions = {
        {x = 3, y = 6}, {x = 14, y = 6}, {x = 25, y = 6},
        {x = 3, y = 17}, {x = 14, y = 17}, {x = 25, y = 17},
    }
    local iconColors = {
        Color3.fromRGB(100, 160, 255), Color3.fromRGB(255, 120, 120),
        Color3.fromRGB(80, 210, 80), Color3.fromRGB(255, 200, 50),
        Color3.fromRGB(180, 100, 255), Color3.fromRGB(255, 160, 60),
    }
    
    for i, pos in ipairs(iconPositions) do
        local appIcon = Instance.new("Frame", wallpaper)
        appIcon.Size = UDim2.new(0, 8, 0, 8)
        appIcon.Position = UDim2.new(0, pos.x, 0, pos.y)
        appIcon.BackgroundColor3 = iconColors[i]
        appIcon.BackgroundTransparency = 0.1
        appIcon.BorderSizePixel = 0
        appIcon.ZIndex = 1004
        corner(appIcon, 2.5)
    end
    
    -- Dock
    local dock = Instance.new("Frame", wallpaper)
    dock.Size = UDim2.new(0, 32, 0, 12)
    dock.Position = UDim2.new(0.5, -16, 1, -13)
    dock.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dock.BackgroundTransparency = 0.9
    dock.BorderSizePixel = 0
    dock.ZIndex = 1004
    corner(dock, 6)
    
    for i = 1, 4 do
        local d = Instance.new("Frame", dock)
        d.Size = UDim2.new(0, 5, 0, 5)
        d.Position = UDim2.new(0, 3 + (i-1) * 7, 0.5, -2.5)
        d.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        d.BackgroundTransparency = 0.3
        d.BorderSizePixel = 0
        d.ZIndex = 1005
        corner(d, 1.5)
    end
    
    -- Dynamic Island
    local di2 = Instance.new("Frame", phoneBody)
    di2.Size = UDim2.new(0, 24, 0, 5)
    di2.Position = UDim2.new(0.5, -12, 0, 6)
    di2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    di2.ZIndex = 1020
    corner(di2, 3)
    
    -- Home Bar
    local hb = Instance.new("Frame", phoneBody)
    hb.Size = UDim2.new(0, 22, 0, 3)
    hb.Position = UDim2.new(0.5, -11, 1, -5)
    hb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hb.BackgroundTransparency = 0.6
    hb.BorderSizePixel = 0
    hb.ZIndex = 1020
    corner(hb, 2)
    
    -- Camera
    local camBump = Instance.new("Frame", phoneBody)
    camBump.Size = UDim2.new(0, 14, 0, 14)
    camBump.Position = UDim2.new(0.5, 8, 1, -14)
    camBump.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    camBump.ZIndex = 1020
    corner(camBump, 100)
    
    local mainLens = Instance.new("Frame", camBump)
    mainLens.Size = UDim2.new(0, 7, 0, 7)
    mainLens.Position = UDim2.new(0.5, -3, 0.5, -3)
    mainLens.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    mainLens.ZIndex = 1021
    corner(mainLens, 100)
    stroke(mainLens, Color3.fromRGB(40, 40, 44), 1, 0)
    
    -- ==================== CLICK BUTTON (FIXED) ====================
    local clickBtn = Instance.new("TextButton", iconContainer)
    clickBtn.Size = UDim2.new(0, 55, 0, 95)
    clickBtn.Position = UDim2.new(0.5, -27, 0.5, -47)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 1030
    clickBtn.AutoButtonColor = false
    
    clickBtn.MouseEnter:Connect(function()
        tween(phoneBody, {Size = UDim2.new(0, 54, 0, 94)}, 0.15)
    end)
    clickBtn.MouseLeave:Connect(function()
        if not mouseDown then
            tween(phoneBody, {Size = UDim2.new(0, 50, 0, 88)}, 0.15)
        end
    end)
    
    -- KLIK BUKA/TUTUP (LANGSUNG - TANPA FUNGSI LAIN)
    clickBtn.MouseButton1Click:Connect(function()
        if mouseMoved then return end -- Jangan proses kalau lagi drag
        
        if not phone or not phone.Parent then return end
        
        if phone.Visible then
            -- TUTUP
            tween(phone, {Size = UDim2.new(0, 0, 0, 0)}, 0.25)
            task.delay(0.25, function()
                if phone and phone.Parent then
                    phone.Visible = false
                end
            end)
        else
            -- BUKA
            applyPhoneOrientationSize()
            phone.Visible = true
            phone.Size = UDim2.new(0, 0, 0, 0)
            tween(phone, {Size = PHONE_SIZE}, 0.3, Enum.EasingStyle.Back)
            
            if isLocked then
                lock.Visible = true
                pass.Visible = false
            else
                goHome()
            end
        end
    end)
    
    -- DRAG
    clickBtn.MouseButton1Down:Connect(function()
        mouseDown = true
        mouseMoved = false
        dragStart = UserInputService:GetMouseLocation()
        iconStartPos = iconContainer.Position
    end)
    
    clickBtn.MouseButton1Up:Connect(function()
        mouseDown = false
        task.wait(0.1)
        mouseMoved = false -- Reset setelah selesai
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if not mouseDown then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local mousePos = UserInputService:GetMouseLocation()
            if not dragStart then return end
            local delta = mousePos - dragStart
            if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
                mouseMoved = true
            end
            if mouseMoved then
                local newX = iconStartPos.X.Offset + delta.X
                local newY = iconStartPos.Y.Offset + delta.Y
                local screenSize = Workspace.CurrentCamera.ViewportSize
                newX = math.clamp(newX, 5, screenSize.X - 70)
                newY = math.clamp(newY, 5, screenSize.Y - 110)
                iconContainer.Position = UDim2.new(0, newX, 0, newY)
            end
        end
    end)
    
    phoneIcon = gui
    return gui
end

-- ==================== INIT ====================
task.spawn(function()
    task.wait(1)
    createFloatingIcon()
    task.wait(0.5)
    openPhone()
end)

-- ==================== RESPAWN ====================
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if not phoneIcon or not phoneIcon.Parent then
        createFloatingIcon()
    end
end)

-- ==================== MONITOR ====================
task.spawn(function()
    while true do
        task.wait(5)
        if not phoneIcon or not phoneIcon.Parent then
            createFloatingIcon()
        end
    end
end)

-- ==================== ORIENTATION MONITOR ====================
task.spawn(function()
    local lastLandscape = nil
    while true do
        task.wait(0.3)
        local cam = Workspace.CurrentCamera
        if not cam then continue end
        local isLand = cam.ViewportSize.X > cam.ViewportSize.Y
        if isLand ~= lastLandscape then
            lastLandscape = isLand
            applyPhoneOrientationSize()
        end
    end
end)

print("[Phone] System ready! Click icon to open/close.")


-- ================= TELEGRAM NOTIFICATION =================
task.spawn(function()
    task.wait(5) -- Tunggu 5 detik setelah script load
    notifyTelegramNewUser()
end)

print("[Phone v10.1] Full code loaded – Favorites horizontal, status bar refined.")