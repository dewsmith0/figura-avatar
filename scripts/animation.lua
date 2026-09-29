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