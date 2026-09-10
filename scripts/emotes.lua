local easyWheel = require("./easyWheel")
local soundEffects = require("./soundEffects")

-------------------------------- THE ACTUAL PINGS -----------------------------
pings.meow = function () if player:isLoaded() then soundEffects.genMeowSound():play() end end

pings.purr = function () if player:isLoaded() then soundEffects.getPurrSound():play() end end

pings.hiss = function () if player:isLoaded() then sounds:playSound("entity.cat.hiss",player:getPos()) end end
function pings.eatUranium ()
    if player:isLoaded() then
        animations.model.eatUranium:play()
    end
end

function pings.reset ()
    if player:isLoaded() then
        models.model.root:setPrimaryColor()
        models.model.root:setPrimaryTexture("PRIMARY")
        --	models.model.root:setSecondaryRenderType()
        renderer:setPostEffect()
    end
end

function pings.sit(state, isVehicle)
    animations.model[isVehicle and "sitCommand" or "sit"]:setPlaying(state)
    if animations.model.sit:isPlaying() and animations.model.sitCommand:isPlaying() then animations.model.sit:stop() end
end

-- function pings.safeguards()
--     if player:isLoaded() then
--         local safeguards = sounds["safeguards"]:setSubtitle("Reactor core safeguards are now non-functional."):pos(player:getPos())
--         safeguards:play()
--     end
-- end
-------------------------------- EVENTS ---------------------------------------

function events.tick()
    if player:getGamemode() == "SPECTATOR" then return end
    if math.random(20000) == 1 then
        pings.meow()
    end
end

if not host:isHost() then return end -- 
-------------------------------- KEYBINDS -------------------------------------
local meowKey = keybinds:newKeybind("meow", "key.keyboard.m")
meowKey.press = pings.meow

-------------------------------- ACTION WHEEL STUFF ---------------------------
local emotesPage = require("./pages").emotes

local boowompState = 1
local boowompStates = {"Normal", "Boowomp", "None"}
local dieBoowomp = false
local dieAction = easyWheel.newAction(emotesPage, easyWheel.getScrollTitle(boowompState, boowompStates, "Die [LC] / Undie [RC] / Change Death Sound [Scroll]"), "minecraft:skeleton_skull", "#FF0000")
dieAction.leftClick = function() pings.die(boowompState) end
dieAction.rightClick = function() pings.undie(boowompState) end
dieAction.scroll = function(dir)
    boowompState = easyWheel.getNextScrollOption(boowompState, boowompStates, dir)
    dieAction:setTitle(easyWheel.getScrollTitle(boowompState, boowompStates, "Die [LC] / Undie [RC] / Change Death Sound [Scroll]"))
end

local meowAction = easyWheel.newAction(emotesPage, "Meow", "minecraft:string", "#ff00ff")
meowAction.leftClick = pings.meow
meowAction.rightClick = pings.meow

local purrAction = easyWheel.newAction(emotesPage, "Purr", "minecraft:lime_dye","#ff7c00")
purrAction.leftClick = pings.purr

local uraniumAction = easyWheel.newAction(emotesPage, "[LC] can't say uranium without yum\n[RC] reset uranium", "minecraft:emerald", "#00FF00")
uraniumAction.leftClick = pings.eatUranium
uraniumAction.rightClick = pings.reset


local sitAction = easyWheel.newAction(emotesPage, "[LC] Sit \n[RC] Unsit", "minecraft:oak_stairs", "#cccc00")
sitAction.leftClick = function () pings.sit(true) end
sitAction.rightClick = function () pings.sit(false) end