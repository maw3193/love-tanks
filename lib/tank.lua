local Entity = require "lib/entity"
local Utils = require "lib/utils"

local Tank = Entity:subclass("Tank")

local triangleShape = love.physics.newPolygonShape(Utils.polygonPoints(16, 3))

Tank.turnSpeed = 1
Tank.thrustPower = 500

function Tank:initialize(world, x, y, params)
    Entity.initialize(self, world, x, y, params)
    love.physics.newFixture(self.body, triangleShape)
end

return Tank