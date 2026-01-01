--!strict
-- Place in StarterPlayer → StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

-- RemoteEvents folder
local TrollRemotes = ReplicatedStorage:FindFirstChild("TrollRemotes")
if not TrollRemotes then
	TrollRemotes = Instance.new("Folder")
	TrollRemotes.Name = "TrollRemotes"
	TrollRemotes.Parent = ReplicatedStorage
	for _, name in ipairs({"SpookPlayer","HeadSit","FakeDeath"}) do
		local r = Instance.new("RemoteEvent")
		r.Name = name
		r.Parent = TrollRemotes
	end
end

-- Feature states
local Features = {
	ESP = false,
	Fly = false,
	FlySpeed = 60,
	Noclip = false,
	Gravity = 50,
	Tracers = false,
	Spin = false,
	BigHead = false,
	Confetti = false,
	RainbowTrail = false,
	Swim = false
}

-- Temporary objects
local TempObjs = {}

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ClientMenu"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.25,0.55)
frame.Position = UDim2.fromScale(0.05,0.25)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Instance.new("UICorner", frame)

-- Top bar
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

-- Drag
local dragging, dragStart, startPos = false, nil, nil
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
-- MISC
---------------------------------------------------
local panicBtn = makeButton("Destroy / Panic",0.05,miscFrame)
local espBtn = makeButton("ESP: OFF",0.15,miscFrame)
local flyBtn = makeButton("Fly: OFF",0.25,miscFrame)
local flySpeedBtn = makeButton("Fly Speed: 60",0.35,miscFrame)
local noclipBtn = makeButton("Noclip: OFF",0.45,miscFrame)
local gravBtn = makeButton("Gravity: 50",0.55,miscFrame)
local presetLow = makeButton("Low (20)",0.6,miscFrame)
local presetNormal = makeButton("Normal (50)",0.65,miscFrame)
local presetHeavy = makeButton("Heavy (80)",0.7,miscFrame)
local customPresetBtn = makeButton("+ Add Preset",0.75,miscFrame)
local tracersBtn = makeButton("Tracers: OFF",0.8,miscFrame)

-- Panic logic
panicBtn.MouseButton1Click:Connect(function()
	print("Panic activated! Resetting all features")
	for k,_ in pairs(Features) do
		Features[k] = false
	end
	for _,obj in pairs(TempObjs) do
		if obj and obj.Parent then obj:Destroy() end
	end
	TempObjs = {}
	-- reset GUI buttons text
	espBtn.Text = "ESP: OFF"
	flyBtn.Text = "Fly: OFF"
	noclipBtn.Text = "Noclip: OFF"
	tracersBtn.Text = "Tracers: OFF"
end)

-- Toggle buttons example
espBtn.MouseButton1Click:Connect(function()
	Features.ESP = not Features.ESP
	espBtn.Text = Features.ESP and "ESP: ON" or "ESP: OFF"
end)
flyBtn.MouseButton1Click:Connect(function()
	Features.Fly = not Features.Fly
	flyBtn.Text = Features.Fly and "Fly: ON" or "Fly: OFF"
end)
noclipBtn.MouseButton1Click:Connect(function()
	Features.Noclip = not Features.Noclip
	noclipBtn.Text = Features.Noclip and "Noclip: ON" or "Noclip: OFF"
end)
tracersBtn.MouseButton1Click:Connect(function()
	Features.Tracers = not Features.Tracers
	tracersBtn.Text = Features.Tracers and "Tracers: ON" or "Tracers: OFF"
end)

---------------------------------------------------
-- FUN
---------------------------------------------------
local spinBtn = makeButton("Spin: OFF",0.05,funFrame)
local bigHeadBtn = makeButton("BigHead: OFF",0.15,funFrame)
local confettiBtn = makeButton("Confetti: OFF",0.25,funFrame)
local rainbowTrailBtn = makeButton("RainbowTrail: OFF",0.35,funFrame)
local swimBtn = makeButton("Swim: OFF",0.45,funFrame)

spinBtn.MouseButton1Click:Connect(function()
	Features.Spin = not Features.Spin
	spinBtn.Text = Features.Spin and "Spin: ON" or "Spin: OFF"
end)
bigHeadBtn.MouseButton1Click:Connect(function()
	Features.BigHead = not Features.BigHead
	bigHeadBtn.Text = Features.BigHead and "BigHead: ON" or "BigHead: OFF"
end)
confettiBtn.MouseButton1Click:Connect(function()
	Features.Confetti = not Features.Confetti
	confettiBtn.Text = Features.Confetti and "Confetti: ON" or "Confetti: OFF"
end)
rainbowTrailBtn.MouseButton1Click:Connect(function()
	Features.RainbowTrail = not Features.RainbowTrail
	rainbowTrailBtn.Text = Features.RainbowTrail and "RainbowTrail: ON" or "RainbowTrail: OFF"
end)
swimBtn.MouseButton1Click:Connect(function()
	Features.Swim = not Features.Swim
	swimBtn.Text = Features.Swim and "Swim: ON" or "Swim: OFF"
end)

---------------------------------------------------
-- TROLL
---------------------------------------------------
-- Spook
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
spookBox.FocusLost:Connect(function(enter)
	if enter and spookBox.Text ~= "" then
		TrollRemotes.SpookPlayer:FireServer(spookBox.Text)
	end
	spookBox.Text = ""
	spookBox.Visible = false
end)

-- Fake Death
local fakeBtn = makeButton("Fake Death",0.35,trollFrame)
fakeBtn.MouseButton1Click:Connect(function()
	TrollRemotes.FakeDeath:FireServer()
end)

-- HeadSit
local headSitBtn = makeButton("HeadSit",0.5,trollFrame)
local headSitBox = Instance.new("TextBox", trollFrame)
headSitBox.Size = UDim2.fromScale(0.9,0.08)
headSitBox.Position = UDim2.fromScale(0.05,0.6)
headSitBox.PlaceholderText = "Enter Username"
headSitBox.TextScaled = true
headSitBox.Visible = false
headSitBox.BackgroundColor3 = Color3.fromRGB(35,35,35)
headSitBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", headSitBox)
headSitBtn.MouseButton1Click:Connect(function()
	headSitBox.Visible = not headSitBox.Visible
end)
headSitBox.FocusLost:Connect(function(enter)
	if enter and headSitBox.Text ~= "" then
		TrollRemotes.HeadSit:FireServer(headSitBox.Text)
	end
	headSitBox.Text = ""
	headSitBox.Visible = false
end)
