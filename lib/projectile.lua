local Entity = require "lib/entity"

local Projectile = Entity:subclass("Projectile")

Projectile.friction = 0
Projectile.launchImpulse = 10
Projectile.lifespan = 0.5

local projectileShape = love.physics.newPolygonShape{
    8, 0,
    -8, -3,
    -8, 3,
}

function Projectile:initialize(game, x, y, params)
    Entity.initialize(self, game, x, y, params)
    self.body:isBullet(true)
    self.hull = love.physics.newFixture(self.body, projectileShape)
    self.age = 0
end

function Projectile:update(dt)
    self.age = self.age + dt
    if self.age >= self.lifespan then
        self.body:destroy()
    end
end

return Projectile