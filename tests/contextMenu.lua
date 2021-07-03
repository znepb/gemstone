local contentMenu = require(".drawing.components.contextMenu")
local manager = require(".drawing.lib.event")
local theme = require(".drawing.themes.light")
term.clear()
local active

term.setBackgroundColor(colors.white)
term.clear()

local function createMenu(x, y)
  active = "rightClickContext-" .. os.epoch()
  contentMenu.create(active, x, y, {
    {
      name = "Run",
      id = "run"
    },
    {
      name = "Edit",
      id = "edit"
    },
    {
      name = "Open With...",
      id = "openWith"
    },
    {
      name = "=sep",
      id = "seperator"
    },
    {
      name = "Cut",
      id = "cut"
    },
    {
      name = "Copy",
      id = "copy"
    },
    {
      name = "Paste",
      id = "paste",
      disabled = true
    },
    {
      name = "Rename",
      id = "rename"
    },
    {
      name = "Delete",
      id = "delete"
    },
    {
      name = "Create Shortcut",
      id = "shortcut"
    },
    {
      name = "=sep",
      id = "seperator"
    },
    {
      name = "Properties",
      id = "properties"
    }
  }, theme)
end

local lastMenu, lastButton
contentMenu.init(manager)

parallel.waitForAny(manager.listen, function()
  while true do
    local e = {os.pullEvent()}

    if e[1] == "context_menu_select" then
      lastMenu, lastButton = e[2], e[3]
    elseif e[1] == "mouse_click" then
      local m, x, y = e[2], e[3], e[4]
      if m == 2 then
        if active and contentMenu.exists(active) then
          contentMenu.dismiss(active)
        end
        createMenu(x, y)
      end
    elseif e[1] == "context_menu_dismiss" then
      term.setBackgroundColor(colors.white)
      term.clear()
      term.setCursorPos(1, 1)
      term.setTextColor(colors.gray)
      if lastButton then
        term.write(lastMenu .. ", " .. lastButton)
      end

      if active and contentMenu.exists(active) then
        contentMenu.render(active)
      end
    end
  end
end)