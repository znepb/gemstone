--- A rather simple to not have a lot of functions in parallel with a main event listener.
-- @module event
-- @author znepb

local event = {}
local eventFunctions = {}

--- Injects a function into the event manager.
-- @param func The function to add to the manager.
function event.inject(func)
  table.insert(eventFunctions, func)
end

--- Listens for events. Put this in parallel with your main event manager, or even better: inject your code into the event manager!
function event.listen()
  while true do
    local e = {os.pullEvent()}

    for i, v in pairs(eventFunctions) do v(e) end
  end
end

return event