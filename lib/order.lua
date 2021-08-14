local Class = require "thirdparty/middleclass/middleclass"

local Order = Class("Order")

function Order:initialize(params)
    self.__mode = "v" -- order doesn't force entities to persist
    self.executor = params.executor
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