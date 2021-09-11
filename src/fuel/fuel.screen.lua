local rslib = require('rslib')
local json = require("dkjson")

-- constants
local DEFAULT_FONT = "Play"
local OPTIONS_TIMEOUT = 10

local X_RES, Y_RES = getResolution()
local VW, VH = X_RES / 100, Y_RES / 100

-- persistent data, only clears when screen fully reloaded
persistent = persistent or {
    power = true,
}

-- screen configuration
local accept = {"fuel"}

-- prepare output
local output = {
    accept = accept
}
-- ouptut immediately in case input processing fails
setOutput(json.encode(output))

-- parse input
local inputString = getInput()
local success, result = pcall(json.decode, inputString)
local input
if not success then
    input = {
        error = result
    }
elseif type(result) == "table" then
    input = result
-- elseif type(result) == "nil" then
--     input = {
--         blank = true
--     }
else
    input = {
        error = string.format("Unexpected input type: %s (%s)", type(result), result)
    }
end

if type(input.error) == "string" and input.error:len() > 0 then
    rslib.drawQuickText(input.error, {textColor = {1, 0, 0, 1}, fontSize = 50})
    return
elseif type(input.message) == "string" and input.message:len() then
    rslib.drawQuickText(input.message, {fontSize = 50})
    return
end

-- extract input data
local function extractInput(root, name, debug)
    if type(root[name]) == "table" then
        return root[name]
    end

    if debug then
        logMessage(string.format("'%s' input missing/not table: %s", name, root[name]))
    end
    return {}
end
local debug = type(input.debug) == "boolean" and input.debug
local options = extractInput(input, "options", true)
if not persistent.options or options.nonce ~= persistent.options.nonce then
    persistent.options = options
elseif options.nonce == persistent.options.nonce then
    if persistent.optionsUpdateTime then
        persistent.optionsUpdateTime = persistent.optionsUpdateTime + getDeltaTime()
    end
end
local fuelData = extractInput(input, "fuel", debug)
local fuelOptions = extractInput(fuelData, "options", debug)
if not persistent.fuelOptions or fuelOptions.nonce ~= persistent.fuelOptions.nonce then
    persistent.fuelOptions = fuelOptions
elseif fuelOptions.nonce == persistent.fuelOptions.nonce then
    if persistent.optionsUpdateTime then
        persistent.optionsUpdateTime = persistent.optionsUpdateTime + getDeltaTime()
    end
end

-----------------
-- draw interface
-----------------
local cX, cY = getCursor()
local xOff, yOff = 0, 0
local xRemaining, yRemaining = X_RES, Y_RES
setBackgroundColor(0, 0, 0)

local uiSize
if persistent.options.uiSmall then
    uiSize = 5 * VH
else
    uiSize = 10 * VH
end

-- create layers, later layers draw on top of earlier
local backgroundLayer = createLayer()
local maskingLayer = createLayer()
local textLayer = createLayer()
local headerLayer = createLayer()
local interfaceLayer = createLayer()


local function buttonPower(layer, on, hover, x, y, width, height)
    -- TODO draw power icon reflecting state
    setNextFillColor(interfaceLayer, 1, 1, 1, 1)
    addBox(interfaceLayer, x, y, width, height)
end

--- Draw a button and detect if clicked.
local function drawButton(layer, buttonFunction, state, box, clickBox)
    clickBox = clickBox or box

    local hover, clicked = false, false
    if cX >= clickBox[1] and cX <= clickBox[1] + clickBox[3] and cY >= clickBox[2] and cY <= clickBox[2] + clickBox[4] then
        hover = true
        clicked = getCursorPressed()
    end

    buttonFunction(layer, state, hover, table.unpack(box))

    return clicked, hover
end

if persistent.options.powerToggle or not persistent.power then
    local clicked = drawButton(interfaceLayer, buttonPower, persistent.power, {X_RES - uiSize, Y_RES - uiSize, uiSize, uiSize})
    if clicked then
        persistent.power = not persistent.power
    end
end

if not persistent.power then
    return
end


-- header
if persistent.options.header then
    local headerText = "FUEL"

    local headerTargetHeight = uiSize
    local headerBold = loadFont("Montserrat-Bold", headerTargetHeight * 1.43)
    local headerTextWidth, _ = getTextBounds(headerBold, headerText)
    setNextFillColor(headerLayer, 1, 0.5, 0, 1)
    addBox(headerLayer, 0, 0, X_RES, headerTargetHeight)
    setNextFillColor(headerLayer, 0, 0, 0, 1)
    addText(headerLayer, headerBold, headerText, X_RES - headerTextWidth - headerTargetHeight, headerTargetHeight)
    yOff = yOff + headerTargetHeight
    yRemaining = yRemaining - headerTargetHeight
end


local fontCache = {}
--- Memoized load of font/size combination.
local function loadCachedFont(name, size)
    if not fontCache[name] then
        fontCache[name] = {}
    end
    local sizeCache = fontCache[name]
    if not fontCache[name][size] then
        fontCache[name][size] = loadFont(name, size)
    end
    return fontCache[name][size]
end

--- Draw a border with a label.
-- @return inner coordinates: x, y, width, height
local function drawGroup(layer, label, margin, border, padding, bgColor, fgColor, x, y, width, height, topMargin)
    topMargin = topMargin or margin
    local tmb = topMargin + border
    local mb = margin + border

    if border > 0 then
        setNextFillColor(layer, table.unpack(bgColor))
        setNextStrokeWidth(layer, border)
        setNextStrokeColor(layer, table.unpack(fgColor))
        addBoxRounded(layer, x + mb, y + tmb, width - mb * 2, height - tmb - mb, padding)
    end

    if label and label:len() > 0 then
        local labelXOff = x + mb + padding * 3
        local groupHeader = loadCachedFont(DEFAULT_FONT, topMargin + padding)
        local headerWidth, _ = getTextBounds(groupHeader, label)
        local _, descender = getFontMetrics(groupHeader)
        setNextFillColor(layer, table.unpack(bgColor))
        addQuad(layer, labelXOff - padding,                 y + tmb - border * 2,
                       labelXOff + headerWidth + padding,   y + tmb - border * 2,
                       labelXOff + headerWidth + padding,   y + tmb + border,
                       labelXOff - padding,                 y + tmb + border)

        setNextFillColor(layer, table.unpack(fgColor))
        addText(layer, groupHeader, label, labelXOff, y + tmb + padding + descender)
    end
    return x + mb + padding, y + tmb + padding, width - (mb + padding) * 2, height - (mb + tmb + padding * 2)
end

--- Draw a check box button.
local function buttonCheckBox(layer, selected, hover, x, y, width, height)
    local strokeWidth = math.max(width, height) / 20

    -- box
    setNextFillColor(layer, 0, 0, 0, 0)
    if hover then
        setNextStrokeColor(layer, 1, 1, 1, 1)
    else
        setNextStrokeColor(layer, 0.5, 0.5, 0.5, 1)
    end
    setNextStrokeWidth(layer, strokeWidth)
    addBox(layer, x + width / 4, y + height / 4, width / 2, height / 2)

    -- check
    if selected then
        setNextStrokeColor(layer, 0, 1, 0, 1)
        setNextStrokeWidth(layer, strokeWidth * 2)
        addLine(layer, x + width * 5 / 16, y + height * 7 / 16, x + width / 2, y + height * 5 / 8)
        setNextStrokeColor(layer, 0, 1, 0, 1)
        setNextStrokeWidth(layer, strokeWidth * 2)
        addLine(layer, x + width / 2, y + height * 5 / 8, x + width * 7 / 8, y + height * 3 / 16)
    end
end

local function buttonExpandBox(layer, expanded, hover, x, y, width, height)
end

local background = {0, 0, 0, 1}
local foreground = {0, 1, 0, 1}
local oX, oY, oW, oH = drawGroup(backgroundLayer, "Options", 2 * VH, VH / 2, 2 * VH, background, foreground, xOff, yOff, xRemaining, yRemaining - uiSize, 4 * VH)

--- Add options to a box area.
local function addOptions(layer, optionsTable, options, scale, box)
    local lineHeight = box[4] / scale
    local lineSpacing = lineHeight * 1.5
    local font = loadCachedFont(DEFAULT_FONT, lineHeight)
    local _, descender = getFontMetrics(font)
    local yOff = box[2]
    local clicked, hover
    setDefaultFillColor(layer, Shape_Text, 0.5, 0.5, 0.5, 1)

    for _, optionRow in pairs(options) do
        local textRows = rslib.getTextWrapped(font, optionRow[2], box[3] - lineHeight)
        clicked, hover = drawButton(layer, buttonCheckBox, optionsTable[optionRow[1]], {box[1], yOff, lineHeight, lineHeight}, {box[1], yOff, box[3], lineHeight * #textRows})
        if hover then
            setNextFillColor(layer, 1, 1, 1, 1)
        end
        for i, row in pairs(textRows) do
            if hover then
                setNextFillColor(layer, 1, 1, 1, 1)
            end
            addText(layer, font, row, box[1] + lineHeight, yOff + lineHeight * i + descender)
        end
        if clicked then
            optionsTable[optionRow[1]] = not optionsTable[optionRow[1]]
        end
        yOff = yOff + lineSpacing
    end
end

local g1X, g1Y, g1W, g1H = drawGroup(backgroundLayer, "Fuel", 2 * VH, VH / 2, 2 * VH, background, foreground, oX, oY, oW / 2, oH, 3 * VH)
local fuelOptions = {
    {"groupByPrefix", "Group Tanks"},
    {"showNames", "Show Tank Names"},
    {"reverseMeters", "Reverse Meters"},
}
if persistent.fuelOptions.groupByPrefix then
    table.insert(fuelOptions, 2, {"showWidget", "Show Widget"})
end
-- TODO determine what tank types are available
table.insert(fuelOptions, {"excludeA", "Exclude Atmo"})
table.insert(fuelOptions, {"excludeS", "Exclude Space"})
table.insert(fuelOptions, {"excludeR", "Exclude Rocket"})
addOptions(interfaceLayer, persistent.fuelOptions, fuelOptions, 10, {g1X, g1Y, g1W, g1H})

local g2X, g2Y, g2W, g2H = drawGroup(backgroundLayer, "General", 2 * VH, VH / 2, 2 * VH, background, foreground, oX + oW / 2, oY, oW / 2, oH, 3 * VH)
local generalOptions = {
    {"header", "Show Header"},
    {"uiSmall", "Small UI Elements"},
    {"powerToggle", "Show Power Button"},
    {"toggleInactive", "Disable Screen with Controller"}
}
addOptions(interfaceLayer, persistent.options, generalOptions, 10, {g2X, g2Y, g2W, g2H})




local optionsChanged = false
local changedOptions = {}
for k, v in pairs (persistent.options) do
    if input.options[k] ~= v then
        optionsChanged = true
        changedOptions[k] = v
    end
end
if optionsChanged then
    if not persistent.optionsUpdateTime then
        persistent.optionsUpdateTime = 0
    end
    output.options = changedOptions
end

local fuelOptionsChanged = false
changedOptions = {}
for k, v in pairs (persistent.fuelOptions) do
    if input.fuel.options[k] ~= v then
        fuelOptionsChanged = true
        changedOptions[k] = v
    end
end
if fuelOptionsChanged then
    if not persistent.optionsUpdateTime then
        persistent.optionsUpdateTime = 0
    end
    output.fuelOptions = changedOptions
end

local message
if optionsChanged or fuelOptionsChanged then
    if persistent.optionsUpdateTime > OPTIONS_TIMEOUT then
        setNextFillColor(interfaceLayer, 1, 0, 0, 1)
        message = "Controller disconnected!"
    else
        setNextFillColor(interfaceLayer, 1, 1, 0, 1)
        message = "Saving..."
        end
else
    persistent.optionsUpdateTime = nil
    setNextFillColor(interfaceLayer, 0, 1, 0, 1)
    message = "Saved"
end
local font = loadCachedFont(DEFAULT_FONT, uiSize)
local _, descender = getFontMetrics(font)
addText(interfaceLayer, font, message, -descender, Y_RES + descender)


if cX >= 0 then
    requestAnimationFrame(5)
elseif persistent.optionsUpdateTime and persistent.optionsUpdateTime < OPTIONS_TIMEOUT then
    requestAnimationFrame(20)
else
    requestAnimationFrame(40)
end


if debug then
    logMessage(string.format("Final render cost: %d / %d", getRenderCost(), getRenderCostMax()))
    logMessage(string.format("Timers: optionsUpdate: %f", persistent.optionsUpdateTime or -1))
end

-- rebuild and report output
setOutput(json.encode(output))

