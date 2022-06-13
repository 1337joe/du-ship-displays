#!/usr/bin/env lua
--- Generic display test conditions for running through ship health screens.

package.path = package.path .. ";../du-mocks/src/?.lua" -- add fallback to du-mocks project (if not installed on path)

local lu = require("luaunit")

require("common.Utilities")
require("common.ScreenUtils")

local mockScreenUnit = require("dumocks.ScreenUnit")
local mockDatabankUnit = require("dumocks.DatabankUnit")

local pocketScoutElements = require("test.ship-health.PocketScout")

local AbstractTestShipHealthScreen = {}

function AbstractTestShipHealthScreen:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    -- first configuration in the list will be used for the download image for the panel
    o.displayConfigurations = {
        function(self)
            self.displayConfigurationName = "sample data"
            self.hpController.elementMetadata = self.generateElementMetadataData()
            self.hpController.elementData = self.generateElementData(pocketScoutElements)
            self.hpController.shipName = "Pocket Scout"
            self.hpController.selectedElement = 1
        end,
    }
    o.sampleDisplayConfiguration = 1

    return o
end

function AbstractTestShipHealthScreen.generateElementMetadataData()
    return {
        min = {x = -6, y = -5.625, z = -2.591827, hp = 50},
        max = {x = 6.25, y = 6.348576, z = 1.384995, hp = 1933},
        totalHp = 10650,
        totalMaxHp = 10670
    }
end

function AbstractTestShipHealthScreen.generateElementData(elements, centerOffset)
    local data = {}
    centerOffset = centerOffset or 16
    local tPos, pos
    for key, element in pairs(elements) do
        tPos = element.position
        pos = {}
        pos.x = tPos[1] - centerOffset
        pos.y = tPos[2] - centerOffset
        pos.z = tPos[3] - centerOffset

        data[key] = {
            n = element.name,
            t = element.type,
            p = pos,
            r = element.rotation,
            m = element.maxHp,
            h = element.hp,
        }
    end
    return data
end

function AbstractTestShipHealthScreen:runScreenSetup()
    lu.fail("Override with whatever is needed to initialize the display.")
end

function AbstractTestShipHealthScreen:setup()

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
    self.hpController = {
        slots = {
            screen = self.screen,
            databank = self.databank
        }
    }
    function self.hpController:select(elementId)
        self.selectedElement = elementId
    end
end

--- Unset all globals set/used by screen.start.
function AbstractTestShipHealthScreen:teardown()
    _G.hpScreenController = nil
end

local SVG_WRAPPER_TEMPLATE = [[<li><p>%s<br>%s</p></li>]]

--- Generate screen images for various configurations, saving as a sample image and grid of test outputs.
function AbstractTestShipHealthScreen:testDisplay()
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
    for configKey, configuration in pairs(self.displayConfigurations) do

        self:setup()
        self:runScreenSetup()

        self.displayConfigurationName = nil
        configuration(self)
        label = string.format("%s (%s)", configKey, self.displayConfigurationName)

        _G.hpScreenController.needRefresh = true
        result, msg = pcall(_G.hpScreenController.refresh, _G.hpScreenController)
        lu.assertTrue(result, string.format("%s produced error: %s", label, msg))

        actual = self.screenMock.html
        lu.assertFalse(actual:len() == 0, string.format("%s produced no output.", label))

        if configKey == self.sampleDisplayConfiguration then
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

return AbstractTestShipHealthScreen
