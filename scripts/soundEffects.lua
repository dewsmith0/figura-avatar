local mod = {}
function mod.getMeowSound()
    return sounds[math.random() > 0.2 and "minecraft:entity.cat.ambient" or "minecraft:entity.cat.stray_ambient" ]
        :pos(player:getPos())
        :subtitle(toJson({{color="white", text="",font="figura:emoji_portrait"},{color="gold", text=" Dew meows :3", font="minecraft:default"}}))
end
function mod.getPurrSound()
    return sounds["minecraft:entity.cat.purr"]
        :pos(player:getPos())
        :subtitle(toJson({{color="white", text="",font="figura:emoji_portrait"},{color="gold", text=" Dew purrs :3", font="minecraft:default"}}))
end
function mod.getPatSound()
    return sounds["minecraft:entity.cat.purr"]
        :pos(player:getPos())
        :subtitle(toJson({{color="white", text="",font="figura:emoji_portrait" }, { color="gold", text=" Dew gets patted :3",font="minecraft:default"}}))
end
function mod.getWawaSound()
    return sounds["sounds.wawa"]
        :pos(player:getPos())
        :pitch(player:getLookDir().y * 0.75 + 1.25)
        :subtitle(toJson({{color="white", text="",font="figura:emoji_portrait"},{color="gold", text=" Dew wawas :3", font="minecraft:default"}}))
end
local varitem_sound = sounds["minecraft:block.note_block.bit"]
    :subtitle(toJson({{
        {color="white", text="",font="figura:emoji_portrait"}, {color= "white", text= "", font= "figura:emoji_object"},{color="green",font="minecraft:default",text="Dew codes"}}
    }
))

function mod.handleVaritemSound()
    if player:getGamemode() ~= "CREATIVE" then return false end
    local heldItem = player:getHeldItem()
    if heldItem == "minecraft:air" then return false end
    if heldItem:getTag()["minecraft:custom_data"] == nil then return false end
    if heldItem:getTag()["minecraft:custom_data"]["PublicBukkitValues"] == nil then return false end
    if heldItem:getTag()["minecraft:custom_data"]["PublicBukkitValues"]["hypercube:varitem"] ~= nil then 
        pings.varitem() 
        return true
    end       
end
function pings.varitem()
     if player:isLoaded() then
        varitem_sound:pos(player:getPos()):pitch(0.5 + math.random() * 1.5):play()
    end
end

return mod