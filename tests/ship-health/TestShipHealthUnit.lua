#!/usr/bin/env lua
--- Tests for ship health unit.start.

package.path = package.path .. ";../du-mocks/?.lua" -- add du-mocks project

local lu = require("luaunit")

require("common.Utilities")

-- load file into a function for efficient calling
local unitStart = loadfile("./ship-health/hp.unit.start.lua")

local mockCoreUnit = require("dumocks.CoreUnit")
local mockScreenUnit = require("dumocks.ScreenUnit")
local mockDatabankUnit = require("dumocks.DatabankUnit")
local mockControlUnit = require("dumocks.ControlUnit")

local pocketScoutElements = require("tests.ship-health.PocketScout")

local SELECTED_ELEMENT_KEY = "HP.unit:SELECTED_ELEMENT"

_G.TestShipHealthUnit = {}

function _G.TestShipHealthUnit:setup()

    self.coreMock = mockCoreUnit:new(nil, 1, "dynamic core unit xs")

    self.coreMock.elements = pocketScoutElements
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
    lu.assertStrContains(self.printOutput, "Slot hpScreen mapped to ship-health screen.")
    lu.assertStrContains(self.printOutput, "Slot core mapped to ship-health core.")
    lu.assertStrContains(self.printOutput, "Slot databank mapped to ship-health databank.")
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

--- Verify initialization works with scout dataset.
function _G.TestShipHealthUnit:testInitialize()
    _G.unit = self.unit

    -- init to non-default: select screen
    self.databankMock.data[SELECTED_ELEMENT_KEY] = 90

    unitStart()

    -- relevant mappings are correct
    lu.assertIs(_G.hpController.slots.core, self.core)

    while self.unitMock.timers["initHp"] ~= nil do
        _G.hpController:finishInitialize()
    end

    lu.assertEquals(_G.hpController.arrowOffsetDistance , 1) -- XS core
    lu.assertStrContains(self.screenMock.html, "Initializing<br>50 of 50 loaded")

    -- verify min/max values from init coroutine
    lu.assertEquals(_G.hpController.elementMetadata.min.x, -6)
    lu.assertEquals(_G.hpController.elementMetadata.max.x, 6.25)
    lu.assertEquals(_G.hpController.elementMetadata.min.y, -5.625)
    lu.assertAlmostEquals(_G.hpController.elementMetadata.max.y, 6.348576, 0.000001)
    lu.assertAlmostEquals(_G.hpController.elementMetadata.min.z, -2.591827, 0.000001)
    lu.assertAlmostEquals(_G.hpController.elementMetadata.max.z, 1.384995, 0.000001)
    lu.assertEquals(_G.hpController.elementMetadata.min.hp, 50)
    lu.assertEquals(_G.hpController.elementMetadata.max.hp, 1933)
    lu.assertEquals(_G.hpController.elementMetadata.totalHp, 10650)
    lu.assertEquals(_G.hpController.elementMetadata.totalMaxHp, 10670)

    -- verify select called
    lu.assertEquals(_G.hpController.selectedElement, 90)

    -- verify result of final init function
    lu.assertNotNil(self.unitMock.timers["updateHp"])
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

    -- _G.hpController:updateState()

    -- lu.fail("NYI")
end

--- Verify select.
function _G.TestShipHealthUnit:testSelect()

    _G.unit = self.unit

    unitStart()

    -- relevant mappings are correct
    lu.assertIs(_G.hpController.slots.core, self.core)
    lu.assertIs(_G.hpController.slots.databank, self.databank)

    -- init to default: no selection
    self.databankMock.data[SELECTED_ELEMENT_KEY] = nil

    local expected

    -- set to core
    expected = 1
    _G.hpController:select(expected)
    lu.assertEquals(_G.hpController.selectedElement, expected)
    lu.assertEquals(self.databankMock.data[SELECTED_ELEMENT_KEY], expected)

    -- unset with nil
    expected = 0
    _G.hpController:select(nil)
    lu.assertEquals(_G.hpController.selectedElement, expected)
    lu.assertEquals(self.databankMock.data[SELECTED_ELEMENT_KEY], expected)

    -- set to screen
    expected = 90
    _G.hpController:select(expected)
    lu.assertEquals(_G.hpController.selectedElement, expected)
    lu.assertEquals(self.databankMock.data[SELECTED_ELEMENT_KEY], expected)

    -- unset
    expected = 0
    _G.hpController:select(expected)
    lu.assertEquals(_G.hpController.selectedElement, expected)
    lu.assertEquals(self.databankMock.data[SELECTED_ELEMENT_KEY], expected)
end

--- Verify set base altitude works when no databank is mapped.
function _G.TestShipHealthUnit:testSelectNoDatabank()
    -- disable databank
    self.unitMock = mockControlUnit:new(nil, 5, "programming board")
    self.unitMock.linkedElements["hpScreen"] = self.screen
    self.unitMock.linkedElements["core"] = self.core
    self.unit = self.unitMock:mockGetClosure()
    _G.unit = self.unit

    unitStart()

    -- relevant mappings are correct
    lu.assertIs(_G.hpController.slots.core, self.core)
    lu.assertNil(_G.hpController.slots.databank)

    local expected

    -- set to core
    expected = 1
    _G.hpController:select(expected)
    lu.assertEquals(_G.hpController.selectedElement, expected)

    -- unset with nil
    expected = 0
    _G.hpController:select(nil)
    lu.assertEquals(_G.hpController.selectedElement, expected)

    -- set to screen
    expected = 90
    _G.hpController:select(expected)
    lu.assertEquals(_G.hpController.selectedElement, expected)

    -- unset
    expected = 0
    _G.hpController:select(expected)
    lu.assertEquals(_G.hpController.selectedElement, expected)
end

os.exit(lu.LuaUnit.run())
