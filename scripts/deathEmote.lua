require("scripts.animation") -- required for loading order (it errors without this)


animLib.deathTime = 0
animLib.isDead = false
local degrees, oldDegrees = 0, 0
local timeDir = 0 -- 1 = dying, -1 = undying, 0 = dead or alive (schrodinger's cat??)
function pings.revive(soundType)
    if timeDir ~= 1 and not animLib.isDead then return end
    animLib.setDead(false, -1)
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
    if timeDir == 1 or animLib.isDead then return end
    models.model:setOverlay(15, 0)
    renderer:setShadowRadius(0)
    timeDir = 1
    --deathTime = 1
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
    if animLib.deathTime == 0 and timeDir == -1 then
        animLib.isDead = false
        timeDir = 0
        models.model:setOverlay()
    end
    if timeDir == 1 then
        if animLib.deathTime == 21 then
            animLib.setDead(true, 0)
            return
        end
    elseif animLib.isDead then timeDir = 0 end
    animLib.deathTime = animLib.deathTime + timeDir
    if (timeDir == 1 and animLib.deathTime == 21) or (timeDir == -1 and animLib.deathTime == 0) then
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
    degrees = math.clamp(math.sqrt((animLib.deathTime - 1 )/ 20 * 1.6), 0, 1) * 90
    degrees = degrees == degrees and degrees or 0
end

function events.render(delta, context, source)
    if timeDir ~= 0 then
        models:setOffsetRot(0, 0, math.lerp(oldDegrees, degrees, delta))
    end
end
animLib.isDead = false

function animLib.setDead(state, dir)
    models.model:setVisible(not state)
    nameplate.ENTITY:setVisible(not state)
    vanilla_model.HELD_ITEMS:setVisible(not state)
    vanilla_model.ARMOR:setVisible(not state)
    if state then 
        timeDir = 0 
        animLib.isDead = true
        degrees = 90
    elseif dir == -1 then timeDir = -1 animLib.isDead = false end
    if not state and timeDir == 0 then animLib.isDead = false degrees = 0 end

    --print(deathTime, timeDir)
    --print("new", deathTime, timeDir)
end

-- function animLib.setDeathTime(time)
--     deathTime = time
-- end
function deathDebug()
    print("isDead:", animLib.isDead)
    print("deathTime:", animLib.deathTime)
    print("degrees (old/now):", oldDegrees, degrees)
    print("timeDir", timeDir)
end
