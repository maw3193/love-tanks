local Tank = require "lib/tank"
local MoveTarget = require "lib/moveTarget"
local MoveOrder = require "lib/moveOrder"
local WanderOrder = require "lib/wanderOrder"
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
    tank.body:setAngle(1 * math.pi)
    game.selected = tank
    tank:appendOrder(MoveOrder{executor=tank,
        target = MoveTarget(game, 50, -100)
    })
    tank:appendOrder(MoveOrder{executor=tank,
        target = MoveTarget(game, 100, -100)
    })

    tank2 = Tank(game, 100, 0)
    tank2:setOrder(WanderOrder{executor=tank2})
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

function love.keypressed(...)
    game:keypressed(...)
end

function love.keyreleased(...)
    game:keyreleased(...)
end