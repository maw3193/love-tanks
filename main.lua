local Tank = require "lib/tank"
local MoveTarget = require "lib/moveTarget"
local MoveOrder = require "lib/moveOrder"
local Config = require "lib/config"
local Game = require "lib/game"

local game
local tank
local tank2

function love.load(arg)
    if arg[#arg] == "-debug" then require("mobdebug").start() end
    love.window.setMode(Config.width, Config.height)
    love.window.setTitle("Tanks!!!")

    love.physics.setMeter(10)

    game = Game()
    tank = Tank(game, 0, 0)
    game:addEntity(tank)
    game.selected = tank

    tank2 = Tank(game, 100, 0)
    game:addEntity(tank2)

    local moveTarget = MoveTarget(game, -100, -100)
    game:addEntity(moveTarget)
    tank:setOrder(MoveOrder{executor=tank, target=moveTarget})
    tank:addOrder(MoveOrder{executor=tank, target=tank2})
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end

function love.mousepressed(...)
    game:mousePressed(...)
end

function love.mousereleased(...)
    game:mouseReleased(...)
end
