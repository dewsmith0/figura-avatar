if not host:isHost() then return end
local easyWheel = require("./easyWheel")
local mod = {}

mod.emotes = easyWheel:newPage("Emotes", "armor_stand", "#FFC700")
mod.toggles = easyWheel:newPage("Toggles", "lever", "#A23BEC")
return mod