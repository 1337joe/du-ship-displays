#!/usr/bin/env lua
--- Tests for antigravity screen.start3.basic.banner

package.path = "src/?.lua;" .. package.path -- add src directory
package.path = package.path .. ";../du-mocks/src/?.lua" -- add fallback to du-mocks project (if not installed on path)

local lu = require("luaunit")

-- load file into a function for efficient calling
local screenStart1 = loadfile("./src/ship-health/hp.screen.start1.lua")
-- load base SVG
local inputHandle = io.open("src/ship-health/hp.screen.basic.svg", "rb")
local BASE_SVG = io.input(inputHandle):read("*all")
inputHandle:close()

local abstractTestScreen = require("test.ship-health.AbstractTestShipHealthScreenBasic")

_G.TestShipHealthScreenBasicBanner = abstractTestScreen:new()
_G.TestShipHealthScreenBasicBanner.SVG_SAMPLE_OUTPUT_FILE = "test/results/images/ship-health-basic.svg"
_G.TestShipHealthScreenBasicBanner.HTML_ALL_OUTPUT_FILE = "test/results/images/ship-health-basic-all.html"

local displayConfigurations = _G.TestShipHealthScreenBasicBanner.displayConfigurations

function _G.TestShipHealthScreenBasicBanner:runScreenSetup()
    screenStart1()
    _G.hpScreenController.SVG_TEMPLATE = BASE_SVG

    _G.hpScreenController:init(self.hpController)

    lu.assertIs(_G.hpScreenController.screen, self.screen)
end

function TestShipHealthScreenBasicBanner:testDisplay()
    abstractTestScreen.testDisplay(self)
end

os.exit(lu.LuaUnit.run())
