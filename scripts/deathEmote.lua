local deathTime = 0
local deathState = "none"
local degrees, oldDegrees = 0, 0
local timeDir = 0
function pings.revive(soundType)
    if deathState == "undying" or deathState == "none" then return end
    deathState = "undying"
    nameplate.ENTITY:setVisible(true)
    models.model:setVisible(true)
    vanilla_model.HELD_ITEMS:setVisible(true)
    vanilla_model.ARMOR:setVisible(true)
    renderer:setShadowRadius(0)
    local sound, soundPitch, soundVolume
    if soundType == 1 then 
        sound = "block.beacon.activate"
        soundPitch = 2
        soundVolume = 1
    elseif soundType == 2 then
        sound = "sounds.pmowoob"
        soundPitch = 1
        soundVolume = 1
    elseif soundType == 3 then 
        sound = "item.totem.use"
        soundPitch = 1
        soundVolume = 0.2
    else return end
    if not player:isLoaded() then return end
    sounds[sound]
        :pos(player:getPos())
        :volume(soundVolume)
        :pitch(soundPitch)
        :subtitle("Dewsmith comes back from the dead")
        :play()
end

function pings.die(soundType)
    if deathState == "dying" or deathState == "dead" then return end
    models.model:setOverlay(15, 0)
    renderer:setShadowRadius(0)
    deathState = "dying"
    deathTime = 1
    local sound = "entity.player.death"
    if soundType == 1 or soundType == 3 then sound = "entity.player.death"
    elseif soundType == 2 then sound = "sounds.boowomp" 
    else return end
    if not player:isLoaded() then return end
    sounds[sound]
        :pos(player:getPos())
        :volume(1)
        :pitch(1)
        :subtitle("Dewsmith dies")
        :play()
    end
function events.tick()
    if deathTime == 0 and deathState == "undying" then
        deathState = "none"
        models.model:setOverlay()
    end
    if deathState == "dying" then
        timeDir = 1
        if deathTime == 21 then
            models.model:setVisible(false)
            nameplate.ENTITY:setVisible(false)
            vanilla_model.HELD_ITEMS:setVisible(false)
            vanilla_model.ARMOR:setVisible(false)
            deathState = "dead"
            return
        end
    elseif deathState == "undying" then
        timeDir = -1

    elseif deathState == "dead" then timeDir = 0
    else return end
    deathTime = deathTime + timeDir
    if (deathState == "dying" and deathTime == 21) or (deathState == "undying" and deathTime == 0) then
        for _ = 0, 19 do
            local velX = math.random(0.2, 0.9) * timeDir
            local velY = math.random(0.2, 0.9) * timeDir
            local velZ = math.random(0.2, 0.9) * timeDir
            local pos = player:getPos():add(
                math.random(-0.5, 0.5),
                math.random(0, 1),
                math.random(-0.5, 0.5)
            )
            particles:newParticle("minecraft:poof", pos, velX, velY, velZ)
        end
    end
    oldDegrees = degrees
    degrees = math.clamp(math.sqrt((deathTime - 1 )/ 20 * 1.6), 0, 1) * 90
    degrees = degrees == degrees and degrees or 0
end

function events.render(delta, context, source)
    if deathState == "dying" or deathState == "undying" then
        models:setOffsetRot(0, 0, math.lerp(oldDegrees, degrees, delta))
    end
end



function deathDebug()
    print("deathState:", deathState)
    print("deathTime:", deathTime)
    print("degrees (old/now):", oldDegrees, degrees)
end
