-- Phone ID Viewer - Main.lua
-- Modular system with GitHub-hosted modules

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Folder setup
local phoneFolder = Instance.new("Folder")
phoneFolder.Name = "PhoneIDViewerData"
phoneFolder.Parent = workspace

-- Theme presets
local THEME_PRESETS = {
	["Putih"] = {
		Background = Color3.fromRGB(255, 255, 255),
		Accent = Color3.fromRGB(0, 122, 255),
		Text = Color3.fromRGB(0, 0, 0),
		SecondaryText = Color3.fromRGB(128, 128, 128),
		Card = Color3.fromRGB(242, 242, 247),
		Stroke = Color3.fromRGB(200, 200, 200)
	},
	["Ungu"] = {
		Background = Color3.fromRGB(30, 30, 45),
		Accent = Color3.fromRGB(150, 100, 255),
		Text = Color3.fromRGB(255, 255, 255),
		SecondaryText = Color3.fromRGB(180, 180, 200),
		Card = Color3.fromRGB(40, 40, 60),
		Stroke = Color3.fromRGB(100, 80, 180)
	},
	["Biru"] = {
		Background = Color3.fromRGB(20, 30, 50),
		Accent = Color3.fromRGB(0, 150, 255),
		Text = Color3.fromRGB(255, 255, 255),
		SecondaryText = Color3.fromRGB(170, 190, 210),
		Card = Color3.fromRGB(30, 40, 65),
		Stroke = Color3.fromRGB(0, 100, 200)
	},
	["Merah"] = {
		Background = Color3.fromRGB(40, 20, 20),
		Accent = Color3.fromRGB(255, 60, 60),
		Text = Color3.fromRGB(255, 255, 255),
		SecondaryText = Color3.fromRGB(210, 170, 170),
		Card = Color3.fromRGB(55, 30, 30),
		Stroke = Color3.fromRGB(200, 50, 50)
	},
	["Emas"] = {
		Background = Color3.fromRGB(30, 25, 15),
		Accent = Color3.fromRGB(255, 200, 50),
		Text = Color3.fromRGB(255, 255, 240),
		SecondaryText = Color3.fromRGB(200, 190, 160),
		Card = Color3.fromRGB(45, 38, 20),
		Stroke = Color3.fromRGB(200, 150, 30)
	},
	["Hijau"] = {
		Background = Color3.fromRGB(20, 35, 25),
		Accent = Color3.fromRGB(50, 200, 100),
		Text = Color3.fromRGB(240, 255, 240),
		SecondaryText = Color3.fromRGB(170, 210, 180),
		Card = Color3.fromRGB(28, 48, 35),
		Stroke = Color3.fromRGB(40, 160, 80)
	}
}

-- Settings
local appSettings = {
	theme = "Biru",
	wallpaperURL = "",
	wallpaperAssetId = "",
	widgetBackgroundURL = "",
	widgetBackgroundAssetId = ""
}

-- Load settings
local function loadJSON(filename)
	local success, data = pcall(function()
		local content = readfile(filename)
		return HttpService:JSONDecode(content)
	end)
	if success and data then
		return data
	end
	return nil
end

local function saveJSON(filename, data)
	pcall(function()
		writefile(filename, HttpService:JSONEncode(data))
	end)
end

-- Load saved settings
local savedSettings = loadJSON("PhoneIDViewer_Settings.json")
if savedSettings then
	for k, v in pairs(savedSettings) do
		appSettings[k] = v
	end
end

-- Load presets
local presets = loadJSON("PhoneIDViewer_Presets.json") or {}

-- Load favorites
local favPlayerSet = {}
local favData = loadJSON("PhoneIDViewer_FavPlayers.json")
if favData and favData.players then
	for _, name in ipairs(favData.players) do
		favPlayerSet[name] = true
	end
end

-- Selected target
local selectedTargetPlayer = nil

-- Current app
local currentApp = "Home"
local appFrames = {}

-- Phone GUI setup
local phoneGUI
local success, err = pcall(function()
	phoneGUI = Instance.new("ScreenGui")
	phoneGUI.Name = "PhoneIDViewer"
	phoneGUI.Parent = CoreGui
end)
if not success then
	phoneGUI = Instance.new("ScreenGui")
	phoneGUI.Name = "PhoneIDViewer"
	phoneGUI.Parent = player:WaitForChild("PlayerGui")
end

-- Main phone frame
local phoneFrame = Instance.new("Frame")
phoneFrame.Name = "PhoneFrame"
phoneFrame.Size = UDim2.new(0, 320, 0, 560)
phoneFrame.Position = UDim2.new(0.5, -160, 0.5, -280)
phoneFrame.BackgroundColor3 = appSettings.theme and THEME_PRESETS[appSettings.theme] and THEME_PRESETS[appSettings.theme].Background or Color3.fromRGB(20, 30, 50)
phoneFrame.BorderSizePixel = 0
phoneFrame.Parent = phoneGUI

local phoneCorner = Instance.new("UICorner")
phoneCorner.CornerRadius = UDim.new(0, 38)
phoneCorner.Parent = phoneFrame

local phoneStroke = Instance.new("UIStroke")
phoneStroke.Color = THEME_PRESETS[appSettings.theme] and THEME_PRESETS[appSettings.theme].Stroke or Color3.fromRGB(0, 100, 200)
phoneStroke.Thickness = 2
phoneStroke.Parent = phoneFrame

-- Gradient background
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 20, 40)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 60, 90))
})
gradient.Rotation = 135
gradient.Parent = phoneFrame

-- Status bar
local statusBar = Instance.new("Frame")
statusBar.Name = "StatusBar"
statusBar.Size = UDim2.new(1, 0, 0, 30)
statusBar.Position = UDim2.new(0, 0, 0, 10)
statusBar.BackgroundTransparency = 1
statusBar.Parent = phoneFrame

-- Time label
local timeLabel = Instance.new("TextLabel")
timeLabel.Name = "TimeLabel"
timeLabel.Size = UDim2.new(0, 60, 1, 0)
timeLabel.Position = UDim2.new(0, 20, 0, 0)
timeLabel.BackgroundTransparency = 1
timeLabel.Font = Enum.Font.GothamSemibold
timeLabel.TextSize = 14
timeLabel.TextColor3 = THEME_PRESETS[appSettings.theme] and THEME_PRESETS[appSettings.theme].Text or Color3.fromRGB(255, 255, 255)
timeLabel.TextXAlignment = Enum.TextXAlignment.Left
timeLabel.Parent = statusBar

-- Signal indicator
local signalFrame = Instance.new("Frame")
signalFrame.Name = "SignalFrame"
signalFrame.Size = UDim2.new(0, 16, 0, 12)
signalFrame.Position = UDim2.new(1, -70, 0.5, -6)
signalFrame.BackgroundTransparency = 1
signalFrame.Parent = statusBar

local signalBars = {}
for i = 1, 4 do
	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0, 3, 1, -((4 - i) * 3))
	bar.Position = UDim2.new(0, (i - 1) * 4, 1, -(12 - (4 - i) * 3))
	bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	bar.BorderSizePixel = 0
	bar.Parent = signalFrame
	table.insert(signalBars, bar)
end

-- Battery indicator
local batteryFrame = Instance.new("Frame")
batteryFrame.Name = "BatteryFrame"
batteryFrame.Size = UDim2.new(0, 22, 0, 11)
batteryFrame.Position = UDim2.new(1, -28, 0.5, -5)
batteryFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
batteryFrame.BackgroundTransparency = 0.7
batteryFrame.BorderSizePixel = 0
batteryFrame.Parent = statusBar

local batteryCorner = Instance.new("UICorner")
batteryCorner.CornerRadius = UDim.new(0, 2)
batteryCorner.Parent = batteryFrame

local batteryFill = Instance.new("Frame")
batteryFill.Name = "BatteryFill"
batteryFill.Size = UDim2.new(0.8, 0, 1, -2)
batteryFill.Position = UDim2.new(0, 1, 0, 1)
batteryFill.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
batteryFill.BorderSizePixel = 0
batteryFill.Parent = batteryFrame

local batteryFillCorner = Instance.new("UICorner")
batteryFillCorner.CornerRadius = UDim.new(0, 1)
batteryFillCorner.Parent = batteryFill

local batteryTip = Instance.new("Frame")
batteryTip.Size = UDim2.new(0, 2, 0, 4)
batteryTip.Position = UDim2.new(1, 0, 0.5, -2)
batteryTip.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
batteryTip.BackgroundTransparency = 0.7
batteryTip.BorderSizePixel = 0
batteryTip.Parent = batteryFrame

-- Dynamic Island
local dynamicIsland = Instance.new("Frame")
dynamicIsland.Name = "DynamicIsland"
dynamicIsland.Size = UDim2.new(0, 90, 0, 24)
dynamicIsland.Position = UDim2.new(0.5, -45, 0, 8)
dynamicIsland.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
dynamicIsland.BorderSizePixel = 0
dynamicIsland.ClipsDescendants = true
dynamicIsland.Parent = phoneFrame

local islandCorner = Instance.new("UICorner")
islandCorner.CornerRadius = UDim.new(0, 12)
islandCorner.Parent = dynamicIsland

local islandLabel = Instance.new("TextLabel")
islandLabel.Name = "IslandLabel"
islandLabel.Size = UDim2.new(1, -10, 1, 0)
islandLabel.Position = UDim2.new(0, 5, 0, 0)
islandLabel.BackgroundTransparency = 1
islandLabel.Font = Enum.Font.GothamSemibold
islandLabel.TextSize = 11
islandLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
islandLabel.Text = ""
islandLabel.Parent = dynamicIsland

-- Wallpaper image
local wallpaperImage = Instance.new("ImageLabel")
wallpaperImage.Name = "WallpaperImage"
wallpaperImage.Size = UDim2.new(1, 0, 1, 0)
wallpaperImage.BackgroundTransparency = 1
wallpaperImage.Visible = false
wallpaperImage.ZIndex = 0
wallpaperImage.Parent = phoneFrame

-- Widget frame (clock + date)
local widgetFrame = Instance.new("Frame")
widgetFrame.Name = "WidgetFrame"
widgetFrame.Size = UDim2.new(0, 180, 0, 80)
widgetFrame.Position = UDim2.new(0, 20, 0, 55)
widgetFrame.BackgroundTransparency = 0.3
widgetFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
widgetFrame.BorderSizePixel = 0
widgetFrame.ZIndex = 1
widgetFrame.Parent = phoneFrame

local widgetCorner = Instance.new("UICorner")
widgetCorner.CornerRadius = UDim.new(0, 16)
widgetCorner.Parent = widgetFrame

local widgetTimeLabel = Instance.new("TextLabel")
widgetTimeLabel.Name = "WidgetTimeLabel"
widgetTimeLabel.Size = UDim2.new(1, 0, 0, 40)
widgetTimeLabel.Position = UDim2.new(0, 10, 0, 10)
widgetTimeLabel.BackgroundTransparency = 1
widgetTimeLabel.Font = Enum.Font.GothamBold
widgetTimeLabel.TextSize = 28
widgetTimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
widgetTimeLabel.TextXAlignment = Enum.TextXAlignment.Left
widgetTimeLabel.ZIndex = 2
widgetTimeLabel.Parent = widgetFrame

local widgetDateLabel = Instance.new("TextLabel")
widgetDateLabel.Name = "WidgetDateLabel"
widgetDateLabel.Size = UDim2.new(1, 0, 0, 20)
widgetDateLabel.Position = UDim2.new(0, 10, 0, 48)
widgetDateLabel.BackgroundTransparency = 1
widgetDateLabel.Font = Enum.Font.Gotham
widgetDateLabel.TextSize = 14
widgetDateLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
widgetDateLabel.TextXAlignment = Enum.TextXAlignment.Left
widgetDateLabel.ZIndex = 2
widgetDateLabel.Parent = widgetFrame

-- Home screen container
local homeScreen = Instance.new("Frame")
homeScreen.Name = "HomeScreen"
homeScreen.Size = UDim2.new(1, 0, 1, -100)
homeScreen.Position = UDim2.new(0, 0, 0, 100)
homeScreen.BackgroundTransparency = 1
homeScreen.ZIndex = 1
homeScreen.Parent = phoneFrame

-- App grid
local appGrid = Instance.new("Frame")
appGrid.Name = "AppGrid"
appGrid.Size = UDim2.new(1, -40, 0, 400)
appGrid.Position = UDim2.new(0, 20, 0, 150)
appGrid.BackgroundTransparency = 1
appGrid.ZIndex = 2
appGrid.Parent = homeScreen

-- App screen container (slides in)
local appScreenContainer = Instance.new("Frame")
appScreenContainer.Name = "AppScreenContainer"
appScreenContainer.Size = UDim2.new(1, 0, 1, -50)
appScreenContainer.Position = UDim2.new(0, 0, 0, 50)
appScreenContainer.BackgroundTransparency = 1
appScreenContainer.ZIndex = 3
appScreenContainer.Visible = false
appScreenContainer.Parent = phoneFrame

-- Bottom navigation bar
local navBar = Instance.new("Frame")
navBar.Name = "NavBar"
navBar.Size = UDim2.new(1, 0, 0, 50)
navBar.Position = UDim2.new(0, 0, 1, -50)
navBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
navBar.BackgroundTransparency = 0.5
navBar.BorderSizePixel = 0
navBar.ZIndex = 4
navBar.Parent = phoneFrame

local navBarTopLine = Instance.new("Frame")
navBarTopLine.Size = UDim2.new(1, -40, 0, 1)
navBarTopLine.Position = UDim2.new(0, 20, 0, 0)
navBarTopLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
navBarTopLine.BackgroundTransparency = 0.7
navBarTopLine.BorderSizePixel = 0
navBarTopLine.Parent = navBar

local homeButton = Instance.new("TextButton")
homeButton.Name = "HomeButton"
homeButton.Size = UDim2.new(0, 50, 1, -5)
homeButton.Position = UDim2.new(0.5, -25, 0, 3)
homeButton.BackgroundTransparency = 1
homeButton.Text = "🏠"
homeButton.TextSize = 20
homeButton.Font = Enum.Font.GothamSemibold
homeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
homeButton.ZIndex = 5
homeButton.Parent = navBar

-- Back button
local backButton = Instance.new("TextButton")
backButton.Name = "BackButton"
backButton.Size = UDim2.new(0, 40, 0, 30)
backButton.Position = UDim2.new(0, 10, 0, 5)
backButton.BackgroundTransparency = 1
backButton.Text = "←"
backButton.TextSize = 20
backButton.Font = Enum.Font.GothamSemibold
backButton.TextColor3 = THEME_PRESETS[appSettings.theme] and THEME_PRESETS[appSettings.theme].Text or Color3.fromRGB(255, 255, 255)
backButton.ZIndex = 5
backButton.Visible = false
backButton.Parent = phoneFrame

-- Utility functions
local T = THEME_PRESETS[appSettings.theme] or THEME_PRESETS["Biru"]

local function copyToClipboard(text)
	pcall(function()
		setclipboard(text)
	end)
	StarterGui:SetCore("SendNotification", {
		Title = "Phone ID Viewer",
		Text = "Copied to clipboard!",
		Duration = 2
	})
end

local function getItems(targetPlayer)
	local items = {}
	if not targetPlayer or not targetPlayer.Character then return items end
	
	local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return items end
	
	-- Scan for accessories and clothing
	for _, child in ipairs(targetPlayer.Character:GetChildren()) do
		if child:IsA("Accessory") then
			local handle = child:FindFirstChild("Handle")
			local id = nil
			if handle then
				-- Try to find asset ID from mesh or texture
				for _, prop in ipairs({"MeshId", "TextureID"}) do
					local meshPart = handle:FindFirstChildOfClass("MeshPart") or handle:FindFirstChildOfClass("Part")
					if meshPart then
						local mesh = meshPart:FindFirstChildOfClass("SpecialMesh")
						if mesh and mesh.MeshId then
							local assetId = string.match(mesh.MeshId, "rbxassetid://(%d+)")
							if assetId then
								id = assetId
								break
							end
						end
					end
				end
			end
			if id then
				table.insert(items, {
					Name = child.Name,
					ID = id,
					Type = "ACC"
				})
			end
		elseif child:IsA("Pants") or child:IsA("Shirt") then
			local template = child:FindFirstChildOfClass("ShirtTemplate") or child:FindFirstChildOfClass("PantsTemplate")
			if template and template.Image then
				local assetId = string.match(template.Image, "rbxassetid://(%d+)")
				if assetId then
					table.insert(items, {
						Name = child.Name,
						ID = assetId,
						Type = "BODY"
					})
				end
			end
		end
	end
	
	-- Check humanoid description for body parts
	local desc = humanoid:GetAppliedDescription()
	if desc then
		for _, id in ipairs(desc:GetAccessories()) do
			-- Check if already added
			local found = false
			for _, item in ipairs(items) do
				if item.ID == tostring(id) then
					found = true
					break
				end
			end
			if not found then
				table.insert(items, {
					Name = "Accessory",
					ID = tostring(id),
					Type = "ACC"
				})
			end
		end
	end
	
	return items
end

local function pressFX(button)
	local ts = TweenService
	local info = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = ts:Create(button, info, {Size = UDim2.new(button.Size.X.Scale * 0.9, button.Size.X.Offset * 0.9, button.Size.Y.Scale * 0.9, button.Size.Y.Offset * 0.9)})
	tween:Play()
	tween.Completed:Connect(function()
		local tween2 = ts:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(button.Size.X.Scale / 0.9, button.Size.X.Offset / 0.9, button.Size.Y.Scale / 0.9, button.Size.Y.Offset / 0.9)})
		tween2:Play()
	end)
end

local function pulseIsland(message, duration)
	islandLabel.Text = message
	local ts = TweenService
	local expandInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local expand = ts:Create(dynamicIsland, expandInfo, {Size = UDim2.new(0, 200, 0, 34), Position = UDim2.new(0.5, -100, 0, 8)})
	expand:Play()
	task.delay(duration or 2, function()
		local shrink = ts:Create(dynamicIsland, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 90, 0, 24), Position = UDim2.new(0.5, -45, 0, 8)})
		shrink:Play()
		shrink.Completed:Connect(function()
			islandLabel.Text = ""
		end)
	end)
end

local function downloadAndCache(url, filename)
	local success, data = pcall(function()
		return game:HttpGet(url)
	end)
	if success and data then
		pcall(function()
			writefile(filename, data)
		end)
		return data
	end
	return nil
end

local function applyWallpaper(url)
	if url and url ~= "" then
		local filename = "PhoneIDViewer_wallpaper.png"
		local data = downloadAndCache(url, filename)
		if data then
			local success, assetId = pcall(function()
				return getcustomasset(filename)
			end)
			if success and assetId then
				wallpaperImage.Image = assetId
				wallpaperImage.Visible = true
				return true
			end
		end
		-- Try direct URL if custom asset fails
		pcall(function()
			wallpaperImage.Image = url
			wallpaperImage.Visible = true
		end)
		return true
	else
		wallpaperImage.Visible = false
		wallpaperImage.Image = ""
		return false
	end
end

local function applyWidget(url)
	if url and url ~= "" then
		local filename = "PhoneIDViewer_widgetbg.png"
		local data = downloadAndCache(url, filename)
		if data then
			local success, assetId = pcall(function()
				return getcustomasset(filename)
			end)
			if success and assetId then
				widgetFrame.BackgroundTransparency = 0
				widgetFrame:ClearAllChildren()
				local img = Instance.new("ImageLabel")
				img.Size = UDim2.new(1, 0, 1, 0)
				img.BackgroundTransparency = 1
				img.Image = assetId
				img.Parent = widgetFrame
				widgetTimeLabel.Parent = widgetFrame
				widgetDateLabel.Parent = widgetFrame
				return true
			end
		end
	end
	return false
end

-- Navigation functions
local function navigateToApp(appName)
	currentApp = appName
	homeScreen.Visible = false
	appScreenContainer.Visible = true
	backButton.Visible = true
	
	-- Clear app screen
	for _, child in ipairs(appScreenContainer:GetChildren()) do
		if child:IsA("Frame") or child:IsA("ScrollingFrame") then
			child:Destroy()
		end
	end
	
	-- Show app frame if exists
	if appFrames[appName] then
		appFrames[appName].Visible = true
	else
		-- Create placeholder
		local placeholder = Instance.new("TextLabel")
		placeholder.Size = UDim2.new(1, 0, 1, 0)
		placeholder.BackgroundTransparency = 1
		placeholder.Text = "Loading..."
		placeholder.TextColor3 = T.Text
		placeholder.TextSize = 16
		placeholder.Parent = appScreenContainer
	end
	
	-- Animate slide
	local ts = TweenService
	local slideIn = ts:Create(appScreenContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 50)})
	slideIn:Play()
end

local function navigateHome()
	currentApp = "Home"
	homeScreen.Visible = true
	backButton.Visible = false
	
	local ts = TweenService
	local slideOut = ts:Create(appScreenContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, 0, 0, 50)})
	slideOut:Play()
	slideOut.Completed:Connect(function()
		appScreenContainer.Visible = false
		appScreenContainer.Position = UDim2.new(0, 0, 0, 50)
	end)
end

local function refreshCurrentApp()
	if currentApp ~= "Home" then
		navigateToApp(currentApp)
	end
end

-- Back button handler
backButton.MouseButton1Click:Connect(navigateHome)
homeButton.MouseButton1Click:Connect(navigateHome)

-- Time update
local function updateTime()
	local now = os.date("*t")
	local hour = now.hour
	local minute = now.min
	timeLabel.Text = string.format("%02d:%02d", hour, minute)
	
	widgetTimeLabel.Text = string.format("%02d:%02d", hour, minute)
	widgetDateLabel.Text = os.date("%A, %d %B %Y")
	
	-- Battery simulation
	local batteryLevel = math.random(80, 100) / 100
	batteryFill.Size = UDim2.new(batteryLevel, 0, 1, -2)
	if batteryLevel > 0.5 then
		batteryFill.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	elseif batteryLevel > 0.2 then
		batteryFill.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
	else
		batteryFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	end
end

updateTime()
task.spawn(function()
	while true do
		task.wait(30)
		updateTime()
	end
end)

-- Shared object for modules
local sharedObj = {
	T = T,
	THEME_PRESETS = THEME_PRESETS,
	appSettings = appSettings,
	presets = presets,
	favPlayerSet = favPlayerSet,
	getItems = getItems,
	copyToClipboard = copyToClipboard,
	saveJSON = saveJSON,
	loadJSON = loadJSON,
	corner = function(parent, radius)
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, radius or 8)
		c.Parent = parent
		return c
	end,
	stroke = function(parent, color, thickness)
		local s = Instance.new("UIStroke")
		s.Color = color or T.Stroke
		s.Thickness = thickness or 1
		s.Parent = parent
		return s
	end,
	tween = function(obj, props, duration)
		local ts = TweenService
		local tween = ts:Create(obj, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
		tween:Play()
		return tween
	end,
	pressFX = pressFX,
	pulseIsland = pulseIsland,
	applyWallpaper = applyWallpaper,
	applyWidget = applyWidget,
	downloadAndCache = downloadAndCache,
	refreshCurrentApp = refreshCurrentApp,
	selectedTargetPlayer = selectedTargetPlayer
}

-- Build home screen apps
local appIcons = {}
local iconModule = loadJSON("PhoneIDViewer_IconsCache")
if not iconModule then
	-- Download icons from GitHub
	local success, iconCode = pcall(function()
		return game:HttpGet("https://raw.githubusercontent.com/AlfreadRorw/CloneBunker/main/PhoneIDViewer/Icons/AllIcons.lua")
	end)
	if success and iconCode then
		local iconFunc = loadstring(iconCode)
		if iconFunc then
			iconModule = iconFunc()
		end
	end
end

if not iconModule then
	-- Fallback icons
	iconModule = {
		Players = {
			Color = Color3.fromRGB(0, 150, 255),
			Builder = function(parent, color)
				local frame = Instance.new("Frame")
				frame.Size = UDim2.new(0, 64, 0, 78)
				frame.BackgroundTransparency = 1
				frame.Parent = parent
				
				local icon = Instance.new("Frame")
				icon.Size = UDim2.new(0, 48, 0, 48)
				icon.Position = UDim2.new(0.5, -24, 0, 0)
				icon.BackgroundColor3 = color
				icon.BorderSizePixel = 0
				Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 12)
				icon.Parent = frame
				
				local head = Instance.new("Frame")
				head.Size = UDim2.new(0, 16, 0, 16)
				head.Position = UDim2.new(0.5, -8, 0, 6)
				head.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				head.BorderSizePixel = 0
				Instance.new("UICorner", head).CornerRadius = UDim.new(1, 0)
				head.Parent = icon
				
				local body = Instance.new("Frame")
				body.Size = UDim2.new(0, 24, 0, 16)
				body.Position = UDim2.new(0.5, -12, 0, 26)
				body.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				body.BorderSizePixel = 0
				Instance.new("UICorner", body).CornerRadius = UDim.new(0, 4)
				body.Parent = icon
				
				return frame
			end
		}
	}
end

-- App definitions
local appDefs = {
	{name = "Players", label = "Players", icon = iconModule.Players},
	{name = "Clone", label = "Clone", icon = iconModule.Clone},
	{name = "Body", label = "Body", icon = iconModule.Body},
	{name = "Accessories", label = "Accessories", icon = iconModule.Accessories},
	{name = "Preset", label = "Preset", icon = iconModule.Preset},
	{name = "Favorite", label = "Favorite", icon = iconModule.Favorite},
	{name = "Setting", label = "Setting", icon = iconModule.Setting}
}

local function createAppIcon(appDef, position)
	local container = Instance.new("TextButton")
	container.Size = UDim2.new(0, 64, 0, 78)
	container.Position = position
	container.BackgroundTransparency = 1
	container.Text = ""
	container.Parent = appGrid
	
	if appDef.icon and appDef.icon.Builder then
		appDef.icon.Builder(container, appDef.icon.Color or Color3.fromRGB(0, 150, 255))
	end
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 18)
	label.Position = UDim2.new(0, 0, 1, -20)
	label.BackgroundTransparency = 1
	label.Text = appDef.label
	label.TextColor3 = T.Text
	label.TextSize = 11
	label.Font = Enum.Font.Gotham
	label.Parent = container
	
	container.MouseButton1Click:Connect(function()
		pressFX(container)
		navigateToApp(appDef.name)
		loadAppModule(appDef.name)
	end)
	
	return container
end

-- Download and load app module
local function loadAppModule(appName)
	if appFrames[appName] then
		-- Already loaded, just show
		for _, child in ipairs(appScreenContainer:GetChildren()) do
			if child:IsA("Frame") or child:IsA("ScrollingFrame") then
				child.Visible = false
			end
		end
		appFrames[appName].Visible = true
		return
	end
	
	-- Clear placeholder
	for _, child in ipairs(appScreenContainer:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end
	
	-- Show loading
	local loadingLabel = Instance.new("TextLabel")
	loadingLabel.Size = UDim2.new(1, 0, 1, 0)
	loadingLabel.BackgroundTransparency = 1
	loadingLabel.Text = "Downloading " .. appName .. "..."
	loadingLabel.TextColor3 = T.Text
	loadingLabel.TextSize = 16
	loadingLabel.Font = Enum.Font.Gotham
	loadingLabel.Parent = appScreenContainer
	
	local success, moduleCode = pcall(function()
		return game:HttpGet("https://raw.githubusercontent.com/AlfreadRorw/CloneBunker/main/PhoneIDViewer/Applications/" .. appName .. ".lua")
	end)
	
	if success and moduleCode then
		loadingLabel:Destroy()
		
		local appFrame = Instance.new("Frame")
		appFrame.Name = appName .. "Frame"
		appFrame.Size = UDim2.new(1, 0, 1, 0)
		appFrame.BackgroundTransparency = 1
		appFrame.Parent = appScreenContainer
		
		local success2, moduleFunc = pcall(function()
			return loadstring(moduleCode)
		end)
		
		if success2 and moduleFunc then
			local success3, err = pcall(function()
				moduleFunc()(appFrame, sharedObj)
			end)
			if not success3 then
				warn("Error loading module " .. appName .. ": " .. tostring(err))
				local errorLabel = Instance.new("TextLabel")
				errorLabel.Size = UDim2.new(1, -20, 1, 0)
				errorLabel.Position = UDim2.new(0, 10, 0, 0)
				errorLabel.BackgroundTransparency = 1
				errorLabel.Text = "Error: " .. tostring(err)
				errorLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
				errorLabel.TextSize = 12
				errorLabel.TextWrapped = true
				errorLabel.Parent = appFrame
			end
		else
			local errorLabel = Instance.new("TextLabel")
			errorLabel.Size = UDim2.new(1, -20, 1, 0)
			errorLabel.Position = UDim2.new(0, 10, 0, 0)
			errorLabel.BackgroundTransparency = 1
			errorLabel.Text = "Failed to load module: " .. appName
			errorLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
			errorLabel.TextSize = 14
			errorLabel.Parent = appFrame
		end
		
		appFrames[appName] = appFrame
	else
		loadingLabel.Text = "Failed to download " .. appName
		loadingLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	end
end

-- Create app icons on grid
local gridCols = 4
local gridRows = 3
local startX = 5
local startY = 5
local spacingX = 75
local spacingY = 95

for i, appDef in ipairs(appDefs) do
	local col = (i - 1) % gridCols
	local row = math.floor((i - 1) / gridCols)
	local xPos = startX + col * spacingX
	local yPos = startY + row * spacingY
	createAppIcon(appDef, UDim2.new(0, xPos, 0, yPos))
end

-- Initialize wallpaper
if appSettings.wallpaperURL and appSettings.wallpaperURL ~= "" then
	applyWallpaper(appSettings.wallpaperURL)
end

-- Initialize widget background
if appSettings.widgetBackgroundURL and appSettings.widgetBackgroundURL ~= "" then
	applyWidget(appSettings.widgetBackgroundURL)
end

-- Preload all apps with delay
task.spawn(function()
	for _, appDef in ipairs(appDefs) do
		task.wait(0.2)
		pcall(function()
			game:HttpGet("https://raw.githubusercontent.com/AlfreadRorw/CloneBunker/main/PhoneIDViewer/Applications/" .. appDef.name .. ".lua")
		end)
	end
end)

-- Tool setup
local tool = Instance.new("Tool")
tool.Name = "Phone"
tool.RequiresHandle = false
tool.CanBeDropped = false
tool.Parent = player.Backpack

tool.Activated:Connect(function()
	phoneGUI.Enabled = not phoneGUI.Enabled
end)

-- Initial theme apply
local function applyTheme(themeName)
	T = THEME_PRESETS[themeName] or THEME_PRESETS["Biru"]
	phoneFrame.BackgroundColor3 = T.Background
	phoneStroke.Color = T.Stroke
	
	-- Update gradient
	gradient:Destroy()
	gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, T.Background:Lerp(Color3.fromRGB(0, 0, 0), 0.5)),
		ColorSequenceKeypoint.new(1, T.Background:Lerp(Color3.fromRGB(255, 255, 255), 0.3))
	})
	gradient.Rotation = 135
	gradient.Parent = phoneFrame
	
	timeLabel.TextColor3 = T.Text
	backButton.TextColor3 = T.Text
	widgetTimeLabel.TextColor3 = T.Text
	widgetDateLabel.TextColor3 = T.SecondaryText
	
	-- Update shared object
	sharedObj.T = T
	
	-- Refresh current app
	if currentApp ~= "Home" then
		refreshCurrentApp()
	end
	
	-- Refresh home screen labels
	for _, child in ipairs(appGrid:GetChildren()) do
		for _, sub in ipairs(child:GetChildren()) do
			if sub:IsA("TextLabel") then
				sub.TextColor3 = T.Text
			end
		end
	end
end

applyTheme(appSettings.theme)

-- Make phone draggable
local dragging = false
local dragStart = nil
local startPos = nil

phoneFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = phoneFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

phoneFrame.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		phoneFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)