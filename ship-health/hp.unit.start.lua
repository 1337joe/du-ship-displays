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
local hpUpdateFrequency = 1 / 5 --export: Ship Health data/screen update rate (Hz)
local SHIP_NAME_DEFAULT = "use_id"
local hpShipName = "default" --export: Ship Name, if left "use_id" will use id.

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
local SHIP_NAME_KEY = "HP.unit:SHIP_NAME"
if string.len(hpShipName) == 0 or hpShipName == SHIP_NAME_DEFAULT then
    hpShipName = string.format("%d", core.getConstructId())
end
local SHIP_NAME = _G.Utilities.getPreference(databank, SHIP_NAME_KEY, hpShipName)

-- define controller-level keys
local SELECTED_ELEMENT_KEY = "HP.unit:SELECTED_ELEMENT"

_G.hpController.elementData = {}
_G.hpController.elementMetadata = {}
_G.hpController.arrowOffsetDistance = 4

local initializationComplete = false
local function loadElementData()
    local INIT_TEMPLATE = [[<span style="font-family:Arial">Initializing<br>%d of %d loaded</span>]]
    local elementKeys = core.getElementIdList()
    local elementsBetweenBreaks = 50

    local coreMaxHp = core.getMaxHitPoints()
    local centerOffset = 128
    if coreMaxHp < 150 then
        centerOffset = 16
        _G.hpController.arrowOffsetDistance = 1
    elseif coreMaxHp < 1100 then
        centerOffset = 32
        _G.hpController.arrowOffsetDistance = 1.5
    elseif coreMaxHp < 10000 then
        centerOffset = 64
        _G.hpController.arrowOffsetDistance = 2
    end

    local min = {}
    local max = {}
    local totalHp = 0
    local totalMaxHp = 0

    local pos, hp, mhp
    for index, key in pairs(elementKeys) do
        pos = core.getElementPositionById(key)
        pos[1] = pos[1] - centerOffset
        pos[2] = pos[2] - centerOffset
        pos[3] = pos[3] - centerOffset
        mhp = core.getElementMaxHitPointsById(key)
        hp = core.getElementHitPointsById(key)
        _G.hpController.elementData[key] = {
            n = core.getElementNameById(key),
            t = core.getElementTypeById(key),
            p = pos,
            r = core.getElementRotationById(key),
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
        if not min.hp or mhp < min.hp then
            min.hp = mhp
        end
        if not max.hp or mhp > max.hp then
            max.hp = mhp
        end
        totalHp = totalHp + hp
        totalMaxHp = totalMaxHp + mhp

        if index % elementsBetweenBreaks == 0 then
            -- show progress
            screen.setCenteredText(string.format(INIT_TEMPLATE, index, #elementKeys))

            coroutine.yield()
        end
    end

    _G.hpController.elementMetadata.min = min
    _G.hpController.elementMetadata.max = max
    _G.hpController.elementMetadata.totalHp = totalHp
    _G.hpController.elementMetadata.totalMaxHp = totalMaxHp

    initializationComplete = true
end

local initCoroutine = coroutine.create(loadElementData)

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

    -- init screen
    _G.hpScreenController:init(_G.hpController)

    -- init stored values
    if databank and databank.hasKey(SELECTED_ELEMENT_KEY) == 1 then
        self:select(databank.getIntValue(SELECTED_ELEMENT_KEY))
    else
        self:select(nil)
    end

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
        self.elementData[key].h = hp
        currentTotalHp = currentTotalHp + hp

        if math.random() > 0.90 then
            self:select(key)
        end
    end
    self.elementMetadata.totalHp = currentTotalHp

    -- signal draw of screen with updated state
    _G.hpScreenController.needRefresh = true
end

local stickerIds = {}
--- Selects the provided elementId, or deselects the current element if provided nil or an unknown id.
function _G.hpController:select(elementId)
    -- clear existing stickers
    for _, stickerId in pairs(stickerIds) do
        core.deleteSticker(stickerId)
    end

    -- persist selection in case of restart of board
    if databank then
        databank.setIntValue(SELECTED_ELEMENT_KEY, elementId)
    end

    -- skip remaining if no valid element actually selected
    if not self.elementData[elementId] then
        return
    end

    local elementPos = self.elementData[elementId].p

    -- draw arrows on element
    -- TODO scale by mass of target instead of core size?
    local offset = self.arrowOffsetDistance
    stickerIds = {
        core.spawnArrowSticker(elementPos[1] + offset, elementPos[2], elementPos[3], "north"),
        core.spawnArrowSticker(elementPos[1] - offset, elementPos[2], elementPos[3], "south"),
        core.spawnArrowSticker(elementPos[1], elementPos[2] + offset, elementPos[3], "west"),
        core.spawnArrowSticker(elementPos[1], elementPos[2] - offset, elementPos[3], "east"),
        core.spawnArrowSticker(elementPos[1], elementPos[2], elementPos[3] + offset, "down"),
        core.spawnArrowSticker(elementPos[1], elementPos[2], elementPos[3] - offset, "up"),
        core.spawnArrowSticker(elementPos[1] + offset * 2, elementPos[2], elementPos[3], "north"),
        core.spawnArrowSticker(elementPos[1] - offset * 2, elementPos[2], elementPos[3], "south"),
        core.spawnArrowSticker(elementPos[1], elementPos[2] + offset * 2, elementPos[3], "west"),
        core.spawnArrowSticker(elementPos[1], elementPos[2] - offset * 2, elementPos[3], "east"),
    }
    -- rotate for visibility (so opposite arrows aren't in same plane and won't vanish at the same angle)
    core.rotateSticker(stickerIds[1], 45, 90, 0)
    core.rotateSticker(stickerIds[2], -45, -90, 0)
    core.rotateSticker(stickerIds[3], -90, 0, -45)
    core.rotateSticker(stickerIds[4], 90, 0, -45)
    core.rotateSticker(stickerIds[5], 0, 0, 45)
    core.rotateSticker(stickerIds[6], 180, 0, 45)
    core.rotateSticker(stickerIds[7], -45, 90, 0)
    core.rotateSticker(stickerIds[8], 45, -90, 0)
    core.rotateSticker(stickerIds[9], -90, 0, 45)
    core.rotateSticker(stickerIds[10], 90, 0, 45)

end

-- call repeatedly until finished
unit.setTimer(INIT_TIMER_KEY, 0)
