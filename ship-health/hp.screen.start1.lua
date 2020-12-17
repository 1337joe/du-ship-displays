--- Run first, define agScreenController basic functionality: SVG-specific definitions and functions are not included.

-- constants and editable lua script parameters

local SELECTED_TAB_KEY = "HP.screen:SELECTED_TAB"
local SELECTED_TAB_DEFAULT = 1

-- constants for svg file
local HEALTHY_CLASS = "healthy"
local DAMAGED_CLASS = "damaged"
local BROKEN_CLASS = "broken"
local SELECTED_CLASS = "selected"
local MOUSE_OVER_CLASS = "mouseOver"
local ELEMENT_TITLE_COLOR_CLASS = "titleColor"
local ELEMENT_TABLE_CLASS = "tableClass"
local ELEMENT_TOP_CLASS = "topClass"
local ELEMENT_SIDE_CLASS = "sideClass"
local ELEMENT_FRONT_CLASS = "frontClass"

local TAB_CONTENTS_TAG = [[<svg id="tabContents"/>]]

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
_G.hpScreenController.BUTTON_TAB_TABLE = "Tab: Table"
_G.hpScreenController.BUTTON_TAB_TOP = "Tab: Top"
_G.hpScreenController.BUTTON_TAB_SIDE = "Tab: Side"
_G.hpScreenController.BUTTON_TAB_FRONT = "Tab: Front"

-- add SVG-specific fields
_G.hpScreenController.SVG_TEMPLATE = [[${file:hp.screen.basic.svg}]]
_G.hpScreenController.SVG_LOGO = [[${file:../logo.svg minify}]]

-- one-time transforms
_G.hpScreenController.SVG_TEMPLATE = string.gsub(_G.hpScreenController.SVG_TEMPLATE, '<svg id="logo"/>', _G.hpScreenController.SVG_LOGO)

-- Define button ranges, either in tables of x1,y1,x2,y2 or lists of those tables.
local buttonCoordinates = {}
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
-- save to controller for press/release event handling
_G.hpScreenController.buttonCoordinates = buttonCoordinates

function _G.hpScreenController:init(controller)
    self.controller = controller
    self.screen = controller.slots.screen
    self.databank = controller.slots.databank

    if self.databank and self.databank.hasKey(SELECTED_TAB_KEY) == 1 then
        self:setSelectedTab(self.databank.getIntValue(SELECTED_TAB_KEY))
    else
        self:setSelectedTab(SELECTED_TAB_DEFAULT)
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
        local template, points = _G.buildShipCloudPoints(self.outlineTop, self.controller.elementData, self.controller.elementMetadata, screenXFunc, screenYFunc)
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
        local template, points = _G.buildShipCloudPoints(self.outlineSide, self.controller.elementData, self.controller.elementMetadata, screenXFunc, screenYFunc)
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
        local template, points = _G.buildShipCloudPoints(self.outlineFront, self.controller.elementData, self.controller.elementMetadata, screenXFunc, screenYFunc)
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

    -- -- update mouse position for tracking drags
    -- self.mouse.x = self.screen.getMouseX()
    -- self.mouse.y = self.screen.getMouseY()
    -- self.mouse.state = self.screen.getMouseState() == 1
    -- -- if mouse has left screen remove pressed flag
    -- if self.mouse.x < 0 then
    --     self.mouse.pressed = nil
    -- end

    -- local mouseOver = _G.ScreenUtils.detectButton(self.buttonCoordinates, self.mouse.x, self.mouse.y)

    -- refresh conditions: needRefresh, mouse-over state changed
    --or self.mouse.over ~= mouseOver
    if not (self.needRefresh ) then
        return
    end
    self.needRefresh = false
    -- self.mouse.over = mouseOver

    if self.databank and self.databank.getIntValue(SELECTED_TAB_KEY) ~= self.selectedTab then
        self:setSelectedTab(self.databank.getIntValue(SELECTED_TAB_KEY))
    end

    -- if initializing tab in background say so?


    local html = self.SVG_TEMPLATE

    -- extract values to show in svg
    local elementData = self.controller.elementData
    local elementMetadata = self.controller.elementMetadata

    local shipName = self.controller.shipName
    local elementIntegrity = math.floor(elementMetadata.totalHp / elementMetadata.totalMaxHp * 100)

    -- insert values to svg
    html = _G.Utilities.sanitizeFormatString(html)
    html = string.format(html, shipName, elementIntegrity)

    html = _G.ScreenUtils.replaceClass(html, ELEMENT_TITLE_COLOR_CLASS, HEALTHY_CLASS)

    -- replacing class on tab intentionally prevents mousing over it from working
    local tabContents = TAB_CONTENTS_TAG
    if self.selectedTab == 1 then
        html = _G.ScreenUtils.replaceClass(html, ELEMENT_TABLE_CLASS, SELECTED_CLASS)
    elseif self.selectedTab == 2 or self.selectedTab == 3 or self.selectedTab == 4 then
        tabContents = updateCloud(self.tabData.template, self.tabData.points, self.controller.elementData, self.controller.selectedElement)

        if self.selectedTab == 2 then
            html = _G.ScreenUtils.replaceClass(html, ELEMENT_TOP_CLASS, SELECTED_CLASS)
        elseif self.selectedTab == 3 then
            tabContents = updateCloud(self.tabData.template, self.tabData.points, self.controller.elementData, self.controller.selectedElement)
        elseif self.selectedTab == 4 then
            tabContents = updateCloud(self.tabData.template, self.tabData.points, self.controller.elementData, self.controller.selectedElement)
        end
    end
    html = string.gsub(html, TAB_CONTENTS_TAG, tabContents)

    -- TODO has performance problems, only with large ships?
    -- add mouse-over highlights
    -- if not self.mouse.pressed then
    --     html = _G.ScreenUtils.mouseoverButtons(self.buttonCoordinates, self.mouse.x, self.mouse.y, html, MOUSE_OVER_CLASS)
    -- end

    self.screen.setHTML(html)
end

--- Processes the input indicated by the provided button id.
-- @treturn boolean True if the state was changed by this action.
function _G.hpScreenController:handleButton(buttonId)
    local modified = false

    if buttonId == _G.hpScreenController.BUTTON_TAB_TABLE then
        modified = self:setSelectedTab(1)
    elseif buttonId == _G.hpScreenController.BUTTON_TAB_TOP then
        modified = self:setSelectedTab(2)
    elseif buttonId == _G.hpScreenController.BUTTON_TAB_SIDE then
        modified = self:setSelectedTab(3)
    elseif buttonId == _G.hpScreenController.BUTTON_TAB_FRONT then
        modified = self:setSelectedTab(4)
    end

    return modified
end

local CLOUD_REPLACE_TARGET = [[<g id="pointCloud"%s*/>]]
local DEFAULT_OUTLINE = [[
<svg id="tabContents" viewBox="%f %f %f %f" scaleMultiplier="%d">
    <style>
    circle {
        stroke: black;
        stroke-width: 1vmin;
    }
    .broken {
        fill: #ff1300;
    }
    .damaged {
        fill: #ffd700;
    }
    .healthy {
        fill: #00c322;
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
local CLOUD_ELEMENT_TEMPLATE = [[<circle cx="%s" cy="%s" r="%s"/>]]
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

    local minX, minY, width, height = string.match(outline, 'viewBox%s*=%s*"([%d.-]+)%s+([%d.-]+)%s+([%d.-]+)%s+([%d.-]+)"')
    local scaleMultiplier = string.match(outline, 'scaleMultiplier="([0-9.]+)"')
    scaleMultiplier = scaleMultiplier or 100
    local maxX = minX + width
    local maxY = minY + height

    local minDimension = math.min(maxX - minX, maxY - minY)
    local minElementSize = minDimension / 50
    local maxElementSize = minDimension / 25

    local minHp2 = elementMetadata.min.hp * elementMetadata.min.hp
    local maxHp2 = elementMetadata.max.hp * elementMetadata.max.hp

    local sortedIds = sortIds(elementData, function(e) return e.p.z end)

    local elementList = {}
    local element, hp2, radius
    for _, id in pairs(sortedIds) do
        element = elementData[id]
        hp2 = element.h * element.h
        radius = (hp2 - minHp2) / (maxHp2 - minHp2) * (maxElementSize - minElementSize) + minElementSize

        elementList[id] = string.format(CLOUD_ELEMENT_TEMPLATE, screenXFunc(element.p) * scaleMultiplier, screenYFunc(element.p) * scaleMultiplier, radius)
    end
    return outline, elementList
end

function _G.updateCloud(outline, points, elementData, selectedId)
    -- if not initialized
    if not outline or not points then
        return ""
    end

    local broken = {}
    local damaged = {}
    local healthy = {}

    local hp, maxHp
    for id, point in pairs(points) do
        if id == selectedId then
            point = string.gsub(point, ">", [[ class="selected">]])
        end

        hp = elementData[id].h
        maxHp = elementData[id].m
        if hp == 0 then
            broken[#broken + 1] = point
        elseif hp < maxHp then
            damaged[#damaged + 1] = point
        else
            healthy[#healthy + 1] = point
        end
    end

    local brokenGroup = string.format(HEALTH_GROUP_TEMPLATE, BROKEN_CLASS, table.concat(broken, ""))
    local damagedGroup = string.format(HEALTH_GROUP_TEMPLATE, DAMAGED_CLASS, table.concat(damaged, ""))
    local healthyGroup = string.format(HEALTH_GROUP_TEMPLATE, HEALTHY_CLASS, table.concat(healthy, ""))

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
