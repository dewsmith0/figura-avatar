local afk = require("libraries.afk")
-- -- stolen from boxxie (she gave it to me)

local warningParent = models.model.root.Head.Camera.LocalWarning
local localWarning = warningParent:newText("localWarning")
    :setText('{"color":"#FFAAAA","text":":cloud::back::no_entry: currently local","italic": true}')
    :setScale(0.5)
    :setAlignment("CENTER")
    :setVisible(false)

-- stolen from boxxie79 (she gave it to me)
local c = 200
function pings.updateLocal() c = 200 end
local _isLocal = false
function events.tick() 

    if c > 0 then
        c = c - 1
        _isLocal = false
    elseif c == 0 then
        _isLocal = true
        if not host:isHost() then
            appearance.setAfkEmoji(":cloud::back::no_entry:") afk.afkFunc() 
        end
    end
    if host:isHost() and host:isAvatarUploaded() and c < 100 then
        pings.updateLocal()
    end
    if host:isHost() then 
        _isLocal = not host:isAvatarUploaded()
    end
    localWarning:setVisible(_isLocal)
end

