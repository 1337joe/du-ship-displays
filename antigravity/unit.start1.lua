
_G.UPDATE_FREQUENCY = 10 -- Hz

-- container for shared state for anti-grav controller
_G.agController = {}

-- slot definitions
_G.agController.slots = {}
_G.agController.slots.core = core
_G.agController.slots.antigrav = antigrav
_G.agController.slots.screen = screen

-- TODO auto-detect slots if not explicitly set

local hideAntiGravityWidget = true --export: Attempt to hide Anti-Gravity Generator widget
_G.agController.hideAntiGravityWidget = hideAntiGravityWidget
