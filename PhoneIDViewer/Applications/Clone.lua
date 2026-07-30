return function(appFrame, shared)
    local T = shared.T
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer
    
    local function clonePlayer(player)
        local items = shared.getItems(player)
        if #items == 0 then shared.pulseIsland("Tidak ada item", true); return end
        local ids = {}
        for _,it in ipairs(items) do table.insert(ids, it.Value) end
        
        shared.pulseIsland("Cloning "..player.DisplayName.."...")
        local chunks = {}
        for i=1,#ids,5 do local c={}; for j=i,math.min(i+4,#ids) do table.insert(c, ids[j]) end; table.insert(chunks, c) end
        
        local current = 0
        local function sendNext()
            current = current + 1
            if current > #chunks then shared.pulseIsland("Clone selesai!"); return end
            ReplicatedStorage.Remotes.Command.CommandEvent:FireServer("hat", {"hat", unpack(chunks[current])})
            shared.pulseIsland("Cloning "..current.."/"..#chunks)
            task.delay(10, sendNext)
        end
        sendNext()
    end
    
    local listHolder = Instance.new("Frame", appFrame)
    listHolder.Size = UDim2.new(1,0,0,0); listHolder.AutomaticSize = Enum.AutomaticSize.Y
    listHolder.BackgroundTransparency = 1; listHolder.LayoutOrder = 0
    Instance.new("UIListLayout", listHolder).Padding = UDim.new(0,8)
    
    for i,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local row = shared.stroke(shared.corner(Instance.new("Frame", listHolder), 10), T.Border, 1, 0.3)
            row.Size = UDim2.new(1,0,0,60); row.BackgroundColor3 = T.Card2; row.LayoutOrder = i
            
            local av = shared.corner(Instance.new("ImageLabel", row), 100)
            av.Size = UDim2.new(0,44,0,44); av.Position = UDim2.new(0,8,0.5,-22)
            av.BackgroundColor3 = T.BG
            av.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..p.UserId.."&width=100&height=100&format=png"
            
            local nameLbl = Instance.new("TextLabel", row)
            nameLbl.Size = UDim2.new(1,-120,0,24); nameLbl.Position = UDim2.new(0,60,0,18)
            nameLbl.BackgroundTransparency = 1; nameLbl.Text = p.DisplayName
            nameLbl.TextColor3 = T.Text; nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextSize = 13
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            
            local cloneBtn = shared.pressFX(shared.corner(Instance.new("TextButton", row), 8))
            cloneBtn.Size = UDim2.new(0,70,0,32); cloneBtn.Position = UDim2.new(1,-76,0.5,-16)
            cloneBtn.BackgroundColor3 = T.Accent; cloneBtn.Text = "Clone"; cloneBtn.TextColor3 = T.OnAccent
            cloneBtn.Font = Enum.Font.GothamBlack; cloneBtn.TextSize = 12; cloneBtn.AutoButtonColor = false
            cloneBtn.MouseButton1Click:Connect(function() clonePlayer(p) end)
        end
    end
end