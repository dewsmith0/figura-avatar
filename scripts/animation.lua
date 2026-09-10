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