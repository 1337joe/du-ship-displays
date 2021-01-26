--- Run first, define agScreenController basic functionality: SVG-specific definitions and functions are not included.

-- Guard to keep this module from reinitializing any time the start event fires.
if _G.hpScreenController then
    return
end

-- constants and editable lua script parameters

local SHOW_HEALTHY_KEY = "HP.screen:SHOW_HEALTHY"
local SHOW_HEALTHY_DEFAULT = true
local SHOW_DAMAGED_KEY = "HP.screen:SHOW_DAMAGED"
local SHOW_DAMAGED_DEFAULT = true
local SHOW_BROKEN_KEY = "HP.screen:SHOW_BROKEN"
local SHOW_BROKEN_DEFAULT = true
local SELECTED_TAB_KEY = "HP.screen:SELECTED_TAB"
local SELECTED_TAB_DEFAULT = 1
local SCROLL_INDEX_KEY = "HP.screen:SCROLL_INDEX"
local SCROLL_INDEX_DEFAULT = 1
local STRECH_CLOUD_KEY = "HP.screen:STRETCH_CLOUD"
local STRETCH_CLOUD_DEFAULT = false
local MAXIMIZE_CLOUD_KEY = "HP.screen:MAXIMIZE_CLOUD"
local MAXIMIZE_CLOUD_DEFAULT = false

-- constants for svg file
local HEALTHY_CLASS = "healthy"
local DAMAGED_CLASS = "damaged"
local BROKEN_CLASS = "broken"
local SELECTED_CLASS = "selected"
local HIDDEN_CLASS = "hidden"
local MOUSE_OVER_CLASS = "mouseOver"
local ELEMENT_TITLE_COLOR_CLASS = "titleColor"
local ELEMENT_FILTER_HEALTHY_CLASS = "healthyFilterClass"
local ELEMENT_FILTER_DAMAGED_CLASS = "damagedFilterClass"
local ELEMENT_FILTER_BROKEN_CLASS = "brokenFilterClass"
local ELEMENT_COUNT_DAMAGED_CLASS = "damagedCountClass"
local ELEMENT_COUNT_HEALTHY_CLASS = "healthyCountClass"
local ELEMENT_COUNT_BROKEN_CLASS = "brokenCountClass"
local ELEMENT_TABLE_CLASS = "tableClass"
local ELEMENT_TOP_CLASS = "topClass"
local ELEMENT_SIDE_CLASS = "sideClass"
local ELEMENT_FRONT_CLASS = "frontClass"
local ELEMENT_HIDDEN_TABLE_INTERFACE = "hiddenTableInterface"
local ELEMENT_TABLE_INTERFACE = "tableInterface"
local ELEMENT_SORT_ID_CLASS = "sortIdClass"
local ELEMENT_SORT_NAME_CLASS = "sortNameClass"
local ELEMENT_SORT_DMG_CLASS = "sortDmgClass"
local ELEMENT_SORT_MAX_CLASS = "sortMaxClass"
local ELEMENT_SORT_INT_CLASS = "sortIntClass"
local ELEMENT_SKIP_UP_CLASS = "skipUpClass"
local ELEMENT_SCROLL_UP_CLASS = "scrollUpClass"
local ELEMENT_SCROLL_DOWN_CLASS = "scrollDownClass"
local ELEMENT_SKIP_DOWN_CLASS = "skipDownClass"
local ELEMENT_HIDDEN_CLOUD_BUTTONS = "hiddenCloudButtonBar"
local ELEMENT_CLOUD_BUTTONS = "cloudButtonBar"
local ELEMENT_CLOUD_STRETCH = "stretchClass"
local ELEMENT_CLOUD_PRESERVE = "preserveClass"
local ELEMENT_CLOUD_MAXIMIZE = "maximizeClass"
local ELEMENT_CLOUD_MINIMIZE = "minimizeClass"
local ELEMENT_HIDE_INTERFACE = "hideInterface"

local TAB_CONTENTS_WIDTH = 1152
local TAB_CONTENTS_HEIGHT = 891

local TAB_CONTENTS_TAG = [[<svg id="tabContents"/>]]
local MAXIMIZED_CONTENTS_TAG = [[<svg id="maximizedContents"/>]]

-- initialize object and fields
_G.hpScreenController = {
    mouse = {
        x = -1,
        y = -1,
        pressed = nil,
        state = false,
        over = nil
    },
    needRefresh = false,
}

-- constant button definition labels
_G.hpScreenController.BUTTON_FILTER_HEALTHY = "Filter: Healthy"
_G.hpScreenController.BUTTON_FILTER_DAMAGED = "Filter: Damaged"
_G.hpScreenController.BUTTON_FILTER_BROKEN = "Filter: Broken"
_G.hpScreenController.BUTTON_TAB_TABLE = "Tab: Table"
_G.hpScreenController.BUTTON_TAB_TOP = "Tab: Top"
_G.hpScreenController.BUTTON_TAB_SIDE = "Tab: Side"
_G.hpScreenController.BUTTON_TAB_FRONT = "Tab: Front"
_G.hpScreenController.BUTTON_SORT_ID = "Table: Sort Id"
_G.hpScreenController.BUTTON_SORT_NAME = "Table: Sort Name"
_G.hpScreenController.BUTTON_SORT_DMG = "Table: Sort Dmg"
_G.hpScreenController.BUTTON_SORT_MAX = "Table: Sort Max"
_G.hpScreenController.BUTTON_SORT_INT = "Table: Sort Int"
_G.hpScreenController.BUTTON_SKIP_UP = "Table: Skip Up"
_G.hpScreenController.BUTTON_SCROLL_UP = "Table: Scroll Up"
_G.hpScreenController.BUTTON_SCROLL_DOWN = "Table: Scroll Down"
_G.hpScreenController.BUTTON_SKIP_DOWN = "Table: Skip Down"
_G.hpScreenController.BUTTON_STRETCH_CLOUD = "Cloud: Stretch"
_G.hpScreenController.BUTTON_MAXIMIZE_CLOUD = "Cloud: Maximize"

-- add SVG-specific fields
_G.hpScreenController.SVG_TEMPLATE = [[${file:hp.screen.basic.svg}]]
_G.hpScreenController.SVG_LOGO = [[${file:../logo.svg minify}]]

-- one-time transforms
_G.hpScreenController.SVG_TEMPLATE = string.gsub(_G.hpScreenController.SVG_TEMPLATE, '<svg id="logo"/>',
                                         _G.hpScreenController.SVG_LOGO)

-- Define button ranges, either in tables of x1,y1,x2,y2 or lists of those tables.
local buttonCoordinates = {}
buttonCoordinates[_G.hpScreenController.BUTTON_FILTER_HEALTHY] = {
    x1 = 0, x2 = 0.2,
    y1 = 0.7, y2 = 0.8,
    class = ELEMENT_FILTER_HEALTHY_CLASS
}
buttonCoordinates[_G.hpScreenController.BUTTON_FILTER_DAMAGED] = {
    x1 = 0, x2 = 0.2,
    y1 = 0.8, y2 = 0.9,
    class = ELEMENT_FILTER_DAMAGED_CLASS
}
buttonCoordinates[_G.hpScreenController.BUTTON_FILTER_BROKEN] = {
    x1 = 0, x2 = 0.2,
    y1 = 0.9, y2 = 1.0,
    class = ELEMENT_FILTER_BROKEN_CLASS
}
buttonCoordinates[_G.hpScreenController.BUTTON_TAB_TABLE] = {
    x1 = 0.433, x2 = 0.567,
    y1 = 0.1, y2 = 0.169,
    class = ELEMENT_TABLE_CLASS
}
buttonCoordinates[_G.hpScreenController.BUTTON_TAB_TOP] = {
    x1 = 0.567, x2 = 0.7,
    y1 = 0.1, y2 = 0.169,
    class = ELEMENT_TOP_CLASS
}
buttonCoordinates[_G.hpScreenController.BUTTON_TAB_SIDE] = {
    x1 = 0.7, x2 = 0.833,
    y1 = 0.1, y2 = 0.169,
    class = ELEMENT_SIDE_CLASS
}
buttonCoordinates[_G.hpScreenController.BUTTON_TAB_FRONT] = {
    x1 = 0.833, x2 = 0.967,
    y1 = 0.1, y2 = 0.169,
    class = ELEMENT_FRONT_CLASS
}
buttonCoordinates[_G.hpScreenController.BUTTON_SORT_ID] = {
    x1 = 0.4, x2 = 0.457,
    y1 = 0.175, y2 = 0.235,
    class = ELEMENT_SORT_ID_CLASS
}
buttonCoordinates[_G.hpScreenController.BUTTON_SORT_NAME] = {
    x1 = 0.457, x2 = 0.76,
    y1 = 0.175, y2 = 0.235,
    class = ELEMENT_SORT_NAME_CLASS
}
buttonCoordinates[_G.hpScreenController.BUTTON_SORT_DMG] = {
    x1 = 0.76, x2 = 0.841,
    y1 = 0.175, y2 = 0.235,
    class = ELEMENT_SORT_DMG_CLASS
}
buttonCoordinates[_G.hpScreenController.BUTTON_SORT_MAX] = {
    x1 = 0.841, x2 = 0.919,
    y1 = 0.175, y2 = 0.235,
    class = ELEMENT_SORT_MAX_CLASS
}
buttonCoordinates[_G.hpScreenController.BUTTON_SORT_INT] = {
    x1 = 0.919, x2 = 0.972,
    y1 = 0.175, y2 = 0.235,
    class = ELEMENT_SORT_INT_CLASS
}
buttonCoordinates[_G.hpScreenController.BUTTON_SKIP_UP] = {
    x1 = 0.972, x2 = 1.0,
    y1 = 0.235, y2 = 0.285,
    class = ELEMENT_SKIP_UP_CLASS
}
buttonCoordinates[_G.hpScreenController.BUTTON_SCROLL_UP] = {
    x1 = 0.972, x2 = 1.0,
    y1 = 0.285, y2 = 0.335,
    class = ELEMENT_SCROLL_UP_CLASS
}
buttonCoordinates[_G.hpScreenController.BUTTON_SCROLL_DOWN] = {
    x1 = 0.972, x2 = 1.0,
    y1 = 0.90, y2 = 0.95,
    class = ELEMENT_SCROLL_DOWN_CLASS
}
buttonCoordinates[_G.hpScreenController.BUTTON_SKIP_DOWN] = {
    x1 = 0.972, x2 = 1.0,
    y1 = 0.95, y2 = 1.0,
    class = ELEMENT_SKIP_DOWN_CLASS
}
buttonCoordinates[_G.hpScreenController.BUTTON_STRETCH_CLOUD] = {
    x1 = 0.8875, x2 = 0.94375,
    y1 = 0.9, y2 = 1.0,
    class = {ELEMENT_CLOUD_STRETCH, ELEMENT_CLOUD_PRESERVE}
}
buttonCoordinates[_G.hpScreenController.BUTTON_MAXIMIZE_CLOUD] = {
    x1 = 0.94375, x2 = 1.0,
    y1 = 0.9, y2 = 1.0,
    class = {ELEMENT_CLOUD_MAXIMIZE, ELEMENT_CLOUD_MINIMIZE}
}
-- save to controller for press/release event handling
_G.hpScreenController.buttonCoordinates = buttonCoordinates

function _G.hpScreenController:init(controller)
    self.controller = controller
    self.screen = controller.slots.screen
    self.databank = controller.slots.databank

    if not (self.databank and self.databank.hasKey(SHOW_HEALTHY_KEY) == 1) then
        self.showHealthy = SHOW_HEALTHY_DEFAULT
    end
    if not (self.databank and self.databank.hasKey(SHOW_DAMAGED_KEY) == 1) then
        self.showDamaged = SHOW_DAMAGED_DEFAULT
    end
    if not (self.databank and self.databank.hasKey(SHOW_BROKEN_KEY) == 1) then
        self.showBroken = SHOW_BROKEN_DEFAULT
    end

    if not (self.databank and self.databank.hasKey(SELECTED_TAB_KEY) == 1) then
        self:setSelectedTab(SELECTED_TAB_DEFAULT)
    end
    if not (self.databank and self.databank.hasKey(STRECH_CLOUD_KEY) == 1) then
        self.stretchCloud = STRETCH_CLOUD_DEFAULT
    end
    if not (self.databank and self.databank.hasKey(MAXIMIZE_CLOUD_KEY) == 1) then
        self.maximizeCloud = MAXIMIZE_CLOUD_DEFAULT
    end
end

--- Handle a mouse down event at the provided coordinates.
function _G.hpScreenController:mouseDown(x, y)
    self.mouse.x = x
    self.mouse.y = y
    self.mouse.pressed = _G.ScreenUtils.detectButton(self.buttonCoordinates, x, y)
end

--- Handle a mouse up event at the provided coordinates.
function _G.hpScreenController:mouseUp(x, y)
    local released = _G.ScreenUtils.detectButton(self.buttonCoordinates, x, y)
    if released and self.mouse.pressed == released then
        local modified = self:handleButton(released)
        self.needRefresh = self.needRefresh or modified
    end
    self.mouse.pressed = nil
end

function _G.hpScreenController:setSelectedTab(tabIndex)
    if tabIndex == self.selectedTab then
        return false
    end

    self.selectedTab = tabIndex
    if self.databank then
        self.databank.setIntValue(SELECTED_TAB_KEY, tabIndex)
    end
    self.tabData = {}
    self.tabInitialized = false

    if tabIndex == 1 then -- Table

    elseif tabIndex == 2 then -- Top
        local screenXFunc = function(pos)
            return pos.x
        end
        local screenYFunc = function(pos)
            return -pos.y
        end
        local template, points = _G.buildShipCloudPoints(self.outlineTop, self.controller.elementData,
                                     self.controller.elementMetadata, screenXFunc, screenYFunc)
        self.tabData.template = template
        self.tabData.points = points

        self.tabInitialized = true
    elseif tabIndex == 3 then -- Side
        local screenXFunc = function(pos)
            return pos.y
        end
        local screenYFunc = function(pos)
            return -pos.z
        end
        local template, points = _G.buildShipCloudPoints(self.outlineSide, self.controller.elementData,
                                     self.controller.elementMetadata, screenXFunc, screenYFunc)
        self.tabData.template = template
        self.tabData.points = points

        self.tabInitialized = true
    elseif tabIndex == 4 then -- Front
        local screenXFunc = function(pos)
            return pos.x
        end
        local screenYFunc = function(pos)
            return -pos.z
        end
        local template, points = _G.buildShipCloudPoints(self.outlineFront, self.controller.elementData,
                                     self.controller.elementMetadata, screenXFunc, screenYFunc)
        self.tabData.template = template
        self.tabData.points = points

        self.tabInitialized = true
    end

    return true
end

--- Render the interface to the screen.
function _G.hpScreenController:refresh()
    if not self.screen then
        return
    end

    -- update mouse position for tracking drags
    self.mouse.x = self.screen.getMouseX()
    self.mouse.y = self.screen.getMouseY()
    self.mouse.state = self.screen.getMouseState() == 1
    -- if mouse has left screen remove pressed flag
    if self.mouse.x < 0 then
        self.mouse.pressed = nil
    end

    local mouseOver = _G.ScreenUtils.detectButton(self.buttonCoordinates, self.mouse.x, self.mouse.y)

    -- refresh conditions: needRefresh, mouse-over state changed
    if not (self.needRefresh or self.mouse.over ~= mouseOver) then
        return
    end
    self.needRefresh = false
    -- self.mouse.over = mouseOver

    if self.databank and self.databank.hasKey(SHOW_HEALTHY_KEY) == 1 then
        self.showHealthy = self.databank.getIntValue(SHOW_HEALTHY_KEY) == 1
    end
    if self.databank and self.databank.hasKey(SHOW_DAMAGED_KEY) == 1 then
        self.showDamaged = self.databank.getIntValue(SHOW_DAMAGED_KEY) == 1
    end
    if self.databank and self.databank.hasKey(SHOW_BROKEN_KEY) == 1 then
        self.showBroken = self.databank.getIntValue(SHOW_BROKEN_KEY) == 1
    end

    if self.databank and self.databank.getIntValue(SELECTED_TAB_KEY) ~= self.selectedTab then
        self:setSelectedTab(self.databank.getIntValue(SELECTED_TAB_KEY))
    end

    if self.databank and self.databank.hasKey(STRECH_CLOUD_KEY) == 1 then
        self.stretchCloud = self.databank.getIntValue(STRECH_CLOUD_KEY) == 1
    end
    if self.databank and self.databank.hasKey(MAXIMIZE_CLOUD_KEY) == 1 then
        self.maximizeCloud = self.databank.getIntValue(MAXIMIZE_CLOUD_KEY) == 1
    end

    local html = self.SVG_TEMPLATE

    -- extract values to show in svg
    local elementData = self.controller.elementData
    local elementMetadata = self.controller.elementMetadata

    local shipName = self.controller.shipName
    local elementIntegrity = math.floor(elementMetadata.totalHp / elementMetadata.totalMaxHp * 100)
    local currentHp = elementMetadata.totalHp
    local maxHp = elementMetadata.totalMaxHp
    local healthyElements = 0
    local damagedElements = 0
    local brokenElements = 0
    for _, element in pairs(self.controller.elementData) do
        if element.h == element.m then
            healthyElements = healthyElements + 1
        elseif element.h > 0 then
            damagedElements = damagedElements + 1
        else
            brokenElements = brokenElements + 1
        end
    end

    -- insert values to svg
    html = _G.Utilities.sanitizeFormatString(html)
    html = string.format(html, shipName, elementIntegrity, currentHp, maxHp, healthyElements, damagedElements,
               brokenElements)

    if brokenElements > 0 then
        html = _G.ScreenUtils.replaceClass(html, ELEMENT_TITLE_COLOR_CLASS, BROKEN_CLASS)
    elseif damagedElements > 0 then
        html = _G.ScreenUtils.replaceClass(html, ELEMENT_TITLE_COLOR_CLASS, DAMAGED_CLASS)
    else
        html = _G.ScreenUtils.replaceClass(html, ELEMENT_TITLE_COLOR_CLASS, HEALTHY_CLASS)
    end

    if brokenElements > 0 then
        html = _G.ScreenUtils.addClass(html, ELEMENT_FILTER_BROKEN_CLASS, BROKEN_CLASS)
    end
    if damagedElements > 0 then
        html = _G.ScreenUtils.addClass(html, ELEMENT_FILTER_DAMAGED_CLASS, DAMAGED_CLASS)
    end
    if healthyElements > 0 then
        html = _G.ScreenUtils.addClass(html, ELEMENT_FILTER_HEALTHY_CLASS, HEALTHY_CLASS)
    end

    if self.showHealthy then
        html = _G.ScreenUtils.addClass(html, ELEMENT_FILTER_HEALTHY_CLASS, SELECTED_CLASS)
        html = _G.ScreenUtils.addClass(html, ELEMENT_COUNT_HEALTHY_CLASS, SELECTED_CLASS)
    end
    if self.showDamaged then
        html = _G.ScreenUtils.addClass(html, ELEMENT_FILTER_DAMAGED_CLASS, SELECTED_CLASS)
        html = _G.ScreenUtils.addClass(html, ELEMENT_COUNT_DAMAGED_CLASS, SELECTED_CLASS)
    end
    if self.showBroken then
        html = _G.ScreenUtils.addClass(html, ELEMENT_FILTER_BROKEN_CLASS, SELECTED_CLASS)
        html = _G.ScreenUtils.addClass(html, ELEMENT_COUNT_BROKEN_CLASS, SELECTED_CLASS)
    end

    -- if initializing tab in background say so?

    -- replacing class on tab intentionally prevents mousing over it from working
    local tabContents = TAB_CONTENTS_TAG
    if self.selectedTab == 1 then
        html = _G.ScreenUtils.replaceClass(html, ELEMENT_TABLE_CLASS, SELECTED_CLASS)

        -- enable table header
        html = _G.ScreenUtils.replaceClass(html, ELEMENT_HIDDEN_TABLE_INTERFACE, ELEMENT_TABLE_INTERFACE)

        tabContents = buildTable(self.controller.elementData, 1, 0, true, self.controller.selectedElement, self.showHealthy, self.showDamaged, self.showBroken)
    elseif self.selectedTab == 2 or self.selectedTab == 3 or self.selectedTab == 4 then
        tabContents = updateCloud(self.tabData.template, self.tabData.points, self.controller.elementData,
                          self.controller.selectedElement, self.showHealthy, self.showDamaged, self.showBroken)

        -- enable cloud button bar
        html = _G.ScreenUtils.replaceClass(html, ELEMENT_HIDDEN_CLOUD_BUTTONS, ELEMENT_CLOUD_BUTTONS)

        if self.selectedTab == 2 then
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_TOP_CLASS, SELECTED_CLASS)
        elseif self.selectedTab == 3 then
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_SIDE_CLASS, SELECTED_CLASS)
            tabContents = updateCloud(self.tabData.template, self.tabData.points, self.controller.elementData,
                              self.controller.selectedElement, self.showHealthy, self.showDamaged, self.showBroken)
        elseif self.selectedTab == 4 then
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_FRONT_CLASS, SELECTED_CLASS)
            tabContents = updateCloud(self.tabData.template, self.tabData.points, self.controller.elementData,
                              self.controller.selectedElement, self.showHealthy, self.showDamaged, self.showBroken)
        end

        -- manage button states
        if self.stretchCloud then
            tabContents = string.gsub(tabContents, "(<svg.-)>", [[%1 preserveAspectRatio="none">]])
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLOUD_STRETCH, HIDDEN_CLASS)
        else
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLOUD_PRESERVE, HIDDEN_CLASS)
        end

        if self.maximizeCloud then
            tabContents = string.gsub(tabContents, "(<svg.-)>",
                              string.format([[%%1 width="%f" height="%f">]], 1920, 1080))
            html = string.gsub(html, MAXIMIZED_CONTENTS_TAG, tabContents)
            tabContents = ""

            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLOUD_MAXIMIZE, HIDDEN_CLASS)
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_HIDE_INTERFACE, "")
        else
            tabContents = string.gsub(tabContents, "(<svg.-)>", string.format([[%%1 width="%f" height="%f">]],
                              TAB_CONTENTS_WIDTH, TAB_CONTENTS_HEIGHT))

            html = _G.ScreenUtils.replaceClass(html, ELEMENT_CLOUD_MINIMIZE, HIDDEN_CLASS)
        end

    end
    html = string.gsub(html, TAB_CONTENTS_TAG, tabContents)

    -- add mouse-over highlights
    if not self.mouse.pressed then
        html = _G.ScreenUtils.mouseoverButtons(self.buttonCoordinates, self.mouse.x, self.mouse.y, html,
                   MOUSE_OVER_CLASS)
    end

    self.screen.setHTML(html)
end

--- Processes the input indicated by the provided button id.
-- @treturn boolean True if the state was changed by this action.
function _G.hpScreenController:handleButton(buttonId)
    local modified = false

    if buttonId == _G.hpScreenController.BUTTON_FILTER_HEALTHY then
        self.showHealthy = not self.showHealthy
        if self.databank then
            if self.showHealthy then
                self.databank.setIntValue(SHOW_HEALTHY_KEY, 1)
            else
                self.databank.setIntValue(SHOW_HEALTHY_KEY, 0)
            end
        end
        modified = true
    elseif buttonId == _G.hpScreenController.BUTTON_FILTER_DAMAGED then
        self.showDamaged = not self.showDamaged
        if self.databank then
            if self.showDamaged then
                self.databank.setIntValue(SHOW_DAMAGED_KEY, 1)
            else
                self.databank.setIntValue(SHOW_DAMAGED_KEY, 0)
            end
        end
        modified = true
    elseif buttonId == _G.hpScreenController.BUTTON_FILTER_BROKEN then
        self.showBroken = not self.showBroken
        if self.databank then
            if self.showBroken then
                self.databank.setIntValue(SHOW_BROKEN_KEY, 1)
            else
                self.databank.setIntValue(SHOW_BROKEN_KEY, 0)
            end
        end
        modified = true

    elseif buttonId == _G.hpScreenController.BUTTON_TAB_TABLE then
        modified = self:setSelectedTab(1)
    elseif buttonId == _G.hpScreenController.BUTTON_TAB_TOP then
        modified = self:setSelectedTab(2)
    elseif buttonId == _G.hpScreenController.BUTTON_TAB_SIDE then
        modified = self:setSelectedTab(3)
    elseif buttonId == _G.hpScreenController.BUTTON_TAB_FRONT then
        modified = self:setSelectedTab(4)

    elseif buttonId == _G.hpScreenController.BUTTON_SORT_ID then
        -- TODO
    elseif buttonId == _G.hpScreenController.BUTTON_SORT_NAME then
        -- TODO
    elseif buttonId == _G.hpScreenController.BUTTON_SORT_DMB then
        -- TODO
    elseif buttonId == _G.hpScreenController.BUTTON_SORT_MAX then
        -- TODO
    elseif buttonId == _G.hpScreenController.BUTTON_SORT_INT then
        -- TODO

    elseif buttonId == _G.hpScreenController.BUTTON_SKIP_UP then
        -- TODO
    elseif buttonId == _G.hpScreenController.BUTTON_SKIP_DOWN then
        -- TODO
    elseif buttonId == _G.hpScreenController.BUTTON_SCROLL_UP then
        -- TODO
    elseif buttonId == _G.hpScreenController.BUTTON_SCROLL_DOWN then
        -- TODO

    elseif buttonId == _G.hpScreenController.BUTTON_STRETCH_CLOUD and self.selectedTab > 1 then
        self.stretchCloud = not self.stretchCloud
        if self.databank then
            if self.stretchCloud then
                self.databank.setIntValue(STRECH_CLOUD_KEY, 1)
            else
                self.databank.setIntValue(STRECH_CLOUD_KEY, 0)
            end
        end
        modified = true
    elseif buttonId == _G.hpScreenController.BUTTON_MAXIMIZE_CLOUD and self.selectedTab > 1 then
        self.maximizeCloud = not self.maximizeCloud
        if self.databank then
            if self.maximizeCloud then
                self.databank.setIntValue(MAXIMIZE_CLOUD_KEY, 1)
            else
                self.databank.setIntValue(MAXIMIZE_CLOUD_KEY, 0)
            end
        end
        modified = true
    end

    return modified
end

local TABLE_ROW_BASE_OFFSET = 65 -- height of heading
-- Use nth-child css selector on .tableRow to style row elements
local TABLE_ROW_TEMPLATE = [[
<g class="tableRow %s" transform="translate(0,%.0f)">
<text x="100">%d</text>
<text x="120">%s</text>
<text x="796">%s</text>
<text x="796">%s</text>
<text x="946">%s</text>
<text x="946">%s</text>
<text x="1081">%d</text>
</g>
]]
function _G.buildTable(elementData, index, sortColumn, sortDown, selectedId, showHealthy, showDamaged, showBroken)
    local table = [[<g id="tableContents">]]

    local rowIndex = 0
    local hp, max, selected, yOffset, hpPrint, hpUnit, maxPrint, maxUnit
    for id, data in pairs(elementData) do
        hp = data.h
        max = data.m
        yOffset = TABLE_ROW_BASE_OFFSET + 40 * (rowIndex + 1)

        if yOffset > 891 then
            break
        end

        if id == selectedId then
            selected = "selected"
        else
            selected = ""
        end

        hpPrint, hpUnit = Utilities.printableNumber(math.floor(max - hp + 0.5), "")
        if hpPrint == "0.0" then
            hpPrint = "0"
        end
        maxPrint, maxUnit = Utilities.printableNumber(max, "")

        if (hp == 0 and showBroken) or (hp > 0 and hp < max and showDamaged) or (hp == max and showHealthy) then
            table = table .. string.format(TABLE_ROW_TEMPLATE, selected, yOffset, id, data.n, hpPrint, hpUnit, maxPrint, maxUnit, math.floor(100 * hp / max + 0.5))
            rowIndex = rowIndex + 1
        end
    end

    table = table .. [[</g>]]
    return table
end

local CLOUD_REPLACE_TARGET = [[<g id="pointCloud"%s*/>]]
local DEFAULT_OUTLINE = [[
<svg viewBox="%f %f %f %f" scaleMultiplier="%d">
    <style>
    circle {
        stroke: black;
        stroke-width: 1vmin;
    }
    .selected {
        stroke: white;
    }
    </style>
    <g>
        <g id="pointCloud" />
    </g>
</svg>
]]
local HEALTH_GROUP_TEMPLATE = [[<g class="%s">%s</g>]]
-- TODO make coroutine
local CLOUD_ELEMENT_TEMPLATE = [[<circle cx="%.2f" cy="%.2f" r="%.2f"/>]]
function _G.buildShipCloudPoints(outline, elementData, elementMetadata, screenXFunc, screenYFunc)
    if not outline then
        local scale = 100
        local buffer = 0.05 -- 5% extra per side
        local metaX1 = screenXFunc(elementMetadata.min)
        local metaX2 = screenXFunc(elementMetadata.max)
        local metaMinX = math.min(metaX1, metaX2)
        local metaMaxX = math.max(metaX1, metaX2)
        local metaY1 = screenYFunc(elementMetadata.min)
        local metaY2 = screenYFunc(elementMetadata.max)
        local metaMinY = math.min(metaY1, metaY2)
        local metaMaxY = math.max(metaY1, metaY2)
        local minX = (metaMinX - (metaMaxX - metaMinX) * buffer) * scale
        local minY = (metaMinY - (metaMaxY - metaMinY) * buffer) * scale
        local maxX = (metaMaxX + (metaMaxX - metaMinX) * buffer) * scale
        local maxY = (metaMaxY + (metaMaxY - metaMinY) * buffer) * scale
        local width = maxX - minX
        local height = maxY - minY
        outline = string.format(DEFAULT_OUTLINE, minX, minY, width, height, scale)
    end

    local minX, minY, width, height = string.match(outline,
                                          'viewBox%s*=%s*"([%d.-]+)%s+([%d.-]+)%s+([%d.-]+)%s+([%d.-]+)"')
    local scaleMultiplier = string.match(outline, 'scaleMultiplier="([0-9.]+)"')
    scaleMultiplier = scaleMultiplier or 100
    local maxX = minX + width
    local maxY = minY + height

    local minDimension = math.min(maxX - minX, maxY - minY)
    local minElementSize = minDimension / 50
    local maxElementSize = minDimension / 25

    local minHp2 = elementMetadata.min.hp * elementMetadata.min.hp
    local maxHp2 = elementMetadata.max.hp * elementMetadata.max.hp

    local sortedIds = sortIds(elementData, function(e)
        return e.p.z
    end)

    local elementList = {}
    local element, hp2, radius
    for _, id in pairs(sortedIds) do
        element = elementData[id]
        hp2 = element.h * element.h
        radius = (hp2 - minHp2) / (maxHp2 - minHp2) * (maxElementSize - minElementSize) + minElementSize

        elementList[id] = string.format(CLOUD_ELEMENT_TEMPLATE, screenXFunc(element.p) * scaleMultiplier,
                              screenYFunc(element.p) * scaleMultiplier, radius)
    end
    return outline, elementList
end

--- Helper function for updateCloud to add a point to the appropriate list.
local function addPoint(point, hp, maxHp, broken, damaged, healthy)
    if hp == 0 then
        broken[#broken + 1] = point
    elseif hp < maxHp then
        damaged[#damaged + 1] = point
    else
        healthy[#healthy + 1] = point
    end
end

function _G.updateCloud(outline, points, elementData, selectedId, showHealthy, showDamaged, showBroken)
    -- if not initialized
    if not outline or not points then
        return ""
    end

    local broken = {}
    local damaged = {}
    local healthy = {}

    local hp, maxHp
    for id, point in pairs(points) do
        hp = elementData[id].h
        maxHp = elementData[id].m
        addPoint(point, hp, maxHp, broken, damaged, healthy)
    end

    -- add selected point to end of type - places on top of similarly (un)damaged elements
    if points[selectedId] then
        local point = string.gsub(points[selectedId], "/>", [[ class="selected"/>]])
        hp = elementData[selectedId].h
        maxHp = elementData[selectedId].m
        addPoint(point, hp, maxHp, broken, damaged, healthy)
    end

    local brokenGroup = ""
    if showBroken then
        brokenGroup = string.format(HEALTH_GROUP_TEMPLATE, BROKEN_CLASS, table.concat(broken, ""))
    end
    local damagedGroup = ""
    if showDamaged then
        damagedGroup = string.format(HEALTH_GROUP_TEMPLATE, DAMAGED_CLASS, table.concat(damaged, ""))
    end
    local healthyGroup = ""
    if showHealthy then
        healthyGroup = string.format(HEALTH_GROUP_TEMPLATE, HEALTHY_CLASS, table.concat(healthy, ""))
    end

    return string.gsub(outline, CLOUD_REPLACE_TARGET, healthyGroup .. damagedGroup .. brokenGroup)
end

function filterIds(ids, filter)
    local filtered = {}
    for _, id in pairs(ids) do
        if filter(id) then
            table.insert(filtered, id)
        end
    end
    return filtered
end

function sortIds(elementData, axisAccessor)
    local ids = {}
    for k, _ in pairs(elementData) do
        ids[#ids + 1] = k
    end

    local comparator = function(a, b)
        local ea = elementData[a]
        local eb = elementData[b]
        -- -- if a and b are not in the same damaged state sort by state
        -- if not ((ea.h == 0 and eb.h == 0) or (ea.h < ea.m and eb.h < eb.m) or (ea.h == ea.m and eb.h == eb.m)) then
        --     -- more damaged comes later in list
        --     return not (ea.h == 0 and eb.h > 0) or (ea.h < ea.m and eb.h == eb.m)
        -- end

        -- else sort by axis
        local axisA = axisAccessor(ea)
        local axisB = axisAccessor(eb)
        if axisA == axisB then
            -- fall back to index
            return a < b
        end
        -- higher axis value comes later in list
        return axisA < axisB
    end
    table.sort(ids, comparator)
    return ids
end
