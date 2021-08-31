local Slab = require "thirdparty/Slab"

local Entity = require "lib/entity"
local Config = require "lib/config"

local Camera = Entity:subclass("Camera")
Camera.cameraSensor = nil
Camera.scrollSpeedX = 50
Camera.scrollSpeedY = 50
Camera.zoomMin = 0.1
Camera.zoomMax = 10
Camera.zoomMult = 1.1
Camera.showWindow = false

function Camera:initialize(game, properties)
    Entity.initialize(self, game, properties)
    -- Camera will have a screen-shaped sensor
    -- this sensor must collide with everything, to decide what gets rendered.
    self:createSensor(Config.width, Config.height)
    self.zoomLevel = 1.0
    self.showWindow = false
end

function Camera:createSensor(width, height)
    if self.cameraSensor then
        self.cameraSensor:destroy()
    end
    local shape = love.physics.newRectangleShape(0, 0, width, height)
    self.cameraSensor = love.physics.newFixture(self.body, shape)
    self.cameraSensor:setSensor(true)
end

function Camera:collidingEntities()
    local uniqueEntities = {}
    local contacts = self.body:getContacts()
    local i = 0
    return function()
        i = i + 1
        if not contacts[i] then
            return nil
        end
        local f1,f2 = contacts[i]:getFixtures()
        local entity
        if f1:getBody() ~= self.body then -- XXX: Could cause redundant drawing if we're not careful
            entity = f1:getBody():getUserData()
        else
            entity = f2:getBody():getUserData()
        end
        if not uniqueEntities[entity] then
            uniqueEntities[entity] = true
            return entity
        end
    end
end

function Camera:window()
    self.showWindow = Slab.BeginWindow('CameraInfo', {
        Title = "Camera info",
        IsOpen = self.showWindow,
    })
    local posx, posy = self.body:getPosition()
    Slab.Text(string.format("Position: %d,%d,  Zoom: %.2f", posx, posy, self.zoomLevel))
    Slab.Text(string.format("Selected: %s", tostring(self.game.selected)))
    Slab.Text("Visible entities:")
    Slab.Indent()
    for entity in self:collidingEntities() do
        Slab.Text(tostring(entity))
    end
    Slab.EndWindow()
end

function Camera:update(dt)
    self:window()
end

function Camera:zoomIn()
    self.zoomLevel = self.zoomLevel * self.zoomMult
    if self.zoomLevel > self.zoomMax then
        self.zoomLevel = self.zoomMax
    end
    local w, h = love.window.getMode()
    w = w / self.zoomLevel
    h = h / self.zoomLevel
    self:createSensor(w, h)
end

function Camera:zoomOut()
    self.zoomLevel = self.zoomLevel / (self.zoomMult)
    if self.zoomLevel < self.zoomMin then
        self.zoomLevel = self.zoomMin
    end
    local w, h = love.window.getMode()
    w = w / self.zoomLevel
    h = h / self.zoomLevel
    self:createSensor(w, h)
end
return Camera