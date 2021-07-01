--- A button api that also draws a fancy border around the button, giving it a rounded effect.
-- @author znepb
-- @module button

local buttonApi = {}
local common = require("common")

--- The all-mighty table of buttons.
-- @local
local buttons = {}

--- Buttons that are enabled.
-- @local
local enabledButtons = {}

--- A table of colors for when the event cycle is between mouse_click and mouse_up, which the border of the button will be set to
-- @local
local clickColors = {
  [1] = colors.lightGray,
  [2] = colors.yellow,
  [4] = colors.purple,
  [8] = colors.blue,
  [16] = colors.orange,
  [32] = colors.green,
  [64] = colors.magenta,
  [128] = colors.lightGray,
  [256] = colors.gray,
  [512] = colors.lightBlue,
  [1024] = colors.magenta,
  [2048] = colors.lightBlue,
  [4096] = colors.orange,
  [8192] = colors.lime,
  [16384] = colors.pink,
  [32768] = colors.gray
}

--- Renders a single button.
-- @param id The ID of the button to render.
-- @param ?borderOverride The border color of the button. Default is to inherit from the button's background.
-- @see render
function buttonApi.renderSingle(id, borderOverride)
  local prev = term.getBackgroundColor()
  local b = buttons[id]
  prev = b.borderColor or prev

  if not b then error("Button ID " .. id .. " is non-existant") end

  common.setColors(b.foreground, b.background)
  term.setCursorPos(b.x + 1, b.y + 1)
  term.write((" %s "):format(b.text))

  local border = borderOverride or b.background

  common.drawBorder(prev, border, b.x, b.y, #b.text + 4, 3)
end

--- Enables a button.
-- @param id The ID of the button to enable.
function buttonApi.enableButton(id)
  table.insert(enabledButtons, id)
end

--- Disables a button.
-- @param id The ID of the button to disable.
function buttonApi.disableButton(id)
  for i, v in pairs(enabledButtons) do
    if v == id then
      table.remove(enabledButtons, i)
      break
    end
  end
end

--- Creates a new button.
-- @param id The ID of the button. This will be the second parameter of a `button_click` event.
-- @param text The text that will be displayed on the button.
-- @param x The X position of the button. Note, this is the left corner of the button, not the text.
-- @param y The Y position of the button. Same goes for this as for the x parameter.
-- @param ?bgc The background color of the button. Default color is white.
-- @param ?fgc The foreground (text) color of the button. Default color is black.
-- @param ?clickColor The highlight color of the button's border. If not supplied, this will pull from the clickColors table.
-- @param ?borderColor The color of the whitespace around the button. THe default is to inherit this when the button is rendered.
function buttonApi.add(id, text, x, y, bgc, fgc, clickColor, borderColor)
  buttons[id] = {
    id = id,
    text = text,
    x = x,
    y = y,
    background = bgc or colors.white,
    foreground = fgc or colors.black,
    click = clickColor,
    borderColor = borderColor
  }
end

--- Renders a table of buttons.
-- @param buttons A table of buttons to render.
-- @see renderSingle
function buttonApi.render(buttons)
  for i, v in pairs(buttons) do
    buttonApi.renderSingle(v)
    table.insert(enabledButtons, v)
  end
end

--- Disables all buttons.
function buttonApi.disableAll()
  enabledButtons = {}
end

--- A function to put in parallel with your event handeler. This will handle all button clicks, and is very important!
function buttonApi.update()
  while true do
    local e, b, x, y = os.pullEvent()

    if e == "mouse_up" then
      if b == 1 then
        for i, v in pairs(enabledButtons) do
          local b = buttons[v]
          if x >= b.x + 1 and y == b.y + 1 and x <= b.x + #b.text + 2 then
            buttonApi.renderSingle(b.id)
            os.queueEvent("button_click", b.id, x, y)
          end
        end
      end
    elseif e == "mouse_click" then
      if b == 1 then
        for i, v in pairs(enabledButtons) do
          local b = buttons[v]
          if x >= b.x + 1 and y == b.y + 1 and x <= b.x + #b.text + 2 then
            local color = clickColors[b.background]
            if b.click then color = b.click end

            buttonApi.renderSingle(b.id, color)
          end
        end
      end
    end
  end
end

return buttonApi