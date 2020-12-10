--- Run first, define agScreenController basic functionality: SVG-specific definitions and functions are not included.

-- constants and editable lua script parameters

local SELECTED_TAB_KEY = "HP.screen:SELECTED_TAB"
local SELECTED_TAB_DEFAULT = 0

-- initialize object and fields
_G.hpScreenController = {
    mouse = {
        x = -1,
        y = -1,
        pressed = nil,
        state = false
    },
    needRefresh = false,
}

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

-- should this be moved to the child class?
function _G.hpScreenController:setSelectedTab(tabIndex)
end

--- Render the interface to the screen.
function _G.hpScreenController:refresh()
    -- refresh conditions: needRefresh, mouse down
    if not (self.needRefresh or self.mouse.pressed) then
        return
    end
    self.needRefresh = false

    -- update mouse position for tracking drags
    self.mouse.x = self.screen.getMouseX()
    self.mouse.y = self.screen.getMouseY()
    self.mouse.state = self.screen.getMouseState() == 1
    -- if mouse has left screen remove pressed flag
    if self.mouse.x < 0 then
        self.mouse.pressed = nil
    end

    -- local html = self.SVG_TEMPLATE

    -- extract values to show in svg

    -- insert values to svg and render
    -- html = _G.Utilities.sanitizeFormatString(html)
    -- html = string.format(html, currentAltitudeSliderHeight, targetAltitudeSliderHeight, baseAltitudeSliderHeight,
    --     targetAltitudeString, baseAltitude, verticalVelocity, verticalUnits,
    --             currentAltitude, agField, agPower)

    screen.setSVG(_G.buildShipCloud(nil, core.getElementIdList(), self.elementData, self.elementMetadata))

end

--- Processes the input indicated by the provided button id.
-- @treturn boolean True if the state was changed by this action.
function _G.hpScreenController:handleButton(buttonId)
    local modified = false

    -- if buttonId == _G.hpScreenController.BUTTON_ALTITUDE_UP then
    --     local adjusted = self.controller.targetAltitude + self.altitudeAdjustment
    --     modified = adjusted ~= self.controller.targetAltitude

    --     self.controller:setBaseAltitude(adjusted)
    -- end

    return modified
end

local CLOUD_REPLACE_TARGET = [[<g id="pointCloud"%s*/>]]
local DEFAULT_OUTLINE = [[
<svg viewBox="%f %f %f %f">
    <style>
    circle {
        fill: #00c322;
        stroke: white;
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
    </style>
    <g>
        <g id="pointCloud" />
    </g>
</svg>
]]
-- TODO make coroutine
local CLOUD_ELEMENT_TEMPLATE = [[<circle cx="%s" cy="%s" r="%s" class="class%d"/>]]
function _G.buildShipCloud(outline, ids, elementData, elementMetadata)
    local scaleMultiplier = 100
    if not outline then
        local buffer = 0.05 -- 5% extra per side
        local minX = (elementMetadata.min.x - (elementMetadata.max.x - elementMetadata.min.x) * buffer) * scaleMultiplier
        local minY = (elementMetadata.min.y - (elementMetadata.max.y - elementMetadata.min.y) * buffer) * scaleMultiplier
        local maxX = (elementMetadata.max.x + (elementMetadata.max.x - elementMetadata.min.x) * buffer) * scaleMultiplier
        local maxY = (elementMetadata.max.y + (elementMetadata.max.y - elementMetadata.min.y) * buffer) * scaleMultiplier
        local width = maxX - minX
        local height = maxY - minY
        outline = string.format(DEFAULT_OUTLINE, minX, minY, width, height)
    end

    local minX, minY, width, height = string.match(outline, 'viewBox%s*=%s*"([%d.-]+)%s+([%d.-]+)%s+([%d.-]+)%s+([%d.-]+)"')
    local maxX = minX + width
    local maxY = minY + height

    local minDimension = math.min(maxX - minX, maxY - minY)
    local minElementSize = minDimension / 50
    local maxElementSize = minDimension / 25

    local minHp2 = elementMetadata.min.hp * elementMetadata.min.hp
    local maxHp2 = elementMetadata.max.hp * elementMetadata.max.hp

    ids = sortIds(ids, elementData, function(e) return e.p[3] end)

    local elementList = {}
    local element, hp2, radius
    for _, id in pairs(ids) do
        element = elementData[id]
        hp2 = element.h * element.h
        radius = (hp2 - minHp2) / (maxHp2 - minHp2) * (maxElementSize - minElementSize) + minElementSize
        
        table.insert(elementList, string.format(CLOUD_ELEMENT_TEMPLATE, element.p[1] * scaleMultiplier, element.p[2] * scaleMultiplier, radius, id))
    end
    local elementGroup = table.concat(elementList, "\n")

    return string.gsub(outline, CLOUD_REPLACE_TARGET, elementGroup)
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

function sortIds(ids, elementData, axisAccessor)
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