--- Context menus, with seperators, and buttons. Fancy!
-- @module[kind=component] contextMenu

local args = { ... }
local path = fs.combine(args[2], "../../")

local contextMenu = {}
local menus = {}
local common = require("/" .. fs.combine(path, "lib", "common"))

--- Renders a context menu.
-- @tparam number id The ID of the context menu to render.
function contextMenu.render(id)
  local maxWidth = 0
  local m = menus[id]

  local bgColor = term.getBackgroundColor()

  for i, v in pairs(m.elements) do
    maxWidth = math.max(maxWidth, #v.name)
  end

  common.drawBorder(bgColor, m.backgroundColor, m.x, m.y, maxWidth + 2, #m.elements + 2, nil, true, true)
  paintutils.drawFilledBox(m.x + 1, m.y + 1, m.x + maxWidth, m.y + #m.elements, m.backgroundColor)

  for i, v in pairs(m.elements) do
    term.setCursorPos(m.x + 1, m.y + i)
    if v.name == "=sep" then
      term.write(("\140"):rep(maxWidth))
    else
      if v.disabled then
        term.setTextColor(m.disabledColor)
        term.write(v.name)
      else
        term.setTextColor(m.activeColor)
        term.write(v.name)
      end
    end
  end

  menus[id].w = maxWidth + 2
  menus[id].h = #m.elements + 2
end

--- Dismisses a context menu.
-- @tparam number id The context menu to dismiss.
function contextMenu.dismiss(id)
  menus[id] = nil
  os.queueEvent("context_menu_dismiss", id)
end

--- Checks if a context menu exists.
-- @tparam number id The ID of the context menu to check the existance of.
-- @return Whether or not the context menu exists.
function contextMenu.exists(id)
  return menus[id] ~= nil
end

--- Creates a new context menu.
-- @tparam number id The ID of the context menu. When a context menu item is selected, a event with the name `context_menu_select` will be dispatched, with a first argument being the context menu id, and the second being thr button id.
-- @tparam number x The X position of the context menu.
-- @tparam number y The Y position of the context menu.
-- @tparam table elements The elements that will be put inside the context menu. See tests/contextMenu.lua for an example.
-- @tparam table theme The theme to use for the context menu.
-- @tparam[opt] table presist If true, the context menu will stick around after being clicked or clicked outside of.
function contextMenu.create(id, x, y, elements, theme, presist)
  menus[id] = {
    x = x,
    y = y,
    elements = elements,
    persist = presist,
    backgroundColor = theme.contextMenu.background,
    disabledColor = theme.contextMenu.disabled,
    activeColor = theme.contextMenu.active,
    selectedColor = theme.contextMenu.selected,
    selectedText = theme.contextMenu.selectedText
  }
  contextMenu.render(id)
end

--- Initalizes the context menu's event manager.
-- @tparam table manager The event manager instance to use.
function contextMenu.init(manager)
  manager.inject(function(e)
    if e[1] == "mouse_click" then
      local m, x, y = e[2], e[3], e[4]
      if m == 1 then
        for mid, v in pairs(menus) do
          if x >= v.x and x <= v.x + v.w - 1 and y >= v.y and y <= v.y + v.h - 1 then
            for i, e in pairs(v.elements) do
              if e.name ~= "=sep" and not e.disabled then
                if y == v.y + i then
                  term.setCursorPos(v.x + 1, v.y + i)
                  term.setBackgroundColor(v.selectedColor)
                  term.setTextColor(v.selectedText)
                  term.write(e.name .. (" "):rep(v.w - #e.name - 2))
                end
              end
            end
          end
        end
      end
    elseif e[1] == "mouse_up" then
      local m, x, y = e[2], e[3], e[4]

      if m == 1 then
        for mid, v in pairs(menus) do
          if x >= v.x and x <= v.x + v.w - 1 and y >= v.y and y <= v.y + v.h - 1 then
            for i, e in pairs(v.elements) do
              if y == v.y + i and not e.disabled then
                os.queueEvent("context_menu_select", mid, e.id)
              end
            end
          end

          if v.persist == nil or v.persist == false then
            contextMenu.dismiss(mid)
          end
        end
      end
    end
  end)
end

return contextMenu