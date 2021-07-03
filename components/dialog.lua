--- A dialog box that can show a title, description, and an OK button.
-- @author znepb
-- @module dialog

local dialogApi = {}
local text = require(".drawing.components.text")
local common = require(".drawing.lib.common")

--- Create a dialog element, and render it.
-- @param title The title of the dialog UI.
-- @param subtext The description of the dialog.
-- @param button The button worker that the UI's OK button will be put in.
-- @param scroll The scrollbox instance that will be used for the textbox.
-- @param ?theme A theme.
-- @param ?width Width of the dialog. Default of 26.
-- @param ?height Height of the dialog. Default of 10.
-- @return A number which is the the second half the the button's ID. The way to find the ID of the button is `"ok-" .. id`. This is used to run a function when the OK button is pressed.
function dialogApi.create(title, subtext, button, scroll, theme, width, height)
  -- @todo add custom buttons (for cancel, differnet ok messages, etc)
  local epoch = os.epoch("utc")

  local w, h = term.getSize()
  local preColor = term.getBackgroundColor()

  local sX, sY = width or 26, height or 10

  local hw, hh = w / 2, h / 2

  paintutils.drawFilledBox(hw - (sX / 2) + 1, hh - (sY / 2), hw + (sX / 2), hh + (sY / 2), theme.dialog.backgroundColor)

  common.setColors(theme.dialog.textColor, theme.dialog.backgroundColor)
  local scrollbox = scroll.create("scroll-" .. epoch, hw - sX / 2 + 2, hh - sY / 2 + 3, sX - 2, sY - 6, term.current())
  scrollbox.setTextColor(theme.dialog.textColor)
  scrollbox.setBackgroundColor(theme.dialog.backgroundColor)
  scrollbox.clear()
  text.create(subtext, 1, 1, sX - 4, 100, scrollbox)

  common.drawBorder(preColor, theme.dialog.borderColor, hw - (sX / 2), hh - (sY / 2) - 1, sX + 2, sY + 3, true)

  paintutils.drawFilledBox(hw - sX / 2 + 1, hh + sY / 2 - 2, hw + sX / 2, hh + sY / 2, theme.dialog.borderColor)
  button.add("ok-" .. epoch, "OK", math.floor(hw + sX / 2 - 5), math.floor(hh + sY / 2 - 2), theme.dialog.sub)
  button.render({"ok-" .. epoch})

  common.setColors(theme.dialog.titleColor, theme.dialog.backgroundColor)
  term.setCursorPos(hw - sX / 2 + 2, hh - sY / 2 + 1)
  term.write(title)

  return epoch
end

--- Dismisses a dialog box.
-- @param id The ID of the dialog, retured at creation.
-- @param button The button manager used at creation.
-- @param scroll The scroll manager used at creation.
function dialogApi.dismiss(id, button, scroll)
  button.disableButton("ok-" .. id)
  scroll.remove("scroll-" .. id)
end

return dialogApi