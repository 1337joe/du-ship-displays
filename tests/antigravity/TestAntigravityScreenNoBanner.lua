#!/usr/bin/env lua

--- Tests for antigravity screen.start2.basic
package.path = package.path .. ";./resources/du-utils/?.lua" -- add du-utils project
package.path = package.path .. ";../du-mocks/?.lua" -- add du-mocks project

local lu = require("luaunit")

require("duutils.Utilities")
require("common.ScreenUtils")

local SVG_OUTPUT_FILE = "tests/results/images/antigravity-nobanner.svg"

-- load file into a function for efficient calling
local screenStart1 = loadfile("./antigravity/ag.screen.start1.lua")
local screenStart2 = loadfile("./antigravity/ag.screen.start2.nobanner.lua")
-- load base SVG
local inputHandle = io.open("antigravity/ag.screen.nobanner.svg", "rb")
local BASE_SVG = io.input(inputHandle):read("*all")
inputHandle:close()


local mockScreenUnit = require("dumocks.ScreenUnit")
local mockDatabankUnit = require("dumocks.DatabankUnit")

_G.TestAntigravityScreenNoBanner = {}

function _G.TestAntigravityScreenNoBanner:setup()

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
function _G.TestAntigravityScreenNoBanner:teardown()
    _G.agScreenController = nil
end

--- Verify refresh generates an SVG and save it as a sample image.
function _G.TestAntigravityScreenNoBanner:testDisplay()
    screenStart1()
    screenStart2()
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


--- Verify a 0 altitude will not crash the display rendering.
function _G.TestAntigravityScreenNoBanner:testDisplayZeroAlt()
    screenStart1()
    screenStart2()
    _G.agScreenController.SVG_TEMPLATE = BASE_SVG

    _G.agScreenController:init(self.agController)

    lu.assertIs(_G.agScreenController.screen, self.screen)

    -- set state in controller
    self.agController.verticalVelocity = 1.2
    self.agController.currentAltitude = 0
    self.agController.targetAltitude = 200000
    self.agController.agState = true
    self.agController.baseAltitude = 23708
    self.agController.agField = 1.2000000178814
    self.agController.agPower = 0.27

    _G.agScreenController.needRefresh = true
    _G.agScreenController:refresh()

    local actual = self.screenMock.html
    lu.assertFalse(actual:len() == 0)
end

os.exit(lu.LuaUnit.run())
