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
    -- ensure preceeded by " or space
    return string.gsub(html, "([\"%s])" .. find, "%1" .. replace)
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

return _G.ScreenUtils
