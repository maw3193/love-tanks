local Class = require "thirdparty/middleclass/middleclass"
local Slab = require "thirdparty/Slab"

local Menu = Class("Menu")

Menu.startsOpen = false

function Menu:initialize(properties)
    self.name = properties.name

    self.isOpen = self.startsOpen
end

function Menu:__tostring()
    return self.class.name or self.name
end

function Menu:uiControls()
end

function Menu:window()
    self.isOpen = Slab.BeginWindow(tostring(self).."Menu", {
            Title = tostring(self), IsOpen = self.isOpen,
    })
    self:uiControls()
    Slab.EndWindow()
end

return Menu