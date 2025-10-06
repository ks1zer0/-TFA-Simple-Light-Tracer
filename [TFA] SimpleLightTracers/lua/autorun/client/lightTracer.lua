--                          ██╗  ██╗███████╗ ██╗███████╗███████╗██████╗  ██████╗ 
--                          ██║ ██╔╝██╔════╝███║╚══███╔╝██╔════╝██╔══██╗██╔═████╗
--                          █████╔╝ ███████╗╚██║  ███╔╝ █████╗  ██████╔╝██║██╔██║
--                          ██╔═██╗ ╚════██║ ██║ ███╔╝  ██╔══╝  ██╔══██╗████╔╝██║
--                          ██║  ██╗███████║ ██║███████╗███████╗██║  ██║╚██████╔╝
--                          ╚═╝  ╚═╝╚══════╝ ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ 
--                                   donation: https://boosty.to/ks1zer0

local lastShotTime = {}
local activeTracers = {}
local tracerIDCounter = 0

local tracerConfig = {
    enabled = true,
    color = Color(255, 200, 100),
    brightness = 1,
    size = 100,
    speed = 7000,
    shotCooldown = .01,
    MAX_TRACERS_PER_PLAYER = 20,
    UPDATE_INTERVAL = 0,
}

function LoadTracerConfig()
    if file.Exists("tracer_config.txt", "DATA") then
        local configData = file.Read("tracer_config.txt", "DATA")
        local loadedConfig = util.JSONToTable(configData)
        if loadedConfig then
            tracerConfig = loadedConfig
            if loadedConfig.color and type(loadedConfig.color) == "table" then
                tracerConfig.color = Color(loadedConfig.color.r, loadedConfig.color.g, loadedConfig.color.b)
            end
        end
    end
end

function SaveTracerConfig()
    local saveConfig = table.Copy(tracerConfig)
    saveConfig.color = {
        r = tracerConfig.color.r,
        g = tracerConfig.color.g, 
        b = tracerConfig.color.b
    }
    file.Write("tracer_config.txt", util.TableToJSON(saveConfig))
end

-- Функция создания панели настроек
function CreateTracerCPanel(panel)
    panel:ClearControls()
    local header = panel:Help("Settings tracers")
    local enableCheckbox = panel:CheckBox("Enable tracers", "tracer_enabled")
    enableCheckbox:SetValue(tracerConfig.enabled)
    enableCheckbox.OnChange = function(panel, val)
        tracerConfig.enabled = val
        SaveTracerConfig()
    end
    panel:Help("")
    panel:Help("Color:")
    local redSlider = panel:NumSlider("Red(R)", "tracer_color_r", 0, 255, 0)
    redSlider:SetValue(tracerConfig.color.r)
    redSlider.OnValueChanged = function(panel, value)
        tracerConfig.color.r = math.Round(value)
        SaveTracerConfig()
    end
    local greenSlider = panel:NumSlider("Green(G)", "tracer_color_g", 0, 255, 0)
    greenSlider:SetValue(tracerConfig.color.g)
    greenSlider.OnValueChanged = function(panel, value)
        tracerConfig.color.g = math.Round(value)
        SaveTracerConfig()
    end
    local blueSlider = panel:NumSlider("Blue (B)", "tracer_color_b", 0, 255, 0)
    blueSlider:SetValue(tracerConfig.color.b)
    blueSlider.OnValueChanged = function(panel, value)
        tracerConfig.color.b = math.Round(value)
        SaveTracerConfig()
    end
    local colorPreview = panel:Button("Color preview")
    colorPreview:SetTall(30)
    colorPreview:SetText("")
    colorPreview.Paint = function(me, w, h)
        draw.RoundedBox(4, 0, 0, w, h, tracerConfig.color)
    end
    colorPreview.DoClick = function() end
    panel:Help("")
    panel:Help("View:")
    local brightnessSlider = panel:NumSlider("Bright", "tracer_brightness", 0.1, 4.0, 1)
    brightnessSlider:SetValue(tracerConfig.brightness)
    brightnessSlider:SetTooltip("Adjusts the brightness of the tracer")
    brightnessSlider.OnValueChanged = function(panel, value)
        tracerConfig.brightness = value
        SaveTracerConfig()
    end
    local sizeSlider = panel:NumSlider("Size glow", "tracer_size", 10, 400, 0)
    sizeSlider:SetValue(tracerConfig.size)
    sizeSlider:SetTooltip("Adjusts the glow range")
    sizeSlider.OnValueChanged = function(panel, value)
        tracerConfig.size = value
        SaveTracerConfig()
    end
    local speedSlider = panel:NumSlider("Speed tracer", "tracer_speed", 1000, 20000, 0)
    speedSlider:SetValue(tracerConfig.speed)
    speedSlider:SetTooltip("Adjusts the speed of the tracer")
    speedSlider.OnValueChanged = function(panel, value)
        tracerConfig.speed = value
        SaveTracerConfig()
    end
    local cooldownSlider = panel:NumSlider("Cooldown tracers", "tracer_shotCooldown", 0.01, 0.2, 2)
    cooldownSlider:SetValue(tracerConfig.shotCooldown)
    cooldownSlider:SetTooltip("Spawn cooldown")
    cooldownSlider.OnValueChanged = function(panel, value)
        tracerConfig.shotCooldown = value
        SaveTracerConfig()
    end
    local maxSlider = panel:NumSlider("Maximum tracers simultaneously", "tracer_max", 1, 100, 0)
    maxSlider:SetValue(tracerConfig.MAX_TRACERS_PER_PLAYER)
    maxSlider:SetTooltip("Maximum tracers simultaneously")
    maxSlider.OnValueChanged = function(panel, value)
        tracerConfig.MAX_TRACERS_PER_PLAYER = value
        SaveTracerConfig()
    end
    local updateSlider = panel:NumSlider("Tracer update rate", "tracer_update", 0, 5.0, 2)
    updateSlider:SetValue(tracerConfig.UPDATE_INTERVAL)
    updateSlider:SetTooltip("Regulates the tracer update rate")
    updateSlider.OnValueChanged = function(panel, value)
        tracerConfig.UPDATE_INTERVAL = value
        SaveTracerConfig()
    end
    local resetButton = panel:Button("Reset settings")
    resetButton.DoClick = function()
        tracerConfig = {
            enabled = true,
            color = Color(255, 200, 100),
            brightness = 1,
            size = 100,
            speed = 7000,
            shotCooldown = .01,
            MAX_TRACERS_PER_PLAYER = 20,
            UPDATE_INTERVAL = 0,
        }
        SaveTracerConfig()
        CreateTracerCPanel(panel)
    end
    panel:Help("")
    panel:Help("")
    panel:Help("[EN]")
    panel:Help("Addon was created for the project: TAU | Copy discord link on click button bottom")
    panel:Help("[RU]")
    panel:Help("Дополнение создано для проекта: TAU | Копировать ссылку на Discord-сервер по кнопке внизу")
    local dsBtn = panel:Button("Discord")
    dsBtn:SetTall(50)
    dsBtn:SetText("Discord-link")
    dsBtn.Paint = function(me, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(70, 110, 255, 255))
    end
    dsBtn.DoClick = function(me) 
        SetClipboardText("https://discord.gg/pmWqrC7R8x")
        gui.OpenURL("https://discord.gg/pmWqrC7R8x")
    end

    local function UpdateColorPreview()
        timer.Simple(0.1, function()
            if IsValid(colorPreview) then
                colorPreview:InvalidateLayout()
            end
        end)
    end
    redSlider.OnValueChanged = function(panel, value)
        tracerConfig.color.r = math.Round(value)
        SaveTracerConfig()
        UpdateColorPreview()
    end
    greenSlider.OnValueChanged = function(panel, value)
        tracerConfig.color.g = math.Round(value)
        SaveTracerConfig()
        UpdateColorPreview()
    end
    blueSlider.OnValueChanged = function(panel, value)
        tracerConfig.color.b = math.Round(value)
        SaveTracerConfig()
        UpdateColorPreview()
    end
end


hook.Add("PopulateToolMenu", "AddTracerOptionsToMenu", function()
    spawnmenu.AddToolMenuOption("Utilities", "TFA SWEP Base Settings", "tfaOptionTracer", "[ADD] Glow Tracers", "", "", CreateTracerCPanel)
end)

hook.Add("Initialize", "LoadTracerConfigOnStart", function()
    LoadTracerConfig()
    CreateClientConVar("tracer_enabled", "1", true, false, "Enable tracer", 0, 1)
    CreateClientConVar("tracer_brightness", "1.0", true, false, "Bright tracers", 0.1, 4.0)
    CreateClientConVar("tracer_size", "100", true, false, "Size glow tracers", 10, 400)
    CreateClientConVar("tracer_speed", "7000", true, false, "Speed tracers", 1000, 20000)
    CreateClientConVar("tracer_shotCooldown", "0.01", true, false, "Cooldown tracers", 0.01, 0.2)
    CreateClientConVar("tracer_max", "20", true, false, "Maximum tracers simultaneously", 1, 100)
    CreateClientConVar("tracer_update", "0", true, false, "Tracer update rate", 0, 5.0)
end)

hook.Add("OnEntityCreated", "ClientMuzzleFlashDetect", function(ent)
    if tracerConfig.enabled then
        timer.Simple(0, function()
            if not IsValid(ent) then return end
            
            local class = ent:GetClass()
            if class == "class CLuaEffect" then
                local pos = ent:GetPos()

                for _, ply in ipairs(player.GetAll()) do
                    if not IsValid(ply) then continue end
                    if not isTfaWeapon(ply) then continue end
                    
                    if lastShotTime[ply] and CurTime() - lastShotTime[ply] < tracerConfig.shotCooldown then
                        continue
                    end
                    
                    local muzzlePos = GetMuzzlePosition(ply)
                    if not muzzlePos then continue end

                    if LocalPlayer():GetPos():Distance(muzzlePos) > 5000 then continue end
                    
                    if pos:Distance(muzzlePos) < 40 then
                        lastShotTime[ply] = CurTime()
                        
                        local playerTracers = 0
                        for _, tracer in pairs(activeTracers) do
                            if tracer.player == ply then
                                playerTracers = playerTracers + 1
                            end
                        end
                        
                        if playerTracers >= tracerConfig.MAX_TRACERS_PER_PLAYER then
                            continue
                        end
                        
                        CreateOptimizedTracerEffect(muzzlePos, ply:EyeAngles():Forward(), ply)
                        break
                    end
                end
            end
        end)
    end
end)

function isTfaWeapon(ply)
    local wpn = ply:GetActiveWeapon()

    if not IsValid(wpn) then return false end

    if string.Left(wpn:GetClass(), 3) == "tfa" then return true end

    return false
end

function GetMuzzlePosition(ply)
    local handBone = ply:LookupBone("ValveBiped.Bip01_R_Hand")
    if not handBone then return nil end
    
    local handPos, handAng = ply:GetBonePosition(handBone)
    if not handPos then return nil end
    
    local muzzleOffset = Vector(10, 0, -4)
    return handPos + 
        handAng:Forward() * muzzleOffset.x + 
        handAng:Right() * muzzleOffset.y + 
        handAng:Up() * muzzleOffset.z
end

function CreateOptimizedTracerEffect(startPos, dir, shooter)
    local trace = util.TraceLine({
        start = startPos,
        endpos = startPos + dir * 5000,
        filter = shooter
    })
    
    tracerIDCounter = tracerIDCounter + 1
    local baseID = tracerIDCounter * 1000
    
    activeTracers[baseID] = {
        startPos = startPos,
        endPos = trace.HitPos,
        dir = dir,
        speed = tracerConfig.speed,
        startTime = CurTime(),
        dieTime = CurTime() + 1.5,
        color = tracerConfig.color,
        baseID = baseID,
        player = shooter
    }
end

local lastThink = 0
hook.Add("Think", "UpdateTracersOptimized", function()
    if CurTime() - lastThink < tracerConfig.UPDATE_INTERVAL then return end
    lastThink = CurTime()
    
    for baseID, tracer in pairs(activeTracers) do
        if CurTime() > tracer.dieTime then
            activeTracers[baseID] = nil
            continue
        end
        
        local travelTime = CurTime() - tracer.startTime
        local currentDistance = tracer.speed * travelTime
        local maxDistance = tracer.startPos:Distance(tracer.endPos)
        
        if currentDistance >= maxDistance then
            activeTracers[baseID] = nil
            continue
        end
        
        local currentPos = tracer.startPos + tracer.dir * currentDistance
        
        local dlight_bullet = DynamicLight(baseID)
        if dlight_bullet then
            dlight_bullet.pos = currentPos
            dlight_bullet.r = tracer.color.r
            dlight_bullet.g = tracer.color.g
            dlight_bullet.b = tracer.color.b
            dlight_bullet.brightness = tracerConfig.brightness
            dlight_bullet.Size = tracerConfig.size
            dlight_bullet.Decay = 800
            dlight_bullet.DieTime = CurTime() + 0.05
        end
    end
end)

hook.Add("Tick", "CleanupTracers", function()
    for baseID, tracer in pairs(activeTracers) do
        if CurTime() > tracer.dieTime then
            activeTracers[baseID] = nil
        end
    end
end)

