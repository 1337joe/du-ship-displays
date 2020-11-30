#!/usr/bin/env lua
--- Tests for antigravity screen.start3.basic.banner

package.path = package.path .. ";../du-mocks/?.lua" -- add du-mocks project

local lu = require("luaunit")

-- load file into a function for efficient calling
local screenStart1 = loadfile("./antigravity/ag.screen.start1.lua")
local screenStart2 = loadfile("./antigravity/ag.screen.start2.basic.lua")
local screenStart3 = loadfile("./antigravity/ag.screen.start3.basic.banner.lua")
-- load base SVG
local inputHandle = io.open("antigravity/ag.screen.basic.svg", "rb")
local BASE_SVG = io.input(inputHandle):read("*all")
inputHandle:close()

local abstractTestScreen = require("tests.antigravity.AbstractTestAntigravityScreenBasic")

_G.TestAntigravityScreenBasicBanner = abstractTestScreen:new()
_G.TestAntigravityScreenBasicBanner.SVG_SAMPLE_OUTPUT_FILE = "tests/results/images/antigravity-basic.svg"
_G.TestAntigravityScreenBasicBanner.HTML_ALL_OUTPUT_FILE = "tests/results/images/antigravity-basic-all.html"

local displayConfigurations = _G.TestAntigravityScreenBasicBanner.displayConfigurations

function _G.TestAntigravityScreenBasicBanner:runScreenSetup()
    screenStart1()
    screenStart2()
    screenStart3()
    _G.agScreenController.SVG_TEMPLATE = BASE_SVG

    _G.agScreenController:init(self.agController)

    lu.assertIs(_G.agScreenController.screen, self.screen)
end

function TestAntigravityScreenBasicBanner:testDisplay()
    abstractTestScreen.testDisplay(self)
end

os.exit(lu.LuaUnit.run())
