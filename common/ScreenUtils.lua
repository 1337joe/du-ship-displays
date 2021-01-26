--- Screen utils module.
-- Frequently needed screen functions.
-- @module ScreenUtils

-- Guard to keep this module from reinitializing any time the start event fires if placed in libraries/system slot.
if _G.ScreenUtils then
    return
end
_G.ScreenUtils = {}

--- Replaces a value from within a class attribute.
function _G.ScreenUtils.replaceClass(html, find, replace)
    -- ensure preceeded and followed by " or space
    return string.gsub(html, "([\"%s])" .. find .. "([%s\"])", "%1" .. replace .. "%2")
end

--- Adds an additional value to a class attribute.
function _G.ScreenUtils.addClass(html, find, add)
    -- ensure preceeded and followed by " or space
    return string.gsub(html, "([\"%s]" .. find .. ")([%s\"])", "%1 " .. add .. "%2")
end

--- Returns the button that intersects the provided coordinates or nil if none is found.
-- @tparam table buttonCoordinates Table of "buttonLabel" => {x1, y1, x2, y2} or "buttonLabel" => {1={x1, y1, x2, y2}, 2={x1, y1, x2, y2}, ...}
-- @tparam number x The x screen position to test.
-- @tparam number y The y screen position to test.
function _G.ScreenUtils.detectButton(buttonCoordinates, x, y)
    local found = false
    local index = nil
    for buttonLabel, coords in pairs(buttonCoordinates) do
        if coords.x1 then
            if x > coords.x1 and x < coords.x2 and y > coords.y1 and y < coords.y2 then
                found = true
            end
        else
            for i, innerCoords in pairs(coords) do
                if innerCoords.x1 then
                    if x > innerCoords.x1 and x < innerCoords.x2 and y > innerCoords.y1 and y < innerCoords.y2 then
                        found = true
                        index = i
                    end
                else
                    break
                end
            end
        end

        if found then
            return buttonLabel, index
        end
    end
    return nil
end

--- Replaces the class for the currently moused-over button with the mouseoverClass
-- @tparam table buttonCoordinates Table of "buttonLabel" => {x1, y1, x2, y2, class} or
--  "buttonLabel" => {1={x1, y1, x2, y2}, 2={x1, y1, x2, y2}, ..., class="elementClass"} or
--  "buttonLabel" => {x1, y1, x2, y2, {class1, class2, ...}}
-- @tparam number x The x screen position to test.
-- @tparam number y The y screen position to test.
-- @tparam string html The html document to update.
-- @tparam string mouseoverClass The css class to replace the current button with.
function _G.ScreenUtils.mouseoverButtons(buttonCoordinates, x, y, html, mouseoverClass)
    local mouseover, index = _G.ScreenUtils.detectButton(buttonCoordinates, x, y)
    -- nil doesn't concatenate nicely
    index = index or ""

    if mouseover then
        if type(buttonCoordinates[mouseover].class) == "table" then
            local newHtml = html
            for _,findClass in pairs(buttonCoordinates[mouseover].class) do
                newHtml = _G.ScreenUtils.replaceClass(newHtml, findClass, mouseoverClass)
            end
            return newHtml
        else
            local findClass = buttonCoordinates[mouseover].class .. index
            return _G.ScreenUtils.replaceClass(html, findClass, mouseoverClass)
        end
    end
    return html
end

return _G.ScreenUtils
