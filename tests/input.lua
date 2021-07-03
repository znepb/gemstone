xpcall(function()
  local input = require(".drawing.components.input")
  local dialog = require(".drawing.components.dialog")
  local theme = require(".drawing.themes.light")
  local event = require(".drawing.lib.event")
  local scrollbox = require(".drawing.components.scrollbox")
  local button = require(".drawing.components.button")

  scrollbox.init(event)
  input.init(event)
  button.init(event)

  input.create("dialogInput", 2, 2, 30, theme, "Enter some text!")
  button.add("inputContinue", "Submit", 33, 2, theme)

  local function render()
    term.setBackgroundColor(colors.white)
    term.clear()
    input.render("dialogInput")
    button.render({"inputContinue"})
  end

  render()

  parallel.waitForAll(event.listen, function()
    while true do
      local e = {os.pullEvent()}

      if e[1] == "button_click" then
        if e[2] == "inputContinue" then
          local id = dialog.create("Entered Text", "You entered: " .. (input.getText("dialogInput") or "Nothing"), button, scrollbox, theme)
          
          repeat local _, button = os.pullEvent("button_click") until button == "ok-" .. id
          input.clear("dialogInput")
          render()
        end
      end
    end
  end)
end, function(err)
  term.setBackgroundColor(colors.black)
  term.clear()
  term.setCursorPos(1, 1)
  printError(err)
  printError(debug.traceback())
end)
