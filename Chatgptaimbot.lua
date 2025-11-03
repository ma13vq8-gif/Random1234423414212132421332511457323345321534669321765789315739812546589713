-- Run this in the CLIENT console (F9 > Client)
local LocalPlayer = game:GetService("Players").LocalPlayer

local scriptSource = [[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GUI Setup
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "POVGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0, 200, 0, 50)
Button.Position = UDim2.new(0, 10, 0, 10)
Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Button.TextColor3 = Color3.new(1, 1, 1)
Button.Font = Enum.Font.SourceSansBold
Button.TextSize = 22
Button.Text = "Lock POV: OFF"
Button.Parent = ScreenGui

local lockEnabled = false
Button.MouseButton1Click:Connect(function()
	lockEnabled = not lockEnabled
	Button.Text = "Lock POV: " .. (lockEnabled and "ON" or "OFF")
	Button.BackgroundColor3 = lockEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(40, 40, 40)
end)

-- Find closest player
local function getClosestPlayer()
	local myChar = LocalPlayer.Character
	if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
	local myPos = myChar.HumanoidRootPart.Position
	local closestPlayer, shortestDist = nil, math.huge
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
			if dist < shortestDist then
				shortestDist = dist
				closestPlayer = p
			end
		end
	end
	return closestPlayer
end

-- Highlights
local highlightFolder = Instance.new("Folder")
highlightFolder.Name = "PlayerHighlights"
highlightFolder.Parent = workspace

local function updateHighlights()
	highlightFolder:ClearAllChildren()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local highlight = Instance.new("Highlight")
			highlight.Adornee = p.Character
			highlight.FillColor = Color3.fromRGB(255, 0, 0)
			highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
			highlight.Parent = highlightFolder
		end
	end
end

task.spawn(function()
	while true do
		updateHighlights()
		task.wait(2)
	end
end)

-- Camera Lock
RunService:BindToRenderStep("POVLockStep", Enum.RenderPriority.Camera.Value + 1, function()
	if not lockEnabled then
		Camera.CameraType = Enum.CameraType.Custom
		return
	end
	local myChar = LocalPlayer.Character
	if not myChar then return end
	local head = myChar:FindFirstChild("Head") or myChar:FindFirstChild("HumanoidRootPart")
	if not head then return end
	local closest = getClosestPlayer()
	if closest and closest.Character and closest.Character:FindFirstChild("HumanoidRootPart") then
		local targetPos = closest.Character.HumanoidRootPart.Position
		Camera.CameraType = Enum.CameraType.Scriptable
		Camera.CFrame = CFrame.lookAt(head.Position, targetPos)
	end
end)
]]

-- Create and run the LocalScript
local scriptInstance = Instance.new("LocalScript")
scriptInstance.Name = "POV_LockScript"
scriptInstance.Source = scriptSource
scriptInstance.Parent = LocalPlayer:WaitForChild("PlayerGui")

print("✅ POV Lock Script loaded! Use the on-screen button to enable/disable.")
