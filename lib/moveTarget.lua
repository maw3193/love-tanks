local Entity = require "lib/entity"

local MoveTarget = Entity:subclass("MoveTarget")

MoveTarget.sensorRadius = 16

local moveTargetSensorShape = love.physics.newCircleShape(MoveTarget.sensorRadius)

function MoveTarget:initialize(world, x, y, params)
    params = params or {}
    params.bodyType = "kinematic"
    Entity.initialize(self, world, x, y, params)
    local sensorFixture = love.physics.newFixture(self.body, moveTargetSensorShape)
    sensorFixture:setSensor(true)
end

return MoveTarget