if not silly then return end

local dash=keybinds:newKeybind("dash", "key.keyboard.x")
dash:onPress(function (mod, key) local _ =player:getVehicle() and silly.vehicle:setVelocity(player:getLookDir()*2.2) or silly:setVelocity(player:getLookDir()*2.2*math.clamp(mod, 1, 99)) end)
