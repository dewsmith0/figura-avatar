local easyWheel = require("libraries.easyWheel")
local pages = require("scripts.pages")

local modelRoot = models.model.root
local outfitBuffer = {} -- stores partially loaded outfits
local expectedSizes = {} -- stores buffer sizes of outfits
local outfitCache = {} -- stores fully loaded outfits
local outfitIdMap = {}
local isPinging = false

local parts = {
    modelRoot.Body.Shirt,

    modelRoot.LeftArm.LeftSleeve, modelRoot.LeftArm.LeftSleeveLayer2,
    modelRoot.RightArm.RightSleeve, modelRoot.RightArm.RightSleeveLayer2,

    modelRoot.LeftLeg.LeftPants, modelRoot.LeftLeg.LeftPantsLayer2,
    modelRoot.RightLeg.RightPants, modelRoot.RightLeg.RightPantsLayer2,
}

local function applyOutfit(name, texture)
    if not texture then 
        for i = 1, #parts do
            parts[i]:setVisible(false)
        end
        return
    end
    for i = 1, #parts do
        parts[i]:setPrimaryTexture("CUSTOM", texture):setVisible(true)
    end
end


local function equipOutfit(id)
    if not id then
        applyOutfit(nil, nil)
        return
    end
    if type(outfitCache[id]) == "Texture" then applyOutfit(id, outfitCache[id]) end
    local bufferEntry = outfitBuffer[id]
    if not bufferEntry then print("buffer is nil"); return end
    local parsedTexture = table.concat(bufferEntry, "", 1, #bufferEntry)
    local success, result = pcall(textures.read, textures, id, parsedTexture)
    if not success then print("outfit error: ", result); return end
    outfitCache[id] = result
    applyOutfit(id, result)
end

function pings.outfitHeader(name, id, size)
    expectedSizes[name] = size 
    outfitBuffer[name] = {}
    outfitIdMap[id] = name
end
function pings.tryLoadCachedOutfit(name) 
    if type(outfitCache[name]) == "Texture" then equipOutfit(name) end
end

function pings.outfitData(id, num, chunk)
    local name = outfitIdMap[id]  
    if not name then return end
    outfitBuffer[name][num] = chunk
    if #outfitBuffer[name] == expectedSizes[name] then 
        equipOutfit(name)
    end
end


--=============== HOST ONLY PART
if not host:isHost() then return end
local CHUNK_SIZE = 300
local OUTFITS_DIR = "dew_outfits/"
local hoveredIndex = 1
local selectedIndex = 1
local outfitNames = {
    "<No Outfit>"
}
local nextOutfit = nil
local reping = false
local pingBuffer = {}
local pingIndex = 1
for i, name in ipairs(file:list(OUTFITS_DIR)) do outfitNames[i+1] = name end

local function splitByChunk(text, chunkSize)
    local s = {}
    for i=1, #text, chunkSize do
        s[#s+1] = text:sub(i,i+chunkSize - 1)
    end
    return s
end

local function startPinging(textureName)
    if textureName == "<No Outfit>" then 
        equipOutfit(nil)
        return
    end
    nextOutfit = textureName
    pingBuffer = {}
    local texturefile = OUTFITS_DIR..textureName
    local textureBuffer = data:createBuffer(1024000)
    local stream = file:openReadStream(texturefile)
    textureBuffer:readFromStream(stream, stream:available())
    local bufferLen = textureBuffer:getLength()
    textureBuffer:setPosition(0)
    local base64 = textureBuffer:readBase64(bufferLen)
    local b64Len = string.len(base64)
    expectedSizes[textureName] = math.ceil(b64Len / CHUNK_SIZE)

    pings.outfitHeader(textureName, selectedIndex, math.ceil(b64Len / CHUNK_SIZE))
    local remaining = b64Len
    local chunkedPing = splitByChunk(base64, CHUNK_SIZE)
    pingBuffer = splitByChunk(base64, CHUNK_SIZE)
        isPinging = true

end

local outfitAction = easyWheel.newAction(pages.toggles, 
    easyWheel.getScrollTitle(hoveredIndex, outfitNames, "Select & Ping Outfit | Equipped: "..outfitNames[selectedIndex]),
    "leather_chestplate",  "#ff7c00")


function outfitAction.leftClick() 
    if isPinging then 
        log("Please wait for the current ping to finish.")
        pings.tryLoadCachedOutfit(outfitNames[hoveredIndex])
        return
    end
    selectedIndex = hoveredIndex
    reping = false

    startPinging(outfitNames[selectedIndex])
end

function outfitAction.scroll(dir)
    hoveredIndex = easyWheel.getNextScrollOption(hoveredIndex, outfitNames, dir)
    outfitAction:setTitle(easyWheel.getScrollTitle(hoveredIndex,outfitNames, "Select & Ping Outfit | Equipped: "..outfitNames[selectedIndex]))
end

events.TICK:register(function ()
    if not isPinging then
        if world.getTime() % 800 == 0 then
            reping = true
            startPinging(outfitNames[selectedIndex])
            return 
        end
        return
    end
        host:actionbar(toJson({
        color="#1ecafd",
        text=((reping and "Repinging: " or "Pinging: ").. outfitNames[selectedIndex] .. " " .. tostring(pingIndex).. "/" .. expectedSizes[outfitNames[selectedIndex]] .." chunks"), 
    }))
    if world.getTime() % 10 == 0 then 
        pings.outfitData(selectedIndex, pingIndex, pingBuffer[pingIndex])
        if expectedSizes[nextOutfit] and pingIndex >= expectedSizes[nextOutfit] then
            isPinging = false
            pingIndex = 1
        else
            pingIndex = pingIndex + 1
        end
    end

end)

events.ERROR:register(function (e) 
    print("Error!")
    print(e)
    print("pingIndex:", pingIndex)
    printTable("outfitBuffer:")
    printTable(outfitBuffer)
    print("expectedSizes: ", expectedSizes)
end)
