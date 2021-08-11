local Entity = require "lib/entity"
local Utils = require "lib/utils"
local MoveTarget = require "lib/moveTarget"

local Tank = Entity:subclass("Tank")

local triangleShape = love.physics.newPolygonShape(Utils.polygonPoints(16, 3))

Tank.turnSpeed = 1
Tank.thrustPower = 500
Tank.forwardAngleThreshold = math.pi / 2

function Tank:initialize(world, x, y, params)
    Entity.initialize(self, world, x, y, params)
    love.physics.newFixture(self.body, triangleShape)
end

function Tank:moveToMoveTarget(dt)
    local targetBearing = self:calculateBearing(self.moveTarget)
    if self.turnSpeed then
        self:turnTowards(dt, targetBearing)
    end
    if self.thrustPower then
        local angleDifference = targetBearing - self.body:getAngle()
        if math.abs(angleDifference) <= self.forwardAngleThreshold then
            self:thrust(dt, 1)
        end
    end
end

function Tank:update(dt)
    if self.moveTarget then
        self:moveToMoveTarget(dt)
    end
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
    if self.moveTarget and self.moveTarget == other and other:isInstanceOf(MoveTarget) then
        self:setMoveTarget(nil)
    end
end

return Tank