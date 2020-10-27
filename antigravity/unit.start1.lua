
_G.UPDATE_FREQUENCY = 10 -- Hz

-- container for shared state for anti-grav controller
_G.agController = {}

-- slot definitions
_G.agController.slots = {}
_G.agController.slots.core = nil -- autodetect
_G.agController.slots.antigrav = nil -- autodetect
_G.agController.slots.screen = agScreen
