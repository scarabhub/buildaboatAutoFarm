local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local gravityNormal = workspace.Gravity
local isRunning = false
local speed = 375
local currentTween = nil

local destinations = {
    CFrame.new(-43.6134491, 62.1137619, 672.744934, -0.999842644, -0.00183729955, 0.017645346, 0, 0.994622767, 0.103564225, -0.0177407414, 0.103547923, -0.994466245),
    CFrame.new(-60.1504707, 97.4659729, 8767.91406, -0.99889338, 0.000705028593, 0.0470264405, 0, 0.999887645, -0.0149902813, -0.047031723, -0.0149736926, -0.998781145),
    CFrame.new(-54.331871, -345.398346, 9488.60645, -0.98221302, 0, 0.187770084, 0, 1, 0, -0.187770084, 0, -0.98221302),
}

local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "AutoFarmUI"
screenGui.ResetOnSpawn = false

local menu = Instance.new("Frame")
menu.Size = UDim2.fromScale(0.2, 0.2)
menu.Position = UDim2.fromScale(0.4, 0.4)
menu.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
menu.BorderSizePixel = 0
menu.Active = true
menu.Draggable = true
menu.Parent = screenGui

local close = Instance.new("TextButton")
close.Size = UDim2.fromScale(0.15, 0.25)
close.Position = UDim2.fromScale(0.82, 0.02)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
close.TextColor3 = Color3.new(1, 1, 1)
close.Parent = menu

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.fromScale(0.8, 0.5)
toggle.Position = UDim2.fromScale(0.1, 0.4)
toggle.Text = "AutoFarm + AntiAfk"
toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Parent = menu

close.MouseButton1Click:Connect(function()
    isRunning = false
    workspace.Gravity = gravityNormal
    if currentTween then
        currentTween:Cancel()
    end
    screenGui:Destroy()
end)

local function moveTo(targetCFrame, setGravity)
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local distance = (root.Position - targetCFrame.Position).Magnitude
    local duration = distance / speed

    currentTween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    currentTween:Play()

    local reached = false
    currentTween.Completed:Connect(function()
        reached = true
    end)

    if setGravity then
        workspace.Gravity = gravityNormal
    else
        workspace.Gravity = 0
    end

    while not reached and isRunning do
        RunService.Heartbeat:Wait()
    end
end

task.spawn(function()
    while true do
        task.wait(10)
        if isRunning then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.K, false, game)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.K, false, game)
        end
    end
end)

local function autoFarmLoop()
    while isRunning do
        local char = player.Character or player.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart", 5)
        if not root then return end

        for i, cf in ipairs(destinations) do
            if not isRunning then return end
            moveTo(cf, i == #destinations)
        end

        repeat
            wait(1)
        until player.CharacterAdded:Wait()
    end
end

toggle.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if not isRunning then
        toggle.Text = "AutoFarm + AntiAfk"
        workspace.Gravity = gravityNormal
        if currentTween then
            currentTween:Cancel()
        end
    else
        toggle.Text = "Stop AutoFarm"
        task.spawn(autoFarmLoop)
    end
end)

player.CharacterAdded:Connect(function()
    if isRunning then
        task.spawn(autoFarmLoop)
    end
end)

player.CharacterAdded:Connect(function()
    if isRunning then
        local char = player.Character or player.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart", 5)
        if root then
            wait(1)
            moveTo(destinations[1], false)
            task.spawn(autoFarmLoop)
        end
    end
end)
