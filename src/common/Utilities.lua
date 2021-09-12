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
    text = string.gsub(text, "%%%%(%d*%.%d*f)", "%%%1") -- allow float specifiers
    text = string.gsub(text, "%%$", "%%%%") -- handle % at end of string
    return text
end

--- Finds the first slot on 'unit' that has element class 'slotClass' and is not listed in the exclude list.
-- @tparam string slotClass The element class of the target slot. May instead be a table containing a list of class names.
-- @tparam table exclude A list of slots to exclude from search.
-- @return The first element found of the desired type, or nil if none is found.
-- @return The name of the slot where the returned element was found.
function _G.Utilities.findFirstSlot(slotClass, exclude)
    if type(slotClass) ~= "table" then
        slotClass = {slotClass}
    end
    exclude = exclude or {}

    for key, value in pairs(unit) do

        -- ignore excluded elements
        for _, exc in pairs(exclude) do
            if value == exc then
                goto continueOuter
            end
        end

        if value and type(value) == "table" and value.getElementClass then
            for _, class in pairs(slotClass) do
                if value.getElementClass() == class then
                    return value, key
                end
            end
        end

        ::continueOuter::
    end

    return nil, nil
end

--- Finds the all slots on 'unit' that have element class 'slotClass'.
-- @tparam string slotClass The element class of the target slot. May instead be a table containing a list of class names.
-- @tparam table exclude A list of slots to exclude from search.
-- @return A table mapping slot names to matching elements.
function _G.Utilities.findAllSlots(slotClass, exclude)
    if type(slotClass) ~= "table" then
        slotClass = {slotClass}
    end
    exclude = exclude or {}

    local result = {}
    for key, value in pairs(unit) do

        -- ignore excluded elements
        for _, exc in pairs(exclude) do
            if value == exc then
                goto continueOuter
            end
        end

        if value and type(value) == "table" and value.getElementClass then
            for _, class in pairs(slotClass) do
                if value.getElementClass() == class then
                    result[key] = value
                end
            end
        end

        ::continueOuter::
    end

    return result
end

-- Verifies the valid argument, if not true then it prints the provided message to the optional screen and to the programming board error log, halting execution.
-- @param valid The condition to test, typically a boolean.
-- @tparam string message The message to display on failure.
-- @tparam ScreenUnit/ScreenSignUnit screen The optional screen for displaying the message on in case of failure.
local function assertValid(valid, message, screen)
    if not valid then
        if screen and screen.setCenteredText and type(screen.setCenteredText) == "function" then
            screen.setCenteredText(message)
        end
        error(message)
    end
end

--- Attempts to verify the provided slot against the expected type, finding missing slot inputs in unit.
-- @tparam Element provided A named slot that should fill the need for this type. May be nil.
-- @tparam string targetClass The ElementClass to look for/validate against. May be a table containing a list of classes.
-- @tparam ScreenUnit/ScreenSignUnit errorScreen A screen to display error messages to on failure.
-- @tparam string moduleName The name of the module, to help disambiguate problems when multiple modules are run on the same controller.
-- @tparam string mappedSlotName The internal name of the slot to indicate exactly what mapping failed.
-- @tparam boolean optional True if this element is optional and should not produce an error on failure to map.
-- @tparam string optionalMessage A message to print to the console on failure to map an optional element.
function _G.Utilities.loadSlot(provided, targetClass, errorScreen, moduleName, mappedSlotName, optional, optionalMessage)
    if type(targetClass) ~= "table" then
        targetClass = {targetClass}
    end
    local slotName

    local typedSlot = provided
    if not (typedSlot and type(typedSlot) == "table" and typedSlot.getElementClass) then
        typedSlot, slotName = _G.Utilities.findFirstSlot(targetClass)
        if not optional then
            assertValid(typedSlot, string.format("%s: %s link not found.", moduleName, mappedSlotName), errorScreen)
        end

        if typedSlot then
            system.print(string.format("Slot %s mapped to %s %s.", slotName, moduleName, mappedSlotName))
        elseif optionalMessage and string.len(optionalMessage) > 0 then
            system.print(string.format("%s: %s", moduleName, optionalMessage))
        end
    else
        local class = typedSlot.getElementClass()
        local valid = false
        for _, tClass in pairs(targetClass) do
            valid = valid or class == tClass
        end
        assertValid(valid, string.format("%s %s slot is of type: %s", moduleName, mappedSlotName, class), errorScreen)
    end
    return typedSlot
end

local useParameterSettings = false --export: Toggle this on to override stored preferences with parameter-set values, otherwise will load from databank if available.
-- can't export value from table, but would rather use it from the utilities object
_G.Utilities.USE_PARAMETER_SETTINGS = useParameterSettings

--- Returns the preferred preference value, storing that in the databank for future use if available. Type will be inferred from the default value provided.
-- @param databank The databank to use for preferences.
-- @tparam string key The databank preference key to look up/store to.
-- @param defaultValue The value to use if the databank doesn't contain key.
-- @return The preference value to use.
function _G.Utilities.getPreference(databank, key, defaultValue)
    local isBool = type(defaultValue) == "boolean"
    local isNumber = type(defaultValue) == "number"
    local prefValue

    if databank then
        if databank.hasKey(key) == 1 and not _G.Utilities.USE_PARAMETER_SETTINGS then
            if isBool then
                prefValue = databank.getIntValue(key) == 1
            elseif isNumber then
                prefValue = databank.getFloatValue(key)
            else
                prefValue = databank.getStringValue(key)
            end
        else
            prefValue = defaultValue
        end

        if isBool then
            local storeValue = 0
            if prefValue then
                storeValue = 1
            end
            databank.setIntValue(key, storeValue)
        elseif isNumber then
            databank.setFloatValue(key, tonumber(prefValue))
        else
            databank.setStringValue(key, prefValue)
        end
    else
        prefValue = defaultValue
    end

    return prefValue
end

return _G.Utilities
