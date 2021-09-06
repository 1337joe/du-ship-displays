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
local SORT_COLUMN_KEY = "HP.screen:SORT_COLUMN"
local SORT_COLUMN_DEFAULT = 5
local SORT_UP_KEY = "HP.screen:SORT_UP"
local SORT_UP_DEFAULT = true
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
local ELEMENT_TABLE_ROW_CLASS = "tableRow"
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
_G.hpScreenController.BUTTON_TABLE_ROW = "Table: Row "
_G.hpScreenController.BUTTON_STRETCH_CLOUD = "Cloud: Stretch"
_G.hpScreenController.BUTTON_MAXIMIZE_CLOUD = "Cloud: Maximize"

-- add SVG-specific fields
_G.hpScreenController.SVG_TEMPLATE = [[${file:hp.screen.basic.svg}]]
_G.hpScreenController.SVG_LOGO = [[${file:../../logo.svg minify}]]

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

for row = 1, 20 do
    buttonCoordinates[_G.hpScreenController.BUTTON_TABLE_ROW .. row] = {
        x1 = 0.4, x2 = 0.972,
        y1 = (189 + 65 - 5 + 41 * row - 30) / 1080, y2 = (189 + 65 + 41 * row + 11) / 1080,
        class = ELEMENT_TABLE_ROW_CLASS .. row
    }
end

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

    if not (self.databank and self.databank.hasKey(SORT_COLUMN_KEY) == 1) then
        self.sortColumn = SORT_COLUMN_DEFAULT
    end
    if not (self.databank and self.databank.hasKey(SORT_UP_KEY) == 1) then
        self.sortUp = SORT_UP_DEFAULT
    end

    if not (self.databank and self.databank.hasKey(SCROLL_INDEX_KEY) == 1) then
        self.scrollIndex = SCROLL_INDEX_DEFAULT
    end

    if not (self.databank and self.databank.hasKey(STRECH_CLOUD_KEY) == 1) then
        self.stretchCloud = STRETCH_CLOUD_DEFAULT
    end
    if not (self.databank and self.databank.hasKey(MAXIMIZE_CLOUD_KEY) == 1) then
        self.maximizeCloud = MAXIMIZE_CLOUD_DEFAULT
    end

    if _G.hpOutline then
        self.outlineTop = _G.hpOutline.SVG_TOP
        self.outlineSide = _G.hpOutline.SVG_SIDE
        self.outlineFront = _G.hpOutline.SVG_FRONT
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
        local screenZFunc = function(pos)
            return pos.z
        end
        local template, points = self:buildShipCloudPoints(self.outlineTop, screenXFunc, screenYFunc, screenZFunc)
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
        local screenZFunc = function(pos)
            return pos.x
        end
        local template, points = self:buildShipCloudPoints(self.outlineSide, screenXFunc, screenYFunc, screenZFunc)
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
        local screenZFunc = function(pos)
            return pos.y
        end
        local template, points = self:buildShipCloudPoints(self.outlineFront, screenXFunc, screenYFunc, screenZFunc)
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

    if self.databank then
        if self.databank.hasKey(SHOW_HEALTHY_KEY) == 1 then
            self.showHealthy = self.databank.getIntValue(SHOW_HEALTHY_KEY) == 1
        end
        if self.databank.hasKey(SHOW_DAMAGED_KEY) == 1 then
            self.showDamaged = self.databank.getIntValue(SHOW_DAMAGED_KEY) == 1
        end
        if self.databank.hasKey(SHOW_BROKEN_KEY) == 1 then
            self.showBroken = self.databank.getIntValue(SHOW_BROKEN_KEY) == 1
        end

        if self.databank.getIntValue(SELECTED_TAB_KEY) ~= self.selectedTab then
            self:setSelectedTab(self.databank.getIntValue(SELECTED_TAB_KEY))
        end

        if self.databank.hasKey(SORT_COLUMN_KEY) == 1 then
            self.sortColumn = self.databank.getIntValue(SORT_COLUMN_KEY)
        end
        if self.databank.hasKey(SORT_UP_KEY) == 1 then
            self.sortUp = self.databank.getIntValue(SORT_UP_KEY) == 1
        end
        if self.databank.hasKey(SCROLL_INDEX_KEY) == 1 then
            self.scrollIndex = self.databank.getIntValue(SCROLL_INDEX_KEY)
        end

        if self.databank.hasKey(STRECH_CLOUD_KEY) == 1 then
            self.stretchCloud = self.databank.getIntValue(STRECH_CLOUD_KEY) == 1
        end
        if self.databank.hasKey(MAXIMIZE_CLOUD_KEY) == 1 then
            self.maximizeCloud = self.databank.getIntValue(MAXIMIZE_CLOUD_KEY) == 1
        end

        -- will call more than desired, but will keep state up to date
        self:updateButtonStates()
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

        tabContents, self.maxScrollIndex = self:buildTable()

        -- manage header states
        local columnElementClass = nil
        if self.sortColumn == 1 then
            columnElementClass = ELEMENT_SORT_ID_CLASS
        elseif self.sortColumn == 2 then
            columnElementClass = ELEMENT_SORT_NAME_CLASS
        elseif self.sortColumn == 3 then
            columnElementClass = ELEMENT_SORT_DMG_CLASS
        elseif self.sortColumn == 4 then
            columnElementClass = ELEMENT_SORT_MAX_CLASS
        elseif self.sortColumn == 5 then
            columnElementClass = ELEMENT_SORT_INT_CLASS
        end
        if columnElementClass then
            html = _G.ScreenUtils.addClass(html, columnElementClass, SELECTED_CLASS)
            if self.sortUp then
                html = _G.ScreenUtils.addClass(html, columnElementClass .. "Up", SELECTED_CLASS)
            else
                html = _G.ScreenUtils.addClass(html, columnElementClass .. "Down", SELECTED_CLASS)
            end
        end
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
    local storeSort = false
    local storeScroll = false

    local tableRow = string.match(buttonId, self.BUTTON_TABLE_ROW .. "(%d+)")

    if buttonId == _G.hpScreenController.BUTTON_FILTER_HEALTHY then
        self.showHealthy = not self.showHealthy
        if self.databank then
            if self.showHealthy then
                self.databank.setIntValue(SHOW_HEALTHY_KEY, 1)
            else
                self.databank.setIntValue(SHOW_HEALTHY_KEY, 0)
            end
        end

        self.scrollIndex = 1
        storeScroll = true

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

        self.scrollIndex = 1
        storeScroll = true

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

        self.scrollIndex = 1
        storeScroll = true

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
        if self.sortColumn == 1 then
            self.sortUp = not self.sortUp
        else
            self.sortColumn = 1
            self.sortUp = SORT_UP_DEFAULT
        end

        storeSort = true
        modified = true
    elseif buttonId == _G.hpScreenController.BUTTON_SORT_NAME then
        if self.sortColumn == 2 then
            self.sortUp = not self.sortUp
        else
            self.sortColumn = 2
            self.sortUp = SORT_UP_DEFAULT
        end

        storeSort = true
        modified = true
    elseif buttonId == _G.hpScreenController.BUTTON_SORT_DMG then
        if self.sortColumn == 3 then
            self.sortUp = not self.sortUp
        else
            self.sortColumn = 3
            self.sortUp = SORT_UP_DEFAULT
        end

        storeSort = true
        modified = true
    elseif buttonId == _G.hpScreenController.BUTTON_SORT_MAX then
        if self.sortColumn == 4 then
            self.sortUp = not self.sortUp
        else
            self.sortColumn = 4
            self.sortUp = SORT_UP_DEFAULT
        end

        storeSort = true
        modified = true
    elseif buttonId == _G.hpScreenController.BUTTON_SORT_INT then
        if self.sortColumn == 5 then
            self.sortUp = not self.sortUp
        else
            self.sortColumn = 5
            self.sortUp = SORT_UP_DEFAULT
        end

        storeSort = true
        modified = true

    elseif buttonId == _G.hpScreenController.BUTTON_SKIP_UP then
        if self.scrollIndex > 1 then
            self.scrollIndex = 1
            storeScroll = true
            modified = true
        end
    elseif buttonId == _G.hpScreenController.BUTTON_SKIP_DOWN then
        if self.scrollIndex < self.maxScrollIndex then
            self.scrollIndex = self.maxScrollIndex
            storeScroll = true
            modified = true
        end
    elseif buttonId == _G.hpScreenController.BUTTON_SCROLL_UP then
        if self.scrollIndex > 1 then
            self.scrollIndex = self.scrollIndex - 1
            storeScroll = true
            modified = true
        end
    elseif buttonId == _G.hpScreenController.BUTTON_SCROLL_DOWN then
        if self.scrollIndex < self.maxScrollIndex then
            self.scrollIndex = self.scrollIndex + 1
            storeScroll = true
            modified = true
        end

    elseif tableRow then
        local index = self.scrollIndex + tonumber(tableRow) - 1 -- both are 1-indexed
        local sortedIds = self:sortIdsForTable()

        if sortedIds[index] then
            if sortedIds[index] == self.controller.selectedElement then
                self.controller:select(nil)
            else
                self.controller:select(sortedIds[index])
            end
            modified = true
        end

    elseif buttonId == _G.hpScreenController.BUTTON_STRETCH_CLOUD then
        self.stretchCloud = not self.stretchCloud
        if self.databank then
            if self.stretchCloud then
                self.databank.setIntValue(STRECH_CLOUD_KEY, 1)
            else
                self.databank.setIntValue(STRECH_CLOUD_KEY, 0)
            end
        end
        modified = true
    elseif buttonId == _G.hpScreenController.BUTTON_MAXIMIZE_CLOUD then
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

    if storeSort and self.databank then
        self.databank.setIntValue(SORT_COLUMN_KEY, self.sortColumn)
        if self.sortUp then
            self.databank.setIntValue(SORT_UP_KEY, 1)
        else
            self.databank.setIntValue(SORT_UP_KEY, 0)
        end
    end

    if storeScroll and self.databank then
        self.databank.setIntValue(SCROLL_INDEX_KEY, self.scrollIndex)
    end

    if modified then
        -- misses case where another player interacts with same panel
        self:updateButtonStates()
    end

    return modified
end

-- Update the active state of buttons based on if they're visible.
function _G.hpScreenController:updateButtonStates()
    local isTable = self.selectedTab == 1
    local isMaximized = self.maximizeCloud

    -- global elements, only depend on not being maximized
    self.buttonCoordinates[self.BUTTON_FILTER_HEALTHY].active = not isMaximized
    self.buttonCoordinates[self.BUTTON_FILTER_DAMAGED].active = not isMaximized
    self.buttonCoordinates[self.BUTTON_FILTER_BROKEN].active = not isMaximized
    self.buttonCoordinates[self.BUTTON_TAB_TABLE].active = not isMaximized
    self.buttonCoordinates[self.BUTTON_TAB_TOP].active = not isMaximized
    self.buttonCoordinates[self.BUTTON_TAB_SIDE].active = not isMaximized
    self.buttonCoordinates[self.BUTTON_TAB_FRONT].active = not isMaximized

    -- table elements, only depend on table being set
    self.buttonCoordinates[self.BUTTON_SORT_ID].active = isTable
    self.buttonCoordinates[self.BUTTON_SORT_NAME].active = isTable
    self.buttonCoordinates[self.BUTTON_SORT_DMG].active = isTable
    self.buttonCoordinates[self.BUTTON_SORT_MAX].active = isTable
    self.buttonCoordinates[self.BUTTON_SORT_INT].active = isTable
    self.buttonCoordinates[self.BUTTON_SKIP_UP].active = isTable
    self.buttonCoordinates[self.BUTTON_SCROLL_UP].active = isTable
    self.buttonCoordinates[self.BUTTON_SCROLL_DOWN].active = isTable
    self.buttonCoordinates[self.BUTTON_SKIP_DOWN].active = isTable
    for row = 1, 20 do
        buttonCoordinates[self.BUTTON_TABLE_ROW .. row].active = isTable
    end

    -- cloud elements, only depend on not table
    self.buttonCoordinates[self.BUTTON_STRETCH_CLOUD].active = not isTable
    self.buttonCoordinates[self.BUTTON_MAXIMIZE_CLOUD].active = not isTable
end

function _G.hpScreenController:sortIdsForTable()
    local elementData = self.controller.elementData
    local sortColumn = self.sortColumn

    local sortFunction
    if self.sortColumn == 1 then -- id
        sortFunction = function(e)
            return 1 -- fallback to id sort
        end
    elseif self.sortColumn == 2 then -- name
        sortFunction = function(e)
            return e.n
        end
    elseif sortColumn == 3 then -- damage
        sortFunction = function(e)
            return e.m - e.h
        end
    elseif sortColumn == 4 then -- max
        sortFunction = function(e)
            return e.m
        end
    elseif sortColumn == 5 then -- integrity
        sortFunction = function(e)
            return e.h / e.m
        end
    end
    local sorted = sortIds(elementData, sortFunction, not self.sortUp)

    local filter = function(id)
        local hp = elementData[id].h
        local max = elementData[id].m
        return (self.showBroken and hp == 0) or (self.showDamaged and hp > 0 and hp < max) or (self.showHealthy and hp == max)
    end
    return filterIds(sorted, filter)
end

local TABLE_ROW_BASE_OFFSET = 65 -- height of heading
local TABLE_SCROLL_BUTTON_SIZE = 54
local TABLE_SCROLL_BAR_OFFSET = TABLE_ROW_BASE_OFFSET + TABLE_SCROLL_BUTTON_SIZE * 2
local TABLE_SCROLL_BAR_HEIGHT = TAB_CONTENTS_HEIGHT - TABLE_SCROLL_BAR_OFFSET - TABLE_SCROLL_BUTTON_SIZE * 2
-- Use nth-child css selector on .tableRow to style row elements
local TABLE_ROW_TEMPLATE = [[
<g class="tableRow%d%s" transform="translate(0,%.0f)">]]..[[
<rect x="2.5" y="-30" width="]] .. TAB_CONTENTS_WIDTH - TABLE_SCROLL_BUTTON_SIZE - 5 .. [[" height="39"/>]] .. [[
<text x="100">%d</text>]] .. [[
<text x="120">%s</text>]] .. [[
<text x="796">%s</text>]] .. [[
<text x="796">%s</text>]] .. [[
<text x="946">%s</text>]] .. [[
<text x="946">%s</text>]] .. [[
<text x="1081">%d</text>]] .. [[
</g>]]
--- Generates the contents of the table.
function _G.hpScreenController:buildTable()
    local elementData = self.controller.elementData
    local scrollIndex = self.scrollIndex
    local selectedId = self.controller.selectedElement
    local table = [[<g id="tableContents">]]

    local sortedIds = self:sortIdsForTable()

    local rowCount = 0
    local visibleCount = 0
    local data, hp, max, class, yOffset, hpPrint, hpUnit, maxPrint, maxUnit, integrity
    for _, id in pairs(sortedIds) do
        data = elementData[id]
        hp = data.h
        max = data.m

        rowCount = rowCount + 1

        yOffset = TABLE_ROW_BASE_OFFSET - 5 + 41 * (visibleCount + 1)
        if rowCount >= scrollIndex and yOffset < TAB_CONTENTS_HEIGHT then
            visibleCount = visibleCount + 1

            if id == selectedId then
                class = " selected"
            else
                class = ""
            end

            hpPrint, hpUnit = Utilities.printableNumber(math.floor(max - hp + 0.5), "")
            if hpPrint == "0.0" then
                hpPrint = "0"
            end
            maxPrint, maxUnit = Utilities.printableNumber(max, "")
            integrity = math.floor(100 * hp / max)

            if integrity == 0 then
                class = class .. " broken"
            elseif integrity < 100 then
                class = class .. " damaged"
            end

            table = table .. string.format(TABLE_ROW_TEMPLATE, visibleCount, class, yOffset, id, data.n, hpPrint, hpUnit, maxPrint, maxUnit, integrity)

        end
    end
    table = table .. [[</g>]]

    local scrollBarHeight = TABLE_SCROLL_BAR_HEIGHT * visibleCount / rowCount
    local scrollBarOffset = TABLE_SCROLL_BAR_HEIGHT * (scrollIndex - 1) / rowCount

    table = table .. string.format([[<rect class="scrollbar" x="%.0f" y="%.0f" width="%.0f" height="%.0f" />]], TAB_CONTENTS_WIDTH - TABLE_SCROLL_BUTTON_SIZE, TABLE_SCROLL_BAR_OFFSET + scrollBarOffset, TABLE_SCROLL_BUTTON_SIZE, scrollBarHeight)

    local maxScrollIndex = rowCount - visibleCount + 1
    return table, maxScrollIndex
end

local CLOUD_REPLACE_TARGET = [[<g id="pointCloud"%s*/>]]
local DEFAULT_OUTLINE = [[
<svg viewBox="%f %f %f %f" scaleMultiplier="%d">
    <style>
    circle {
        stroke: black;
        stroke-width: %.2f;
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
function _G.hpScreenController:buildShipCloudPoints(outline, screenXFunc, screenYFunc, screenZFunc)
    local elementData = self.controller.elementData
    local elementMetadata = self.controller.elementMetadata

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
        local strokeWidth = math.min(width, height) / 200
        outline = string.format(DEFAULT_OUTLINE, minX, minY, width, height, scale, strokeWidth)
    end

    local minX, minY, width, height = string.match(outline,
                                          'viewBox%s*=%s*"([%d.-]+)%s+([%d.-]+)%s+([%d.-]+)%s+([%d.-]+)"')
    local scaleMultiplier = string.match(outline, 'scaleMultiplier="([0-9.]+)"')
    scaleMultiplier = scaleMultiplier or 100
    local maxX = minX + width
    local maxY = minY + height

    local maxDimension = math.max(maxX - minX, maxY - minY)
    local minElementSize = maxDimension / 50
    local maxElementSize = maxDimension / 25

    local minHp2 = elementMetadata.min.hp * elementMetadata.min.hp
    local maxHp2 = elementMetadata.max.hp * elementMetadata.max.hp

    -- TODO should change for each perspective, not be staticly set to the z axis
    local sortedIds = sortIds(elementData, screenZFunc)

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

function sortIds(elementData, valueAccessor, reverse)
    local ids = {}
    for k, _ in pairs(elementData) do
        ids[#ids + 1] = k
    end

    local comparator = function(a, b)
        local ea = elementData[a]
        local eb = elementData[b]

        -- else sort by axis
        local valueA = valueAccessor(ea)
        local valueB = valueAccessor(eb)
        if valueA == valueB then
            -- fall back to index
            return (not reverse and a < b) or (reverse and a > b)
        end
        -- higher value comes later in list
        return (not reverse and valueA < valueB) or (reverse and valueA > valueB)
    end
    table.sort(ids, comparator)
    return ids
end
