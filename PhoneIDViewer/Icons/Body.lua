return {
    Color = Color3.fromRGB(255, 149, 0),
    Builder = function(parent, color)
        local c = color or Color3.new(1,1,1)
        local shirt = Instance.new("Frame", parent)
        shirt.Size = UDim2.new(0,36,0,40); shirt.Position = UDim2.new(0.5,-18,0.5,-20)
        shirt.BackgroundColor3 = c; Instance.new("UICorner", shirt).CornerRadius = UDim.new(0,8)
        local neck = Instance.new("Frame", parent)
        neck.Size = UDim2.new(0,16,0,8); neck.Position = UDim2.new(0.5,-8,0.15,0)
        neck.BackgroundColor3 = c; Instance.new("UICorner", neck).CornerRadius = UDim.new(0,4)
    end
}