local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HypershotGui"
screenGui.Parent = playerGui

-- Main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 180)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromHSV(0, 1, 1)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Title bar for dragging + minimize button
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundTransparency = 0.2
titleBar.BackgroundColor3 = Color3.new(0, 0, 0)
titleBar.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 1, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Hypershot Cheats"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 1, 0)
minimizeBtn.Position = UDim2.new(1, -30, 0, 0)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
minimizeBtn.Text = "–"
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.TextSize = 24
minimizeBtn.Parent = titleBar

-- Function to create buttons
local function createButton(text, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 180, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromHSV(0, 1, 1)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = text
    btn.Parent = frame
    return btn
end

local autoAimBtn = createButton("Toggle Auto Aim", 40)
local autoShootBtn = createButton("Toggle Auto Shoot", 90)
local espBtn = createButton("Toggle ESP", 140)

local autoAimEnabled = false
local autoShootEnabled = false
local espEnabled = false

autoAimBtn.MouseButton1Click:Connect(function()
    autoAimEnabled = not autoAimEnabled
    autoAimBtn.Text = autoAimEnabled and "Auto Aim: ON" or "Auto Aim: OFF"
    -- Your auto aim logic here
end)

autoShootBtn.MouseButton1Click:Connect(function()
    autoShootEnabled = not autoShootEnabled
    autoShootBtn.Text = autoShootEnabled and "Auto Shoot: ON" or "Auto Shoot: OFF"
    -- Your auto shoot logic here
end)

-- ESP Implementation
local espBoxes = {}

local function createBox(player)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = hrp
    box.Size = Vector3.new(4, 6, 1)
    box.Color3 = Color3.fromRGB(255, 0, 0)
    box.Transparency = 0.5
    box.ZIndex = 10
    box.AlwaysOnTop = true
    box.Parent = hrp
    return box
end

local function enableESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if not espBoxes[plr] then
                espBoxes[plr] = createBox(plr)
            end
        end
    end
end

local function disableESP()
    for plr, box in pairs(espBoxes) do
        if box then
            box:Destroy()
        end
    end
    espBoxes = {}
end

espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    if espEnabled then
        enableESP()
    else
        disableESP()
    end
end)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        if espEnabled then
            wait(1)
            enableESP()
        end
    end)
end)

-- Rainbow color changer
local hue = 0
RunService.Heartbeat:Connect(function(delta)
    hue = (hue + delta * 0.2) % 1
    local color = Color3.fromHSV(hue, 1, 1)
    frame.BackgroundColor3 = color
    autoAimBtn.BackgroundColor3 = color
    autoShootBtn.BackgroundColor3 = color
    espBtn.BackgroundColor3 = color
    titleBar.BackgroundColor3 = color * 0.4 -- Slightly darker for title bar
    minimizeBtn.BackgroundColor3 = color * 0.4
end)

-- Movable GUI logic
local dragging = false
local dragInput, dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Minimize button toggle
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        -- Hide buttons, keep title bar visible
        autoAimBtn.Visible = false
        autoShootBtn.Visible = false
        espBtn.Visible = false
        frame.Size = UDim2.new(0, 200, 0, 30)
        minimizeBtn.Text = "+"
    else
        -- Show buttons
        autoAimBtn.Visible = true
        autoShootBtn.Visible = true
        espBtn.Visible = true
        frame.Size = UDim2.new(0, 200, 0, 180)
        minimizeBtn.Text = "–"
    end
end)
