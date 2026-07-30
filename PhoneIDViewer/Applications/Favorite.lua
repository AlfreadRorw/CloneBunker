return function(appFrame, shared)
    local T = shared.T
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    -- Pemain favorit
    local section1 = Instance.new("TextLabel", appFrame)
    section1.Size = UDim2.new(1,0,0,20); section1.BackgroundTransparency = 1; section1.LayoutOrder = 0
    section1.Text = "Pemain Favorit"; section1.TextColor3 = T.Text2; section1.Font = Enum.Font.GothamBold
    section1.TextSize = 11; section1.TextXAlignment = Enum.TextXAlignment.Left
    
    local anyFav = false
    for _,p in ipairs(Players:GetPlayers()) do
        if shared.favPlayerSet[tostring(p.UserId)] then
            anyFav = true
            local row = shared.stroke(shared.corner(Instance.new("Frame", appFrame), 10), T.Gold, 1, 0.4)
            row.Size = UDim2.new(1,0,0,60); row.BackgroundColor3 = T.Card2; row.LayoutOrder = 1
            
            local av = shared.corner(Instance.new("ImageLabel", row), 100)
            av.Size = UDim2.new(0,44,0,44); av.Position = UDim2.new(0,8,0.5,-22)
            av.BackgroundColor3 = T.BG
            av.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..p.UserId.."&width=100&height=100&format=png"
            
            local nameLbl = Instance.new("TextLabel", row)
            nameLbl.Size = UDim2.new(1,-140,0,34); nameLbl.Position = UDim2.new(0,60,0,12)
            nameLbl.BackgroundTransparency = 1; nameLbl.Text = p.DisplayName; nameLbl.TextColor3 = T.Text
            nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextSize = 13; nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            
            local selBtn = shared.pressFX(shared.corner(Instance.new("TextButton", row), 8))
            selBtn.Size = UDim2.new(0,70,0,30); selBtn.Position = UDim2.new(1,-76,0.5,-15)
            selBtn.BackgroundColor3 = T.Accent; selBtn.Text = "Pilih"; selBtn.TextColor3 = T.OnAccent
            selBtn.Font = Enum.Font.GothamBold; selBtn.TextSize = 11; selBtn.AutoButtonColor = false
            selBtn.MouseButton1Click:Connect(function() shared.selectedTargetPlayer = p; shared.pulseIsland("Target: "..p.DisplayName) end)
        end
    end
    if not anyFav then
        local none = Instance.new("TextLabel", appFrame)
        none.Size = UDim2.new(1,0,0,30); none.BackgroundTransparency = 1; none.LayoutOrder = 2
        none.Text = "Belum ada pemain favorit."; none.TextColor3 = T.Text2; none.Font = Enum.Font.Gotham; none.TextSize = 11
    end
    
    -- Preset favorit
    local section2 = Instance.new("TextLabel", appFrame)
    section2.Size = UDim2.new(1,0,0,20); section2.BackgroundTransparency = 1; section2.LayoutOrder = 3
    section2.Text = "Preset Favorit"; section2.TextColor3 = T.Text2; section2.Font = Enum.Font.GothamBold
    section2.TextSize = 11; section2.TextXAlignment = Enum.TextXAlignment.Left
    
    local anyPreset = false
    for i,p in ipairs(shared.presets) do
        if p.favorite then
            anyPreset = true
            local row = shared.stroke(shared.corner(Instance.new("Frame", appFrame), 10), T.Gold, 1, 0.4)
            row.Size = UDim2.new(1,0,0,66); row.BackgroundColor3 = T.Card2; row.LayoutOrder = 4+i
            
            local nameLbl = Instance.new("TextLabel", row)
            nameLbl.Size = UDim2.new(1,-90,0,20); nameLbl.Position = UDim2.new(0,10,0,8)
            nameLbl.BackgroundTransparency = 1; nameLbl.Text = p.name; nameLbl.TextColor3 = T.Text
            nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextSize = 12; nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
            
            local infoLbl = Instance.new("TextLabel", row)
            infoLbl.Size = UDim2.new(1,-90,0,16); infoLbl.Position = UDim2.new(0,10,0,28)
            infoLbl.BackgroundTransparency = 1; infoLbl.Text = #p.ids.." item"; infoLbl.TextColor3 = T.Text2
            infoLbl.Font = Enum.Font.Gotham; infoLbl.TextSize = 10; infoLbl.TextXAlignment = Enum.TextXAlignment.Left
            
            local copyBtn = shared.pressFX(shared.corner(Instance.new("TextButton", row), 8))
            copyBtn.Size = UDim2.new(0,80,0,30); copyBtn.Position = UDim2.new(1,-86,0.5,-15)
            copyBtn.BackgroundColor3 = T.Accent; copyBtn.Text = "Salin ID"; copyBtn.TextColor3 = T.OnAccent
            copyBtn.Font = Enum.Font.GothamBold; copyBtn.TextSize = 11; copyBtn.AutoButtonColor = false
            copyBtn.MouseButton1Click:Connect(function()
                shared.copyToClipboard(table.concat(p.ids, " "))
                shared.pulseIsland("Disalin "..#p.ids.." ID")
            end)
        end
    end
    if not anyPreset then
        local none2 = Instance.new("TextLabel", appFrame)
        none2.Size = UDim2.new(1,0,0,30); none2.BackgroundTransparency = 1; none2.LayoutOrder = 999
        none2.Text = "Belum ada preset favorit."; none2.TextColor3 = T.Text2; none2.Font = Enum.Font.Gotham; none2.TextSize = 11
    end
end