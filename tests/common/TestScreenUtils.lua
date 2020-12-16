#!/usr/bin/env lua
--- Tests for ScreenUtils.

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

--- Verify add class works as expected.
function _G.TestScreenUtils.testAddClass()
    local html, oldClass, newClass, expected, actual

    -- doesn't modify css definitions
    html = [[ .hidden, .unlockSlideClass, .disabledText, .powerSlideClass, .pulsorsText { display: none; }]]
    expected = html
    oldClass = "unlockSlideClass"
    newClass = "newClass"
    actual = _G.ScreenUtils.addClass(html, oldClass, newClass)
    lu.assertEquals(actual, expected)

    -- adds if first in attribute
    html = [[class="unlockSlideClass"]]
    expected = [[class="unlockSlideClass newClass"]]
    oldClass = "unlockSlideClass"
    newClass = "newClass"
    actual = _G.ScreenUtils.addClass(html, oldClass, newClass)
    lu.assertEquals(actual, expected)

    -- adds if not first in attribute
    html = [[class="label unlockSlideClass"]]
    expected = [[class="label unlockSlideClass newClass"]]
    oldClass = "unlockSlideClass"
    newClass = "newClass"
    actual = _G.ScreenUtils.addClass(html, oldClass, newClass)
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
        x1 = 0.1,
        x2 = 0.3,
        y1 = 0.2,
        y2 = 0.4
    }
    buttonCoordinates[BUTTON_ALTITUDE_ADJUST_UP] = {{
        x1 = 0.3,
        x2 = 0.35,
        y1 = 0.3,
        y2 = 0.45
    }, {
        x1 = 0.3,
        x2 = 0.35,
        y1 = 0.65,
        y2 = 0.8
    }}

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

--- Test activation of mouseover buttons detect/highlight.
function _G.TestScreenUtils.testMouseoverButtons()
    local BUTTON_ALTITUDE_UP = "Altitude Up"
    local BUTTON_ALTITUDE_ADJUST_UP = "Altitude Adjust Up"

    local buttonCoordinates = {}
    buttonCoordinates[BUTTON_ALTITUDE_UP] = {
        x1 = 0.1,
        x2 = 0.3,
        y1 = 0.2,
        y2 = 0.4,
        class = "altitudeUpClass"
    }
    buttonCoordinates[BUTTON_ALTITUDE_ADJUST_UP] = {
        {
            x1 = 0.3,
            x2 = 0.35,
            y1 = 0.3,
            y2 = 0.45
        },
        {
            x1 = 0.3,
            x2 = 0.35,
            y1 = 0.65,
            y2 = 0.8
        },
        class = "adjustUpClass"
    }

    local expectedHtml, actualHtml
    local htmlIn = [[
    <g class="adjustmentWidgets">
        <g class="altitude">
            <use xlink:href="#altitudeUp" x="384" y="324" class="altitudeUpClass" />
        </g>
        <g class="adjust">
            <use x="576" y="405" xlink:href="#adjustUp" class="adjustUpClass1"/>
            <use x="576" y="783" xlink:href="#adjustUp" class="adjustUpClass2" />
        </g>
    </g>
    ]]
    local mouseover = "mouseover"

    -- outside of buttons, no change
    expectedHtml = htmlIn
    actualHtml = _G.ScreenUtils.mouseoverButtons(buttonCoordinates, 0, 0, htmlIn, mouseover)
    lu.assertEquals(actualHtml, expectedHtml)

    -- center of simple button - detects and no index
    expectedHtml = [[
    <g class="adjustmentWidgets">
        <g class="altitude">
            <use xlink:href="#altitudeUp" x="384" y="324" class="mouseover" />
        </g>
        <g class="adjust">
            <use x="576" y="405" xlink:href="#adjustUp" class="adjustUpClass1"/>
            <use x="576" y="783" xlink:href="#adjustUp" class="adjustUpClass2" />
        </g>
    </g>
    ]]
    actualHtml = _G.ScreenUtils.mouseoverButtons(buttonCoordinates, 0.2, 0.3, htmlIn, mouseover)
    lu.assertEquals(actualHtml, expectedHtml)

    -- center of simple button, class not found, no change
    expectedHtml = [[
    <g class="adjustmentWidgets">
        <g class="altitude">
            <use xlink:href="#altitudeUp" x="384" y="324" class="selected" />
        </g>
        <g class="adjust">
            <use x="576" y="405" xlink:href="#adjustUp" class="adjustUpClass1"/>
            <use x="576" y="783" xlink:href="#adjustUp" class="adjustUpClass2" />
        </g>
    </g>
    ]]
    actualHtml = _G.ScreenUtils.mouseoverButtons(buttonCoordinates, 0.2, 0.3, expectedHtml, mouseover)
    lu.assertEquals(actualHtml, expectedHtml)

    -- complex button, first index
    expectedHtml = [[
    <g class="adjustmentWidgets">
        <g class="altitude">
            <use xlink:href="#altitudeUp" x="384" y="324" class="altitudeUpClass" />
        </g>
        <g class="adjust">
            <use x="576" y="405" xlink:href="#adjustUp" class="mouseover"/>
            <use x="576" y="783" xlink:href="#adjustUp" class="adjustUpClass2" />
        </g>
    </g>
    ]]
    actualHtml = _G.ScreenUtils.mouseoverButtons(buttonCoordinates, 0.325, 0.375, htmlIn, mouseover)
    lu.assertEquals(actualHtml, expectedHtml)

    -- complex button, second index
    expectedHtml = [[
    <g class="adjustmentWidgets">
        <g class="altitude">
            <use xlink:href="#altitudeUp" x="384" y="324" class="altitudeUpClass" />
        </g>
        <g class="adjust">
            <use x="576" y="405" xlink:href="#adjustUp" class="adjustUpClass1"/>
            <use x="576" y="783" xlink:href="#adjustUp" class="mouseover" />
        </g>
    </g>
    ]]
    actualHtml = _G.ScreenUtils.mouseoverButtons(buttonCoordinates, 0.325, 0.725, htmlIn, mouseover)
    lu.assertEquals(actualHtml, expectedHtml)
end

os.exit(lu.LuaUnit.run())
