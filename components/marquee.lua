--- Basicly the scroll box, but without event listening, so technically it can be used as a marquee sign, etc.
-- @module[kind=component] marquee

local marquee = {}

--- Creates a marquee frame.
-- @tparam number x The X position of the marquee frame.
-- @tparam number y The Y position of the marquee frame.
-- @tparam number w The width of the marquee frame.
-- @tparam number h The height of the marquee frame.
-- @tparam table parent The parent term of the marquee window.
-- @return A 500x500 terminal which can be used like a normal terminal.
function marquee.create(x, y, w, h, parent)
  local parentWin = window.create(parent, x, y, w, h)
  local scrollWin = window.create(parentWin, 1, 1, 500, 500)

  local internal = {
    scrollWin = scrollWin,
    scrollX = 1,
    scrollY = 1,
    maxWidth = 0,
    maxHeight = 0
  }

  local sbterm = {
    nativePaletteColour = scrollWin.nativePaletteColor,
    nativePaletteColor = scrollWin.nativePaletteColor,
    write = function(text)
      internal.scrollWin.write(text)
      local x, y = internal.scrollWin.getCursorPos()
      internal.maxWidth = math.max(internal.maxWidth, x)
      internal.maxHeight = math.max(internal.maxHeight, y)
      internal.scrollWin.redraw()
    end,
    scroll = function(y, x)
      -- x and y is inverted for compatibility
      parentWin.clear()
      internal.scrollX = internal.scrollX + (x or 0)
      internal.scrollY = internal.scrollY + (-y or 0)
      internal.scrollWin.reposition(internal.scrollX, internal.scrollY)
      internal.scrollWin.redraw()
    end,
    getCursorPos = scrollWin.getCursorPos,
    setCursorPos = scrollWin.setCursorPos,
    getCursorBlink = scrollWin.getCursorBlink,
    setCursorBlink = scrollWin.setCursorBlink,
    getSize = function()
      return internal.maxWidth, internal.maxHeight
    end,
    clear = function()
      internal.scrollWin.clear()
      internal.maxWidth = 0
      internal.maxHeight = 0
    end,
    clearLine = scrollWin.clearLine,
    getTextColour = scrollWin.getTextColor,
    getTextColor = scrollWin.getTextColor,
    setTextColour = scrollWin.setTextColor,
    setTextColor = scrollWin.setTextColor,
    getBackgroundColour = scrollWin.getBackgroundColor,
    getBackgroundColor = scrollWin.getBackgroundColor,
    setBackgroundColour = scrollWin.setBackgroundColor,
    setBackgroundColor = scrollWin.setBackgroundColor,
    isColour = scrollWin.isColor,
    isColor = scrollWin.isColor,
    blit = function( ... )
      internal.scrollWin.blit( ... )
      local x, y = internal.scrollWin.getCursorPos()
      internal.maxWidth = math.max(internal.maxWidth, x)
      internal.maxHeight = math.max(internal.maxHeight, y)
      internal.scrollWin.reposition(internal.scrollX, internal.scrollY)
    end,
    setPaletteColor = scrollWin.setPaletteColor,
    setPaletteColour = scrollWin.setPaletteColor,
    redirect = scrollWin.redirect,
    current = scrollWin.current,
    native = scrollWin.native,
    getScroll = function()
      return internal.scrollX, -internal.scrollY
    end,
    setVisible = function(value)
      parentWin.setVisible(value)
    end
  }
  return sbterm
end

return marquee