THIS SCIPT DOS NOT WORK! do not try this

-- LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Wait for character
LocalPlayer.CharacterAdded:Wait()
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- GUI setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "POVGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

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

-- Helper: Get closest player
local function getClosestPlayer()
	local myChar = LocalPlayer.Character
	if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
	local myPos = myChar.HumanoidRootPart.Position

	local closest, minDist = nil, math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (plr.Character.HumanoidRootPart.Position - myPos).Magnitude
			if dist < minDist then
				minDist = dist
				closest = plr
			end
		end
	end
	return closest
end

-- Highlight system
local highlightFolder = Instance.new("Folder")
highlightFolder.Name = "PlayerHighlights"
highlightFolder.Parent = workspace

local function updateHighlights()
	highlightFolder:ClearAllChildren()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local h = Instance.new("Highlight")
			h.Adornee = plr.Character
			h.FillColor = Color3.fromRGB(255, 0, 0)
			h.OutlineColor = Color3.fromRGB(0, 0, 0)
			h.Parent = highlightFolder
		end
	end
end

task.spawn(function()
	while true do
		updateHighlights()
		task.wait(2)
	end
end)

-- Camera Control
local camModuleDisabled = false
RunService:BindToRenderStep("POVLockStep", Enum.RenderPriority.Camera.Value + 1, function()
	if not lockEnabled then
		if camModuleDisabled then
			Camera.CameraType = Enum.CameraType.Custom
			camModuleDisabled = false
		end
		return
	end

	local myChar = LocalPlayer.Character
	if not myChar then return end
	local head = myChar:FindFirstChild("Head") or myChar:FindFirstChild("HumanoidRootPart")
	if not head then return end

	local target = getClosestPlayer()
	if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		Camera.CameraType = Enum.CameraType.Scriptable
		camModuleDisabled = true
		local targetPos = target.Character.HumanoidRootPart.Position
		local headPos = head.Position
		Camera.CFrame = CFrame.lookAt(headPos, targetPos)
	end
end)
