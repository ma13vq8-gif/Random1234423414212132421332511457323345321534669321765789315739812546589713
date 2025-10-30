-- LocalScript in StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- === SETTINGS ===
local LOCK_KEY = Enum.KeyCode.L
local cameraLockEnabled = false

-- === GUI SETUP ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CameraLockGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 180, 0, 40)
ToggleButton.Position = UDim2.new(0, 20, 0, 100)
ToggleButton.BackgroundColor3 = Color3.fromRGB(150, 60, 60)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 20
ToggleButton.Text = "🔓 Camera Lock: OFF"
ToggleButton.Parent = ScreenGui
ToggleButton.BorderSizePixel = 0
ToggleButton.AutoButtonColor = true

-- === UPDATE BUTTON VISUALS ===
local function updateButtonVisual()
	if cameraLockEnabled then
		ToggleButton.Text = "🔒 Camera Lock: ON"
		ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 150, 60)
	else
		ToggleButton.Text = "🔓 Camera Lock: OFF"
		ToggleButton.BackgroundColor3 = Color3.fromRGB(150, 60, 60)
	end
end

-- === HIGHLIGHT ALL PLAYERS ===
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

-- === FIND NEAREST PLAYER ===
local function getNearestPlayer()
	local nearestPlayer = nil
	local shortestDistance = math.huge
	local localChar = LocalPlayer.Character
	if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return nil end
	local myPos = localChar.HumanoidRootPart.Position

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

-- === CAMERA LOCK LOOP ===
RunService.RenderStepped:Connect(function()
	if not cameraLockEnabled then return end
	local nearest = getNearestPlayer()
	if nearest and nearest.Character and nearest.Character:FindFirstChild("HumanoidRootPart") then
		Camera.CameraSubject = nearest.Character:FindFirstChild("Humanoid")
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, nearest.Character.HumanoidRootPart.Position)
	end
end)

-- === TOGGLE FUNCTION ===
local function toggleCameraLock()
	cameraLockEnabled = not cameraLockEnabled
	updateButtonVisual()

	if not cameraLockEnabled then
		-- Reset camera to local player
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
		end
	end
end

-- === BUTTON CLICK ===
ToggleButton.MouseButton1Click:Connect(toggleCameraLock)

-- === KEYBIND TOGGLE ===
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == LOCK_KEY then
		toggleCameraLock()
	end
end)

-- Initialize visuals
updateButtonVisual()
