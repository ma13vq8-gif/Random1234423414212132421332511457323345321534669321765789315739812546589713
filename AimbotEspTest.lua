-- LocalScript in StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- === SETTINGS ===
local LOCK_KEY = Enum.KeyCode.L
local lockEnabled = false
local guiMinimized = false

-- === GUI SETUP ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FullLockGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- === Main Frame ===
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 270)
MainFrame.Position = UDim2.new(0, 20, 0, 100)
MainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- === Toggle Lock Button ===
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 200, 0, 40)
ToggleButton.Position = UDim2.new(0, 20, 0, 10)
ToggleButton.BackgroundColor3 = Color3.fromRGB(150, 60, 60)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 20
ToggleButton.Text = "🔓 Lock: OFF"
ToggleButton.Parent = MainFrame
ToggleButton.BorderSizePixel = 0
ToggleButton.AutoButtonColor = true

local function updateButton()
	if lockEnabled then
		ToggleButton.Text = "🔒 Lock: ON"
		ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 150, 60)
	else
		ToggleButton.Text = "🔓 Lock: OFF"
		ToggleButton.BackgroundColor3 = Color3.fromRGB(150, 60, 60)
	end
end

-- === Minimize / Expand Button ===
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -35, 0, 5)
MinimizeButton.Text = "—"
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.TextSize = 20
MinimizeButton.TextColor3 = Color3.fromRGB(255,255,255)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(100,100,100)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Parent = MainFrame

MinimizeButton.MouseButton1Click:Connect(function()
	guiMinimized = not guiMinimized
	for _, child in pairs(MainFrame:GetChildren()) do
		if child ~= ToggleButton and child ~= MinimizeButton then
			child.Visible = not guiMinimized
		end
	end
	MinimizeButton.Text = guiMinimized and "+" or "—"
end)

-- === HIGHLIGHT PLAYERS ===
local function highlightCharacter(character)
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(255, 255, 0)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.Parent = character
end

-- === HELPER FUNCTIONS ===
local function getNearestPlayer()
	local localChar = LocalPlayer.Character
	if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return nil end
	local myPos = localChar.HumanoidRootPart.Position

	local nearestPlayer = nil
	local shortestDistance = math.huge

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local distance = (player.Character.HumanoidRootPart.Position - myPos).Magnitude
			if distance < shortestDistance then
				shortestDistance = distance
				nearestPlayer = player
			end
		end
	end

	return nearestPlayer
end

-- === BODY & CAMERA LOCK LOOP ===
RunService.RenderStepped:Connect(function()
	if not lockEnabled then return end
	local localChar = LocalPlayer.Character
	if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return end
	local HRP = localChar.HumanoidRootPart

	local nearest = getNearestPlayer()
	if nearest and nearest.Character and nearest.Character:FindFirstChild("HumanoidRootPart") then
		local targetPos = nearest.Character.HumanoidRootPart.Position
		local myPos = HRP.Position
		local lookVector = (Vector3.new(targetPos.X, myPos.Y, targetPos.Z) - myPos).Unit

		-- Rotate character
		HRP.CFrame = CFrame.new(myPos, myPos + lookVector)

		-- Lock camera to follow character
		Camera.CameraType = Enum.CameraType.Attach
		Camera.CameraSubject = HRP
	end
end)

-- === TOGGLE FUNCTION ===
local function toggleLock()
	lockEnabled = not lockEnabled
	updateButton()
	if not lockEnabled then
		Camera.CameraType = Enum.CameraType.Custom
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			Camera.CameraSubject = LocalPlayer.Character.Humanoid
		end
	end
end

-- === GUI BUTTON CLICK ===
ToggleButton.MouseButton1Click:Connect(toggleLock)

-- === KEYBIND ===
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == LOCK_KEY then
		toggleLock()
	end
end)

-- INITIALIZE
updateButton()

-- === COLOR SLIDERS GUI ===
local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(0, 200, 0, 110)
SliderFrame.Position = UDim2.new(0, 20, 0, 60)
SliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SliderFrame.BorderSizePixel = 0
SliderFrame.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 20)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Highlight Color"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = SliderFrame

-- Helper to create draggable sliders
local function createSlider(labelText, yPos, initial)
	local label = Instance.new("TextLabel")
	label.Text = labelText
	label.Size = UDim2.new(0, 20, 0, 20)
	label.Position = UDim2.new(0, 5, 0, yPos)
	label.BackgroundTransparency = 1
	label.TextColor3 = labelText == "R" and Color3.new(1,0,0) or labelText == "G" and Color3.new(0,1,0) or Color3.new(0,0,1)
	label.Parent = SliderFrame

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0, 150, 0, 20)
	bar.Position = UDim2.new(0, 25, 0, yPos)
	bar.BackgroundColor3 = Color3.fromRGB(100,100,100)
	bar.BorderSizePixel = 0
	bar.Parent = SliderFrame

	local handle = Instance.new("Frame")
	handle.Size = UDim2.new(0, 10, 1, 0)
	handle.Position = UDim2.new(initial/255, 0, 0, 0)
	handle.BackgroundColor3 = Color3.fromRGB(200,200,200)
	handle.BorderSizePixel = 0
	handle.Parent = bar

	local dragging = false

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
		end
	end)

	handle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	bar.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local mousePos = UserInputService:GetMouseLocation().X
			local barPos = bar.AbsolutePosition.X
			local barSize = bar.AbsoluteSize.X
			local newPos = math.clamp(mousePos - barPos, 0, barSize)
			handle.Position = UDim2.new(newPos / barSize, 0, 0, 0)
		end
	end)

	local function getValue()
		return math.floor(handle.Position.X.Scale * 255)
	end

	return getValue
end

-- Create RGB sliders
local getRed = createSlider("R", 25, 255)
local getGreen = createSlider("G", 50, 255)
local getBlue = createSlider("B", 75, 0)

-- === HIGHLIGHT MANAGEMENT ===
local function ensureHighlight(character)
	local highlight = character:FindFirstChildOfClass("Highlight")
	if not highlight then
		highlightCharacter(character)
		highlight = character:FindFirstChildOfClass("Highlight")
	end
	return highlight
end

local function refreshHighlights()
	local r, g, b = getRed(), getGreen(), getBlue()
	local color = Color3.fromRGB(r,g,b)

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local highlight = ensureHighlight(player.Character)
			if highlight then
				highlight.FillColor = color
			end
		end
	end
end

-- Instant highlight for joining players
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local highlight = ensureHighlight(character)
		if highlight then
			local r, g, b = getRed(), getGreen(), getBlue()
			highlight.FillColor = Color3.fromRGB(r,g,b)
		end
	end)
end)

for _, player in pairs(Players:GetPlayers()) do
	player.CharacterAdded:Connect(function(character)
		local highlight = ensureHighlight(character)
		if highlight then
			local r, g, b = getRed(), getGreen(), getBlue()
			highlight.FillColor = Color3.fromRGB(r,g,b)
		end
	end)
end

-- Refresh highlights every 1 second
spawn(function()
	while true do
		refreshHighlights()
		wait(1)
	end
end)

-- === DRAGGABLE GUI ===
local dragging = false
local dragInput
local dragStart
local startPos

local function update(input)
	local delta = input.Position - dragStart
	MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

MainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input == dragInput then
		update(input)
	end
end)
