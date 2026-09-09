local patpat = require ("scripts.patpat")
local tailPhysics = require("scripts.tail")
local earsPhysics = require('scripts.ears')
local soundEffects= require('scripts.soundEffects')

--hide vanilla model
vanilla_model.PLAYER:setVisible(false)
vanilla_model.CAPE:setVisible(false)

--local midiPlayer = require("midiPlayerClient")

--if host:isHost() then midiPlayer:addMidiPlayer(page) end

local tail = tailPhysics.new(models.model.root.Body.Tail1)

tail:setConfig {
    idleSpeed = vec(0.025, 0.1, 0), -- how fast should tail move when nothing is happening
    idleStrength = vec(1, 4, 0), -- how much should tail move
    rotVelocityStrength = 1,
}


local ears = earsPhysics.new(models.model.root.Head.Ears.LeftEar, models.model.root.Head.Ears.RightEar)
ears:setConfig {
    -- you can check ears.lua to see default config
}

table.insert(patpat.oncePat, function ()
    soundEffects.getPatSound():
    play()
end)
--hisswords = {}




--- stupid stuff
pings.maybe = function() printJson('[{"color":"blue","text":"[lua] "},{"color":"white","text":"Dewsmith"},{"color":"blue","text":" : "},{"color":"#A155DA","text":"maybe"},"\n"]') end
