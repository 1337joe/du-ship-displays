#!/usr/bin/env lua

--- Tests for antigravity unit.start.
package.path = package.path .. ";../du-utils/?.lua" -- add du-utils project
package.path = package.path .. ";../du-mocks/?.lua" -- add du-mocks project

local lu = require("luaunit")

require("duutils.Utilities")

local mockCoreUnit = require("dumocks.CoreUnit")
local mockScreenUnit = require("dumocks.ScreenUnit")
local mockAntiGravityGeneratorUnit = require("dumocks.AntiGravityGeneratorUnit")
local mockDatabankUnit = require("dumocks.DatabankUnit")
local mockControlUnit = require("dumocks.ControlUnit")

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
    _G.agScreenController = {}
    function _G.agScreenController:init(_)
    end
end

--- Verify slot loader maps all elements and reports correctly.
function _G.TestAntigravityUnit:testSlotMappingAuto()

    _G.unit = self.unit

    dofile("antigravity/unit.start.lua")

    -- mappings are correct
    lu.assertEquals(_G.agController.slots.screen, self.screen)
    lu.assertEquals(_G.agController.slots.antigrav, self.agGenerator)
    lu.assertEquals(_G.agController.slots.core, self.core)
    lu.assertEquals(_G.agController.slots.databank, self.databank)

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

    dofile("antigravity/unit.start.lua")

    -- mappings are correct
    lu.assertEquals(_G.agController.slots.screen, self.screen)
    lu.assertEquals(_G.agController.slots.antigrav, self.agGenerator)
    lu.assertEquals(_G.agController.slots.core, self.core)
    lu.assertEquals(_G.agController.slots.databank, self.databank)

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

    lu.assertErrorMsgContains("Screen link not found.", dofile, "antigravity/unit.start.lua")
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
    lu.assertErrorMsgContains(errorMsgPrefix, dofile, "antigravity/unit.start.lua")

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
    lu.assertErrorMsgContains(errorMsgPrefix, dofile, "antigravity/unit.start.lua")

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
    dofile("antigravity/unit.start.lua")

    -- screen should also have message
    lu.assertStrContains(self.printOutput, "No databank found")
end

os.exit(lu.LuaUnit.run())
