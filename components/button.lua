--- A button component that also draws a fancy border around the button, giving it a rounded effect.
-- @module[kind=component] button

local args = { ... }
local path = fs.combine(args[2], "../../")

local buttonApi = {}
local common = require("/" .. fs.combine(path, "lib", "common"))
local rawButton = require("/" .. fs.combine(path, "components", "rawButton"))
local buttons = {}

-- @section Rendering

--- Renders a single button.
-- @tparam string id The ID of the button to render.
-- @tparam[opt] boolean clicking Whether or not to render the border with the click color rather than the button color.
-- @tparam[opt] boolean dontEnable If true, the button won't be enabled.
function buttonApi.renderSingle(id, clicking, dontEnable)
  local b = buttons[id]

  local previous = term.current()
  term.redirect(b.term)
  
  local bg = term.getBackgroundColor()
  local c = b.background

  if clicking then c = b.click end
  common.drawBorder(b.border or bg, c, b.x, b.y, #b.text + 4, 3)
  term.setCursorPos(b.x + 1, b.y + 1)
  common.setColors(b.foreground, b.background)
  term.write((" %s "):format(b.text))

  if not dontEnable then rawButton.enableSingle(id) end
  term.setBackgroundColor(bg)

  term.redirect(previous)
end

--- Renders multiple buttons.
-- @tparam table ids The table of IDs to render.
function buttonApi.render(ids)
  for i, v in pairs(ids) do
    buttonApi.renderSingle(v)
  end
end

-- @section Disabling & enabling

--- Disables a button.
-- @tparam number id The ID of the button to disable.
function buttonApi.disableSingle(id)
  rawButton.disableSingle(id)
end

--- Disables a button.
-- @tparam number id The ID of the button to disable.
function buttonApi.disable(ids)
  rawButton.disable(ids)
end

--- Disables all buttons in the manager.
function buttonApi.disableAll()
  rawButton.disableAll()
end

--- Enables a button.
-- @tparam number id The ID of the button to enable.
function buttonApi.enableSingle(id)
  rawButton.enableSingle(id)
end

--- Enables multiple buttons.
-- @tparam table ids A table of IDs to enable.
function buttonApi.enable(ids)
  rawButton.enable(ids)
end

-- @section Initalization

--- Creates a new button.
-- @tparam number id The ID of the button. This will be the second parameter of a `button_click` event.
-- @tparam number text The text that will be displayed on the button.
-- @tparam number x The X position of the button. Note, this is the left corner of the button, not the text.
-- @tparam number y The Y position of the button. Same goes for this as for the x parameter.
-- @tparam table theme A theme table.
-- @tparam table uTerm The terminal to draw the button to.
function buttonApi.add(id, text, x, y, theme, uTerm)
  buttons[id] = {
    id = id,
    x = x,
    y = y,
    text = text,
    rawButton = rawButton.add(id, x + 1, y + 1, #text + 2, 1, uTerm, "__gemstone_internal_"),
    background = theme.button.buttonColor,
    foreground = theme.button.textColor,
    click = theme.button.clickBorderColor,
    border = theme.button.buttonBorder,
    term = uTerm or term.current()
  }
end


-- ! NOTICE ! --
-- The "__gemstone_internal_button_click" event is NOT meant to be used by your application!
-- Use the `button_click` event, or if you want, use the rawButton component.

--- Initalizes the button manager.
-- @tparam table manager The manager to initalize to.
function buttonApi.init(manager)
  rawButton.init(manager)

  manager.inject(function(re)
    if re[1] == "__gemstone_internal_button_down" then
      buttonApi.renderSingle(buttons[re[2]].id, true, true)
      os.queueEvent("button_down", re[2], re[3], re[4])
    elseif re[1] == "__gemstone_internal_button_click" then
      buttonApi.renderSingle(buttons[re[2]].id, false, true)
      os.queueEvent("button_click", re[2], re[3], re[4])
    end
  end)
end

return buttonApi