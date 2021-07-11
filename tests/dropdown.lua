local eventmgr = require(".drawing.lib.event")
local dropdown = require(".drawing.components.dropdown")
local theme = require(".drawing.themes.light")

dropdown.add("dropdown", 2, 2, "Select", {
  "Option 1",
  "Option 2",
  "Option 3",
  "Option 4",
  "Option 5"
}, theme)

local function render()
  term.setBackgroundColor(colors.white)
  term.clear()

  dropdown.renderSingle("dropdown")

  term.setBackgroundColor(colors.white)
end

render()

eventmgr.inject(function(e)
  if e[1] == "dropdown_select" then
    render()
    term.setCursorPos(1, 1)
    print("DropDown Select", e[2], e[3])
  end
end)

dropdown.init(eventmgr)
eventmgr.listen()