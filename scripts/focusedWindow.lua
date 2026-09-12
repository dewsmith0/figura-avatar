local appearance = require("./appearance")
local lastFocused = ""

--local debugChangeCounter = 0
local programEmojis = {
    codium = ":vscode:",
    blockbench = ":blockbench:",
    firefox = ":internet:",
    dolphin = ":folder:",
    plasmashell = ":cursor_1:",
    aseprite = ":aseprite:",
    konsole = ">_"
}

function pings.afkEmoji(emoji)
    appearance.setAfkEmoji(emoji)
end

function events.tick() 
    if host:isHost() then
        local success, rawName = pcall(file.readString, file, "processdata/pname.txt")
        if success and rawName then
            local windowName = string.gsub(rawName:match("^%s*(.-)%s*$"), '%s+', '')

            if windowName ~= lastFocused then
                --debugChangeCounter = debugChangeCounter + 1
                lastFocused = windowName
                local tryEmoji = programEmojis[lastFocused]
                if tryEmoji == nil then tryEmoji = ":zzz:" end
                if appearance.afkEmoji == tryEmoji then return end
                pings.afkEmoji(tryEmoji)
                --host:setActionbar("wname="..windowName.." last="..lastFocused.." debug="..debugChangeCounter.." emoji="..tryEmoji)
                --print(windowName)
            end
        end
    end
end


