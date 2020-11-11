
-- constants and editable lua script parameters
local SCREEN_HEIGHT = 1080
local MAX_SLIDER_ALTITUDE = 200000
local MIN_SLIDER_ALTITUDE = 1000
local MIN_ADJUSTMENT_VALUE = 1
local MAX_ADJUSTMENT_VALUE = 10000 --export: Max step size for altitude adjustment (m)
local USE_KMPH = true --export: True for km/h, false for m/s
local MPS_TO_MPH = 3600

-- constants for svg file
local ALT_SLIDER_TOP = 162
local ALT_SLIDER_BOTTOM = 1026
local MOUSE_OVER_CLASS = "mouseOver"
local HIDDEN_CLASS = "hidden"
local PANEL_CLASS_ADJUSTMENT = "adjustmentWidgets"
local PANEL_CLASS_STATUS = "statusWidgets"
local ELEMENT_CLASS_UNLOCKED_BUTTON = "unlockedClass"
local ELEMENT_CLASS_UNLOCKING_LABEL = "unlockSlideClass"
local ELEMENT_CLASS_LOCKED_BUTTON = "lockedClass"
local ELEMENT_CLASS_ALTITUDE_UP = "altitudeUpClass"
local ELEMENT_CLASS_ALTITUDE_DOWN = "altitudeDownClass"
local ELEMENT_CLASS_ADJUST_UP = "adjustUpClass"
local ELEMENT_CLASS_ADJUST_DOWN = "adjustDownClass"
local ELEMENT_CLASS_LEFT_SLIDER = "leftSliderClass"
local ELEMENT_CLASS_RIGHT_SLIDER = "rightSliderClass"
local ELEMENT_CLASS_DISABLED = "disabledText"
local ELEMENT_CLASS_NEED_PULSORS = "pulsorsText"
local ELEMENT_CLASS_POWER_IS_OFF = "powerIsOffClass"
local ELEMENT_CLASS_POWER_IS_ON = "powerIsOnClass"
local ELEMENT_CLASS_POWER_SLIDER = "powerSlideClass"

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
    SVG_TEMPLATE = [[${file:ag.screen.svg minify}]],
    SVG_LOGO = [[${file:../logo.svg minify}]]
}

-- one-time transforms
_G.agScreenController.SVG_TEMPLATE = string.gsub(_G.agScreenController.SVG_TEMPLATE, '<svg id="logo"/>', _G.agScreenController.SVG_LOGO)

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

-- constant button definition labels
local BUTTON_ALTITUDE_UP = "Altitude Up"
local BUTTON_ALTITUDE_DOWN = "Altitude Down"
local BUTTON_ALTITUDE_ADJUST_UP = "Altitude Adjust Up"
local BUTTON_ALTITUDE_ADJUST_DOWN = "Altitude Adjust Down"
local BUTTON_TARGET_ALTITUDE_SLIDER = "Target Altitude Slider"
local BUTTON_MATCH_CURRENT_ALTITUDE = "Match Current Altitude"
local BUTTON_LOCK = "Lock"
local BUTTON_UNLOCK = "Unlock"
local BUTTON_POWER_OFF = "Power Off"
local BUTTON_POWER_ON = "Power On"

-- Define button ranges, either in tables of x1,y1,x2,y2 or lists of those tables.
_G.agScreenController.buttonCoordinates = {}
_G.agScreenController.buttonCoordinates[BUTTON_ALTITUDE_UP] = {
    x1 = 0.05, x2 = 0.35,
    y1 = 0.2, y2 = 0.45
}
_G.agScreenController.buttonCoordinates[BUTTON_ALTITUDE_DOWN] = {
    x1 = 0.05, x2 = 0.35,
    y1 = 0.65, y2 = 0.9
}
_G.agScreenController.buttonCoordinates[BUTTON_ALTITUDE_ADJUST_DOWN] = {
    x1 = 0.35, x2 = 0.4,
    y1 = 0.5, y2 = 0.6
}
_G.agScreenController.buttonCoordinates[BUTTON_ALTITUDE_ADJUST_UP] = {
    x1 = 0.0, x2 = 0.05,
    y1 = 0.5, y2 = 0.6
}
_G.agScreenController.buttonCoordinates[BUTTON_TARGET_ALTITUDE_SLIDER] = {
    x1 = 0.4, x2 = 0.5,
    y1 = 0.1, y2 = 1.0
}
_G.agScreenController.buttonCoordinates[BUTTON_MATCH_CURRENT_ALTITUDE] = {
    x1 = 0.5, x2 = 0.6,
    y1 = 0.1, y2 = 1.0
}
_G.agScreenController.buttonCoordinates[BUTTON_LOCK] = {
    x1 = 0.3, x2 = 0.4,
    y1 = 0.1, y2 = 0.2
}
_G.agScreenController.buttonCoordinates[BUTTON_UNLOCK] = {
    x1 = 0.0, x2 = 0.1,
    y1 = 0.1, y2 = 0.2
}
_G.agScreenController.buttonCoordinates[BUTTON_POWER_OFF] = {
    x1 = 0.9, x2 = 1.0,
    y1 = 0.1, y2 = 0.2
}
_G.agScreenController.buttonCoordinates[BUTTON_POWER_ON] = {
    x1 = 0.6, x2 = 0.7,
    y1 = 0.1, y2 = 0.2
}

-- both sliders on same level, pre-compute y ranges with 5% buffer
local sliderYMin = _G.agScreenController.buttonCoordinates[BUTTON_UNLOCK].y1 - SCREEN_HEIGHT * 0.05
local sliderYMax = _G.agScreenController.buttonCoordinates[BUTTON_UNLOCK].y2 + SCREEN_HEIGHT * 0.05

-- pre-computed values for less computation in render thread
local logMin = math.log(MIN_SLIDER_ALTITUDE)
local logMax = math.log(MAX_SLIDER_ALTITUDE)
local scaleHeight = ALT_SLIDER_BOTTOM - ALT_SLIDER_TOP
local scaleHeightOverLogDifference = scaleHeight / (logMax - logMin)

-- yPixel = sliderBottom - (sliderHeight * (log(altitude) - log(minAltitude)) / (log(maxAltitude) - log(minAltitude)))
local function calculateSliderIndicator(altitude)
    return math.floor(ALT_SLIDER_BOTTOM - scaleHeightOverLogDifference * (math.log(altitude) - logMin) + 0.5)
end

-- altitude = e^((sliderBottom - yPixel) / sliderHeight * (log(maxAltitude) - log(minAltitude)) + log(minAltitude)
local function calculateSliderAltitude(indicatorY)
    local indicatorYpixels = indicatorY * SCREEN_HEIGHT
    return math.floor(math.exp((ALT_SLIDER_BOTTOM - indicatorYpixels) / scaleHeightOverLogDifference + logMin) + 0.5)
end

function _G.agScreenController:refresh()
    -- refresh conditions: needRefresh, mouse down
    if not (self.needRefresh or self.mouse.pressed) then
        return
    end
    self.needRefresh = false

    -- update mouse position for tracking drags
    self.mouse.x = self.screen.getMouseX()
    self.mouse.y = self.screen.getMouseY()
    self.mouse.state = self.screen.getMouseState() == 1
    -- if mouse has left screen remove pressed flag
    if self.mouse.x < 0 then
        self.mouse.pressed = nil
    end

    local html = self.SVG_TEMPLATE

    -- track mouse drags
    if self.locked and self.mouse.pressed == BUTTON_UNLOCK then
        -- if unlocking then check mouse against bounds of slide bar
        if not self.mouse.state or self.mouse.y < sliderYMin or self.mouse.y > sliderYMax then
            self.mouse.pressed = nil
        elseif self.mouse.x > self.buttonCoordinates[BUTTON_LOCK].x1 then
            self.mouse.pressed = nil
            self.locked = false
        else
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_UNLOCKING_LABEL, "")
            html = string.gsub(html, "(id=\"locked\" x=)\"%d+", "%1\"" .. (self.mouse.x * 1920))
        end
    elseif self.controller.agState and self.mouse.pressed == BUTTON_POWER_OFF then
        -- if powering off then check mouse against bounds of slide bar
        if not self.mouse.state or self.mouse.y < sliderYMin or self.mouse.y > sliderYMax then
            self.mouse.pressed = nil
        elseif self.mouse.x < self.buttonCoordinates[BUTTON_POWER_ON].x2 then
            self.mouse.pressed = nil
            self.controller:setAgState(false)
        else
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_POWER_SLIDER, "")
            html = string.gsub(html, "(id=\"power\" x=)\"%d+", "%1\"" .. (self.mouse.x * 1920))
        end
    elseif not self.locked and self.mouse.pressed == BUTTON_TARGET_ALTITUDE_SLIDER then
        -- if dragging altitude track mouse
        if not self.mouse.state then
            self.mouse.pressed = nil
        else
            local target = calculateSliderAltitude(self.mouse.y)

            if target > MAX_SLIDER_ALTITUDE then
                target = MAX_SLIDER_ALTITUDE
            end

            self.controller:setBaseAltitude(target)
        end
    end

    -- extract values to show in svg
    local targetAltitude = self.controller.targetAltitude

    local targetAltitudeString
    if self.locked then
        targetAltitudeString = math.floor(targetAltitude)
    else
        targetAltitudeString = ""
        local targetAltitudeRemainder = targetAltitude
        local adjustmentRemainder = self.altitudeAdjustment
        while targetAltitudeRemainder > 0 or adjustmentRemainder > 0 do
            local nextDigit = math.floor(targetAltitudeRemainder % 10)
            if adjustmentRemainder == 1 then
                targetAltitudeString = string.format('<tspan class="adjust">%d</tspan>%s',
                    nextDigit, targetAltitudeString)
            else
                targetAltitudeString = nextDigit .. targetAltitudeString
            end
            targetAltitudeRemainder = math.floor(targetAltitudeRemainder / 10)
            adjustmentRemainder = math.floor(adjustmentRemainder / 10)
        end
    end

    local baseAltitude = math.floor(self.controller.baseAltitude)

    local verticalVelocity, verticalUnits
    if USE_KMPH then
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
    local currentAltitude = math.floor(self.controller.currentAltitude + 0.5)
    local agPower = math.floor(self.controller.agPower * 100 + 0.5)
    local agField = math.floor(self.controller.agField * 100 + 0.5)
    local targetAltitudeSliderHeight = calculateSliderIndicator(targetAltitude)
    local currentAltitudeSliderHeight
    if currentAltitude == 0 then
        currentAltitude = "N/A"
        currentAltitudeSliderHeight = -1000
    else
        currentAltitudeSliderHeight = calculateSliderIndicator(currentAltitude)
    end
    local baseAltitudeSliderHeight = calculateSliderIndicator(baseAltitude)

    -- insert values to svg and render
    html = _G.Utilities.sanitizeFormatString(html)
    html = string.format(html, currentAltitudeSliderHeight, targetAltitudeSliderHeight, baseAltitudeSliderHeight,
        targetAltitudeString, baseAltitude, verticalVelocity, verticalUnits,
               currentAltitude, agField, agPower)

    -- adjust visibility for state
    -- controls locked
    if self.locked then
        html = _G.ScreenUtils.replaceClass(html, PANEL_CLASS_ADJUSTMENT, HIDDEN_CLASS)
        html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_UNLOCKED_BUTTON, HIDDEN_CLASS)
    else
        html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_LOCKED_BUTTON, HIDDEN_CLASS)
    end
    -- AG power/error state
    if not self.controller.agState then
        -- powered off
        html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_POWER_IS_ON, HIDDEN_CLASS)
        html = _G.ScreenUtils.replaceClass(html, PANEL_CLASS_STATUS, HIDDEN_CLASS)
        html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_DISABLED, "")
    else
        -- powered on
        html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_POWER_IS_OFF, HIDDEN_CLASS)

        if agField <= 50 then -- use rounded number from display
            -- insufficient pulsors
            html = _G.ScreenUtils.replaceClass(html, PANEL_CLASS_STATUS, HIDDEN_CLASS)
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_NEED_PULSORS, "")
        end
    end

    if not self.mouse.pressed then
        -- add mouse-over highlights
        local mouseOver, _ = _G.ScreenUtils.detectButton(self.buttonCoordinates, self.mouse.x, self.mouse.y)
        if mouseOver == BUTTON_ALTITUDE_ADJUST_UP then
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_ADJUST_UP, MOUSE_OVER_CLASS)
        elseif mouseOver == BUTTON_ALTITUDE_ADJUST_DOWN then
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_ADJUST_DOWN, MOUSE_OVER_CLASS)
        elseif mouseOver == BUTTON_ALTITUDE_UP then
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_ALTITUDE_UP, MOUSE_OVER_CLASS)
        elseif mouseOver == BUTTON_ALTITUDE_DOWN then
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_ALTITUDE_DOWN, MOUSE_OVER_CLASS)
        elseif not self.locked and mouseOver == BUTTON_TARGET_ALTITUDE_SLIDER then
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_LEFT_SLIDER, MOUSE_OVER_CLASS)
        elseif not self.locked and mouseOver == BUTTON_MATCH_CURRENT_ALTITUDE then
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_RIGHT_SLIDER, MOUSE_OVER_CLASS)
        elseif mouseOver == BUTTON_LOCK then
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_UNLOCKED_BUTTON, MOUSE_OVER_CLASS)
        elseif mouseOver == BUTTON_UNLOCK then
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_LOCKED_BUTTON, MOUSE_OVER_CLASS)
        elseif mouseOver == BUTTON_POWER_OFF then
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_POWER_IS_ON, MOUSE_OVER_CLASS)
        elseif mouseOver == BUTTON_POWER_ON then
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_POWER_IS_OFF, MOUSE_OVER_CLASS)
        end
    end

    self.screen.setHTML(html)
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
    if not released then
        return
    elseif self.mouse.pressed == released then
        local modified = self:handleButton(released)
        self.needRefresh = self.needRefresh or modified
    end
    self.mouse.pressed = nil
end

--- Processes the input indicated by the provided button id.
-- @treturn boolean True if the state was changed by this action.
function _G.agScreenController:handleButton(buttonId)
    local modified = false

    if not self.locked then
        if buttonId == BUTTON_ALTITUDE_UP then
            local adjusted = self.controller.targetAltitude + self.altitudeAdjustment
            modified = adjusted ~= self.controller.targetAltitude

            self.controller:setBaseAltitude(adjusted)

        elseif buttonId == BUTTON_ALTITUDE_DOWN then
            local adjusted = self.controller.targetAltitude - self.altitudeAdjustment
            modified = adjusted ~= self.controller.targetAltitude

            self.controller:setBaseAltitude(adjusted)

        elseif buttonId == BUTTON_ALTITUDE_ADJUST_UP then
            modified = self:setAltitudeAdjust(self.altitudeAdjustment * 10)

        elseif buttonId == BUTTON_ALTITUDE_ADJUST_DOWN then
            modified = self:setAltitudeAdjust(self.altitudeAdjustment / 10)

        elseif buttonId == BUTTON_MATCH_CURRENT_ALTITUDE then
            local adjusted = self.controller.currentAltitude
            modified = adjusted ~= self.controller.targetAltitude

            self.controller:setBaseAltitude(adjusted)

        elseif buttonId == BUTTON_LOCK then
            self.locked = true
            modified = true

        elseif buttonId == BUTTON_POWER_ON then
            self.controller:setAgState(true)
            modified = true
        end
    end

    return modified
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
