local showingPronouns = true
local afk = require("libraries.afk")
local appearance = {}
appearance.defaultNameplate = toJson({
    {
        text = "Dewsmith :@dew:${badges}${afk}",
        color = "#dface1"
    }
})


appearance.pronounsNameplate = toJson({
    {
        text = ":@dew: Dewsmith  :@dew:${badges}${afk}",
        color = "#dface1"
    },
    {
        text = "\nany pronouns",
        color = "#dface1",
        bold = true
    }
})

appearance.chatNameplate = toJson({
    {text = "Dewsmith ", color = "#dface1"},
    {text = ":@dew: ", color = "#ffffff"},
    {text = "${badges}${afk_alt}", color = "#1ecafd"}
})
appearance.afkEmoji = ":zzz:"
function appearance.setAfkEmoji(emoji)
    appearance.afkEmoji = emoji
    afk.config.short = " ["..emoji.." ${m}:${ss}]"
    afk.config.long = " ["..emoji.." ${H}:${mm}:${ss}]"

end

nameplate.CHAT:setText(appearance.chatNameplate)
nameplate.LIST:setText(appearance.defaultNameplate)
avatar:setColor(vectors.hexToRGB("#A23BEC"),"donator")

function events.tick()
    if 
    client.getCameraEntity():getTargetedEntity(5) == player then
        if not showingPronouns then nameplate.ENTITY:setText(appearance.pronounsNameplate) end
    else
        nameplate.ENTITY:setText(appearance.defaultNameplate)
    end 
end

return appearance
