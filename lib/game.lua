local Class = require "thirdparty/middleclass/middleclass"
local Config = require "lib/config"

local Game = Class("Game")

Game.worldFriction = 1
function Game:initialize()
    self.world = love.physics.newWorld()
end

function Game:addEntity(entity)
    entity.body:setLinearDamping(self.worldFriction)
    -- world already stores the bodies, no use for storing entities yet
end

function Game:update(dt)
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

return Game