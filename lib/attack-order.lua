local Slab = require "thirdparty/Slab"

local Order = require "lib/order"
local MoveOrder = require "lib/move-order"
local Utils = require "lib/utils"

local AttackOrder = Order:subclass("AttackOrder")

AttackOrder.forwardAngleThreshold = math.pi / 4
AttackOrder.fireAngleThreshold = math.pi / 6
AttackOrder.color = {1.0, 0, 0, 1.0}

function AttackOrder:initialize(params)
    Order.initialize(self, params)
    self.target = params.target
end

function AttackOrder:__tostring()
    return self.class.name..":"..tostring(self.target)
end

function AttackOrder:setExecutor(executor)
    Order.setExecutor(self, executor)
    self.target:addTargetter(executor)
end

function AttackOrder:destroy()
    self.target:removeTargetter(self.executor)
end

function AttackOrder:draw(prevX, prevY) --there MUST be a previous position to draw an order from
    local x, y = self.target.body:getPosition()
    love.graphics.setColor(self.color)
    love.graphics.line(prevX, prevY, x, y)
    love.graphics.setColor{1, 1, 1, 1}
end

function AttackOrder:attackTarget(dt)
    local targetBearing = self.executor:calculateBearing(self.target)
    -- Called alongside the move order, so this only fires on the target if it's within the firing arc
    if self.executor.thrustPower then
        local angleDifference = targetBearing - self.executor.body:getAngle()
        if math.abs(angleDifference) <= self.fireAngleThreshold then
            self.executor:fire()
        end
    end
end

function AttackOrder:uiControls()
    Slab.Text(self.class.name)
    Slab.SameLine()
    if Slab.BeginComboBox("AttackOrderTargetName:"..tostring(self), {Selected = self.target}) then
        for entity in self.executor.game:entities({require "lib/tank"}) do
            if entity ~= self.executor then
                if Slab.TextSelectable(tostring(entity)) then
                    self.target:removeTargetter(self.executor)
                    self.target = entity
                    self.target:addTargetter(self.executor)
                end
            end
        end

        Slab.EndComboBox()
    end
end

function AttackOrder:update(dt, isFirstOrder)
    if not isFirstOrder then
        return
    end
    MoveOrder.moveToTarget(self, dt)
    self:attackTarget(dt)
end

function AttackOrder:getPosition()
    return self.target.body:getPosition()
end

return AttackOrder