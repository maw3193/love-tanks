local Entity = require "lib/entity"
local Utils = require "lib/utils"
local Config = require "lib/config"

local Waypoint = Entity:subclass("Waypoint")

Waypoint.sensorRadius = Config.waypointRadius
Waypoint.bodyType = "kinematic"

local waypointSensorShape = love.physics.newCircleShape(Waypoint.sensorRadius)


function Waypoint:initialize(game, properties)
    Entity.initialize(self, game, properties)
    self.sensor = love.physics.newFixture(self.body, waypointSensorShape)
    self.sensor:setSensor(true)
end

function Waypoint:update(dt)
    if Utils.tableIsEmpty(self.targetters) then -- nothing is targetting me any more
        self.body:destroy()
    end
end

return Waypoint
