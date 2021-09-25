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
_G.fuelController.slots.core = core -- if not found by name will autodetect
_G.fuelController.slots.databank = databank -- if not found by name will autodetect

-----------------------
-- End Configuration --
-----------------------

-- link missing slot inputs / validate provided slots
local slots = _G.fuelController.slots
local MAPPING_DEBUG = "Slot %s mapped to %s %s"
local MODULE = "fuel"

local remainingSlots = _G.Utilities.findAllSlots(nil, {unit, unit.export, slots.core, slots.databank})
slots.screens = {}
slots.tanks = {}

local screenAccepts = {}
local fuelBonuses = {}

local function calculateFuelTankBonus(slot, type, fuelDensity, tankSizes)
    local massOpt = slot.getItemsMass() / (slot.getItemsVolume() * fuelDensity)
    local volHand = slot.getMaxVolume() / tankSizes[slot.getSelfMass()]
    if enableDebug then
        system.print(string.format("%s bonus: %0.1f%% mass optimization, %0.1f%% volume handling", type, massOpt,
            volHand))
    end
    return massOpt, volHand
end
 -- TODO global for testing, put in fuel module scope when extracted
function _G.findGroupName(tankName)
    local group, name = string.match(tankName, "^%[([^%]]+)]%s*(.*)")
    if group and name then
        return group, name
    end
    return nil, tankName
end
function _G.storeTankData(tankRoot, slot)
    local name = string.match(slot.getData(), [["name":"(.-)"]])
    local group, tankName = _G.findGroupName(name)
    local parent
    if group then
        local groupId = -1
        while tankRoot[groupId] and tankRoot[groupId].name ~= group do
            groupId = groupId - 1
        end
        if not tankRoot[groupId] then
            tankRoot[groupId] = {
                name = group,
                children = {}
            }
        elseif not tankRoot[groupId].children then
            tankRoot[groupId].children = {}
        end
        parent = tankRoot[groupId].children
    else
        parent = tankRoot
    end

    parent[slot.getId()] = {
        name = tankName,
        getVolume = slot.getItemsVolume,
        maxVol = slot.getMaxVolume(),
        getTimeLeft = function()
            return tonumber(string.match(slot.getData(), [["timeLeft":([0-9%.-]+)]]))
        end
    }
end

local elementClass
for name, slot in pairs(remainingSlots) do
    elementClass = slot.getElementClass()
    if elementClass == "CoreUnitDynamic" then
        slots.core = slot
        if enableDebug then
            system.print(string.format(MAPPING_DEBUG, name, MODULE, "core"))
        end
    elseif elementClass == "DataBankUnit" then
        if slots.databank then
            system.print("Warning: multiple databanks not currently supported") -- TODO support multiple databanks?
        else
            slots.databank = slot
            if enableDebug then
                system.print(string.format(MAPPING_DEBUG, name, MODULE, "databank"))
            end
        end
    elseif elementClass == "ScreenUnit" then
        local outputString = slot.getScriptOutput()
        local success, output = pcall(json.decode, outputString)
        if not (success and type(output) == "table") then
            local message = string.format("Unexpected screen output, is screen on slot [%s] initialized? (%s)", name, outputString)
            system.print(message)
        else
            slots.screens[slot.getId()] = slot
            slot.activate()
            screenAccepts[slot.getId()] = output.accept
        end

    elseif elementClass == "AtmoFuelContainer" then
        if not slots.tanks.atmo then
            slots.tanks.atmo = {}
        end
        _G.storeTankData(slots.tanks.atmo, slot)
        if not fuelBonuses.atmoVolHand then
            local tankSizes = {[35.03] = 100, [182.67] = 400, [988.67] = 1600, [5481.27] = 12800}
            local massOpt, volHand = calculateFuelTankBonus(slot, "atmo", 4.0, tankSizes)
            fuelBonuses.massOpt = massOpt
            fuelBonuses.atmoVolHand = volHand
        end
    elseif elementClass == "SpaceFuelContainer" then
        if not slots.tanks.space then
            slots.tanks.space = {}
        end
        _G.storeTankData(slots.tanks.space, slot)
        if not fuelBonuses.spaceVolHand then
            local tankSizes = {[182.67] = 400, [988.67] = 1600, [5481.27] = 12800}
            local massOpt, volHand = calculateFuelTankBonus(slot, "space", 6.0, tankSizes)
            fuelBonuses.massOpt = massOpt
            fuelBonuses.spaceVolHand = volHand
        end
    elseif elementClass == "RocketFuelContainer" then
        if not slots.tanks.rocket then
            slots.tanks.rocket = {}
        end
        _G.storeTankData(slots.tanks.rocket, slot)
        if not fuelBonuses.rocketVolHand then
            local tankSizes = {[173.42] = 400, [886.72] = 800, [4724.43] = 6400, [25741.76] = 50000}
            local massOpt, volHand = calculateFuelTankBonus(slot, "rocket", 0.8, tankSizes)
            fuelBonuses.massOpt = massOpt
            fuelBonuses.rocketVolHand = volHand
        end
    end
end

if enableDebug then
    if not slots.databank then
        system.print("No databank found, controller state will not persist between sessions.")
    end
    if not slots.core then
        if not (slots.tanks.atmo or slots.tanks.space or slots.tanks.rocket) then
            system.print("No tanks linked and no core to scan, display will be empty.")
        else
            system.print("No core link to scan, only linked tanks will display.")
        end
    end
end

 -- TODO scan core (if available) for non-linked fuel tanks

-- hide widgets
unit.hide()

local core = _G.fuelController.slots.core
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
    excludeA = false,
    excludeS = false,
    excludeR = false,
}

local function shallowCopyTable(input)
    local copy = {}
    for k, v in pairs(input) do
        copy[k] = v
    end
    return copy
end

 -- TODO lazy load this on first screen update, only load options supported by screen
if databank then
    local optionsKey, databankOptions, optionsSuccess, options

    for id, screen in pairs(screens) do
        optionsKey = string.format(GENERAL_OPTIONS_KEY, id)
        databankOptions = databank.getStringValue(optionsKey)
        optionsSuccess, options = pcall(json.decode, databankOptions)
        if not (optionsSuccess and type(options) == "table") then
            options = _G.fuelController.options[0]
            _G.fuelController.options[id] = shallowCopyTable(options)
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
            _G.fuelController.fuelOptions[id] = shallowCopyTable(options)
            databank.setStringValue(optionsKey, json.encode(options))
        else
            _G.fuelController.fuelOptions[id] = options
        end
        databank.setIntValue(FUEL_OPTIONS_NONCE_KEY,options.nonce)
    end
else
    for id, screen in pairs(screens) do
        _G.fuelController.options[id] =  shallowCopyTable(_G.fuelController.options[0])
        -- TODO only on fuel-tagged screens
        _G.fuelController.fuelOptions[id] = shallowCopyTable(_G.fuelController.fuelOptions[0])
    end
end


-- TODO pull up to fuel module
function _G.collectChildData(tankList)
    local compiledChildren = {}
    local maxVol = 0
    local vol = 0
    local minTimeLeft = nil

    local tankData
    for id, tank in pairs(tankList) do
        -- populate this tank
        tankData = {
            name = tank.name
        }
        if tank.children then
            local children, childMaxVol, childVol, childTimeLeft = collectChildData(tank.children)
            tankData.children = children
            tankData.maxVol = childMaxVol
            tankData.vol = childVol
            tankData.timeLeft = childTimeLeft
        else
            tankData.maxVol = tank.maxVol
            tankData.vol = tank.getVolume()
            tankData.timeLeft = tank.getTimeLeft()
        end

        -- roll data up for parent
        maxVol = maxVol + tankData.maxVol
        vol = vol + tankData.vol
        if not minTimeLeft then
            minTimeLeft = tankData.timeLeft
        elseif tankData.timeLeft then
            minTimeLeft = math.min(minTimeLeft, tankData.timeLeft)
        end
        table.insert(compiledChildren, tankData)
    end
    return compiledChildren, maxVol, vol, minTimeLeft
end

-- declare methods
function _G.fuelController:updateState()

    -- get requested data (common)
    local processFuel = false
    for _, accepts in pairs(screenAccepts) do
        for _, accept in pairs(accepts) do
            if accept == "fuel" then
                processFuel = true
            end
        end
    end

    local data = {}

    if processFuel then


        local atmoTanks
        if slots.tanks.atmo then
            atmoTanks = {
                name = "Atmo"
            }
            local children, childMaxVol, childVol, childTimeLeft = _G.collectChildData(slots.tanks.atmo)
            atmoTanks.children = children
            atmoTanks.maxVol = childMaxVol
            atmoTanks.vol = childVol
            atmoTanks.timeLeft = childTimeLeft
        end

        local spaceTanks
        if slots.tanks.space then
            spaceTanks = {
                name = "Space"
            }
            local children, childMaxVol, childVol, childTimeLeft = _G.collectChildData(slots.tanks.space)
            spaceTanks.children = children
            spaceTanks.maxVol = childMaxVol
            spaceTanks.vol = childVol
            spaceTanks.timeLeft = childTimeLeft
        end

        local rocketTanks
        if slots.tanks.rocket then
            rocketTanks = {
                name = "Rocket"
            }
            local children, childMaxVol, childVol, childTimeLeft = _G.collectChildData(slots.tanks.rocket)
            rocketTanks.children = children
            rocketTanks.maxVol = childMaxVol
            rocketTanks.vol = childVol
            rocketTanks.timeLeft = childTimeLeft
        end

        local fuel = {
            atmo = atmoTanks,
            space = spaceTanks,
            rocket = rocketTanks
        }
        data.fuel = fuel
    end

    for id, screen in pairs(screens) do
        self:updateScreen(id, screen, data)
    end
end

function _G.fuelController:updateScreen(screenId, screen, data)
    local output = json.decode(screen.getScriptOutput())

    -- support updating accepts list dynamically, will lag by one refresh to actually fetch data
    -- TODO monitor for change, show loading message instead of data on change
    screenAccepts[screenId] = output.accept

    -- get requested data (specific)
    local processFuel = false
    for _, accept in pairs(output.accept) do
        if accept == "fuel" then
            processFuel = true
        end
    end

    local input = {}

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

        input.fuel = shallowCopyTable(data.fuel)
        input.fuel.options = self.fuelOptions[screenId]
    end

    if enableDebug then
        input.debug = true
    end

    local inputString = json.encode(input)
    -- system.print(inputString)
    screen.setScriptInput(inputString)
end

_G.fuelController:updateState()

-- schedule updating
unit.setTimer("updateFuel", 1 / FUEL_UPDATE_FREQUENCY)
