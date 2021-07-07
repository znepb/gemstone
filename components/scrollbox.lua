--- A scroll box.
-- @module[kind=component] scrollbox

local args = { ... }
local path = fs.combine(args[2], "../../")

local scrollbox = {}
local marquee = require("/" .. fs.combine(path, "components", "marquee"))
local scrollboxes = {}

--- Create a new scroll box.
-- @tparam number id The ID of the scrollbox.
-- @tparam number x The X position of the scrollbox.
-- @tparam number y The Y position of the scrollbox.
-- @tparam number w The width of the scrollbox.
-- @tparam number h The height of the scrollbox.
-- @tparam table parent The parent terminal of the scrollbox.
-- @return A terminal-like instance, with a couple more functions.
function scrollbox.create(id, x, y, w, h, parent)
  local newScrollbox = marquee.create(x, y, w, h, parent)
  scrollboxes[id] = {
    scrollbox = newScrollbox,
    x = x,
    y = y,
    w = w,
    h = h
  }
  return newScrollbox
end

--- Removes a scrollbox's event listener. Notice this does not clear it, you will have to clear the screen to remove it.
-- @tparam number id The ID of the scroll box.
function scrollbox.remove(id)
  scrollboxes[id] = nil
end

--- Initalizes the event manager for the scrollbox.
-- @tparam table manager The event manager.
function scrollbox.init(manager)
  manager.inject(function(e)
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
  end)
end

return scrollbox