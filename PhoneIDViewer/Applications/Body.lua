return function(appFrame, shared)
    local T = shared.T
    
    if not shared.selectedTargetPlayer then
        local hint = Instance.new("TextLabel", appFrame)
        hint.Size = UDim2.new(1,0,0,60); hint.BackgroundTransparency = 1
        hint.Text = "Pilih pemain dulu di aplikasi Players."; hint.TextColor3 = T.Text2
        hint.Font = Enum.Font.Gotham; hint.TextSize = 12; hint.TextWrapped = true
        return
    end
    
    local items = shared.getItems(shared.selectedTargetPlayer)
    local shown = 0
    for _,it in ipairs(items) do
        if it.Type == "BODY" then
            shown = shown + 1
            local row = shared.stroke(shared.corner(Instance.new("Frame", appFrame), 10), T.Border, 1, 0.3)
            row.Size = UDim2.new(1,0,0,60); row.BackgroundColor3 = T.Card2; row.LayoutOrder = shown
            
            local thumb = shared.stroke(shared.corner(Instance.new("ImageLabel", row), 8), T.Border, 1, 0.3)
            thumb.Size = UDim2.new(0,48,0,48); thumb.Position = UDim2.new(0,6,0.5,-24)
            thumb.BackgroundColor3 = T.BG
            thumb.Image = "https://www.roblox.com/asset-thumbnail/image?assetId="..it.Value.."&width=100&height=100&format=png"
            thumb.ScaleType = Enum.ScaleType.Fit
            
            local nameLbl = Instance.new("TextLabel", row)
            nameLbl.Size = UDim2.new(1,-140,0,20); nameLbl.Position = UDim2.new(0,60,0,8)
            nameLbl.BackgroundTransparency = 1; nameLbl.Text = it.Label; nameLbl.TextColor3 = T.Text
            nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextSize = 13; nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            
            local idLbl = Instance.new("TextLabel", row)
            idLbl.Size = UDim2.new(1,-140,0,18); idLbl.Position = UDim2.new(0,60,0,30)
            idLbl.BackgroundTransparency = 1; idLbl.Text = it.Value; idLbl.TextColor3 = T.Green
            idLbl.Font = Enum.Font.Code; idLbl.TextSize = 11; idLbl.TextXAlignment = Enum.TextXAlignment.Left
            
            local copyBtn = shared.pressFX(shared.corner(Instance.new("TextButton", row), 8))
            copyBtn.Size = UDim2.new(0,64,0,32); copyBtn.Position = UDim2.new(1,-70,0.5,-16)
            copyBtn.BackgroundColor3 = T.Accent; copyBtn.Text = "Salin"; copyBtn.TextColor3 = T.OnAccent
            copyBtn.Font = Enum.Font.GothamBold; copyBtn.TextSize = 11; copyBtn.AutoButtonColor = false
            copyBtn.MouseButton1Click:Connect(function()
                shared.copyToClipboard(it.Value); shared.pulseIsland("Disalin: "..it.Value)
            end)
        end
    end
    if shown == 0 then
        local none = Instance.new("TextLabel", appFrame)
        none.Size = UDim2.new(1,0,0,40); none.BackgroundTransparency = 1
        none.Text = "Tidak ada item body."; none.TextColor3 = T.Text2
        none.Font = Enum.Font.Gotham; none.TextSize = 12
    end
end