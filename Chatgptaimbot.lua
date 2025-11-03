local LocalPlayer = game:GetService("Players").LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local scriptInstance = Instance.new("LocalScript")
scriptInstance.Source = [[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Create GUI
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.new(0, 200, 0, 50)
btn.Position = UDim2.new(0, 10, 0, 10)
btn.Text = "Lock POV: OFF"

local lock = false
btn.MouseButton1Click:Connect(function()
	lock = not lock
	btn.Text = "Lock POV: " .. (lock and "ON" or "OFF")
end)

local function getClosest()
	local myChar = LocalPlayer.Character
	if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
	local myPos = myChar.HumanoidRootPart.Position
	local closest, dist = nil, math.huge
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local d = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
			if d < dist then
				dist = d
				closest = p
			end
		end
	end
	return closest
end

-- Highlight all players
local folder = Instance.new("Folder", workspace)
folder.Name = "Highlights"
task.spawn(function()
	while true do
		folder:ClearAllChildren()
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character then
				local h = Instance.new("Highlight")
				h.Adornee = p.Character
				h.FillColor = Color3.fromRGB(255, 0, 0)
				h.Parent = folder
			end
		end
		task.wait(2)
	end
end)

RunService:BindToRenderStep("POVLock", Enum.RenderPriority.Camera.Value + 1, function()
	if not lock then
		Camera.CameraType = Enum.CameraType.Custom
		return
	end
	local me = LocalPlayer.Character
	if not me then return end
	local head = me:FindFirstChild("Head") or me:FindFirstChild("HumanoidRootPart")
	local target = getClosest()
	if head and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		Camera.CameraType = Enum.CameraType.Scriptable
		Camera.CFrame = CFrame.lookAt(head.Position, target.Character.HumanoidRootPart.Position)
	end
end)
]]
scriptInstance.Parent = PlayerGui
