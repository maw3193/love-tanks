local Class = require "thirdparty/middleclass/middleclass"
local Config = require "lib/config"

local Game = Class("Game")

Game.worldFriction = 1
function Game:initialize()
    self.world = love.physics.newWorld()
    self.world:setCallbacks(
        function(...) return self:beginContact(...) end,
        function(...) return self:endContact(...) end,
        function(...) return self:preSolve(...) end,
        function(...) return self:postSolve(...) end)
end

function Game:addEntity(entity)
    entity.body:setLinearDamping(self.worldFriction)
    -- world already stores the bodies, no use for storing entities yet
end

function Game:update(dt)
    for _,body in ipairs(self.world:getBodies()) do
        body:getUserData():update(dt)
    end
    self.world:update(dt)
end

function Game:draw()
    love.graphics.push()
    love.graphics.translate(Config.width / 2, Config.height / 2)    
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

return Game