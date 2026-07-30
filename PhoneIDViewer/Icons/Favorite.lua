return {
    Color = Color3.fromRGB(255, 204, 0),
    Builder = function(parent, color)
        local c = color or Color3.new(1,1,1)
        local star = Instance.new("TextLabel", parent)
        star.Size = UDim2.new(1,0,1,0); star.BackgroundTransparency = 1
        star.Text = "★"; star.TextColor3 = c; star.Font = Enum.Font.GothamBlack
        star.TextSize = 32; star.TextYAlignment = Enum.TextYAlignment.Center
    end
}