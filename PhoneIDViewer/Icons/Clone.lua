return {
    Color = Color3.fromRGB(52, 199, 89),
    Builder = function(parent, color)
        local c = color or Color3.new(1,1,1)
        for _,x in ipairs({-8, 8}) do
            local head = Instance.new("Frame", parent)
            head.Size = UDim2.new(0,16,0,16); head.Position = UDim2.new(0.5,-8+x,0.2,0)
            head.BackgroundColor3 = c; Instance.new("UICorner", head).CornerRadius = UDim.new(1,0)
            local body = Instance.new("Frame", parent)
            body.Size = UDim2.new(0,28,0,20); body.Position = UDim2.new(0.5,-14+x,0.5,0)
            body.BackgroundColor3 = c; Instance.new("UICorner", body).CornerRadius = UDim.new(0,10)
        end
    end
}