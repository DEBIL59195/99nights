loadstring(game:HttpGet("https://raw.githubusercontent.com/Rx1m/CpsHub/refs/heads/main/99%20days%20at%20the%20forest%20Diamond%20Farm"))()
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- ÐÐ°ÑÑÑÐ¾Ð¹ÐºÐ¸
local SETTINGS = {
    GAME_ID = 126509999114328,
    PASTEFY_URL = "https://raw.githubusercontent.com/DEBIL59195/99nights/refs/heads/main/server.lua",
    COOLDOWN_TIME = 5 * 60,
    COUNTDOWN_TIME = 2,
    ERROR_RETRY_DELAY = 3,  -- 3 ÑÐµÐºÑÐ½Ð´Ñ Ð¿ÑÐ¸ Ð¾ÑÐ¸Ð±ÐºÐµ
    SUCCESS_DELAY = 7      -- 6 ÑÐµÐºÑÐ½Ð´ Ð¿ÑÐ¸ ÑÑÐ¿ÐµÑÐµ
}

-- Ð¥ÑÐ°Ð½Ð¸Ð»Ð¸ÑÐµ Ð´Ð°Ð½Ð½ÑÑ
local SERVER_LIST = {}
local BLACKLIST = {}
local SHOW_COUNTDOWN = true

-- Ð¡Ð¾Ð·Ð´Ð°Ð½Ð¸Ðµ GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportStatusGUI"
screenGui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 120)
frame.Position = UDim2.new(0.5, -125, 1, -130)
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "AUTO TELEPORT"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 60)
status.Position = UDim2.new(0, 10, 0, 35)
status.BackgroundTransparency = 1
status.Text = "ÐÐ°Ð³ÑÑÐ·ÐºÐ° ÑÐ¿Ð¸ÑÐºÐ° ÑÐµÑÐ²ÐµÑÐ¾Ð²..."
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.TextWrapped = true
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextYAlignment = Enum.TextYAlignment.Top
status.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 20, 0, 20)
closeButton.Position = UDim2.new(1, -25, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
closeButton.BorderSizePixel = 0
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.Parent = frame

local corner2 = Instance.new("UICorner")
corner2.CornerRadius = UDim.new(0, 4)
corner2.Parent = closeButton

-- ÐÐ½Ð¸Ð¼Ð°ÑÐ¸Ñ Ð·Ð°ÐºÑÑÑÐ¸Ñ
closeButton.MouseButton1Click:Connect(function()
    local tween = TweenService:Create(frame, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -125, 1, 130)})
    tween:Play()
    tween.Completed:Wait()
    screenGui:Destroy()
end)

-- ÐÐµÑÐµÑÐ°ÑÐºÐ¸Ð²Ð°Ð½Ð¸Ðµ GUI
local dragging = false
local dragStartPos, frameStartPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
        frameStartPos = frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStartPos
        frame.Position = UDim2.new(frameStartPos.X.Scale, frameStartPos.X.Offset + delta.X, 
                                  frameStartPos.Y.Scale, frameStartPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ÐÐ±Ð½Ð¾Ð²Ð»ÐµÐ½Ð¸Ðµ ÑÑÐ°ÑÑÑÐ° Ð² GUI
local function UpdateStatus(text, color)
    status.Text = text
    status.TextColor3 = color or Color3.fromRGB(200, 200, 200)
end

-- ÐÑÐ¾Ð²ÐµÑÐºÐ° Ð²ÑÐµÑ Ð²Ð¾Ð·Ð¼Ð¾Ð¶Ð½ÑÑ Ð¾ÑÐ¸Ð±Ð¾Ðº ÑÐµÐ»ÐµÐ¿Ð¾ÑÑÐ°ÑÐ¸Ð¸
local function IsTeleportError(err)
    local errorStr = tostring(err)
    return string.find(errorStr, "Unauthorized") ~= nil or
           string.find(errorStr, "cannot be joined") ~= nil or
           string.find(errorStr, "Teleport") ~= nil or
           string.find(errorStr, "experience is full") ~= nil or
           string.find(errorStr, "GameFull") ~= nil
end

local function LoadServers()
    local success, response = pcall(function()
        return game:HttpGet(SETTINGS.PASTEFY_URL)
    end)
    
    if not success then 
        UpdateStatus("â ÐÑÐ¸Ð±ÐºÐ° Ð·Ð°Ð³ÑÑÐ·ÐºÐ¸ ÑÐ¿Ð¸ÑÐºÐ° ÑÐµÑÐ²ÐµÑÐ¾Ð²:\n"..tostring(response):sub(1, 100), Color3.fromRGB(255, 100, 100))
        return {}
    end
    
    local servers = {}
    for serverId in string.gmatch(response, "([a-f0-9%-]+)") do
        table.insert(servers, serverId)
    end
    return servers
end

local function IsServerAvailable(serverId)
    if not BLACKLIST[serverId] then return true end
    return (os.time() - BLACKLIST[serverId]) > SETTINGS.COOLDOWN_TIME
end

local function TryTeleport(target)
    if SHOW_COUNTDOWN then
        for i = SETTINGS.COUNTDOWN_TIME, 1, -1 do
            UpdateStatus("ð ÐÐ¾Ð´ÐºÐ»ÑÑÐµÐ½Ð¸Ðµ ÑÐµÑÐµÐ· "..i.." ÑÐµÐº...", Color3.fromRGB(255, 255, 150))
            task.wait(1)
        end
        SHOW_COUNTDOWN = false
    end
    
    UpdateStatus("ð ÐÐ¾Ð´ÐºÐ»ÑÑÐµÐ½Ð¸Ðµ Ðº ÑÐµÑÐ²ÐµÑÑ...", Color3.fromRGB(150, 255, 150))
    
    local success, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(
            SETTINGS.GAME_ID,
            target,
            Players.LocalPlayer
        )
    end)
    
    if not success then
        if IsTeleportError(err) then
            UpdateStatus("â ÐÑÐ¸Ð±ÐºÐ°:\n"..tostring(err):match("^[^\n]+"):sub(1, 100), Color3.fromRGB(255, 100, 100))
        else
            UpdateStatus("â  ÐÐµÐ¸Ð·Ð²ÐµÑÑÐ½Ð°Ñ Ð¾ÑÐ¸Ð±ÐºÐ°:\n"..tostring(err):match("^[^\n]+"):sub(1, 100), Color3.fromRGB(255, 150, 100))
        end
        BLACKLIST[target] = os.time()
        UpdateStatus("â³ ÐÐ¾Ð²ÑÐ¾Ñ ÑÐµÑÐµÐ· "..SETTINGS.ERROR_RETRY_DELAY.." ÑÐµÐº...", Color3.fromRGB(255, 200, 100))
        task.wait(SETTINGS.ERROR_RETRY_DELAY)
        return false
    end
    
    UpdateStatus("â Ð£ÑÐ¿ÐµÑÐ½Ð¾Ðµ Ð¿Ð¾Ð´ÐºÐ»ÑÑÐµÐ½Ð¸Ðµ!\nÐÐ°Ð²ÐµÑÑÐµÐ½Ð¸Ðµ ÑÐµÑÐµÐ· "..SETTINGS.SUCCESS_DELAY.." ÑÐµÐº...", Color3.fromRGB(100, 255, 100))
    task.wait(SETTINGS.SUCCESS_DELAY)
    return true
end

local function TeleportLoop()
    while true do
        SERVER_LIST = LoadServers()
        if #SERVER_LIST == 0 then
            UpdateStatus("â  Ð¡Ð¿Ð¸ÑÐ¾Ðº ÑÐµÑÐ²ÐµÑÐ¾Ð² Ð¿ÑÑÑ\nÐÐ¾Ð²ÑÐ¾Ñ ÑÐµÑÐµÐ· 10 ÑÐµÐº...", Color3.fromRGB(255, 200, 100))
            task.wait(10)
        else
            UpdateStatus("â ÐÐ¾ÑÑÑÐ¿Ð½Ð¾ ÑÐµÑÐ²ÐµÑÐ¾Ð²: "..#SERVER_LIST, Color3.fromRGB(150, 255, 150))
            break
        end
    end
    
    while true do
        local available = {}
        for _, serverId in ipairs(SERVER_LIST) do
            if IsServerAvailable(serverId) then
                table.insert(available, serverId)
            end
        end
        
        if #available == 0 then
            UpdateStatus("â³ ÐÑÐµ ÑÐµÑÐ²ÐµÑÑ Ð½Ð° ÐºÐ´\nÐÐ¶Ð¸Ð´Ð°Ð½Ð¸Ðµ "..SETTINGS.COOLDOWN_TIME.." ÑÐµÐº...", Color3.fromRGB(255, 200, 100))
            SHOW_COUNTDOWN = true
            task.wait(SETTINGS.COOLDOWN_TIME)
            SERVER_LIST = LoadServers()
        else
            local target = available[math.random(1, #available)]
            UpdateStatus("ð ÐÐ¾Ð¿ÑÑÐºÐ° Ð¿Ð¾Ð´ÐºÐ»ÑÑÐµÐ½Ð¸Ñ Ðº:\n"..target:sub(1, 8).."...", Color3.fromRGB(200, 200, 255))
            
            if TryTeleport(target) then
                UpdateStatus("ð Ð£ÑÐ¿ÐµÑÐ½Ð¾Ðµ Ð¿Ð¾Ð´ÐºÐ»ÑÑÐµÐ½Ð¸Ðµ!", Color3.fromRGB(100, 255, 100))
                break
            end
        end
    end
end

-- ÐÑÐ½Ð¾Ð²Ð½Ð¾Ð¹ ÑÐ¸ÐºÐ»
while true do
    local success, err = pcall(TeleportLoop)
    if not success then
        UpdateStatus("ð ÐÑÐ¸ÑÐ¸ÑÐµÑÐºÐ°Ñ Ð¾ÑÐ¸Ð±ÐºÐ°:\n"..tostring(err):sub(1, 100), Color3.fromRGB(255, 100, 100))
        SHOW_COUNTDOWN = true
        task.wait(5)
    end
end
