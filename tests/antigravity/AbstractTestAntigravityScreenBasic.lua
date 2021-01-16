#!/usr/bin/env lua
--- Additional generic display test conditions for running through antigravity basic screens.

package.path = package.path .. ";../du-mocks/?.lua" -- add du-mocks project

local lu = require("luaunit")

local abstractTestScreen = require("tests.antigravity.AbstractTestAntigravityScreen")

_G.AbstractTestAntigravityScreenBasic = abstractTestScreen:new()

function AbstractTestAntigravityScreenBasic:new()
    o = abstractTestScreen:new()
    setmetatable(o, self)
    self.__index = self

    -- configuration changes
    o.displayConfigurations[#o.displayConfigurations + 1] = function(self)
        self.displayConfigurationName = "vert vel m/s"
        self.agController.verticalVelocity = 5.842261
        self.agController.currentAltitude = 1283.1961686802
        self.agController.targetAltitude = 1250
        self.agController.agState = true
        self.agController.baseAltitude = 1277.0
        self.agController.agField = 1.2000000178814
        self.agController.agPower = 0.35299472945713

        _G.agScreenController.USE_KMPH = false
    end
    -- error messages
    o.displayConfigurations[#o.displayConfigurations + 1] = function(self)
        self.displayConfigurationName = "AGG Off"
        self.agController.verticalVelocity = 5.842261
        self.agController.currentAltitude = 1283.1961686802
        self.agController.targetAltitude = 1250
        self.agController.agState = false
        self.agController.baseAltitude = 1277.0
        self.agController.agField = 1.2000000178814
        self.agController.agPower = 0.35299472945713
    end
    o.displayConfigurations[#o.displayConfigurations + 1] = function(self)
        self.displayConfigurationName = "Insufficient Pulsors"
        self.agController.verticalVelocity = 5.842261
        self.agController.currentAltitude = 1283.1961686802
        self.agController.targetAltitude = 1250
        self.agController.agState = true
        self.agController.baseAltitude = 1277.0
        self.agController.agField = 0.4000000178814
        self.agController.agPower = 0.35299472945713
    end
    o.displayConfigurations[#o.displayConfigurations + 1] = function(self)
        self.displayConfigurationName = "Base too far"
        self.agController.verticalVelocity = 5.842261
        self.agController.currentAltitude = 1283.1961686802
        self.agController.targetAltitude = 1250
        self.agController.agState = true
        self.agController.baseAltitude = 3000.0
        self.agController.agField = 1.2000000178814
        self.agController.agPower = 0.0
    end

    -- controls
    o.displayConfigurations[#o.displayConfigurations + 1] = function(self)
        self.displayConfigurationName = "Drag Power"
        self.agController.verticalVelocity = 5.842261
        self.agController.currentAltitude = 1283.1961686802
        self.agController.targetAltitude = 1250
        self.agController.agState = true
        self.agController.baseAltitude = 1277.0
        self.agController.agField = 1.2000000178814
        self.agController.agPower = 0.35299472945713

        self.screenMock.mouseState = true
        _G.agScreenController.mouse.pressed = _G.agScreenController.BUTTON_POWER_OFF
        local buttonCoords = _G.agScreenController.buttonCoordinates
        self.screenMock.mouseY = buttonCoords[_G.agScreenController.BUTTON_POWER_OFF].y1
        self.screenMock.mouseX = (buttonCoords[_G.agScreenController.BUTTON_POWER_ON].x1 +
                                     buttonCoords[_G.agScreenController.BUTTON_POWER_OFF].x2) / 2
    end
    o.displayConfigurations[#o.displayConfigurations + 1] = function(self)
        self.displayConfigurationName = "Locked"
        self.agController.verticalVelocity = 5.842261
        self.agController.currentAltitude = 1283.1961686802
        self.agController.targetAltitude = 1250
        self.agController.agState = true
        self.agController.baseAltitude = 1277.0
        self.agController.agField = 1.2000000178814
        self.agController.agPower = 0.35299472945713

        _G.agScreenController.locked = true
    end
    o.displayConfigurations[#o.displayConfigurations + 1] = function(self)
        self.displayConfigurationName = "Drag Lock"
        self.agController.verticalVelocity = 5.842261
        self.agController.currentAltitude = 1283.1961686802
        self.agController.targetAltitude = 1250
        self.agController.agState = true
        self.agController.baseAltitude = 1277.0
        self.agController.agField = 1.2000000178814
        self.agController.agPower = 0.35299472945713

        _G.agScreenController.locked = true
        self.screenMock.mouseState = true
        _G.agScreenController.mouse.pressed = _G.agScreenController.BUTTON_UNLOCK
        local buttonCoords = _G.agScreenController.buttonCoordinates
        self.screenMock.mouseY = buttonCoords[_G.agScreenController.BUTTON_UNLOCK].y1
        self.screenMock.mouseX = (buttonCoords[_G.agScreenController.BUTTON_UNLOCK].x1 +
                                     buttonCoords[_G.agScreenController.BUTTON_LOCK].x2) / 2
    end
    o.displayConfigurations[#o.displayConfigurations + 1] = function(self)
        self.displayConfigurationName = "Drag Slider - 0.5"
        self.agController.verticalVelocity = 5.842261
        self.agController.currentAltitude = 1283.1961686802
        self.agController.targetAltitude = 1250
        self.agController.agState = true
        self.agController.baseAltitude = 1277.0
        self.agController.agField = 1.2000000178814
        self.agController.agPower = 0.35299472945713

        self.screenMock.mouseState = true
        _G.agScreenController.mouse.pressed = _G.agScreenController.BUTTON_TARGET_ALTITUDE_SLIDER
        local buttonCoords = _G.agScreenController.buttonCoordinates
        self.screenMock.mouseY = 0.5
        self.screenMock.mouseX = (buttonCoords[_G.agScreenController.BUTTON_TARGET_ALTITUDE_SLIDER].x1 +
                                     buttonCoords[_G.agScreenController.BUTTON_TARGET_ALTITUDE_SLIDER].x2) / 2
    end

    local buttons = {"Altitude Up", "Altitude Down", "Altitude Adjust Up", "Altitude Adjust Down",
                     "Target Altitude Slider", "Match Current Altitude", "Lock", "Power Off"}
    for _, button in pairs(buttons) do
        o.displayConfigurations[#o.displayConfigurations + 1] =
            function(self)
                self.displayConfigurationName = "Mouseover " .. button
                self.agController.verticalVelocity = 5.842261
                self.agController.currentAltitude = 1283.1961686802
                self.agController.targetAltitude = 1250
                self.agController.agState = true
                self.agController.baseAltitude = 1277.0
                self.agController.agField = 1.2000000178814
                self.agController.agPower = 0.35299472945713

                local coords = _G.agScreenController.buttonCoordinates[button]
                self.screenMock.mouseY = (coords.y1 + coords.y2) / 2
                self.screenMock.mouseX = (coords.x1 + coords.x2) / 2
            end
    end

    return o
end

return AbstractTestAntigravityScreenBasic
