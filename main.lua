local Slab = require "thirdparty/Slab"

love.physics.setMeter(10)

local Tank = require "lib/tank"
local Waypoint = require "lib/waypoint"
local MoveOrder = require "lib/move-order"
local AttackOrder = require "lib/attack-order"
local WanderOrder = require "lib/wander-order"
local Config = require "lib/config"
local Game = require "lib/game"

local game
local tank
local tank2

function love.load(arg)
    if arg[#arg] == "-debug" then require("mobdebug").start() end
    love.window.setMode(Config.width, Config.height)
    love.window.setTitle("Tanks!!!")
    love.filesystem.setIdentity("LoveTanks")
    math.randomseed(os.time())


    game = Game()
    tank = Tank(game, {
        name = "Tank 1",
        x=0, y=0,
        orders = {
            MoveOrder{target = Waypoint(game, {x=50, y=-100})},
--            MoveOrder{target = Waypoint(game, {x=50, y=-120})},
            WanderOrder(),
        },
    })
    game.selected = tank
    tank2 = Tank(game, {
        name = "Tank 2",
        x=100, y=0,
        orders = {
            MoveOrder{target = Waypoint(game, {x=100, y=50})},
            MoveOrder{target = Waypoint(game, {x=100, y=100})},
            MoveOrder{target = Waypoint(game, {x=100, y=-100})},
            AttackOrder{target = tank},
            WanderOrder(),
        },
    })
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

function love.quit(...)
    return game:quit(...)
end