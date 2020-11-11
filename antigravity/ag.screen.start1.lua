--- Run first, define agScreenController basic functionality: SVG-specific definitions and functions are not included.

-- constants and editable lua script parameters
local MIN_ADJUSTMENT_VALUE = 1
local MAX_ADJUSTMENT_VALUE = 10000 -- export: Max step size for altitude adjustment (m)
local USE_KMPH = true -- export: True for km/h, false for m/s
local MPS_TO_MPH = 3600

local ALTITUDE_ADJUST_KEY = "altitudeAdjustment"

-- initialize object and fields
_G.agScreenController = {
    mouse = {
        x = -1,
        y = -1,
        pressed = nil,
        state = false
    },
    locked = false,
    needRefresh = false,
    USE_KMPH = USE_KMPH
}

function _G.agScreenController:init(controller)
    self.controller = controller
    self.screen = controller.slots.screen
    self.databank = controller.slots.databank

    if self.databank and self.databank.hasKey(ALTITUDE_ADJUST_KEY) == 1 then
        self:setAltitudeAdjust(self.databank.getIntValue(ALTITUDE_ADJUST_KEY))
    else
        self:setAltitudeAdjust(1000)
    end
end

--- Handle a mouse down event at the provided coordinates.
function _G.agScreenController:mouseDown(x, y)
    self.mouse.x = x
    self.mouse.y = y
    self.mouse.pressed = _G.ScreenUtils.detectButton(self.buttonCoordinates, x, y)
end

--- Handle a mouse up event at the provided coordinates.
function _G.agScreenController:mouseUp(x, y)
    local released = _G.ScreenUtils.detectButton(self.buttonCoordinates, x, y)
    if released and self.mouse.pressed == released then
        local modified = self:handleButton(released)
        self.needRefresh = self.needRefresh or modified
    end
    self.mouse.pressed = nil
end

function _G.agScreenController:setAltitudeAdjust(newAdjust)
    if newAdjust < MIN_ADJUSTMENT_VALUE then
        newAdjust = MIN_ADJUSTMENT_VALUE
    elseif newAdjust > MAX_ADJUSTMENT_VALUE then
        newAdjust = MAX_ADJUSTMENT_VALUE
    end

    if self.altitudeAdjustment == newAdjust then
        return false
    end
    self.altitudeAdjustment = newAdjust

    if self.databank then
        self.databank.setIntValue(ALTITUDE_ADJUST_KEY, newAdjust)
    end
    return true
end

--- Returns vertical velocity in the user-chosen units.
function _G.agScreenController:getVerticalVelocity()
    local verticalVelocity, verticalUnits
    if self.USE_KMPH then
        local mph = self.controller.verticalVelocity * MPS_TO_MPH
        local lessThan = mph < 1000
        if lessThan then
            mph = 1000
        end
        verticalVelocity, verticalUnits = _G.Utilities.printableNumber(mph, "m/h")
        if lessThan then
            verticalVelocity = "<1.0"
        end
    else
        verticalVelocity, verticalUnits = _G.Utilities.printableNumber(self.controller.verticalVelocity, "m/s")
    end
    return verticalVelocity, verticalUnits
end

--- Render the interface to the screen.
function _G.agScreenController:refresh()
    assert(false, "Should be overridden by SVG-specific method.")
end

--- Processes the input indicated by the provided button id.
-- @treturn boolean True if the state was changed by this action.
function _G.agScreenController:handleButton(buttonId)
    assert(false, "Should be overridden by SVG-specific method.")
end
