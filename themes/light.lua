--- A base light theme.
-- @module theme-light
-- @author znepb

return {
  button = {
    buttonColor = colors.lightGray,
    textColor = colors.black,
    clickBorderColor = colors.gray
  },
  contextMenu = {
    background = colors.lightGray,
    disabled = colors.gray,
    active = colors.black,
    selected = colors.gray,
    selectedText = colors.lightGray
  },
  dialog = {
    backgroundColor = colors.white,
    borderColor = colors.lightGray,
    textColor = colors.gray,
    titleColor = colors.black,
    sub = {
      button = {
        buttonColor = colors.white,
        textColor = colors.black,
        clickBorderColor = colors.gray,
        buttonBorder = colors.lightGray
      }
    }
  },
  input = {
    backgroundColor = colors.white,
    borderColor = colors.lightGray,
    borderColorActive = colors.gray,
    textColor = colors.gray,
    placeholderColor = colors.lightGray
  },
  text = {
    color = colors.gray
  }
}