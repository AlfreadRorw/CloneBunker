return {
    Color = Color3.fromRGB(0, 122, 255),
    Builder = function(parent, color)
        local c = color or Color3.new(1,1,1)
        local box = Instance.new("Frame", parent)
        box.Size = UDim2.new(0,30,0,34); box.Position = UDim2.new(0.5,-15,0.5,-17)
        box.BackgroundTransparency = 1
        Instance.new("UIStroke", box).Color = c; Instance.new("UICorner", box).CornerRadius = UDim.new(0,4)
        local arrow = Instance.new("Frame", box)
        arrow.Size = UDim2.new(0,14,0,4); arrow.Position = UDim2.new(0.5,-7,0.5,-2)
        arrow.BackgroundColor3 = c; Instance.new("UICorner", arrow).CornerRadius = UDim.new(0,2)
        local stick = Instance.new("Frame", box)
        stick.Size = UDim2.new(0,4,0,14); stick.Position = UDim2.new(0.5,-2,0.5,-1)
        stick.BackgroundColor3 = c
    end
}