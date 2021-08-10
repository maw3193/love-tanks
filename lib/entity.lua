local Class = require "thirdparty/middleclass/middleclass"
local Config = require "lib/config"
local Utils = require "lib/utils"

local Entity = Class("Entity")

Entity.drawPoint = true
Entity.drawName = true
Entity.moveTarget = nil

function Entity:initialize(world, x, y, params)
    params = params or {}
    local bodyType = params.bodyType or "dynamic"
    self.body = love.physics.newBody(world, x, y, bodyType)
    self.body:setUserData(self)
    self.body:setFixedRotation(true)
end

function Entity:update(dt)
end

function Entity:drawAllShapes()
    for _,fixture in ipairs(self.body:getFixtures()) do
        local shape = fixture:getShape()
        if shape:getType() == "polygon" then
            love.graphics.polygon("line", shape:getPoints())
        elseif shape:getType() == "circle" then
            local px, py = shape:getPoint()
            local radius = shape:getRadius()
            love.graphics.circle("line", px, py, radius)
        end
    end    
end

function Entity:calculateBearing(other)
    local px, py = self.body:getPosition()
    local ox, oy = other.body:getPosition()
    local bearing = Utils.bearingFromPositions(px, py, ox, oy)
    if bearing < 0 then bearing = bearing + 2 * math.pi end
    return bearing
end

function Entity:draw()
    local px, py = self.body:getPosition()
    if self.moveTarget then
        -- draw a line from this entity to its moveTarget
        local tx, ty = self.moveTarget.body:getPosition()
        love.graphics.line(px, py, tx, ty)
    end
    love.graphics.push() -- now in entity-local coordinates
    love.graphics.translate(px, py)
    if self.drawName then
        local textData = {
            self.class.name,
            math.floor(px),
            math.floor(py),
            self.body:getAngle() / math.pi,
            math.floor(math.deg(self.body:getAngle())),
        }
        local angle = math.floor(math.deg(self.body:getAngle()))
        table.insert(textData, angle)
        if self.moveTarget then
            local targetAngle = math.floor(math.deg(self:calculateBearing(self.moveTarget)))
            table.insert(textData, targetAngle)
        end

        local text = table.concat(textData, ", ")
        love.graphics.print(text)
    end
    love.graphics.rotate(self.body:getAngle())
    if self.drawPoint then
        love.graphics.points(0,0) -- fallback to avoid entities getting lost
    end
    self:drawAllShapes()
    love.graphics.pop()
end

function Entity:onContact(other)
end

return Entity