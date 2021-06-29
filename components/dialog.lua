local dialogApi = {}

local function setColors(fg, bg)
  term.setBackgroundColor(bg)
  term.setTextColor(fg)
end

function dialogApi.create(title, subtext, button)
  local w, h = term.getSize()

  local sX, sY = 26, 10

  local hw, hh = w / 2, h / 2

  paintutils.drawFilledBox(hw - (sX / 2) + 1, hh - (sY / 2), hw + (sX / 2), hh + (sY / 2), colors.white)

  term.setCursorPos(hw - sX / 2 + 1, hh - math.floor(sY / 2) - 1)
  setColors(colors.white, colors.lightGray)
  term.write(("\143"):rep(sX))

  term.setCursorPos(hw - sX / 2 + 1, hh + sY / 2 - 3)
  term.write(("\143"):rep(sX))

  for i = hh - sY / 2, hh + sY / 2 do
    term.setCursorPos(hw - sX / 2, i)
    term.write("\149")
  end

  setColors(colors.lightGray, colors.white)
  for i = hh - sY / 2, hh + sY / 2 do
    term.setCursorPos(hw + sX / 2 + 1, i)
    term.write("\149")
  end

  term.setCursorPos(hw - sX / 2 + 1, hh + math.floor(sY / 2) + 1)
  term.write(("\131"):rep(sX))

  local epoch = os.epoch("utc")
  paintutils.drawFilledBox(hw - sX / 2 + 1, hh + sY / 2 - 2, hw + sX / 2, hh + sY / 2, colors.lightGray)
  button.add("ok-" .. epoch, "OK", math.floor(hw + sX / 2 - 5), math.floor(hh + sY / 2 - 2), colors.white, colors.gray, colors.gray)
  button.render({"ok-" .. epoch})

  setColors(colors.black, colors.white)
  term.setCursorPos(hw - sX / 2 + 2, hh - sY / 2 + 1)
  term.write(title)

  setColors(colors.gray, colors.white)
  term.setCursorPos(hw - sX / 2 + 2, hh - sY / 2 + 3)
  term.write(subtext)

  return epoch
end

return dialogApi