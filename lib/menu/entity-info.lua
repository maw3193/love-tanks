local Menu = require "lib/menu/menu"
local Slab = require "thirdparty/Slab"

local EntityInfo = Menu:subclass("EntityInfo")

EntityInfo.startsOpen = false

function EntityInfo:initialize(properties)
    Menu.initialize(self, properties)
    self.entity = properties.entity
end


function EntityInfo:uiControls()
    Slab.Text("ID:")
    if not self.entity then
        Slab.Text("None selected")
        return
    end
    Slab.SameLine()
    Slab.Input("EntityID", {Text = tostring(self.entity)})

    if Slab.Input("EntityNameInput", {Text = self.entity.name}) then
        self.entity.name = Slab.GetInputText()
    end

    local posx, posy = self.entity.body:getPosition()
    Slab.Text("X:")
    Slab.SameLine()
    if Slab.Input("EntityPosXInput", {Text = posx, NumbersOnly = true}) then
        self.entity.body:setPosition(tonumber(Slab.GetInputText()), posy)
    end
    Slab.SameLine()
    Slab.Text("Y:")
    Slab.SameLine()
    if Slab.Input("EntityPosYInput", {Text = posy, NumbersOnly = true}) then
        self.entity.body:setPosition(posx, tonumber(Slab.GetInputText()))
    end

    Slab.Text("Angle:")
    Slab.SameLine()
    if Slab.Input("EntityAngleInput", {
        Text = self.entity.body:getAngle(),
        NumbersOnly = true, UseSlider = true, Step = 0.1,
        MinNumber = 0, MaxNumber = math.pi * 2,
    }) then
        self.entity.body:setAngle(tonumber(Slab.GetInputText()))
    end

    local vx, vy = self.entity.body:getLinearVelocity()
    Slab.Text("VX:")
    Slab.SameLine()
    if Slab.Input("EntityVelocityXInput", {Text = vx, NumbersOnly = true}) then
        self.entity.body:setLinearVelocity(tonumber(Slab.GetInputText()), vy)
    end
    Slab.SameLine()
    Slab.Text("VY:")
    Slab.SameLine()
    if Slab.Input("EntityVelocityYInput", {Text = vy, NumbersOnly = true}) then
        self.entity.body:setLinearVelocity(vx, tonumber(Slab.GetInputText()))
    end

    Slab.Text("Orders:")
    Slab.Indent()
    for i, order in ipairs(self.entity.orders) do
        if Slab.Button("X", {W=16, H=16}) then
            self.entity:removeOrder(i)
        end
        Slab.SameLine()
        if Slab.Button("U", {W=16, H=16, Disabled=(i == 1)}) then
            self.entity:shiftUpOrder(i)
        end
        Slab.SameLine()
        if Slab.Button("D", {W=16, H=16, Disabled=(i == #self.entity.orders)}) then
            self.entity:shiftDownOrder(i)
        end
        Slab.SameLine()
        order:uiControls()
    end
end

return EntityInfo