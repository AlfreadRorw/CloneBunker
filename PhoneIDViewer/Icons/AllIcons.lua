-- All Icons Builder
-- Returns table of icon builders

local function createPlayersIcon(parent, color)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 64, 0, 78)
	frame.BackgroundTransparency = 1
	frame.Parent = parent
	
	local iconBg = Instance.new("Frame")
	iconBg.Size = UDim2.new(0, 48, 0, 48)
	iconBg.Position = UDim2.new(0.5, -24, 0, 0)
	iconBg.BackgroundColor3 = color
	iconBg.BorderSizePixel = 0
	Instance.new("UICorner", iconBg).CornerRadius = UDim.new(0, 12)
	iconBg.Parent = frame
	
	-- Head (circle)
	local head = Instance.new("Frame")
	head.Size = UDim2.new(0, 18, 0, 18)
	head.Position = UDim2.new(0.5, -9, 0, 5)
	head.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	head.BorderSizePixel = 0
	Instance.new("UICorner", head).CornerRadius = UDim.new(1, 0)
	head.Parent = iconBg
	
	-- Body
	local body = Instance.new("Frame")
	body.Size = UDim2.new(0, 28, 0, 18)
	body.Position = UDim2.new(0.5, -14, 0, 26)
	body.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	body.BorderSizePixel = 0
	Instance.new("UICorner", body).CornerRadius = UDim.new(0, 4)
	body.Parent = iconBg
	
	return frame
end

local function createCloneIcon(parent, color)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 64, 0, 78)
	frame.BackgroundTransparency = 1
	frame.Parent = parent
	
	local iconBg = Instance.new("Frame")
	iconBg.Size = UDim2.new(0, 48, 0, 48)
	iconBg.Position = UDim2.new(0.5, -24, 0, 0)
	iconBg.BackgroundColor3 = color
	iconBg.BorderSizePixel = 0
	Instance.new("UICorner", iconBg).CornerRadius = UDim.new(0, 12)
	iconBg.Parent = frame
	
	-- Person 1 (left)
	local head1 = Instance.new("Frame")
	head1.Size = UDim2.new(0, 12, 0, 12)
	head1.Position = UDim2.new(0.25, -6, 0, 6)
	head1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	head1.BorderSizePixel = 0
	Instance.new("UICorner", head1).CornerRadius = UDim.new(1, 0)
	head1.Parent = iconBg
	
	local body1 = Instance.new("Frame")
	body1.Size = UDim2.new(0, 18, 0, 14)
	body1.Position = UDim2.new(0.25, -9, 0, 20)
	body1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	body1.BorderSizePixel = 0
	Instance.new("UICorner", body1).CornerRadius = UDim.new(0, 3)
	body1.Parent = iconBg
	
	-- Person 2 (right)
	local head2 = Instance.new("Frame")
	head2.Size = UDim2.new(0, 12, 0, 12)
	head2.Position = UDim2.new(0.75, -6, 0, 6)
	head2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	head2.BorderSizePixel = 0
	Instance.new("UICorner", head2).CornerRadius = UDim.new(1, 0)
	head2.Parent = iconBg
	
	local body2 = Instance.new("Frame")
	body2.Size = UDim2.new(0, 18, 0, 14)
	body2.Position = UDim2.new(0.75, -9, 0, 20)
	body2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	body2.BorderSizePixel = 0
	Instance.new("UICorner", body2).CornerRadius = UDim.new(0, 3)
	body2.Parent = iconBg
	
	return frame
end

local function createBodyIcon(parent, color)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 64, 0, 78)
	frame.BackgroundTransparency = 1
	frame.Parent = parent
	
	local iconBg = Instance.new("Frame")
	iconBg.Size = UDim2.new(0, 48, 0, 48)
	iconBg.Position = UDim2.new(0.5, -24, 0, 0)
	iconBg.BackgroundColor3 = color
	iconBg.BorderSizePixel = 0
	Instance.new("UICorner", iconBg).CornerRadius = UDim.new(0, 12)
	iconBg.Parent = frame
	
	-- Torso/shirt shape
	local torso = Instance.new("Frame")
	torso.Size = UDim2.new(0, 26, 0, 30)
	torso.Position = UDim2.new(0.5, -13, 0, 9)
	torso.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	torso.BorderSizePixel = 0
	Instance.new("UICorner", torso).CornerRadius = UDim.new(0, 5)
	torso.Parent = iconBg
	
	-- Collar
	local collar = Instance.new("Frame")
	collar.Size = UDim2.new(0, 14, 0, 6)
	collar.Position = UDim2.new(0.5, -7, 0, 8)
	collar.BackgroundColor3 = color
	collar.BorderSizePixel = 0
	Instance.new("UICorner", collar).CornerRadius = UDim.new(0, 3)
	collar.Parent = iconBg
	
	return frame
end

local function createAccessoriesIcon(parent, color)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 64, 0, 78)
	frame.BackgroundTransparency = 1
	frame.Parent = parent
	
	local iconBg = Instance.new("Frame")
	iconBg.Size = UDim2.new(0, 48, 0, 48)
	iconBg.Position = UDim2.new(0.5, -24, 0, 0)
	iconBg.BackgroundColor3 = color
	iconBg.BorderSizePixel = 0
	Instance.new("UICorner", iconBg).CornerRadius = UDim.new(0, 12)
	iconBg.Parent = frame
	
	-- Hat base
	local hatBase = Instance.new("Frame")
	hatBase.Size = UDim2.new(0, 30, 0, 8)
	hatBase.Position = UDim2.new(0.5, -15, 0, 12)
	hatBase.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	hatBase.BorderSizePixel = 0
	Instance.new("UICorner", hatBase).CornerRadius = UDim.new(0, 4)
	hatBase.Parent = iconBg
	
	-- Hat top
	local hatTop = Instance.new("Frame")
	hatTop.Size = UDim2.new(0, 20, 0, 16)
	hatTop.Position = UDim2.new(0.5, -10, 0, 4)
	hatTop.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	hatTop.BorderSizePixel = 0
	Instance.new("UICorner", hatTop).CornerRadius = UDim.new(0, 4)
	hatTop.Parent = iconBg
	
	return frame
end

local function createPresetIcon(parent, color)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 64, 0, 78)
	frame.BackgroundTransparency = 1
	frame.Parent = parent
	
	local iconBg = Instance.new("Frame")
	iconBg.Size = UDim2.new(0, 48, 0, 48)
	iconBg.Position = UDim2.new(0.5, -24, 0, 0)
	iconBg.BackgroundColor3 = color
	iconBg.BorderSizePixel = 0
	Instance.new("UICorner", iconBg).CornerRadius = UDim.new(0, 12)
	iconBg.Parent = frame
	
	-- Box
	local box = Instance.new("Frame")
	box.Size = UDim2.new(0, 26, 0, 24)
	box.Position = UDim2.new(0.5, -13, 0, 12)
	box.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	box.BorderSizePixel = 0
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 3)
	box.Parent = iconBg
	
	-- Arrow
	local arrow = Instance.new("Frame")
	arrow.Size = UDim2.new(0, 10, 0, 10)
	arrow.Position = UDim2.new(0.5, -5, 0, 18)
	arrow.BackgroundColor3 = color
	arrow.BorderSizePixel = 0
	arrow.Rotation = 45
	arrow.Parent = iconBg
	
	return frame
end

local function createFavoriteIcon(parent, color)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 64, 0, 78)
	frame.BackgroundTransparency = 1
	frame.Parent = parent
	
	local iconBg = Instance.new("Frame")
	iconBg.Size = UDim2.new(0, 48, 0, 48)
	iconBg.Position = UDim2.new(0.5, -24, 0, 0)
	iconBg.BackgroundColor3 = color
	iconBg.BorderSizePixel = 0
	Instance.new("UICorner", iconBg).CornerRadius = UDim.new(0, 12)
	iconBg.Parent = frame
	
	local star = Instance.new("TextLabel")
	star.Size = UDim2.new(0, 32, 0, 32)
	star.Position = UDim2.new(0.5, -16, 0.5, -16)
	star.BackgroundTransparency = 1
	star.Text = "★"
	star.TextColor3 = Color3.fromRGB(255, 200, 50)
	star.TextSize = 30
	star.Font = Enum.Font.GothamBold
	star.Parent = iconBg
	
	return frame
end

local function createSettingIcon(parent, color)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 64, 0, 78)
	frame.BackgroundTransparency = 1
	frame.Parent = parent
	
	local iconBg = Instance.new("Frame")
	iconBg.Size = UDim2.new(0, 48, 0, 48)
	iconBg.Position = UDim2.new(0.5, -24, 0, 0)
	iconBg.BackgroundColor3 = color
	iconBg.BorderSizePixel = 0
	Instance.new("UICorner", iconBg).CornerRadius = UDim.new(0, 12)
	iconBg.Parent = frame
	
	-- Outer gear ring
	local outerRing = Instance.new("Frame")
	outerRing.Size = UDim2.new(0, 28, 0, 28)
	outerRing.Position = UDim2.new(0.5, -14, 0.5, -14)
	outerRing.BackgroundTransparency = 1
	outerRing.BorderSizePixel = 0
	outerRing.Parent = iconBg
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = 3
	stroke.Parent = outerRing
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = outerRing
	
	-- Inner dot
	local innerDot = Instance.new("Frame")
	innerDot.Size = UDim2.new(0, 8, 0, 8)
	innerDot.Position = UDim2.new(0.5, -4, 0.5, -4)
	innerDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	innerDot.BorderSizePixel = 0
	Instance.new("UICorner", innerDot).CornerRadius = UDim.new(1, 0)
	innerDot.Parent = iconBg
	
	return frame
end

-- Return icon builders
return {
	Players = {Color = Color3.fromRGB(0, 150, 255), Builder = createPlayersIcon},
	Clone = {Color = Color3.fromRGB(100, 180, 100), Builder = createCloneIcon},
	Body = {Color = Color3.fromRGB(255, 150, 50), Builder = createBodyIcon},
	Accessories = {Color = Color3.fromRGB(200, 100, 200), Builder = createAccessoriesIcon},
	Preset = {Color = Color3.fromRGB(0, 200, 200), Builder = createPresetIcon},
	Favorite = {Color = Color3.fromRGB(255, 200, 50), Builder = createFavoriteIcon},
	Setting = {Color = Color3.fromRGB(150, 150, 150), Builder = createSettingIcon}
}