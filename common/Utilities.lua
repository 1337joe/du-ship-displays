--- Utilities module.
-- Frequently needed utility functions.
-- @module Utilities

-- Guard to keep this module from reinitializing any time the start event fires if placed in libraries/system slot.
if _G.Utilities then
    return
end
_G.Utilities = {}

local SI_PREFIXES = {"", "k", "M", "G", "T", "P", "E", "Z", "Y"}
--- Converts raw float to formatted SI prefix with limited decimal places.
-- @tparam number value The number to format.
-- @tparam string units The units label to apply SI prefixes to.
-- @treturn string The formated number for display.
-- @treturn string The units with SI prefix applied.
function _G.Utilities.printableNumber(value, units)
    -- can't process nil, 0 breaks the sign calculation
    if not value or value == 0 then
        return "0.0", units
    end

    local adjustedValue = math.abs(value)
    local sign = value / adjustedValue
    local factor = 1 -- index of no prefix
    while adjustedValue >= 999.5 and factor < #SI_PREFIXES do
        adjustedValue = adjustedValue / 1000
        factor = factor + 1
    end

    if adjustedValue < 9.95 then -- rounded to 10, show 1 decimal place
        return string.format("%.1f", sign * math.floor(adjustedValue * 10 + 0.5) / 10), SI_PREFIXES[factor] .. units
    end
    return string.format("%.0f", sign * math.floor(adjustedValue + 0.5)), SI_PREFIXES[factor] .. units
end

--- Escapes % symbols that are not part of string format strings.
-- @tparam string text The string to sanitize.
function _G.Utilities.sanitizeFormatString(text)
    text = string.gsub(text, "%%([^sdf])", "%%%%%1")
    text = string.gsub(text, "%%$", "%%%%") -- handle % at end of string
    return text
end

--- Finds the first slot on 'unit' that has element class 'slotClass' and is not listed in the exclude list.
-- @tparam string slotClass The element class of the target slot.
-- @tparam table exclude A list of slots to exclude from search.
-- @return The first element found of the desired type, or nil if none is found.
-- @return The name of the slot where the returned element was found.
function _G.Utilities.findFirstSlot(slotClass, exclude)
    exclude = exclude or {}

    for key, value in pairs(unit) do

        -- ignore excluded elements
        for _, exc in pairs(exclude) do
            if value == exc then
                goto continueOuter
            end
        end

        if value and type(value) == "table" and value.getElementClass and value.getElementClass() == slotClass then
            return value, key
        end

        ::continueOuter::
    end

    return nil, nil
end

return _G.Utilities
