return {
    Color = Color3.fromRGB(0, 122, 255),
    Builder = function(parent, color)
        local c = color or Color3.new(1,1,1)
        local head = Instance.new("Frame", parent)
        head.Size = UDim2.new(0,22,0,22); head.Position = UDim2.new(0.5,-11,0.18,0)
        head.BackgroundColor3 = c; Instance.new("UICorner", head).CornerRadius = UDim.new(1,0)
        local body = Instance.new("Frame", parent)
        body.Size = UDim2.new(0,38,0,24); body.Position = UDim2.new(0.5,-19,0.55,0)
        body.BackgroundColor3 = c; Instance.new("UICorner", body).CornerRadius = UDim.new(0,12)
    end
}