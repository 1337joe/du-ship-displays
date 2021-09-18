#!/usr/bin/env lua
--- Tests for fuel unit.start.

package.path = "src/?.lua;" .. package.path -- add src directory
package.path = package.path .. ";../du-mocks/src/?.lua" -- add fallback to du-mocks project (if not installed on path)
package.path = "../game-data-lua/?.lua;" .. package.path -- add link to Dual Universe/Game/data/lua/ directory

local lu = require("luaunit")

require("common.Utilities")

-- load file into a function for efficient calling
local unitStart = loadfile("./src/fuel/fuel.unit.start.lua")

local mockCoreUnit = require("dumocks.CoreUnit")
local mockScreenUnit = require("dumocks.ScreenUnit")
local mockDatabankUnit = require("dumocks.DatabankUnit")
local mockControlUnit = require("dumocks.ControlUnit")
local mockContainerUnit = require("dumocks.ContainerUnit")

_G.TestFuelUnit = {}

function _G.TestFuelUnit:setup()

    self.coreMock = mockCoreUnit:new(nil, 1, "dynamic core unit s")
    self.core = self.coreMock:mockGetClosure()

    self.screenMock = mockScreenUnit:new(nil, 2)
    self.screen = self.screenMock:mockGetClosure()

    self.databankMock = mockDatabankUnit:new(nil, 4)
    self.databank = self.databankMock:mockGetClosure()

    self.unitMock = mockControlUnit:new(nil, 5, "programming board")

    -- link all mocks by default
    self.unitMock.linkedElements["fuelScreen"] = self.screen
    self.unitMock.linkedElements["core"] = self.core
    self.unitMock.linkedElements["databank"] = self.databank
    self.unit = self.unitMock:mockGetClosure()

    self.printOutput = ""
    _G.system = {
        print = function(output)
            self.printOutput = self.printOutput .. output .. "\n"
        end
    }
end

--- Unset all globals set/used by unit.start.
function _G.TestFuelUnit:teardown()
    _G.fuelController = nil
    _G.core = nil
    _G.databank = nil
end

--- Verifies behavior of find group name regex/function.
function _G.TestFuelUnit:testFindGroupName()
    _G.unit = self.unit
    unitStart()

    local tankName, expectedGroup, actualGroup, expectedName, actualName

    tankName = "no group"
    expectedGroup = nil
    expectedName = tankName
    actualGroup, actualName = _G.findGroupName(tankName)
    lu.assertEquals(actualGroup, expectedGroup)
    lu.assertEquals(actualName, expectedName)

    tankName = "[group]without space"
    expectedGroup = "group"
    expectedName = "without space"
    actualGroup, actualName = _G.findGroupName(tankName)
    lu.assertEquals(actualGroup, expectedGroup)
    lu.assertEquals(actualName, expectedName)

    tankName = "[group] with space"
    expectedGroup = "group"
    expectedName = "with space"
    actualGroup, actualName = _G.findGroupName(tankName)
    lu.assertEquals(actualGroup, expectedGroup)
    lu.assertEquals(actualName, expectedName)

    tankName = "[double][group]not supported"
    expectedGroup = "double"
    expectedName = "[group]not supported"
    actualGroup, actualName = _G.findGroupName(tankName)
    lu.assertEquals(actualGroup, expectedGroup)
    lu.assertEquals(actualName, expectedName)
end

--- Verifies behavior of tank data extraction without groups.
function _G.TestFuelUnit:testStoreTankDataFlat ()
    _G.unit = self.unit
    unitStart()

    local root, id, tankMock, tank, expectedRoot

    -- no name set
    root = {}
    id = 100
    tankMock = mockContainerUnit:new(nil, id, "atmospheric fuel tank xs")
    tank = tankMock:mockGetClosure()
    expectedRoot = {
        [id] = {
            name = tankMock.name,
            maxVol = 100,
            getVolume = tank.getItemsVolume
        }
    }
    _G.storeTankData(root, tank)
    expectedRoot[id].getTimeLeft = root[id].getTimeLeft -- can't generate matching value statically
    lu.assertEquals(root, expectedRoot)
    lu.assertIsFunction(root[id].getTimeLeft)

    -- name but no group
    root = {}
    id = 101
    tankMock = mockContainerUnit:new(nil, id, "atmospheric fuel tank xs")
    tankMock.name = "Atmo Tank 1"
    tank = tankMock:mockGetClosure()
    expectedRoot = {
        [id] = {
            name = tankMock.name,
            maxVol = 100,
            getVolume = tank.getItemsVolume
        }
    }
    _G.storeTankData(root, tank)
    expectedRoot[id].getTimeLeft = root[id].getTimeLeft -- can't generate matching value statically
    lu.assertEquals(root, expectedRoot)
    lu.assertIsFunction(root[id].getTimeLeft)

    -- add to previous root, no group
    id = 102
    tankMock = mockContainerUnit:new(nil, id, "atmospheric fuel tank xs")
    tankMock.name = "Atmo Tank 2"
    tank = tankMock:mockGetClosure()
    expectedRoot[id] = { -- add key/value, not redefine entire table
        name = tankMock.name,
        maxVol = 100,
        getVolume = tank.getItemsVolume
    }
    _G.storeTankData(root, tank)
    expectedRoot[id].getTimeLeft = root[id].getTimeLeft -- can't generate matching value statically
    lu.assertEquals(root, expectedRoot)
    lu.assertIsFunction(root[id].getTimeLeft)
end

--- Verifies behavior of tank data extraction with groups mixed in.
function _G.TestFuelUnit:testStoreTankDataGroup()
    _G.unit = self.unit
    unitStart()

    local root, id, tankMock, tank, expectedRoot

    -- reset root, group
    root = {}
    id = 103
    tankMock = mockContainerUnit:new(nil, id, "atmospheric fuel tank xs")
    tankMock.name = "[Hover]Starboard"
    tank = tankMock:mockGetClosure()
    expectedRoot = {
        [-1] = {
            name = "Hover",
            children = {
                [id] = {
                    name = "Starboard",
                    maxVol = 100,
                    getVolume = tank.getItemsVolume
                }
            }
        }
    }
    _G.storeTankData(root, tank)
    -- can't generate matching value statically
    expectedRoot[-1].children[id].getTimeLeft = root[-1].children[id].getTimeLeft
    lu.assertEquals(root, expectedRoot)
    lu.assertIsFunction(root[-1].children[id].getTimeLeft)

    -- add to previous root, no group
    id = 104
    tankMock = mockContainerUnit:new(nil, id, "atmospheric fuel tank xs")
    tankMock.name = "Atmo Tank 2"
    tank = tankMock:mockGetClosure()
    expectedRoot[id] = { -- add key/value, not redefine entire table
        name = tankMock.name,
        maxVol = 100,
        getVolume = tank.getItemsVolume
    }
    _G.storeTankData(root, tank)
    expectedRoot[id].getTimeLeft = root[id].getTimeLeft -- can't generate matching value statically
    lu.assertEquals(root, expectedRoot)
    lu.assertIsFunction(root[id].getTimeLeft)

    -- add to previous root, same group
    id = 105
    tankMock = mockContainerUnit:new(nil, id, "atmospheric fuel tank xs")
    tankMock.name = "[Hover]Port"
    tank = tankMock:mockGetClosure()
    expectedRoot[-1].children[id] = {
        name = "Port",
        maxVol = 100,
        getVolume = tank.getItemsVolume
    }
    _G.storeTankData(root, tank)
    -- can't generate matching value statically
    expectedRoot[-1].children[id].getTimeLeft = root[-1].children[id].getTimeLeft
    lu.assertEquals(root, expectedRoot)
    lu.assertIsFunction(root[-1].children[id].getTimeLeft)

    -- add to previous root, new group
    id = 106
    tankMock = mockContainerUnit:new(nil, id, "atmospheric fuel tank xs")
    tankMock.name = "[Engine]Starboard Top"
    tank = tankMock:mockGetClosure()
    expectedRoot[-2] = {
        name = "Engine",
        children = {
            [id] = {
                name = "Starboard Top",
                maxVol = 100,
                getVolume = tank.getItemsVolume
            }
        }
    }
    _G.storeTankData(root, tank)
    -- can't generate matching value statically
    expectedRoot[-2].children[id].getTimeLeft = root[-2].children[id].getTimeLeft
    lu.assertEquals(root, expectedRoot)
    lu.assertIsFunction(root[-2].children[id].getTimeLeft)
end

--- Verifies behavior of tank data building without groups.
function _G.TestFuelUnit:testCollectChildDataFlat()
    _G.unit = self.unit
    unitStart()

    local tanksIn
    local expectedTanks, expectedMaxVol, expectedVol, expectedTimeLeft
    local actualTanks, actualMaxVol, actualVol, actualTimeLeft

    -- single tank
    tanksIn = {
        [100] = {
            name = "Tank 1",
            maxVol = 100,
            getVolume = function() return 70 end,
            getTimeLeft = function() return nil end
        }
    }
    expectedTanks = {
        {name = "Tank 1", maxVol = 100, vol = 70}
    }
    expectedMaxVol, expectedVol, expectedTimeLeft = 100, 70, nil
    actualTanks, actualMaxVol, actualVol, actualTimeLeft = collectChildData(tanksIn)
    lu.assertEquals(actualTanks, expectedTanks)
    lu.assertEquals(actualMaxVol, expectedMaxVol)
    lu.assertEquals(actualVol, expectedVol)
    lu.assertEquals(actualTimeLeft, expectedTimeLeft)

    -- multiple tanks
    tanksIn = {
        [100] = {
            name = "Tank 1",
            maxVol = 100,
            getVolume = function() return 70 end,
            getTimeLeft = function() return nil end
        },
        [101] = {
            name = "Tank 2",
            maxVol = 400,
            getVolume = function() return 325 end,
            getTimeLeft = function() return 100 end
        }
    }
    expectedTanks = {
        {name = "Tank 1", maxVol = 100, vol = 70},
        {name = "Tank 2", maxVol = 400, vol = 325, timeLeft = 100}
    }
    expectedMaxVol, expectedVol, expectedTimeLeft = 500, 395, 100
    actualTanks, actualMaxVol, actualVol, actualTimeLeft = collectChildData(tanksIn)
    lu.assertEquals(actualTanks, expectedTanks)
    lu.assertEquals(actualMaxVol, expectedMaxVol)
    lu.assertEquals(actualVol, expectedVol)
    lu.assertEquals(actualTimeLeft, expectedTimeLeft)
end

--- Verifies behavior of tank data building with groups.
function _G.TestFuelUnit:testCollectChildDataGroups()
    _G.unit = self.unit
    unitStart()

    local tanksIn
    local expectedTanks, expectedMaxVol, expectedVol, expectedTimeLeft
    local actualTanks, actualMaxVol, actualVol, actualTimeLeft

    -- single group, single tank
    tanksIn = {
        [-1] = {
            name = "Hover",
            children = {
                [100] = {
                    name = "Starboard",
                    maxVol = 100,
                    getVolume = function() return 70 end,
                    getTimeLeft = function() return nil end
                }
            }
        }
    }
    expectedTanks = {
        {
            name = "Hover", maxVol = 100, vol = 70, children = {
                {name = "Starboard", maxVol = 100, vol = 70}
            }
        }
    }
    expectedMaxVol, expectedVol, expectedTimeLeft = 100, 70, nil
    actualTanks, actualMaxVol, actualVol, actualTimeLeft = collectChildData(tanksIn)
    lu.assertItemsEquals(actualTanks, expectedTanks)
    lu.assertEquals(actualMaxVol, expectedMaxVol)
    lu.assertEquals(actualVol, expectedVol)
    lu.assertEquals(actualTimeLeft, expectedTimeLeft)

    -- single group, single tank, single tank out of group
    tanksIn = {
        [-1] = {
            name = "Hover",
            children = {
                [100] = {
                    name = "Starboard",
                    maxVol = 100,
                    getVolume = function() return 70 end,
                    getTimeLeft = function() return nil end
                }
            }
        },
        [99] = {
            name = "Tank 1",
            maxVol = 100,
            getVolume = function() return 10 end,
            getTimeLeft = function() return 5 end
        }
    }
    expectedTanks = {
        {
            name = "Hover", maxVol = 100, vol = 70, children = {
                {name = "Starboard", maxVol = 100, vol = 70}
            }
        },
        {name = "Tank 1", maxVol = 100, vol = 10, timeLeft = 5}
    }
    expectedMaxVol, expectedVol, expectedTimeLeft = 200, 80, 5
    actualTanks, actualMaxVol, actualVol, actualTimeLeft = collectChildData(tanksIn)
    lu.assertItemsEquals(actualTanks, expectedTanks)
    lu.assertEquals(actualMaxVol, expectedMaxVol)
    lu.assertEquals(actualVol, expectedVol)
    lu.assertEquals(actualTimeLeft, expectedTimeLeft)

    -- single group, multiple tanks
    tanksIn = {
        [-1] = {
            name = "Hover",
            children = {
                [100] = {
                    name = "Starboard",
                    maxVol = 100,
                    getVolume = function() return 70 end,
                    getTimeLeft = function() return nil end
                },
                [101] = {
                    name = "Port",
                    maxVol = 400,
                    getVolume = function() return 325 end,
                    getTimeLeft = function() return 100 end
                }
            }
        }
    }
    expectedTanks = {
        {
            name = "Hover", maxVol = 500, vol = 395, timeLeft = 100, children = {
                {name = "Starboard", maxVol = 100, vol = 70},
                {name = "Port", maxVol = 400, vol = 325, timeLeft = 100}
            }
        }
    }
    expectedMaxVol, expectedVol, expectedTimeLeft = 500, 395, 100
    actualTanks, actualMaxVol, actualVol, actualTimeLeft = collectChildData(tanksIn)
    lu.assertItemsEquals(actualTanks, expectedTanks)
    lu.assertEquals(actualMaxVol, expectedMaxVol)
    lu.assertEquals(actualVol, expectedVol)
    lu.assertEquals(actualTimeLeft, expectedTimeLeft)

    -- multiple groups, multiple tanks
    tanksIn = {
        [-1] = {
            name = "Hover",
            children = {
                [100] = {
                    name = "Starboard",
                    maxVol = 100,
                    getVolume = function() return 70 end,
                    getTimeLeft = function() return nil end
                },
                [101] = {
                    name = "Port",
                    maxVol = 400,
                    getVolume = function() return 325 end,
                    getTimeLeft = function() return 100 end
                }
            }
        },
        [-2] = {
            name = "Engine",
            children = {
                [102] = {
                    name = "Starboard",
                    maxVol = 600,
                    getVolume = function() return 500 end,
                    getTimeLeft = function() return 450 end
                },
                [103] = {
                    name = "Port",
                    maxVol = 600,
                    getVolume = function() return 595 end,
                    getTimeLeft = function() return 500 end
                }
            }
        }
    }
    expectedTanks = {
        {
            name = "Hover", maxVol = 500, vol = 395, timeLeft = 100, children = {
                {name = "Starboard", maxVol = 100, vol = 70},
                {name = "Port", maxVol = 400, vol = 325, timeLeft = 100}
            }
        },
        {
            name = "Engine", maxVol = 1200, vol = 1095, timeLeft = 450, children = {
                {name = "Starboard", maxVol = 600, vol = 500, timeLeft = 450},
                {name = "Port", maxVol = 600, vol = 595, timeLeft = 500}
            }
        }
    }
    expectedMaxVol, expectedVol, expectedTimeLeft = 1700, 1490, 100
    actualTanks, actualMaxVol, actualVol, actualTimeLeft = collectChildData(tanksIn)
    lu.assertItemsEquals(actualTanks, expectedTanks)
    lu.assertEquals(actualMaxVol, expectedMaxVol)
    lu.assertEquals(actualVol, expectedVol)
    lu.assertEquals(actualTimeLeft, expectedTimeLeft)

end

os.exit(lu.LuaUnit.run())
