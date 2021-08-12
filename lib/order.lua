local Class = require "thirdparty/middleclass/middleclass"

local Order = Class("Order")

function Order:initialize(params)
    self.__mode = "v" -- order doesn't force entities to persist
    self.executor = params.executor
end

function Order:draw()
end

function Order:update(dt)
end

function Order:destroy()
end

return Order