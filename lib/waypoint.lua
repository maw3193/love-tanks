local Entity = require "lib/entity"
local Utils = require "lib/utils"
local Config = require "lib/config"

local Waypoint = Entity:subclass("Waypoint")

Waypoint.sensorRadius = Config.waypointRadius
Waypoint.bodyType = "kinematic"

local waypointSensorShape = love.physics.newCircleShape(Waypoint.sensorRadius)

function Waypoint:__tostring()
    local px, py = self.body:getPosition()
    return self.class.name..":"..px..","..py
end

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

function Waypoint:draw()
    Entity.draw(self)
    love.graphics.push() -- now in entity-local coordinates
    love.graphics.translate(self.body:getPosition())
    love.graphics.print(Utils.tableCountKeys(self.targetters))
    love.graphics.pop()
end

return Waypoint
