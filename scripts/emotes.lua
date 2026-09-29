local easyWheel = require("libraries.easyWheel")
local soundEffects = require("./soundEffects")

local isSitting = false
local isSittingInVehicle = false
local isWagging = false
-- isRadioactive and isDead are in animLib 
-------------------------------- CARRY OUT ACTIONS ---------------------------- 

local function doSit(state, isVehicle)
    animations.model[isVehicle and "sitCommand" or "sit"]:setPlaying(state)
    if animations.model.sit:isPlaying() and animations.model.sitCommand:isPlaying() then animations.model.sit:stop() end
    isSitting = state
    isSittingInVehicle = isVehicle
end
local function doWag(state) tail.config.enableWag.emote = state isWagging = state end



-------------------------------- THE ACTUAL PINGS -----------------------------
function pings.meow () 
    if player:isLoaded() then 
        soundEffects.getMeowSound():play()
        animations.model.msgsend:play()
    end
end

function pings.purr () if player:isLoaded() then soundEffects.getPurrSound():play() end end

function pings.hiss () if player:isLoaded() then sounds:playSound("entity.cat.hiss",player:getPos()) end end

function pings.wawa ()
    if player:isLoaded() then 
        soundEffects.getWawaSound():play() 
        animations.model.msgsend:play()
    end
end

function pings.eatUranium ()
    if player:isLoaded() then
        animations.model.eatUranium:play()
    end
end

function pings.reset ()
    animLib.setRadioactive(false)
    --	models.model.root:setSecondaryRenderType()
    renderer:setPostEffect()
end

function pings.sit(state, isVehicle) doSit(state, isVehicle) end
function pings.wagTail(state) doWag(state) end


    
-- function pings.safeguards()
--     if player:isLoaded() then
--         local safeguards = sounds["safeguards"]:setSubtitle("Reactor core safeguards are now non-functional."):pos(player:getPos())
--         safeguards:play()
--     end
-- end
-------------------------------- RESYNC ---------------------------------------
function pings.resync(sitting, sittingVehicle, wagging, radioactive, dead)
    doSit(sitting, sittingVehicle)
    doWag(wagging)
    animLib.setRadioactive(radioactive)
    animLib.setDead(dead)
end
--============================== HOST ONLY ====================================
if not host:isHost() then return end 
-------------------------------- EVENTS ---------------------------------------
local resyncTimer = 0
function events.tick()
    if player:getGamemode() == "SPECTATOR" then return end
    if math.random(20000) == 1 then
        pings.meow()
    end
    resyncTimer = resyncTimer + 1    if resyncTimer == 100 then 
        pings.resync(isSitting, isSittingInVehicle, isWagging, animLib.isRadioactive, animLib.isDead)
        resyncTimer = 0
    end
end


-------------------------------- KEYBINDS -------------------------------------
local meowKey = keybinds:newKeybind("meow", "key.keyboard.m"):onPress(pings.meow)
local wawakey = keybinds:newKeybind("wawa", "key.keyboard.y"):onPress(pings.wawa)

-------------------------------- ACTION WHEEL STUFF ---------------------------
local emotesPage = require("./pages").emotes

local boowompState = 1
local boowompStates = {"Normal", "Boowomp", "Totem", "None"}

local dieAction = easyWheel.newAction(emotesPage, easyWheel.getScrollTitle(boowompState, boowompStates, "Die [LC] / Revive [RC] / Change Death Sound [Scroll]"), "minecraft:skeleton_skull", "#FF0000")
dieAction.leftClick = function() pings.die(boowompState) end
dieAction.rightClick = function() pings.revive(boowompState) end
dieAction.scroll = function(dir)
    boowompState = easyWheel.getNextScrollOption(boowompState, boowompStates, dir)
    dieAction:setTitle(easyWheel.getScrollTitle(boowompState, boowompStates, "Die [LC] / Revive [RC] / Change Death Sound [Scroll]"))
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
sitAction.leftClick = function () pings.sit(true, player:getVehicle()) end
sitAction.rightClick = function () pings.sit(false, player:getVehicle()) end

local wagAction = easyWheel.newAction(emotesPage, "[LC] Start wagging tail\n[RC] Stop wagging tail", "minecraft:ink_sac", "#7f007f")
wagAction.leftClick = function () pings.wagTail(true) end
wagAction.rightClick = function () pings.wagTail(false) end