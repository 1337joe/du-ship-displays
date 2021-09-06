#!/usr/bin/env lua
--- Tests for ship health screen.start1 - functionality tests, not display

package.path = "src/?.lua;" .. package.path -- add src directory
package.path = package.path .. ";../du-mocks/src/?.lua" -- add fallback to du-mocks project (if not installed on path)

local lu = require("luaunit")

require("common.Utilities")
require("common.ScreenUtils")

-- load file into a function for efficient calling
local screenStart1 = loadfile("./src/ship-health/hp.screen.start1.lua")

local mockScreenUnit = require("dumocks.ScreenUnit")
local mockDatabankUnit = require("dumocks.DatabankUnit")

local pocketScoutElements = require("test.ship-health.PocketScout")

local SHOW_HEALTHY_KEY = "HP.screen:SHOW_HEALTHY"
local SHOW_DAMAGED_KEY = "HP.screen:SHOW_DAMAGED"
local SHOW_BROKEN_KEY = "HP.screen:SHOW_BROKEN"
local SELECTED_TAB_KEY = "HP.screen:SELECTED_TAB"
local SCROLL_INDEX_KEY = "HP.screen:SCROLL_INDEX"
local STRECH_CLOUD_KEY = "HP.screen:STRETCH_CLOUD"
local MAXIMIZE_CLOUD_KEY = "HP.screen:MAXIMIZE_CLOUD"

_G.TestShipHealthScreen = {}

function _G.TestShipHealthScreen:setup()

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

    local metadata = {
        min = {x = -6, y = -5.625, z = -2.591827, hp = 50},
        max = {x = 6.25, y = 6.348576, z = 1.384995, hp = 1933},
        totalHp = 10650,
        totalMaxHp = 10670
    }

    local data = {}
    local centerOffset = 16
    local tPos, pos
    for key, element in pairs(pocketScoutElements) do
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

    -- not testing controller, mock its functions
    self.hpController = {
        slots = {
            screen = self.screen,
            databank = self.databank
        },
        elementMetadata = metadata,
        elementData = data
    }
    function self.hpController:select(elementId)
        self.hpController.selectedElement = elementId
    end
end

--- Unset all globals set/used by screen.start.
function _G.TestShipHealthScreen:teardown()
    _G.hpScreenController = nil
end

--- Verify init stores references and loads settings from populated databank.
function _G.TestShipHealthScreen:testInit()
    screenStart1()

    -- local expectedShowHealthy = false
    -- self.databankMock.data[SHOW_HEALTHY_KEY] = 0
    -- local expectedShowDamaged = false
    -- self.databankMock.data[SHOW_DAMAGED_KEY] = 0
    -- local expectedShowBroken = false
    -- self.databankMock.data[SHOW_BROKEN_KEY] = 0
    -- local expectedTab = 2
    -- self.databankMock.data[SELECTED_TAB_KEY] = expectedTab
    -- local expectedStretchCloud = true
    -- self.databankMock.data[STRECH_CLOUD_KEY] = 1
    -- local expectedMaximizeCloud = true
    -- self.databankMock.data[MAXIMIZE_CLOUD_KEY] = 1

    _G.hpScreenController:init(self.hpController)

    lu.assertIs(_G.hpScreenController.screen, self.screen)
    lu.assertIs(_G.hpScreenController.databank, self.databank)

    -- only defaults set in init, db values load in refresh
    -- lu.assertEquals(_G.hpScreenController.showHealthy, expectedShowHealthy)
    -- lu.assertEquals(_G.hpScreenController.showDamaged, expectedShowDamaged)
    -- lu.assertEquals(_G.hpScreenController.showBroken, expectedShowBroken)
    -- lu.assertEquals(_G.hpScreenController.selectedTab, expectedTab)
    -- lu.assertEquals(_G.hpScreenController.stretchCloud, expectedStretchCloud)
    -- lu.assertEquals(_G.hpScreenController.maximizeCloud, expectedMaximizeCloud)
end

--- Verify init stores references and defaults settings due to unpopulated databank.
function _G.TestShipHealthScreen:testInitEmptyDatabank()
    screenStart1()

    local expectedShowHealthy = true
    local expectedShowDamaged = true
    local expectedShowBroken = true
    local expectedTab = 1
    local expectedSortColumn = 5
    local expectedSortUp = true
    local expectedScrollIndex = 1
    local expectedStretchCloud = false
    local expectedMaximizeCloud = false

    _G.hpScreenController:init(self.hpController)

    lu.assertIs(_G.hpScreenController.screen, self.screen)
    lu.assertIs(_G.hpScreenController.databank, self.databank)

    lu.assertEquals(_G.hpScreenController.showHealthy, expectedShowHealthy)
    lu.assertEquals(_G.hpScreenController.showDamaged, expectedShowDamaged)
    lu.assertEquals(_G.hpScreenController.showBroken, expectedShowBroken)
    lu.assertEquals(_G.hpScreenController.selectedTab, expectedTab)
    lu.assertEquals(_G.hpScreenController.sortColumn, expectedSortColumn)
    lu.assertEquals(_G.hpScreenController.sortUp, expectedSortUp)
    lu.assertEquals(_G.hpScreenController.scrollIndex, expectedScrollIndex)
    lu.assertEquals(_G.hpScreenController.stretchCloud, expectedStretchCloud)
    lu.assertEquals(_G.hpScreenController.maximizeCloud, expectedMaximizeCloud)
end

--- Verify init stores references and defaults settings due to missing databank.
function _G.TestShipHealthScreen:testInitNoDatabank()
    self.hpController.slots.databank = nil

    screenStart1()

    local expectedShowHealthy = true
    local expectedShowDamaged = true
    local expectedShowBroken = true
    local expectedTab = 1
    local expectedSortColumn = 5
    local expectedSortUp = true
    local expectedScrollIndex = 1
    local expectedStretchCloud = false
    local expectedMaximizeCloud = false

    _G.hpScreenController:init(self.hpController)

    lu.assertIs(_G.hpScreenController.screen, self.screen)
    lu.assertNil(_G.hpScreenController.databank)

    lu.assertEquals(_G.hpScreenController.showHealthy, expectedShowHealthy)
    lu.assertEquals(_G.hpScreenController.showDamaged, expectedShowDamaged)
    lu.assertEquals(_G.hpScreenController.showBroken, expectedShowBroken)
    lu.assertEquals(_G.hpScreenController.selectedTab, expectedTab)
    lu.assertEquals(_G.hpScreenController.sortColumn, expectedSortColumn)
    lu.assertEquals(_G.hpScreenController.sortUp, expectedSortUp)
    lu.assertEquals(_G.hpScreenController.scrollIndex, expectedScrollIndex)
    lu.assertEquals(_G.hpScreenController.stretchCloud, expectedStretchCloud)
    lu.assertEquals(_G.hpScreenController.maximizeCloud, expectedMaximizeCloud)
end

--- Verify mouseDown updates state properly.
function _G.TestShipHealthScreen:testMouseDown()
    screenStart1()

    _G.hpScreenController:init(self.hpController)

    lu.assertIs(_G.hpScreenController.screen, self.screen)

    -- init button definition to single button covering bottom right corner of screen
    local BUTTON_1 = "Button 1"
    local buttonCoordinates = {}
    buttonCoordinates[BUTTON_1] = {x1 = 0.5, x2 = 1.0, y1 = 0.5, y2 = 1.0}
    _G.hpScreenController.buttonCoordinates = buttonCoordinates

    local expectedX, expectedY, expectedButton

    -- miss button
    expectedX = 0.25
    expectedY = 0.25
    expectedButton = nil
    _G.hpScreenController:mouseDown(expectedX, expectedY)
    lu.assertEquals(_G.hpScreenController.mouse.x, expectedX)
    lu.assertEquals(_G.hpScreenController.mouse.y, expectedY)
    lu.assertEquals(_G.hpScreenController.mouse.pressed, expectedButton)

    -- hit button
    expectedX = 0.75
    expectedY = 0.75
    expectedButton = BUTTON_1
    _G.hpScreenController:mouseDown(expectedX, expectedY)
    lu.assertEquals(_G.hpScreenController.mouse.x, expectedX)
    lu.assertEquals(_G.hpScreenController.mouse.y, expectedY)
    lu.assertEquals(_G.hpScreenController.mouse.pressed, expectedButton)
end

--- Verify mouseUp updates state and calls handler properly.
function _G.TestShipHealthScreen:testMouseUp()
    screenStart1()

    _G.hpScreenController:init(self.hpController)

    lu.assertIs(_G.hpScreenController.screen, self.screen)

    -- init button definition to single button covering bottom right corner of screen
    local BUTTON_1 = "Button 1"
    local buttonCoordinates = {}
    buttonCoordinates[BUTTON_1] = {x1 = 0.5, x2 = 1.0, y1 = 0.5, y2 = 1.0}
    _G.hpScreenController.buttonCoordinates = buttonCoordinates

    -- implement simple handler to verify call
    local actualButton = nil
    _G.hpScreenController.handleButton = function(self, button)
        actualButton = button
    end

    -- release off button, button was not pressed
    actualButton = nil
    _G.hpScreenController.mouse.pressed = nil
    _G.hpScreenController:mouseUp(0.25, 0.25)
    lu.assertNil(_G.hpScreenController.mouse.pressed)
    lu.assertNil(actualButton)

    -- release off button, button was pressed
    actualButton = nil
    _G.hpScreenController.mouse.pressed = BUTTON_1
    _G.hpScreenController:mouseUp(0.25, 0.25)
    lu.assertNil(_G.hpScreenController.mouse.pressed)
    lu.assertNil(actualButton)
    
    -- release on button, button was not pressed
    actualButton = nil
    _G.hpScreenController.mouse.pressed = nil
    _G.hpScreenController:mouseUp(0.75, 0.75)
    lu.assertNil(_G.hpScreenController.mouse.pressed)
    lu.assertNil(actualButton)

    -- release on button, button was pressed - calls handler
    actualButton = nil
    _G.hpScreenController.mouse.pressed = BUTTON_1
    _G.hpScreenController:mouseUp(0.75, 0.75)
    lu.assertNil(_G.hpScreenController.mouse.pressed)
    lu.assertEquals(actualButton, BUTTON_1)
end

os.exit(lu.LuaUnit.run())
