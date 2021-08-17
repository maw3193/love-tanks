local Entity = require "lib/entity"
local Utils = require "lib/utils"
local Config = require "lib/config"

local Waypoint = Entity:subclass("Waypoint")

Waypoint.sensorRadius = Config.waypointRadius

local waypointSensorShape = love.physics.newCircleShape(Waypoint.sensorRadius)

function Waypoint:initialize(game, x, y, params)
    params = params or {}
    params.bodyType = "kinematic"
    Entity.initialize(self, game, x, y, params)
    self.sensor = love.physics.newFixture(self.body, waypointSensorShape)
    self.sensor:setSensor(true)
end

function Waypoint:update(dt)
    if Utils.tableIsEmpty(self.targetters) then -- nothing is targetting me any more
        self.body:destroy()
    end
end

return Waypoint
