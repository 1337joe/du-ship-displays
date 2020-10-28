-- container for shared state for anti-grav controller
_G.agController = {}

-------------------------
-- Begin Configuration --
-------------------------
_G.UPDATE_FREQUENCY = 10 -- screen update rate (Hz)

-- slot definitions
_G.agController.slots = {}
_G.agController.slots.core = nil -- autodetect
_G.agController.slots.antigrav = nil -- autodetect
_G.agController.slots.screen = agScreen
_G.agController.slots.databank = nil -- autodetect

local MIN_AG_ALTITUDE = 1000 --export: Min altitude to allow setting on anti-grav (m)

-----------------------
-- End Configuration --
-----------------------

-- link missing slot inputs / validate provided slots
local slots = _G.agController.slots
local targetClass, class, slotName

targetClass = "ScreenUnit"
if not (slots.screen and type(slots.screen) == "table" and slots.screen.getElementClass) then
    slots.screen, slotName = _G.Utilities.findFirstSlot(targetClass)
    assert(slots.screen, "Screen slot failed to map.")
    system.print(string.format("Slot %s mapped to agScreen.", slotName))
else
    class = slots.screen.getElementClass()
    assert(class == targetClass, "Screen slot is of type: " .. class)
end

-- once screen is mapped use it for displaying errors
slots.screen.activate()
local function testValid(valid, message)
    if not valid then
        slots.screen.setCenteredText(message)
        error(message)
    end
end

targetClass = "AntiGravityGeneratorUnit"
if not (slots.antigrav and type(slots.antigrav) == "table" and slots.antigrav.getElementClass) then
    slots.antigrav, slotName = _G.Utilities.findFirstSlot(targetClass)
    testValid(slots.antigrav, "AntiGravity Generator link not found.")
    system.print(string.format("Slot %s mapped to antigrav.", slotName))
else
    class = slots.antigrav.getElementClass()
    testValid(class == targetClass, "AntiGravity Generator slot is of type: " .. class)
end

targetClass = "CoreUnitDynamic"
if not (slots.core and type(slots.core) == "table" and slots.core.getElementClass) then
    slots.core, slotName = _G.Utilities.findFirstSlot(targetClass)
    testValid(slots.core, "Core Unit link not found.")
    system.print(string.format("Slot %s mapped to core.", slotName))
else
    class = slots.core.getElementClass()
    testValid(class == targetClass, "Core Unit slot is of type: " .. class)
end

targetClass = "DatabankUnit"
if not (slots.databank and type(slots.databank) == "table" and slots.databank.getElementClass) then
    slots.databank, slotName = _G.Utilities.findFirstSlot(targetClass)
    -- optional, don't force to be set
    if slots.databank then
        system.print(string.format("Slot %s mapped to databank.", slotName))
    else
        system.print("No databank found, controller state will not persist between sessions.")
    end
else
    class = slots.databank.getElementClass()
    testValid(class == targetClass, "Databank slot is of type: " .. class)
end

-- hide widgets
unit.hide()

local core = _G.agController.slots.core
local antigrav = _G.agController.slots.antigrav
local databank = _G.agController.slots.databank

local TARGET_ALTITUDE_KEY = "targetAltitude.I"

-- declare methods
function _G.agController:updateState()
    self.verticalVelocity = core.getWorldVelocity()[3]
    self.currentAltitude = core.getAltitude()
    self.agState = antigrav.getState() == 1
    local data = antigrav.getData()
    self.baseAltitude = antigrav.getBaseAltitude()
    self.agField = tonumber(string.match(data, "\"antiGravityField\":([%d.-]+)"))
    self.agPower = tonumber(string.match(data, "\"antiGPower\":([%d.-]+)"))

    -- signal draw of screen with updated state
    _G.agScreen.needRefresh = true
end

function _G.agController:setBaseAltitude(target)
    if target < MIN_AG_ALTITUDE then
        target = MIN_AG_ALTITUDE
    else
        target = math.floor(target + 0.5) -- snap to nearest meter
    end

    self.targetAltitude = target
    self.slots.antigrav.setBaseAltitude(target)

    if databank then
        databank.setIntValue(TARGET_ALTITUDE_KEY, target)
    end

    self:updateState()
end

function _G.agController:setAgState(newState)
    local state
    if newState then
        self.slots.antigrav.activate()
    else
        self.slots.antigrav.deactivate()
    end

    self:updateState()
end

-- init screen
_G.agScreen:init(_G.agController)

-- init stored values
if databank and databank.hasKey(TARGET_ALTITUDE_KEY) == 1 then
    _G.agController:setBaseAltitude(databank.getIntValue(TARGET_ALTITUDE_KEY))
else
    _G.agController:setBaseAltitude(antigrav.getBaseAltitude())
end

_G.agController:updateState()

-- schedule updating
unit.setTimer("update", 1 / _G.UPDATE_FREQUENCY)
