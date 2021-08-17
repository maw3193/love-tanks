local Class = require "thirdparty/middleclass/middleclass"
local Config = require "lib/config"
local Utils = require "lib/utils"

local Entity = Class("Entity")

Entity.shouldDrawPoint = true
Entity.shouldDrawName = false
Entity.friction = 1

function Entity:initialize(game, x, y, params)
    params = params or {}
    self.game = game
    local bodyType = params.bodyType or "dynamic"
    self.body = love.physics.newBody(game.world, x, y, bodyType)
    self.body:setUserData(self)
    self.body:setFixedRotation(true)
    self.targetters = {} -- should this be a weak table? if so, I need a better check of emptiness
    self.orders = {}
    game:addEntity(self)
end

function Entity:update(dt)
    for i,order in ipairs(Utils.duplicateTable(self.orders)) do
        order:update(dt, (i == 1))
    end
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

function Entity:drawName()
    local px, py = self.body:getPosition()
    local textData = {
        self.class.name,
        math.floor(px),
        math.floor(py),
        self.body:getAngle() / math.pi,
        math.floor(math.deg(self.body:getAngle())),
    }
    local angle = math.floor(math.deg(self.body:getAngle()))
    table.insert(textData, angle)
    local text = table.concat(textData, ", ")
    love.graphics.print(text)
end

function Entity:drawOrders()
    local prevX, prevY = self.body:getPosition()
    for i, order in ipairs(self.orders) do
        order:draw(prevX, prevY)
        local nextX, nextY = order:getPosition()
        if nextX then
            prevX = nextX
            prevY = nextY
        end
    end
end

function Entity:draw()
    local px, py = self.body:getPosition()
    if not Utils.tableIsEmpty(self.orders) then
        self:drawOrders()
    end
    love.graphics.push() -- now in entity-local coordinates
    love.graphics.translate(px, py)
    if self.shouldDrawName then
        self:drawName()
    end
    love.graphics.rotate(self.body:getAngle())
    if self.shouldDrawPoint then
        love.graphics.points(0,0) -- fallback to avoid entities getting lost
    end
    self:drawAllShapes()
    love.graphics.pop()
end

function Entity:onContact(other)
end

function Entity:clearOrders()
    for _,order in ipairs(self.orders) do
        order:destroy()
end
    self.orders = {}
end

function Entity:setOrder(order)
    self:clearOrders()
    table.insert(self.orders, order)
end

function Entity:appendOrder(order)
    table.insert(self.orders, order)
end

function Entity:prependOrder(order)
    table.insert(self.orders, 1, order)
end

function Entity:isTouching(other)
    for _, contact in ipairs(self.body:getContacts()) do
        if contact:isTouching() then
            local fixa, fixb = contact:getFixtures()
            for _, fixture in ipairs({fixa, fixb}) do
                if fixture:getBody():getUserData() == other then
                    return true
                end
            end
        end
    end
    return false
end

return Entity
