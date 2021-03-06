local Slab = require "thirdparty/Slab"

local Order = require "lib/order"
local Utils = require "lib/utils"

local MoveOrder = Order:subclass("MoveOrder")

MoveOrder.forwardAngleThreshold = math.pi / 4

function MoveOrder:initialize(params)
    Order.initialize(self, params)
    self.target = params.target
end

function MoveOrder:__tostring()
    return self.class.name..":"..tostring(self.target)
end

function MoveOrder:setExecutor(executor)
    Order.setExecutor(self, executor)
    self.target:addTargetter(executor)
end

function MoveOrder:destroy()
    self.target:removeTargetter(self.executor)
end

function MoveOrder:draw(prevX, prevY) --there MUST be a previous position to draw an order from
    local x, y = self.target.body:getPosition()
    love.graphics.line(prevX, prevY, x, y)
end

function MoveOrder:moveToTarget(dt)
    local targetBearing = self.executor:calculateBearing(self.target)
    if self.executor.turnSpeed then
        self.executor:turnTowards(dt, targetBearing)
    end
    if self.executor.thrustPower then
        local angleDifference = targetBearing - self.executor.body:getAngle()
        if math.abs(angleDifference) <= self.forwardAngleThreshold then
            self.executor:thrust(dt, 1)
        end
    end
end

function MoveOrder:uiControls()
    Slab.Text(self.class.name)
    Slab.SameLine()
    if Slab.BeginComboBox("MoveOrderTargetName:"..tostring(self), {Selected = self.target}) then
        for entity in self.executor.game:entities({require "lib/tank", require "lib/waypoint"}) do
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

function MoveOrder:update(dt, isFirstOrder)
    if not isFirstOrder then
        return
    end

    if self.executor:isTouching(self.target) then
        -- what if I touched it before being given the order?
        Utils.removeItemFromArray(self.executor.orders, self)
        self:destroy()
        return
    end
    self:moveToTarget(dt)
end

function MoveOrder:onContact(other)
    if self.target == other then
        Utils.removeItemFromArray(self.executor.orders, self)
        self:destroy()
    end
end

function MoveOrder:getPosition()
    return self.target.body:getPosition()
end

return MoveOrder