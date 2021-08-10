local Tank = require "lib/tank"
local MoveTarget = require "lib/moveTarget"
local Config = require "lib/config"
local Game = require "lib/game"

local game
local tank
local tank2

function love.load()
    love.window.setMode(Config.width, Config.height)
    love.window.setTitle("Tanks!!!")

    love.physics.setMeter(10)

    game = Game()
    tank = Tank(game.world, 0, 0)
    game:addEntity(tank)

    tank2 = Tank(game.world, 100, 0)
    game:addEntity(tank2)

    local moveTarget = MoveTarget(game.world, -100, -100)
    tank.moveTarget = moveTarget
    game:addEntity(moveTarget)
end

function love.update(dt)
    if love.keyboard.isDown("q") then
        tank:turn(dt, -1)
    elseif love.keyboard.isDown("e") then
        tank:turn(dt, 1)
    end
    if love.keyboard.isDown("w") then
        tank:thrust(dt, 1)
    elseif love.keyboard.isDown("s") then
        tank:thrust(dt, -1)
    end

    game:update(dt)
end

function love.draw()
    game:draw()
end
