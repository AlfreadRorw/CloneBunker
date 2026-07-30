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
	
	-- Scroll container agar semua konten bisa diakses
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size = UDim2.new(1, 0, 1, 0)
	scrollFrame.Position = UDim2.new(0, 0, 0, 0)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 3
	scrollFrame.ScrollBarImageColor3 = T.Accent
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 480)
	scrollFrame.Parent = appFrame
	
	-- ========== PROFILE CARD ==========
	local profileCard = Instance.new("Frame")
	profileCard.Size = UDim2.new(1, -20, 0, 70)
	profileCard.Position = UDim2.new(0, 10, 0, 8)
	profileCard.BackgroundColor3 = T.Card
	profileCard.BorderSizePixel = 0
	shared.corner(profileCard, 14)
	profileCard.Parent = scrollFrame
	
	local avatar = Instance.new("ImageLabel")
	avatar.Size = UDim2.new(0, 48, 0, 48)
	avatar.Position = UDim2.new(0, 11, 0.5, -24)
	avatar.BackgroundTransparency = 1
	shared.corner(avatar, 24)
	pcall(function()
		avatar.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	end)
	avatar.Parent = profileCard
	
	local appTitleLabel = Instance.new("TextLabel")
	appTitleLabel.Size = UDim2.new(0, 180, 0, 20)
	appTitleLabel.Position = UDim2.new(0, 72, 0, 12)
	appTitleLabel.BackgroundTransparency = 1
	appTitleLabel.Text = "Phone ID Viewer"
	appTitleLabel.TextColor3 = T.Text
	appTitleLabel.TextSize = 15
	appTitleLabel.Font = Enum.Font.GothamBold
	appTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	appTitleLabel.Parent = profileCard
	
	local versionLabel = Instance.new("TextLabel")
	versionLabel.Size = UDim2.new(0, 180, 0, 14)
	versionLabel.Position = UDim2.new(0, 72, 0, 33)
	versionLabel.BackgroundTransparency = 1
	versionLabel.Text = "Version 1.0.0"
	versionLabel.TextColor3 = T.SecondaryText
	versionLabel.TextSize = 10
	versionLabel.Font = Enum.Font.Gotham
	versionLabel.TextXAlignment = Enum.TextXAlignment.Left
	versionLabel.Parent = profileCard
	
	local devLabel = Instance.new("TextLabel")
	devLabel.Size = UDim2.new(0, 180, 0, 14)
	devLabel.Position = UDim2.new(0, 72, 0, 47)
	devLabel.BackgroundTransparency = 1
	devLabel.Text = "Developer: AlfreadRorw"
	devLabel.TextColor3 = T.Accent
	devLabel.TextSize = 9
	devLabel.Font = Enum.Font.Gotham
	devLabel.TextXAlignment = Enum.TextXAlignment.Left
	devLabel.Parent = profileCard
	
	-- ========== THEME SECTION ==========
	local themeSectionY = 90
	
	local themeSectionLabel = Instance.new("TextLabel")
	themeSectionLabel.Size = UDim2.new(1, -20, 0, 20)
	themeSectionLabel.Position = UDim2.new(0, 12, 0, themeSectionY)
	themeSectionLabel.BackgroundTransparency = 1
	themeSectionLabel.Text = "Color Theme"
	themeSectionLabel.TextColor3 = T.Text
	themeSectionLabel.TextSize = 13
	themeSectionLabel.Font = Enum.Font.GothamSemibold
	themeSectionLabel.TextXAlignment = Enum.TextXAlignment.Left
	themeSectionLabel.Parent = scrollFrame
	
	local currentThemeLabel = Instance.new("TextLabel")
	currentThemeLabel.Size = UDim2.new(1, -20, 0, 14)
	currentThemeLabel.Position = UDim2.new(0, 12, 0, themeSectionY + 18)
	currentThemeLabel.BackgroundTransparency = 1
	currentThemeLabel.Text = "Current: " .. (appSettings.theme or "Biru")
	currentThemeLabel.TextColor3 = T.Accent
	currentThemeLabel.TextSize = 10
	currentThemeLabel.Font = Enum.Font.Gotham
	currentThemeLabel.TextXAlignment = Enum.TextXAlignment.Left
	currentThemeLabel.Parent = scrollFrame
	
	local themeNames = {"Putih", "Ungu", "Biru", "Merah", "Emas", "Hijau"}
	local themeColors = {
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(150, 100, 255),
		Color3.fromRGB(0, 150, 255),
		Color3.fromRGB(255, 60, 60),
		Color3.fromRGB(255, 200, 50),
		Color3.fromRGB(50, 200, 100)
	}
	
	local themeGridY = themeSectionY + 38
	
	for i, themeName in ipairs(themeNames) do
		local col = (i - 1) % 3
		local row = math.floor((i - 1) / 3)
		local xPos = 12 + col * 100
		local yPos = row * 48
		
		local swatchContainer = Instance.new("Frame")
		swatchContainer.Size = UDim2.new(0, 88, 0, 40)
		swatchContainer.Position = UDim2.new(0, xPos, 0, themeGridY + yPos)
		swatchContainer.BackgroundTransparency = 1
		swatchContainer.Parent = scrollFrame
		
		local swatch = Instance.new("TextButton")
		swatch.Size = UDim2.new(0, 34, 0, 34)
		swatch.Position = UDim2.new(0, 5, 0, 3)
		swatch.BackgroundColor3 = themeColors[i]
		swatch.BorderSizePixel = 0
		shared.corner(swatch, 17)
		swatch.Text = ""
		swatch.Parent = swatchContainer
		
		-- Stroke for white theme
		if themeName == "Putih" then
			shared.stroke(swatch, Color3.fromRGB(180, 180, 180), 1)
		end
		
		-- Active indicator
		if appSettings.theme == themeName then
			local dot = Instance.new("Frame")
			dot.Size = UDim2.new(0, 8, 0, 8)
			dot.Position = UDim2.new(0.5, -4, 0.5, -4)
			dot.BackgroundColor3 = themeName == "Putih" and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
			dot.BorderSizePixel = 0
			Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
			dot.Parent = swatch
		end
		
		local themeNameLabel = Instance.new("TextLabel")
		themeNameLabel.Size = UDim2.new(0, 45, 1, 0)
		themeNameLabel.Position = UDim2.new(0, 42, 0, 0)
		themeNameLabel.BackgroundTransparency = 1
		themeNameLabel.Text = themeName
		themeNameLabel.TextColor3 = T.Text
		themeNameLabel.TextSize = 11
		themeNameLabel.Font = Enum.Font.Gotham
		themeNameLabel.TextXAlignment = Enum.TextXAlignment.Left
		themeNameLabel.Parent = swatchContainer
		
		swatch.MouseButton1Click:Connect(function()
			appSettings.theme = themeName
			saveJSON("PhoneIDViewer_Settings.json", appSettings)
			currentThemeLabel.Text = "Current: " .. themeName
			pulseIsland("Theme: " .. themeName .. " (Re-execute to apply)", 2)
		end)
	end
	
	-- ========== WALLPAPER SECTION ==========
	local wallpaperY = themeGridY + 110
	
	local wallpaperSectionLabel = Instance.new("TextLabel")
	wallpaperSectionLabel.Size = UDim2.new(1, -20, 0, 20)
	wallpaperSectionLabel.Position = UDim2.new(0, 12, 0, wallpaperY)
	wallpaperSectionLabel.BackgroundTransparency = 1
	wallpaperSectionLabel.Text = "Wallpaper"
	wallpaperSectionLabel.TextColor3 = T.Text
	wallpaperSectionLabel.TextSize = 13
	wallpaperSectionLabel.Font = Enum.Font.GothamSemibold
	wallpaperSectionLabel.TextXAlignment = Enum.TextXAlignment.Left
	wallpaperSectionLabel.Parent = scrollFrame
	
	local wallpaperStatusLabel = Instance.new("TextLabel")
	wallpaperStatusLabel.Size = UDim2.new(1, -20, 0, 14)
	wallpaperStatusLabel.Position = UDim2.new(0, 12, 0, wallpaperY + 18)
	wallpaperStatusLabel.BackgroundTransparency = 1
	wallpaperStatusLabel.Text = appSettings.wallpaperURL ~= "" and "✓ Wallpaper active" or "No wallpaper set"
	wallpaperStatusLabel.TextColor3 = appSettings.wallpaperURL ~= "" and Color3.fromRGB(100, 200, 100) or T.SecondaryText
	wallpaperStatusLabel.TextSize = 10
	wallpaperStatusLabel.Font = Enum.Font.Gotham
	wallpaperStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
	wallpaperStatusLabel.Parent = scrollFrame
	
	local wallpaperInput = Instance.new("TextBox")
	wallpaperInput.Size = UDim2.new(1, -24, 0, 34)
	wallpaperInput.Position = UDim2.new(0, 12, 0, wallpaperY + 36)
	wallpaperInput.BackgroundColor3 = T.Card
	wallpaperInput.BorderSizePixel = 0
	shared.corner(wallpaperInput, 10)
	shared.stroke(wallpaperInput, T.Stroke)
	wallpaperInput.Font = Enum.Font.Gotham
	wallpaperInput.TextSize = 11
	wallpaperInput.TextColor3 = T.Text
	wallpaperInput.PlaceholderText = "Enter Catbox image URL..."
	wallpaperInput.PlaceholderColor3 = T.SecondaryText
	wallpaperInput.Text = appSettings.wallpaperURL or ""
	wallpaperInput.ClearTextOnFocus = false
	wallpaperInput.Parent = scrollFrame
	
	local wallpaperButtons = Instance.new("Frame")
	wallpaperButtons.Size = UDim2.new(1, -24, 0, 28)
	wallpaperButtons.Position = UDim2.new(0, 12, 0, wallpaperY + 76)
	wallpaperButtons.BackgroundTransparency = 1
	wallpaperButtons.Parent = scrollFrame
	
	local applyWallBtn = Instance.new("TextButton")
	applyWallBtn.Size = UDim2.new(0, 75, 0, 28)
	applyWallBtn.BackgroundColor3 = T.Accent
	applyWallBtn.BorderSizePixel = 0
	shared.corner(applyWallBtn, 8)
	applyWallBtn.Text = "Apply"
	applyWallBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	applyWallBtn.TextSize = 11
	applyWallBtn.Font = Enum.Font.GothamSemibold
	applyWallBtn.Parent = wallpaperButtons
	
	applyWallBtn.MouseButton1Click:Connect(function()
		local url = wallpaperInput.Text
		if url == "" then
			pulseIsland("Enter a URL first!", 1.5)
			return
		end
		appSettings.wallpaperURL = url
		saveJSON("PhoneIDViewer_Settings.json", appSettings)
		local success = applyWallpaper(url)
		if success then
			wallpaperStatusLabel.Text = "✓ Wallpaper active"
			wallpaperStatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
			pulseIsland("Wallpaper applied!", 1.5)
		else
			wallpaperStatusLabel.Text = "Failed to load"
			wallpaperStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
			pulseIsland("Failed to load wallpaper", 2)
		end
	end)
	
	local removeWallBtn = Instance.new("TextButton")
	removeWallBtn.Size = UDim2.new(0, 75, 0, 28)
	removeWallBtn.Position = UDim2.new(0, 85, 0, 0)
	removeWallBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
	removeWallBtn.BorderSizePixel = 0
	shared.corner(removeWallBtn, 8)
	removeWallBtn.Text = "Remove"
	removeWallBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	removeWallBtn.TextSize = 11
	removeWallBtn.Font = Enum.Font.GothamSemibold
	removeWallBtn.Parent = wallpaperButtons
	
	removeWallBtn.MouseButton1Click:Connect(function()
		appSettings.wallpaperURL = ""
		saveJSON("PhoneIDViewer_Settings.json", appSettings)
		applyWallpaper("")
		wallpaperInput.Text = ""
		wallpaperStatusLabel.Text = "No wallpaper set"
		wallpaperStatusLabel.TextColor3 = T.SecondaryText
		pulseIsland("Wallpaper removed", 1.5)
	end)
	
	-- ========== WIDGET BACKGROUND SECTION ==========
	local widgetY = wallpaperY + 115
	
	local widgetSectionLabel = Instance.new("TextLabel")
	widgetSectionLabel.Size = UDim2.new(1, -20, 0, 20)
	widgetSectionLabel.Position = UDim2.new(0, 12, 0, widgetY)
	widgetSectionLabel.BackgroundTransparency = 1
	widgetSectionLabel.Text = "Widget Background"
	widgetSectionLabel.TextColor3 = T.Text
	widgetSectionLabel.TextSize = 13
	widgetSectionLabel.Font = Enum.Font.GothamSemibold
	widgetSectionLabel.TextXAlignment = Enum.TextXAlignment.Left
	widgetSectionLabel.Parent = scrollFrame
	
	local widgetStatusLabel = Instance.new("TextLabel")
	widgetStatusLabel.Size = UDim2.new(1, -20, 0, 14)
	widgetStatusLabel.Position = UDim2.new(0, 12, 0, widgetY + 18)
	widgetStatusLabel.BackgroundTransparency = 1
	widgetStatusLabel.Text = appSettings.widgetBackgroundURL ~= "" and "✓ Widget bg active" or "No widget background"
	widgetStatusLabel.TextColor3 = appSettings.widgetBackgroundURL ~= "" and Color3.fromRGB(100, 200, 100) or T.SecondaryText
	widgetStatusLabel.TextSize = 10
	widgetStatusLabel.Font = Enum.Font.Gotham
	widgetStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
	widgetStatusLabel.Parent = scrollFrame
	
	local widgetInput = Instance.new("TextBox")
	widgetInput.Size = UDim2.new(1, -24, 0, 34)
	widgetInput.Position = UDim2.new(0, 12, 0, widgetY + 36)
	widgetInput.BackgroundColor3 = T.Card
	widgetInput.BorderSizePixel = 0
	shared.corner(widgetInput, 10)
	shared.stroke(widgetInput, T.Stroke)
	widgetInput.Font = Enum.Font.Gotham
	widgetInput.TextSize = 11
	widgetInput.TextColor3 = T.Text
	widgetInput.PlaceholderText = "Enter Catbox image URL..."
	widgetInput.PlaceholderColor3 = T.SecondaryText
	widgetInput.Text = appSettings.widgetBackgroundURL or ""
	widgetInput.ClearTextOnFocus = false
	widgetInput.Parent = scrollFrame
	
	local widgetButtons = Instance.new("Frame")
	widgetButtons.Size = UDim2.new(1, -24, 0, 28)
	widgetButtons.Position = UDim2.new(0, 12, 0, widgetY + 76)
	widgetButtons.BackgroundTransparency = 1
	widgetButtons.Parent = scrollFrame
	
	local applyWidgetBgBtn = Instance.new("TextButton")
	applyWidgetBgBtn.Size = UDim2.new(0, 75, 0, 28)
	applyWidgetBgBtn.BackgroundColor3 = T.Accent
	applyWidgetBgBtn.BorderSizePixel = 0
	shared.corner(applyWidgetBgBtn, 8)
	applyWidgetBgBtn.Text = "Apply"
	applyWidgetBgBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	applyWidgetBgBtn.TextSize = 11
	applyWidgetBgBtn.Font = Enum.Font.GothamSemibold
	applyWidgetBgBtn.Parent = widgetButtons
	
	applyWidgetBgBtn.MouseButton1Click:Connect(function()
		local url = widgetInput.Text
		if url == "" then
			pulseIsland("Enter a URL first!", 1.5)
			return
		end
		appSettings.widgetBackgroundURL = url
		saveJSON("PhoneIDViewer_Settings.json", appSettings)
		local success = applyWidget(url)
		if success then
			widgetStatusLabel.Text = "✓ Widget bg active"
			widgetStatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
			pulseIsland("Widget bg applied!", 1.5)
		else
			widgetStatusLabel.Text = "Failed to load"
			widgetStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
			pulseIsland("Failed to load widget bg", 2)
		end
	end)
	
	local removeWidgetBgBtn = Instance.new("TextButton")
	removeWidgetBgBtn.Size = UDim2.new(0, 75, 0, 28)
	removeWidgetBgBtn.Position = UDim2.new(0, 85, 0, 0)
	removeWidgetBgBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
	removeWidgetBgBtn.BorderSizePixel = 0
	shared.corner(removeWidgetBgBtn, 8)
	removeWidgetBgBtn.Text = "Remove"
	removeWidgetBgBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	removeWidgetBgBtn.TextSize = 11
	removeWidgetBgBtn.Font = Enum.Font.GothamSemibold
	removeWidgetBgBtn.Parent = widgetButtons
	
	removeWidgetBgBtn.MouseButton1Click:Connect(function()
		appSettings.widgetBackgroundURL = ""
		saveJSON("PhoneIDViewer_Settings.json", appSettings)
		applyWidget("")
		widgetInput.Text = ""
		widgetStatusLabel.Text = "No widget background"
		widgetStatusLabel.TextColor3 = T.SecondaryText
		pulseIsland("Widget bg removed", 1.5)
	end)
	
	-- Update canvas size
	local finalY = widgetY + 110
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, finalY)
end