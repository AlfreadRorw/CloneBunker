return {
    Players = {
        Color = Color3.fromRGB(0, 122, 255),
        Builder = function(parent, color)
            local c = color or Color3.new(1,1,1)
            local h = Instance.new("Frame", parent); h.Size = UDim2.new(0,22,0,22); h.Position = UDim2.new(0.5,-11,0.18,0)
            h.BackgroundColor3 = c; Instance.new("UICorner", h).CornerRadius = UDim.new(1,0)
            local b = Instance.new("Frame", parent); b.Size = UDim2.new(0,38,0,24); b.Position = UDim2.new(0.5,-19,0.55,0)
            b.BackgroundColor3 = c; Instance.new("UICorner", b).CornerRadius = UDim.new(0,12)
        end
    },
    Clone = {
        Color = Color3.fromRGB(52, 199, 89),
        Builder = function(parent, color)
            local c = color or Color3.new(1,1,1)
            for _,x in ipairs({-8,8}) do
                local h = Instance.new("Frame", parent); h.Size = UDim2.new(0,16,0,16); h.Position = UDim2.new(0.5,-8+x,0.2,0)
                h.BackgroundColor3 = c; Instance.new("UICorner", h).CornerRadius = UDim.new(1,0)
                local b = Instance.new("Frame", parent); b.Size = UDim2.new(0,28,0,20); b.Position = UDim2.new(0.5,-14+x,0.5,0)
                b.BackgroundColor3 = c; Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
            end
        end
    },
    Body = {
        Color = Color3.fromRGB(255, 149, 0),
        Builder = function(parent, color)
            local c = color or Color3.new(1,1,1)
            local s = Instance.new("Frame", parent); s.Size = UDim2.new(0,36,0,40); s.Position = UDim2.new(0.5,-18,0.5,-20)
            s.BackgroundColor3 = c; Instance.new("UICorner", s).CornerRadius = UDim.new(0,8)
            local n = Instance.new("Frame", parent); n.Size = UDim2.new(0,16,0,8); n.Position = UDim2.new(0.5,-8,0.15,0)
            n.BackgroundColor3 = c; Instance.new("UICorner", n).CornerRadius = UDim.new(0,4)
        end
    },
    Accessories = {
        Color = Color3.fromRGB(175, 82, 222),
        Builder = function(parent, color)
            local c = color or Color3.new(1,1,1)
            local br = Instance.new("Frame", parent); br.Size = UDim2.new(0,38,0,8); br.Position = UDim2.new(0.5,-19,0.6,0)
            br.BackgroundColor3 = c; Instance.new("UICorner", br).CornerRadius = UDim.new(0,4)
            local tp = Instance.new("Frame", parent); tp.Size = UDim2.new(0,28,0,20); tp.Position = UDim2.new(0.5,-14,0.28,0)
            tp.BackgroundColor3 = c; Instance.new("UICorner", tp).CornerRadius = UDim.new(1,0)
        end
    },
    Preset = {
        Color = Color3.fromRGB(0, 122, 255),
        Builder = function(parent, color)
            local c = color or Color3.new(1,1,1)
            local bx = Instance.new("Frame", parent); bx.Size = UDim2.new(0,30,0,34); bx.Position = UDim2.new(0.5,-15,0.5,-17)
            bx.BackgroundTransparency = 1; Instance.new("UIStroke", bx).Color = c; Instance.new("UICorner", bx).CornerRadius = UDim.new(0,4)
            local ar = Instance.new("Frame", bx); ar.Size = UDim2.new(0,14,0,4); ar.Position = UDim2.new(0.5,-7,0.5,-2)
            ar.BackgroundColor3 = c; Instance.new("UICorner", ar).CornerRadius = UDim.new(0,2)
            local st = Instance.new("Frame", bx); st.Size = UDim2.new(0,4,0,14); st.Position = UDim2.new(0.5,-2,0.5,-1)
            st.BackgroundColor3 = c
        end
    },
    Favorite = {
        Color = Color3.fromRGB(255, 204, 0),
        Builder = function(parent, color)
            local c = color or Color3.new(1,1,1)
            local s = Instance.new("TextLabel", parent); s.Size = UDim2.new(1,0,1,0); s.BackgroundTransparency = 1
            s.Text = "★"; s.TextColor3 = c; s.Font = Enum.Font.GothamBlack; s.TextSize = 32
        end
    },
    Setting = {
        Color = Color3.fromRGB(142, 142, 147),
        Builder = function(parent, color)
            local c = color or Color3.new(1,1,1)
            local o = Instance.new("Frame", parent); o.Size = UDim2.new(0,36,0,36); o.Position = UDim2.new(0.5,-18,0.5,-18)
            o.BackgroundTransparency = 1; Instance.new("UIStroke", o).Color = c; Instance.new("UICorner", o).CornerRadius = UDim.new(1,0)
            local i = Instance.new("Frame", o); i.Size = UDim2.new(0,14,0,14); i.Position = UDim2.new(0.5,-7,0.5,-7)
            i.BackgroundColor3 = c; Instance.new("UICorner", i).CornerRadius = UDim.new(1,0)
        end
    },
}