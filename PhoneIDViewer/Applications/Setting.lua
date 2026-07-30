return function(appFrame, shared)
    local T = shared.T
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- Profile
    local profile = shared.stroke(shared.corner(Instance.new("Frame", appFrame), 12), T.Accent, 1.5, 0.3)
    profile.Size = UDim2.new(1,0,0,86); profile.BackgroundColor3 = T.Card2; profile.LayoutOrder = 0

    local av = shared.stroke(shared.corner(Instance.new("ImageLabel", profile), 100), T.Accent, 2, 0.2)
    av.Size = UDim2.new(0,60,0,60); av.Position = UDim2.new(0,13,0.5,-30); av.BackgroundColor3 = T.BG
    av.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..LocalPlayer.UserId.."&width=150&height=150&format=png"

    local nameLbl = Instance.new("TextLabel", profile)
    nameLbl.Size = UDim2.new(1,-90,0,22); nameLbl.Position = UDim2.new(0,82,0,14); nameLbl.BackgroundTransparency = 1
    nameLbl.Text = "Alfread"; nameLbl.TextColor3 = T.Text; nameLbl.Font = Enum.Font.GothamBlack; nameLbl.TextSize = 16
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left

    local tagLbl = Instance.new("TextLabel", profile)
    tagLbl.Size = UDim2.new(1,-90,0,16); tagLbl.Position = UDim2.new(0,82,0,38); tagLbl.BackgroundTransparency = 1
    tagLbl.Text = "Phone ID Viewer v5.0"; tagLbl.TextColor3 = T.Text2; tagLbl.Font = Enum.Font.Gotham; tagLbl.TextSize = 10
    tagLbl.TextXAlignment = Enum.TextXAlignment.Left

    local verLbl = Instance.new("TextLabel", profile)
    verLbl.Size = UDim2.new(1,-90,0,14); verLbl.Position = UDim2.new(0,82,0,56); verLbl.BackgroundTransparency = 1
    verLbl.Text = "Update via GitHub"; verLbl.TextColor3 = Color3.fromRGB(120,120,120); verLbl.Font = Enum.Font.Code; verLbl.TextSize = 9
    verLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Tema
    local themeLbl = Instance.new("TextLabel", appFrame)
    themeLbl.Size = UDim2.new(1,0,0,20); themeLbl.BackgroundTransparency = 1; themeLbl.LayoutOrder = 1
    themeLbl.Text = "Tema Warna"; themeLbl.TextColor3 = T.Text2; themeLbl.Font = Enum.Font.GothamBold; themeLbl.TextSize = 11
    themeLbl.TextXAlignment = Enum.TextXAlignment.Left

    local themeGrid = Instance.new("Frame", appFrame)
    themeGrid.Size = UDim2.new(1,0,0,130); themeGrid.BackgroundTransparency = 1; themeGrid.LayoutOrder = 2
    local gridLayout = Instance.new("UIGridLayout", themeGrid)
    gridLayout.CellSize = UDim2.new(0,84,0,60); gridLayout.CellPadding = UDim2.new(0,8,0,8)

    for i, preset in ipairs(shared.THEME_PRESETS) do
        local swatch = shared.pressFX(shared.stroke(shared.corner(Instance.new("TextButton", themeGrid), 10), i==shared.appSettings.themeIndex and preset.Accent or T.Border, i==shared.appSettings.themeIndex and 2 or 1))
        swatch.Size = UDim2.new(0,84,0,60); swatch.BackgroundColor3 = T.Card2; swatch.Text = ""; swatch.AutoButtonColor = false; swatch.LayoutOrder = i
        local dot = shared.corner(Instance.new("Frame", swatch), 100)
        dot.Size = UDim2.new(0,22,0,22); dot.Position = UDim2.new(0.5,-11,0,6); dot.BackgroundColor3 = preset.Accent
        local swLbl = Instance.new("TextLabel", swatch)
        swLbl.Size = UDim2.new(1,0,0,16); swLbl.Position = UDim2.new(0,0,0,32); swLbl.BackgroundTransparency = 1
        swLbl.Text = preset.Name; swLbl.TextColor3 = T.Text2; swLbl.Font = Enum.Font.GothamBold; swLbl.TextSize = 10
        swatch.MouseButton1Click:Connect(function()
            shared.appSettings.themeIndex = i
            T.Accent = preset.Accent; T.OnAccent = preset.OnAccent
            shared.persistSettings(); shared.pulseIsland("Tema: "..preset.Name)
        end)
    end

    -- Wallpaper
    local wallLbl = Instance.new("TextLabel", appFrame)
    wallLbl.Size = UDim2.new(1,0,0,20); wallLbl.BackgroundTransparency = 1; wallLbl.LayoutOrder = 3
    wallLbl.Text = "Wallpaper (URL Catbox)"; wallLbl.TextColor3 = T.Text2; wallLbl.Font = Enum.Font.GothamBold; wallLbl.TextSize = 11
    wallLbl.TextXAlignment = Enum.TextXAlignment.Left

    local wallCard = shared.stroke(shared.corner(Instance.new("Frame", appFrame), 12), T.Border, 1, 0.3)
    wallCard.Size = UDim2.new(1,0,0,120); wallCard.BackgroundColor3 = T.Card2; wallCard.LayoutOrder = 4

    local wallHint = Instance.new("TextLabel", wallCard)
    wallHint.Size = UDim2.new(1,-20,0,28); wallHint.Position = UDim2.new(0,10,0,8); wallHint.BackgroundTransparency = 1
    wallHint.Text = "Masukkan URL gambar dari Catbox"; wallHint.TextColor3 = T.Text2; wallHint.Font = Enum.Font.Gotham; wallHint.TextSize = 9
    wallHint.TextWrapped = true; wallHint.TextXAlignment = Enum.TextXAlignment.Left

    local wallInput = shared.stroke(shared.corner(Instance.new("TextBox", wallCard), 8), T.Border, 1, 0.3)
    wallInput.Size = UDim2.new(1,-20,0,32); wallInput.Position = UDim2.new(0,10,0,40); wallInput.BackgroundColor3 = T.Card
    wallInput.PlaceholderText = "https://files.catbox.moe/xxxxx.png"; wallInput.Text = shared.appSettings.wallpaperUrl or ""
    wallInput.TextColor3 = T.Text; wallInput.Font = Enum.Font.Gotham; wallInput.TextSize = 11; wallInput.ClearTextOnFocus = false

    local wallApplyBtn = shared.pressFX(shared.corner(Instance.new("TextButton", wallCard), 8))
    wallApplyBtn.Size = UDim2.new(0.48,-14,0,32); wallApplyBtn.Position = UDim2.new(0,10,0,80)
    wallApplyBtn.BackgroundColor3 = T.Accent; wallApplyBtn.Text = "Terapkan"; wallApplyBtn.TextColor3 = T.OnAccent
    wallApplyBtn.Font = Enum.Font.GothamBold; wallApplyBtn.TextSize = 12; wallApplyBtn.AutoButtonColor = false
    wallApplyBtn.MouseButton1Click:Connect(function()
        shared.appSettings.wallpaperUrl = wallInput.Text
        shared.persistSettings()
        shared.applyWallpaper()
        shared.pulseIsland("Wallpaper diterapkan!")
    end)

    local wallClearBtn = shared.pressFX(shared.corner(Instance.new("TextButton", wallCard), 8))
    wallClearBtn.Size = UDim2.new(0.48,-14,0,32); wallClearBtn.Position = UDim2.new(0.52,4,0,80)
    wallClearBtn.BackgroundColor3 = Color3.fromRGB(50,30,35); wallClearBtn.Text = "Hapus"; wallClearBtn.TextColor3 = T.Red
    wallClearBtn.Font = Enum.Font.GothamBold; wallClearBtn.TextSize = 12; wallClearBtn.AutoButtonColor = false
    wallClearBtn.MouseButton1Click:Connect(function()
        wallInput.Text = ""
        shared.appSettings.wallpaperUrl = ""
        shared.persistSettings()
        shared.applyWallpaper()
        shared.pulseIsland("Wallpaper dihapus")
    end)

    -- Widget
    local widLbl = Instance.new("TextLabel", appFrame)
    widLbl.Size = UDim2.new(1,0,0,20); widLbl.BackgroundTransparency = 1; widLbl.LayoutOrder = 5
    widLbl.Text = "Widget Background (URL Catbox)"; widLbl.TextColor3 = T.Text2; widLbl.Font = Enum.Font.GothamBold; widLbl.TextSize = 11
    widLbl.TextXAlignment = Enum.TextXAlignment.Left

    local widCard = shared.stroke(shared.corner(Instance.new("Frame", appFrame), 12), T.Border, 1, 0.3)
    widCard.Size = UDim2.new(1,0,0,120); widCard.BackgroundColor3 = T.Card2; widCard.LayoutOrder = 6

    local widHint = Instance.new("TextLabel", widCard)
    widHint.Size = UDim2.new(1,-20,0,28); widHint.Position = UDim2.new(0,10,0,8); widHint.BackgroundTransparency = 1
    widHint.Text = "Masukkan URL gambar untuk Widget"; widHint.TextColor3 = T.Text2; widHint.Font = Enum.Font.Gotham; widHint.TextSize = 9
    widHint.TextWrapped = true; widHint.TextXAlignment = Enum.TextXAlignment.Left

    local widInput = shared.stroke(shared.corner(Instance.new("TextBox", widCard), 8), T.Border, 1, 0.3)
    widInput.Size = UDim2.new(1,-20,0,32); widInput.Position = UDim2.new(0,10,0,40); widInput.BackgroundColor3 = T.Card
    widInput.PlaceholderText = "https://files.catbox.moe/xxxxx.png"; widInput.Text = shared.appSettings.widgetUrl or ""
    widInput.TextColor3 = T.Text; widInput.Font = Enum.Font.Gotham; widInput.TextSize = 11; widInput.ClearTextOnFocus = false

    local widApplyBtn = shared.pressFX(shared.corner(Instance.new("TextButton", widCard), 8))
    widApplyBtn.Size = UDim2.new(0.48,-14,0,32); widApplyBtn.Position = UDim2.new(0,10,0,80)
    widApplyBtn.BackgroundColor3 = T.Accent; widApplyBtn.Text = "Terapkan"; widApplyBtn.TextColor3 = T.OnAccent
    widApplyBtn.Font = Enum.Font.GothamBold; widApplyBtn.TextSize = 12; widApplyBtn.AutoButtonColor = false
    widApplyBtn.MouseButton1Click:Connect(function()
        shared.appSettings.widgetUrl = widInput.Text
        shared.persistSettings()
        shared.applyWidget()
        shared.pulseIsland("Widget diterapkan!")
    end)

    local widClearBtn = shared.pressFX(shared.corner(Instance.new("TextButton", widCard), 8))
    widClearBtn.Size = UDim2.new(0.48,-14,0,32); widClearBtn.Position = UDim2.new(0.52,4,0,80)
    widClearBtn.BackgroundColor3 = Color3.fromRGB(50,30,35); widClearBtn.Text = "Hapus"; widClearBtn.TextColor3 = T.Red
    widClearBtn.Font = Enum.Font.GothamBold; widClearBtn.TextSize = 12; widClearBtn.AutoButtonColor = false
    widClearBtn.MouseButton1Click:Connect(function()
        widInput.Text = ""
        shared.appSettings.widgetUrl = ""
        shared.persistSettings()
        shared.applyWidget()
        shared.pulseIsland("Widget dihapus")
    end)

    -- Footer
    local footer = Instance.new("TextLabel", appFrame)
    footer.Size = UDim2.new(1,0,0,36); footer.BackgroundTransparency = 1; footer.LayoutOrder = 7
    footer.Text = "Dibuat oleh Alfread.\nGratis dipakai & dimodifikasi."; footer.TextColor3 = T.Text2
    footer.Font = Enum.Font.Gotham; footer.TextSize = 9; footer.TextWrapped = true
end