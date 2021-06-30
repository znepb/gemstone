--- Dialog component
-- @author znepb
-- @module dialog

local dialogApi = {}

--- Internal function for setting colors.
-- @param fg The foreground (text) color
-- @param bg The background color.
-- @local
local function setColors(fg, bg)
  term.setBackgroundColor(bg)
  term.setTextColor(fg)
end

--- Create a dialog element, and render it.
-- @param title The title of the dialog UI.
-- @param subtext The description of the dialog.
-- @param button The button worker that the UI's OK button will be put in.
-- @param ?width Width of the dialog. Default of 26.
-- @param ?height Height of the dialog. Default of 10.
-- @param ?backgroundColor Background color of the dialog. Default color is white.
-- @param ?borderColor Color of the border and the area where the button is contained. Default color is light gray.
-- @param ?textColor Color of the subtext in the dialog. Default color is gray.
-- @param ?titleColor Color of the title in the dialog. Default color is black.
-- @param ?highlightColor Color of the button's border between mouse_click and mouse_up. Default color is gray.
-- @return A number which is the the second half the the button's ID. The way to find the ID of the button is `"ok-" .. id`. This is used to run a function when the OK button is pressed.
function dialogApi.create(title, subtext, button, width, height, backgroundColor, borderColor, textColor, titleColor, highlightColor)
  -- @todo add custom buttons (for cancel, differnet ok messages, etc)
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

  term.setCursorPos(hw - sX / 2 + 1, hh - math.floor(sY / 2) - 1)
  setColors(preColor, borderColor)
  term.write(("\143"):rep(sX))

  for i = hh - sY / 2, hh + sY / 2 do
    term.setCursorPos(hw - sX / 2, i)
    term.write("\149")
  end

  setColors(backgroundColor, borderColor)
  term.setCursorPos(hw - sX / 2 + 1, hh + sY / 2 - 3)
  term.write(("\143"):rep(sX))

  setColors(borderColor, preColor)
  for i = hh - sY / 2, hh + sY / 2 do
    term.setCursorPos(hw + sX / 2 + 1, i)
    term.write("\149")
  end

  term.setCursorPos(hw - sX / 2 + 1, hh + math.floor(sY / 2) + 1)
  term.write(("\131"):rep(sX))

  local epoch = os.epoch("utc")
  paintutils.drawFilledBox(hw - sX / 2 + 1, hh + sY / 2 - 2, hw + sX / 2, hh + sY / 2, borderColor)
  button.add("ok-" .. epoch, "OK", math.floor(hw + sX / 2 - 5), math.floor(hh + sY / 2 - 2), backgroundColor, textColor, highlightColor, colors.gray)
  button.render({"ok-" .. epoch})

  setColors(titleColor, backgroundColor)
  term.setCursorPos(hw - sX / 2 + 2, hh - sY / 2 + 1)
  term.write(title)

  setColors(textColor, backgroundColor)
  term.setCursorPos(hw - sX / 2 + 2, hh - sY / 2 + 3)
  term.write(subtext)

  return epoch
end

return dialogApi