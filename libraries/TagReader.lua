local returnPart = models.model.root.Body
local tag = returnPart.Card
local cardArm = models.model.root.LeftArm

local holdingCard = false
local info = {
    Name = "Dewsmith",
    Pronouns = "Any",
    Species = "Felis sapiens",
    Join = "2025/10/29",
    Install = "2023/8/15"
}

for i, v in pairs(info) do
    local translatedJson = {{text = string.upper(i), bold = true}, {text = ": ", bold = false}, {text = v, bold = false, italic = true}}
    tag.info[string.lower(i)]:newText("CARD_DATA:"..i):setText(toJson(translatedJson)):scale(0.015)
end



function pings.holdToggle(holding)
    if holdingCard ~= holding and player:isLoaded() then
        if holding then
            sounds["item.armor.equip_leather"]:pitch(2):volume(0.1):setPos(player:getPos()):play()
        else
            sounds["item.armor.equip_leather"]:pitch(2):volume(0.1):setPos(player:getPos()):play()
        end
    end

    holdingCard = holding
end



function events.tick()
    if holdingCard and player:getVelocity():length() < 0.1 then
        cardArm:setOffsetRot(vec(90, 0, 0))
        tag:moveTo(cardArm):setPos(vec(-4.5, -10.5, 5)):setRot(vec(90, 180, -180)):scale(2.5)
    else
        cardArm:setOffsetRot(vec(0, 0, 0))
        tag:moveTo(returnPart):setPos(vec(0,0,0)):setRot(vec(0,0,0)):scale(1)
    end
end



if not host:isHost() then return end

local page = require("scripts.pages").emotes

local holdAction = page:newAction()
    :title("Hold Tag")
    :toggleTitle("Stop Holding Tag")
    :item("paper")
    :toggleItem("filled_map")
    :onToggle(function() pings.holdToggle(true) end)
    :onUntoggle(function() pings.holdToggle(false) end)