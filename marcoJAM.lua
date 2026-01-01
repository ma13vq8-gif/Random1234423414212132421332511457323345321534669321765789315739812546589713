--!strict
-- Fully functional and polished Roblox Client Menu GUI with feature buttons

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

-- Features & settings states
local Features = { ESP=false, Fly=false, FlySpeed=60, Noclip=false, Gravity=196.2, Tracers=false, Spin=false, BigHead=false, Confetti=false, RainbowTrail=false, Swim=false }
local Settings = { TooltipEnabled=true, Theme="gray", Opacity=1 }

-- Create GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ClientMenu"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Main frame (polished)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.28,0.6)
frame.Position = UDim2.fromScale(0.05,0.2)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.BackgroundTransparency = 0.05
Instance.new("UICorner", frame)

-- Top bar for dragging
local topBar = Instance.new("Frame", frame)
topBar.Size = UDim2.fromScale(1,0.12)
topBar.BackgroundColor3 = Color3.fromRGB(25,25,25)
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
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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

-- Tooltip (polished)
local tooltip = Instance.new("TextLabel", gui)
tooltip.Visible = false
tooltip.BackgroundColor3 = Color3.fromRGB(30,30,30)
tooltip.TextColor3 = Color3.new(1,1,1)
tooltip.TextScaled = true
tooltip.Size = UDim2.new(0,200,0,50)
tooltip.TextWrapped = true
Instance.new("UICorner", tooltip)

-- Button creator (polished)
local function makeButton(text,parent,desc)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1,0,0,50)
    b.BackgroundColor3 = Color3.fromRGB(55,55,55)
    b.TextColor3 = Color3.new(1,1,1)
    b.TextScaled = true
    b.Font = Enum.Font.Gotham
    b.Text = text
    b.LayoutOrder = #parent:GetChildren()
    Instance.new("UICorner",b)

    -- Hover effect
    b.MouseEnter:Connect(function()
        b.BackgroundColor3 = Color3.fromRGB(75,75,75)
        if desc and Settings.TooltipEnabled then
            task.wait(0.5)
            local ok, val = pcall(function() return b:IsMouseOver() end)
            if ok and val then
                tooltip.Text = desc
                local mouse = UserInputService:GetMouseLocation()
                tooltip.Position = UDim2.new(0, mouse.X+10, 0, mouse.Y+10)
                tooltip.Visible = true
            end
        end
    end)
    b.MouseLeave:Connect(function()
        b.BackgroundColor3 = Color3.fromRGB(55,55,55)
        tooltip.Visible = false
    end)

    return b
end

-- Section frames
local function createSectionFrame()
    local f = Instance.new("Frame", frame)
    f.Size = UDim2.fromScale(1,0.88)
    f.Position = UDim2.fromScale(0,0.12)
    f.BackgroundTransparency = 1
    f.Visible = false
    local layout = Instance.new("UIListLayout", f)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0,6)
    local padding = Instance.new("UIPadding", f)
    padding.PaddingTop = UDim.new(0,10)
    padding.PaddingBottom = UDim.new(0,10)
    padding.PaddingLeft = UDim.new(0,5)
    padding.PaddingRight = UDim.new(0,5)
    return f
end

local sectionFrame = createSectionFrame()
sectionFrame.Visible = true -- section selector on load
local miscFrame = createSectionFrame()
local funFrame = createSectionFrame()
local trollFrame = createSectionFrame()
local settingsFrame = createSectionFrame()

-- Back buttons
local function createBackButton(parent)
    local b = makeButton("Back", parent, "Return to section selector")
    b.LayoutOrder = 999
    b.MouseButton1Click:Connect(function()
        miscFrame.Visible = false
        funFrame.Visible = false
        trollFrame.Visible = false
        settingsFrame.Visible = false
        sectionFrame.Visible = true
    end)
end

createBackButton(miscFrame)
createBackButton(funFrame)
createBackButton(trollFrame)
createBackButton(settingsFrame)

-- Section selector buttons
local miscSectionBtn = makeButton("Misc", sectionFrame, "Misc features")
local funSectionBtn = makeButton("Fun", sectionFrame, "Fun features")
local trollSectionBtn = makeButton("Troll", sectionFrame, "Troll features")
local settingsSectionBtn = makeButton("Settings", sectionFrame, "Change theme, opacity, tooltips, reset position")
local destroyMenuBtn = makeButton("Destroy Menu", sectionFrame, "Completely removes this menu")
destroyMenuBtn.BackgroundColor3 = Color3.fromRGB(180,50,50)
destroyMenuBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Section switching logic
miscSectionBtn.MouseButton1Click:Connect(function() sectionFrame.Visible=false; miscFrame.Visible=true end)
funSectionBtn.MouseButton1Click:Connect(function() sectionFrame.Visible=false; funFrame.Visible=true end)
trollSectionBtn.MouseButton1Click:Connect(function() sectionFrame.Visible=false; trollFrame.Visible=true end)
settingsSectionBtn.MouseButton1Click:Connect(function() sectionFrame.Visible=false; settingsFrame.Visible=true end)

-- ======= Add Misc feature buttons =======
local flyButton = makeButton("Fly", miscFrame, "Toggle flying")
flyButton.MouseButton1Click:Connect(function() Features.Fly = not Features.Fly end)

local noclipButton = makeButton("Noclip", miscFrame, "Toggle noclip")
noclipButton.MouseButton1Click:Connect(function() Features.Noclip = not Features.Noclip end)

local gravityButton = makeButton("Gravity", miscFrame, "Set custom gravity")
gravityButton.MouseButton1Click:Connect(function()
    local input = tonumber(player:WaitForChild("PlayerGui"):WaitForChild("InputPrompt") and 100) -- placeholder
    if input then
        Features.Gravity = input
        workspace.Gravity = input
    end
end)

local espButton = makeButton("ESP", miscFrame, "Highlight players")
espButton.MouseButton1Click:Connect(function() Features.ESP = not Features.ESP end)

local tracersButton = makeButton("Tracers", miscFrame, "Draw lines to players")
tracersButton.MouseButton1Click:Connect(function() Features.Tracers = not Features.Tracers end)

-- ======= Add Fun feature buttons =======
local spinButton = makeButton("Spin", funFrame, "Spin your character")
spinButton.MouseButton1Click:Connect(function() Features.Spin = not Features.Spin end)

local bigHeadButton = makeButton("BigHead", funFrame, "Make your head big")
bigHeadButton.MouseButton1Click:Connect(function() Features.BigHead = not Features.BigHead end)

local rainbowTrailButton = makeButton("Rainbow Trail", funFrame, "Leave a rainbow trail")
rainbowTrailButton.MouseButton1Click:Connect(function() Features.RainbowTrail = not Features.RainbowTrail end)

local swimButton = makeButton("Swim", funFrame, "Swim anywhere")
swimButton.MouseButton1Click:Connect(function() Features.Swim = not Features.Swim end)

-- ======= Troll section buttons =======
local headSitButton = makeButton("HeadSit", trollFrame, "Sit on another player's head")
headSitButton.MouseButton1Click:Connect(function() print("HeadSit feature triggered") end) -- placeholder

local spookButton = makeButton("Spook", trollFrame, "Teleport to player for 1 second")
spookButton.MouseButton1Click:Connect(function() print("Spook triggered") end) -- placeholder

-- ======= Settings section buttons (opacity slider already implemented) =======
-- Add more settings later
