local Slab = require "thirdparty/Slab"

local Tank = require "lib/tank"
local Waypoint = require "lib/waypoint"
local MoveOrder = require "lib/move-order"
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
    math.randomseed(os.time())

    love.physics.setMeter(10)

    game = Game()
    tank = Tank(game, {x=0, y=0})
    tank.showWindow = true
    game.selected = tank
    tank:appendOrder(MoveOrder{executor=tank,
        target = Waypoint(game, {x=50, y=-100})
    })
    tank:appendOrder(MoveOrder{executor=tank,
        target = Waypoint(game, {x=100, y=-100})
    })

    tank2 = Tank(game, {x=100, y=0})
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
