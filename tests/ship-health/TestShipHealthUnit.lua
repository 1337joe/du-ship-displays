#!/usr/bin/env lua

--- Tests for ship health unit.start.
package.path = package.path .. ";./resources/du-utils/?.lua" -- add du-utils project
package.path = package.path .. ";../du-mocks/?.lua" -- add du-mocks project

local lu = require("luaunit")

require("duutils.Utilities")

-- load file into a function for efficient calling
local unitStart = loadfile("./ship-health/hp.unit.start.lua")

local mockCoreUnit = require("dumocks.CoreUnit")
local mockScreenUnit = require("dumocks.ScreenUnit")
local mockDatabankUnit = require("dumocks.DatabankUnit")
local mockControlUnit = require("dumocks.ControlUnit")

local TARGET_ALTITUDE_KEY = "targetAltitude"

_G.TestShipHealthUnit = {}

function _G.TestShipHealthUnit:setup()

    self.coreMock = mockCoreUnit:new(nil, 1, "dynamic core unit m")
    self.core = self.coreMock:mockGetClosure()

    self.screenMock = mockScreenUnit:new(nil, 2)
    self.screen = self.screenMock:mockGetClosure()

    self.databankMock = mockDatabankUnit:new(nil, 4)
    self.databank = self.databankMock:mockGetClosure()

    self.unitMock = mockControlUnit:new(nil, 5, "programming board")

    -- link all mocks by default
    self.unitMock.linkedElements["hpScreen"] = self.screen
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
    _G.hpScreenController = {
        needRefresh = false
    }
    function _G.hpScreenController:init(_)
    end
end

--- Unset all globals set/used by unit.start.
function _G.TestShipHealthUnit:teardown()
    _G.hpController = nil
    _G.UPDATE_FREQUENCY = nil
    _G.hpScreen = nil
    _G.core = nil
    _G.databank = nil
end

--- Verify slot loader maps all elements and reports correctly.
function _G.TestShipHealthUnit:testSlotMappingAuto()

    _G.unit = self.unit

    unitStart()

    -- mappings are correct
    lu.assertIs(_G.hpController.slots.screen, self.screen)
    lu.assertIs(_G.hpController.slots.core, self.core)
    lu.assertIs(_G.hpController.slots.databank, self.databank)

    -- helper print text is correct
    lu.assertStrContains(self.printOutput, "Slot hpScreen mapped to ship health screen.")
    lu.assertStrContains(self.printOutput, "Slot core mapped to core.")
    lu.assertStrContains(self.printOutput, "Slot databank mapped to databank.")
end

--- Verify slot loader verifies elements and reports correctly.
function _G.TestShipHealthUnit:testSlotMappingManual()

    _G.unit = self.unit

    -- manual mapping to named slots
    _G.hpScreen = self.screen
    _G.core = self.core
    _G.databank = self.databank

    unitStart()

    -- mappings are correct
    lu.assertIs(_G.hpController.slots.screen, self.screen)
    lu.assertIs(_G.hpController.slots.core, self.core)
    lu.assertIs(_G.hpController.slots.databank, self.databank)

    -- helper print text is correct - no output on valid manual mapping
    lu.assertEquals(self.printOutput, "")
end

--- Verify slot loader provides useful output on failure to find element.
function _G.TestShipHealthUnit:testSlotMappingErrorScreen()

    self.unitMock = mockControlUnit:new(nil, 5, "programming board")
    -- missing screen
    self.unitMock.linkedElements["core"] = self.core
    self.unitMock.linkedElements["databank"] = self.databank
    self.unit = self.unitMock:mockGetClosure()
    _G.unit = self.unit

    lu.assertErrorMsgContains("Screen link not found.", unitStart)
end

--- Verify slot loader provides useful output on failure to find element.
function _G.TestShipHealthUnit:testSlotMappingErrorCore()

    self.unitMock = mockControlUnit:new(nil, 5, "programming board")
    -- missing core
    self.unitMock.linkedElements["hpScreen"] = self.screen
    self.unitMock.linkedElements["databank"] = self.databank
    self.unit = self.unitMock:mockGetClosure()
    _G.unit = self.unit

    local errorMsgPrefix = "Core Unit link"
    lu.assertErrorMsgContains(errorMsgPrefix, unitStart)

    -- screen should also have message
    lu.assertStrContains(self.screenMock.html, errorMsgPrefix)
end

--- Verify slot loader provides useful output on failure to find element.
function _G.TestShipHealthUnit:testSlotMappingErrorDatabank()

    self.unitMock = mockControlUnit:new(nil, 5, "programming board")
    -- missing databank
    self.unitMock.linkedElements["hpScreen"] = self.screen
    self.unitMock.linkedElements["core"] = self.core
    self.unit = self.unitMock:mockGetClosure()
    _G.unit = self.unit

    -- not an error, databank is optional but recommended
    unitStart()

    -- screen should also have message
    lu.assertStrContains(self.printOutput, "No databank found")
end

--- Verify underlying data is read properly when updating state.
function _G.TestShipHealthUnit:testUpdateState()
    _G.unit = self.unit

    unitStart()

    -- relevant mappings are correct
    lu.assertIs(_G.hpController.slots.core, self.core)
    lu.assertIs(_G.hpController.slots.databank, self.databank)

    -- update all values
--    local targetAltitude = 1750.5

--    self.databankMock.data[TARGET_ALTITUDE_KEY] = targetAltitude

--    self.coreMock.worldVelocity = worldVelocity

    _G.hpScreenController.needRefresh = false

    _G.hpController:updateState()

    lu.fail("NYI")
end

os.exit(lu.LuaUnit.run())
