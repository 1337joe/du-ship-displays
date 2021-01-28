#!/usr/bin/env lua
--- Additional generic display test conditions for running through ship health basic screens.

package.path = package.path .. ";../du-mocks/?.lua" -- add du-mocks project

local lu = require("luaunit")

local pocketScoutElements = require("tests.ship-health.PocketScout")

local abstractTestScreen = require("tests.ship-health.AbstractTestShipHealthScreen")

_G.AbstractTestShipHealthScreenBasic = abstractTestScreen:new()

function AbstractTestShipHealthScreenBasic:new()
    o = abstractTestScreen:new()
    setmetatable(o, self)
    self.__index = self

    o.displayConfigurations[#o.displayConfigurations + 1] = function(self)
        self.displayConfigurationName = "table no healthy"
        self.hpController.elementMetadata = self.generateElementMetadataData()
        self.hpController.elementData = self.generateElementData(pocketScoutElements)
        self.hpController.shipName = "Pocket Scout"
        self.hpController.selectedElement = 1

        self.databankMock.data["HP.screen:SHOW_HEALTHY"] = 0
    end
    o.displayConfigurations[#o.displayConfigurations + 1] = function(self)
        self.displayConfigurationName = "table sort id down, scrolled"
        self.hpController.elementMetadata = self.generateElementMetadataData()
        self.hpController.elementData = self.generateElementData(pocketScoutElements)
        self.hpController.shipName = "Pocket Scout"
        self.hpController.selectedElement = 1

        self.databankMock.data["HP.screen:SORT_UP"] = 0
        self.databankMock.data["HP.screen:SCROLL_INDEX"] = 10
    end
    o.displayConfigurations[#o.displayConfigurations + 1] = function(self)
        self.displayConfigurationName = "table sort name up"
        self.hpController.elementMetadata = self.generateElementMetadataData()
        self.hpController.elementData = self.generateElementData(pocketScoutElements)
        self.hpController.shipName = "Pocket Scout"
        self.hpController.selectedElement = 1

        self.databankMock.data["HP.screen:SORT_COLUMN"] = 2
    end
    o.displayConfigurations[#o.displayConfigurations + 1] = function(self)
        self.displayConfigurationName = "table sort dmg down"
        self.hpController.elementMetadata = self.generateElementMetadataData()
        self.hpController.elementData = self.generateElementData(pocketScoutElements)
        self.hpController.shipName = "Pocket Scout"
        self.hpController.selectedElement = 1

        self.databankMock.data["HP.screen:SORT_COLUMN"] = 3
        self.databankMock.data["HP.screen:SORT_UP"] = 0
    end
    o.displayConfigurations[#o.displayConfigurations + 1] = function(self)
        self.displayConfigurationName = "table sort max up"
        self.hpController.elementMetadata = self.generateElementMetadataData()
        self.hpController.elementData = self.generateElementData(pocketScoutElements)
        self.hpController.shipName = "Pocket Scout"
        self.hpController.selectedElement = 1

        self.databankMock.data["HP.screen:SORT_COLUMN"] = 4
    end
    o.displayConfigurations[#o.displayConfigurations + 1] = function(self)
        self.displayConfigurationName = "table sort int down"
        self.hpController.elementMetadata = self.generateElementMetadataData()
        self.hpController.elementData = self.generateElementData(pocketScoutElements)
        self.hpController.shipName = "Pocket Scout"
        self.hpController.selectedElement = 1

        self.databankMock.data["HP.screen:SORT_COLUMN"] = 5
        self.databankMock.data["HP.screen:SORT_UP"] = 0
    end

    -- new default: top view
    o.displayConfigurations[#o.displayConfigurations + 1] = function(self)
        self.displayConfigurationName = "tab: top"
        self.hpController.elementMetadata = self.generateElementMetadataData()
        self.hpController.elementData = self.generateElementData(pocketScoutElements)
        self.hpController.shipName = "Pocket Scout"
        self.hpController.selectedElement = 1

        self.databankMock.data["HP.screen:SELECTED_TAB"] = 2
    end
    -- override default display
    o.sampleDisplayConfiguration = #o.displayConfigurations

    o.displayConfigurations[#o.displayConfigurations + 1] = function(self)
        self.displayConfigurationName = "top no healthy"
        self.hpController.elementMetadata = self.generateElementMetadataData()
        self.hpController.elementData = self.generateElementData(pocketScoutElements)
        self.hpController.shipName = "Pocket Scout"
        self.hpController.selectedElement = 1

        self.databankMock.data["HP.screen:SELECTED_TAB"] = 2
        self.databankMock.data["HP.screen:SHOW_HEALTHY"] = 0
    end
    o.displayConfigurations[#o.displayConfigurations + 1] = function(self)
        self.displayConfigurationName = "top no damaged"
        self.hpController.elementMetadata = self.generateElementMetadataData()
        self.hpController.elementData = self.generateElementData(pocketScoutElements)
        self.hpController.shipName = "Pocket Scout"
        self.hpController.selectedElement = 1

        self.databankMock.data["HP.screen:SELECTED_TAB"] = 2
        self.databankMock.data["HP.screen:SHOW_DAMAGED"] = 0
    end
    o.displayConfigurations[#o.displayConfigurations + 1] = function(self)
        self.displayConfigurationName = "top no broken"
        self.hpController.elementMetadata = self.generateElementMetadataData()
        self.hpController.elementData = self.generateElementData(pocketScoutElements)
        self.hpController.shipName = "Pocket Scout"
        self.hpController.selectedElement = 1

        self.databankMock.data["HP.screen:SELECTED_TAB"] = 2
        self.databankMock.data["HP.screen:SHOW_BROKEN"] = 0
    end
    o.displayConfigurations[#o.displayConfigurations + 1] = function(self)
        self.displayConfigurationName = "top maximized"
        self.hpController.elementMetadata = self.generateElementMetadataData()
        self.hpController.elementData = self.generateElementData(pocketScoutElements)
        self.hpController.shipName = "Pocket Scout"
        self.hpController.selectedElement = 1

        self.databankMock.data["HP.screen:SELECTED_TAB"] = 2
        self.databankMock.data["HP.screen:MAXIMIZE_CLOUD"] = 1
    end
    o.displayConfigurations[#o.displayConfigurations + 1] = function(self)
        self.displayConfigurationName = "top stretched"
        self.hpController.elementMetadata = self.generateElementMetadataData()
        self.hpController.elementData = self.generateElementData(pocketScoutElements)
        self.hpController.shipName = "Pocket Scout"
        self.hpController.selectedElement = 1

        self.databankMock.data["HP.screen:SELECTED_TAB"] = 2
        self.databankMock.data["HP.screen:STRETCH_CLOUD"] = 1
    end
    o.displayConfigurations[#o.displayConfigurations + 1] = function(self)
        self.displayConfigurationName = "top maximized stretched"
        self.hpController.elementMetadata = self.generateElementMetadataData()
        self.hpController.elementData = self.generateElementData(pocketScoutElements)
        self.hpController.shipName = "Pocket Scout"
        self.hpController.selectedElement = 1

        self.databankMock.data["HP.screen:SELECTED_TAB"] = 2
        self.databankMock.data["HP.screen:MAXIMIZE_CLOUD"] = 1
        self.databankMock.data["HP.screen:STRETCH_CLOUD"] = 1
    end
    o.displayConfigurations[#o.displayConfigurations + 1] = function(self)
        self.displayConfigurationName = "tab: side"
        self.hpController.elementMetadata = self.generateElementMetadataData()
        self.hpController.elementData = self.generateElementData(pocketScoutElements)
        self.hpController.shipName = "Pocket Scout"
        self.hpController.selectedElement = 1

        self.databankMock.data["HP.screen:SELECTED_TAB"] = 3
    end
    o.displayConfigurations[#o.displayConfigurations + 1] = function(self)
        self.displayConfigurationName = "tab: front"
        self.hpController.elementMetadata = self.generateElementMetadataData()
        self.hpController.elementData = self.generateElementData(pocketScoutElements)
        self.hpController.shipName = "Pocket Scout"
        self.hpController.selectedElement = 1

        self.databankMock.data["HP.screen:SELECTED_TAB"] = 4
    end

    -- Table display
    local buttons = {"Filter: Healthy", "Filter: Damaged", "Filter: Broken", "Tab: Top", "Tab: Side", "Tab: Front",
                     "Table: Sort Id", "Table: Sort Name", "Table: Sort Dmg", "Table: Sort Max", "Table: Sort Int",
                     "Table: Skip Up", "Table: Scroll Up", "Table: Scroll Down", "Table: Skip Down"}
    for _, button in pairs(buttons) do
        o.displayConfigurations[#o.displayConfigurations + 1] =
            function(self)
                self.displayConfigurationName = "Table: Mouseover " .. button
                self.hpController.elementMetadata = self.generateElementMetadataData()
                self.hpController.elementData = self.generateElementData(pocketScoutElements)
                self.hpController.shipName = "Pocket Scout"
                self.hpController.selectedElement = 1

                local coords = _G.hpScreenController.buttonCoordinates[button]
                self.screenMock.mouseY = (coords.y1 + coords.y2) / 2
                self.screenMock.mouseX = (coords.x1 + coords.x2) / 2
            end
    end

    -- TODO mouseover some row in table

    -- Cloud display
    buttons = {"Tab: Table", "Cloud: Stretch", "Cloud: Maximize"}
    for _, button in pairs(buttons) do
        o.displayConfigurations[#o.displayConfigurations + 1] =
            function(self)
                self.displayConfigurationName = "Cloud: Mouseover " .. button
                self.hpController.elementMetadata = self.generateElementMetadataData()
                self.hpController.elementData = self.generateElementData(pocketScoutElements)
                self.hpController.shipName = "Pocket Scout"
                self.hpController.selectedElement = 1

                self.databankMock.data["HP.screen:SELECTED_TAB"] = 2

                local coords = _G.hpScreenController.buttonCoordinates[button]
                self.screenMock.mouseY = (coords.y1 + coords.y2) / 2
                self.screenMock.mouseX = (coords.x1 + coords.x2) / 2
            end
    end

    return o
end

return AbstractTestShipHealthScreenBasic
