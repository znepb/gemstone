--- A scroll box.
-- @author znepb
-- @module scrollbox

local scrollbox = {}
local marquee = require("marquee")
local scrollboxes = {}

--- Create a new scroll box.
-- @param x The X position of the scrollbox.
-- @param y The Y position of the scrollbox.
-- @param w The width of the scrollbox.
-- @param h The height of the scrollbox.
-- @param parent The parent terminal of the scrollbox.
-- @return A terminal-like instance, with a couple more functions.
function scrollbox.create(x, y, w, h, parent)
  local newScrollbox = marquee.create(x, y, w, h, parent)
  table.insert(scrollboxes, {
    scrollbox = newScrollbox,
    x = x,
    y = y,
    w = w,
    h = h
  })
  return newScrollbox
end

--- The event listener for the scrollbox. Put this in parallel with your event loop.
function scrollbox.update()
  while true do
    local e = {os.pullEvent()}

    if e[1] == "mouse_scroll" then
      local d, x, y = e[2], e[3], e[4]
      for i, v in pairs(scrollboxes) do
        if x >= v.x and x <= v.x + v.w - 1 and y >= v.y and y <= v.y + v.h - 1 then
          local sX, sY = v.scrollbox.getScroll()
          local ssX, ssY = v.scrollbox.getSize()

          local canscroll = false
          if d == 1 then -- down
            canscroll = sY < ssY - 2
          elseif d == -1 then -- up
            canscroll = sY >= 0
          end

          if canscroll == true then v.scrollbox.scroll(d) end
        end
      end
    end
  end
end

return scrollbox