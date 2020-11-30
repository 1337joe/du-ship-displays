#!/usr/bin/env lua
--- Tests for antigravity screen.start1 - functionality tests, not display

package.path = package.path .. ";../du-mocks/?.lua" -- add du-mocks project

local lu = require("luaunit")

require("common.Utilities")
require("common.ScreenUtils")

local SVG_OUTPUT_FILE = "tests/results/images/antigravity-basic.svg"

-- load file into a function for efficient calling
local screenStart1 = loadfile("./antigravity/ag.screen.start1.lua")

local mockScreenUnit = require("dumocks.ScreenUnit")
local mockDatabankUnit = require("dumocks.DatabankUnit")

local ALTITUDE_ADJUST_KEY = "altitudeAdjustment"

_G.TestAntigravityScreen = {}

function _G.TestAntigravityScreen:setup()

    self.screenMock = mockScreenUnit:new(nil, 2)
    self.screen = self.screenMock:mockGetClosure()

    self.databankMock = mockDatabankUnit:new(nil, 4)
    self.databank = self.databankMock:mockGetClosure()

    self.printOutput = ""
    _G.system = {
        print = function(output)
            self.printOutput = self.printOutput .. output .. "\n"
        end
    }

    -- not testing controller, mock its functions
    self.agController = {
        slots = {
            screen = self.screen,
            databank = self.databank
        }
    }
    function self.agController:setAgState(newState)
    end
end

--- Unset all globals set/used by screen.start.
function _G.TestAntigravityScreen:teardown()
    _G.agScreenController = nil
end

--- Verify init stores references and loads settings from populated databank.
function _G.TestAntigravityScreen:testInit()
    screenStart1()

    local expected = 1234
    self.databankMock.data[ALTITUDE_ADJUST_KEY] = expected

    _G.agScreenController:init(self.agController)

    lu.assertIs(_G.agScreenController.screen, self.screen)
    lu.assertIs(_G.agScreenController.databank, self.databank)

    lu.assertEquals(_G.agScreenController.altitudeAdjustment, expected)
end

--- Verify init stores references and defaults settings due to unpopulated databank.
function _G.TestAntigravityScreen:testInitEmptyDatabank()
    screenStart1()

    local expected = 1000

    _G.agScreenController:init(self.agController)

    lu.assertIs(_G.agScreenController.screen, self.screen)
    lu.assertIs(_G.agScreenController.databank, self.databank)

    lu.assertEquals(_G.agScreenController.altitudeAdjustment, expected)
end

--- Verify init stores references and defaults settings due to missing databank.
function _G.TestAntigravityScreen:testInitNoDatabank()
    self.agController.slots.databank = nil

    screenStart1()

    local expected = 1000

    _G.agScreenController:init(self.agController)

    lu.assertIs(_G.agScreenController.screen, self.screen)
    lu.assertNil(_G.agScreenController.databank)

    lu.assertEquals(_G.agScreenController.altitudeAdjustment, expected)
end

--- Verify altitude adjust works without a databank.
function _G.TestAntigravityScreen:testSetAltitudeAdjust()
    self.agController.slots.databank = nil

    screenStart1()

    _G.agScreenController:init(self.agController)

    lu.assertIs(_G.agScreenController.screen, self.screen)
    lu.assertNil(_G.agScreenController.databank)

    local expected, modified

    expected = 100
    modified = _G.agScreenController:setAltitudeAdjust(expected)
    lu.assertTrue(modified)
    lu.assertEquals(_G.agScreenController.altitudeAdjustment, expected)

    -- below minimum
    expected = 0
    modified = _G.agScreenController:setAltitudeAdjust(expected)
    lu.assertTrue(modified)
    lu.assertNotEquals(_G.agScreenController.altitudeAdjustment, expected)
end

--- Verify altitude adjust works with a databank.
function _G.TestAntigravityScreen:testSetAltitudeAdjust()
    screenStart1()

    _G.agScreenController:init(self.agController)

    lu.assertIs(_G.agScreenController.screen, self.screen)
    lu.assertIs(_G.agScreenController.databank, self.databank)

    local expected, modified

    expected = 100
    modified = _G.agScreenController:setAltitudeAdjust(expected)
    lu.assertTrue(modified)
    lu.assertEquals(_G.agScreenController.altitudeAdjustment, expected)
    lu.assertEquals(self.databankMock.data[ALTITUDE_ADJUST_KEY], expected)

    -- same value
    expected = 100
    modified = _G.agScreenController:setAltitudeAdjust(expected)
    lu.assertFalse(modified)
    lu.assertEquals(_G.agScreenController.altitudeAdjustment, expected)
    lu.assertEquals(self.databankMock.data[ALTITUDE_ADJUST_KEY], expected)

    -- below minimum
    expected = 0
    modified = _G.agScreenController:setAltitudeAdjust(expected)
    lu.assertTrue(modified)
    lu.assertNotEquals(_G.agScreenController.altitudeAdjustment, expected)

    -- above maximum
    expected = 1000000
    modified = _G.agScreenController:setAltitudeAdjust(expected)
    lu.assertTrue(modified)
    lu.assertNotEquals(_G.agScreenController.altitudeAdjustment, expected)
end

--- Verify mouseDown updates state properly.
function _G.TestAntigravityScreen:testMouseDown()
    screenStart1()

    _G.agScreenController:init(self.agController)

    lu.assertIs(_G.agScreenController.screen, self.screen)

    -- init button definition to single button covering bottom right corner of screen
    local BUTTON_1 = "Button 1"
    local buttonCoordinates = {}
    buttonCoordinates[BUTTON_1] = {x1 = 0.5, x2 = 1.0, y1 = 0.5, y2 = 1.0}
    _G.agScreenController.buttonCoordinates = buttonCoordinates

    local expectedX, expectedY, expectedButton

    -- miss button
    expectedX = 0.25
    expectedY = 0.25
    expectedButton = nil
    _G.agScreenController:mouseDown(expectedX, expectedY)
    lu.assertEquals(_G.agScreenController.mouse.x, expectedX)
    lu.assertEquals(_G.agScreenController.mouse.y, expectedY)
    lu.assertEquals(_G.agScreenController.mouse.pressed, expectedButton)

    -- hit button
    expectedX = 0.75
    expectedY = 0.75
    expectedButton = BUTTON_1
    _G.agScreenController:mouseDown(expectedX, expectedY)
    lu.assertEquals(_G.agScreenController.mouse.x, expectedX)
    lu.assertEquals(_G.agScreenController.mouse.y, expectedY)
    lu.assertEquals(_G.agScreenController.mouse.pressed, expectedButton)
end


--- Verify mouseUp updates state and calls handler properly.
function _G.TestAntigravityScreen:testMouseUp()
    screenStart1()

    _G.agScreenController:init(self.agController)

    lu.assertIs(_G.agScreenController.screen, self.screen)

    -- init button definition to single button covering bottom right corner of screen
    local BUTTON_1 = "Button 1"
    local buttonCoordinates = {}
    buttonCoordinates[BUTTON_1] = {x1 = 0.5, x2 = 1.0, y1 = 0.5, y2 = 1.0}
    _G.agScreenController.buttonCoordinates = buttonCoordinates

    -- implement simple handler to verify call
    local actualButton = nil
    _G.agScreenController.handleButton = function(self, button)
        actualButton = button
    end

    -- release off button, button was not pressed
    actualButton = nil
    _G.agScreenController.mouse.pressed = nil
    _G.agScreenController:mouseUp(0.25, 0.25)
    lu.assertNil(_G.agScreenController.mouse.pressed)
    lu.assertNil(actualButton)

    -- release off button, button was pressed
    actualButton = nil
    _G.agScreenController.mouse.pressed = BUTTON_1
    _G.agScreenController:mouseUp(0.25, 0.25)
    lu.assertNil(_G.agScreenController.mouse.pressed)
    lu.assertNil(actualButton)
    
    -- release on button, button was not pressed
    actualButton = nil
    _G.agScreenController.mouse.pressed = nil
    _G.agScreenController:mouseUp(0.75, 0.75)
    lu.assertNil(_G.agScreenController.mouse.pressed)
    lu.assertNil(actualButton)

    -- release on button, button was pressed - calls handler
    actualButton = nil
    _G.agScreenController.mouse.pressed = BUTTON_1
    _G.agScreenController:mouseUp(0.75, 0.75)
    lu.assertNil(_G.agScreenController.mouse.pressed)
    lu.assertEquals(actualButton, BUTTON_1)
end

os.exit(lu.LuaUnit.run())
