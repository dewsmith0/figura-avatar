local soundEffects = require("scripts.soundEffects")

function events.chat_send_message(msg)
    if not player:isLoaded() then return msg end
    if player:getGamemode() == "SPECTATOR" then return msg end
    if handleEval(msg) then return nil end
    if soundEffects.handleVaritemSound() then return nil end
    if msg:sub(1, 1) == "/" or msg:sub(1, 1) == "@" then
        return msg
    else
        local hissed = false
--         for _, hissword in ipairs(hisswords) do
--             if msg:lower():find(hissword:lower(), 1, true) then
--                 pings.hiss()
--                 hissed = true
--                 break -- found a hiss word, stop checking
--             end
--         end
        if not hissed then pings.meow() end
        return msg
    end
end