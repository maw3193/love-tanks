local Entity = require "lib/entity"
local Config = require "lib/config"

local Camera = Entity:subclass("Camera")
Camera.cameraSensor = nil
Camera.scrollSpeedX = 50
Camera.scrollSpeedY = 50

function Camera:initialize(game, x, y, params)
    Entity.initialize(self, game, x, y, params)
    -- Camera will have a screen-shaped sensor
    -- this sensor must collide with everything, to decide what gets rendered.
    self:createSensor(Config.width, Config.height)
end

function Camera:createSensor(width, height)
    local shape = love.physics.newRectangleShape(0, 0, width, height)
    self.cameraSensor = love.physics.newFixture(self.body, shape)
    self.cameraSensor:setSensor(true)
end

return Camera