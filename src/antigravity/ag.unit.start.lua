----------------------------
-- Antigravity Controller --
--   By W3asel (1337joe)  --
----------------------------
-- Bundled: ${date}
-- Latest version always available here: https://1337joe.github.io/du-ship-displays

-- container for shared state for anti-grav controller
_G.agController = {}

-------------------------
-- Begin Configuration --
-------------------------
local agUpdateFrequency = 10 --export: Antigravity data/screen update rate (Hz)

-- slot definitions
_G.agController.slots = {}
_G.agController.slots.core = core -- if not found by name will autodetect
_G.agController.slots.antigrav = agg -- if not found by name will autodetect
_G.agController.slots.screen = agScreen -- if not found by name will autodetect
_G.agController.slots.databank = databank -- if not found by name will autodetect

local agMinAltitude = 1000 --export: Min altitude to allow setting on anti-grav (m), raise this if you don't want a non-default lower limit.
local agMinG = 0.1 --export: Below this value of g no altitude or vertical velocity will be reported.

-----------------------
-- End Configuration --
-----------------------

-- link missing slot inputs / validate provided slots
local slots = _G.agController.slots
local module = "antigrav"
slots.screen = _G.Utilities.loadSlot(slots.screen, "ScreenUnit", nil, module, "screen")
slots.screen.activate()
slots.antigrav = _G.Utilities.loadSlot(slots.antigrav, "AntiGravityGeneratorUnit", slots.screen, module, "antigrav")
slots.core = _G.Utilities.loadSlot(slots.core, "CoreUnitDynamic", slots.screen, module, "core")
slots.databank = _G.Utilities.loadSlot(slots.databank, "DataBankUnit", slots.screen, module, "databank", true,
                     "No databank found, controller state will not persist between sessions.")

-- hide widgets
unit.hide()

local core = _G.agController.slots.core
local antigrav = _G.agController.slots.antigrav
local databank = _G.agController.slots.databank

-- load preferences, either from databank or exported parameters
local AG_UPDATE_FREQUENCY_KEY = "AG.unit:UPDATE_FREQUENCY"
local AG_UPDATE_FREQUENCY = _G.Utilities.getPreference(databank, AG_UPDATE_FREQUENCY_KEY, agUpdateFrequency)
local MIN_AG_ALTITUDE_KEY = "AG.unit:MIN_AG_ALTITUDE"
local MIN_AG_ALTITUDE = _G.Utilities.getPreference(databank, MIN_AG_ALTITUDE_KEY, agMinAltitude)
local MIN_AG_G_KEY = "AG.unit:MIN_AG_G"
local MIN_AG_G = _G.Utilities.getPreference(databank, MIN_AG_G_KEY, agMinG)

local TARGET_ALTITUDE_KEY = "AntigravTargetAltitude"

local vec3 = require("cpml.vec3")
local planetReference0 = PlanetaryReference(_G.atlas)[0]
local piHalf = math.pi / 2

-- declare methods
--- Compute vertical velocity by projecting world velocity onto world vertical vector
local function calculateVertVel(core)
    -- compute vertical velocity by projecting world velocity onto world vertical vector
    local vel = vec3.new(core.getWorldVelocity())
    local vert = vec3.new(core.getWorldVertical())
    local verticalVelocity = vel:project_on(vert):len()

    -- add sign
    if vel:angle_between(vert) < piHalf then
        verticalVelocity = -1 * verticalVelocity
    end

    return verticalVelocity
end

function _G.agController:updateState()
    if databank then
        self.targetAltitude = databank.getFloatValue(TARGET_ALTITUDE_KEY)
    end

    self.currentAltitude = core.getAltitude()

    if self.currentAltitude == 0 then
        local coreWorldPos = core.getConstructWorldPos()
        local closestBody = planetReference0:closestBody(coreWorldPos)

        -- core.g() is thrown off by the activity of the antigravity generator
        if closestBody:getGravity(coreWorldPos):len() < MIN_AG_G then
            self.verticalVelocity = 0 / 0 -- nan
            self.currentAltitude = 0 / 0 -- nan
        else
            -- calculate altitude from position
            self.currentAltitude = closestBody:getAltitude(coreWorldPos)

            self.verticalVelocity = calculateVertVel(core)
        end
    else
        self.verticalVelocity = calculateVertVel(core)
    end

    self.agState = antigrav.getState() == 1
    local data = antigrav.getData()
    self.baseAltitude = antigrav.getBaseAltitude()
    self.agField = tonumber(string.match(data, "\"antiGravityField\":([%d.-]+)"))
    self.agPower = tonumber(string.match(data, "\"antiGPower\":([%d.-]+)"))

    -- signal draw of screen with updated state
    _G.agScreenController.needRefresh = true
end

function _G.agController:setBaseAltitude(target)
    if target < MIN_AG_ALTITUDE then
        target = MIN_AG_ALTITUDE
    end

    self.targetAltitude = target
    self.slots.antigrav.setBaseAltitude(target)

    if databank then
        databank.setFloatValue(TARGET_ALTITUDE_KEY, target)
    end

    self:updateState()
end

function _G.agController:setAgState(newState)
    if newState == self.agState then
        return
    end

    local state
    if newState then
        self.slots.antigrav.activate()
    else
        self.slots.antigrav.deactivate()
    end

    self:updateState()
end

-- init screen
_G.agScreenController:init(_G.agController)

-- init stored values
if databank and databank.hasKey(TARGET_ALTITUDE_KEY) == 1 then
    _G.agController:setBaseAltitude(databank.getFloatValue(TARGET_ALTITUDE_KEY))
else
    _G.agController:setBaseAltitude(antigrav.getBaseAltitude())
end

_G.agController:updateState()

-- schedule updating
unit.setTimer("updateAg", 1 / AG_UPDATE_FREQUENCY)
