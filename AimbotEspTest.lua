-- LocalScript in StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- === SETTINGS ===
local LOCK_KEY = Enum.KeyCode.L
local lockEnabled = false

-- === GUI SETUP ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FullLockGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 200, 0, 40)
ToggleButton.Position = UDim2.new(0, 20, 0, 100)
ToggleButton.BackgroundColor3 = Color3.fromRGB(150, 60, 60)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 20
ToggleButton.Text = "🔓 Lock: OFF"
ToggleButton.Parent = ScreenGui
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

-- === HIGHLIGHT PLAYERS ===
local function highlightCharacter(character)
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(255, 255, 0)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.Parent = character
end

for _, player in pairs(Players:GetPlayers()) do
	if player ~= LocalPlayer and player.Character then
		highlightCharacter(player.Character)
	end
	player.CharacterAdded:Connect(function(character)
		if player ~= LocalPlayer then
			highlightCharacter(character)
		end
	end)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		if player ~= LocalPlayer then
			highlightCharacter(character)
		end
	end)
end)

-- === HELPER FUNCTION ===
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
		-- Reset camera to default
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

-- === COLOR SLIDERS ===
local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(0, 220, 0, 110)
SliderFrame.Position = UDim2.new(0, 20, 0, 160)
SliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SliderFrame.BorderSizePixel = 0
SliderFrame.Parent = ScreenGui

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

-- Update highlights every frame
RunService.RenderStepped:Connect(function()
	local r, g, b = getRed(), getGreen(), getBlue()
	local color = Color3.fromRGB(r,g,b)
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local highlight = player.Character:FindFirstChildOfClass("Highlight")
			if highlight then
				highlight.FillColor = color
			end
		end
	end
end)
