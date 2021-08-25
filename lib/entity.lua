local Class = require "thirdparty/middleclass/middleclass"
local Slab=  require "thirdparty/Slab"
local Config = require "lib/config"
local Utils = require "lib/utils"

local Entity = Class("Entity")

Entity.shouldDrawPoint = true
Entity.shouldDrawName = false
Entity.friction = 1
Entity.bodyType = "dynamic"
Entity.showWindow = false

function Entity:initialize(game, properties)
    assert(properties.x, "Creating Entity with no X position")
    assert(properties.y, "Creating Entity with no Y position")
    self.game = game
    self.body = love.physics.newBody(game.world, properties.x, properties.y, self.bodyType)
    self.body:setUserData(self)
    self.body:setFixedRotation(true)
    self.targetters = {} -- should this be a weak table? if so, I need a better check of emptiness
    self.orders = {}
    self:setProperties(properties)
    game:addEntity(self)
end

function Entity:setProperties(properties)
    if properties.x and properties.y then
        self.body:setPosition(properties.x, properties.y)
    end
    if properties.angle then
        self.body:setAngle(properties.angle)
    end
    if properties.vx and properties.vy then
        self.body:setLinearVelocity(properties.vx, properties.vy)
    end
    if properties.orders then
        self:clearOrders()
        for _, order in ipairs(properties.orders) do
            self:appendOrder(order)
        end
    end
end

function Entity:getProperties()
    local properties = {}
    properties.x, properties.y = self.body:getPosition()
    properties.angle = self.body:getAngle()
    properties.vx, properties.vy = self.body:getLinearVelocity()
    properties.orders = self.orders
    return properties
end

function Entity:__tostring()
    return self.class.name..":"..(self.name or "")
end

function Entity:window()
    if self.showWindow then
        self.showWindow = Slab.BeginWindow("EntityInfo", {
            Title = tostring(self),
            IsOpen = self.showWindow,
        })
        Slab.Text(tostring(self))
        Slab.Separator()
        Slab.Properties(Utils.toSlabProperties(self:getProperties()))
        Slab.EndWindow()
    end
end

function Entity:update(dt)
    self:window()
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

function Entity:drawOrders()
    if not Utils.tableIsEmpty(self.orders) then
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
end

function Entity:draw()
    local px, py = self.body:getPosition()
    love.graphics.push() -- now in entity-local coordinates
    love.graphics.translate(px, py)
    if self.name then
        love.graphics.print(self.name)
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
    order:setExecutor(self)
end

function Entity:appendOrder(order)
    table.insert(self.orders, order)
    order:setExecutor(self)
end

function Entity:prependOrder(order)
    table.insert(self.orders, 1, order)
    order:setExecutor(self)
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

function Entity:addTargetter(targetter)
    if self.targetters[targetter] then
        self.targetters[targetter] = self.targetters[targetter] + 1
    else
        self.targetters[targetter] = 1
    end
end

function Entity:removeTargetter(targetter)
    assert(self.targetters[targetter])
    self.targetters[targetter] = self.targetters[targetter] - 1
    if self.targetters[targetter] < 1 then
        self.targetters[targetter] = nil
    end
end

return Entity
