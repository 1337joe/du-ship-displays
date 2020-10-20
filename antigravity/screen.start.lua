
local SVG_TEMPLATE = [[${file:screen.svg}]]
local SVG_LOGO = [[${file:../logo.svg minify}]]

-- constants and editable lua script parameters
local MAX_SLIDER_ALTITUDE = 100000 --export: Max altitude value on the slider (m)
local MIN_ADJUSTMENT_VALUE = 1
local MAX_ADJUSTMENT_VALUE = 10000 --export: Max step size for altitude adjustment (m)

-- one-off transforms
-- embed logo
SVG_TEMPLATE = string.gsub(SVG_TEMPLATE, '<svg id="logo"/>', SVG_LOGO)
-- set max slider height, subtract 1000 to account for min height
SVG_TEMPLATE = string.gsub(SVG_TEMPLATE, "99000", tostring(MAX_SLIDER_ALTITUDE - 1000))

-- constants for svg file
local ALT_SLIDER_TOP = 162
local ALT_SLIDER_BOTTOM = 1026
local MOUSE_OVER_CLASS = "mouseOver"
local HIDDEN_CLASS = "hidden"
local PANEL_CLASS_ADJUSTMENT = "adjustmentWidgets"
local ELEMENT_CLASS_UNLOCKED_BUTTON = "unlockedClass"
local ELEMENT_CLASS_UNLOCKING_LABEL = "unlockSlideClass"
local ELEMENT_CLASS_LOCKED_BUTTON = "lockedClass"
local ELEMENT_CLASS_ALTITUDE_UP = "altitudeUpClass"
local ELEMENT_CLASS_ALTITUDE_DOWN = "altitudeDownClass"
local ELEMENT_CLASS_ADJUST_UP = "adjustUpClass"
local ELEMENT_CLASS_ADJUST_DOWN = "adjustDownClass"
local ELEMENT_CLASS_RIGHT_SLIDER = "rightSliderClass"

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
local BUTTON_MATCH_CURRENT_ALTITUDE = "Match Current Altitude"
local BUTTON_LOCK = "Lock"
local BUTTON_UNLOCK = "Unlock"

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

local function replaceClass(html, find, replace)
    -- ensure preceeded by " or space
    return string.gsub(html, "([\"%s])" .. find, "%1" .. replace)
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

    -- extract values to show in svg
    local targetAltitude = self.targetAltitude
    local baseAltitude = self.controller.baseAltitude
    local altitudeAdjustment = string.format("%d m", self.altitudeAdjustment)
    local verticalVelocity, verticalUnits = _G.Utilities.printableNumber(self.controller.verticalVelocity, "m/s")
    local currentAltitude = math.floor(self.controller.currentAltitude + 0.5)
    local agPower = math.floor(self.controller.agPower * 100 + 0.5)
    local agField = math.floor(self.controller.agField * 100 + 0.5)
    local targetAltitudeSliderHeight = math.floor(ALT_SLIDER_BOTTOM - targetAltitude / (MAX_SLIDER_ALTITUDE - 1000 ) * (ALT_SLIDER_BOTTOM - ALT_SLIDER_TOP) + 0.5)
    local currentAltitudeSliderHeight = math.floor(ALT_SLIDER_BOTTOM - currentAltitude / (MAX_SLIDER_ALTITUDE - 1000 ) * (ALT_SLIDER_BOTTOM - ALT_SLIDER_TOP) + 0.5)

    -- insert values to svg and render
    local html = SVG_TEMPLATE
    html = _G.Utilities.sanitizeFormatString(html)
    html = string.format(html, MAX_SLIDER_ALTITUDE, currentAltitudeSliderHeight, targetAltitudeSliderHeight,
        targetAltitude, baseAltitude, altitudeAdjustment, altitudeAdjustment,
        verticalVelocity, verticalUnits, currentAltitude, agField, agPower)

    -- if unlocking track drag against bounds
    if self.locked and self.mouse.pressed == BUTTON_UNLOCK then
        if not self.mouse.state or self.mouse.y < self.buttonCoordinates[BUTTON_UNLOCK].y1 or self.mouse.y > self.buttonCoordinates[BUTTON_UNLOCK].y2 then
            self.mouse.pressed = nil
        elseif self.mouse.x > self.buttonCoordinates[BUTTON_LOCK].x1 then
            self.locked = false
        else
            html = replaceClass(html, ELEMENT_CLASS_UNLOCKING_LABEL, "")
            html = string.gsub(html, "(id=\"locked\" x=)\"%d+", "%1\"" .. (self.mouse.x * 1920))
        end
    end

    -- adjust visibility for state
    if self.locked then
        html = replaceClass(html, PANEL_CLASS_ADJUSTMENT, HIDDEN_CLASS)
        html = replaceClass(html, ELEMENT_CLASS_UNLOCKED_BUTTON, HIDDEN_CLASS)
    else
        html = replaceClass(html, ELEMENT_CLASS_LOCKED_BUTTON, HIDDEN_CLASS)
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
        elseif mouseOver == BUTTON_MATCH_CURRENT_ALTITUDE then
            html = replaceClass(html, ELEMENT_CLASS_RIGHT_SLIDER, MOUSE_OVER_CLASS)
        elseif mouseOver == BUTTON_LOCK then
            html = replaceClass(html, ELEMENT_CLASS_UNLOCKED_BUTTON, MOUSE_OVER_CLASS)
        elseif mouseOver == BUTTON_UNLOCK then
            html = replaceClass(html, ELEMENT_CLASS_LOCKED_BUTTON, MOUSE_OVER_CLASS)
        end
    end

    _G.agController.slots.screen.setHTML(html)
end

function _G.agScreen:mouseDown(x, y)
    self.mouse.x = x
    self.mouse.y = y
    self.mouse.pressed = self:detectPress(x, y)
    system.print(string.format("Down: %f, %f: %s", x, y, self.mouse.pressed))
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
    system.print(string.format("Up: %f, %f: %s", x, y, released))
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
            if adjusted < 1000 then
                adjusted = 1000
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
        end
    end

    return modified
end