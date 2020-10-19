
local SVG_TEMPLATE = [[${file:screen.svg}]]
local SVG_LOGO = [[${file:../logo.svg minify}]]

-- embed logo on load
SVG_TEMPLATE = string.gsub(SVG_TEMPLATE, '<svg id="logo"/>', SVG_LOGO)

-- constants and editable lua script parameters
local MAX_SLIDER_ALTITUDE = 100000 --export: Max altitude value on the slider (m)
local MIN_ADJUSTMENT_VALUE = 1
local MAX_ADJUSTMENT_VALUE = 10000 --export: Max step size for altitude adjustment (m)


-- initialize object and fields
_G.agScreen = {
    altitudeAdjustment = 1000,
    mouse = {x = -1, y = -1, pressed = nil},
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
function _G.agScreen:refresh()
    -- refresh conditions: needRefresh, mouse down
    if not (self.controller.needRefresh or self.mouse.pressed) then
        return
    end
    self.controller.needRefresh = false

    -- update mouse position for tracking drags
    self.mouse.x = self.screen.getMouseX()
    self.mouse.y = self.screen.getMouseY()
    -- if mouse has left screen remove pressed flag
    if self.screen.getMouseX() < 0 then
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

    -- insert values to svg and render
    local html = SVG_TEMPLATE
    html = _G.Utilities.sanitizeFormatString(html)
    html = string.format(html,
        targetAltitude, baseAltitude, altitudeAdjustment, altitudeAdjustment,
        verticalVelocity, verticalUnits, currentAltitude, agField, agPower)

    if not self.mouse.pressed then
        local mouseOver, index = self:detectPress(self.mouse.x, self.mouse.y)
        if mouseOver == BUTTON_ALTITUDE_ADJUST_UP then
            html = string.gsub(html, "adjustUpClass" .. index, "mouseOver")
        elseif mouseOver == BUTTON_ALTITUDE_ADJUST_DOWN then
            html = string.gsub(html, "adjustDownClass" .. index, "mouseOver")
        elseif mouseOver == BUTTON_ALTITUDE_UP then
            html = string.gsub(html, "altitudeUpClass", "mouseOver")
        elseif mouseOver == BUTTON_ALTITUDE_DOWN then
            html = string.gsub(html, "altitudeDownClass", "mouseOver")
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
    end

    return modified
end