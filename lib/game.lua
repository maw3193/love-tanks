local Class = require "thirdparty/middleclass/middleclass"
local Config = require "lib/config"
local Tank = require "lib/tank"
local MoveTarget = require "lib/moveTarget"

local Game = Class("Game")

Game.worldFriction = 1
Game.selected = nil -- an Entity

function Game:initialize()
    self.world = love.physics.newWorld()
    self.world:setCallbacks(
        function(...) return self:beginContact(...) end,
        function(...) return self:endContact(...) end,
        function(...) return self:preSolve(...) end,
        function(...) return self:postSolve(...) end)
    self.viewportTransform = love.math.newTransform(Config.width / 2, Config.height / 2)
end

function Game:addEntity(entity)
    entity.body:setLinearDamping(self.worldFriction)
    -- world already stores the bodies, no use for storing entities yet
end

function Game:update(dt)
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
    end

    for _,body in ipairs(self.world:getBodies()) do
        body:getUserData():update(dt)
    end
    
    self.world:update(dt)
end

function Game:draw()
    love.graphics.push()
    love.graphics.applyTransform(self.viewportTransform)
    for _,body in ipairs(self.world:getBodies()) do
        body:getUserData():draw()
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

function Game:mouseReleased(x, y, button, isTouch, presses)
    love.graphics.push()
    love.graphics.applyTransform(self.viewportTransform)
    local wx, wy = love.graphics.inverseTransformPoint(x, y)
    love.graphics.pop()
    if button == 1 then
        -- left-click on a tank to select it
        self.selected = self:findTankAtCoords(wx, wy) -- could be nil, that works for us too
    elseif button == 2 then
        if self.selected then
            if self.selected.moveTarget and self.selected.moveTarget:isInstanceOf(MoveTarget) then
                self.selected.moveTarget.body:destroy()
            end
            self.selected.moveTarget = self:findTankAtCoords(wx, wy)
            if not self.selected.moveTarget then -- clicked empty space
                local moveTarget = MoveTarget(self.world, wx, wy)
                self.selected.moveTarget = moveTarget
            end
        end
    end
    
end

return Game