--                          ██╗  ██╗███████╗ ██╗███████╗███████╗██████╗  ██████╗ 
--                          ██║ ██╔╝██╔════╝███║╚══███╔╝██╔════╝██╔══██╗██╔═████╗
--                          █████╔╝ ███████╗╚██║  ███╔╝ █████╗  ██████╔╝██║██╔██║
--                          ██╔═██╗ ╚════██║ ██║ ███╔╝  ██╔══╝  ██╔══██╗████╔╝██║
--                          ██║  ██╗███████║ ██║███████╗███████╗██║  ██║╚██████╔╝
--                          ╚═╝  ╚═╝╚══════╝ ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ 
--                                   donation: https://boosty.to/ks1zer0

local lastShotTime = {}
local shotCooldown = 0.01
local activeTracers = {}
local tracerIDCounter = 0
local TRACER_SETTINGS = {
    MAX_TRACERS_PER_PLAYER = 20,
    UPDATE_INTERVAL = 0.0,
}

hook.Add("OnEntityCreated", "ClientMuzzleFlashDetect", function(ent)
    timer.Simple(0, function()
        if not IsValid(ent) then return end
        
        local class = ent:GetClass()
        if class == "class CLuaEffect" then
            local pos = ent:GetPos()

            for _, ply in ipairs(player.GetAll()) do
                if not IsValid(ply) then continue end
                if not isTfaWeapon(ply) then continue end
                
                if lastShotTime[ply] and CurTime() - lastShotTime[ply] < shotCooldown then
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
                    
                    if playerTracers >= TRACER_SETTINGS.MAX_TRACERS_PER_PLAYER then
                        continue
                    end
                    
                    CreateOptimizedTracerEffect(muzzlePos, ply:EyeAngles():Forward(), ply)
                    break
                end
            end
        end
    end)
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
        speed = 7000,
        startTime = CurTime(),
        dieTime = CurTime() + 1.5,
        color = Color(255, 200, 100),
        baseID = baseID,
        player = shooter
    }
end

local lastThink = 0
hook.Add("Think", "UpdateTracersOptimized", function()
    if CurTime() - lastThink < TRACER_SETTINGS.UPDATE_INTERVAL then return end
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
            dlight_bullet.brightness = 1
            dlight_bullet.Size = 100
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

