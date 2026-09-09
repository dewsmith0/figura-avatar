----------------------------------------------------------------
-- tag.lua — GNUI popup editor + Config + Ping + AUTO ActionWheel
----------------------------------------------------------------
if not client:getFiguraVersion() == "0.1.5b+1.21.4" then return end

-- == GNUI (matches your .playerList.lua usage) ===============================
local GNUI      = require "GNUI.main"  -- screen + primitives
local Theme     = require "GNUI.theme" -- Theme.style(...)
local TextField = require "GNUI.element.textField"
local Button    = require "GNUI.element.button"
local Slider    = require "GNUI.element.slider"

local ui_built  = false

-- forward declarations used by openUI()
local overlay, panel
local t_header, t1, t2, t3, t4, t5
local v1, v2, v3, v4, v5
-- counters keyed by "t1".."t5","v1".."v5"
local COUNTER   = {}
-- layout constants; tweak to taste
local f5Box
-- counter offsets
local CT        = { pad = 6, w = 72, yoff = 0 }  -- Title counters
local CV        = { pad = 6, w = 110, yoff = 0 } -- Value counters

local function place_counter_rect(key, x1, y1, x2, y2, is_value)
  local cfg = is_value and CV or CT
  local cx1 = x2 + cfg.pad
  local cy1 = y1 + cfg.yoff
  local cx2 = cx1 + cfg.w
  local cy2 = y2 + cfg.yoff
  local box = COUNTER[key] or GNUI.newBox(panel)
  COUNTER[key] = box
  box:setDimensions(cx1, cy1, cx2, cy2)
end


-- below: local overlay = GNUI.newBox(screen) ...
-- replace your helper with this


local ui_open = false
local function setUIVisible(v)
  ui_open = not not v
  if overlay and overlay.setVisible then overlay:setVisible(v) end
  if overlay and overlay.setEnabled then overlay:setEnabled(v) end
  if panel and panel.setVisible then panel:setVisible(v) end
  if panel and panel.setEnabled then panel:setEnabled(v) end
  if host and host.setUnlockCursor then
    host:setUnlockCursor(v)
    events.TICK:register(function() host:setUnlockCursor(v) end, "nt_unlock_once")
  end
end



-- == MODEL BINDINGS ==========================================================
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

-- == STATE / LIMITS ==========================================================
local DEFAULTS = { header = "Nametag", hColor = 120, titles = { "Name", "Gender", "Age", "Birthday", "Custom" } }
local NT = { header = DEFAULTS.header, hColor = DEFAULTS.hColor, titles = { table.unpack(DEFAULTS.titles) }, values = { "", "", "", "", "" }, f5 = true }

local MAX = { title = 10, value = 28, desc = 120, header = 32 }

-- Draft buffer for the open editor session
local D = nil -- { header=..., titles={...}, values={...}, f5=... }


-- == CONFIG I/O ==============================================================
local function KC(s, i) return i and ("nt." .. s .. i) or ("nt." .. s) end

local function cfgSave()
  -- host only
  if not host:isHost() then return end
  config:save("nt.header", NT.header)
  config:save("nt.hColor", NT.hColor)
  config:save("nt.f5", NT.f5 and 1 or 0)
  for i = 1, 5 do
    config:save("nt.t" .. i, NT.titles[i] or "")
    config:save("nt.v" .. i, NT.values[i] or "")
  end
end

local function cfgLoad()
  NT.header = config:load("nt.header") or NT.header
  NT.hColor = config:load("nt.hColor") or NT.hColor
  NT.f5     = (config:load("nt.f5") or (NT.f5 and 1 or 0)) ~= 0
  for i = 1, 5 do
    NT.titles[i] = config:load("nt.t" .. i) or NT.titles[i]
    NT.values[i] = config:load("nt.v" .. i) or NT.values[i]
  end
end

-- == APPLY TO MODEL ==========================================================
local function hsv_to_rgb(h, s, v)
  h = (h % 360) / 60
  local c = v * s
  local x = c * (1 - math.abs((h % 2) - 1))
  local m = v - c
  local r, g, b
  if h < 1 then
    r, g, b = c, x, 0
  elseif h < 2 then
    r, g, b = x, c, 0
  elseif h < 3 then
    r, g, b = 0, c, x
  elseif h < 4 then
    r, g, b = 0, x, c
  elseif h < 5 then
    r, g, b = x, 0, c
  else
    r, g, b = c, 0, x
  end
  return r + m, g + m, b + m -- 0..1 for Figura setColor
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

local created = {}

local function clamp(s, n)
  s = tostring(s or "")
  return (#s > n) and s:sub(1, n) or s
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
tagRoot = tag.tag

local function applyToModel()
  -- header
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
end


-- == PINGS ===================================================================
function broadcastApply()
  cfgSave()
  applyToModel()
  pings.nt_apply(
    NT.header, NT.hColor, NT.f5,
    NT.titles[1], NT.titles[2], NT.titles[3], NT.titles[4], NT.titles[5],
    NT.values[1], NT.values[2], NT.values[3], NT.values[4], NT.values[5])
end

-- client asks host for current state
function pings.nt_request()
  if not host:isHost() then return end
  pings.nt_apply(
    NT.header, NT.hColor, NT.f5,
    NT.titles[1], NT.titles[2], NT.titles[3], NT.titles[4], NT.titles[5],
    NT.values[1], NT.values[2], NT.values[3], NT.values[4], NT.values[5]
  )
end

-- everyone applies received state; only host persists it
function pings.nt_apply(header, hColor, f5, t1, t2, t3, t4, t5, v1, v2, v3, v4, v5)
  NT.header = tostring(header or DEFAULTS.header)
  NT.hColor = hColor or DEFAULTS.hColor
  NT.f5     = not not f5
  NT.titles = { t1 or DEFAULTS.titles[1], t2 or DEFAULTS.titles[2], t3 or DEFAULTS.titles[3], t4 or DEFAULTS.titles[4],
    t5 or DEFAULTS.titles[5] }
  NT.values = { v1 or "", v2 or "", v3 or "", v4 or "", v5 or "" }
  
  applyToModel()  
  local r,g,b = hsv_to_rgb(NT.hColor % 360, 1.0, 1.0)
  tag.tag.header:setColor(r, g, b)
  if host:isHost() then cfgSave() end -- persist once
end

-- == GNUI POPUP ==============================================================
local function buildUI()
  if ui_built then return end
  -- Uses GNUI.Box + TextField + Button. Theme.style for basic visuals.
  local screen = GNUI.getScreenCanvas()

  -- Safe get/set for either TextInput or TextField
  local function getText(tf) return tf.text or tf.textField or "" end
  local function setText(tf, s)
    if tf.setText then tf:setText(s) else tf:setTextField(s) end
  end


  -- Modal overlay
  overlay = GNUI.newBox(screen)
  overlay:setAnchor(0, 0, 1, 1):setDimensions(0, 0, 0, 0)
  Theme.style(overlay, "Background")
  setUIVisible(false)

  -- Center panel
  panel = GNUI.newBox(overlay)
  panel:setAnchor(0.5, 0.5, 0.5, 0.5):setDimensions(-130, -130, 130, 130)
  Theme.style(panel, "Background")

  -- Rows helper
  local inputs = {} -- keep if you use it elsewhere

  -- replace your whole bind_for_key with this
  local function bind_for_key(key)
    local function store() return D or NT end -- use draft if present, else live

    if key == "header" then
      return function() return (D or NT).header end,
          function(v) (D or NT).header = v end,
          MAX.header
    end

    local kind, idx = key:sub(1, 1), tonumber(key:sub(2))
    if kind == "t" then
      return function() return store().titles[idx] end,
          function(v) store().titles[idx] = v end,
          MAX.title
    elseif kind == "v" then
      local cap = (idx == 5) and MAX.desc or MAX.value
      return function() return store().values[idx] end,
          function(v) store().values[idx] = v end,
          cap
    end

    return function() return "" end, function(_) end, MAX.value
  end


  local function addRow(y, label, key)
    local tLxo, vLxo = 4, 80
    if key:find("^t") then
      local lab = GNUI.newBox(panel):setDimensions(tLxo, y, tLxo + 90, y + 7)
      lab:setText(label):setDefaultTextColor("white"):setFontScale(0.9)
    elseif key:find("^v") then
      local lab = GNUI.newBox(panel):setDimensions(vLxo, y, vLxo + 110, y + 7)
      lab:setText(label):setDefaultTextColor("gray"):setFontScale(0.9)
    elseif key == "header" then
      local lab = GNUI.newBox(panel):setDimensions(tLxo, y, tLxo + 90, y + 7)
      lab:setText(label):setDefaultTextColor("white"):setFontScale(0.9)
    end

    local getv, setv, cap = bind_for_key(key)

    local tf = TextField.new(panel)
    tf:setTextField(clamp(getv(), cap)):setTextAlign(0.5)
    tf:setEditing(false)
    if tf.setConfirmOnUnfocus then tf:setConfirmOnUnfocus(true) end

    -- Keep text when clicking off, and update the draft
    local in_handler = false
    local function writeDraft(tf, cap, setv)
      if in_handler then return end
      in_handler = true
      local raw = getText(tf) or ""
      local clipped = (#raw > cap) and raw:sub(1, cap) or raw
      -- do NOT call setText here for FIELD_CHANGED to avoid recursion
      setv(clipped)
      in_handler = false
    end

    -- CHANGED: update draft only
    if tf.FIELD_CHANGED then
      tf.FIELD_CHANGED:register(function() writeDraft(tf, cap, setv) end)
    end

    -- BLUR or CONFIRM: clamp and reflect to UI once
    local function commitAndClamp()
      if in_handler then return end
      in_handler = true
      local raw = getText(tf) or ""
      local clipped = (#raw > cap) and raw:sub(1, cap) or raw
      if clipped ~= raw then setText(tf, clipped) end
      setv(clipped)
      in_handler = false
    end
    if tf.FOCUS_LOST then tf.FOCUS_LOST:register(commitAndClamp) end
    if tf.FIELD_CONFIRMED then tf.FIELD_CONFIRMED:register(commitAndClamp) end


    -- place input box
    local box = GNUI.newBox(panel):setDimensions(10, y, 240, y + 2):setTextAlign(0, 0)
    tf.box = box

    inputs[key] = tf
    -- counter label to the right of this input box
    -- known geometry used above
    local bx1, by1, bx2, by2 = 38, y, 240, y + 27
    local counter = GNUI.newBox(panel):setDimensions(bx1, by1 + .5, bx2, by2)
    counter:setDefaultTextColor("gray"):setFontScale(0.64):setTextAlign(0, 0)
    COUNTER[key] = counter

    local function keyLabel(k)
      if k == "header" then return "Character Limit " end
      local p = k:sub(0, 1) -- "t" or "v"
      if p == "t" then return "Character\nLimit " end
      if p == "v" then return "Character Limit " end
      return k
    end

    local function updateCounter()
      local s    = (tf.text or tf.textField or "") .. ""
      local n    = #s
      local over = (n >= cap)
      local col  = over and "§c" or "§7"
      -- “Character n/max” (no “header Limit”)
      counter:setText(col .. keyLabel(key) .. n .. "/" .. cap)
    end

    if tf.FIELD_CHANGED then tf.FIELD_CHANGED:register(updateCounter) end
    if tf.FOCUS_LOST then tf.FOCUS_LOST:register(updateCounter) end
    if tf.FIELD_CONFIRMED then tf.FIELD_CONFIRMED:register(updateCounter) end
    updateCounter()


    return tf
  end


  ryo = 32
  r1y = -2 + ryo
  r2y = r1y + ryo
  r3y = r2y + ryo
  r4y = r3y + ryo
  r5y = r4y + ryo

  txo = 4
  vxo = 74

  -- Titles and values fields
  t_header = addRow(4, "Header", "header", MAX.title):setDimensions(txo, 12, txo + vxo * 1.44, 28)

  t1 = addRow(r1y, "Title 1", "t1", MAX.title):setDimensions(txo, r1y + 12, txo + 66, r1y + 28)
  t2 = addRow(r2y, "Title 2", "t2", MAX.title):setDimensions(txo, r2y + 12, txo + 66, r2y + 28)
  t3 = addRow(r3y, "Title 3", "t3", MAX.title):setDimensions(txo, r3y + 12, txo + 66, r3y + 28)
  t4 = addRow(r4y, "Title 4", "t4", MAX.title):setDimensions(txo, r4y + 12, txo + 66, r4y + 28)
  t5 = addRow(r5y, "Misc", "t5", MAX.title):setDimensions(txo, r5y + 12, txo + 66, r5y + 28)

  v1 = addRow(r1y, "Value", "v1", MAX.value):setDimensions(vxo, r1y + 12, vxo * 3.44, r1y + 28)
  v2 = addRow(r2y, "Value", "v2", MAX.value):setDimensions(vxo, r2y + 12, vxo * 3.44, r2y + 28)
  v3 = addRow(r3y, "Value", "v3", MAX.value):setDimensions(vxo, r3y + 12, vxo * 3.44, r3y + 28)
  v4 = addRow(r4y, "Value", "v4", MAX.value):setDimensions(vxo, r4y + 12, vxo * 3.44, r4y + 28)
  v5 = addRow(r5y, "Value", "v5", MAX.desc):setDimensions(vxo, r5y + 12, vxo * 3.44, r5y + 70):setTextBehavior(WRAP)


  -- values
  place_counter_rect("v1", vxo, r1y + 2, vxo * 1.4, r1y + 10, true)
  place_counter_rect("v2", vxo, r2y + 2, vxo * 1.4, r2y + 10, true)
  place_counter_rect("v3", vxo, r3y + 2, vxo * 1.4, r3y + 10, true)
  place_counter_rect("v4", vxo, r4y + 2, vxo * 1.4, r4y + 10, true)
  place_counter_rect("v5", vxo, r5y + 2, vxo * 1.4, r5y + 10, true) -- taller row 5


  -- Toggle row 5 visibility via a toggle button



  colorSlider = Slider.new(panel, { isVertical = false, min = 0, max = 1, step = 1, value = 0, showNumber = true })
      :setDimensions(140, 12, 240, 28):setMin(0):setTextAlign(.5, -1.6)
  colorSlider:setText("Color"):setMax(360):setValue(100):setStep(1)
  Theme.style(colorSlider, "Default")
  colorSlider.VALUE_CHANGED:register(function(h)
    local r, g, b = hsv_to_rgb(h, 1.0, 1.0) -- even hue spacing around the wheel
    colorSlider:setColor(r, g, b)           -- GNUI text widget (if it supports RGB 0..1)
    tag.tag.header:setColor(r, g, b)
    local S = D or NT
    S.hColor = h
  end)

  f5Btn = Button.new(panel):setDimensions(txo, 210, 70, 230)
  f5Btn:setText("Misc Visibility\n" .. ((D and D.f5) and "ON" or "OFF")):setFontScale(0.8)
  local S = D or NT
  if S.f5 then
    f5Btn:setColor(0, 1, 0)
  else
    f5Btn:setColor(1, 0, 0)
  end

  Theme.style(f5Btn, "Default")
  f5Btn.PRESSED:register(function()
    local S = D or NT
    S.f5 = not S.f5
    f5Btn:setText("Misc Visibility\n" .. ((D and D.f5) and "ON" or "OFF"))
    if S.f5 then
      f5Btn:setColor(0, 1, 0)
    else
      f5Btn:setColor(1, 0, 0)
    end
  end)

  clearF5 = Button.new(panel):setDimensions(txo + 30, 190, 70, 205)
  clearF5:setText("CLEAR >"):setColor(1, 0.46, 0.46):setFontScale(0.8)
  Theme.style(clearF5, "Default")
  clearF5.PRESSED:register(function()
    NT.header = DEFAULTS.header
    NT.values[5] = ""
    broadcastApply()
    toggleUI()
    toggleUI()
  end)

  cancelBox = Button.new(panel):setDimensions(txo, 234, txo + 66, 254)
  cancelBox:setText("Close")
  Theme.style(cancelBox, "Default")
  cancelBox.PRESSED:register(function()
    toggleUI()
  end)


  resetBox = Button.new(panel):setDimensions(txo + 95 + 10, 234, txo + 125 + 10, 254)
  resetBox:setText("RESET\nALL"):setColor(1, 1, 0):setFontScale(0.8)
  Theme.style(resetBox, "Default")
  resetBox.PRESSED:register(function()
    NT.header = DEFAULTS.header
    NT.titles = { table.unpack(DEFAULTS.titles) }
    NT.values = { "", "", "", "", "" }
    NT.f5 = true
    broadcastApply()
    toggleUI()
    toggleUI()
  end)

  saveBox = Button.new(panel):setDimensions(vxo * 2.4, 234, vxo * 3.44, 254)
  saveBox:setText("Save Changes")
  Theme.style(saveBox, "Default")
  saveBox.PRESSED:register(function()
    -- harvest UI
    -- Save button: commit draft -> NT -> persist -> apply -> close
    NT.header    = D.header
    NT.hColor    = D.hColor
    NT.titles[1] = D.titles[1]; NT.titles[2] = D.titles[2]; NT.titles[3] = D.titles[3]
    NT.titles[4] = D.titles[4]; NT.titles[5] = D.titles[5]

    NT.values[1] = D.values[1]; NT.values[2] = D.values[2]; NT.values[3] = D.values[3]
    NT.values[4] = D.values[4]; NT.values[5] = D.values[5]

    NT.f5        = D.f5

    broadcastApply()
    toggleUI()
  end)

  -- start hidden
  setUIVisible(false)
  ui_built = true
end


local function openUI()
  if not ui_built then buildUI() end
  -- Make a fresh draft from current NT
  D = {
    header = NT.header,
    hColor = NT.hColor,
    titles = { table.unpack(NT.titles) },
    values = { table.unpack(NT.values) },
    f5 = NT.f5
  }

  t_header:setTextField(D.header); colorSlider:setValue(D.hColor)

  t1:setTextField(D.titles[1]); t2:setTextField(D.titles[2]); t3:setTextField(D.titles[3])
  t4:setTextField(D.titles[4]); t5:setTextField(D.titles[5])

  v1:setTextField(D.values[1]); v2:setTextField(D.values[2]); v3:setTextField(D.values[3])
  v4:setTextField(D.values[4]); v5:setTextField(D.values[5])

  f5Btn:setText("Misc Visibility\n" .. (((D and D.f5) or NT.f5) and "ON" or "OFF"))
  local S = D or NT
  if S.f5 then
    f5Btn:setColor(0, 1, 0)
  else
    f5Btn:setColor(1, 0, 0)
  end
  -- repaint counters after seeding text
  for _, k in ipairs({ "t1", "t2", "t3", "t4", "t5", "v1", "v2", "v3", "v4", "v5" }) do
    local c = COUNTER[k]
    if c and c.setText then
      -- force recompute by firing our local helper via the field’s changed event
      -- or just rebuild the text from current field state:
      local tf = (k:sub(1, 1) == "t") and _G[k] or _G[k] -- t1..t5, v1..v5 are already globals in your file
      if tf then
        local cap = (k:sub(1, 1) == "t") and MAX.title or ((k == "v5") and MAX.desc or MAX.value)
        local s = (tf.text or tf.textField or "") .. ""
        local n = #s
        local over = (n >= cap)
        c:setText((over and "§c" or "§7") .. (k:sub(1, 1) == "t" and "Title " or "Value ") .. k:sub(2) ..
          " " .. n .. "/" .. cap)
      end
    end
  end

  setUIVisible(true)
end




local function isUIVisible()
  return ui_open
end


function toggleUI()
  if isUIVisible() then setUIVisible(false) else openUI() end
end

events.KEY_PRESS:register(function(key, _)
  if key == "key.keyboard.escape" and isUIVisible() then
    setUIVisible(false)
    return true
  end
end)

local showAnim = animations["naTa.tag"].show:setSpeed(1.3)


function passPortAnim(show)
  log(show)

  if show then
    showAnim:play():setSpeed(1.3)
  end
  if not show then
    showAnim:play():setSpeed(-2.5)
  end
  --  hideAnim:play()
end

function pings.showPassport()
  show = not show
  passPortAnim(show)
end

local headRot = vec(0,0,0)
local homeTagPos = tag.tag:getPos()
local homeTagRot = tag.tag:getRot()
local homeTagPiv = tag.tag:getPivot()
local homeTagSca = tag.tag:getScale()

function events.post_render(dt, ctx)
  if not player:isLoaded() then return end
  showBlend    = models.naTa.tag.root.Body.showArm:getAnimRot().x / 90
  showBlendVec = vec(showBlend,showBlend,showBlend)
  headRot      = vanilla_model.HEAD:getOriginRot()
  showRot      = models.naTa.tag.root.Body.showArm:getAnimRot()
  showAngle    = showRot + vec(headRot.x * showBlend, headRot.y * showBlend, headRot.z * showBlend)
  lArPi        = models.naTa.tag.root.Body.showArm

  --[[
 log("getPivot", lArPi:getPivot(),"getOffsetPivot", lArPi:getOffsetPivot(),"getTruePivot", lArPi:getTruePivot())
 log("getPos", lArPi:getPos(),"getTruePos", lArPi:getTruePos())
 log("getPivot", lItPi:getPivot(),"getOffsetPivot", lItPi:getOffsetPivot(),"getTruePivot", lItPi:getTruePivot())
 log("getPos", lItPi:getPos(),"getTruePos", lItPi:getTruePos())
 
 funny = lArPi:getPivot() - homeTagPiv
pivot = stuff
particles:newParticle("dust 0 1 1 .1", lArPi:partToWorldMatrix():apply())
particles:newParticle("dust 0 1 0 .1", lItPi:partToWorldMatrix():apply())
particles:newParticle("dust 1 0 0 .1", tag.tag:partToWorldMatrix():apply())]]

-- ^^debug SHIT^^

-- coordinate BULLSHIT HELL

offset = vec(-3,2,-8)
offset2 = vec(-2,1,4)
offsetSc = vec(1.8,1.8,-0.04)

  if showAnim:isPlaying() or show then
    vanilla_model.LEFT_ARM:setOffsetRot(showAngle)
    tag.tag:setPivot(homeTagPiv+ (-offset * showBlendVec))
    tag.tag:setPos(homeTagPos+ (offset * showBlendVec))
    tag.tag:setScale(homeTagSca+ (offsetSc * showBlendVec))
    :setOffsetPivot(offset2 * showBlendVec)
    
    :setRot(homeTagRot + showBlendVec* (vec(-90,0,0)+showAngle))
  if not show then
    tag.tag:setOffsetRot()
  end
  end
end

-- == ACTION WHEEL: AUTO ENTRY (pattern from ship.lua) ========================
events.entity_init:register(function()
  cfgLoad()

  if not host:isHost() then return end

  local root = action_wheel:getCurrentPage() or action_wheel:newPage("Main Page")
  if not action_wheel:getCurrentPage() then action_wheel:setPage("Main Page") end

  local page = action_wheel:newPage("Nametag")

  root:newAction()
      :setTitle("Nametag")
      :setItem("minecraft:name_tag")
      :setOnLeftClick(function()
        sounds:playSound("minecraft:ui.button.click", player:getPos(), 0.2, 1)
        action_wheel:setPage(page)
      end)

  page:newAction()
      :setTitle("Open Editor")
      :setItem("minecraft:writable_book")
      :setOnLeftClick(function()
        sounds:playSound("minecraft:ui.button.click", player:getPos(), 0.2, 1)
        toggleUI()
      end)
  page:newAction()
      :setTitle("Show Passport")
      :setItem("minecraft:paper")
      :setOnLeftClick(function()
        sounds:playSound("minecraft:ui.button.click", player:getPos(), 0.2, 1)
        if player:getItem(2).id:find("minecraft:air") then
          pings.showPassport()
        else
          log("There's something in your offhand, you can't show your tag!")
        end
      end)

  page:newAction()
      :setTitle("Sync Changes")
      :setItem("minecraft:redstone_torch")
      :setOnLeftClick(function()
        sounds:playSound("minecraft:ui.button.click", player:getPos(), 0.2, 1)
        pings.nt_apply(
          NT.header, NT.hColor, NT.f5,
          NT.titles[1], NT.titles[2], NT.titles[3], NT.titles[4], NT.titles[5],
          NT.values[1], NT.values[2], NT.values[3], NT.values[4], NT.values[5]
        )
        ticks = 600
      end)


  page:newAction()
      :setTitle("Back")
      :setItem("minecraft:structure_void")
      :setOnLeftClick(function()
        action_wheel:setPage(root)
      end)
      

  pings.nt_apply(
    NT.header, NT.hColor, NT.f5,
    NT.titles[1], NT.titles[2], NT.titles[3], NT.titles[4], NT.titles[5],
    NT.values[1], NT.values[2], NT.values[3], NT.values[4], NT.values[5])

  h = NT.hColor
  local r, g, b = hsv_to_rgb(h, 1.0, 1.0) -- even hue spacing around the wheel
  tag.tag.header:setColor(r, g, b)
end)


-- radius filter (optional). Set R=nil to disable.
local R = 48
local last_sig = ""
local ticks = 0

local function players_sig_map(t)
  if not t then return "" end
  local names = {}
  -- if you want “surrounding players”, filter by distance here
  local me = client:getViewer()
  local mypos = me and me:getPos()

  for name, ply in pairs(t) do
    if not R or (mypos and ply and ply.getPos and (ply:getPos() - mypos):length() <= R) then
      names[#names + 1] = name
    end
  end

  table.sort(names)               -- order-independent
  return table.concat(names, ",") -- stable string
end

events.tick:register(function()
  ticks = ticks - 1
  if ticks > 0 then return end
  ticks = 240

  local cur = world.getPlayers() -- map: name -> Player
  local sig = players_sig_map(cur)

  if sig ~= last_sig then

    pings.nt_apply(
      NT.header, NT.hColor, NT.f5,
      NT.titles[1], NT.titles[2], NT.titles[3], NT.titles[4], NT.titles[5],
      NT.values[1], NT.values[2], NT.values[3], NT.values[4], NT.values[5]
    )    
    tag.tag.header:setColor(NT.hColor)
    last_sig = sig
  end
end, "pinger")
