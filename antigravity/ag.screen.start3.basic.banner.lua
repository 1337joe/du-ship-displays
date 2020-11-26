--- Run third, define agScreenController basic SVG-specific functionality: SVG image, button coordinates, slider scaling

-- constants for svg file
local SCREEN_HEIGHT = 1080
local MAX_SLIDER_ALTITUDE = 200000
local MIN_SLIDER_ALTITUDE = 1000
local ALT_SLIDER_TOP = 162
local ALT_SLIDER_BOTTOM = 1026

-- add SVG-specific fields
_G.agScreenController.SVG_TEMPLATE = [[${file:ag.screen.basic.svg minify}]]
_G.agScreenController.SVG_LOGO = [[${file:../logo.svg minify}]]

-- one-time transforms
_G.agScreenController.SVG_TEMPLATE = string.gsub(_G.agScreenController.SVG_TEMPLATE, '<svg id="logo"/>', _G.agScreenController.SVG_LOGO)

-- Define button ranges, either in tables of x1,y1,x2,y2 or lists of those tables.
local buttonCoordinates = {}
buttonCoordinates[_G.agScreenController.BUTTON_ALTITUDE_UP] = {
    x1 = 0.05, x2 = 0.35,
    y1 = 0.2, y2 = 0.45
}
buttonCoordinates[_G.agScreenController.BUTTON_ALTITUDE_DOWN] = {
    x1 = 0.05, x2 = 0.35,
    y1 = 0.65, y2 = 0.9
}
buttonCoordinates[_G.agScreenController.BUTTON_ALTITUDE_ADJUST_DOWN] = {
    x1 = 0.35, x2 = 0.4,
    y1 = 0.5, y2 = 0.6
}
buttonCoordinates[_G.agScreenController.BUTTON_ALTITUDE_ADJUST_UP] = {
    x1 = 0.0, x2 = 0.05,
    y1 = 0.5, y2 = 0.6
}
buttonCoordinates[_G.agScreenController.BUTTON_TARGET_ALTITUDE_SLIDER] = {
    x1 = 0.4, x2 = 0.5,
    y1 = 0.1, y2 = 1.0
}
buttonCoordinates[_G.agScreenController.BUTTON_MATCH_CURRENT_ALTITUDE] = {
    x1 = 0.5, x2 = 0.6,
    y1 = 0.1, y2 = 1.0
}
buttonCoordinates[_G.agScreenController.BUTTON_LOCK] = {
    x1 = 0.3, x2 = 0.4,
    y1 = 0.1, y2 = 0.2
}
buttonCoordinates[_G.agScreenController.BUTTON_UNLOCK] = {
    x1 = 0.0, x2 = 0.1,
    y1 = 0.1, y2 = 0.2
}
buttonCoordinates[_G.agScreenController.BUTTON_POWER_OFF] = {
    x1 = 0.9, x2 = 1.0,
    y1 = 0.1, y2 = 0.2
}
buttonCoordinates[_G.agScreenController.BUTTON_POWER_ON] = {
    x1 = 0.6, x2 = 0.7,
    y1 = 0.1, y2 = 0.2
}
-- save to controller for press/release event handling
_G.agScreenController.buttonCoordinates = buttonCoordinates

-- both sliders on same level, pre-compute y ranges with 5% buffer
_G.agScreenController.sliderYMin = buttonCoordinates[_G.agScreenController.BUTTON_UNLOCK].y1 - SCREEN_HEIGHT * 0.05
_G.agScreenController.sliderYMax = buttonCoordinates[_G.agScreenController.BUTTON_UNLOCK].y2 + SCREEN_HEIGHT * 0.05

-- pre-computed values for less computation in render thread
local logMin = math.log(MIN_SLIDER_ALTITUDE)
local logMax = math.log(MAX_SLIDER_ALTITUDE)
local scaleHeight = ALT_SLIDER_BOTTOM - ALT_SLIDER_TOP
local scaleHeightOverLogDifference = scaleHeight / (logMax - logMin)

-- yPixel = sliderBottom - (sliderHeight * (log(altitude) - log(minAltitude)) / (log(maxAltitude) - log(minAltitude)))
function _G.agScreenController.calculateSliderIndicator(altitude)
    return math.floor(ALT_SLIDER_BOTTOM - scaleHeightOverLogDifference * (math.log(altitude) - logMin) + 0.5)
end

-- altitude = e^((sliderBottom - yPixel) / sliderHeight * (log(maxAltitude) - log(minAltitude)) + log(minAltitude)
function _G.agScreenController.calculateSliderAltitude(indicatorY)
    local indicatorYpixels = indicatorY * SCREEN_HEIGHT
    local target = math.floor(math.exp((ALT_SLIDER_BOTTOM - indicatorYpixels) / scaleHeightOverLogDifference + logMin) + 0.5)
    if target > MAX_SLIDER_ALTITUDE then
        target = MAX_SLIDER_ALTITUDE
    end
    return target
end
