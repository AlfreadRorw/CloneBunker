return function(appFrame, shared)
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local T = shared.T
	local THEME_PRESETS = shared.THEME_PRESETS
	local appSettings = shared.appSettings
	local saveJSON = shared.saveJSON
	local applyWallpaper = shared.applyWallpaper
	local applyWidget = shared.applyWidget
	local pulseIsland = shared.pulseIsland
	local refreshCurrentApp = shared.refreshCurrentApp
	
	-- Profile Card
	local profileCard = Instance.new("Frame")
	profileCard.Size = UDim2.new(1, -20, 0, 80)
	profileCard.Position = UDim2.new(0, 10, 0, 10)
	profileCard.BackgroundColor3 = T.Card
	profileCard.BorderSizePixel = 0
	shared.corner(profileCard, 14)
	profileCard.Parent = appFrame
	
	local avatar = Instance.new("ImageLabel")
	avatar.Size = UDim2.new(0, 55, 0, 55)
	avatar.Position = UDim2.new(0, 12, 0.5, -27)
	avatar.BackgroundTransparency = 1
	shared.corner(avatar, 27)
	pcall(function()
		avatar.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	end)
	avatar.Parent = profileCard
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0, 150, 0, 22)
	nameLabel.Position = UDim2.new(0, 80, 0, 15)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = "Phone ID Viewer"
	nameLabel.TextColor3 = T.Text
	nameLabel.TextSize = 15
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = profileCard
	
	local versionLabel = Instance.new("TextLabel")
	versionLabel.Size = UDim2.new(0, 150, 0, 16)
	versionLabel.Position = UDim2.new(0, 80, 0, 38)
	versionLabel.BackgroundTransparency = 1
	versionLabel.Text = "Version 1.0.0"
	versionLabel.TextColor3 = T.SecondaryText
	versionLabel.TextSize = 11
	versionLabel.Font = Enum.Font.Gotham
	versionLabel.TextXAlignment = Enum.TextXAlignment.Left
	versionLabel.Parent = profileCard
	
	local devLabel = Instance.new("TextLabel")
	devLabel.Size = UDim2.new(0, 150, 0, 16)
	devLabel.Position = UDim2.new(0, 80, 0, 54)
	devLabel.BackgroundTransparency = 1
	devLabel.Text = "by AlfreadRorw"
	devLabel.TextColor3 = T.Accent
	devLabel.TextSize = 10
	devLabel.Font = Enum.Font.Gotham
	devLabel.TextXAlignment = Enum.TextXAlignment.Left
	devLabel.Parent = profileCard
	
	-- Theme Section
	local themeSectionLabel = Instance.new("TextLabel")
	themeSectionLabel.Size = UDim2.new(1, -20, 0, 22)
	themeSectionLabel.Position = UDim2.new(0, 15, 0, 100)
	themeSectionLabel.BackgroundTransparency = 1
	themeSectionLabel.Text = "Color Theme"
	themeSectionLabel.TextColor3 = T.Text
	themeSectionLabel.TextSize = 14
	themeSectionLabel.Font = Enum.Font.GothamSemibold
	themeSectionLabel.TextXAlignment = Enum.TextXAlignment.Left
	themeSectionLabel.Parent = appFrame
	
	local themeNames = {"Putih", "Ungu", "Biru", "Merah", "Emas", "Hijau"}
	local themeColors = {
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(150, 100, 255),
		Color3.fromRGB(0, 150, 255),
		Color3.fromRGB(255, 60, 60),
		Color3.fromRGB(255, 200, 50),
		Color3.fromRGB(50, 200, 100)
	}
	
	local themeGrid = Instance.new("Frame")
	themeGrid.Size = UDim2.new(1, -20, 0, 55)
	themeGrid.Position = UDim2.new(0, 10, 0, 125)
	themeGrid.BackgroundTransparency = 1
	themeGrid.Parent = appFrame
	
	for i, themeName in ipairs(themeNames) do
		local swatch = Instance.new("TextButton")
		swatch.Size = UDim2.new(0, 42, 0, 42)
		swatch.Position = UDim2.new(0, (i - 1) * 48 + 5, 0, 5)
		swatch.BackgroundColor3 = themeColors[i]
		swatch.BorderSizePixel = 0
		shared.corner(swatch, 21)
		swatch.Text = ""
		swatch.Parent = themeGrid
		
		-- Stroke for white theme
		if themeName == "Putih" then
			shared.stroke(swatch, Color3.fromRGB(200, 200, 200), 1)
		end
		
		-- Accent dot for active
		if appSettings.theme == themeName then
			local dot = Instance.new("Frame")
			dot.Size = UDim2.new(0, 10, 0, 10)
			dot.Position = UDim2.new(0.5, -5, 0.5, -5)
			dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			dot.BorderSizePixel = 0
			Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
			dot.Name = "ActiveDot"
			dot.Parent = swatch
			
			if themeName == "Putih" then
				dot.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			end
		end
		
		swatch.MouseButton1Click:Connect(function()
			appSettings.theme = themeName
			saveJSON("PhoneIDViewer_Settings.json", appSettings)
			
			-- Update theme
			local newT = THEME_PRESETS[themeName]
			shared.T = newT
			
			-- Rebuild setting with new theme
			pulseIsland("Theme: " .. themeName, 2)
			task.wait(0.3)
			refreshCurrentApp()
		end)
	end
	
	-- Wallpaper Section
	local wallpaperSectionLabel = Instance.new("TextLabel")
	wallpaperSectionLabel.Size = UDim2.new(1, -20, 0, 22)
	wallpaperSectionLabel.Position = UDim2.new(0, 15, 0, 190)
	wallpaperSectionLabel.BackgroundTransparency = 1
	wallpaperSectionLabel.Text = "Wallpaper"
	wallpaperSectionLabel.TextColor3 = T.Text
	wallpaperSectionLabel.TextSize = 14
	wallpaperSectionLabel.Font = Enum.Font.GothamSemibold
	wallpaperSectionLabel.TextXAlignment = Enum.TextXAlignment.Left
	wallpaperSectionLabel.Parent = appFrame
	
	local wallpaperInput = Instance.new("TextBox")
	wallpaperInput.Size = UDim2.new(1, -30, 0, 34)
	wallpaperInput.Position = UDim2.new(0, 15, 0, 215)
	wallpaperInput.BackgroundColor3 = T.Card
	wallpaperInput.BorderSizePixel = 0
	shared.corner(wallpaperInput, 10)
	shared.stroke(wallpaperInput, T.Stroke)
	wallpaperInput.Font = Enum.Font.Gotham
	wallpaperInput.TextSize = 12
	wallpaperInput.TextColor3 = T.Text
	wallpaperInput.PlaceholderText = "Catbox URL for wallpaper..."
	wallpaperInput.PlaceholderColor3 = T.SecondaryText
	wallpaperInput.Text = appSettings.wallpaperURL or ""
	wallpaperInput.ClearTextOnFocus = false
	wallpaperInput.Parent = appFrame
	
	local wallpaperButtons = Instance.new("Frame")
	wallpaperButtons.Size = UDim2.new(1, -30, 0, 30)
	wallpaperButtons.Position = UDim2.new(0, 15, 0, 255)
	wallpaperButtons.BackgroundTransparency = 1
	wallpaperButtons.Parent = appFrame
	
	local applyWallBtn = Instance.new("TextButton")
	applyWallBtn.Size = UDim2.new(0, 80, 0, 28)
	applyWallBtn.Position = UDim2.new(0, 0, 0, 0)
	applyWallBtn.BackgroundColor3 = T.Accent
	applyWallBtn.BorderSizePixel = 0
	shared.corner(applyWallBtn, 8)
	applyWallBtn.Text = "Apply"
	applyWallBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	applyWallBtn.TextSize = 12
	applyWallBtn.Font = Enum.Font.GothamSemibold
	applyWallBtn.Parent = wallpaperButtons
	
	applyWallBtn.MouseButton1Click:Connect(function()
		local url = wallpaperInput.Text
		appSettings.wallpaperURL = url
		saveJSON("PhoneIDViewer_Settings.json", appSettings)
		if applyWallpaper(url) then
			pulseIsland("Wallpaper applied!", 2)
		else
			pulseIsland("Failed to load wallpaper", 2)
		end
	end)
	
	local removeWallBtn = Instance.new("TextButton")
	removeWallBtn.Size = UDim2.new(0, 80, 0, 28)
	removeWallBtn.Position = UDim2.new(0, 90, 0, 0)
	removeWallBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
	removeWallBtn.BorderSizePixel = 0
	shared.corner(removeWallBtn, 8)
	removeWallBtn.Text = "Remove"
	removeWallBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	removeWallBtn.TextSize = 12
	removeWallBtn.Font = Enum.Font.GothamSemibold
	removeWallBtn.Parent = wallpaperButtons
	
	removeWallBtn.MouseButton1Click:Connect(function()
		appSettings.wallpaperURL = ""
		saveJSON("PhoneIDViewer_Settings.json", appSettings)
		applyWallpaper("")
		wallpaperInput.Text = ""
		pulseIsland("Wallpaper removed", 1.5)
	end)
	
	-- Widget Background Section
	local widgetSectionLabel = Instance.new("TextLabel")
	widgetSectionLabel.Size = UDim2.new(1, -20, 0, 22)
	widgetSectionLabel.Position = UDim2.new(0, 15, 0, 295)
	widgetSectionLabel.BackgroundTransparency = 1
	widgetSectionLabel.Text = "Widget Background"
	widgetSectionLabel.TextColor3 = T.Text
	widgetSectionLabel.TextSize = 14
	widgetSectionLabel.Font = Enum.Font.GothamSemibold
	widgetSectionLabel.TextXAlignment = Enum.TextXAlignment.Left
	widgetSectionLabel.Parent = appFrame
	
	local widgetInput = Instance.new("TextBox")
	widgetInput.Size = UDim2.new(1, -30, 0, 34)
	widgetInput.Position = UDim2.new(0, 15, 0, 320)
	widgetInput.BackgroundColor3 = T.Card
	widgetInput.BorderSizePixel = 0
	shared.corner(widgetInput, 10)
	shared.stroke(widgetInput, T.Stroke)
	widgetInput.Font = Enum.Font.Gotham
	widgetInput.TextSize = 12
	widgetInput.TextColor3 = T.Text
	widgetInput.PlaceholderText = "Catbox URL for widget background..."
	widgetInput.PlaceholderColor3 = T.SecondaryText
	widgetInput.Text = appSettings.widgetBackgroundURL or ""
	widgetInput.ClearTextOnFocus = false
	widgetInput.Parent = appFrame
	
	local widgetButtons = Instance.new("Frame")
	widgetButtons.Size = UDim2.new(1, -30, 0, 30)
	widgetButtons.Position = UDim2.new(0, 15, 0, 360)
	widgetButtons.BackgroundTransparency = 1
	widgetButtons.Parent = appFrame
	
	local applyWidgetBtn = Instance.new("TextButton")
	applyWidgetBtn.Size = UDim2.new(0, 80, 0, 28)
	applyWidgetBtn.Position = UDim2.new(0, 0, 0, 0)
	applyWidgetBtn.BackgroundColor3 = T.Accent
	applyWidgetBtn.BorderSizePixel = 0
	shared.corner(applyWidgetBtn, 8)
	applyWidgetBtn.Text = "Apply"
	applyWidgetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	applyWidgetBtn.TextSize = 12
	applyWidgetBtn.Font = Enum.Font.GothamSemibold
	applyWidgetBtn.Parent = widgetButtons
	
	applyWidgetBtn.MouseButton1Click:Connect(function()
		local url = widgetInput.Text
		appSettings.widgetBackgroundURL = url
		saveJSON("PhoneIDViewer_Settings.json", appSettings)
		if applyWidget(url) then
			pulseIsland("Widget bg applied!", 2)
		else
			pulseIsland("Failed to load widget bg", 2)
		end
	end)
	
	local removeWidgetBtn = Instance.new("TextButton")
	removeWidgetBtn.Size = UDim2.new(0, 80, 0, 28)
	removeWidgetBtn.Position = UDim2.new(0, 90, 0, 0)
	removeWidgetBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
	removeWidgetBtn.BorderSizePixel = 0
	shared.corner(removeWidgetBtn, 8)
	removeWidgetBtn.Text = "Remove"
	removeWidgetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	removeWidgetBtn.TextSize = 12
	removeWidgetBtn.Font = Enum.Font.GothamSemibold
	removeWidgetBtn.Parent = widgetButtons
	
	removeWidgetBtn.MouseButton1Click:Connect(function()
		appSettings.widgetBackgroundURL = ""
		saveJSON("PhoneIDViewer_Settings.json", appSettings)
		applyWidget("")
		widgetInput.Text = ""
		pulseIsland("Widget bg removed", 1.5)
	end)
end