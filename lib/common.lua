--- A common module for other components to piggyback off of.
-- @module[kind=library] common

local common = {}

--- Internal function for setting colors.
-- @tparam number fg The foreground (text) color
-- @tparam number bg The background color.
function common.setColors(fg, bg)
  term.setBackgroundColor(bg)
  term.setTextColor(fg)
end

--- Draws a fancy rounded (or not) border.
-- @tparam number background The background color of the border.
-- @tparam number foreground The foreground color of the border.
-- @tparam number x The X position of the border.
-- @tparam number y The Y position of the border.
-- @tparam number w The width of the border. This should be at least 3.
-- @tparam number h The height of the border. This should be at least 3.
-- @tparam[opt] boolean ?dialog If true, this moves the border's bottom up one subpixel. This is used by the dialog element.
-- @tparam[opt] boolean ?large Makes the border a little larger. This is used for inputs.
-- @tparam[opt] boolean ?filled Fills in the edges if the large parameter is true. Note that this does not fill in the area of the border.
-- @tparam[opt] boolean ?squareEdges If true, the rounded corners of the UIs will be disabled, and will be square instead.
function common.drawBorder(background, foreground, x, y, w, h, dialog, large, filled, squareEdges)
  if large then
    if filled then
      common.setColors(background, foreground)
      term.setCursorPos(x, y)
      term.write(squareEdges and "\131" or "\135")
      term.write(("\131"):rep(w - 2))
      term.write(squareEdges and "\131" or  "\139")

      for i = 1, h - 2 do
        common.setColors(background, foreground)
        term.setCursorPos(x, y + i)
        term.write(" ")
        term.setCursorPos(x + w - 1, y + i)
        term.write(" ")
      end

      term.setCursorPos(x, y + h - 1)
      common.setColors(foreground, background)
      term.write(squareEdges and "\143" or "\139")
      term.write(("\143"):rep(w - 2))
      term.write(squareEdges and "\143" or "\135")
    else
      common.setColors(foreground, background)
      term.setCursorPos(x, y)
      term.write(squareEdges and "\156" or "\152")
      term.write(("\140"):rep(w - 2))
      common.setColors(background, foreground)
      term.write(squareEdges and "\147" or"\155")

      for i = 1, h - 2 do
        common.setColors(foreground, background)
        term.setCursorPos(x, y + i)
        term.write("\149")
        common.setColors(background, foreground)
        term.setCursorPos(x + w - 1, y + i)
        term.write("\149")
      end

      term.setCursorPos(x, y + h - 1)
      common.setColors(foreground, background)
      term.write(squareEdges and "\141" or "\137")
      term.write(("\140"):rep(w - 2))
      term.write(squareEdges and "\142" or "\134")
    end
  else
    if squareEdges then
      common.setColors(background, foreground)
      term.setCursorPos(x, y)
      term.write("\159")
      common.setColors(foreground, background)
      term.setCursorPos(x + w - 1, y)
      term.write("\144")

      if not dialog then
        term.setCursorPos(x + w - 1, y + h - 1)
        term.write("\129")

        term.setCursorPos(x, y + h - 1)
        term.write("\130")
      end
    end

    common.setColors(background, foreground)

    for i = y + 1, y + h - 2 do
      term.setCursorPos(x, i)
      term.write("\149")
    end

    term.setCursorPos(x + 1, y)
    term.write(("\143"):rep(w - 2))

    common.setColors(foreground, background)

    for i = y + 1, y + h - 2 do
      term.setCursorPos(x + w - 1, i)
      term.write("\149")
    end

    if dialog then
      if squareEdges then
        term.setCursorPos(x, y + h - 2)
        common.setColors(background, foreground)
        term.write("\149")
        term.write(("\143"):rep(w - 2))
        common.setColors(foreground, background)
        term.write("\149")
      else
        term.setCursorPos(x, y + h - 2)
        term.write("\138")
        term.write(("\143"):rep(w - 2))
        term.write("\133")
      end
    else
      term.setCursorPos(x + 1, y + h - 1)
      term.write(("\131"):rep(w - 2))
    end
  end
end

--- A function that will chop off text if it's longer than a specified number.
-- @tparam string text The text to check for overflow.
-- @tparam number max The maximum size of the text.
function common.textOverflow(text, max)
  if #text >= max then
    return text:sub(1, max)
  else
    return text
  end
end

return common

