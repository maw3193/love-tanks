local NameGen = require "namegen/namegen"
local Slab = require "thirdparty/Slab"

local Entity = require "lib/entity"
local Utils = require "lib/utils"
local MoveOrder = require "lib/move-order"
local Projectile = require "lib/projectile"

local Tank = Entity:subclass("Tank")

local triangleShape = love.physics.newPolygonShape(Utils.polygonPoints(16, 3))

Tank.turnSpeed = 1
Tank.thrustPower = 4000
Tank.projectileVelocity = 800
Tank.projectileFireInterval = 0.33
Tank.shouldDrawName = true

function Tank:initialize(game, properties)
    Entity.initialize(self, game, properties)
    self.hull = love.physics.newFixture(self.body, triangleShape)
    self.nextFireTime = self.game.runtime
    self.name = NameGen.generate("human male")
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
        -- assumes projectiles always fire forwards
        local vx, vy = self.body:getWorldVector(self.projectileVelocity, 0)
        Projectile(self.game, {
            x = px + dx, y = py + dy,
            angle = self.body:getAngle(),
            vx = vx, vy = vy,
        })
        self.nextFireTime = self.game.runtime + self.projectileFireInterval
    end
end

return Tank
