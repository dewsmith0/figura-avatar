local DewOutfits = require "scripts.DewOutfits"
-- by Dewsmith
if not host:isHost() then return end
local Lift = require("libraries.Lift")
local togglesPage = require("scripts.pages").toggles
local onColor = vectors.hexToRGB("#228022")
local offColor = vectors.hexToRGB("#802222")

local nameplateVisibilityAction = togglesPage:newAction()
    :title(toJson({{color="gold",text="Nameplate: "}, {color="red", text="Disabled"}}))
    :toggleTitle(toJson({{color="gold",text="Nameplate: "}, {color="green", text="Enabled"}}))
    :item("name_tag")
    :color(offColor)
    :toggleColor(onColor)
    :onToggle(function (state) pings.nameVisible(state) end)

local chatBubbleAction = togglesPage:newAction()
    :title(toJson({{color="gold",text="(Not KK's) Chat Bubble: "}, {color="red", text="Disabled"}}))
    :toggleTitle(toJson({{color="gold",text="(Not KK's) Chat Bubble: "}, {color="green", text="Enabled"}}))
    :color(offColor)
    :toggleColor(onColor)
    :item("bubble_coral_fan")
    :onToggle(function (state) appearance.chatBubble = state end)

chatBubbleAction:setToggled(true)

nameplateVisibilityAction:setToggled(true)
if silly then

    local flyAction = togglesPage:newAction()
        :title(toJson({{color="#dface1",text="Flight: "}, {color="red", text="Disabled"}}))
        :toggleTitle(toJson({{color="#dface1",text="Flight: "}, {color="green", text="Enabled"}}))
        :color(offColor)
        :toggleColor(onColor)
        :item(world.newItem("elytra", 1, 2000))
        :toggleItem("elytra")
        :onToggle(function (state)
            silly:setFly(state)
            end
        )
    local liftAction = togglesPage:newAction()
        :title(toJson({{color="gold",text="Lift: "}, {color="red", text="Disabled"}}))
        :toggleTitle(toJson({{color="gold",text="Lift: "}, {color="green", text="Enabled"}}))
        :color(offColor)
        :toggleColor(onColor)
        :item("snowball")
        :toggleItem("wind_charge")
        :onToggle(function (state)
            Lift.config.enabled = state
            end
        )
    flyAction:setToggled(true)
    liftAction:setToggled(true)
    silly:setFly(true)
end
DewOutfits.addAction(togglesPage)
