local patpat = require ("libraries.patpat")
local tailPhysics = require("libraries.tail")
local earsPhysics = require('libraries.ears')
local soundEffects= require('scripts.soundEffects')
local gaze = require("libraries.Gaze")

--hide vanilla model
vanilla_model.PLAYER:setVisible(false)
vanilla_model.CAPE:setVisible(false)

--local midiPlayer = require("midiPlayerClient")

--if host:isHost() then midiPlayer:addMidiPlayer(page) end

tail = tailPhysics.new(models.model.root.Body.Tail1)

tail:setConfig {
    idleSpeed = vec(0.025, 0.1, 0), -- how fast should tail move when nothing is happening
    idleStrength = vec(1, 4, 0), -- how much should tail move
    rotVelocityStrength = 1,
}


ears = earsPhysics.new(models.model.root.Head.Ears.LeftEar, models.model.root.Head.Ears.RightEar)
ears:setConfig {
    -- you can check ears.lua to see default config
}

local mainGaze = gaze:newGaze()
mainGaze:newAnim(animations.model.LookHorizontal, animations.model.LookVertical)
mainGaze:newBlink(animations.model.Blink) 


table.insert(patpat.oncePat, function ()
    soundEffects.getPatSound():play()
    animations.model.pat:stop():play()
    tail.config.enableWag.pat = true
end)

table.insert(patpat.onUnpat, function ()
    tail.config.enableWag.pat = false
end)


--- stupid stuff
function pings.maybe() printJson('[{"color":"blue","text":"[lua] "},{"color":"white","text":"Dewsmith"},{"color":"blue","text":" : "},{"color":"#A155DA","text":"maybe"},"\n"]') end
