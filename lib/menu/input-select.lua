local Menu = require "lib/menu/menu"
local Slab = require "thirdparty/Slab"

local InputSelect = Menu:subclass("InputSelect")

InputSelect.setIndex = nil

function InputSelect:initialize(properties)
    self.game = properties.game
end

function InputSelect:uiControls()
    Slab.BeginLayout("InputSelectColumns", {Columns=2})
    if self.setIndex and self.game.lastKey then
        self.game.inputMap[self.setIndex].key = self.game.lastKey
        self.setIndex = nil
        self.game:saveConfig()
    end
    for i, mapping in ipairs(self.game.inputMap) do
        Slab.SetLayoutColumn(1)
        Slab.Text(mapping.name)
        Slab.SetLayoutColumn(2)
        local buttontext
        if type(mapping.key) == "number" then
            buttontext = "Mouse "..mapping.key
        elseif type(mapping.key) == "string" then
            buttontext = mapping.key
        else
            buttontext = "Press a key..."
        end
        if Slab.Button(buttontext, {H=Slab.GetTextHeight(mapping.name)}) then
            self.setIndex = i
            self.game.lastKey = nil
            mapping.key = nil
        end
    end
    Slab.EndLayout()
end

return InputSelect