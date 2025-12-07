if _G.a then
    for _, conn in pairs(_G.a) do
        conn:Disconnect()
    end
    _G.a = nil
end

repeat task.wait() until game.Players.LocalPlayer
local player = game.Players.LocalPlayer
local character, humanoid, rootPart
local invisible = false
local parts = {}
local gui

local function setupCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    parts = {}
    for _, obj in pairs(character:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Transparency == 0 then
            table.insert(parts, obj)
        end
    end
end

local function makeDraggable(gui)
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

local function createUI()
    if player.PlayerGui:FindFirstChild("InvisibleUI") then
        return
    end
    
    gui = Instance.new("ScreenGui")
    gui.Name = "InvisibleUI"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 90)
    frame.Position = UDim2.new(0.5, -110, 0.15, 0)  -- Позиция из первого скрипта
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.BorderSizePixel = 2
    frame.Active = true
    frame.Parent = gui

    makeDraggable(frame)

    local invisBtn = Instance.new("TextButton")
    invisBtn.Size = UDim2.new(0, 100, 0, 40)
    invisBtn.Position = UDim2.new(0, 10, 0, 25)
    invisBtn.Text = "Invisible"
    invisBtn.TextScaled = true
    invisBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    invisBtn.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 80, 0, 30)
    toggleBtn.Position = UDim2.new(0, 130, 0, 30)
    toggleBtn.Text = "Hide"
    toggleBtn.TextScaled = true
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 160, 240)
    toggleBtn.Active = false
    toggleBtn.Parent = frame

    invisBtn.MouseButton1Click:Connect(function()
        invisible = not invisible
        for _, part in pairs(parts) do
            part.Transparency = invisible and 0.5 or 0
        end
    end)

    toggleBtn.MouseButton1Click:Connect(function()
        if toggleBtn.Text == "Hide" then
            invisBtn.Visible = false
            toggleBtn.Text = "Show"
            frame.Size = UDim2.new(0, 100, 0, 40)
            toggleBtn.Size = UDim2.new(1, 0, 1, 0)
            toggleBtn.Position = UDim2.new(0, 0, 0, 0)
        else
            invisBtn.Visible = true
            toggleBtn.Text = "Hide"
            frame.Size = UDim2.new(0, 220, 0, 90)
            invisBtn.Size = UDim2.new(0, 100, 0, 40)
            invisBtn.Position = UDim2.new(0, 10, 0, 25)
            toggleBtn.Size = UDim2.new(0, 80, 0, 30)
            toggleBtn.Position = UDim2.new(0, 130, 0, 30)
        end
    end)
end

setupCharacter()
createUI()

local connections = {}
connections[1] = player:GetMouse().KeyDown:Connect(function(key)
    if key == "g" then
        invisible = not invisible
        for _, part in pairs(parts) do
            part.Transparency = invisible and 0.5 or 0
        end
    end
end)

connections[2] = game:GetService("RunService").Heartbeat:Connect(function()
    if invisible then
        local cf = rootPart.CFrame
        local camOffset = humanoid.CameraOffset
        local hidden = cf * CFrame.new(0, -200000, 0)
        rootPart.CFrame = hidden
        humanoid.CameraOffset = hidden:ToObjectSpace(CFrame.new(cf.Position)).Position
        game:GetService("RunService").RenderStepped:Wait()
        rootPart.CFrame = cf
        humanoid.CameraOffset = camOffset
    end
end)

player.CharacterAdded:Connect(function()
    invisible = false
    setupCharacter()
end)

_G.a = connections
