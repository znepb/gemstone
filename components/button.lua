local function setColors(fg, bg)
  term.setBackgroundColor(bg)
  term.setTextColor(fg)
end

local buttons = {}
local enabledButtons = {}

local buttonApi = {}

local clickColors = {
  [1] = colors.lightGray,
  [2] = colors.yellow,
  [4] = colors.purple,
  [8] = colors.blue,
  [16] = colors.orange,
  [32] = colors.green,
  [64] = colors.magenta,
  [128] = colors.lightGray,
  [256] = colors.gray,
  [512] = colors.lightBlue,
  [1024] = colors.magenta,
  [2048] = colors.lightBlue,
  [4096] = colors.orange,
  [8192] = colors.lime,
  [16384] = colors.pink,
  [32768] = colors.gray
}

function buttonApi.renderSingle(id, bgOverride)
  local prev = term.getBackgroundColor()
  local b = buttons[id]

  if not b then error("Button ID " .. id .. " is non-existant") end

  setColors(b.foreground, b.background)
  term.setCursorPos(b.x + 1, b.y + 1)
  term.write((" %s "):format(b.text))

  setColors(prev, bgOverride or b.background)
  term.setCursorPos(b.x + 1, b.y)
  term.write(("\143"):rep(#b.text + 2))

  term.setCursorPos(b.x, b.y + 1)
  term.write("\149")

  term.setCursorPos(b.x + 3 + #b.text, b.y + 1)
  setColors(bgOverride or b.background, prev)
  term.write("\149")

  term.setCursorPos(b.x + 1, b.y + 2)
  term.write(("\131"):rep(#b.text + 2))
end

function buttonApi.add(id, text, x, y, bgc, fgc, clickColor)
  buttons[id] = {
    id = id,
    text = text,
    x = x,
    y = y,
    background = bgc or colors.white,
    foreground = fgc or colors.black,
    click = clickColor
  }
end

function buttonApi.render(many)
  for i, v in pairs(many) do
    buttonApi.renderSingle(v)
    table.insert(enabledButtons, v)
  end
end

function buttonApi.clear()
  enabledButtons = {}
end

function buttonApi.update()
  while true do
    local e, b, x, y = os.pullEvent()

    if e == "mouse_up" then
      if b == 1 then
        for i, v in pairs(enabledButtons) do
          local b = buttons[v]
          if x >= b.x + 1 and y == b.y + 1 and x <= b.x + #b.text + 2 then
            buttonApi.renderSingle(b.id)
            os.queueEvent("button_click", b.id, x, y)
          end
        end
      end
    elseif e == "mouse_click" then
      if b == 1 then
        for i, v in pairs(enabledButtons) do
          local b = buttons[v]
          if x >= b.x + 1 and y == b.y + 1 and x <= b.x + #b.text + 2 then
            local color = clickColors[b.background]
            if b.click then color = b.click end

            buttonApi.renderSingle(b.id, color)
          end
        end
      end
    end
  end
end

return buttonApi