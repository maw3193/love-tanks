local Entity = require "lib/entity"
local Utils = require "lib/utils"
local Config = require "lib/config"

local MoveTarget = Entity:subclass("MoveTarget")

MoveTarget.sensorRadius = Config.moveTargetRadius

local moveTargetSensorShape = love.physics.newCircleShape(MoveTarget.sensorRadius)

function MoveTarget:initialize(game, x, y, params)
    params = params or {}
    params.bodyType = "kinematic"
    Entity.initialize(self, game, x, y, params)
    self.sensor = love.physics.newFixture(self.body, moveTargetSensorShape)
    self.sensor:setSensor(true)
end

function MoveTarget:update(dt)
    if Utils.tableIsEmpty(self.targetters) then -- nothing is targetting me any more
        self.body:destroy()
    end
end

return MoveTarget