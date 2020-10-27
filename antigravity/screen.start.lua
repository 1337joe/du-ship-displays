
local SVG_TEMPLATE = [[${file:screen.svg}]]
local SVG_LOGO = [[${file:../logo.svg minify}]]

-- constants and editable lua script parameters
local SCREEN_HEIGHT = 1080
local MAX_SLIDER_ALTITUDE = 200000
local MIN_SLIDER_ALTITUDE = 1000
local MIN_AG_ALTITUDE = 1025 --export: Min altitude to allow setting on anti-grav (m)
local MIN_ADJUSTMENT_VALUE = 1
local MAX_ADJUSTMENT_VALUE = 10000 --export: Max step size for altitude adjustment (m)

-- one-time transforms
SVG_TEMPLATE = string.gsub(SVG_TEMPLATE, '<svg id="logo"/>', SVG_LOGO)

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

-- initialize object and fields
_G.agScreen = {
    altitudeAdjustment = 1000,
    mouse = {x = -1, y = -1, pressed = nil, state = false},
    locked = false,
}

function _G.agScreen:init(controller)
    self.controller = controller
    self.screen = controller.slots.screen
    self.targetAltitude = math.floor(controller.baseAltitude + 0.5) -- snap to nearest meter
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
_G.agScreen.buttonCoordinates = {}
_G.agScreen.buttonCoordinates[BUTTON_ALTITUDE_UP] = {
    x1 = 0.1, x2 = 0.3,
    y1 = 0.2, y2 = 0.4
}
_G.agScreen.buttonCoordinates[BUTTON_ALTITUDE_DOWN] = {
    x1 = 0.1, x2 = 0.3,
    y1 = 0.7, y2 = 0.9
}
_G.agScreen.buttonCoordinates[BUTTON_ALTITUDE_ADJUST_UP] = {
    {
        x1 = 0.3, x2 = 0.35,
        y1 = 0.3, y2 = 0.45
    },
    {
        x1 = 0.3, x2 = 0.35,
        y1 = 0.65, y2 = 0.8
    }
}
_G.agScreen.buttonCoordinates[BUTTON_ALTITUDE_ADJUST_DOWN] = {
    {
        x1 = 0.05, x2 = 0.1,
        y1 = 0.3, y2 = 0.45
    },
    {
        x1 = 0.05, x2 = 0.1,
        y1 = 0.65, y2 = 0.8
    }
}
_G.agScreen.buttonCoordinates[BUTTON_TARGET_ALTITUDE_SLIDER] = {
    x1 = 0.4, x2 = 0.5,
    y1 = 0.1, y2 = 1.0
}
_G.agScreen.buttonCoordinates[BUTTON_MATCH_CURRENT_ALTITUDE] = {
    x1 = 0.5, x2 = 0.6,
    y1 = 0.1, y2 = 1.0
}
_G.agScreen.buttonCoordinates[BUTTON_LOCK] = {
    x1 = 0.3, x2 = 0.4,
    y1 = 0.1, y2 = 0.2
}
_G.agScreen.buttonCoordinates[BUTTON_UNLOCK] = {
    x1 = 0.0, x2 = 0.1,
    y1 = 0.1, y2 = 0.2
}
_G.agScreen.buttonCoordinates[BUTTON_POWER_OFF] = {
    x1 = 0.9, x2 = 1.0,
    y1 = 0.1, y2 = 0.2
}
_G.agScreen.buttonCoordinates[BUTTON_POWER_ON] = {
    x1 = 0.6, x2 = 0.7,
    y1 = 0.1, y2 = 0.2
}

-- both sliders on same level, pre-compute y ranges with 5% buffer
local sliderYMin = _G.agScreen.buttonCoordinates[BUTTON_UNLOCK].y1 - SCREEN_HEIGHT * 0.05
local sliderYMax = _G.agScreen.buttonCoordinates[BUTTON_UNLOCK].y2 + SCREEN_HEIGHT * 0.05

local function replaceClass(html, find, replace)
    -- ensure preceeded by " or space
    return string.gsub(html, "([\"%s])" .. find, "%1" .. replace)
end

local logMin = math.log(MIN_SLIDER_ALTITUDE)
local logMax = math.log(MAX_SLIDER_ALTITUDE)
local scaleHeight = ALT_SLIDER_BOTTOM - ALT_SLIDER_TOP
local function calculateSliderIndicator(altitude)
    return math.floor(ALT_SLIDER_BOTTOM - scaleHeight * (math.log(altitude) - logMin) / (logMax - logMin) + 0.5)
end

local function calculateSliderAltitude(indicatorY)
    local indicatorYpixels = indicatorY * SCREEN_HEIGHT
    return math.floor(math.exp((ALT_SLIDER_BOTTOM - indicatorYpixels) / scaleHeight * (logMax - logMin) + logMin) + 0.5)
end

function _G.agScreen:refresh()
    -- refresh conditions: needRefresh, mouse down
    if not (self.controller.needRefresh or self.mouse.pressed) then
        return
    end
    self.controller.needRefresh = false

    -- update mouse position for tracking drags
    self.mouse.x = self.screen.getMouseX()
    self.mouse.y = self.screen.getMouseY()
    self.mouse.state = self.screen.getMouseState() == 1
    -- if mouse has left screen remove pressed flag
    if self.mouse.x < 0 then
        self.mouse.pressed = nil
    end

    local html = SVG_TEMPLATE

    -- track mouse drags
    -- if unlocking track drag against bounds
    if self.locked and self.mouse.pressed == BUTTON_UNLOCK then
        if not self.mouse.state or self.mouse.y < sliderYMin or self.mouse.y > sliderYMax then
            self.mouse.pressed = nil
        elseif self.mouse.x > self.buttonCoordinates[BUTTON_LOCK].x1 then
            self.mouse.pressed = nil
            self.locked = false
        else
            html = replaceClass(html, ELEMENT_CLASS_UNLOCKING_LABEL, "")
            html = string.gsub(html, "(id=\"locked\" x=)\"%d+", "%1\"" .. (self.mouse.x * 1920))
        end
    -- if powering off track against bounds
    elseif self.controller.agState and self.mouse.pressed == BUTTON_POWER_OFF then
        if not self.mouse.state or self.mouse.y < sliderYMin or self.mouse.y > sliderYMax then
            self.mouse.pressed = nil
        elseif self.mouse.x < self.buttonCoordinates[BUTTON_POWER_ON].x2 then
            self.mouse.pressed = nil
            self.controller:setAgState(false)
        else
            html = replaceClass(html, ELEMENT_CLASS_POWER_SLIDER, "")
            html = string.gsub(html, "(id=\"power\" x=)\"%d+", "%1\"" .. (self.mouse.x * 1920))
        end
    -- if dragging altitude track mouse
    elseif not self.locked and self.mouse.pressed == BUTTON_TARGET_ALTITUDE_SLIDER then
        local targetAltitud
        if not self.mouse.state then
            self.mouse.pressed = nil
        else
            local target = calculateSliderAltitude(self.mouse.y)

            if target > MAX_SLIDER_ALTITUDE then
                target = MAX_SLIDER_ALTITUDE
            elseif target < MIN_AG_ALTITUDE then
                target = MIN_AG_ALTITUDE
            end

            self.targetAltitude = target
            self.controller:setBaseAltitude(self.targetAltitude)
        end
    end

    -- extract values to show in svg
    local targetAltitude = self.targetAltitude
    local baseAltitude = self.controller.baseAltitude
    local altitudeAdjustment = string.format("%d m", self.altitudeAdjustment)
    local verticalVelocity, verticalUnits = _G.Utilities.printableNumber(self.controller.verticalVelocity, "m/s")
    local currentAltitude = math.floor(self.controller.currentAltitude + 0.5)
    local agPower = math.floor(self.controller.agPower * 100 + 0.5)
    local agField = math.floor(self.controller.agField * 100 + 0.5)
    local targetAltitudeSliderHeight = calculateSliderIndicator(targetAltitude)
    local currentAltitudeSliderHeight = calculateSliderIndicator(currentAltitude)
    local baseAltitudeSliderHeight = calculateSliderIndicator(baseAltitude)

    -- insert values to svg and render
    html = _G.Utilities.sanitizeFormatString(html)
    html = string.format(html,
        currentAltitudeSliderHeight, targetAltitudeSliderHeight, baseAltitudeSliderHeight,
        targetAltitude, baseAltitude, altitudeAdjustment, altitudeAdjustment,
        verticalVelocity, verticalUnits, currentAltitude, agField, agPower)

    -- adjust visibility for state
    -- controls locked
    if self.locked then
        html = replaceClass(html, PANEL_CLASS_ADJUSTMENT, HIDDEN_CLASS)
        html = replaceClass(html, ELEMENT_CLASS_UNLOCKED_BUTTON, HIDDEN_CLASS)
    else
        html = replaceClass(html, ELEMENT_CLASS_LOCKED_BUTTON, HIDDEN_CLASS)
    end
    -- AG power/error state
    if not self.controller.agState then
        -- powered off
        html = replaceClass(html, ELEMENT_CLASS_POWER_IS_ON, HIDDEN_CLASS)
        html = replaceClass(html, PANEL_CLASS_STATUS, HIDDEN_CLASS)
        html = replaceClass(html, ELEMENT_CLASS_DISABLED, "")
    else
        -- powered on
        html = replaceClass(html, ELEMENT_CLASS_POWER_IS_OFF, HIDDEN_CLASS)

        if self.controller.agField < 0.5 then
            -- insufficient pulsors
            html = replaceClass(html, PANEL_CLASS_STATUS, HIDDEN_CLASS)
            html = replaceClass(html, ELEMENT_CLASS_NEED_PULSORS, "")
        end
    end

    if not self.mouse.pressed then
        -- add mouse-over highlights
        local mouseOver, index = self:detectPress(self.mouse.x, self.mouse.y)
        if mouseOver == BUTTON_ALTITUDE_ADJUST_UP then
            html = replaceClass(html, ELEMENT_CLASS_ADJUST_UP .. index, MOUSE_OVER_CLASS)
        elseif mouseOver == BUTTON_ALTITUDE_ADJUST_DOWN then
            html = replaceClass(html, ELEMENT_CLASS_ADJUST_DOWN .. index, MOUSE_OVER_CLASS)
        elseif mouseOver == BUTTON_ALTITUDE_UP then
            html = replaceClass(html, ELEMENT_CLASS_ALTITUDE_UP, MOUSE_OVER_CLASS)
        elseif mouseOver == BUTTON_ALTITUDE_DOWN then
            html = replaceClass(html, ELEMENT_CLASS_ALTITUDE_DOWN, MOUSE_OVER_CLASS)
        elseif not self.locked and mouseOver == BUTTON_TARGET_ALTITUDE_SLIDER then
            html = replaceClass(html, ELEMENT_CLASS_LEFT_SLIDER, MOUSE_OVER_CLASS)
        elseif not self.locked and mouseOver == BUTTON_MATCH_CURRENT_ALTITUDE then
            html = replaceClass(html, ELEMENT_CLASS_RIGHT_SLIDER, MOUSE_OVER_CLASS)
        elseif mouseOver == BUTTON_LOCK then
            html = replaceClass(html, ELEMENT_CLASS_UNLOCKED_BUTTON, MOUSE_OVER_CLASS)
        elseif mouseOver == BUTTON_UNLOCK then
            html = replaceClass(html, ELEMENT_CLASS_LOCKED_BUTTON, MOUSE_OVER_CLASS)
        elseif mouseOver == BUTTON_POWER_OFF then
            html = replaceClass(html, ELEMENT_CLASS_POWER_IS_ON, MOUSE_OVER_CLASS)
        elseif mouseOver == BUTTON_POWER_ON then
            html = replaceClass(html, ELEMENT_CLASS_POWER_IS_OFF, MOUSE_OVER_CLASS)
        end
    end

    self.screen.setHTML(html)
end

function _G.agScreen:mouseDown(x, y)
    self.mouse.x = x
    self.mouse.y = y
    self.mouse.pressed = self:detectPress(x, y)
end

function _G.agScreen:mouseUp(x, y)
    local released = self:detectPress(x, y)
    if not released then
        return
    elseif self.mouse.pressed == released then
        local modified = self:handleButton(released)
        self.controller.needRefresh = self.controller.needRefresh or modified
    end
    self.mouse.pressed = nil
end

--- Returns the button that intersects the provided coordinates or nil if none is found.
function _G.agScreen:detectPress(x, y)
    local found = false
    local index = nil
    for button, coords in pairs(self.buttonCoordinates) do
        if coords.x1 then
            if x > coords.x1 and x < coords.x2 and y > coords.y1 and y < coords.y2 then
                found = true
            end
        else
            for i,innerCoords in pairs(coords) do
                if innerCoords.x1 then
                    if x > innerCoords.x1 and x < innerCoords.x2 and y > innerCoords.y1 and y < innerCoords.y2 then
                        found = true
                        index = i
                    end
                else
                    break
                end
            end
        end

        if found then
            return button, index
        end
    end
    return nil
end

--- Processes the input indicated by the provided button id.
-- @treturn boolean True if the state was changed by this action.
function _G.agScreen:handleButton(buttonId)
    local modified = false

    if not self.locked then
        if buttonId == BUTTON_ALTITUDE_UP then
            local adjusted = self.targetAltitude + self.altitudeAdjustment
            modified = adjusted ~= self.targetAltitude
            self.targetAltitude = adjusted

            self.controller:setBaseAltitude(self.targetAltitude)

        elseif buttonId == BUTTON_ALTITUDE_DOWN then
            local adjusted = self.targetAltitude - self.altitudeAdjustment
            if adjusted < MIN_AG_ALTITUDE then
                adjusted = MIN_AG_ALTITUDE
            end
            modified = adjusted ~= self.targetAltitude
            self.targetAltitude = adjusted

            self.controller:setBaseAltitude(self.targetAltitude)

        elseif buttonId == BUTTON_ALTITUDE_ADJUST_UP then
            local newAdjust = self.altitudeAdjustment * 10
            if newAdjust > MAX_ADJUSTMENT_VALUE then
                newAdjust = MAX_ADJUSTMENT_VALUE
            end
            modified = newAdjust ~= self.altitudeAdjustment
            self.altitudeAdjustment = newAdjust

        elseif buttonId == BUTTON_ALTITUDE_ADJUST_DOWN then
            local newAdjust = self.altitudeAdjustment / 10
            if newAdjust < MIN_ADJUSTMENT_VALUE then
                newAdjust = MIN_ADJUSTMENT_VALUE
            end
            modified = newAdjust ~= self.altitudeAdjustment
            self.altitudeAdjustment = newAdjust

        elseif buttonId == BUTTON_MATCH_CURRENT_ALTITUDE then
            local adjusted = math.floor(_G.agController.currentAltitude + 0.5) -- snap to nearest meter
            modified = adjusted ~= self.targetAltitude
            self.targetAltitude = adjusted

            self.controller:setBaseAltitude(self.targetAltitude)

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