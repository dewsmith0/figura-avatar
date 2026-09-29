if not silly then return end


local showProfiler = true -- default for debugging
local profilers = {
}

local profilerKey =  keybinds:newKeybind("Toggle Avatar Profiler", "key.keyboard.f8")
profilerKey:setOnPress(function(mod, key)
    showProfiler = not showProfiler
end)

profilers[avatar:getEntityName()] = silly.profiler
local activeProfilerName = avatar:getEntityName()

local lastTimes = {}
---@param playerName string
local function processTimes(playerName)
    if not profilers[playerName] then return {} end
    profilers[playerName] = silly:getProfiler(playerName)
    local times = profilers[playerName]:getTimes(true)
    --print(times)
    return times
end
local lastRender = 0

events.GUI_RENDER:register(function(graphics, delta)
    if not showProfiler then return end
    local now = client.getSystemTime() 
    if now - lastRender >= 1000 then
        lastRender = now
        lastTimes[activeProfilerName] = processTimes(activeProfilerName) 
        
    end
    if not lastTimes[activeProfilerName] then return end
    local scaledSize = client.getWindowSize():div(client.getGuiScale(), client.getGuiScale())
    local xPos = client.isDebugOverlayEnabled() and scaledSize.x / 3  or scaledSize.x / 8
    local yPos = 30
    for k, v in pairs(lastTimes[activeProfilerName]) do
        yPos = yPos + 10
        local timeString = k .. ": " .. v / 1000000 .. "ms"
        graphics:blitString(timeString, vec(xPos, yPos))
    end
end
)
