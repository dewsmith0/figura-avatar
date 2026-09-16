local DewOutfits = require "scripts.DewOutfits"
-- by Dewsmith
if not host:isHost() then return end
local Lift = require("libraries.Lift")
local togglesPage = require("scripts.pages").toggles
if silly then
    local liftAction = togglesPage:newAction()
        :title(toJson({{color="gold",text="Lift: "}, {color="red", text="Disabled"}}))
        :toggleTitle(toJson({{color="gold",text="Lift: "}, {color="green", text="Enabled"}}))
        :color(vectors.hexToRGB("#802222"))
        :toggleColor(vectors.hexToRGB("#228022"))
        :item("snowball")
        :toggleItem("wind_charge")
        :onToggle(function (state)
            Lift.config.enabled = state
            end
        )
    local flyAction = togglesPage:newAction()
        :title(toJson({{color="#dface1",text="Flight: "}, {color="red", text="Disabled"}}))
        :toggleTitle(toJson({{color="#dface1",text="Flight: "}, {color="green", text="Enabled"}}))
        :color(vectors.hexToRGB("#802222"))
        :toggleColor(vectors.hexToRGB("#228022"))
        :item(world.newItem("elytra", 1, 2000))
        :toggleItem("elytra")
        :onToggle(function (state)
            silly:setFly(state)
            end
        )
    flyAction:setToggled(true)
    liftAction:setToggled(true)
    silly:setFly(true)
end


DewOutfits.addAction(togglesPage)