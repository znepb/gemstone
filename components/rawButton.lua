--- The button module, but without a border and text.
-- @module[kind=component] rawButton

local rawButton = {}

local buttons = {}
local enabledButtons = {}

--- Disables a button.
-- @tparam number id The ID of the button to disable.
function rawButton.disableSingle(id)
  for i, v in pairs(enabledButtons) do
    if v == id then
      table.remove(enabledButtons, i)
      break
    end
  end
end

--- Disables a button.
-- @tparam number id The ID of the button to disable.
function rawButton.disable(ids)
  for i, v in pairs(ids) do
    rawButton.disableSingle(v)
  end
end

--- Disables all buttons in the manager.
function rawButton.disableAll()
  enabledButtons = {}
end

--- Enables a button.
-- @tparam number id The ID of the button to enable.
function rawButton.enableSingle(id)
  table.insert(enabledButtons, id)
end

--- Enables multiple buttons.
-- @tparam table ids A table of IDs to enable.
function rawButton.enable(ids)
  for i, v in pairs(ids) do
    table.insert(enabledButtons, v)
  end
end

--- Creates a new button
-- @tparam number id The ID of the button to create.
-- @tparam number x The X position of the button.
-- @tparam number y The Y position of the button.
-- @tparam number width The width of the button.
-- @tparam number height The height of the button.
-- @tparam[opt] table term Currently unused. Will be used in the future.
-- @tparam[opt] string eventNamePrefix Changes the name of the event when dispatched. This can be used for using this module in other button-related modules, like the context menu component.
function rawButton.add(id, x, y, width, height, uTerm, eventNamePrefix)
  buttons[id] = {
    id = id,
    x = x,
    y = y,
    width = width,
    height = height,
    uTerm = uTerm,
    eventNamePrefix = eventNamePrefix or ""
  }
end

--- Initalizes the event manager.
-- @tparam table manager The event manager.
function rawButton.init(manager)
  manager.inject(function(re)
    local e, b, x, y = re[1], re[2], re[3], re[4]

    if e == "mouse_up" then
      if b == 1 then
        for i, v in pairs(enabledButtons) do
          local b = buttons[v]
          if x >= b.x and y >= b.y and x <= b.x + b.width - 1 and y <= b.y + b.height - 1 then
            os.queueEvent(b.eventNamePrefix .. "button_click", b.id, x, y)
          end
        end
      end
    elseif e == "mouse_click" then
      if b == 1 then
        for i, v in pairs(enabledButtons) do
          local b = buttons[v]
          if x >= b.x and y >= b.y and x <= b.x + b.width - 1 and y <= b.y + b.height - 1 then
            os.queueEvent(b.eventNamePrefix .. "button_down", b.id, x, y)
          end
        end
      end
    end
  end)
end

return rawButton