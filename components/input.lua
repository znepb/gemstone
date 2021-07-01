--- A fancy looking input with a new read function, which includes a limit for the size.
-- @module input

local input = {}
local common = require("common")

local inputs = {}

--- Basicly, CC's read function with a custom width parameter.
-- @param _sReplaceChar The character to hide all the characters.
-- @param _tHistory A table containing a history for the textbox.
-- @param _fnComplete A function that is random when the text is completed. The only parameter is the line.
-- @param _sDefault The default text.
-- @param _nLimit The size limit of the read window.
function input.read(_sReplaceChar, _tHistory, _fnComplete, _sDefault, _nLimit)
  term.setCursorBlink(true)

  local sLine
  if type(_sDefault) == "string" then
    sLine = _sDefault
  else
    sLine = ""
  end
  local nHistoryPos
  local nPos, nScroll = #sLine, 0
  if _sReplaceChar then
    _sReplaceChar = string.sub(_sReplaceChar, 1, 1)
  end

  local tCompletions
  local nCompletion
  local function recomplete()
    if _fnComplete and nPos == #sLine then
      tCompletions = _fnComplete(sLine)
      if tCompletions and #tCompletions > 0 then
        nCompletion = 1
      else
        nCompletion = nil
      end
    else
      tCompletions = nil
      nCompletion = nil
    end
  end

  local function uncomplete()
    tCompletions = nil
    nCompletion = nil
  end

  local w = _nLimit or term.getSize()
  local sx = term.getCursorPos()

  local function redraw(_bClear)
    local cursor_pos = nPos - nScroll
    if sx + cursor_pos >= w then
      -- We've moved beyond the RHS, ensure we're on the edge.
      nScroll = sx + nPos - w
    elseif cursor_pos < 0 then
      -- We've moved beyond the LHS, ensure we're on the edge.
      nScroll = nPos
    end

    local _, cy = term.getCursorPos()
    term.setCursorPos(sx, cy)
    local sReplace = _bClear and " " or _sReplaceChar
    if sReplace then
      term.write(string.rep(sReplace, math.max(#sLine - nScroll, 0)))
    else
      term.write(string.sub(sLine, nScroll + 1))
    end

    if nCompletion then
      local sCompletion = tCompletions[nCompletion]
      local oldText, oldBg
      if not _bClear then
        oldText = term.getTextColor()
        oldBg = term.getBackgroundColor()
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.gray)
      end
      if sReplace then
        term.write(string.rep(sReplace, #sCompletion))
      else
        term.write(sCompletion)
      end
      if not _bClear then
        term.setTextColor(oldText)
        term.setBackgroundColor(oldBg)
      end
    end

    term.setCursorPos(sx + nPos - nScroll, cy)
   end

  local function clear()
    redraw(true)
  end

  recomplete()
  redraw()

  local function acceptCompletion()
    if nCompletion then
      -- Clear
      clear()

      -- Find the common prefix of all the other suggestions which start with the same letter as the current one
      local sCompletion = tCompletions[nCompletion]
      sLine = sLine .. sCompletion
      nPos = #sLine

      -- Redraw
      recomplete()
      redraw()
    end
  end
    
  while true do
    local sEvent, param, param1, param2 = os.pullEvent()
    if sEvent == "char" then
      -- Typed key
      clear()
      sLine = string.sub(sLine, 1, nPos) .. param .. string.sub(sLine, nPos + 1)
      nPos = nPos + 1
      recomplete()
      redraw()

    elseif sEvent == "paste" then
      -- Pasted text
      clear()
      sLine = string.sub(sLine, 1, nPos) .. param .. string.sub(sLine, nPos + 1)
      nPos = nPos + #param
      recomplete()
      redraw()
    elseif sEvent == "key" then
      if param == keys.enter or param == keys.numPadEnter then
        -- Enter/Numpad Enter
        if nCompletion then
          clear()
          uncomplete()
            redraw()
        end
        break
      elseif param == keys.left then
        -- Left
        if nPos > 0 then
            clear()
            nPos = nPos - 1
            recomplete()
            redraw()
        end
      elseif param == keys.right then
        -- Right
        if nPos < #sLine then
          -- Move right
          clear()
          nPos = nPos + 1
          recomplete()
          redraw()
        else
          -- Accept autocomplete
          acceptCompletion()
        end
      elseif param == keys.up or param == keys.down then
        -- Up or down
        if nCompletion then
          -- Cycle completions
          clear()
          if param == keys.up then
            nCompletion = nCompletion - 1
            if nCompletion < 1 then
              nCompletion = #tCompletions
            end
          elseif param == keys.down then
            nCompletion = nCompletion + 1
            if nCompletion > #tCompletions then
              nCompletion = 1
            end
          end
          redraw()
        elseif _tHistory then
          -- Cycle history
          clear()
          if param == keys.up then
            -- Up
            if nHistoryPos == nil then
              if #_tHistory > 0 then
                nHistoryPos = #_tHistory
              end
            elseif nHistoryPos > 1 then
              nHistoryPos = nHistoryPos - 1
            end
          else
            -- Down
            if nHistoryPos == #_tHistory then
              nHistoryPos = nil
            elseif nHistoryPos ~= nil then
              nHistoryPos = nHistoryPos + 1
            end
          end
          if nHistoryPos then
            sLine = _tHistory[nHistoryPos]
            nPos, nScroll = #sLine, 0
          else
            sLine = ""
            nPos, nScroll = 0, 0
          end
          uncomplete()
          redraw()
        end

        elseif param == keys.backspace then
          -- Backspace
          if nPos > 0 then
            clear()
            sLine = string.sub(sLine, 1, nPos - 1) .. string.sub(sLine, nPos + 1)
            nPos = nPos - 1
            if nScroll > 0 then
              nScroll = nScroll - 1
            end
            recomplete()
            redraw()
          end
        elseif param == keys.home then
          -- Home
          if nPos > 0 then
            clear()
            nPos = 0
            recomplete()
            redraw()
          end
        elseif param == keys.delete then
          -- Delete
          if nPos < #sLine then
            clear()
            sLine = string.sub(sLine, 1, nPos) .. string.sub(sLine, nPos + 2)
            recomplete()
            redraw()
          end
        elseif param == keys["end"] then
          -- End
          if nPos < #sLine then
            clear()
            nPos = #sLine
            recomplete()
            redraw()
          end

        elseif param == keys.tab then
          -- Tab (accept autocomplete)
          acceptCompletion()
        end

    elseif sEvent == "mouse_click" or sEvent == "mouse_drag" and param == 1 then
      local _, cy = term.getCursorPos()
      if param1 >= sx and param1 <= w and param2 == cy then
        -- Ensure we don't scroll beyond the current line
        nPos = math.min(math.max(nScroll + param1 - sx, 0), #sLine)
        redraw()
      end
    elseif sEvent == "term_resize" then
      -- Terminal resized
      w = _nLimit or term.getSize()
      redraw()
    end
  end

  local _, cy = term.getCursorPos()
  term.setCursorBlink(false)
  term.setCursorPos(w + 1, cy)
  print()

  return sLine
end

--- Internal function to draw a border for the text box. This doesn't use the common one because this input box is THICC
-- @param x The X position of the border
-- @param y The Y position of the border
-- @param w The width of the border.
-- @param fg The foreground color of the border
-- @param bg The background color of the border
local function drawTextboxBorder(x, y, w, fg, bg)
  term.setCursorPos(x, y)
  common.setColors(bg, fg)
  term.write("\152")
  term.write(("\140"):rep(w - 2))
  common.setColors(fg, bg)
  term.write("\155")

  common.setColors(bg, fg)
  term.setCursorPos(x, y + 1)
  term.write("\149")
  common.setColors(fg, bg)
  term.setCursorPos(x + w - 1, y + 1)
  term.write("\149")

  term.setCursorPos(x, y + 2)
  common.setColors(bg, fg)
  term.write("\137")
  term.write(("\140"):rep(w - 2))
  term.write("\134")
end

--- Renders a textbox.
-- @param id The ID of the textbox to render.
function input.render(id)
  local o = inputs[id]

  paintutils.drawFilledBox(o.x + 1, o.y + 1, o.x + o.w - 2, o.y + 1, o.backgroundColor or colors.white)
  drawTextboxBorder(o.x, o.y, o.w, o.backgroundColor or colors.white, o.borderColor or colors.gray)

  if o.defaultText then
    term.setCursorPos(o.x + 1, o.y + 1)
    term.setTextColor(o.textColor or colors.gray)
    term.write(common.textOverflow(o.defaultText, o.w - 2))
  elseif o.placeholder then
    term.setTextColor(o.placeholderColor or colors.lightGray)
    term.setCursorPos(o.x + 1, o.y + 1)
    term.write(o.placeholder)
  end
end

--- Creates a new input box.
-- @param id The ID of the text box. Used to remove, render, etc.
-- @param x The X position of the textbox.
-- @param y The Y position of the textbox.
-- @param w The width of the textbox.
-- @param placeholder The text that will be shown when no text has been entered. Note that this is overidden by default. The difference is that placeholder text does not persist when the textbox is selected.
-- @param history The history table that the read function will draw from.
-- @param replace The replace character, mainly for passwords.
-- @param default The default text that will be entered. For mor information on this, see the placeholder paramerer.
-- @param ?textColor The text of default text, or the text when it is being entered into the box. Default color is gray.
-- @param ?bgColor The color of the background of the input box. Default color is white.
-- @param ?placeholderColor The color of the placeholder text.
-- @param ?borderColor The color of the border of the textbox when it isn't selected
-- @param ?borderSelColor The color of the border when the textbox is selected.
function input.create(id, x, y, w, placeholder, history, replace, default, textColor, bgColor, placeholderColor, borderColor, borderSelColor)
  term.setTextColor(colors.gray)

  inputs[id] = {
    x = x,
    y = y,
    w = w,
    placeholder = placeholder,
    history = history,
    replaceCharacter = replace,
    defaultText = default,
    borderColor = borderColor,
    borderSelectedColor = borderSelColor,
    backgroundColor = bgColor,
    textColor = textColor,
    placeholderColor = placeholderColor
  }

  input.render(id)
end

--- Removes an input.
-- @param id The ID of the element to remove.
function input.remove(id)
  inputs[id] = nil
end

--- The event listener for the text box. When the text box has been finished, an event will be queued, entitled "textbox_complete". The first parameter is the ID of the textbox, and the second is the text entered into said textbox.
function input.update()
  while true do
    local e = {os.pullEvent()}
    
    if e[1] == "mouse_click" then
      local m, x, y = e[2], e[3], e[4]

      for i, v in pairs(inputs) do
        if x >= v.x and y >= v.y and y <= v.y + 2 and x <= v.x + v.w - 1 then
          drawTextboxBorder(v.x, v.y, v.w, v.backgroundColor or colors.white, v.borderSelectedColor or colors.lightBlue)
          term.setTextColor(v.textColor or colors.gray)
          paintutils.drawFilledBox(v.x + 1, v.y + 1, v.x + v.w- 2, v.y + 1, v.backgroundColor or colors.white)

          term.setCursorPos(v.x + 1, v.y + 1)
          local newText = input.read(v.replaceCharacter, v.history, nil, v.defaultText, v.w + 1)
          v.defaultText = newText
          input.render(i)

          os.queueEvent("textbox_complete", i, newText)
        end
      end
    end
  end
end

return input