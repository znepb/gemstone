--- A dropdown element to select many things from. Currently buggy and unfinished.
-- @module[kind=component] dropdown

local dropdown = {}
local dropdowns = {}

local button = require(".drawing.components.button")
local contextMenu = require(".drawing.components.contextMenu")

--- Creates a new dropdown.
-- @tparam string id The ID of the new dropdown.
-- @tparam number x The X position of the dropdown's button.
-- @tparam number y The Y position of the dropdown's button.
-- @tparam string title The text that will display on the dropdown's button.
-- @tparam table objects A table of strings that will be displayed when the dropdown is clicked.
-- @tparam table theme The theme to use.
function dropdown.add(id, x, y, title, objects, theme)
  local newObjects = {}

  for i, v in pairs(objects) do
    table.insert(newObjects, {
      name = v,
      id = v
    })
  end
  
  dropdowns[id] = {
    id = id,
    x = x,
    y = y,
    title = title,
    theme = theme,
    objects = newObjects,
    button = button.add(id .. "-dropdown-button", title .. " " .. string.char(0x1F), x, y, theme)
  }
end

--- Draws a single dropdown.
-- @tparam string id The ID of the dropdown to draw.
function dropdown.renderSingle(id)
  local d = dropdowns[id]
  d.preRender = term.getBackgroundColor()

  button.renderSingle(id .. "-dropdown-button")
  button.enableSingle(id .. "-dropdown-button")
end

--- Initlaises the dropdown to the event manager.
-- @tparam table manager The manager to use.
function dropdown.init(manager)
  button.init(manager)
  contextMenu.init(manager)
  manager.inject(function(e)
    if e[1] == "button_click" then
      if e[2]:match("%-dropdown%-button$") then
        local id = e[2]:gsub("%-dropdown%-button$", "")
        local d = dropdowns[id]
        term.setBackgroundColor(d.preRender)
        contextMenu.create("dropdown-content-" .. id, d.x + 1, d.y + 3, d.objects, d.theme)
        os.queueEvent("dropdown_open", id)
      end
    elseif e[1] == "context_menu_select" then
      if e[2]:match("^dropdown%-content%-") then
        local id = e[2]:gsub("^dropdown%-content%-", "")
        os.queueEvent("dropdown_select", id, e[3])
      end
    end
  end)
end

return dropdown