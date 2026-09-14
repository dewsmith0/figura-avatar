local LockMovement = false
function events.tick()
  LockMovement = animations.model.sit:isPlaying()
end


for _,key in ipairs({
  keybinds:fromVanilla("key.forward"),
  keybinds:fromVanilla("key.back"),
  keybinds:fromVanilla("key.left"),
  keybinds:fromVanilla("key.right"),
  keybinds:fromVanilla("key.jump"),
  --keybinds:fromVanilla("key.attack"),
  --keybinds:fromVanilla("key.use"),
  keybinds:fromVanilla("key.sneak"),
}) do
  key.press = function()
    return LockMovement
  end
end
-- function events.mouse_move()
--   return LockMovement
-- end