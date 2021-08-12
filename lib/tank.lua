local Entity = require "lib/entity"
local Utils = require "lib/utils"
local MoveOrder = require "lib/moveOrder"

local Tank = Entity:subclass("Tank")

local triangleShape = love.physics.newPolygonShape(Utils.polygonPoints(16, 3))

Tank.turnSpeed = 1
Tank.thrustPower = 500

function Tank:initialize(game, x, y, params)
    Entity.initialize(self, game, x, y, params)
    love.physics.newFixture(self.body, triangleShape)
end

function Tank:turnTowards(dt, bearing)
    local currentAngle = self.body:getAngle()
    local angleDifference = bearing - currentAngle

    if angleDifference > math.pi then
        angleDifference = angleDifference - 2 * math.pi
    end
    if math.abs(angleDifference) < dt * self.turnSpeed then
        self.body:setAngle(bearing)
    elseif angleDifference > 0 then
        self:turn(dt, 1)
    elseif angleDifference < 0 then
        self:turn(dt, -1)
    end
end

function Tank:turn(dt, mult)
    local angle = self.body:getAngle()
    angle = angle + dt * mult * self.turnSpeed
    if angle >= 2 * math.pi then
        angle = angle - 2 * math.pi
    elseif angle < 0 then
        angle = angle + 2 * math.pi
    end
    self.body:setAngle(angle)
end

function Tank:thrust(dt, mult)
    self.body:applyForce(self.body:getWorldVector(self.thrustPower * dt * mult, 0))
end

function Tank:onContact(other)
    -- TODO: Better way of doing this
    if self.orders[1] and self.orders[1]:isInstanceOf(MoveOrder) and self.orders[1].target == other then
        self.orders[1]:destroy()
        table.remove(self.orders, 1)
    end
end

return Tank