local lib = {}



lib.mainPage = action_wheel:newPage("Main Page")
lib.pages = { lib.mainPage }



local unpack = table.unpack
local vec3 = vectors.vec3
local hexToRGB = vectors.hexToRGB

--[[
local function hexToInactiveColor(hexColor)
    local colorRGB = hexToRGB(hexColor)
    return colorRGB / 1.5
end

local function hexToActiveColor(hexColor)
    local colorRGB = hexToRGB(hexColor)
    return colorRGB * 1.25
end]]



---@param parentPage Page?
---@param title string
---@param icon string | {texture: Texture, u: number, v: number}
---@param color string
---@return Action newPage, Action enterPage, Action exitPage
lib.newPage = function (parentPage, title, icon, color)
    if not parentPage then return end
    if parentPage.mainPage then parentPage = parentPage.mainPage end

    local newPage = action_wheel:newPage(title)
    local enterPage = lib.newAction(parentPage, title, icon, color)
        :onLeftClick(function()
            action_wheel:setPage(newPage)
        end)

    local exitPage = lib.newAction(newPage, "Exit", "barrier", "#BD3333")
        :onLeftClick(function()
            action_wheel:setPage(parentPage)
        end)
    
    lib.pages[title] = newPage
    return newPage, enterPage, exitPage
end


---@param page Page
---@param title string
---@param icon string | {texture: Texture, u: number, v: number}
---@param color string
lib.newAction = function (page, title, icon, color, g, b)
    if type(color) == "string" then color = hexToRGB(color) end
    if g and b then color = vec3(color, g, b) end
    
    local newAction = page:newAction()
        :setTitle(title)
        :setColor(color * 0.675)
        :setHoverColor(color * 1.25)
    if type(icon) == "string" then
        newAction:setItem(icon)
    else
        newAction:setTexture(unpack(icon))
    end
    return newAction
end



function lib.getNextScrollOption(currentlySelected, selectionTable, scrollDir)
    return (currentlySelected + -scrollDir - 1) % #selectionTable + 1
end

function lib.getScrollTitle(currentlySelected, selectionTable, mainTitle)
    local tbl = {}
    tbl[#tbl+1] = { text = mainTitle, color = "#FFFFFF" }
    for index, title in ipairs(selectionTable) do
        if index == currentlySelected then
            tbl[#tbl+1] = { text = "\n> "..title, color = "#F3C738" }
        else
            tbl[#tbl+1] = { text = "\n  "..title, color = "#797979" }
        end
    end
    return toJson(tbl)
end


action_wheel:setPage(lib.mainPage)

return lib
