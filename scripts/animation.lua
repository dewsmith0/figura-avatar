local oldSitting = false

function events.render() 
    if not player:isLoaded() then return end
    local sitting = player:getVehicle() ~= nil
    if oldSitting ~= sitting then 
        if sitting then 
            pings.sit(true, true)
            animations.model.sit:stop()
        else 
            pings.sit(false, true)
            animations.model.sit:stop()
        end
        oldSitting = sitting    
    end
end

function events.tick() 
    -- disable gaze while using spyglass
    mainGaze:setTargetOverride((
    (player:getHeldItem():getID() == "minecraft:spyglass" or player:getHeldItem(true):getID() == "minecraft:spyglass") and player:isUsingItem()) and vec(0,0) or nil)
    
end

animLib = {}
animLib.isRadioactive = false
function animLib.setRadioactive(state)
    if state then 
        models.model.root:setPrimaryColor(0,1,0)
        animLib.isRadioactive = true
    else
        models.model.root:setPrimaryColor()
        animLib.isRadioactive = false
    end
end

-- animLib.isDead, , animLib.setDead() in deathEmote.lua