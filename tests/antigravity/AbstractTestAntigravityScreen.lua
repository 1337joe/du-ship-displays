#!/usr/bin/env lua
--- Generic display test conditions for running through antigravity screens.

package.path = package.path .. ";../du-mocks/?.lua" -- add du-mocks project

local lu = require("luaunit")

require("common.Utilities")
require("common.ScreenUtils")

local mockScreenUnit = require("dumocks.ScreenUnit")
local mockDatabankUnit = require("dumocks.DatabankUnit")

local TestAntigravityScreen = {}

function TestAntigravityScreen:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    -- first configuration in the list will be used for the download image for the panel
    o.displayConfigurations = {
        function(self)
            self.displayConfigurationName = "sample data"
            self.agController.verticalVelocity = 5.842261
            self.agController.currentAltitude = 1283.1961686802
            self.agController.targetAltitude = 1250
            self.agController.agState = true
            self.agController.baseAltitude = 1277.0
            self.agController.agField = 1.2000000178814
            self.agController.agPower = 0.35299472945713
        end,
        function(self)
            self.displayConfigurationName = "0 altitude/vel"
            self.agController.verticalVelocity = 0
            self.agController.currentAltitude = 0
            self.agController.targetAltitude = 200000
            self.agController.agState = true
            self.agController.baseAltitude = 23708
            self.agController.agField = 1.2000000178814
            self.agController.agPower = 0.27
        end,
        function(self)
            self.displayConfigurationName = "nan altitude/vel"
            self.agController.verticalVelocity = 0 / 0
            self.agController.currentAltitude = 0 / 0
            self.agController.targetAltitude = 200000
            self.agController.agState = true
            self.agController.baseAltitude = 23708
            self.agController.agField = 1.2000000178814
            self.agController.agPower = 0.27
        end,
        function(self)
            self.displayConfigurationName = "negative altitude"
            self.agController.verticalVelocity = -1.2
            self.agController.currentAltitude = -100
            self.agController.targetAltitude = 200000
            self.agController.agState = true
            self.agController.baseAltitude = 23708
            self.agController.agField = 1.2000000178814
            self.agController.agPower = 0.27
        end
    }
    o.sampleDisplayConfiguration = 1

    return o
end

function TestAntigravityScreen:runScreenSetup()
    lu.fail("Override with whatever is needed to initialize the display.")
end

function TestAntigravityScreen:setup()

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
    function self.agController:setBaseAltitude(altitude)
        self.targetAltitude = altitude
    end
end

--- Unset all globals set/used by screen.start.
function TestAntigravityScreen:teardown()
    _G.agScreenController = nil
end

local SVG_WRAPPER_TEMPLATE = [[<li><p>%s<br>%s</p></li>]]

--- Generate screen images for various configurations, saving as a sample image and grid of test outputs.
function TestAntigravityScreen:testDisplay()
    local allSvg = {}
    allSvg[#allSvg + 1] = [[
<html>
<head>
    <style>
        ul.gallery {
            list-style-type: none;
            padding: 0;
            margin: 5px;
            display: grid;
            grid-gap: 20px 5px;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        }
        
        ul.gallery svg {
            width: 100%;
            height: 100%;
        }
    </style>
</head>

<body>
    <ul class="gallery">
]]

    local index = 0
    local result, msg, actual, label
    for name, configuration in pairs(self.displayConfigurations) do

        self:setup()
        self:runScreenSetup()

        self.displayConfigurationName = nil
        configuration(self)
        label = string.format("%s (%s)", name, self.displayConfigurationName)

        _G.agScreenController.needRefresh = true
        result, msg = pcall(_G.agScreenController.refresh, _G.agScreenController)
        lu.assertTrue(result, string.format("%s produced error: %s", label, msg))

        actual = self.screenMock.html
        lu.assertFalse(actual:len() == 0, string.format("%s produced no output.", label))

        if name == self.sampleDisplayConfiguration then
            -- save as file
            local outputHandle, errorMsg = io.open(self.SVG_SAMPLE_OUTPUT_FILE, "w")
            if errorMsg then
                error(errorMsg)
            else
                io.output(outputHandle):write(actual)
                outputHandle:close()
            end
        end

        allSvg[#allSvg + 1] = string.format(SVG_WRAPPER_TEMPLATE, label, actual)

        self:teardown()

        index = index + 1
    end

    allSvg[#allSvg + 1] = [[
    </ul>
</body>
</html>
]]

    -- save as file
    local outputHandle, errorMsg = io.open(self.HTML_ALL_OUTPUT_FILE, "w")
    if errorMsg then
        error(errorMsg)
    else
        io.output(outputHandle):write(table.concat(allSvg, "\n"))
        outputHandle:close()
    end
end

return TestAntigravityScreen
