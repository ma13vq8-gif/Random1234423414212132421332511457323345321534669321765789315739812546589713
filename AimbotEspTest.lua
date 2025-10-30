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
