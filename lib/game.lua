local Slab = require "thirdparty/Slab"
local Class = require "thirdparty/middleclass/middleclass"

local Config = require "lib/config"
local Tank = require "lib/tank"
local Camera = require "lib/camera"
local MoveOrder = require "lib/move-order"
local Waypoint = require "lib/waypoint"
local Utils = require "lib/utils"

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
    Slab.Initialize()
    self.camera = Camera(self, {x=0, y=0})
    self.runtime = 0
end

function Game:addEntity(entity)
    entity.body:setLinearDamping(self.worldFriction * entity.friction)
    -- world already stores the bodies, no use for storing entities yet
end

function Game:menu()
    if Slab.BeginMainMenuBar() then
        if Slab.BeginMenu("Window") then
            if Slab.MenuItemChecked("Camera Info", self.camera.showWindow) then
               self.camera.showWindow = not self.camera.showWindow
            end
            if self.selected then
                if Slab.MenuItemChecked("Selected Entity Info", self.selected.showWindow) then
                    self.selected.showWindow = not self.selected.showWindow
                end
            else
                Slab.MenuItemChecked("Selected Entity info", false, {Enabled=false})
            end

            Slab.EndMenu()
        end
        Slab.EndMainMenuBar()
    end
end

function Game:update(dt)
    Slab.Update(dt)
    self:menu()
    self.runtime = self.runtime + dt
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
    if self.selected and Utils.tableIsEmpty(self.selected.orders) then
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

    for entity in self:entities() do
        entity:update(dt)
    end

    self.world:update(dt)
end

function Game:viewportTransform()
    love.graphics.translate(Config.width / 2, Config.height / 2)
    local px, py = self.camera.body:getPosition()
    love.graphics.translate(-px, -py)
    love.graphics.scale(self.camera.zoomLevel, self.camera.zoomLevel)
end

function Game:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.push()
    self:viewportTransform()
    if self.selected then
        self.selected:drawOrders()
    end
    for _, entity in ipairs(self.camera:getCollidingEntities()) do
       entity:draw()
    end
    love.graphics.pop()
    Slab.Draw()
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
    if not Slab.IsVoidHovered() then
        return
    end
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
                target = Waypoint(self, {x=wx, y=wy})
            end
            local order = MoveOrder{
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
    if key == "=" then
        self.camera:zoomIn()
    elseif key == "-" then
        self.camera:zoomOut()
    elseif self.selected and Utils.tableIsEmpty(self.selected.orders) then
        if key == "space" then
            self.selected:fire()
        end
    end
end

function Game:findMoveTargetAtCoords(x, y)
    local found
    self.world:queryBoundingBox(x, y, x+1, y+1, function(fixture)
        local entity = fixture:getBody():getUserData()
        if (entity:isInstanceOf(Tank) and not fixture:isSensor()) or -- only the hull counts
           (entity:isInstanceOf(Waypoint)) then
            found = entity
            return false
        end
        return true
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

function Game:searchEntityByName(name, allowedEntityTypes)
    local found = nil
    for entity in self:entities(allowedEntityTypes) do
        if tostring(entity) == name then
            found = entity
            break
        end
    end
    return found
end

function Game:entities(allowedEntityTypes)
    local i = 0
    local bodies = self.world:getBodies()
    return function()
        i = i + 1
        if bodies[i] then
            local entity = bodies[i]:getUserData()
            if allowedEntityTypes and #allowedEntityTypes then
                for _, eType in ipairs(allowedEntityTypes) do
                    if entity:isInstanceOf(eType) then
                        return entity
                    end
                end
            else
                return entity
            end
        end
    end
end

return Game
