#!/usr/bin/env lua

--- Tests for antigravity screen.start.
package.path = package.path .. ";./resources/du-utils/?.lua" -- add du-utils project
package.path = package.path .. ";../du-mocks/?.lua" -- add du-mocks project

local lu = require("luaunit")

require("duutils.Utilities")

local SVG_OUTPUT_FILE = "tests/results/images/antigravity-basic.svg"

-- load file into a function for efficient calling
local screenStart = loadfile("antigravity/screen.start.lua")
-- load base SVG
local inputHandle = io.open("antigravity/screen.svg", "rb")
local BASE_SVG = io.input(inputHandle):read("*all")
inputHandle:close()


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
    screenStart()

    local expected = 1234
    self.databankMock.data[ALTITUDE_ADJUST_KEY] = expected

    _G.agScreenController:init(self.agController)

    lu.assertIs(_G.agScreenController.screen, self.screen)
    lu.assertIs(_G.agScreenController.databank, self.databank)

    lu.assertEquals(_G.agScreenController.altitudeAdjustment, expected)
end

--- Verify init stores references and defaults settings due to unpopulated databank.
function _G.TestAntigravityScreen:testInitEmptyDatabank()
    screenStart()

    local expected = 1000

    _G.agScreenController:init(self.agController)

    lu.assertIs(_G.agScreenController.screen, self.screen)
    lu.assertIs(_G.agScreenController.databank, self.databank)

    lu.assertEquals(_G.agScreenController.altitudeAdjustment, expected)
end

--- Verify init stores references and defaults settings due to missing databank.
function _G.TestAntigravityScreen:testInitNoDatabank()
    self.agController.slots.databank = nil

    screenStart()

    local expected = 1000

    _G.agScreenController:init(self.agController)

    lu.assertIs(_G.agScreenController.screen, self.screen)
    lu.assertNil(_G.agScreenController.databank)

    lu.assertEquals(_G.agScreenController.altitudeAdjustment, expected)
end

--- Verify replace class only replaces where appropriate.
function _G.TestAntigravityScreen.testReplaceClass()
    screenStart()

    local html, oldClass, newClass, expected, actual

    -- doesn't replace in css definitions
    html = [[ .hidden, .unlockSlideClass, .disabledText, .powerSlideClass, .pulsorsText { display: none; }]]
    expected = html
    oldClass = "unlockSlideClass"
    newClass = ""
    actual = _G.agScreenController.replaceClass(html, oldClass, newClass)
    lu.assertEquals(actual, expected)

    -- replaces if first in attribute
    html = [[class="unlockSlideClass"]]
    expected = [[class=""]]
    oldClass = "unlockSlideClass"
    newClass = ""
    actual = _G.agScreenController.replaceClass(html, oldClass, newClass)
    lu.assertEquals(actual, expected)

    -- replaces if not first in attribute
    html = [[class="label unlockSlideClass"]]
    expected = [[class="label "]]
    oldClass = "unlockSlideClass"
    newClass = ""
    actual = _G.agScreenController.replaceClass(html, oldClass, newClass)
    lu.assertEquals(actual, expected)
end

--- Verify altitude adjust works without a databank.
function _G.TestAntigravityScreen:testSetAltitudeAdjust()
    self.agController.slots.databank = nil

    screenStart()

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
    screenStart()

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

--- Verify refresh generates an SVG and save it as a sample image.
function _G.TestAntigravityScreen:testDisplay()
    screenStart()
    _G.agScreenController.SVG_TEMPLATE = BASE_SVG

    _G.agScreenController:init(self.agController)

    lu.assertIs(_G.agScreenController.screen, self.screen)

    -- set state in controller
    self.agController.verticalVelocity = 5.842261
    self.agController.currentAltitude = 1283.1961686802
    self.agController.targetAltitude = 1250
    self.agController.agState = true
    self.agController.baseAltitude = 1277.0
    self.agController.agField = 1.2000000178814
    self.agController.agPower = 0.35299472945713

    _G.agScreenController.needRefresh = true
    _G.agScreenController:refresh()

    local actual = self.screenMock.html
    lu.assertFalse(actual:len() == 0)

    -- save as file
    local outputHandle, errorMsg = io.open(SVG_OUTPUT_FILE, "w")
    if errorMsg then
        error(errorMsg)
    else
        io.output(outputHandle):write(actual)
        outputHandle:close()
    end
end

os.exit(lu.LuaUnit.run())
