return function(appFrame, shared)
    local T = shared.T
    
    local saveBtn = shared.pressFX(shared.corner(Instance.new("TextButton", appFrame), 10))
    saveBtn.Size = UDim2.new(1,0,0,40); saveBtn.BackgroundColor3 = T.Accent; saveBtn.LayoutOrder = 0
    saveBtn.Text = "Simpan Item Pemain Terpilih sebagai Preset"; saveBtn.TextColor3 = T.OnAccent
    saveBtn.Font = Enum.Font.GothamBlack; saveBtn.TextSize = 12; saveBtn.AutoButtonColor = false
    saveBtn.MouseButton1Click:Connect(function()
        if not shared.selectedTargetPlayer then shared.pulseIsland("Pilih pemain dulu", true); return end
        local items = shared.getItems(shared.selectedTargetPlayer)
        if #items == 0 then shared.pulseIsland("Tidak ada item", true); return end
        local ids = {}
        for _,it in ipairs(items) do table.insert(ids, it.Value) end
        table.insert(shared.presets, {
            name = shared.selectedTargetPlayer.DisplayName.." - "..os.date("%d%m %H%M"),
            ids = ids,
            date = os.date("%d/%m/%Y %H:%M"),
            favorite = false,
        })
        shared.saveJSON("PhoneIDViewer_Presets.json", shared.presets)
        shared.pulseIsland("Preset tersimpan ("..#ids.." item)")
        shared.refreshCurrentApp()
    end)
    
    if #shared.presets == 0 then
        local none = Instance.new("TextLabel", appFrame)
        none.Size = UDim2.new(1,0,0,60); none.BackgroundTransparency = 1; none.LayoutOrder = 1
        none.Text = "Belum ada preset."; none.TextColor3 = T.Text2; none.Font = Enum.Font.Gotham; none.TextSize = 12
        return
    end
    
    local sorted = {}
    for _,p in ipairs(shared.presets) do table.insert(sorted, p) end
    table.sort(sorted, function(a,b) local af=a.favorite and 1 or 0; local bf=b.favorite and 1 or 0; if af~=bf then return af>bf end; return false end)
    
    for i,p in ipairs(sorted) do
        local row = shared.stroke(shared.corner(Instance.new("Frame", appFrame), 10), p.favorite and T.Gold or T.Border, 1, p.favorite and 0.2 or 0.3)
        row.Size = UDim2.new(1,0,0,96); row.BackgroundColor3 = T.Card2; row.LayoutOrder = i+1
        
        local nameLbl = Instance.new("TextLabel", row)
        nameLbl.Size = UDim2.new(1,-50,0,20); nameLbl.Position = UDim2.new(0,10,0,8)
        nameLbl.BackgroundTransparency = 1; nameLbl.Text = p.name; nameLbl.TextColor3 = T.Text
        nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextSize = 13; nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
        
        local infoLbl = Instance.new("TextLabel", row)
        infoLbl.Size = UDim2.new(1,-50,0,16); infoLbl.Position = UDim2.new(0,10,0,28)
        infoLbl.BackgroundTransparency = 1; infoLbl.Text = #p.ids.." item - "..(p.date or "")
        infoLbl.TextColor3 = T.Text2; infoLbl.Font = Enum.Font.Gotham; infoLbl.TextSize = 10
        infoLbl.TextXAlignment = Enum.TextXAlignment.Left
        
        local favBtn = shared.pressFX(shared.stroke(shared.corner(Instance.new("TextButton", row), 7), T.Border, 1, 0.3))
        favBtn.Size = UDim2.new(0,34,0,28); favBtn.Position = UDim2.new(1,-38,0,6)
        favBtn.BackgroundColor3 = p.favorite and T.Gold or T.Card; favBtn.Text = "Fav"
        favBtn.TextColor3 = p.favorite and T.OnAccent or T.Text2; favBtn.Font = Enum.Font.GothamBold
        favBtn.TextSize = 10; favBtn.AutoButtonColor = false
        favBtn.MouseButton1Click:Connect(function()
            p.favorite = not p.favorite
            shared.saveJSON("PhoneIDViewer_Presets.json", shared.presets)
            shared.refreshCurrentApp()
        end)
        
        local copyAllBtn = shared.pressFX(shared.corner(Instance.new("TextButton", row), 8))
        copyAllBtn.Size = UDim2.new(0.47,-14,0,30); copyAllBtn.Position = UDim2.new(0,10,1,-38)
        copyAllBtn.BackgroundColor3 = T.Accent; copyAllBtn.Text = "Salin Semua ID"; copyAllBtn.TextColor3 = T.OnAccent
        copyAllBtn.Font = Enum.Font.GothamBold; copyAllBtn.TextSize = 11; copyAllBtn.AutoButtonColor = false
        copyAllBtn.MouseButton1Click:Connect(function()
            shared.copyToClipboard(table.concat(p.ids, " "))
            shared.pulseIsland("Disalin "..#p.ids.." ID")
        end)
        
        local delBtn = shared.pressFX(shared.corner(Instance.new("TextButton", row), 8))
        delBtn.Size = UDim2.new(0.47,-14,0,30); delBtn.Position = UDim2.new(0.53,4,1,-38)
        delBtn.BackgroundColor3 = Color3.fromRGB(50,30,35); delBtn.Text = "Hapus"; delBtn.TextColor3 = T.Red
        delBtn.Font = Enum.Font.GothamBold; delBtn.TextSize = 11; delBtn.AutoButtonColor = false
        delBtn.MouseButton1Click:Connect(function()
            local idx = table.find(shared.presets, p)
            if idx then table.remove(shared.presets, idx) end
            shared.saveJSON("PhoneIDViewer_Presets.json", shared.presets)
            shared.pulseIsland("Preset dihapus", true)
            shared.refreshCurrentApp()
        end)
    end
end