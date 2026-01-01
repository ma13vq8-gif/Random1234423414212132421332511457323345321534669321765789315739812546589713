--!strict
-- Place in StarterPlayer -> StarterPlayerScripts

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

-- Settings states
local Settings = {
    TooltipEnabled = true,
    Theme = "gray",
    Opacity = 1
}

-- Temporary objects
local TempObjs = {}

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ClientMenu"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.3,0.6)
frame.Position = UDim2.fromScale(0.05,0.2)
frame.BackgroundColor3 = Color3.fromRGB(128,128,128)
frame.BackgroundTransparency = 0
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

-- Tooltip
local tooltip = Instance.new("TextLabel", gui)
tooltip.Visible = false
tooltip.BackgroundColor3 = Color3.fromRGB(50,50,50)
tooltip.TextColor3 = Color3.new(1,1,1)
tooltip.TextScaled = true
tooltip.Size = UDim2.new(0,200,0,50)
tooltip.TextWrapped = true

-- Button creator
local function makeButton(text,parent,desc)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1,0,0,50)
    b.BackgroundColor3 = Color3.fromRGB(50,50,50)
    b.TextColor3 = Color3.new(1,1,1)
    b.TextScaled = true
    b.Font = Enum.Font.Gotham
    b.Text = text
    b.LayoutOrder = parent:GetChildren() and #parent:GetChildren() or 0
    Instance.new("UICorner",b)

    if desc then
        b.MouseEnter:Connect(function()
            if Settings.TooltipEnabled then
                task.wait(0.5)
                if b:IsMouseOver() then
                    tooltip.Text = desc
                    local mouse = UserInputService:GetMouseLocation()
                    tooltip.Position = UDim2.new(0, mouse.X + 10, 0, mouse.Y + 10)
                    tooltip.Visible = true
                end
            end
        end)
        b.MouseLeave:Connect(function()
            tooltip.Visible = false
        end)
    end

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

local miscSectionBtn = makeButton("Misc",sectionFrame,"Misc features like Fly, Noclip, Gravity etc.")
local funSectionBtn = makeButton("Fun",sectionFrame,"Fun features like Spin, BigHead, Rainbow Trail")
local trollSectionBtn = makeButton("Troll",sectionFrame,"Troll features like Spook or HeadSit")
local settingsSectionBtn = makeButton("Settings",sectionFrame,"Change theme, opacity, tooltips, reset position")
local destroyMenuBtn = makeButton("Destroy Menu",sectionFrame,"Completely removes this menu")
destroyMenuBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)

-- Destroy menu action
destroyMenuBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

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
local settingsFrame = createSectionFrame()

-- Back buttons
local function createBackButton(parent)
    local b = makeButton("Back",parent,"Return to section selector")
    b.LayoutOrder = 999
    b.MouseButton1Click:Connect(function()
        miscFrame.Visible = false
        funFrame.Visible = false
        trollFrame.Visible = false
        settingsFrame.Visible = false
        sectionFrame.Visible = true
    end)
    return b
end

createBackButton(miscFrame)
createBackButton(funFrame)
createBackButton(trollFrame)
createBackButton(settingsFrame)

-- Section selector logic
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
settingsSectionBtn.MouseButton1Click:Connect(function()
    sectionFrame.Visible = false
    settingsFrame.Visible = true
end)

-- Settings tab: Opacity slider (clickable)
local opacityLabel = Instance.new("TextLabel", settingsFrame)
opacityLabel.Size = UDim2.new(0.9,0,0,30)
opacityLabel.Position = UDim2.new(0.05,0,0,10)
opacityLabel.Text = "Menu Opacity"
opacityLabel.TextScaled = true
opacityLabel.BackgroundTransparency = 1
opacityLabel.TextColor3 = Color3.new(1,1,1)

local sliderBar = Instance.new("Frame", settingsFrame)
sliderBar.Size = UDim2.new(0.8,0,0,20)
sliderBar.Position = UDim2.new(0.1,0,0,50)
sliderBar.BackgroundColor3 = Color3.fromRGB(50,50,50)
sliderBar.ClipsDescendants = true
Instance.new("UICorner", sliderBar)

local sliderPoint = Instance.new("Frame", sliderBar)
sliderPoint.Size = UDim2.new(Settings.Opacity,0,1,0)
sliderPoint.BackgroundColor3 = Color3.fromRGB(200,200,200)
Instance.new("UICorner", sliderPoint)

sliderBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        local relativeX = input.Position.X - sliderBar.AbsolutePosition.X
        local newScale = math.clamp(relativeX/sliderBar.AbsoluteSize.X, 0, 1)
        sliderPoint.Size = UDim2.new(newScale,0,1,0)
        Settings.Opacity = newScale
        frame.BackgroundTransparency = 1 - newScale
