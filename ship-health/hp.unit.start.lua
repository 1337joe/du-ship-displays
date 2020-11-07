----------------------------
-- Ship Health Controller --
--   By W3asel (1337joe)  --
----------------------------
-- Bundled: ${date}
-- Latest version always available here: https://github.com/1337joe/du-ship-displays

-- container for shared state for ship health controller
_G.hpController = {}

-------------------------
-- Begin Configuration --
-------------------------
local hpUpdateFrequency = 1 --export: Ship Health data/screen update rate (Hz)
local hpShipName = "asdf" --export: Ship Name, if left empty will use id.

-- slot definitions
_G.hpController.slots = {}
_G.hpController.slots.core = core -- if not found by name will autodetect
_G.hpController.slots.screen = hpScreen -- if not found by name will autodetect
_G.hpController.slots.databank = databank -- if not found by name will autodetect

-----------------------
-- End Configuration --
-----------------------

-- link missing slot inputs / validate provided slots
local slots = _G.hpController.slots
local module = "ship-health"
slots.screen = _G.Utilities.loadSlot(slots.screen, "ScreenUnit", nil, module, "screen")
slots.screen.activate()
slots.core = _G.Utilities.loadSlot(slots.core, "CoreUnitDynamic", slots.screen, module, "core")
slots.databank = _G.Utilities.loadSlot(slots.databank, "DataBankUnit", slots.screen, module, "databank", true,
                     "No databank found, controller state will not persist between sessions.")

-- hide widgets
unit.hide()

local core = slots.core
local screen = slots.screen
local databank = slots.databank

-- load preferences, either from databank or exported parameters
local HP_UPDATE_FREQUENCY_KEY = "HP.unit:UPDATE_FREQUENCY"
local HP_UPDATE_FREQUENCY = _G.Utilities.getPreference(databank, HP_UPDATE_FREQUENCY_KEY, hpUpdateFrequency)
local HP_SHIP_NAME_KEY = "HP.unit:SHIP_NAME"
if string.len(hpShipName) == 0 then
    hpShipName = core.getConstructId()
end
local SHIP_NAME = _G.Utilities.getPreference(databank, HP_SHIP_NAME_KEY, hpShipName)

-- TODO controller-level keys?

local elementData = {}
local elementMetadata = {}

local progressIndicatorIndex = 0
local elementsBetweenBreaks = 5
local initializationComplete = false
local function loadElementData()
    local elementKeys = core.getElementIdList()

    local min = {}
    local max = {}
    local totalHp = 0
    local totalMaxHp = 0

    local pos, hp, mhp
    for index, key in pairs(elementKeys) do
        pos = core.getElementPositionById(key)
        mhp = core.getElementMaxHitPointsById(key)
        hp = core.getElementHitPointsById(key)
        elementData[key] = {
            n = core.getElementNameById(key),
            t = core.getElementTypeById(key),
            p = pos,
            -- r = core.getElementRotationById(key),
            m = mhp,
            h = hp,
        }

        -- track metadata
        if not min.x or pos[1] < min.x then
            min.x = pos[1]
        end
        if not max.x or pos[1] > max.x then
            max.x = pos[1]
        end
        if not min.y or pos[2] < min.y then
            min.y = pos[2]
        end
        if not max.y or pos[2] > max.y then
            max.y = pos[2]
        end
        if not min.z or pos[3] < min.z then
            min.z = pos[3]
        end
        if not max.z or pos[3] > max.z then
            max.z = pos[3]
        end
        if not max.hp or mhp > max.hp then
            max.hp = mhp
        end
        totalHp = totalHp + hp
        totalMaxHp = totalMaxHp + mhp

        if index % elementsBetweenBreaks == 0 then
            -- show progress
            progressIndicatorIndex = progressIndicatorIndex + 1
            screen.setCenteredText("Initializing" .. string.rep(".", progressIndicatorIndex % 4))

            coroutine.yield()
        end
    end

    elementMetadata.min = min
    elementMetadata.max = max
    elementMetadata.totalHp = totalHp
    elementMetadata.totalMaxHp = totalMaxHp

    initializationComplete = true
end

local initCoroutine = coroutine.create(loadElementData)

-- TODO define screen-level keys: filter selection, active panel, zoom level
-- local TARGET_ALTITUDE_KEY = "targetAltitude"

-- declare methods
local INIT_TIMER_KEY = "initHp"
function _G.hpController:finishInitialize()
    if not initializationComplete then
        local ok, message = coroutine.resume(initCoroutine)
        if not ok then
            error(string.format("Initialization coroutine failed: %s", message))
        end
        return
    else
        unit.stopTimer(INIT_TIMER_KEY)
    end

    system.print("X: " .. elementMetadata.min.x .. ", " .. elementMetadata.max.x)
    system.print("Y: " .. elementMetadata.min.y .. ", " .. elementMetadata.max.y)
    system.print("Z: " .. elementMetadata.min.z .. ", " .. elementMetadata.max.z)
    system.print("Max HP: " .. elementMetadata.max.hp)
    -- init screen
    -- _G.hpScreenController:init(_G.hpController)

    -- init stored values
    -- if databank and databank.hasKey(TARGET_ALTITUDE_KEY) == 1 then
    --     _G.agController:setBaseAltitude(databank.getFloatValue(TARGET_ALTITUDE_KEY))
    -- else
    --     _G.agController:setBaseAltitude(antigrav.getBaseAltitude())
    -- end

    _G.hpController:updateState()

    -- schedule updating
    unit.setTimer("updateHp", 1 / HP_UPDATE_FREQUENCY)
end

function _G.hpController:updateState()
    -- TODO - determine if this needs to be in a background coroutine for large ships
    -- update all hp
    local currentTotalHp = 0
    local hp
    for _, key in pairs(core.getElementIdList()) do
        hp = core.getElementHitPointsById(key)
        elementData[key].h = hp
        currentTotalHp = currentTotalHp + hp
    end
    elementMetadata.totalHp = currentTotalHp

    local tempOutputTemplate = [[Ship Name: %s<br>Current Integrity: %.1f%%<br>Max HP: %d]]
    screen.addText(0,0,10,string.format(tempOutputTemplate, SHIP_NAME, (100 * elementMetadata.totalHp / elementMetadata.totalMaxHp), elementMetadata.totalMaxHp))
    -- signal draw of screen with updated state
    -- _G.hpScreenController.needRefresh = true
end

-- call repeatedly until finished
unit.setTimer(INIT_TIMER_KEY, 0)
