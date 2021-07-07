--- A fancy looking input with a new read function, which includes a limit for the size.
-- @module[kind=component] input

local args = { ... }
local path = fs.combine(args[2], "../../")

local input = {}
local common = require("/" .. fs.combine(path, "lib", "common"))

local inputs = {}
local activeInput

--- Basicly, CC's read function with a width parameter.
-- @tparam string id The ID of the input that is being focused.
-- @tparam[opt] byte _sReplaceChar The character to hide all the characters.
-- @tparam[opt] table _tHistory A table containing a history for the textbox.
-- @tparam[opt] func _fnComplete A function that is random when the text is completed. The only parameter is the line.
-- @tparam[opt] string _sDefault The default text.
-- @tparam[opt] number _nLimit The size limit of the read window.
-- @return The text inputted.
function input.read(id, _sReplaceChar, _tHistory, _fnComplete, _sDefault, _nLimit)
  term.setCursorBlink(true)

  activeInput = {
    id = id
  }

  activeInput.w = _nLimit or term.getSize()

  activeInput._tHistory = _tHistory

  if type(_sDefault) == "string" then
    activeInput.sLine = _sDefault
  else
    activeInput.sLine = ""
  end
  activeInput.nPos, activeInput.nScroll = #activeInput.sLine, 0
  if _sReplaceChar then
    _sReplaceChar = string.sub(_sReplaceChar, 1, 1)
  end

  function activeInput.recomplete()
    if _fnComplete and activeInput.nPos == #activeInput.sLine then
      activeInput.tCompletions = _fnComplete(activeInput.sLine)
      if activeInput.tCompletions and #activeInput.tCompletions > 0 then
        activeInput.tCompletions = 1
      else
        activeInput.tCompletions = nil
      end
    else
      activeInput.tCompletions = nil
      activeInput.tCompletions = nil
    end
  end

  function activeInput.uncomplete()
    activeInput.tCompletions = nil
    activeInput.nCompletion = nil
  end

  function activeInput.complete(quiet)
    term.setCursorBlink(false)
    if quiet == nil then os.queueEvent("textbox_complete", activeInput.id, activeInput.sLine) end
    inputs[activeInput.id].defaultText = activeInput.sLine
    input.render(activeInput.id)
    activeInput = nil
  end

  activeInput.w = _nLimit or term.getSize()
  activeInput.sx = term.getCursorPos()

  function activeInput.redraw(_bClear)
    local cursor_pos = activeInput.nPos - activeInput.nScroll
    if activeInput.sx + cursor_pos >= activeInput.w then
      -- We've moved beyond the RHS, ensure we're on the edge.
      activeInput.nScroll = activeInput.sx + activeInput.nPos - activeInput.w
    elseif cursor_pos < 0 then
      -- We've moved beyond the LHS, ensure we're on the edge.
      activeInput.nScroll = activeInput.nPos
    end

    local _, cy = term.getCursorPos()
    term.setCursorPos(activeInput.sx, cy)
    local sReplace = _bClear and " " or _sReplaceChar
    if sReplace then
      term.write(
        common.textOverflow(
          string.rep(sReplace, 
          math.max(#activeInput.sLine - activeInput.nScroll, 0)
        ), activeInput.w - 2)
      )
    else
      term.write(common.textOverflow(string.sub(activeInput.sLine, activeInput.nScroll + 1), activeInput.w - 2))
    end

    if activeInput.nCompletion then
      local sCompletion = activeInput.tCompletions[activeInput.nCompletion]
      local oldText, oldBg
      if not _bClear then
        oldText = term.getTextColor()
        oldBg = term.getBackgroundColor()
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.gray)
      end
      if activeInput.sReplace then
        term.write(string.rep(activeInput.sReplace, #sCompletion))
      else
        term.write(sCompletion)
      end
      if not _bClear then
        term.setTextColor(oldText)
        term.setBackgroundColor(oldBg)
      end
    end

    term.setCursorPos(activeInput.sx + activeInput.nPos - activeInput.nScroll, cy)
  end

  function activeInput.clear()
    activeInput.redraw(true)
  end

  activeInput.recomplete()
  activeInput.redraw()

  function activeInput.acceptCompletion()
    if activeInput.nCompletion then
      -- Clear
      activeInput.clear()

      -- Find the common prefix of all the other suggestions which start with the same letter as the current one
      local sCompletion = activeInput.tCompletions[activeInput.nCompletion]
      activeInput.sLine = activeInput.sLine .. sCompletion
      activeInput.nPos = #activeInput.sLine

      -- Redraw
      activeInput.recomplete()
      activeInput.redraw()
    end
  end
end

--- Renders a textbox.
-- @param id The ID of the textbox to render.
function input.render(id)
  local o = inputs[id]
  local bg = term.getBackgroundColor()

  paintutils.drawFilledBox(o.x + 1, o.y + 1, o.x + o.w - 2, o.y + 1, o.backgroundColor)
  common.drawBorder(colors.white, o.borderColor, o.x, o.y, o.w, 3, nil, true)

  if o.defaultText and o.defaultText ~= "" then
    term.setCursorPos(o.x + 1, o.y + 1)
    term.setTextColor(o.textColor)
    term.write(common.textOverflow(o.defaultText, o.w - 2))
  elseif o.placeholder then
    term.setTextColor(o.placeholderColor)
    term.setCursorPos(o.x + 1, o.y + 1)
    term.write(o.placeholder)
  end
end

--- Creates a new input box.
-- @tparam string id The ID of the text box. Used to remove, render, etc.
-- @tparam number x The X position of the textbox.
-- @tparam number y The Y position of the textbox.
-- @tparam number w The width of the textbox.
-- @tparam table theme The theme to use.
-- @tparam[opt] string placeholder The text that will be shown when no text has been entered. Note that this is overidden by default. The difference is that placeholder text does not persist when the textbox is selected.
-- @tparam[opt] table history The history table that the read function will draw from.
-- @tparam[opt] byte replace The replace character, mainly for passwords.
-- @tparam[opt] string default The default text that will be entered. For mor information on this, see the placeholder paramerer.
function input.create(id, x, y, w, theme, placeholder, history, replace, default)
  term.setTextColor(colors.gray)

  inputs[id] = {
    x = x,
    y = y,
    w = w,
    placeholder = placeholder,
    history = history,
    replaceCharacter = replace,
    defaultText = default,
    borderColor = theme.input.borderColor,
    borderSelectedColor = theme.input.borderColorActive,
    backgroundColor = theme.input.backgroundColorbgColor,
    textColor = theme.input.textColor,
    placeholderColor = theme.input.placeholderColor
  }

  input.render(id)
end

--- Gets the current text inside an input.
-- @tparam number id The ID of the input to retrieve text from.
function input.getText(id)
  return inputs[id].defaultText
end

--- Clears an input
-- @tparam number id The ID of the input to clear out.
function input.clear(id)
  inputs[id].defaultText = ""

  if activeInput and activeInput.complete then
    activeInput.complete(true)
  end
end

--- Removes an input.
-- @tparam number id The ID of the element to remove.
function input.remove(id)
  inputs[id] = nil
end

--- The event listener for the text box. When the text box has been finished, an event will be queued, entitled "textbox_complete". The first parameter is the ID of the textbox, and the second is the text entered into said textbox.
-- @tparam table manager The event manager.
function input.init(manager)
  manager.inject(function(e)
    if e[1] == "mouse_click" then
      local m, x, y = e[2], e[3], e[4]
      local found = false

      for i, v in pairs(inputs) do
        if x >= v.x and y >= v.y and y <= v.y + 2 and x <= v.x + v.w - 1 then
          if activeInput and activeInput.id ~= i or activeInput == nil then
            common.drawBorder(v.backgroundColor or colors.white, v.borderSelectedColor or colors.lightBlue, v.x, v.y, v.w, 3, nil, true)
            term.setTextColor(v.textColor or colors.gray)
            paintutils.drawFilledBox(v.x + 1, v.y + 1, v.x + v.w- 2, v.y + 1, v.backgroundColor or colors.white)
          
            if activeInput then activeInput.complete() end

            found = true
            term.setCursorPos(v.x + 1, v.y + 1)

            os.queueEvent("textbox_focus", i)
            input.read(i, v.replaceCharacter, v.history, nil, v.defaultText, v.w)
          end
        end
      end

      if found == false and activeInput then
        activeInput.complete()
      end
    end
  
    if activeInput then
      local sEvent, param, param1, param2 = e[1], e[2], e[3], e[4] -- Haha, no way I am going to rewrite this whole thing!

      if sEvent == "char" then
        -- Typed key
        activeInput.clear()
        activeInput.sLine = string.sub(activeInput.sLine, 1, activeInput.nPos) .. param .. string.sub(activeInput.sLine, activeInput.nPos + 1)
        activeInput.nPos = activeInput.nPos + 1
        activeInput.recomplete()
        activeInput.redraw()
      elseif sEvent == "paste" then
        -- Pasted text
        activeInput. clear()
        activeInput.sLine = string.sub(activeInput.sLine, 1, activeInput.nPos) .. param .. string.sub(activeInput.sLine, activeInput.nPos + 1)
        activeInput.nPos = activeInput.nPos + #param
        activeInput.recomplete()
        activeInput.redraw()
      elseif sEvent == "key" then
        if param == keys.enter or param == keys.numPadEnter then
          -- Enter/Numpad Enter
          if activeInput.nCompletion then
            activeInput.clear()
            activeInput.uncomplete()
            activeInput.redraw()
          end
          
          activeInput.complete()
        elseif param == keys.left then
          -- Left
          if activeInput.nPos > 0 then
              activeInput.clear()
              activeInput.nPos = activeInput.nPos - 1
              activeInput.recomplete()
              activeInput.redraw()
          end
        elseif param == keys.right then
          -- Right
          if activeInput.nPos < #activeInput.sLine then
            -- Move right
            activeInput.clear()
            activeInput.nPos = activeInput.nPos + 1
            activeInput.recomplete()
            activeInput.redraw()
          else
            -- Accept autocomplete
            activeInput.acceptCompletion()
          end
        elseif param == keys.up or param == keys.down then
          -- Up or down
          if activeInput.nCompletion then
            -- Cycle completions
            activeInput.clear()
            if param == keys.up then
              activeInput.nCompletion = activeInput.nCompletion - 1
              if activeInput.nCompletion < 1 then
                activeInput.nCompletion = #activeInput.tCompletions
              end
            elseif param == keys.down then
              activeInput.nCompletion = activeInput.nCompletion + 1
              if activeInput.nCompletion > #activeInput.tCompletions then
                activeInput.nCompletion = 1
              end
            end
            activeInput.redraw()
          elseif activeInput._tHistory then
            -- Cycle history
            activeInput.clear()
            if param == keys.up then
              -- Up
              if activeInput.nHistoryPos == nil then
                if #activeInput._tHistory > 0 then
                  activeInput.nHistoryPos = #activeInput._tHistory
                end
              elseif activeInput.nHistoryPos > 1 then
                activeInput.nHistoryPos = activeInput.nHistoryPos - 1
              end
            else
              -- Down
              if activeInput.nHistoryPos == #activeInput._tHistory then
                activeInput.nHistoryPos = nil
              elseif activeInput.nHistoryPos ~= nil then
                activeInput.nHistoryPos = activeInput.nHistoryPos + 1
              end
            end
            if activeInput.nHistoryPos then
              activeInput.sLine = activeInput._tHistory[activeInput.nHistoryPos]
              activeInput.nPos, activeInput.nScroll = #activeInput.sLine, 0
            else
              activeInput.sLine = ""
              activeInput.nPos, activeInput.nScroll = 0, 0
            end
            activeInput.uncomplete()
            activeInput.redraw()
          end

        elseif param == keys.backspace then
          -- Backspace
          if activeInput.nPos > 0 then
            activeInput.clear()
            activeInput.sLine = string.sub(activeInput.sLine, 1, activeInput.nPos - 1) .. string.sub(activeInput.sLine, activeInput.nPos + 1)
            activeInput.nPos = activeInput.nPos - 1
            if activeInput.nScroll > 0 then
              activeInput.nScroll = activeInput.nScroll - 1
            end
            activeInput.recomplete()
            activeInput.redraw()
          end
        elseif param == keys.home then
          -- Home
          if activeInput.nPos > 0 then
            activeInput.clear()
            activeInput.nPos = 0
            activeInput.recomplete()
            activeInput.redraw()
          end
        elseif param == keys.delete then
          -- Delete
          if activeInput.nPos < #activeInput.sLine then
            activeInput.clear()
            activeInput.sLine = string.sub(activeInput.sLine, 1, activeInput.nPos) .. string.sub(activeInput.sLine, activeInput.nPos + 2)
            activeInput.recomplete()
            activeInput.redraw()
          end
        elseif param == keys["end"] then
          -- End
          if activeInput.nPos < #activeInput.sLine then
            activeInput.clear()
            activeInput.nPos = #activeInput.sLine
            activeInput.recomplete()
            activeInput.redraw()
          end
        elseif param == keys.tab then
          -- Tab (accept autocomplete)
          activeInput.acceptCompletion()
        end
      elseif sEvent == "mouse_click" or sEvent == "mouse_drag" and param == 1 and param1 and param2 then
        local _, cy = term.getCursorPos()
        if param1 >= activeInput.sx and param1 <= activeInput.w and param2 == cy then
          -- Ensure we don't scroll beyond the current line
          activeInput.nPos = math.min(math.max(activeInput.nScroll + param1 - activeInput.sx, 0), #activeInput.sLine)
          activeInput.redraw()
        end
      elseif sEvent == "term_resize" then
        -- Terminal resized
        activeInput.w = activeInput._nLimit or term.getSize()
        activeInput.redraw()
      end
    end
  end)
end

return input