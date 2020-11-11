#!/usr/bin/env lua
--- Tests for antigravity screen.start.

local lu = require("luaunit")

require("common.ScreenUtils")

_G.TestScreenUtils = {}

--- Verify replace class only replaces where appropriate.
function _G.TestScreenUtils.testReplaceClass()
    local html, oldClass, newClass, expected, actual

    -- doesn't replace in css definitions
    html = [[ .hidden, .unlockSlideClass, .disabledText, .powerSlideClass, .pulsorsText { display: none; }]]
    expected = html
    oldClass = "unlockSlideClass"
    newClass = ""
    actual = _G.ScreenUtils.replaceClass(html, oldClass, newClass)
    lu.assertEquals(actual, expected)

    -- replaces if first in attribute
    html = [[class="unlockSlideClass"]]
    expected = [[class=""]]
    oldClass = "unlockSlideClass"
    newClass = ""
    actual = _G.ScreenUtils.replaceClass(html, oldClass, newClass)
    lu.assertEquals(actual, expected)

    -- replaces if not first in attribute
    html = [[class="label unlockSlideClass"]]
    expected = [[class="label "]]
    oldClass = "unlockSlideClass"
    newClass = ""
    actual = _G.ScreenUtils.replaceClass(html, oldClass, newClass)
    lu.assertEquals(actual, expected)

    -- replaces instead of clear
    html = [[class="unlockSlideClass"]]
    expected = [[class="hidden"]]
    oldClass = "unlockSlideClass"
    newClass = "hidden"
    actual = _G.ScreenUtils.replaceClass(html, oldClass, newClass)
    lu.assertEquals(actual, expected)
end

--- Test bounds and features of detect button.
function _G.TestScreenUtils.testDetectButton()
    -- how close to test to edges
    local epsilon = 0.0001

    local BUTTON_ALTITUDE_UP = "Altitude Up"
    local BUTTON_ALTITUDE_ADJUST_UP = "Altitude Adjust Up"

    local buttonCoordinates = {}
    buttonCoordinates[BUTTON_ALTITUDE_UP] = {
        x1 = 0.1, x2 = 0.3,
        y1 = 0.2, y2 = 0.4
    }
    buttonCoordinates[BUTTON_ALTITUDE_ADJUST_UP] = {
        {
            x1 = 0.3, x2 = 0.35,
            y1 = 0.3, y2 = 0.45
        },
        {
            x1 = 0.3, x2 = 0.35,
            y1 = 0.65, y2 = 0.8
        }
    }
    
    local expectedButton, expectedIndex, actualButton, actualIndex

    -- center of simple button - detects and no index
    expectedButton = BUTTON_ALTITUDE_UP
    actualButton, actualIndex = _G.ScreenUtils.detectButton(buttonCoordinates, 0.2, 0.3)
    lu.assertEquals(actualButton, expectedButton)
    lu.assertNil(actualIndex)

    -- edges of button, inside - detects and no index
    expectedButton = BUTTON_ALTITUDE_UP

    actualButton, actualIndex = _G.ScreenUtils.detectButton(buttonCoordinates, 0.1 + epsilon, 0.3)
    lu.assertEquals(actualButton, expectedButton)
    lu.assertNil(actualIndex)

    actualButton, actualIndex = _G.ScreenUtils.detectButton(buttonCoordinates, 0.3 - epsilon, 0.3)
    lu.assertEquals(actualButton, expectedButton)
    lu.assertNil(actualIndex)

    actualButton, actualIndex = _G.ScreenUtils.detectButton(buttonCoordinates, 0.2, 0.2 + epsilon)
    lu.assertEquals(actualButton, expectedButton)
    lu.assertNil(actualIndex)

    actualButton, actualIndex = _G.ScreenUtils.detectButton(buttonCoordinates, 0.2, 0.4 - epsilon)
    lu.assertEquals(actualButton, expectedButton)
    lu.assertNil(actualIndex)

    -- edges of button, outside - no detect and no index
    expectedButton = nil

    actualButton, actualIndex = _G.ScreenUtils.detectButton(buttonCoordinates, 0.1 - epsilon, 0.3)
    lu.assertNil(actualButton, expectedButton)
    lu.assertNil(actualIndex)

    actualButton, actualIndex = _G.ScreenUtils.detectButton(buttonCoordinates, 0.3 + epsilon, 0.3)
    lu.assertEquals(actualButton, expectedButton)
    lu.assertNil(actualIndex)

    actualButton, actualIndex = _G.ScreenUtils.detectButton(buttonCoordinates, 0.2, 0.2 - epsilon)
    lu.assertEquals(actualButton, expectedButton)
    lu.assertNil(actualIndex)

    actualButton, actualIndex = _G.ScreenUtils.detectButton(buttonCoordinates, 0.2, 0.4 + epsilon)
    lu.assertEquals(actualButton, expectedButton)
    lu.assertNil(actualIndex)

    -- complex button, first index
    expectedButton = BUTTON_ALTITUDE_ADJUST_UP
    expectedIndex = 1
    actualButton, actualIndex = _G.ScreenUtils.detectButton(buttonCoordinates, 0.325, 0.375)
    lu.assertEquals(actualButton, expectedButton)
    lu.assertEquals(actualIndex, expectedIndex)

    -- complex button, second index
    expectedButton = BUTTON_ALTITUDE_ADJUST_UP
    expectedIndex = 2
    actualButton, actualIndex = _G.ScreenUtils.detectButton(buttonCoordinates, 0.325, 0.725)
    lu.assertEquals(actualButton, expectedButton)
    lu.assertEquals(actualIndex, expectedIndex)

    -- complex button, between buttons, no detect
    expectedButton = nil
    expectedIndex = nil
    actualButton, actualIndex = _G.ScreenUtils.detectButton(buttonCoordinates, 0.325, 0.5)
    lu.assertEquals(actualButton, expectedButton)
    lu.assertEquals(actualIndex, expectedIndex)
end

os.exit(lu.LuaUnit.run())
