local Entity = require "lib/entity"
local Utils = require "lib/utils"
local MoveOrder = require "lib/moveOrder"
local Projectile = require "lib/projectile"

local Tank = Entity:subclass("Tank")

local triangleShape = love.physics.newPolygonShape(Utils.polygonPoints(16, 3))

Tank.turnSpeed = 1
Tank.thrustPower = 1000
Tank.projectileVelocity = 800
Tank.projectileFireInterval = 0.33

function Tank:initialize(game, x, y, params)
    Entity.initialize(self, game, x, y, params)
    self.hull = love.physics.newFixture(self.body, triangleShape)
    self.nextFireTime = self.game.runtime
end

function Tank:draw()
    Entity.draw(self)
    love.graphics.push() -- now in entity-local coordinates
    love.graphics.translate(self.body:getPosition())
    local radius = self.projectileVelocity * Projectile.lifespan + 16
    love.graphics.circle("line", 0, 0, radius)
    love.graphics.pop()
end

function Tank:turnTowards(dt, bearing)
    local currentAngle = self.body:getAngle()
    local angleDifference = bearing - currentAngle

    if angleDifference > math.pi then
        angleDifference = angleDifference - 2 * math.pi
    elseif angleDifference <= -math.pi then
        angleDifference = angleDifference + 2 * math.pi
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
    if self.orders[1] then
        self.orders[1]:onContact(other)
    end
end

function Tank:fire()
    -- create the projectile outside the tank
    if self.game.runtime >= self.nextFireTime then
        -- TODO: A proper solution to entity radius, since Shape:getRadius() can't be relied on
        --local r = self.hull:getShape():getRadius()
        local r = 16
        local dx, dy = self.body:getWorldVector(r + 1, 0)
        local px, py = self.body:getPosition()
        local projectile = Projectile(self.game, px + dx, py + dy)
        projectile.body:setAngle(self.body:getAngle())
        projectile.body:setLinearVelocity(projectile.body:getWorldVector(self.projectileVelocity, 0))
        self.nextFireTime = self.game.runtime + self.projectileFireInterval
    end
end

return Tank