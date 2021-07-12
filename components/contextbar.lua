--- Menu bar? Context bar? I don't know, It's one of those things says file, edit, help etc. And it's customizable!
-- @module[kind=component] contextbar

local contextBar = {}
local bar = {}

local args = { ... }
local path = fs.combine(args[2], "../../")

local contextMenu = require("/" .. fs.combine(path, "components", "contextMenu"))
local rawButton = require("/" .. fs.combine(path, "components", "rawButton"))

--- Creates a context bar. Note, only one is supported per application.
-- @tparam table options A list of button to put on the context bar.
-- @tparam table theme The theme to use.
-- @tparam[opt] number baseColor The color that will be set when a menu is opened.
-- @usage Creates a context bar.
--    
--     contextBar.create({
--       name = "File",
--       id = "file",
--       items = {
--         -- A table of context menu objects.
--       }
--     })
--
-- @see contextMenu
function contextBar.create(options, theme, baseColor)
  bar = {
    options = options,
    theme = theme,
    baseColor = baseColor,
    activeMenuId = nil
  }
end

--- Modifys an existing item in the context bar.
-- @tparam number menuId The ID of the menu to set.
-- @tparam number buttonId The ID of the button to modify.
-- @tparam table set What to set the updated context selection to.
function contextBar.modify(menuId, buttonId, set)
  for i, v in pairs(bar.options) do
    if v.id == menuId then
      for i2, v2 in pairs(v) do
        if v2.id == buttonId then
          bar.options[i][i2] = set
          break
        end
      end
      break
    end
  end
end

--- Gets the context menu manager
-- @return An instance of the contextMenu component.
-- @see contextMenu
function contextBar.getMenuManager()
  return contextMenu
end

--- Gets the context menu's ID.
-- @return The ID of the currently active menu.
function contextBar.getActiveMenuId()
  return bar.activeMenuId
end

--- Renders the context bar.
function contextBar.render()
  term.setCursorPos(1, 1)
  term.setBackgroundColor(bar.theme.contextMenu.background)
  term.setTextColor(bar.theme.contextMenu.active)
  term.clearLine()

  for i, v in pairs(bar.options) do
    local p = term.getCursorPos()

    if bar.activeMenuId == v.id then
      term.setBackgroundColor(bar.theme.contextMenu.selected)
      term.setTextColor(bar.theme.contextMenu.selectedText)
    else
      term.setBackgroundColor(bar.theme.contextMenu.background)
      term.setTextColor(bar.theme.contextMenu.active)
    end
    
    term.write((" %s "):format(v.name))
    bar.options[i].position = p
    rawButton.add(v.id, p, 1, #v.name + 2, 1, nil, "__gemstone_context_bar_")
    rawButton.enableSingle(v.id)
  end
end

--- Initalizes the event manager.
-- @tparam table manager The event manager to use.
-- @see event
function contextBar.init(manager)
  rawButton.init(manager)
  contextMenu.init(manager)
  manager.inject(function(e)
    if e[1] == "__gemstone_context_bar_button_click" then
      for i, v in pairs(bar.options) do
        if v.id == e[2] then
          local pre = bar.baseColor or term.getBackgroundColor()
          os.queueEvent("context_bar", e[2])
          term.setCursorPos(v.position, 1)
          term.setBackgroundColor(bar.theme.contextMenu.selected)
          term.setTextColor(bar.theme.contextMenu.selectedText)
          term.write(" " .. v.name .. " ")
          term.setBackgroundColor(pre)
          contextMenu.create(v.id, v.position, 2, v.items, bar.theme)
          bar.activeMenuId = v.id
        end
      end
    elseif e[1] == "context_menu_dismiss" then
      if e[2] == bar.activeMenuId then bar.activeMenuId = nil end
    end
  end)
end

return contextBar