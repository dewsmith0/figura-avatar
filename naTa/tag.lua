-- original nametag script by AnOrcaDork
-- this version has been butchered by Dewsmith
 
-- == CONFIG ==================================================================
local NT  = {
  header = "FIGURA PLAZA ID CARD", 
  hColor = 227, 
  titles = { "Name", "Pronouns", "Species", "Join Date", "Extra" }, 
  values = {"Dewsmith", "any", "Felis catus sapiens", "2025-10-29", "Figura Implant Install Date: 2023-08-15"},
  f5 = true
}

-- == OTHER THINGS == =========================================================
-- Adjust this path only if your tree differs.
-- Expect: tag.header, tag.name, tag.gender, tag.age, tag.bday, tag.custom
local tag = models.naTa.tag.root.Body.nametag
tag.tag.pfp:setPrimaryTexture("SKIN"):setSecondaryTexture():setUV(0, 1)
tag.tag.pfp2:setPrimaryTexture("SKIN"):setSecondaryTexture():setUVPixels(8, 32)


-- Optional small pose tweak you already run
local basePos = tag:getPos()
local frontPos = basePos + vec(0, 0, -0.25)
function events.render(_, _)
  if not player:isLoaded() then return end
  local chest = player:getItem(5).id or ""
  if chest:find("chestplate") then
    tag:setPos(0, 0, -.5)
  else
    tag:setPos(frontPos)
  end
end

-- soft wrap at word boundaries
local function wrap_words(s, max_chars)
  s = tostring(s or "")
  if s == "" or max_chars <= 0 then return s end
  local lines, line, llen = {}, "", 0
  for word in s:gmatch("%S+") do
    local wlen = #word
    local need = wlen + (llen > 0 and 1 or 0)
    if llen + need > max_chars then
      table.insert(lines, line)
      line, llen = word, wlen
    else
      if llen > 0 then line = line .. " " .. word else line = word end
      llen = llen + need
    end
  end
  if line ~= "" then table.insert(lines, line) end
  return table.concat(lines, "\n")
end


local TXT = {} -- cache of part->Text objects by key

local function trim(s)
  s = tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""); return s
end
local function join_tv(t, v)
  t, v = trim(t), trim(v)
  if t == "" and v == "" then return "" end
  if t == "" then return v end
  if v == "" then return t end
  return "§n" .. t .. "§r§0" .. " " .. v
end

local function upsert_text(part, key, text, align, scale)
  -- remove if empty
  if text == "" then
    if TXT[key] and TXT[key].remove then
      TXT[key]:remove(); TXT[key] = nil
    end
    return
  end
  local t = TXT[key]
  if not t then
    t = part:newText(key)
    if align then t:setAlignment(align) end
    if scale then t:setScale(scale, scale, scale) end
    t:setBackground(true):setScale(.011):setBackgroundColor(0.6, 0.6, 0.6, 1)
    TXT[key] = t
  end
  if key == "nt_header" then
    t:setText("§f" .. text):setWidth(220):setScale(.021):setBackground(false):setBackgroundColor(0.4, 0.4, 0.4, 0)
        :setOutline(true)
  else
    t:setText("§3" .. text):setWidth(140)
  end
end

-- expects: models.root.Body.nametag.tag.{header,t1,t2,t3,t4,t5}
local tagRoot = tag.tag

upsert_text(tagRoot.header, "nt_header", trim(NT.header), "CENTER", 0.5)
  for i = 1, 5 do
    local key = "nt_row" .. i
    if i == 5 and not NT.f5 then
      upsert_text(tagRoot.t5, key, "§n" .. "", "LEFT", 0.28)
    else
      local text = join_tv(NT.titles[i], NT.values[i])
    if i == 5 then
      text = wrap_words(text, 146) -- tune width for your scale
    end
    upsert_text(tagRoot["t" .. i], key, text, "LEFT", 0.28)
  end
end


local color = vectors.hsvToRGB(NT.hColor / 360, 1, 1)
local r,g,b = color.r, color.g, color.b
tag.tag.header:setColor(r, g, b)

local showAnim = animations["naTa.tag"].show:setSpeed(1.3)
local showingTag = false

local function passPortAnim(show)
  if show then
    showAnim:play():setSpeed(1.3)
  end
  if not show then
    showAnim:play():setSpeed(-2.5)
  end
end
function pings.showPassport(show)
  showingTag = show
  passPortAnim(showingTag)
end

local homeTagPos = tag.tag:getPos()
local homeTagRot = tag.tag:getRot()
local homeTagPiv = tag.tag:getPivot()
local homeTagSca = tag.tag:getScale()

function events.post_render(dt, ctx)
  if not player:isLoaded() then return end
  local showBlend    = models.naTa.tag.root.Body.showArm:getAnimRot().x / 90
  local showBlendVec = vec(showBlend,showBlend,showBlend)
  local headRot      = vanilla_model.HEAD:getOriginRot()
  local showRot      = models.naTa.tag.root.Body.showArm:getAnimRot()
  local showAngle    = showRot + vec(headRot.x * showBlend, headRot.y * showBlend, headRot.z * showBlend)

-- coordinate BULLSHIT HELL

  local offset = vec(-3,2,-8)
  local offset2 = vec(-2,1,4)
  local offsetSc = vec(1.8,1.8,-0.04)

  if showAnim:isPlaying() or showingTag then
    vanilla_model.LEFT_ARM:setOffsetRot(showAngle)
    tag.tag:setPivot(homeTagPiv+ (-offset * showBlendVec))
    tag.tag:setPos(homeTagPos+ (offset * showBlendVec))
    tag.tag:setScale(homeTagSca+ (offsetSc * showBlendVec))
    :setOffsetPivot(offset2 * showBlendVec)
    :setRot(homeTagRot + showBlendVec* (vec(-90,0,0)+showAngle))
  if not showingTag then
    tag.tag:setOffsetRot()
  end
  end
end

if host:isHost() then 
  local page = require("scripts.pages").emotes
  page:newAction()
      :setTitle("Show Passport")
      :setItem("minecraft:paper")
      :setOnLeftClick(function()
        sounds:playSound("minecraft:ui.button.click", player:getPos(), 0.2, 1)
        if player:getItem(2).id:find("minecraft:air") then
          pings.showPassport(not showingTag)
        else
          log("There's something in your offhand, you can't show your tag!")
        end
      end)
end