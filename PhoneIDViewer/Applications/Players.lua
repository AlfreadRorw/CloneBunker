return function(appFrame, shared)
    local T = shared.T
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local searchBox = shared.stroke(shared.corner(Instance.new("Frame", appFrame), 9), T.Border, 1, 0.3)
    searchBox.Size = UDim2.new(1,0,0,36); searchBox.BackgroundColor3 = T.Card2; searchBox.LayoutOrder = 0
    
    local searchInput = Instance.new("TextBox", searchBox)
    searchInput.Size = UDim2.new(1,-16,1,0); searchInput.Position = UDim2.new(0,8,0,0)
    searchInput.BackgroundTransparency = 1; searchInput.PlaceholderText = "Cari pemain..."
    searchInput.Text = ""; searchInput.TextColor3 = T.Text
    searchInput.Font = Enum.Font.Gotham; searchInput.TextSize = 13; searchInput.ClearTextOnFocus = false
    
    local listHolder = Instance.new("Frame", appFrame)
    listHolder.Size = UDim2.new(1,0,0,0); listHolder.AutomaticSize = Enum.AutomaticSize.Y
    listHolder.BackgroundTransparency = 1; listHolder.LayoutOrder = 1
    Instance.new("UIListLayout", listHolder).Padding = UDim.new(0,8)
    
    local function renderList(filter)
        for _,c in ipairs(listHolder:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
        filter = (filter or ""):lower()
        
        local list = Players:GetPlayers()
        table.sort(list, function(a,b)
            if a == LocalPlayer then return true end
            if b == LocalPlayer then return false end
            local af = shared.favPlayerSet[tostring(a.UserId)] and 1 or 0
            local bf = shared.favPlayerSet[tostring(b.UserId)] and 1 or 0
            if af ~= bf then return af > bf end
            return a.DisplayName < b.DisplayName
        end)
        
        for i,p in ipairs(list) do
            if filter == "" or p.Name:lower():find(filter,1,true) or p.DisplayName:lower():find(filter,1,true) then
                local isMe = p == LocalPlayer
                local isFav = shared.favPlayerSet[tostring(p.UserId)] == true
                local isSel = shared.selectedTargetPlayer == p
                
                local row = shared.stroke(shared.corner(Instance.new("Frame", listHolder), 10), isSel and T.Accent or T.Border, isSel and 2 or 1, isSel and 0 or 0.3)
                row.Size = UDim2.new(1,0,0,60); row.BackgroundColor3 = isSel and Color3.fromRGB(38,38,38) or T.Card2; row.LayoutOrder = i
                
                local av = shared.corner(Instance.new("ImageLabel", row), 100)
                av.Size = UDim2.new(0,44,0,44); av.Position = UDim2.new(0,8,0.5,-22)
                av.BackgroundColor3 = T.BG
                av.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..p.UserId.."&width=100&height=100&format=png"
                
                local nameLbl = Instance.new("TextLabel", row)
                nameLbl.Size = UDim2.new(1,-170,0,20); nameLbl.Position = UDim2.new(0,60,0,10)
                nameLbl.BackgroundTransparency = 1; nameLbl.Text = (isMe and "(Kamu) " or "") .. p.DisplayName
                nameLbl.TextColor3 = isMe and T.Accent or T.Text; nameLbl.Font = Enum.Font.GothamBold
                nameLbl.TextSize = 13; nameLbl.TextXAlignment = Enum.TextXAlignment.Left; nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
                
                local userLbl = Instance.new("TextLabel", row)
                userLbl.Size = UDim2.new(1,-170,0,16); userLbl.Position = UDim2.new(0,60,0,32)
                userLbl.BackgroundTransparency = 1; userLbl.Text = "@"..p.Name; userLbl.TextColor3 = T.Text2
                userLbl.Font = Enum.Font.Gotham; userLbl.TextSize = 10; userLbl.TextXAlignment = Enum.TextXAlignment.Left
                
                if not isMe then
                    local starBtn = shared.pressFX(shared.stroke(shared.corner(Instance.new("TextButton", row), 7), T.Border, 1, 0.3))
                    starBtn.Size = UDim2.new(0,34,0,30); starBtn.Position = UDim2.new(1,-108,0.5,-15)
                    starBtn.BackgroundColor3 = isFav and T.Gold or T.Card; starBtn.Text = "Fav"
                    starBtn.TextColor3 = isFav and T.OnAccent or T.Text2; starBtn.Font = Enum.Font.GothamBold
                    starBtn.TextSize = 10; starBtn.AutoButtonColor = false
                    starBtn.MouseButton1Click:Connect(function()
                        local key = tostring(p.UserId)
                        if shared.favPlayerSet[key] then shared.favPlayerSet[key] = nil; shared.pulseIsland("Dihapus dari favorit")
                        else shared.favPlayerSet[key] = true; shared.pulseIsland("Ditambah ke favorit") end
                        shared.persistFav(); renderList(searchInput.Text)
                    end)
                end
                
                local selBtn = shared.pressFX(shared.corner(Instance.new("TextButton", row), 7))
                selBtn.Size = UDim2.new(0,66,0,30); selBtn.Position = UDim2.new(1,-72,0.5,-15)
                selBtn.BackgroundColor3 = T.Accent; selBtn.Text = isSel and "Dipilih" or "Pilih"
                selBtn.TextColor3 = T.OnAccent; selBtn.Font = Enum.Font.GothamBold; selBtn.TextSize = 10; selBtn.AutoButtonColor = false
                selBtn.MouseButton1Click:Connect(function()
                    shared.selectedTargetPlayer = p; shared.pulseIsland("Target: "..p.DisplayName); renderList(searchInput.Text)
                end)
            end
        end
    end
    
    renderList("")
    searchInput:GetPropertyChangedSignal("Text"):Connect(function() renderList(searchInput.Text) end)
end