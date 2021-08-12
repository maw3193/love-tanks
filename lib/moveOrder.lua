local Order = require "lib/order"

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
    self:moveToTarget(dt)
end

return MoveOrder