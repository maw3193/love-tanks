local Order = require "lib/order"
local Utils = require "lib/utils"

local MoveOrder = Order:subclass("MoveOrder")

MoveOrder.forwardAngleThreshold = math.pi / 2

function MoveOrder:initialize(params)
    Order.initialize(self, params)
    self.target = params.target
    self.target.targetters[self.executor] = true
end

function MoveOrder:destroy()
    self.target.targetters[self.executor] = nil
end

function MoveOrder:draw()
    local px, py = self.executor.body:getPosition()
    local tx, ty = self.target.body:getPosition()
    love.graphics.line(px, py, tx, ty)
end

function MoveOrder:moveToTarget(dt)
    local targetBearing = self.executor:calculateBearing(self.target)
    if self.executor.turnSpeed then
        self.executor:turnTowards(dt, targetBearing)
    end
    if self.executor.thrustPower then
        local angleDifference = targetBearing - self.executor.body:getAngle()
        if math.abs(angleDifference) <= self.forwardAngleThreshold then
            self.executor:thrust(dt, 1)
        end
    end
end

function MoveOrder:update(dt)
    if self.executor:isTouching(self.target) then
        -- what if I touched it before being given the order?
        Utils.removeItemFromArray(self.executor.orders, self)
        self:destroy()
        return
    end
    self:moveToTarget(dt)
end

function MoveOrder:onContact(other)
    if self.target == other then
        Utils.removeItemFromArray(self.executor.orders, self)
        self:destroy()
    end
end

return MoveOrder