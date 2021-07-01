--- A dialog box that can show a title, description, and an OK button.
-- @author znepb
-- @module dialog

local dialogApi = {}
local text = require("text")
local common = require("common")

--- Create a dialog element, and render it.
-- @param title The title of the dialog UI.
-- @param subtext The description of the dialog.
-- @param button The button worker that the UI's OK button will be put in.
-- @param scroll The scrollbox instance that will be used for the textbox.
-- @param ?width Width of the dialog. Default of 26.
-- @param ?height Height of the dialog. Default of 10.
-- @param ?backgroundColor Background color of the dialog. Default color is white.
-- @param ?borderColor Color of the border and the area where the button is contained. Default color is light gray.
-- @param ?textColor Color of the subtext in the dialog. Default color is gray.
-- @param ?titleColor Color of the title in the dialog. Default color is black.
-- @param ?highlightColor Color of the button's border between mouse_click and mouse_up. Default color is gray.
-- @return A number which is the the second half the the button's ID. The way to find the ID of the button is `"ok-" .. id`. This is used to run a function when the OK button is pressed.
function dialogApi.create(title, subtext, button, scroll, width, height, backgroundColor, borderColor, textColor, titleColor, highlightColor)
  -- @todo add custom buttons (for cancel, differnet ok messages, etc)
  local epoch = os.epoch("utc")

  local w, h = term.getSize()
  local preColor = term.getBackgroundColor()

  if not backgroundColor then backgroundColor = colors.white end
  if not borderColor then borderColor = colors.lightGray end
  if not textColor then textColor = colors.gray end
  if not titleColor then titleColor = colors.black end
  if not highlightColor then highlightColor = colors.gray end

  local sX, sY = width or 26, height or 10

  local hw, hh = w / 2, h / 2

  paintutils.drawFilledBox(hw - (sX / 2) + 1, hh - (sY / 2), hw + (sX / 2), hh + (sY / 2), backgroundColor)

  common.setColors(textColor, backgroundColor)
  local scrollbox = scroll.create("scroll-" .. epoch, hw - sX / 2 + 2, hh - sY / 2 + 3, sX - 2, sY - 6, term.current())
  scrollbox.setTextColor(textColor)
  scrollbox.setBackgroundColor(backgroundColor)
  scrollbox.clear()
  text.create(subtext, 1, 1, sX - 4, 100, scrollbox)

  common.drawBorder(backgroundColor, borderColor, hw - (sX / 2), hh - (sY / 2) - 1, sX + 2, sY + 3, true)

  paintutils.drawFilledBox(hw - sX / 2 + 1, hh + sY / 2 - 2, hw + sX / 2, hh + sY / 2, borderColor)
  button.add("ok-" .. epoch, "OK", math.floor(hw + sX / 2 - 5), math.floor(hh + sY / 2 - 2), backgroundColor, textColor, highlightColor, borderColor)
  button.render({"ok-" .. epoch})

  common.setColors(titleColor, backgroundColor)
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