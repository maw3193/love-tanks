local Class = require "thirdparty/middleclass/middleclass"
local Config = require "lib/config"
local Tank = require "lib/tank"
local Camera = require "lib/camera"
local MoveOrder = require "lib/move-order"
local Waypoint = require "lib/waypoint"

local Game = Class("Game")

Game.worldFriction = 1
Game.selected = nil -- an Entity
Game.camera = nil -- a Camera Entity

function Game:initialize()
    self.world = love.physics.newWorld()
    self.world:setCallbacks(
        function(...) return self:beginContact(...) end,
        function(...) return self:endContact(...) end,
        function(...) return self:preSolve(...) end,
        function(...) return self:postSolve(...) end)
    self.camera = Camera(self, 0, 0)
    self.runtime = 0
end

function Game:addEntity(entity)
    entity.body:setLinearDamping(self.worldFriction * entity.friction)
    -- world already stores the bodies, no use for storing entities yet
end

function Game:update(dt)
    self.runtime = self.runtime + dt
    if self.selected then
        if love.keyboard.isDown("q") then
            self.selected:turn(dt, -1)
        elseif love.keyboard.isDown("e") then
            self.selected:turn(dt, 1)
        end
        if love.keyboard.isDown("w") then
            self.selected:thrust(dt, 1)
        elseif love.keyboard.isDown("s") then
            self.selected:thrust(dt, -1)
        end
        if love.keyboard.isDown("up") then
            local posy = self.camera.body:getY()
            self.camera.body:setY(posy - self.camera.scrollSpeedY * dt)
        elseif love.keyboard.isDown("down") then
            local posy = self.camera.body:getY()
            self.camera.body:setY(posy + self.camera.scrollSpeedY * dt)
        end
        if love.keyboard.isDown("left") then
            local posy = self.camera.body:getX()
            self.camera.body:setX(posy - self.camera.scrollSpeedX * dt)
        elseif love.keyboard.isDown("right") then
            local posy = self.camera.body:getX()
            self.camera.body:setX(posy + self.camera.scrollSpeedX * dt)
        end
    end

    for _,body in ipairs(self.world:getBodies()) do
        body:getUserData():update(dt)
    end

    self.world:update(dt)
end

function Game:viewportTransform()
    love.graphics.translate(Config.width / 2, Config.height / 2)
    local px, py = self.camera.body:getPosition()
    love.graphics.translate(-px, -py)
end

function Game:draw()
    local px, py = self.camera.body:getPosition()
    love.graphics.print(px..","..py)
    love.graphics.push()
    self:viewportTransform()
    for _, contact in ipairs(self.camera.body:getContacts()) do
        local f1,f2 = contact:getFixtures()
        for _, fixture in ipairs({f1,f2}) do
            if fixture:getBody() ~= self.camera.body then
                fixture:getBody():getUserData():draw()
            end
        end
    end
    love.graphics.pop()
end

function Game:beginContact(fixture1, fixture2, contact)
    local entity1 = fixture1:getBody():getUserData()
    local entity2 = fixture2:getBody():getUserData()
    entity1:onContact(entity2)
    entity2:onContact(entity1)
end

function Game:endContact(fixture1, fixture2, contact)
end

function Game:preSolve(fixture1, fixture2, contact)
end

function Game:postSolve(fixture1, fixture2, contact, normal_impulse1,
                        tangent_impulse1, normal_impulse2,
                        tangent_impulse2)
end

function Game:mousePressed(x, y, button, isTouch, presses)

end

function Game:mouseReleased(x, y, button, isTouch, presses)
    love.graphics.push()
    self:viewportTransform()
    local wx, wy = love.graphics.inverseTransformPoint(x, y)
    love.graphics.pop()
    if button == 1 then
        -- left-click on a tank to select it
        self.selected = self:findTankAtCoords(wx, wy) -- could be nil, that works for us too
    elseif button == 2 then
        if self.selected then
            local target = self:findMoveTargetAtCoords(wx, wy)
            if not target then
                target = Waypoint(self, wx, wy)
            end
            local order = MoveOrder{
                executor = self.selected,
                target = target,
            }
            if love.keyboard.isDown("lshift") then
                self.selected:appendOrder(order)
            else
                self.selected:setOrder(order)
            end
        end
    end
end

function Game:keypressed(key, scancode, isrepeat)
end

function Game:keyreleased(key, scancode)
    if key == "space" and self.selected then
        self.selected:fire()
    end
end

function Game:findMoveTargetAtCoords(x, y)
    local found
    self.world:queryBoundingBox(x, y, x+1, y+1, function(fixture)
        local entity = fixture:getBody():getUserData()
        if (entity:isInstanceOf(Tank) and not fixture:isSensor()) or -- only the hull counts
           (entity:isInstanceOf(Waypoint)) then
            found = entity
            return true
        end
        return false
    end)
    return found
end

function Game:findTankAtCoords(x, y)
    local foundTank
    self.world:queryBoundingBox(x, y, x+1, y+1, function(fixture)
        local entity = fixture:getBody():getUserData()
        if not fixture:isSensor() and entity:isInstanceOf(Tank) then
            foundTank = entity
            return true
        end
        return false
    end)
    return foundTank
end

return Game
