--- A button component that also draws a fancy border around the button, giving it a rounded effect.
-- @module[kind=component] button

local buttonApi = {}
local common = require(".drawing.lib.common")

local buttons = {}
local enabledButtons = {}

--- Renders a single button.
-- @tparam number id The ID of the button to render.
-- @tparam[opt] boolean clicking Whether or not the event cycle is in between down and up.
-- @see render
function buttonApi.renderSingle(id, clicking)
  local prev = buttons[id].buttonBorder or term.getBackgroundColor()
  local b = buttons[id]

  if not b then error("Button ID " .. id .. " is non-existant") end

  common.setColors(b.foreground, b.background)
  term.setCursorPos(b.x + 1, b.y + 1)
  term.write((" %s "):format(b.text))

  local border = clicking and b.click or b.background

  common.drawBorder(prev, border, b.x, b.y, #b.text + 4, 3)

  local found = false

  for i, v in pairs(enabledButtons) do
    if v == id then
      found = true
    end
  end

  if not found then
    table.insert(enabledButtons, id)
  end
end

--- Enables a button.
-- @tparam number id The ID of the button to enable.
function buttonApi.enableButton(id)
  table.insert(enabledButtons, id)
end

--- Disables a button.
-- @tparam number id The ID of the button to disable.
function buttonApi.disableButton(id)
  for i, v in pairs(enabledButtons) do
    if v == id then
      table.remove(enabledButtons, i)
      break
    end
  end
end

--- Creates a new button.
-- @tparam number id The ID of the button. This will be the second parameter of a `button_click` event.
-- @tparam number text The text that will be displayed on the button.
-- @tparam number x The X position of the button. Note, this is the left corner of the button, not the text.
-- @tparam number y The Y position of the button. Same goes for this as for the x parameter.
-- @tparam table theme A theme table.
function buttonApi.add(id, text, x, y, theme)
  buttons[id] = {
    id = id,
    text = text,
    x = x,
    y = y,
    background = theme.button.buttonColor,
    buttonBorder = theme.button.buttonBorder,
    foreground = theme.button.textColor,
    click = theme.button.clickBorderColor
  }
end

--- Renders a table of buttons.
-- @param buttons A table of buttons to render.
-- @see renderSingle
function buttonApi.render(buttons)
  for i, v in pairs(buttons) do
    buttonApi.renderSingle(v)
  end
end

--- Disables all buttons.
function buttonApi.disableAll()
  enabledButtons = {}
end

--- Initalizes the event manager.
-- @tparam table manager The event manager.
function buttonApi.init(manager)
  manager.inject(function(re)
    local e, m, x, y = re[1], re[2], re[3], re[4]

    if e == "mouse_up" then
      if m == 1 then
        for i, v in pairs(enabledButtons) do
          local b = buttons[v]
          if x >= b.x + 1 and y == b.y + 1 and x <= b.x + #b.text + 2 then
            buttonApi.renderSingle(b.id, false)
            os.queueEvent("button_click", b.id, x, y)
          end
        end
      end
    elseif e == "mouse_click" then
      if m == 1 then
        for i, v in pairs(enabledButtons) do
          local b = buttons[v]
          if x >= b.x + 1 and y == b.y + 1 and x <= b.x + #b.text + 2 then
            buttonApi.renderSingle(b.id, true)
          end
        end
      end
    end
  end)
end

return buttonApi