if not host:isHost() then return end
local easyWheel = require("./easyWheel")
local mod = {}

mod.nametag = easyWheel:newPage("Nametag", "name_tag", "#aa00aa")
mod.toggles = easyWheel:newPage("Toggles", "lever", "#A23BEC")
mod.emotes = easyWheel:newPage("Emotes", "armor_stand", "#FFC700")
return mod