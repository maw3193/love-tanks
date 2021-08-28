local Order = require "lib/order"
local Waypoint = require "lib/waypoint"
local MoveOrder = require "lib/move-order"

local WanderOrder = Order:subclass("WanderOrder")

WanderOrder.wanderRange = 100

function WanderOrder:initialize(params)
    Order.initialize(self, params)
end

function WanderOrder:update(dt, isFirstOrder)
    if isFirstOrder then
        local radius = math.random(0, self.wanderRange)
        local angle = math.random() * math.pi * 2
        local px, py = self.executor.body:getPosition()
        px = math.floor(px + radius * math.cos(angle))
        py = math.floor(py + radius * math.sin(angle))
        local moveTarget = Waypoint(self.executor.game, {x=px, y=py})
        local moveOrder = MoveOrder{target=moveTarget}
        self.executor:prependOrder(moveOrder)
    end
end

return WanderOrder
