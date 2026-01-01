-- Place this in StarterPlayer → StarterPlayerScripts
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")
gui.Name = "TestMenu"

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
local dragging, dragStart, startPos = false, nil, nil
local UserInputService = game:GetService("UserInputService")
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
UserInputService.InputChanged:Connect(function(input)
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

---------------------------------------------------
-- MISC BUTTONS (Panic at top)
---------------------------------------------------
local panicBtn = makeButton("Destroy / Panic",0.05,miscFrame)
local testBtn = makeButton("Test Button",0.15,miscFrame)
panicBtn.MouseButton1Click:Connect(function()
	print("Panic clicked!")
end)

---------------------------------------------------
-- TROLL BUTTONS (TextBoxes)
---------------------------------------------------
local spookBtn = makeButton("Spook Player",0.05,trollFrame)
local spookBox = Instance.new("TextBox", trollFrame)
spookBox.Size = UDim2.fromScale(0.9,0.08)
spookBox.Position = UDim2.fromScale(0.05,0.15)
spookBox.PlaceholderText = "Enter Username"
spookBox.TextScaled = true
spookBox.Visible = false
spookBox.BackgroundColor3 = Color3.fromRGB(35,35,35)
spookBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", spookBox)
spookBtn.MouseButton1Click:Connect(function()
	spookBox.Visible = not spookBox.Visible
end)

local headSitBtn = makeButton("HeadSit",0.3,trollFrame)
local headSitBox = Instance.new("TextBox", trollFrame)
headSitBox.Size = UDim2.fromScale(0.9,0.08)
headSitBox.Position = UDim2.fromScale(0.05,0.4)
headSitBox.PlaceholderText = "Enter Username"
headSitBox.TextScaled = true
headSitBox.Visible = false
headSitBox.BackgroundColor3 = Color3.fromRGB(35,35,35)
headSitBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", headSitBox)
headSitBtn.MouseButton1Click:Connect(function()
	headSitBox.Visible = not headSitBox.Visible
end)
