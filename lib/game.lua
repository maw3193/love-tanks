local Slab = require "thirdparty/Slab"
local Class = require "thirdparty/middleclass/middleclass"
local json = require "thirdparty/json/json"

local Config = require "lib/config"
local Tank = require "lib/tank"
local Camera = require "lib/camera"
local MoveOrder = require "lib/move-order"
local Waypoint = require "lib/waypoint"
local Utils = require "lib/utils"
local InputSelect = require "lib/menu/input-select"

local Game = Class("Game")

Game.worldFriction = 1
Game.selected = nil -- an Entity
Game.camera = nil -- a Camera Entity
Game.lastKey = nil -- the last key (or mouse button) pressed
Game.inputMap = nil
Game.inputMapByName = nil
Game.configFilename = "config.json"

function Game:generateInputMapByName()
    self.inputMapByName = {}
    for _,mapping in ipairs(self.inputMap) do
        self.inputMapByName[mapping.name] = mapping
    end
end

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
    self.inputMap = {
        {key = "q", name = "Selected Turn Left", action = self.selectedTurnLeft},
        {key = "e", name = "Selected Turn Right", action = self.selectedTurnRight},
        {key = "w", name = "Selected Move Forward", action = self.selectedMoveForward},
        {key = "s", name = "Selected Move Backward", action = self.selectedMoveBackward},
        {key = "space", name = "Selected Fire", action = self.selectedFire},
        {key = "backspace", name = "Selected Clear Orders", action = self.selectedClearOrders},
        {key = "up", name = "Camera Move Up", action = self.cameraMoveUp},
        {key = "down", name = "Camera Move Down", action = self.cameraMoveDown},
        {key = "left", name = "Camera Move Left", action = self.cameraMoveLeft},
        {key = "right", name = "Camera Move Right", action = self.cameraMoveRight},
        {key = "=", name = "Camera Zoom In", action = self.cameraZoomIn},
        {key = "-", name = "Camera Zoom Out", action = self.cameraZoomOut},
        {key = 1, name = "Select At Cursor", action = self.selectAtCursor},
        {key = 2, name = "Interact At Cursor", action = self.interactAtCursor},
    }
    self:generateInputMapByName()
    self.inputSelectMenu = InputSelect{game=self}
    if love.filesystem.getInfo(self.configFilename) then
        self:loadConfig()
    end
end

function Game:saveConfig()
    local savetext = json.encode(self:getConfig())
    local savedir = love.filesystem.getSaveDirectory()
    if not love.filesystem.getInfo(self.configFilename) then
        love.filesystem.newFile(self.configFilename)
    end
    local success, message = love.filesystem.write(self.configFilename, savetext)
    assert(success, "Failed to save config: "..tostring(message))
end

function Game:loadConfig()
    local contents, extra = love.filesystem.read(self.configFilename)
    assert(contents, "Failed to load config: "..extra)
    local config = json.decode(contents)
    self:setConfig(config)
end

function Game:setConfig(config)
    for name,key in pairs(config.inputMap) do
        self.inputMapByName[name].key = key
    end
end

function Game:getConfig()
    local config = {
        inputMap = {},
    }
    for i,mapping in ipairs(self.inputMap) do
        config.inputMap[mapping.name] = mapping.key
    end
    return config
end

function Game:setProperties(properties)
    self.camera.body:setPosition(properties.cameraX, properties.cameraY)
end

function Game:getProperties()
    local properties = {}
    properties.cameraX, properties.cameraY = self.camera.body:getPosition()
    return properties
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

            if Slab.MenuItemChecked("Input Selector", self.inputSelectMenu.isOpen) then
                self.inputSelectMenu.isOpen = not self.inputSelectMenu.isOpen
            end
            Slab.EndMenu()
        end
        Slab.EndMainMenuBar()
    end
end

function Game:processInput(dt)
    for _, item in ipairs(self.inputMap) do
        if type(item.key) == "string" then --a key code
            if Slab.IsKeyDown(item.key) then
                item.action(self, dt)
            end
        elseif type(item.key) == "number" then --a mouse button
            if Slab.IsVoidClicked(item.key) then
                item.action(self, dt)
            end
        elseif item.key == nil then
            -- input is unset, do nothing
        else
            assert(false, "key '"..tostring(item.key).."' is an unexpected type: "..type(item.key))
        end
    end
end

function Game:update(dt)
    Slab.Update(dt)
    self:menu()
    self.runtime = self.runtime + dt

    self:processInput(dt)

    for entity in self:entities() do
        entity:update(dt)
    end

    self.inputSelectMenu:window()
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
        local sx, sy = self.selected.body:getPosition()
        love.graphics.circle("line", sx, sy, self.selected.radius)
        self.selected:drawOrders()
    end
    for entity in self.camera:collidingEntities() do
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
    -- NOTE: clicking into the game area doesn't use this because it's hard to catch whether it touched a Slab window instead
    self.lastKey = button
end

function Game:keypressed(key, scancode, isrepeat)
end

function Game:keyreleased(key, scancode)
    self.lastKey = key
end

function Game:quit()
    return false
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

function Game:getMousePositionInWorld()
    local x, y = love.mouse.getPosition()
    love.graphics.push()
    self:viewportTransform()
    local wx, wy = love.graphics.inverseTransformPoint(x, y)
    love.graphics.pop()
    return wx, wy
end

-- Input Actions

function Game:selectedTurnLeft(dt)
    if self.selected and Utils.tableIsEmpty(self.selected.orders) then
        self.selected:turn(dt, -1)
    end
end

function Game:selectedTurnRight(dt)
    if self.selected and Utils.tableIsEmpty(self.selected.orders) then
        self.selected:turn(dt, 1)
    end
end

function Game:selectedMoveForward(dt)
    if self.selected and Utils.tableIsEmpty(self.selected.orders) then
        self.selected:thrust(dt, 1)
    end
end

function Game:selectedMoveBackward(dt)
    if self.selected and Utils.tableIsEmpty(self.selected.orders) then
        self.selected:thrust(dt, -1)
    end
end

function Game:selectedFire(dt)
    if self.selected and Utils.tableIsEmpty(self.selected.orders) then
        self.selected:fire()
    end
end

function Game:selectedClearOrders(dt)
    if self.selected then
        self.selected:clearOrders()
    end
end

function Game:selectAtCursor(dt)
    local x, y = self:getMousePositionInWorld()
    self.selected = self:findTankAtCoords(x, y)
end

function Game:interactAtCursor(dt)
    if self.selected then
        local x, y = self:getMousePositionInWorld()
        local target = self:findMoveTargetAtCoords(x, y)
        if not target then
            target = Waypoint(self, {x=x, y=y})
        end
        local order = MoveOrder{target = target}
        if love.keyboard.isDown("lshift") then
            self.selected:appendOrder(order)
        else
            self.selected:setOrder(order)
        end
    end
end

function Game:cameraMoveUp(dt)
    self.camera:move(0, -self.camera.scrollSpeedY * dt)
end

function Game:cameraMoveDown(dt)
    self.camera:move(0, self.camera.scrollSpeedY * dt)
end

function Game:cameraMoveLeft(dt)
    self.camera:move(-self.camera.scrollSpeedX * dt, 0)
end

function Game:cameraMoveRight(dt)
    self.camera:move(self.camera.scrollSpeedX * dt, 0)
end

function Game:cameraZoomIn(dt)
    self.camera:zoomIn()
end

function Game:cameraZoomOut(dt)
    self.camera:zoomOut()
end

return Game
