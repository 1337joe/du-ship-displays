-------------------------
--   Fuel Controller   --
-- By W3asel (1337joe) --
-------------------------
-- Bundled: ${date}
-- Latest version always available here: https://github.com/1337joe/du-ship-displays

-- constants and imports
local json = require("dkjson")

-- container for shared state for fuel controller
_G.fuelController = {}

-------------------------
-- Begin Configuration --
-------------------------
local fuelUpdateFrequency = 2 --export: Fuel data/screen update rate (Hz)
local enableDebug = false --export: Show screen debug info.

-- slot definitions
_G.fuelController.slots = {}
-- _G.fuelController.slots.core = core -- if not found by name will autodetect
_G.fuelController.slots.screen = fuelScreen -- if not found by name will autodetect
_G.fuelController.slots.databank = databank -- if not found by name will autodetect
-- _G.fuelController.slots.tankAtm = tankAtm -- if not found by name will autodetect
-- _G.fuelController.slots.tankSpa = tankSpa -- if not found by name will autodetect
-- _G.fuelController.slots.tankRoc = tankRoc -- if not found by name will autodetect

-----------------------
-- End Configuration --
-----------------------

-- link missing slot inputs / validate provided slots
local slots = _G.fuelController.slots
local module = "fuel"
slots.screen = _G.Utilities.loadSlot(slots.screen, "ScreenUnit", nil, module, "screen")
slots.screen.activate()
-- slots.core = _G.Utilities.loadSlot(slots.core, "CoreUnitDynamic", slots.screen, module, "core")
slots.databank = _G.Utilities.loadSlot(slots.databank, "DataBankUnit", slots.screen, module, "databank", true,
                     "No databank found, controller state will not persist between sessions.")

-- gather linked fuel tanks in list
-- scan core (if available) for non-linked fuel tanks

-- hide widgets
unit.hide()

-- local core = _G.fuelController.slots.core
local screen = _G.fuelController.slots.screen
local databank = _G.fuelController.slots.databank

-- load preferences/defaults
local FUEL_UPDATE_FREQUENCY_KEY = string.format("screen.%s.updateFrequency", screen.getId())
local FUEL_UPDATE_FREQUENCY = _G.Utilities.getPreference(databank, FUEL_UPDATE_FREQUENCY_KEY, fuelUpdateFrequency)
local GENERAL_OPTIONS_KEY = "screen.%s.options"
local GENERAL_OPTIONS_NONCE_KEY = "screen.%s.options.nonce"
local FUEL_OPTIONS_KEY = "screen.%s.fuel.options"
local FUEL_OPTIONS_NONCE_KEY = "screen.%s.fuel.options.nonce"

_G.fuelController.options = {
    nonce = 1,
    header = true,
    uiSmall = false,
    powerToggle = false,
    toggleInactive = false,
}
_G.fuelController.fuelOptions = {
    groupByPrefix = true,
    showWidget = false,
    showNames = true,
    reverseMeters = false,
    excludeA = false,
    excludeS = false,
    excludeR = false,
}
if databank then
    local databankOptions, optionsSuccess, options

    databankOptions = databank.getStringValue(GENERAL_OPTIONS_KEY)
    optionsSuccess, options = pcall(json.decode, databankOptions)
    if not (optionsSuccess and type(options) == "table") then
        options = _G.fuelController.options
        databank.setStringValue(GENERAL_OPTIONS_KEY, json.encode(options))
    else
        _G.fuelController.options = options
        databank.setStringValue(GENERAL_OPTIONS_KEY, json.encode(options))
    end
    databank.setIntValue(GENERAL_OPTIONS_NONCE_KEY,options.nonce)

    databankOptions = databank.getStringValue(FUEL_OPTIONS_KEY)
    optionsSuccess, options = pcall(json.decode, databankOptions)
    if not (optionsSuccess and type(options) == "table") then
        options = _G.fuelController.fuelOptions
        databank.setStringValue(FUEL_OPTIONS_KEY, json.encode(options))
    else
        _G.fuelController.fuelOptions = options
    end
    databank.setIntValue(FUEL_OPTIONS_NONCE_KEY,options.nonce)
end


-- declare methods
function _G.fuelController:updateState()
    local outputString = screen.getScriptOutput()
    local success, output = pcall(json.decode, outputString)
    if not (success and type(output) == "table") then
        screen.setCenteredText(string.format("Unexpected screen output, is it initialized? (%s)", outputString))
        unit.exit()
    end

    local input = {}

    -- get requested data
    local processFuel = false
    for _, accept in pairs(output.accept) do
        if accept == "fuel" then
            processFuel = true
        end
    end

    -- process updates/build inputs
    if type(output.options) == "table" then
        for k, v in pairs(output.options) do
            self.options[k] = v
        end
        local oldNonce = self.options.nonce
        while self.options.nonce == oldNonce do
            self.options.nonce = math.random(99)
        end

        if databank then
            databank.setStringValue(GENERAL_OPTIONS_KEY, json.encode(self.options))
            databank.setIntValue(GENERAL_OPTIONS_NONCE_KEY,self.options.nonce)
        end
    elseif databank then
        if databank.getIntValue(GENERAL_OPTIONS_NONCE_KEY) ~= self.options.nonce then
            self.options = json.decode(databank.getStringValue(GENERAL_OPTIONS_KEY))
        end
    end
    input.options = self.options

    if processFuel then
        if type(output.fuelOptions) == "table" then
            for k, v in pairs(output.fuelOptions) do
                self.fuelOptions[k] = v
            end
            local oldNonce = self.fuelOptions.nonce
            while self.fuelOptions.nonce == oldNonce do
                self.fuelOptions.nonce = math.random(99)
            end

            if databank then
                databank.setStringValue(FUEL_OPTIONS_KEY, json.encode(self.fuelOptions))
                databank.setIntValue(FUEL_OPTIONS_NONCE_KEY,self.fuelOptions.nonce)
            end
        elseif databank.getIntValue(FUEL_OPTIONS_NONCE_KEY) ~= self.fuelOptions.nonce then
            self.fuelOptions = json.decode(databank.getStringValue(FUEL_OPTIONS_KEY))
        end

        input.fuel = {
            options = self.fuelOptions,
        }
    end

    if enableDebug then
        input.debug = true
    end

    screen.setScriptInput(json.encode(input))
end

_G.fuelController:updateState()

-- schedule updating
unit.setTimer("updateFuel", 1 / FUEL_UPDATE_FREQUENCY)
