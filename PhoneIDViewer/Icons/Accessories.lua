return {
    Color = Color3.fromRGB(175, 82, 222),
    Builder = function(parent, color)
        local c = color or Color3.new(1,1,1)
        local brim = Instance.new("Frame", parent)
        brim.Size = UDim2.new(0,38,0,8); brim.Position = UDim2.new(0.5,-19,0.6,0)
        brim.BackgroundColor3 = c; Instance.new("UICorner", brim).CornerRadius = UDim.new(0,4)
        local top = Instance.new("Frame", parent)
        top.Size = UDim2.new(0,28,0,20); top.Position = UDim2.new(0.5,-14,0.28,0)
        top.BackgroundColor3 = c; Instance.new("UICorner", top).CornerRadius = UDim.new(1,0)
    end
}