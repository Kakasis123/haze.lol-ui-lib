getgenv().DNS = {
    Camlock = {
        Main = {
            Enabled = true,
            Key = "V",
            Smoothness = 1,
            Prediction = 0.1345,
            Shake = false,
            ShakeValue = 15,
            Parts = {"HumanoidRootPart"}
        },
        FOV = {
            ShowFOV = true,
            Radius = 25,
            Color = Color3.fromRGB(0, 71, 171),
            Filled = false,
            Transparency = 1
        }
    },
    Silent = {
        Main = {
            Enabled = true,
            Mode = "Fov",
            Prediction = 0.155,
            Parts = {"Head","UpperTorso"}
        },
        FOV = {
            ShowFOV = false,
            Radius = 500,
            Color = Color3.fromRGB(0, 71, 171),
            Filled = false,
            Transparency = 1
        }
    },
}

local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local plrs = game:GetService("Players")
local ws = game:GetService("Workspace")
local rps = game:GetService("ReplicatedStorage")

local vect2 = Vector2.new
local lplr = plrs.LocalPlayer
local m = lplr:GetMouse()
local c = ws.CurrentCamera

local cfov = Drawing.new("Circle")
cfov.Visible = getgenv().DNS.Camlock.FOV.ShowFOV
cfov.Thickness = 1
cfov.NumSides = 30
cfov.Radius = getgenv().DNS.Camlock.FOV.Radius * 3
cfov.Color = getgenv().DNS.Camlock.FOV.Color
cfov.Filled = getgenv().DNS.Camlock.FOV.Filled
cfov.Transparency = getgenv().DNS.Camlock.FOV.Transparency

local sfov = Drawing.new("Circle")
sfov.Visible = getgenv().DNS.Silent.FOV.ShowFOV
sfov.Thickness = 1
sfov.NumSides = 30
sfov.Radius = getgenv().DNS.Silent.FOV.Radius * 3
sfov.Color = getgenv().DNS.Silent.FOV.Color
sfov.Filled = getgenv().DNS.Silent.FOV.Filled
sfov.Transparency = getgenv().DNS.Silent.FOV.Transparency

local dns = {functions = {}}
local ctarg = nil
local starg = nil
local cfound = nil
dns.functions.newConnection = function(event, callback)
    local connection = event:Connect(callback)
    return {
        Connection = connection,
        Disconnect = function()
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    }
end

dns.functions.updateFOV = function()
    cfov.Radius = getgenv().DNS.Camlock.FOV.Radius * 3
    cfov.Visible = getgenv().DNS.Camlock.FOV.ShowFOV
    cfov.Filled = getgenv().DNS.Camlock.FOV.Filled
    cfov.Position = vect2(m.X, m.Y + 36)

    sfov.Radius = getgenv().DNS.Silent.FOV.Radius * 3
    sfov.Visible = getgenv().DNS.Silent.FOV.ShowFOV
    sfov.Filled = getgenv().DNS.Silent.FOV.Filled
    sfov.Position = vect2(m.X, m.Y + 36)
end

dns.functions.closestToMouse = function()
    local closestPlayer
    local closestDistance = math.huge

    for _, player in pairs(plrs:GetPlayers()) do
        if player ~= lplr and player.Character then
            for _, partName in ipairs(getgenv().DNS.Camlock.Main.Parts) do
                local part = player.Character:FindFirstChild(partName)
                if part then
                    local screenPoint = c:WorldToScreenPoint(part.Position)
                    local distance = (vect2(screenPoint.X, screenPoint.Y) - uis:GetMouseLocation()).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

dns.functions.findAimbotPart = function(target)
    local closestPart = nil
    local closestDistance = math.huge

    for _, partName in ipairs(getgenv().DNS.Camlock.Main.Parts) do
        local part = target.Character:FindFirstChild(partName)
        if part then
            local screenPoint = c:WorldToScreenPoint(part.Position)
            local distance = (vect2(screenPoint.X, screenPoint.Y) - uis:GetMouseLocation()).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestPart = part
            end
        end
    end

    return closestPart
end

dns.functions.newConnection(m.KeyDown, function(Key)
    pcall(function()
        if Key:lower() == getgenv().DNS.Camlock.Main.Key:lower() and getgenv().DNS.Camlock.Main.Enabled then
            cfound = not cfound
            ctarg = cfound and dns.functions.closestToMouse() or nil
        end
    end)
end)

dns.functions.newConnection(rs.RenderStepped, function()
    if ctarg and ctarg.Character and getgenv().DNS.Camlock.Main.Enabled then
        local cpart = dns.functions.findAimbotPart(ctarg)

        if cpart then
            local targetVelocity = cpart.Velocity * getgenv().DNS.Camlock.Main.Prediction
            local targetPosition = cpart.Position + targetVelocity

            local mainCF = CFrame.new(c.CFrame.p, targetPosition)
            c.CFrame = c.CFrame:Lerp(mainCF, getgenv().DNS.Camlock.Main.Smoothness, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

            if getgenv().DNS.Camlock.Main.Shake then
                local shakeOffset = Vector3.new(
                    math.random(-getgenv().DNS.Camlock.Main.ShakeValue, getgenv().DNS.Camlock.Main.ShakeValue),
                    math.random(-getgenv().DNS.Camlock.Main.ShakeValue, getgenv().DNS.Camlock.Main.ShakeValue),
                    math.random(-getgenv().DNS.Camlock.Main.ShakeValue, getgenv().DNS.Camlock.Main.ShakeValue)
                )
                c.CFrame = c.CFrame * CFrame.new(shakeOffset * 0.1)
            end
        end
    end
    dns.functions.updateFOV()
end)

dns.functions.closestInFov = function()
    local closestPlayer
    local closestDistance = math.huge

    for _, player in pairs(plrs:GetPlayers()) do
        if player ~= lplr and player.Character then
            for _, partName in ipairs(getgenv().DNS.Silent.Main.Parts) do
                local part = player.Character:FindFirstChild(partName)
                if part then
                    local screenPoint = c:WorldToScreenPoint(part.Position)
                    local distance = (vect2(screenPoint.X, screenPoint.Y) - uis:GetMouseLocation()).Magnitude
                    if sfov.Radius > distance and distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

dns.functions.findSilentPart = function(target)
    local closestPart = nil
    local closestDistance = math.huge

    for _, partName in ipairs(getgenv().DNS.Silent.Main.Parts) do
        local part = target.Character:FindFirstChild(partName)
        if part then
            local screenPoint = c:WorldToScreenPoint(part.Position)
            local distance = (vect2(screenPoint.X, screenPoint.Y) - uis:GetMouseLocation()).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestPart = part
            end
        end
    end

    return closestPart
end

local function silent()
    if not getgenv().DNS.Silent.Main.Enabled then
        return
    end

    local predictionMultiplier = getgenv().DNS.Silent.Main.Prediction
    local starg

    if getgenv().DNS.Silent.Main.Mode == "FOV" then
        starg = dns.functions.closestInFov()
    elseif getgenv().DNS.Silent.Main.Mode == "Target" then
        starg = ctarg
    end

    if not starg or not starg.Character then
        return
    end

    local targetPart = dns.functions.findSilentPart(starg)
    if not targetPart or not targetPart.Velocity then
        return
    end

    local velocity = targetPart.Velocity
    local endpoint = targetPart.Position + (velocity * predictionMultiplier)

    local methods = {}
    if game.PlaceId == 9825515356 then
        methods = {"MousePosUpdate"}
        endpoint = endpoint + Vector3.new(25, 100, 25)
    elseif game.PlaceId == 2788229376 then
        methods = {"UpdateMousePosI2"}
    else
        methods = {"UpdateMousePos"}
    end

    pcall(function()
        for _, method in ipairs(methods) do
            rps.MainEvent:FireServer(method, endpoint)
        end
    end)
end

local function connectTool(tool)
    if tool and tool:IsA("Tool") then
        dns.functions.newConnection(tool.Activated, function()
            silent()
        end)
    end
end

local function connectCharacter(character)
    for _, tool in ipairs(character:GetChildren()) do
        connectTool(tool)
    end
    dns.functions.newConnection(character.ChildAdded, function(child)
        if child:IsA("Tool") then
            connectTool(child)
        end
    end)
end

local function connectPlayer(player)
    dns.functions.newConnection(player.CharacterAdded, function(character)
        connectCharacter(character)
    end)
    if player.Character then
        connectCharacter(player.Character)
    end
end

dns.functions.newConnection(plrs.PlayerAdded, connectPlayer)

for _, player in ipairs(plrs:GetPlayers()) do
    connectPlayer(player)
end

if lplr.Character then
    connectCharacter(lplr.Character)
end
dns.functions.newConnection(lplr.CharacterAdded, connectCharacter)