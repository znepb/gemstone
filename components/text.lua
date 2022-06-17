local strings = require("cc.strings")

--- A text display frame. With text wrapping at X, and doesn't restart at X=1.
-- @module[kind=component] text

local textApi = {}

--- Create a text box.
-- @tparam number text Text to display in the box.
-- @tparam number iX The starting X position of the text frame.
-- @tparam number iY The starting Y position of the text frame.
-- @tparam number eX The ending X of the text frame.
-- @tparam number eY The ending Y of the text frame.
-- @tparam table term The terminal the text will be written to.
function textApi.create(text, iX, iY, eX, eY, term)
  term.setCursorPos(iX, iY)
  local x, y = iX, iY
  local w, h = eX, eY

  local lines = strings.wrap(text, iX - iY)

  for i, line in ipairs(lines) do
    term.setCursorPos(y + i - 1)
    term.write(line)
  end
end

return textApi