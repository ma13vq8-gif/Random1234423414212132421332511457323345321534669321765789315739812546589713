-- Place this LocalScript in StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LockPOVGui"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 200, 0, 50)
ToggleButton.Position = UDim2.new(0, 10, 0, 10)
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 22
ToggleButton.Text = "Lock POV: OFF"
ToggleButton.Parent = ScreenGui

local lockPOV = false

ToggleButton.MouseButton1Click:Connect(function()
	lockPOV = not lockPOV
	ToggleButton.Text = "Lock POV: " .. (lockPOV and "ON" or "OFF")
	ToggleButton.BackgroundColor3 = lockPOV and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(40, 40, 40)
end)

-- Find closest player
local function getClosestPlayer()
	local closest, shortest = nil, math.huge
	local myChar = LocalPlayer.Character
	if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
	local myPos = myChar.HumanoidRootPart.Position

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (player.Character.HumanoidRootPart.Position - myPos).Magnitude
			if dist < shortest then
				shortest = dist
				closest = player
			end
		end
	end
	return closest
end

-- Highlight setup
local highlightFolder = Instance.new("Folder")
highlightFolder.Name = "PlayerHighlights"
highlightFolder.Parent = workspace

local function updateHighlights()
	highlightFolder:ClearAllChildren()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local highlight = Instance.new("Highlight")
			highlight.Adornee = player.Character
			highlight.FillColor = Color3.fromRGB(255, 0, 0)
			highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
			highlight.Parent = highlightFolder
		end
	end
end

-- Update ESP every 2 seconds
task.spawn(function()
	while true do
		updateHighlights()
		task.wait(2)
	end
end)

-- Camera lock update (fixed)
RunService.RenderStepped:Connect(function()
	if lockPOV then
		local myChar = LocalPlayer.Character
		local myHead = myChar and myChar:FindFirstChild("Head")
		local closest = getClosestPlayer()

		if myHead and closest and closest.Character and closest.Character:FindFirstChild("HumanoidRootPart") then
			local targetPos = closest.Character.HumanoidRootPart.Position
			local headPos = myHead.Position
			local newCFrame = CFrame.new(headPos, targetPos)
			Camera.CFrame = newCFrame
			Camera.CameraType = Enum.CameraType.Scriptable
		end
	else
		Camera.CameraType = Enum.CameraType.Custom
	end
end)
