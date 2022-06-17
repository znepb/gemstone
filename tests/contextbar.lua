local contextBar = require(".gemstone.components.contextbar")
local theme = require(".gemstone.themes.light")
local event = require(".gemstone.lib.event")

contextBar.create({
  {
    name = "File",
    id = "file",
    items = {
      {
        name = "Create Shortcut",
        id = "shortcut"
      },
      {
        name = "Delete",
        id = "delete"
      },
      {
        name = "Rename",
        id = "rename"
      },
      {
        name = "Properties",
        id = "properties"
      },
      {
        name = "=sep",
        id = ""
      },
      {
        name = "Close",
        id = "close"
      }
    }
  },
  {
    name = "Edit",
    id = "edit",
    items = {
      { name = "Undo", id = "undo" },
      { name = "=sep", id = "" },
      { name = "Cut", id = "cut" },
      { name = "Copy", id = "copy" },
      { name = "Paste", id = "paste" },
      { name = "Paste Shortcut", id = "shortcutPaste" },
      { name = "=sep", id = "" },
      { name = "Select All", id = "selectAll" },
      { name = "Invert Selection", id = "invertSelection" }
    }
  },
  {
    name = "View",
    id = "view",
    items = {
      { name = "Refresh", id = "reload" }
    }
  },
  {
    name = "Help",
    id = "help",
    items = {
      { name = "About", id = "about" }
    }
  }
}, theme, colors.white)

contextBar.init(event)

local function render()
  term.setBackgroundColor(colors.white)
  term.clear()
  contextBar.render()

  local menuManager = contextBar.getMenuManager()
  if menuManager.exists(contextBar.getActiveMenuId()) then
    term.setBackgroundColor(colors.white)
    menuManager.render(contextBar.getActiveMenuId())
  end

  term.setBackgroundColor(colors.white)
end

render()

event.inject(function(e)
  if e[1] == "context_menu_dismiss" then
    render()
  end
end)

event.listen()