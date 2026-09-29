local dash=keybinds:newKeybind("dash", "key.keyboard.x")
dash:onPress(function (mod, key) local _ =player:getVehicle() and silly.vehicle:setVelocity(player:getLookDir()*8) or silly:setVelocity(player:getLookDir()*8) end)
