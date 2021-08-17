local Entity = require "lib/entity"
local Config = require "lib/config"

local Camera = Entity:subclass("Camera")
Camera.cameraSensor = nil
Camera.scrollSpeedX = 50
Camera.scrollSpeedY = 50
Camera.zoomMult = 1.1

function Camera:initialize(game, x, y, params)
    Entity.initialize(self, game, x, y, params)
    -- Camera will have a screen-shaped sensor
    -- this sensor must collide with everything, to decide what gets rendered.
    self:createSensor(Config.width, Config.height)
    self.zoomLevel = 1.0
end

function Camera:createSensor(width, height)
    if self.cameraSensor then
        self.cameraSensor:destroy()
    end
    local shape = love.physics.newRectangleShape(0, 0, width, height)
    self.cameraSensor = love.physics.newFixture(self.body, shape)
    self.cameraSensor:setSensor(true)
end

function Camera:zoomIn()
    self.zoomLevel = self.zoomLevel * self.zoomMult
    local w, h = love.window.getMode()
    w = w / self.zoomLevel
    h = h / self.zoomLevel
    self:createSensor(w, h)
end

function Camera:zoomOut()
    self.zoomLevel = self.zoomLevel / self.zoomMult
    local w, h = love.window.getMode()
    w = w / self.zoomLevel
    h = h / self.zoomLevel
    self:createSensor(w, h)
end
return Camera