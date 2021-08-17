local Entity = require "lib/entity"
local CollisionCategory = require "lib/collisionCategory"

local Projectile = Entity:subclass("Projectile")

Projectile.friction = 0
Projectile.lifespan = 0.5

local projectileShape = love.physics.newPolygonShape{
    8, 0,
    -8, -3,
    -8, 3,
}

function Projectile:initialize(game, x, y, params)
    Entity.initialize(self, game, x, y, params)
    self.body:setBullet(true)
    self.hull = love.physics.newFixture(self.body, projectileShape)
    self.hull:setCategory(CollisionCategory.PROJECTILE)
    self.hull:setMask(CollisionCategory.PROJECTILE)
    self.expireTime = game.runtime + self.lifespan
end

function Projectile:update(dt)
    if self.game.runtime >= self.expireTime then
        self.body:destroy()
    end
end

return Projectile