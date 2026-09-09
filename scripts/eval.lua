-- eval command by Luihum
-- usage: type "eval>" in chat, followed by lua code, and press enter to run it in a ping
--
function pings.eval(code)
    --local status, err =
    print(pcall(loadstring(code)))
   -- print(status, err)
   -- if status then return true else if host:isHost() then handleEvalError(err) end end
end

function events.char_typed(input, modifier, code)
    if not host:isChatOpen() then return end
    if host:getChatText():find("^eval>") ~= nil then
        host:setChatColor(0,1,0)
    else 
        host:setChatColor(1,1,1)
    end
end


function handleEval(msg)
    if msg:find("^eval>") ~= nil then
        host:appendChatHistory(msg)
     --   host:setChatColor(1,1,1)
        local code = string.sub(msg,6)
        pings.eval(code)
        return true
    end
end

function handleEvalError(err)
    print("EVAL ERROR:", err)
    return err
end


return handleEval
