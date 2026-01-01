local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Dummy variables to prevent errors
local flyEnabled, flyBV, flyBG = false, nil, nil
local swimEnabled, swimBV, swimBG = false, nil, nil
local trail, rainbowTrailEnabled = nil, false
local spinEnabled, bigHeadEnabled, confettiEnabled = false, false, false
local tracersEnabled = false

-- GUI
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")
gui.Name = "ClientMenu"

-- Main frame
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.25,0.55)
frame.Position = UDim2.fromScale(0.05,0.25)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Instance.new("UICorner", frame)

-- Top bar (drag)
local topBar = Instance.new("Frame", frame)
topBar.Size = UDim2.fromScale(1,0.12)
topBar.BackgroundColor3 = Color3.fromRGB(45,45,45)
Instance.new("UICorner", topBar)
local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.fromScale(1,1)
title.BackgroundTransparency = 1
title.Text = "CLIENT MENU"
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold

-- Drag logic
local dragging, dragStart, startPos = false
local function updateDrag(input)
	local delta = input.Position - dragStart
	frame.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end
topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)
topBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		updateDrag(input)
	end
end)

-- Button creator
local function makeButton(text,posY,parent)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.fromScale(0.9,0.08)
	b.Position = UDim2.fromScale(0.05,posY)
	b.Text = text
	b.TextScaled = true
	b.BackgroundColor3 = Color3.fromRGB(50,50,50)
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.Gotham
	Instance.new("UICorner", b)
	return b
end

-- Section selector
local sectionFrame = Instance.new("Frame", frame)
sectionFrame.Size = UDim2.fromScale(1,0.88)
sectionFrame.Position = UDim2.fromScale(0,0.12)
sectionFrame.BackgroundTransparency = 1

local miscSectionBtn = makeButton("Misc",0.3,sectionFrame)
local funSectionBtn  = makeButton("Fun",0.5,sectionFrame)
local trollSectionBtn = makeButton("Troll",0.7,sectionFrame)

-- Section frames
local miscFrame = Instance.new("Frame",frame)
miscFrame.Size = UDim2.fromScale(1,0.88)
miscFrame.Position = UDim2.fromScale(0,0.12)
miscFrame.BackgroundTransparency = 1
miscFrame.Visible = false

local funFrame = Instance.new("Frame",frame)
funFrame.Size = UDim2.fromScale(1,0.88)
funFrame.Position = UDim2.fromScale(0,0.12)
funFrame.BackgroundTransparency = 1
funFrame.Visible = false

local trollFrame = Instance.new("Frame",frame)
trollFrame.Size = UDim2.fromScale(1,0.88)
trollFrame.Position = UDim2.fromScale(0,0.12)
trollFrame.BackgroundTransparency = 1
trollFrame.Visible = false

-- Back buttons
local backMisc = makeButton("Back",0.9,miscFrame)
local backFun = makeButton("Back",0.9,funFrame)
local backTroll = makeButton("Back",0.9,trollFrame)

miscSectionBtn.MouseButton1Click:Connect(function()
	sectionFrame.Visible = false
	miscFrame.Visible = true
end)
funSectionBtn.MouseButton1Click:Connect(function()
	sectionFrame.Visible = false
	funFrame.Visible = true
end)
trollSectionBtn.MouseButton1Click:Connect(function()
	sectionFrame.Visible = false
	trollFrame.Visible = true
end)
backMisc.MouseButton1Click:Connect(function()
	miscFrame.Visible = false
	sectionFrame.Visible = true
end)
backFun.MouseButton1Click:Connect(function()
	funFrame.Visible = false
	sectionFrame.Visible = true
end)
backTroll.MouseButton1Click:Connect(function()
	trollFrame.Visible = false
	sectionFrame.Visible = true
end)

-- Minimal buttons (no functionality yet)
makeButton("ESP",0.05,miscFrame)
makeButton("Fly",0.15,miscFrame)
makeButton("Noclip",0.25,miscFrame)
makeButton("Gravity",0.35,miscFrame)
makeButton("Tracers",0.45,miscFrame)
makeButton("Destroy / Panic",0.55,miscFrame)

makeButton("Spin",0.05,funFrame)
makeButton("BigHead",0.15,funFrame)
makeButton("Confetti",0.25,funFrame)
makeButton("RainbowTrail",0.35,funFrame)
makeButton("Swim",0.45,funFrame)

makeButton("Spook Player",0.05,trollFrame)
makeButton("Fake Death",0.15,trollFrame)
makeButton("HeadSit",0.25,trollFrame)
