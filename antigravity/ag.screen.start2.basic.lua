--- Run second, define agScreenController SVG-specific functionality: rendering, buttons, etc

-- constants for svg file
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
local ELEMENT_CLASS_NO_POWER_WARNING = "noPowerWarning"
local ELEMENT_CLASS_POWER_IS_OFF = "powerIsOffClass"
local ELEMENT_CLASS_POWER_IS_ON = "powerIsOnClass"
local ELEMENT_CLASS_POWER_SLIDER = "powerSlideClass"

local ALTITUDE_ADJUST_KEY = "altitudeAdjustment"

-- add SVG-specific fields
_G.agScreenController.SVG_TEMPLATE = [[${file:ag.screen.basic.svg minify}]]
_G.agScreenController.SVG_LOGO = [[${file:../logo.svg minify}]]

-- one-time transforms
_G.agScreenController.SVG_TEMPLATE = string.gsub(_G.agScreenController.SVG_TEMPLATE, '<svg id="logo"/>', _G.agScreenController.SVG_LOGO)

-- constant button definition labels
_G.agScreenController.BUTTON_ALTITUDE_UP = "Altitude Up"
_G.agScreenController.BUTTON_ALTITUDE_DOWN = "Altitude Down"
_G.agScreenController.BUTTON_ALTITUDE_ADJUST_UP = "Altitude Adjust Up"
_G.agScreenController.BUTTON_ALTITUDE_ADJUST_DOWN = "Altitude Adjust Down"
_G.agScreenController.BUTTON_TARGET_ALTITUDE_SLIDER = "Target Altitude Slider"
_G.agScreenController.BUTTON_MATCH_CURRENT_ALTITUDE = "Match Current Altitude"
_G.agScreenController.BUTTON_LOCK = "Lock"
_G.agScreenController.BUTTON_UNLOCK = "Unlock"
_G.agScreenController.BUTTON_POWER_OFF = "Power Off"
_G.agScreenController.BUTTON_POWER_ON = "Power On"

-- both sliders on same level, pre-compute y ranges with 5% buffer
_G.agScreenController.sliderYMin = nil -- override with SVG-specific value
_G.agScreenController.sliderYMax = nil -- override with SVG-specific value

function _G.agScreenController.calculateSliderIndicator(altitude)
    assert(false, "Should be overridden by SVG-specific method.")
end

function _G.agScreenController.calculateSliderAltitude(indicatorY)
    assert(false, "Should be overridden by SVG-specific method.")
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
    if self.locked and self.mouse.pressed == _G.agScreenController.BUTTON_UNLOCK then
        -- if unlocking then check mouse against bounds of slide bar
        if not self.mouse.state or self.mouse.y < _G.agScreenController.sliderYMin or self.mouse.y > _G.agScreenController.sliderYMax then
            self.mouse.pressed = nil
        elseif self.mouse.x > self.buttonCoordinates[_G.agScreenController.BUTTON_LOCK].x1 then
            self.mouse.pressed = nil
            self.locked = false
        else
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_UNLOCKING_LABEL, "")
            html = string.gsub(html, "(id=\"locked\" x=)\"%d+", "%1\"" .. (self.mouse.x * 1920))
        end
    elseif self.controller.agState and self.mouse.pressed == _G.agScreenController.BUTTON_POWER_OFF then
        -- if powering off then check mouse against bounds of slide bar
        if not self.mouse.state or self.mouse.y < _G.agScreenController.sliderYMin or self.mouse.y > _G.agScreenController.sliderYMax then
            self.mouse.pressed = nil
        elseif self.mouse.x < self.buttonCoordinates[_G.agScreenController.BUTTON_POWER_ON].x2 then
            self.mouse.pressed = nil
            self.controller:setAgState(false)
        else
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_POWER_SLIDER, "")
            html = string.gsub(html, "(id=\"power\" x=)\"%d+", "%1\"" .. (self.mouse.x * 1920))
        end
    elseif not self.locked and self.mouse.pressed == _G.agScreenController.BUTTON_TARGET_ALTITUDE_SLIDER then
        -- if dragging altitude track mouse
        if not self.mouse.state then
            self.mouse.pressed = nil
        else
            local target = _G.agScreenController.calculateSliderAltitude(self.mouse.y)

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
    local verticalVelocity, verticalUnits = self:getVerticalVelocity()
    local currentAltitude = math.floor(self.controller.currentAltitude + 0.5)
    local agPower = math.floor(self.controller.agPower * 100 + 0.5)
    local agField = math.floor(self.controller.agField * 100 + 0.5)
    local targetAltitudeSliderHeight = _G.agScreenController.calculateSliderIndicator(targetAltitude)
    local currentAltitudeSliderHeight
    if currentAltitude < 0 then
        -- breaks log scale
        currentAltitudeSliderHeight = -1000
    elseif currentAltitude == 0 then
        currentAltitude = "N/A"
        currentAltitudeSliderHeight = -1000
    else
        currentAltitudeSliderHeight = _G.agScreenController.calculateSliderIndicator(currentAltitude)
    end
    local baseAltitudeSliderHeight = _G.agScreenController.calculateSliderIndicator(baseAltitude)

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
        elseif agPower <= 0 then -- use rounded number from display
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_NO_POWER_WARNING, "")
        end
    end

    if not self.mouse.pressed then
        -- add mouse-over highlights
        local mouseOver, _ = _G.ScreenUtils.detectButton(self.buttonCoordinates, self.mouse.x, self.mouse.y)
        if mouseOver == _G.agScreenController.BUTTON_ALTITUDE_ADJUST_UP then
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_ADJUST_UP, MOUSE_OVER_CLASS)
        elseif mouseOver == _G.agScreenController.BUTTON_ALTITUDE_ADJUST_DOWN then
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_ADJUST_DOWN, MOUSE_OVER_CLASS)
        elseif mouseOver == _G.agScreenController.BUTTON_ALTITUDE_UP then
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_ALTITUDE_UP, MOUSE_OVER_CLASS)
        elseif mouseOver == _G.agScreenController.BUTTON_ALTITUDE_DOWN then
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_ALTITUDE_DOWN, MOUSE_OVER_CLASS)
        elseif not self.locked and mouseOver == _G.agScreenController.BUTTON_TARGET_ALTITUDE_SLIDER then
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_LEFT_SLIDER, MOUSE_OVER_CLASS)
        elseif not self.locked and mouseOver == _G.agScreenController.BUTTON_MATCH_CURRENT_ALTITUDE then
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_RIGHT_SLIDER, MOUSE_OVER_CLASS)
        elseif mouseOver == _G.agScreenController.BUTTON_LOCK then
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_UNLOCKED_BUTTON, MOUSE_OVER_CLASS)
        elseif mouseOver == _G.agScreenController.BUTTON_UNLOCK then
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_LOCKED_BUTTON, MOUSE_OVER_CLASS)
        elseif mouseOver == _G.agScreenController.BUTTON_POWER_OFF then
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_POWER_IS_ON, MOUSE_OVER_CLASS)
        elseif mouseOver == _G.agScreenController.BUTTON_POWER_ON then
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLASS_POWER_IS_OFF, MOUSE_OVER_CLASS)
        end
    end

    self.screen.setHTML(html)
end

--- Processes the input indicated by the provided button id.
-- @treturn boolean True if the state was changed by this action.
function _G.agScreenController:handleButton(buttonId)
    local modified = false

    if not self.locked then
        if buttonId == _G.agScreenController.BUTTON_ALTITUDE_UP then
            local adjusted = self.controller.targetAltitude + self.altitudeAdjustment
            modified = adjusted ~= self.controller.targetAltitude

            self.controller:setBaseAltitude(adjusted)

        elseif buttonId == _G.agScreenController.BUTTON_ALTITUDE_DOWN then
            local adjusted = self.controller.targetAltitude - self.altitudeAdjustment
            modified = adjusted ~= self.controller.targetAltitude

            self.controller:setBaseAltitude(adjusted)

        elseif buttonId == _G.agScreenController.BUTTON_ALTITUDE_ADJUST_UP then
            modified = self:setAltitudeAdjust(self.altitudeAdjustment * 10)

        elseif buttonId == _G.agScreenController.BUTTON_ALTITUDE_ADJUST_DOWN then
            modified = self:setAltitudeAdjust(self.altitudeAdjustment / 10)

        elseif buttonId == _G.agScreenController.BUTTON_MATCH_CURRENT_ALTITUDE then
            local adjusted = self.controller.currentAltitude
            modified = adjusted ~= self.controller.targetAltitude

            self.controller:setBaseAltitude(adjusted)

        elseif buttonId == _G.agScreenController.BUTTON_LOCK then
            self.locked = true
            modified = true

        elseif buttonId == _G.agScreenController.BUTTON_POWER_ON then
            self.controller:setAgState(true)
            modified = true
        end
    end

    return modified
end
