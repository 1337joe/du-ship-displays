#!/usr/bin/env lua

--- Tests for antigravity unit.start.
package.path = package.path .. ";../du-mocks/?.lua" -- add du-mocks project
package.path = "../game-data-lua/?.lua;" .. package.path -- add link to Dual Universe/Game/data/lua/ directory

local lu = require("luaunit")

require("common.Utilities")
require("common.atlas")
require("common.planetref")

-- load file into a function for efficient calling
local unitStart = loadfile("./antigravity/ag.unit.start.lua")

local mockCoreUnit = require("dumocks.CoreUnit")
local mockScreenUnit = require("dumocks.ScreenUnit")
local mockAntiGravityGeneratorUnit = require("dumocks.AntiGravityGeneratorUnit")
local mockDatabankUnit = require("dumocks.DatabankUnit")
local mockControlUnit = require("dumocks.ControlUnit")

local TARGET_ALTITUDE_KEY = "AntigravTargetAltitude"

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
    lu.assertStrContains(self.printOutput, "Slot agg mapped to antigrav antigrav.")
    lu.assertStrContains(self.printOutput, "Slot core mapped to antigrav core.")
    lu.assertStrContains(self.printOutput, "Slot databank mapped to antigrav databank.")
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

--- Verify underlying antigravity data is read properly when updating state.
function _G.TestAntigravityUnit:testUpdateStateAntiGravity()
    _G.unit = self.unit

    unitStart()

    -- relevant mappings are correct
    lu.assertIs(_G.agController.slots.antigrav, self.agGenerator)
    lu.assertIs(_G.agController.slots.databank, self.databank)

    -- update all values
    local targetAltitude = 1750.5

    local agState = true
    local baseAltitude = 1277.0
    local agField = 1.2000000178814
    local agPower = 0.35299472945713

    self.databankMock.data[TARGET_ALTITUDE_KEY] = targetAltitude

    self.agGeneratorMock.state = agState
    self.agGeneratorMock.baseAltitude = baseAltitude
    self.agGeneratorMock.antiGravityField = agField
    self.agGeneratorMock.antiGravityPower = agPower
    _G.agScreenController.needRefresh = false

    _G.agController:updateState()

    lu.assertEquals(_G.agController.targetAltitude, targetAltitude)
    lu.assertEquals(_G.agController.agState, agState)
    lu.assertEquals(_G.agController.baseAltitude, baseAltitude)
    lu.assertEquals(_G.agController.agField, agField)
    lu.assertEquals(_G.agController.agPower, agPower)
    lu.assertTrue(_G.agScreenController.needRefresh)
end

--- Verify altitude calculations under various flight conditions.
function _G.TestAntigravityUnit:testUpdateStateFlight()
    _G.unit = self.unit

    unitStart()

    -- relevant mappings are correct
    lu.assertIs(_G.agController.slots.core, self.core)

    -- gValue is commented out because agg distorts it, but left in to show expected calculated result
    
    -- underwater, parked
    -- self.coreMock.gValue = 9.807479
    self.coreMock.worldVelocity = {-0.012110, 0.010807, 0.000693}
    self.coreMock.altitude = -20.920222
    self.coreMock.worldVertical = {0.409438, 0.911008, -0.049251}
    self.coreMock.constructWorldPos = {-1438971.755137, 486695.731718, -280968.612056}

    _G.agController:updateState()

    lu.assertAlmostEquals(_G.agController.verticalVelocity, 0, 0.1)
    lu.assertAlmostEquals(_G.agController.currentAltitude, -20.92, 1)

    -- underwater, moving straight up
    -- self.coreMock.gValue = 9.807643
    self.coreMock.worldVelocity = {-5.454992, -12.116544, 0.656135}
    self.coreMock.altitude = -19.516626
    self.coreMock.worldVertical = {0.409433, 0.911010, -0.049249}
    self.coreMock.constructWorldPos = {-1438971.896043, 486694.249222, -280968.706895}

    _G.agController:updateState()

    lu.assertTrue(_G.agController.verticalVelocity > 0)
    lu.assertAlmostEquals(_G.agController.currentAltitude, -19.52, 1)

    -- atmo, moving up
    -- self.coreMock.gValue = 9.397845
    self.coreMock.worldVelocity = {109.752930, -147.477219, 37.130440}
    self.coreMock.altitude = 1808.802935
    self.coreMock.worldVertical = {0.371743, 0.926504, -0.058285}
    self.coreMock.constructWorldPos = {-1436511.977069, 483709.645575, -280109.044122}

    _G.agController:updateState()

    lu.assertTrue(_G.agController.verticalVelocity > 0)
    lu.assertAlmostEquals(_G.agController.currentAltitude, 1808.80, 1)

    -- atmo, moving down
    -- self.coreMock.gValue = 9.438065
    self.coreMock.worldVelocity = {197.800613, 71.364143, 2.466721}
    self.coreMock.altitude = 1628.717478
    self.coreMock.worldVertical = {0.344287, 0.936704, -0.063651}
    self.coreMock.constructWorldPos = {-1434110.053024, 483008.986417, -279663.074442}

    _G.agController:updateState()

    lu.assertTrue(_G.agController.verticalVelocity < 0)
    lu.assertAlmostEquals(_G.agController.currentAltitude, 1628.71, 1)

    -- near space (within planet influence), moving up
    -- self.coreMock.gValue = 8.540230
    self.coreMock.worldVelocity = {143.945374, 13.137656, 159.881790}
    self.coreMock.altitude = 5985.715003
    self.coreMock.worldVertical = {0.012509, 0.962592, -0.270667}
    self.coreMock.constructWorldPos = {-1405952.891129, 476613.360567, -260881.213486}

    _G.agController:updateState()

    lu.assertTrue(_G.agController.verticalVelocity > 0)
    lu.assertAlmostEquals(_G.agController.currentAltitude, 5985.72, 1)

    -- middle space (hud stops showing altitude but core still gives it), moving up
    -- self.coreMock.gValue = 2.896656
    self.coreMock.worldVelocity = {664.247437, 1240.123413, 461.507721}
    self.coreMock.altitude = 70094.493816
    self.coreMock.worldVertical = {-0.648452, -0.278465, -0.708497}
    self.coreMock.constructWorldPos = {-1305284.859003, 605398.637673, -176339.349603}

    _G.agController:updateState()

    lu.assertTrue(_G.agController.verticalVelocity > 0)
    lu.assertAlmostEquals(_G.agController.currentAltitude, 70094.49, 1)

    -- far space (g < 0.1), moving down
    -- self.coreMock.gValue = 0.010681
    self.coreMock.worldVelocity = {-87.481560, -39.660667, 33.877953}
    self.coreMock.altitude = 0.000000
    self.coreMock.worldVertical = {0.862569, 0.351494, -0.363905}
    self.coreMock.constructWorldPos = {2260235.337751, -99279961.240220, -700690.506668}

    _G.agController:updateState()

    -- nan check, not equal to self
    lu.assertTrue(_G.agController.verticalVelocity ~= _G.agController.verticalVelocity)
    lu.assertTrue(_G.agController.currentAltitude ~= _G.agController.currentAltitude)
    
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

    -- handles floats
    expected = 2555.5
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
    local expected = 3000.5
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
