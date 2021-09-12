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
-- _G.fuelController.slots.screen = fuelScreen -- if not found by name will autodetect
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

local slotNameScreens = _G.Utilities.findAllSlots("ScreenUnit")
slots.screens = {}
for name, screen in pairs(slotNameScreens) do
    local outputString = screen.getScriptOutput()
    local success, output = pcall(json.decode, outputString)
    if not (success and type(output) == "table") then
        local message = string.format("Unexpected screen output, is screen on slot [%s] initialized? (%s)", name, outputString)
        system.print(message)
    else
        slots.screens[screen.getId()] = screen
        screen.activate()
        -- todo collect list of accepted types?
    end
end


-- slots.core = _G.Utilities.loadSlot(slots.core, "CoreUnitDynamic", slots.screen, module, "core")
slots.databank = _G.Utilities.loadSlot(slots.databank, "DataBankUnit", slots.screen, module, "databank", true,
                     "No databank found, controller state will not persist between sessions.")

-- gather linked fuel tanks in list
-- scan core (if available) for non-linked fuel tanks

-- hide widgets
unit.hide()

-- local core = _G.fuelController.slots.core
local screens = _G.fuelController.slots.screens
local databank = _G.fuelController.slots.databank

-- load preferences/defaults
local FUEL_UPDATE_FREQUENCY_KEY = "screen.updateFrequency"
local FUEL_UPDATE_FREQUENCY = _G.Utilities.getPreference(databank, FUEL_UPDATE_FREQUENCY_KEY, fuelUpdateFrequency)
local GENERAL_OPTIONS_KEY = "screen.%s.options"
local GENERAL_OPTIONS_NONCE_KEY = "screen.%s.options.nonce"
local FUEL_OPTIONS_KEY = "screen.%s.fuel.options"
local FUEL_OPTIONS_NONCE_KEY = "screen.%s.fuel.options.nonce"

_G.fuelController.options = {}
_G.fuelController.options[0] = {
    nonce = 1,
    header = true,
    uiSmall = false,
    powerToggle = false,
    toggleInactive = false,
}
_G.fuelController.fuelOptions = {}
_G.fuelController.fuelOptions[0] = {
    groupByPrefix = true,
    showWidget = false,
    showNames = true,
    reverseMeters = false,
    excludeA = false,
    excludeS = false,
    excludeR = false,
}
if databank then
    local optionsKey, databankOptions, optionsSuccess, options

    for id, screen in pairs(screens) do
        optionsKey = string.format(GENERAL_OPTIONS_KEY, id)
        databankOptions = databank.getStringValue(optionsKey)
        optionsSuccess, options = pcall(json.decode, databankOptions)
        if not (optionsSuccess and type(options) == "table") then
            options = _G.fuelController.options[0]
            _G.fuelController.options[id] = {table.unpack(options)} -- copy
            databank.setStringValue(optionsKey, json.encode(options))
        else
            _G.fuelController.options[id] = options
        end
        databank.setIntValue(GENERAL_OPTIONS_NONCE_KEY,options.nonce)

        -- TODO only on fuel-tagged screens
        optionsKey = string.format(FUEL_OPTIONS_KEY, id)
        databankOptions = databank.getStringValue(optionsKey)
        optionsSuccess, options = pcall(json.decode, databankOptions)
        if not (optionsSuccess and type(options) == "table") then
            options = _G.fuelController.fuelOptions[0]
            _G.fuelController.fuelOptions[id] = {table.unpack(options)} -- copy
            databank.setStringValue(optionsKey, json.encode(options))
        else
            _G.fuelController.fuelOptions[id] = options
        end
        databank.setIntValue(FUEL_OPTIONS_NONCE_KEY,options.nonce)
    end
end


-- declare methods
function _G.fuelController:updateState()
    for id, screen in pairs(screens) do
        self:updateScreen(id, screen)
    end
end

function _G.fuelController:updateScreen(screenId, screen)
    local output = json.decode(screen.getScriptOutput())

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
            self.options[screenId][k] = v
        end
        local oldNonce = self.options[screenId].nonce
        while self.options[screenId].nonce == oldNonce do
            self.options[screenId].nonce = math.random(99)
        end

        if databank then
            databank.setStringValue(string.format(GENERAL_OPTIONS_KEY, screenId), json.encode(self.options[screenId]))
            databank.setIntValue(string.format(GENERAL_OPTIONS_NONCE_KEY, screenId),self.options[screenId].nonce)
        end
    elseif databank then
        if databank.getIntValue(string.format(GENERAL_OPTIONS_NONCE_KEY, screenId)) ~= self.options[screenId].nonce then
            self.options[screenId] = json.decode(databank.getStringValue(string.format(GENERAL_OPTIONS_KEY, screenId)))
        end
    end
    input.options = self.options[screenId]

    if processFuel then
        if type(output.fuelOptions) == "table" then
            for k, v in pairs(output.fuelOptions) do
                self.fuelOptions[screenId][k] = v
            end
            local oldNonce = self.fuelOptions[screenId].nonce
            while self.fuelOptions[screenId].nonce == oldNonce do
                self.fuelOptions[screenId].nonce = math.random(99)
            end

            if databank then
                databank.setStringValue(string.format(FUEL_OPTIONS_KEY, screenId), json.encode(self.fuelOptions[screenId]))
                databank.setIntValue(string.format(FUEL_OPTIONS_NONCE_KEY, screenId),self.fuelOptions[screenId].nonce)
            end
        elseif databank and databank.getIntValue(string.format(FUEL_OPTIONS_NONCE_KEY, screenId)) ~= self.fuelOptions[screenId].nonce then
            self.fuelOptions[screenId] = json.decode(databank.getStringValue(string.format(FUEL_OPTIONS_KEY, screenId)))
        end

        input.fuel = {
            options = self.fuelOptions[screenId],
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
