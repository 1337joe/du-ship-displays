#!/usr/bin/env lua
--- Tests for Utilities.

package.path = package.path .. ";../du-mocks/?.lua" -- add du-mocks project

local lu = require("luaunit")

local mockCoreUnit = require("dumocks.CoreUnit")
local mockScreenUnit = require("dumocks.ScreenUnit")
local mockDatabankUnit = require("dumocks.DatabankUnit")
local mockControlUnit = require("dumocks.ControlUnit")

local ut = require("common.Utilities")

_G.TestUtilities = {}

local BIG_PREFIXES = {"", "k", "M", "G", "T", "P", "E", "Z", "Y"}

--- Verify SI unit prefix matches the number of digits for positive values.
function _G.TestUtilities.testPrintableNumberUnits()
    local expected, actual, value, _

    for i=1,30 do
        expected = BIG_PREFIXES[math.min(math.floor(i / 3) + 1, #BIG_PREFIXES)]
        value = math.pow(10, i)
        _,actual = ut.printableNumber(value, "")
        lu.assertEquals(actual, expected, "Prefix for: "..value)
    end
end

--- Verify SI unit prefix matches the number of digits for negative values.
function _G.TestUtilities.testPrintableNumberUnitsNegative()
    local expected, actual, value, _

    for i=1,30 do
        expected = BIG_PREFIXES[math.min(math.floor(i / 3) + 1, #BIG_PREFIXES)]
        value = -math.pow(10, i)
        _,actual = ut.printableNumber(value, "")
        lu.assertEquals(actual, expected, "Prefix for: "..value)
    end
end

--- Verify rounding to prefix boundaries works as expected for positive values.
function _G.TestUtilities.testPrintableNumberUnitsBoundaries()
    local expected, actual, _

    -- no prefix
    expected = ""
    _, actual = ut.printableNumber(0, "")
    lu.assertEquals(actual, expected)
    _, actual = ut.printableNumber(999.4, "")
    lu.assertEquals(actual, expected)

    -- k prefix
    expected = "k"
    _, actual = ut.printableNumber(999.5, "")
    lu.assertEquals(actual, expected)
    _, actual = ut.printableNumber(999499, "")
    lu.assertEquals(actual, expected)

    -- M prefix
    expected = "M"
    _, actual = ut.printableNumber(999500, "")
    lu.assertEquals(actual, expected)
    _, actual = ut.printableNumber(999499999, "")
    lu.assertEquals(actual, expected)
end

--- Verify rounding to prefix boundaries works as expected for negative values.
function _G.TestUtilities.testPrintableNumberUnitsBoundariesNegative()
    local expected, actual, _

    -- no prefix
    expected = ""
    _, actual = ut.printableNumber(-0, "")
    lu.assertEquals(actual, expected)
    _, actual = ut.printableNumber(-999.4, "")
    lu.assertEquals(actual, expected)

    -- k prefix
    expected = "k"
    _, actual = ut.printableNumber(-999.5, "")
    lu.assertEquals(actual, expected)
    _, actual = ut.printableNumber(-999499, "")
    lu.assertEquals(actual, expected)

    -- M prefix
    expected = "M"
    _, actual = ut.printableNumber(-999500, "")
    lu.assertEquals(actual, expected)
    _, actual = ut.printableNumber(-999499999, "")
    lu.assertEquals(actual, expected)
end

--- Verify values are correctly shortened for positive values.
function _G.TestUtilities.testPrintableNumberValuePlain()
    local expected, actual, _

    expected = "1.0"
    actual, _ = ut.printableNumber(1, "")
    lu.assertEquals(actual, expected)

    expected = "10"
    actual, _ = ut.printableNumber(10, "")
    lu.assertEquals(actual, expected)

    expected = "100"
    actual, _ = ut.printableNumber(100, "")
    lu.assertEquals(actual, expected)

    expected = "1.0"
    actual, _ = ut.printableNumber(1000, "")
    lu.assertEquals(actual, expected)

    expected = "10"
    actual, _ = ut.printableNumber(10000, "")
    lu.assertEquals(actual, expected)

    expected = "100"
    actual, _ = ut.printableNumber(100000, "")
    lu.assertEquals(actual, expected)

    expected = "1.0"
    actual, _ = ut.printableNumber(1000000, "")
    lu.assertEquals(actual, expected)

    expected = "10"
    actual, _ = ut.printableNumber(10000000, "")
    lu.assertEquals(actual, expected)

    expected = "100"
    actual, _ = ut.printableNumber(100000000, "")
    lu.assertEquals(actual, expected)
end

--- Verify values are correctly shortened for negative values.
function _G.TestUtilities.testPrintableNumberValuePlainNegative()
    local expected, actual, _

    expected = "-1.0"
    actual, _ = ut.printableNumber(-1, "")
    lu.assertEquals(actual, expected)

    expected = "-10"
    actual, _ = ut.printableNumber(-10, "")
    lu.assertEquals(actual, expected)

    expected = "-100"
    actual, _ = ut.printableNumber(-100, "")
    lu.assertEquals(actual, expected)

    expected = "-1.0"
    actual, _ = ut.printableNumber(-1000, "")
    lu.assertEquals(actual, expected)

    expected = "-10"
    actual, _ = ut.printableNumber(-10000, "")
    lu.assertEquals(actual, expected)

    expected = "-100"
    actual, _ = ut.printableNumber(-100000, "")
    lu.assertEquals(actual, expected)

    expected = "-1.0"
    actual, _ = ut.printableNumber(-1000000, "")
    lu.assertEquals(actual, expected)

    expected = "-10"
    actual, _ = ut.printableNumber(-10000000, "")
    lu.assertEquals(actual, expected)

    expected = "-100"
    actual, _ = ut.printableNumber(-100000000, "")
    lu.assertEquals(actual, expected)
end

--- Verify values are correctly rounded for positive values.
function _G.TestUtilities.testPrintableNumberValueRounded()
    local expected, actual, _

    expected = "9.9"
    actual, _ = ut.printableNumber(9.94, "")
    lu.assertEquals(actual, expected)

    expected = "10"
    actual, _ = ut.printableNumber(9.95, "")
    lu.assertEquals(actual, expected)

    expected = "999"
    actual, _ = ut.printableNumber(999.4, "")
    lu.assertEquals(actual, expected)

    expected = "1.0"
    actual, _ = ut.printableNumber(999.5, "")
    lu.assertEquals(actual, expected)

    expected = "9.9"
    actual, _ = ut.printableNumber(9949, "")
    lu.assertEquals(actual, expected)

    expected = "10"
    actual, _ = ut.printableNumber(9950, "")
    lu.assertEquals(actual, expected)

    expected = "999"
    actual, _ = ut.printableNumber(999499, "")
    lu.assertEquals(actual, expected)

    expected = "1.0"
    actual, _ = ut.printableNumber(999500, "")
    lu.assertEquals(actual, expected)

    expected = "9.9"
    actual, _ = ut.printableNumber(9949999, "")
    lu.assertEquals(actual, expected)

    expected = "10"
    actual, _ = ut.printableNumber(9950000, "")
    lu.assertEquals(actual, expected)
end

--- Verify values are correctly rounded for negative values.
function _G.TestUtilities.testPrintableNumberValueRoundedNegative()
    local expected, actual, _

    expected = "-9.9"
    actual, _ = ut.printableNumber(-9.94, "")
    lu.assertEquals(actual, expected)

    expected = "-10"
    actual, _ = ut.printableNumber(-9.95, "")
    lu.assertEquals(actual, expected)

    expected = "-999"
    actual, _ = ut.printableNumber(-999.4, "")
    lu.assertEquals(actual, expected)

    expected = "-1.0"
    actual, _ = ut.printableNumber(-999.5, "")
    lu.assertEquals(actual, expected)

    expected = "-9.9"
    actual, _ = ut.printableNumber(-9949, "")
    lu.assertEquals(actual, expected)

    expected = "-10"
    actual, _ = ut.printableNumber(-9950, "")
    lu.assertEquals(actual, expected)

    expected = "-999"
    actual, _ = ut.printableNumber(-999499, "")
    lu.assertEquals(actual, expected)

    expected = "-1.0"
    actual, _ = ut.printableNumber(-999500, "")
    lu.assertEquals(actual, expected)

    expected = "-9.9"
    actual, _ = ut.printableNumber(-9949999, "")
    lu.assertEquals(actual, expected)

    expected = "-10"
    actual, _ = ut.printableNumber(-9950000, "")
    lu.assertEquals(actual, expected)
end

--- Verify valid string format strings are not escaped.
function _G.TestUtilities.testSanitizeFormatString()
    local expected, actual, input

    -- non-format strings
    input = "%"
    expected = "%%"
    actual = _G.Utilities.sanitizeFormatString(input)
    lu.assertEquals(actual, expected)

    input = "100%;"
    expected = "100%%;"
    actual = _G.Utilities.sanitizeFormatString(input)
    lu.assertEquals(actual, expected)

    -- simple format strings
    input = "%s"
    expected = "%s"
    actual = _G.Utilities.sanitizeFormatString(input)
    lu.assertEquals(actual, expected)

    input = "%f"
    expected = "%f"
    actual = _G.Utilities.sanitizeFormatString(input)
    lu.assertEquals(actual, expected)

    input = "%d"
    expected = "%d"
    actual = _G.Utilities.sanitizeFormatString(input)
    lu.assertEquals(actual, expected)
end

--- Verify find slot retreives values appropriately.
function _G.TestUtilities.testFindFirstSlot()

    -- create and link a few mocks to a control unit
    local screen1Mock = mockScreenUnit:new(nil, 2)
    local screen1 = screen1Mock:mockGetClosure()

    local screen2Mock = mockScreenUnit:new(nil, 6)
    local screen2 = screen2Mock:mockGetClosure()

    local databankMock = mockDatabankUnit:new(nil, 4)
    local databank = databankMock:mockGetClosure()

    local unitMock = mockControlUnit:new(nil, 5, "programming board")

    unitMock.linkedElements["screen1"] = screen1
    unitMock.linkedElements["screen2"] = screen2
    unitMock.linkedElements["databank"] = databank

    _G.unit = unitMock:mockGetClosure()

    local actual, actualSlot

    -- not found
    actual, actualSlot = _G.Utilities.findFirstSlot("AntiGravityGeneratorUnit")
    lu.assertNil(actual)
    lu.assertNil(actualSlot)

    -- found, single choice
    actual, actualSlot = _G.Utilities.findFirstSlot(databank.getElementClass());
    lu.assertIs(actual, databank)
    lu.assertEquals(actualSlot, "databank")

    -- found: choice of two - slot order does not matter in-game, don't rely on it here
    actual, actualSlot = _G.Utilities.findFirstSlot(screen1.getElementClass());
    lu.assertNotNil(actual)
    lu.assertNotNil(actualSlot)
    lu.assertEquals(actual.getElementClass(), screen1.getElementClass())

    -- fail to find due to exclusion
    actual, actualSlot = _G.Utilities.findFirstSlot(databank.getElementClass(), {databank});
    lu.assertNil(actual)
    lu.assertNil(actualSlot)

    -- find specific due to exclusion
    actual, actualSlot = _G.Utilities.findFirstSlot(screen1.getElementClass(), {screen1});
    lu.assertIs(actual, screen2)
    lu.assertEquals(actualSlot, "screen2")
    actual, actualSlot = _G.Utilities.findFirstSlot(screen1.getElementClass(), {screen2});
    lu.assertIs(actual, screen1)
    lu.assertEquals(actualSlot, "screen1")
end

--- Verify variations on loadSlot function properly with error reporting.
function _G.TestUtilities.testLoadSlot()
    -- create and link a few mocks to a control unit
    local screenMock = mockScreenUnit:new(nil, 2)
    local screen = screenMock:mockGetClosure()

    local coreMock = mockCoreUnit:new(nil, 1)
    local core = coreMock:mockGetClosure()

    local databankMock = mockDatabankUnit:new(nil, 4)
    local databank = databankMock:mockGetClosure()

    local unitMock = mockControlUnit:new(nil, 5, "programming board")

    unitMock.linkedElements["screenSlot"] = screen
    unitMock.linkedElements["coreSlot"] = core
    unitMock.linkedElements["dbSlot"] = databank

    local populatedUnit = unitMock:mockGetClosure()
    local emptyUnit = mockControlUnit:new(nil, 5, "programming board"):mockGetClosure()

    local printOutput
    _G.system = {
        print = function(output)
            printOutput = printOutput .. output .. "\n"
        end
    }

    local provided, targetClass, errorScreen, moduleName, mappedSlotName, optional, optionalMessage
    local actual, errorMsg

    moduleName = "antigrav"

    ----------
    -- test for screen - no error screen provided
    ----------
    targetClass = "ScreenUnit"
    errorScreen = nil
    mappedSlotName = "screen"
    optional = nil
    optionalMessage = nil
    _G.unit = populatedUnit

    -- provided correct link, no output
    printOutput = ""
    actual = _G.Utilities.loadSlot(screen, targetClass, errorScreen, moduleName, mappedSlotName, optional, optionalMessage)
    lu.assertIs(actual, screen)
    lu.assertEquals(printOutput, "")

    -- provided nil, automapping prints mapping result
    printOutput = ""
    actual = _G.Utilities.loadSlot(nil, targetClass, errorScreen, moduleName, mappedSlotName, optional, optionalMessage)
    lu.assertIs(actual, screen)
    lu.assertStrContains(printOutput, "Slot screenSlot mapped to antigrav screen.")

    -- provided nil, automap not found
    _G.unit = emptyUnit
    errorMsg = "antigrav: screen link not found"
    printOutput = ""
    lu.assertErrorMsgContains(errorMsg, _G.Utilities.loadSlot, nil, targetClass, errorScreen, moduleName, mappedSlotName, optional, optionalMessage)

    ----------
    -- test for core - error screen provided
    ----------
    targetClass = "CoreUnitDynamic"
    errorScreen = screen
    mappedSlotName = "core"
    optional = nil
    optionalMessage = nil
    _G.unit = populatedUnit

    -- provided correct link, no output
    printOutput = ""
    actual = _G.Utilities.loadSlot(core, targetClass, errorScreen, moduleName, mappedSlotName, optional, optionalMessage)
    lu.assertIs(actual, core)
    lu.assertEquals(printOutput, "")

    -- provided nil, automapping prints mapping result
    printOutput = ""
    actual = _G.Utilities.loadSlot(nil, targetClass, errorScreen, moduleName, mappedSlotName, optional, optionalMessage)
    lu.assertIs(actual, core)
    lu.assertStrContains(printOutput, "Slot coreSlot mapped to antigrav core.")

    -- provided nil, automap not found
    _G.unit = emptyUnit
    errorMsg = "antigrav: core link not found"
    printOutput = ""
    lu.assertErrorMsgContains(errorMsg, _G.Utilities.loadSlot, nil, targetClass, errorScreen, moduleName, mappedSlotName, optional, optionalMessage)
    -- screen should also have message
    lu.assertStrContains(screenMock.html, errorMsg)

        ----------
    -- test for databank - optional with error screen provided
    ----------
    targetClass = "DataBankUnit"
    errorScreen = screen
    mappedSlotName = "databank"
    optional = true
    optionalMessage = "No databank found, controller state will not persist between sessions."
    _G.unit = populatedUnit

    -- provided correct link, no output
    printOutput = ""
    actual = _G.Utilities.loadSlot(databank, targetClass, errorScreen, moduleName, mappedSlotName, optional, optionalMessage)
    lu.assertIs(actual, databank)
    lu.assertEquals(printOutput, "")

    -- provided nil, automapping prints mapping result
    printOutput = ""
    actual = _G.Utilities.loadSlot(nil, targetClass, errorScreen, moduleName, mappedSlotName, optional, optionalMessage)
    lu.assertIs(actual, databank)
    lu.assertStrContains(printOutput, "Slot dbSlot mapped to antigrav databank.")

    -- provided nil, automap not found
    _G.unit = emptyUnit
    errorMsg = "antigrav: No databank found"
    printOutput = ""
    -- no error, but check for warning message
    _G.Utilities.loadSlot(nil, targetClass, errorScreen, moduleName, mappedSlotName, optional, optionalMessage)
    lu.assertStrContains(printOutput, errorMsg)

    -- provided nil, automap not found, empty optionalMessage so no warning displayed
    _G.unit = emptyUnit
    optionalMessage = nil
    printOutput = ""
    _G.Utilities.loadSlot(nil, targetClass, errorScreen, moduleName, mappedSlotName, optional, optionalMessage)
    lu.assertEquals(printOutput, "")

    -- provided nil, automap not found, empty optionalMessage so no warning displayed
    _G.unit = emptyUnit
    optionalMessage = ""
    printOutput = ""
    _G.Utilities.loadSlot(nil, targetClass, errorScreen, moduleName, mappedSlotName, optional, optionalMessage)
    lu.assertEquals(printOutput, "")
end

--- Verify get preference handles overrides properly.
function _G.TestUtilities.testGetPreference()
    local databankMock = mockDatabankUnit:new(nil, 1)
    local databank = databankMock:mockGetClosure()

    local pref, key, result, expected

    -- no databank, uses proveded default regardless
    key = "key"
    pref = 1
    _G.Utilities.USE_PARAMETER_SETTINGS = true
    result = _G.Utilities.getPreference(nil, key, pref)
    lu.assertEquals(result, pref)

    key = "key"
    pref = "string"
    _G.Utilities.USE_PARAMETER_SETTINGS = false
    result = _G.Utilities.getPreference(nil, key, pref)
    lu.assertEquals(result, pref)

    -- databank but prefer provided
    _G.Utilities.USE_PARAMETER_SETTINGS = true

    key = "key"
    databank.setIntValue(key, 2)
    pref = 1
    result = _G.Utilities.getPreference(databank, key, pref)
    lu.assertEquals(result, pref)
    lu.assertEquals(databank.getIntValue(key), pref)

    key = "key"
    databank.setIntValue(key, 1)
    pref = true
    result = _G.Utilities.getPreference(databank, key, pref)
    lu.assertEquals(result, pref)
    lu.assertEquals(databank.getIntValue(key) == 1, pref)

    key = "key"
    databank.setStringValue(key, "other value")
    pref = "string"
    result = _G.Utilities.getPreference(databank, key, pref)
    lu.assertEquals(result, pref)
    lu.assertEquals(databank.getStringValue(key), pref)

    -- prefer databank
    _G.Utilities.USE_PARAMETER_SETTINGS = false

    key = "key"
    expected = 2
    databank.setIntValue(key, expected)
    pref = 1
    result = _G.Utilities.getPreference(databank, key, pref)
    lu.assertEquals(result, expected)
    lu.assertEquals(databank.getIntValue(key), expected)

    key = "key"
    expected = false
    databank.setIntValue(key, 0)
    pref = true
    result = _G.Utilities.getPreference(databank, key, pref)
    lu.assertEquals(result, expected)
    lu.assertEquals(databank.getIntValue(key) == 0, pref)

    key = "key"
    expected = "other value"
    databank.setStringValue(key, expected)
    pref = "string"
    result = _G.Utilities.getPreference(databank, key, pref)
    lu.assertEquals(result, expected)
    lu.assertEquals(databankMock.data[key], expected)
end

os.exit(lu.LuaUnit.run())
