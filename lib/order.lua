local Slab = require "thirdparty/Slab"
local Class = require "thirdparty/middleclass/middleclass"

local Order = Class("Order")

Order.executor = nil --set when the order is added to an entity.

function Order:initialize(params)
    self.__mode = "v" -- order doesn't force entities to persist
end

function Order:setExecutor(executor)
    self.executor = executor
end

function Order:uiControls()
    Slab.Text(self.class.name)
end

function Order:draw(prevX, prevY)
end

function Order:update(dt, isFirstOrder)
end

function Order:destroy()
end

function Order:onContact(other)
end

function Order:getPosition()
end

return Order