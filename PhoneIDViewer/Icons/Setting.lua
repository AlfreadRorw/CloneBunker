return {
    Color = Color3.fromRGB(142, 142, 147),
    Builder = function(parent, color)
        local c = color or Color3.new(1,1,1)
        local outer = Instance.new("Frame", parent)
        outer.Size = UDim2.new(0,36,0,36); outer.Position = UDim2.new(0.5,-18,0.5,-18)
        outer.BackgroundTransparency = 1
        Instance.new("UIStroke", outer).Color = c; Instance.new("UICorner", outer).CornerRadius = UDim.new(1,0)
        local inner = Instance.new("Frame", outer)
        inner.Size = UDim2.new(0,14,0,14); inner.Position = UDim2.new(0.5,-7,0.5,-7)
        inner.BackgroundColor3 = c; Instance.new("UICorner", inner).CornerRadius = UDim.new(1,0)
    end
}