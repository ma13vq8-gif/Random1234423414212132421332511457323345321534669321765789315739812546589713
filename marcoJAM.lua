--!strict
-- Place in StarterPlayer → StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

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
	Gravity = 196.2,
	Tracers = false,
	Spin = false,
	BigHead = false,
	Confetti = false,
	RainbowTrail = false,
	Swim = false
}

-- Temp objects
local TempObjs = {}

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ClientMenu"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.3,0.6)
frame.Position = UDim2.fromScale(0.05,0.2)
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

-- Drag logic
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
local function makeButton(text,parent)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(1,0,0,50)
	b.BackgroundColor3 = Color3.fromRGB(50,50,50)
	b.TextColor3 = Color3.new(1,1,1)
	b.TextScaled = true
	b.Font = Enum.Font.Gotham
	Instance.new("UICorner",b)
	return b
end

-- Section selector
local sectionFrame = Instance.new("Frame", frame)
sectionFrame.Size = UDim2.fromScale(1,0.88)
sectionFrame.Position = UDim2.fromScale(0,0.12)
sectionFrame.BackgroundTransparency = 1
local sectionLayout = Instance.new("UIListLayout", sectionFrame)
sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
sectionLayout.Padding = UDim.new(0,10)

local miscSectionBtn = makeButton("Misc",sectionFrame)
local funSectionBtn  = makeButton("Fun",sectionFrame)
local trollSectionBtn = makeButton("Troll",sectionFrame)

-- Section frames
local function createSectionFrame()
	local f = Instance.new("Frame", frame)
	f.Size = UDim2.fromScale(1,0.88)
	f.Position = UDim2.fromScale(0,0.12)
	f.BackgroundTransparency = 1
	f.Visible = false
	local layout = Instance.new("UIListLayout", f)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0,5)
	return f
end

local miscFrame = createSectionFrame()
local funFrame = createSectionFrame()
local trollFrame = createSectionFrame()

local function createBackButton(parent)
	local b = makeButton("Back",parent)
	b.LayoutOrder = 999
	b.MouseButton1Click:Connect(function()
		miscFrame.Visible = false
		funFrame.Visible = false
		trollFrame.Visible = false
		sectionFrame.Visible = true
	end)
	return b
end

createBackButton(miscFrame)
createBackButton(funFrame)
createBackButton(trollFrame)

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

---------------------------------------------------
-- MISC Buttons
---------------------------------------------------
local panicBtn = makeButton("Destroy / Panic",miscFrame)
local espBtn = makeButton("ESP: OFF",miscFrame)
local flyBtn = makeButton("Fly: OFF",miscFrame)
local noclipBtn = makeButton("Noclip: OFF",miscFrame)
local gravBtn = makeButton("Gravity: 196.2",miscFrame)
local tracersBtn = makeButton("Tracers: OFF",miscFrame)

panicBtn.MouseButton1Click:Connect(function()
	print("Panic!")
	for k,_ in pairs(Features) do
		Features[k] = false
	end
	for _,obj in pairs(TempObjs) do
		if obj and obj.Parent then obj:Destroy() end
	end
	TempObjs = {}
	espBtn.Text = "ESP: OFF"
	flyBtn.Text = "Fly: OFF"
	noclipBtn.Text = "Noclip: OFF"
	tracersBtn.Text = "Tracers: OFF"
end)

-- Toggle logic
local function toggleFeature(btn,featureName,textOn,textOff)
	btn.MouseButton1Click:Connect(function()
		Features[featureName] = not Features[featureName]
		btn.Text = Features[featureName] and textOn or textOff
	end)
end

toggleFeature(espBtn,"ESP","ESP: ON","ESP: OFF")
toggleFeature(flyBtn,"Fly","Fly: ON","Fly: OFF")
toggleFeature(noclipBtn,"Noclip","Noclip: ON","Noclip: OFF")
toggleFeature(tracersBtn,"Tracers","Tracers: ON","Tracers: OFF")

-- Gravity example
gravBtn.MouseButton1Click:Connect(function()
	local text = tostring(Workspace.Gravity)
	local newGrav = tonumber(text)
	if newGrav then
		Features.Gravity = newGrav
	end
end)

---------------------------------------------------
-- FUN Buttons
---------------------------------------------------
local spinBtn = makeButton("Spin: OFF",funFrame)
local bigHeadBtn = makeButton("BigHead: OFF",funFrame)
local confettiBtn = makeButton("Confetti: OFF",funFrame)
local rainbowTrailBtn = makeButton("RainbowTrail: OFF",funFrame)
local swimBtn = makeButton("Swim: OFF",funFrame)

toggleFeature(spinBtn,"Spin","Spin: ON","Spin: OFF")
toggleFeature(bigHeadBtn,"BigHead","BigHead: ON","BigHead: OFF")
toggleFeature(confettiBtn,"Confetti","Confetti: ON","Confetti: OFF")
toggleFeature(rainbowTrailBtn,"RainbowTrail","RainbowTrail: ON","RainbowTrail: OFF")
toggleFeature(swimBtn,"Swim","Swim: ON","Swim: OFF")

---------------------------------------------------
-- TROLL Buttons
---------------------------------------------------
-- Spook
local spookBtn = makeButton("Spook Player",trollFrame)
local spookBox = Instance.new("TextBox", trollFrame)
spookBox.Size = UDim2.new(1,0,0,50)
spookBox.PlaceholderText = "Enter Username"
spookBox.TextScaled = true
spookBox.Visible = false
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
local fakeBtn = makeButton("Fake Death",trollFrame)
fakeBtn.MouseButton1Click:Connect(function()
	TrollRemotes.FakeDeath:FireServer()
end)

-- HeadSit
local headSitBtn = makeButton("HeadSit",trollFrame)
local headSitBox = Instance.new("TextBox", trollFrame)
headSitBox.Size = UDim2.new(1,0,0,50)
headSitBox.PlaceholderText = "Enter Username"
headSitBox.TextScaled = true
headSitBox.Visible = false
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

---------------------------------------------------
-- Main update loop (apply features)
---------------------------------------------------
RunService.RenderStepped:Connect(function()
	-- Gravity
	if Features.Gravity then
		Workspace.Gravity = Features.Gravity
	end
	-- Fly
	if Features.Fly then
		if not TempObjs.FlyBV then
			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(1e5,1e5,1e5)
			bv.Velocity = Vector3.new(0,0,0)
			bv.Parent = root
			TempObjs.FlyBV = bv
			local bg = Instance.new("BodyGyro")
			bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
			bg.CFrame = root.CFrame
			bg.Parent = root
			TempObjs.FlyBG = bg
		end
		TempObjs.FlyBV.Velocity = humanoid.MoveDirection * Features.FlySpeed
	else
		if TempObjs.FlyBV then TempObjs.FlyBV:Destroy() TempObjs.FlyBV=nil end
		if TempObjs.FlyBG then TempObjs.FlyBG:Destroy() TempObjs.FlyBG=nil end
	end
	-- Noclip
	for _,part in pairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = not Features.Noclip
		end
	end
end)
