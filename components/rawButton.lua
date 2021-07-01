--- The button module, but without a border and text.
-- @module rawButton
-- @author znepb

local rawButton = {}

local buttons = {}
local enabledButtons = {}

--- Disables a button.
-- @param id The ID of the button to disable.
function rawButton.disableButton(id)
  for i, v in pairs(enabledButtons) do
    if v == id then
      table.remove(enabledButtons, i)
      break
    end
  end
end

--- Creates a new button
-- @param id The ID of the button to create.
-- @param x The X position of the button.
-- @param y The Y position of the button.
-- @param width The width of the button.
-- @param height The height of the button.
function rawButton.add(id, x, y, width, height)
  buttons[id] = {
    id = id,
    x = x,
    y = y,
    width = width,
    height = height
  }
end

--- Enables a button.
-- @param id The ID of the button to enable.
function rawButton.enableButton(id)
  table.insert(enabledButtons, id)
end

--- Enables multiple buttons.
-- @param ids A table of IDs to enable.
function rawButton.enableButtons(ids)
  for i, v in pairs(ids) do
    table.insert(enabledButtons, v)
  end
end

--- Disables all buttons in the manager.
function rawButton.disableAll()
  enabledButtons = {}
end

--- Initalizes the event manager.
-- @param manager The event manager.
function rawButton.init(manager)
  manager.inject(function(re)
    local e, b, x, y = re[1], re[2], re[3], re[4]

    if e == "mouse_up" then
      if b == 1 then
        for i, v in pairs(enabledButtons) do
          local b = buttons[v]
          if x >= b.x and y >= b.y and x <= b.x + b.width - 1 and y <= b.y + b.height - 1 then
            os.queueEvent("button_click", b.id, x, y)
          end
        end
      end
    elseif e == "mouse_click" then
      if b == 1 then
        for i, v in pairs(enabledButtons) do
          local b = buttons[v]
          if x >= b.x and y >= b.y and x <= b.x + b.width - 1 and y <= b.y + b.height - 1 then
            os.queueEvent("button_down", b.id, x, y)
          end
        end
      end
    end
  end)
end

return rawButton