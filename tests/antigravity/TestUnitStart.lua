#!/usr/bin/env lua

--- Tests for antigravity unit.start.
package.path = package.path .. ";../du-utils/?.lua" -- add du-utils project
package.path = package.path .. ";../du-mocks/?.lua" -- add du-mocks project

local lu = require("luaunit")

require("duutils.Utilities")

-- load file into a function for efficient calling
local unitStart = loadfile("antigravity/unit.start.lua")

local mockCoreUnit = require("dumocks.CoreUnit")
local mockScreenUnit = require("dumocks.ScreenUnit")
local mockAntiGravityGeneratorUnit = require("dumocks.AntiGravityGeneratorUnit")
local mockDatabankUnit = require("dumocks.DatabankUnit")
local mockControlUnit = require("dumocks.ControlUnit")

local TARGET_ALTITUDE_KEY = "targetAltitude"

_G.TestAntigravityUnit = {}

function _G.TestAntigravityUnit:setup()

    self.coreMock = mockCoreUnit:new(nil, 1, "dynamic core unit m")
    self.core = self.coreMock:mockGetClosure()

    self.screenMock = mockScreenUnit:new(nil, 2)
    self.screen = self.screenMock:mockGetClosure()

    self.agGeneratorMock = mockAntiGravityGeneratorUnit:new(nil, 3, "anti-gravity generator s")
    self.agGenerator = self.agGeneratorMock:mockGetClosure()

    self.databankMock = mockDatabankUnit:new(nil, 4)
    self.databank = self.databankMock:mockGetClosure()

    self.unitMock = mockControlUnit:new(nil, 5, "programming board")

    -- link all mocks by default
    self.unitMock.linkedElements["agScreen"] = self.screen
    self.unitMock.linkedElements["agg"] = self.agGenerator
    self.unitMock.linkedElements["core"] = self.core
    self.unitMock.linkedElements["databank"] = self.databank
    self.unit = self.unitMock:mockGetClosure()

    self.printOutput = ""
    _G.system = {
        print = function(output)
            self.printOutput = self.printOutput .. output .. "\n"
        end
    }

    -- not testing screen, mock its functions
    _G.agScreenController = {
        needRefresh = false
    }
    function _G.agScreenController:init(_)
    end
end

--- Unset all globals set/used by unit.start.
function _G.TestAntigravityUnit:teardown()
    _G.agController = nil
    _G.UPDATE_FREQUENCY = nil
    _G.agScreen = nil
    _G.agg = nil
    _G.core = nil
    _G.databank = nil
end

--- Verify slot loader maps all elements and reports correctly.
function _G.TestAntigravityUnit:testSlotMappingAuto()

    _G.unit = self.unit

    unitStart()

    -- mappings are correct
    lu.assertIs(_G.agController.slots.screen, self.screen)
    lu.assertIs(_G.agController.slots.antigrav, self.agGenerator)
    lu.assertIs(_G.agController.slots.core, self.core)
    lu.assertIs(_G.agController.slots.databank, self.databank)

    -- helper print text is correct
    lu.assertStrContains(self.printOutput, "Slot agScreen mapped to antigrav screen.")
    lu.assertStrContains(self.printOutput, "Slot agg mapped to antigrav.")
    lu.assertStrContains(self.printOutput, "Slot core mapped to core.")
    lu.assertStrContains(self.printOutput, "Slot databank mapped to databank.")
end

--- Verify slot loader verifies elements and reports correctly.
function _G.TestAntigravityUnit:testSlotMappingManual()

    _G.unit = self.unit

    -- manual mapping to named slots
    _G.agScreen = self.screen
    _G.agg = self.agGenerator
    _G.core = self.core
    _G.databank = self.databank

    unitStart()

    -- mappings are correct
    lu.assertIs(_G.agController.slots.screen, self.screen)
    lu.assertIs(_G.agController.slots.antigrav, self.agGenerator)
    lu.assertIs(_G.agController.slots.core, self.core)
    lu.assertIs(_G.agController.slots.databank, self.databank)

    -- helper print text is correct - no output on valid manual mapping
    lu.assertEquals(self.printOutput, "")
end

--- Verify slot loader provides useful output on failure to find element.
function _G.TestAntigravityUnit:testSlotMappingErrorScreen()

    self.unitMock = mockControlUnit:new(nil, 5, "programming board")
    -- missing screen
    self.unitMock.linkedElements["agg"] = self.agGenerator
    self.unitMock.linkedElements["core"] = self.core
    self.unitMock.linkedElements["databank"] = self.databank
    self.unit = self.unitMock:mockGetClosure()
    _G.unit = self.unit

    lu.assertErrorMsgContains("Screen link not found.", unitStart)
end

--- Verify slot loader provides useful output on failure to find element.
function _G.TestAntigravityUnit:testSlotMappingErrorAgg()

    self.unitMock = mockControlUnit:new(nil, 5, "programming board")
    -- missing ag generator
    self.unitMock.linkedElements["agScreen"] = self.screen
    self.unitMock.linkedElements["core"] = self.core
    self.unitMock.linkedElements["databank"] = self.databank
    self.unit = self.unitMock:mockGetClosure()
    _G.unit = self.unit

    local errorMsgPrefix = "AntiGravity Generator link"
    lu.assertErrorMsgContains(errorMsgPrefix, unitStart)

    -- screen should also have message
    lu.assertStrContains(self.screenMock.html, errorMsgPrefix)
end

--- Verify slot loader provides useful output on failure to find element.
function _G.TestAntigravityUnit:testSlotMappingErrorCore()

    self.unitMock = mockControlUnit:new(nil, 5, "programming board")
    -- missing core
    self.unitMock.linkedElements["agScreen"] = self.screen
    self.unitMock.linkedElements["agg"] = self.agGenerator
    self.unitMock.linkedElements["databank"] = self.databank
    self.unit = self.unitMock:mockGetClosure()
    _G.unit = self.unit

    local errorMsgPrefix = "Core Unit link"
    lu.assertErrorMsgContains(errorMsgPrefix, unitStart)

    -- screen should also have message
    lu.assertStrContains(self.screenMock.html, errorMsgPrefix)
end

--- Verify slot loader provides useful output on failure to find element.
function _G.TestAntigravityUnit:testSlotMappingErrorDatabank()

    self.unitMock = mockControlUnit:new(nil, 5, "programming board")
    -- missing databank
    self.unitMock.linkedElements["agScreen"] = self.screen
    self.unitMock.linkedElements["agg"] = self.agGenerator
    self.unitMock.linkedElements["core"] = self.core
    self.unit = self.unitMock:mockGetClosure()
    _G.unit = self.unit

    -- not an error, databank is optional but recommended
    unitStart()

    -- screen should also have message
    lu.assertStrContains(self.printOutput, "No databank found")
end

--- Verify underlying data is read properly when updating state.
function _G.TestAntigravityUnit:testUpdateState()
    _G.unit = self.unit

    unitStart()

    -- relevant mappings are correct
    lu.assertIs(_G.agController.slots.antigrav, self.agGenerator)
    lu.assertIs(_G.agController.slots.core, self.core)

    -- update all values
    local worldVelocity = {-0.444427, -0.755448, 5.842261}
    local currentAltitude = 1283.1961686802

    local agState = true
    local baseAltitude = 1277.0
    local agField = 1.2000000178814
    local agPower = 0.35299472945713

    self.coreMock.worldVelocity = worldVelocity
    self.coreMock.altitude = currentAltitude

    self.agGeneratorMock.state = agState
    self.agGeneratorMock.baseAltitude = baseAltitude
    self.agGeneratorMock.antiGravityField = agField
    self.agGeneratorMock.antiGravityPower = agPower
    _G.agScreenController.needRefresh = false

    _G.agController:updateState()

    lu.assertEquals(_G.agController.verticalVelocity, worldVelocity[3])
    lu.assertEquals(_G.agController.currentAltitude, currentAltitude)
    lu.assertEquals(_G.agController.agState, agState)
    lu.assertEquals(_G.agController.baseAltitude, baseAltitude)
    lu.assertEquals(_G.agController.agField, agField)
    lu.assertEquals(_G.agController.agPower, agPower)
    lu.assertTrue(_G.agScreenController.needRefresh)
end

--- Verify setBaseAltitude rounds and respects minimum altitude.
function _G.TestAntigravityUnit:testSetBaseAltitude()
    local DEFAULT_MIN_ALTITUDE = 1000

    _G.unit = self.unit

    unitStart()

    -- relevant mappings are correct
    lu.assertIs(_G.agController.slots.antigrav, self.agGenerator)
    lu.assertIs(_G.agController.slots.databank, self.databank)

    -- init to default of 2000 m
    self.agGeneratorMock.targetAltitude = 2000
    self.agGeneratorMock.baseAltitude = self.agGeneratorMock.targetAltitude

    local expected

    -- basic set
    expected = 1500
    _G.agController:setBaseAltitude(expected)
    lu.assertEquals(_G.agController.targetAltitude, expected)
    lu.assertEquals(self.agGeneratorMock.targetAltitude, expected)
    lu.assertEquals(self.databankMock.data[TARGET_ALTITUDE_KEY], expected)

    -- too low
    expected = 1000
    _G.agController:setBaseAltitude(500)
    lu.assertEquals(_G.agController.targetAltitude, expected)
    lu.assertEquals(self.agGeneratorMock.targetAltitude, expected)
    lu.assertEquals(self.databankMock.data[TARGET_ALTITUDE_KEY], expected)

    -- rounded
    expected = 2556
    _G.agController:setBaseAltitude(2555.5)
    lu.assertEquals(_G.agController.targetAltitude, expected)
    lu.assertEquals(self.agGeneratorMock.targetAltitude, expected)
    lu.assertEquals(self.databankMock.data[TARGET_ALTITUDE_KEY], expected)
end

--- Verify set base altitude works when no databank is mapped.
function _G.TestAntigravityUnit:testSetBaseAltitudeNoDatabank()
    -- disable databank
    self.unitMock = mockControlUnit:new(nil, 5, "programming board")
    self.unitMock.linkedElements["agScreen"] = self.screen
    self.unitMock.linkedElements["agg"] = self.agGenerator
    self.unitMock.linkedElements["core"] = self.core
    self.unit = self.unitMock:mockGetClosure()
    _G.unit = self.unit

    unitStart()

    -- relevant mappings are correct
    lu.assertIs(_G.agController.slots.antigrav, self.agGenerator)
    lu.assertNil(_G.agController.slots.databank)

    -- init to default of 2000 m
    self.agGeneratorMock.targetAltitude = 2000
    self.agGeneratorMock.baseAltitude = self.agGeneratorMock.targetAltitude

    local expected

    -- basic set, just making sure no nil error on databank
    expected = 1500
    _G.agController:setBaseAltitude(expected)
    lu.assertEquals(_G.agController.targetAltitude, expected)
    lu.assertEquals(self.agGeneratorMock.targetAltitude, expected)
end

--- Verify databank preference load works with no stored preferences.
function _G.TestAntigravityUnit:testDatabankEmptyPrefLoad()
    _G.unit = self.unit

    -- base and target non-default and different
    local expected = 2500
    self.agGeneratorMock.targetAltitude = 1500
    self.agGeneratorMock.baseAltitude = expected

    unitStart()

    -- relevant mappings are correct
    lu.assertIs(_G.agController.slots.antigrav, self.agGenerator)
    lu.assertIs(_G.agController.slots.databank, self.databank)

    -- defaults to current base altitude
    lu.assertEquals(_G.agController.targetAltitude, expected)
    lu.assertEquals(self.agGeneratorMock.targetAltitude, expected)
    lu.assertEquals(self.databankMock.data[TARGET_ALTITUDE_KEY], expected)
end

--- Verify databank preference load works with stored preferences.
function _G.TestAntigravityUnit:testDatabankPopulatedPrefLoad()
    _G.unit = self.unit

    -- stored, base, and target non-default and different
    local expected = 3000
    self.databankMock.data[TARGET_ALTITUDE_KEY] = expected
    self.agGeneratorMock.targetAltitude = 1500
    self.agGeneratorMock.baseAltitude = 2500

    unitStart()

    -- relevant mappings are correct
    lu.assertIs(_G.agController.slots.antigrav, self.agGenerator)
    lu.assertIs(_G.agController.slots.databank, self.databank)

    -- defaults to current base altitude
    lu.assertEquals(_G.agController.targetAltitude, expected)
    lu.assertEquals(self.agGeneratorMock.targetAltitude, expected)
    lu.assertEquals(self.databankMock.data[TARGET_ALTITUDE_KEY], expected)
end

--- Verify non-databank preference default works.
function _G.TestAntigravityUnit:testDefaultPrefLoad()
    -- disable databank
    self.unitMock = mockControlUnit:new(nil, 5, "programming board")
    self.unitMock.linkedElements["agScreen"] = self.screen
    self.unitMock.linkedElements["agg"] = self.agGenerator
    self.unitMock.linkedElements["core"] = self.core
    self.unit = self.unitMock:mockGetClosure()
    _G.unit = self.unit

    -- base and target non-default and different
    local expected = 2500
    self.agGeneratorMock.targetAltitude = 1500
    self.agGeneratorMock.baseAltitude = expected

    unitStart()

    -- relevant mappings are correct
    lu.assertIs(_G.agController.slots.antigrav, self.agGenerator)
    lu.assertNil(_G.agController.slots.databank)

    -- defaults to current base altitude
    lu.assertEquals(_G.agController.targetAltitude, expected)
    lu.assertEquals(self.agGeneratorMock.targetAltitude, expected)
end

--- Verify setting state turns the agg on and off.
function _G.TestAntigravityUnit:testSetAgState()
    _G.unit = self.unit

    unitStart()

    -- relevant mappings are correct
    lu.assertIs(_G.agController.slots.antigrav, self.agGenerator)

    -- start on
    self.agGeneratorMock.state = true

    -- no-op
    _G.agController:setAgState(true)
    lu.assertTrue(self.agGeneratorMock.state)

    -- turn off
    _G.agController:setAgState(false)
    lu.assertFalse(self.agGeneratorMock.state)

    -- no-op
    _G.agController:setAgState(false)
    lu.assertFalse(self.agGeneratorMock.state)

    -- turn on
    _G.agController:setAgState(true)
    lu.assertTrue(self.agGeneratorMock.state)
end

os.exit(lu.LuaUnit.run())
