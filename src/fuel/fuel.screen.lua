local rslib = require("rslib")
local json = require("dkjson")

-- constants
local DEFAULT_FONT = "Play"
local DEFAULT_MONO_FONT = "RobotoMono"
local OPTIONS_TIMEOUT = 10

local BACKGROUND_COLOR = {0, 0, 0, 1}
 -- TODO adjust colors
local ATMO_COLOR = {0, 1, 1, 1}
local SPACE_COLOR = {1, 1, 0, 1}
local ROCKET_COLOR = {0, 0, 1, 1}

 -- TODO adjust colors
local VOL_GREEN = {0, 1, 0, 1}
local VOL_YELLOW = {1, 1, 0, 1}
local VOL_RED = {1, 0, 0, 1}
local VOL_THRESHOLD_YELLOW = 0.25
local VOL_THRESHOLD_RED = 0.125

local X_RES, Y_RES = getResolution()
local VW, VH = X_RES / 100, Y_RES / 100

-- persistent data, only clears when screen fully reloaded
persistent = persistent or {
    power = true,
    view = "fuel",
}

-- screen configuration
local accept = {"fuel"}

-- prepare output
local output = {
    accept = accept
}
-- set output immediately in case processing is cut short
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
elseif result == nil then
    input = {
        error = "Input missing/empty, is Programming Board running?"
    }
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
setBackgroundColor(table.unpack(BACKGROUND_COLOR))

local uiSize
if persistent.options.uiSmall then
    uiSize = 5 * VH
else
    uiSize = 10 * VH
end




--------------------
-- library functions
--------------------
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

local SI_PREFIXES = {"", "k", "M", "G", "T", "P", "E", "Z", "Y"}
--- Converts raw float to formatted SI prefix with limited decimal places.
-- @tparam number value The number to format.
-- @tparam string units The units label to apply SI prefixes to.
-- @treturn string The formated number for display.
-- @treturn string The units with SI prefix applied.
local function printableNumber(value, units)
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

--- Draw a power button.
local function buttonPower(layer, on, hover, x, y, width, height)
    local xC = x + width / 2
    local strokeWidth = math.max(width, height) / 15

    local fillColor, ringColor, lineColor, alpha
    if hover then
        alpha = 1
    else
        alpha = 0.5
    end
    if on then
        fillColor = BACKGROUND_COLOR
        ringColor = {1, 1, 1, alpha}
        lineColor = {0, 1, 0, alpha}
    else
        fillColor = {0, 0, 0, 1}
        ringColor = {1, 0, 0, alpha}
        lineColor = {1, 1, 1, alpha}
    end

    -- take advantage of draw order to mask in a single layer: boxRounded < circle < line
    -- assume width = height
    setNextFillColor(layer, table.unpack(fillColor))
    addBoxRounded(layer, x, y, width, height, width / 2)

    setNextFillColor(layer, 0, 0, 0, 0)
    setNextStrokeWidth(layer, strokeWidth)
    setNextStrokeColor(layer, table.unpack(ringColor))
    addCircle(layer, xC, y + width * 7 / 12, width / 3)

    setNextFillColor(layer, table.unpack(fillColor))
    addCircle(layer, xC, y + width * 3 / 12, strokeWidth * 2)

    setNextStrokeWidth(layer, strokeWidth)
    setNextStrokeColor(layer, table.unpack(lineColor))
    addLine(layer, xC, y + strokeWidth, xC, y + height / 2)
end

-- Draw a 3-line menu button.
local function buttonMenu(layer, selected, hover, x, y, width, height)
    local strokeWidth = height / 10
    local x1, x2 = x + width / 6, x + width * 5 / 6

    local lineColor, alpha
    if hover then
        alpha = 1
    else
        alpha = 0.5
    end
    if selected then
        lineColor = {1, 1, 1, alpha}
    else
        lineColor = {0, 0, 0, alpha}
    end

    -- take advantage of draw order to mask in a single layer: boxRounded < circle < line
    -- assume width = height
    setNextFillColor(layer, 1, 1, 1, 0.3)
    addBox(layer, x, y, width, height)

    setNextStrokeWidth(layer, strokeWidth)
    setNextStrokeColor(layer, table.unpack(lineColor))
    addLine(layer, x1, y + height / 6, x2, y + height / 6)

    setNextStrokeWidth(layer, strokeWidth)
    setNextStrokeColor(layer, table.unpack(lineColor))
    addLine(layer, x1, y + height / 2, x2, y + height / 2)

    setNextStrokeWidth(layer, strokeWidth)
    setNextStrokeColor(layer, table.unpack(lineColor))
    addLine(layer, x1, y + height * 5 / 6, x2, y + height * 5 / 6)
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

--- Draw an expand box button.
local function buttonExpandBox(layer, expanded, hover, x, y, width, height)
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

    -- TODO +/- indicator
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





-- create layers, later layers draw on top of earlier
local backgroundLayer = createLayer()
local maskingLayer = createLayer()
local textLayer = createLayer()
local headerLayer = createLayer()
local interfaceLayer = createLayer()


if persistent.options.powerToggle or not persistent.power then
    local clicked = drawButton(interfaceLayer, buttonPower, persistent.power, {X_RES - uiSize, Y_RES - uiSize, uiSize, uiSize})
    if clicked then
        persistent.power = not persistent.power
    end
end

if not persistent.power then
    setBackgroundColor(0, 0, 0)
    return
end

if true then
    local clicked = drawButton(interfaceLayer, buttonMenu, persistent.view == "options", {X_RES - uiSize, 0, uiSize, uiSize})
    if clicked then
        if persistent.view == "options" then
            persistent.view = "fuel"
        else
            persistent.view = "options"
        end
    end
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
    addText(headerLayer, headerBold, headerText, X_RES - headerTextWidth - headerTargetHeight * 1.5, headerTargetHeight)
    yOff = yOff + headerTargetHeight
    yRemaining = yRemaining - headerTargetHeight
end

local function drawMeter(baseLayer, overlayLayer, boundsBox, tankGroup, overlayColor)
    local xOff, yOff, xRemaining, yRemaining = table.unpack(boundsBox)
    -- TODO limit aspect ratio - text stops fitting
    local strokeWidth = boundsBox[4] / 20
    local percentRemaining = tankGroup.vol / tankGroup.maxVol
    local volColor = VOL_GREEN
    if percentRemaining < VOL_THRESHOLD_RED then
        volColor = VOL_RED
    elseif percentRemaining < VOL_THRESHOLD_YELLOW then
        volColor = VOL_YELLOW
    end

    local bigFont = loadCachedFont(DEFAULT_MONO_FONT, boundsBox[4] * 7 / 16)
    local medMetrics = {size = boundsBox[4] / 4}
    local medFont = loadCachedFont(DEFAULT_FONT, medMetrics.size)
    medMetrics.asc, medMetrics.desc = getFontMetrics(medFont)
    local medMetrics2 = {size = boundsBox[4] / 4}
    local medFont2 = loadCachedFont(DEFAULT_MONO_FONT, medMetrics2.size)
    medMetrics2.asc, medMetrics2.desc = getFontMetrics(medFont)
    local smlMetrics = {size = boundsBox[4] / 6}
    local smlFont = loadCachedFont(DEFAULT_MONO_FONT, smlMetrics.size)
    smlMetrics.asc, smlMetrics.desc = getFontMetrics(smlFont)

    -- percent box
    local percentText = string.format("%.0f", percentRemaining * 100)
    local strokeWidth2 = strokeWidth * 2
    local cornerRadius = strokeWidth * 4
    -- fill in rounded corners on right side of box
    setNextFillColor(baseLayer, table.unpack(overlayColor))
    addBox(baseLayer, xOff + yRemaining - cornerRadius - strokeWidth2, yOff, cornerRadius + strokeWidth2, yRemaining)
    setNextFillColor(baseLayer, table.unpack(BACKGROUND_COLOR))
    setNextStrokeColor(baseLayer, table.unpack(overlayColor))
    setNextStrokeWidth(baseLayer, strokeWidth2)
    addBoxRounded(baseLayer, xOff + strokeWidth2, yOff + strokeWidth2, yRemaining - strokeWidth2 * 2, yRemaining - strokeWidth2 * 2, cornerRadius)

    -- percent text
    local fx, fy = getTextBounds(bigFont, "100")
    local tx, _ = getTextBounds(bigFont, percentText)
    setNextFillColor(overlayLayer, table.unpack(volColor))
    addText(overlayLayer, bigFont, percentText, xOff + yRemaining / 2 + fx / 2 - tx, yOff + yRemaining / 2)

    -- volume text
    local volString, units = printableNumber(tankGroup.vol, "L")
    local vx, vy = getTextBounds(medFont2, volString)
    local volY = yOff + yRemaining * 3 / 4
    setNextFillColor(overlayLayer, 0.5, 0.5, 0.5, 1)
    -- 3 / 5: 3 characters volume, 2 characters units
    addText(overlayLayer, medFont2, units, xOff + yRemaining * 3 / 5, volY)
    setNextFillColor(overlayLayer, table.unpack(overlayColor))
    addText(overlayLayer, medFont2, volString, xOff + yRemaining * 3 / 5 - vx, volY)

    xOff = xOff + yRemaining
    xRemaining = xRemaining - yRemaining

    -- fill fuel bar - draw behind and mask to follow edges
    local slantedStrokeWidth = strokeWidth / math.cos(math.pi / 8) -- 22.5 deg from vertical
    local barMaxWidth = xRemaining - strokeWidth * 2 - slantedStrokeWidth * 2
    local xQuarter = xOff + strokeWidth + barMaxWidth / 4
    local xHalf = xOff + strokeWidth + barMaxWidth / 2
    local xThreeQuarter = xOff + strokeWidth + barMaxWidth * 3 / 4
    setNextFillColor(baseLayer, table.unpack(volColor))
    addBox(baseLayer, xOff + strokeWidth, yOff + smlMetrics.size + strokeWidth * 2, barMaxWidth * percentRemaining, yRemaining - smlMetrics.size - strokeWidth * 4)

    -- label text
    if persistent.fuelOptions.showNames then
        -- TODO truncate to fit?
        local labelText = tankGroup.name

        -- align with top edge
        local labelY = yOff + medMetrics.asc + medMetrics.desc
        setNextFillColor(overlayLayer, table.unpack(overlayColor))
        addText(overlayLayer, medFont, labelText, xOff + medMetrics.size / 2, labelY)
    end
    -- decorator
    setNextFillColor(baseLayer, table.unpack(overlayColor))
    addTriangle(baseLayer, xOff, yOff, xOff + medMetrics.size / 2, yOff, xOff, yOff + medMetrics.size)

    -- remaining text
    if tankGroup.timeLeft then
        local h = math.floor(tankGroup.timeLeft / 3600)
        local m = math.floor((tankGroup.timeLeft % 3600) / 60)
        local s = math.floor(tankGroup.timeLeft % 60)
        local remainingText = string.format("%02d:%02d:%02d", h, m, s)
        -- align with top edge
        local labelY = yOff + smlMetrics.asc + smlMetrics.desc
        setNextFillColor(overlayLayer, table.unpack(overlayColor))
        addText(overlayLayer, smlFont, remainingText, xThreeQuarter + strokeWidth + smlMetrics.size / 2, labelY)
    end

    -- mask fuel bar
    setNextFillColor(baseLayer, table.unpack(BACKGROUND_COLOR))
    addQuad(baseLayer, xOff + strokeWidth / 2, yOff + medMetrics.size + strokeWidth * 2,
                       xOff + strokeWidth, yOff + smlMetrics.size + strokeWidth * 3 / 2,
                       xThreeQuarter + (strokeWidth / 2) * (xThreeQuarter - xHalf) / (medMetrics.size - smlMetrics.size), yOff + smlMetrics.size + strokeWidth * 3 / 2, -- extend along slope to fully mask
                       xHalf, yOff + medMetrics.size + strokeWidth * 2)
    setNextFillColor(baseLayer, table.unpack(BACKGROUND_COLOR))
    addQuad(baseLayer, xOff + barMaxWidth + strokeWidth + strokeWidth / 4, yOff + smlMetrics.size + strokeWidth * 3 / 2,
                       xOff + barMaxWidth + strokeWidth + strokeWidth / 2, yOff + smlMetrics.size + strokeWidth * 3 / 2,
                       xOff + barMaxWidth + strokeWidth + strokeWidth / 2, yOff + yRemaining - strokeWidth * 3 / 2,
                       xOff + barMaxWidth + strokeWidth + strokeWidth / 4 - ((yOff + yRemaining - strokeWidth * 3 / 2) - (yOff + smlMetrics.size + strokeWidth * 3 / 2)) / 2, yOff + yRemaining - strokeWidth * 3 / 2)
    -- meter lines
    setNextFillColor(baseLayer, table.unpack(BACKGROUND_COLOR))
    addQuad(baseLayer, xQuarter - strokeWidth / 2, yOff + smlMetrics.size + strokeWidth * 3 / 2,
                       xQuarter + strokeWidth / 2, yOff + smlMetrics.size + strokeWidth * 3 / 2,
                       xQuarter + strokeWidth / 2, yOff + yRemaining - strokeWidth * 3 / 2,
                       xQuarter - strokeWidth / 2, yOff + yRemaining - strokeWidth * 3 / 2)
    setNextFillColor(baseLayer, table.unpack(BACKGROUND_COLOR))
    addQuad(baseLayer, xHalf - strokeWidth / 2, yOff + smlMetrics.size + strokeWidth * 3 / 2,
                       xHalf + strokeWidth / 2, yOff + smlMetrics.size + strokeWidth * 3 / 2,
                       xHalf + strokeWidth / 2, yOff + yRemaining - strokeWidth * 3 / 2,
                       xHalf - strokeWidth / 2, yOff + yRemaining - strokeWidth * 3 / 2)
    setNextFillColor(baseLayer, table.unpack(BACKGROUND_COLOR))
    addQuad(baseLayer, xThreeQuarter - strokeWidth / 2, yOff + smlMetrics.size + strokeWidth * 3 / 2,
                       xThreeQuarter + strokeWidth / 2, yOff + smlMetrics.size + strokeWidth * 3 / 2,
                       xThreeQuarter + strokeWidth / 2, yOff + yRemaining - strokeWidth * 3 / 2,
                       xThreeQuarter - strokeWidth / 2, yOff + yRemaining - strokeWidth * 3 / 2)

    -- outline fuel bar - use quads to draw over masking quads (same shape, same layer renders in draw order)
    setNextFillColor(baseLayer, table.unpack(overlayColor))
    addQuad(baseLayer, xOff, yOff + medMetrics.size + strokeWidth,
                       xOff, yOff + medMetrics.size,
                       xHalf, yOff + medMetrics.size,
                       xHalf, yOff + medMetrics.size + strokeWidth)
    setNextFillColor(baseLayer, table.unpack(overlayColor))
    addQuad(baseLayer, xHalf, yOff + medMetrics.size + strokeWidth,
                       xHalf, yOff + medMetrics.size,
                       xThreeQuarter + strokeWidth / 2 + smlMetrics.size / 2, yOff,
                       xThreeQuarter, yOff + smlMetrics.size + strokeWidth)
    setNextFillColor(baseLayer, table.unpack(overlayColor))
    addQuad(baseLayer, xThreeQuarter, yOff + smlMetrics.size + strokeWidth,
                       xThreeQuarter, yOff + smlMetrics.size,
                       xOff + xRemaining, yOff + smlMetrics.size,
                       xOff + xRemaining - strokeWidth / 2, yOff + smlMetrics.size + strokeWidth)
    local xLowerRightInner = xOff + xRemaining - (yRemaining - smlMetrics.size) / 2 - slantedStrokeWidth + strokeWidth / 2
    setNextFillColor(baseLayer, table.unpack(overlayColor))
    addQuad(baseLayer, xOff + xRemaining - strokeWidth / 2 - slantedStrokeWidth, yOff + smlMetrics.size + strokeWidth,
                       xOff + xRemaining, yOff + smlMetrics.size,
                       xOff + xRemaining - (yRemaining - smlMetrics.size) / 2, yOff + yRemaining,
                       xLowerRightInner, yOff + yRemaining - strokeWidth)
    setNextFillColor(baseLayer, table.unpack(overlayColor))
    addQuad(baseLayer, xOff, yOff + yRemaining,
                       xOff, yOff + yRemaining - strokeWidth,
                       xOff + xRemaining - (yRemaining - smlMetrics.size) / 2 + strokeWidth / 2, yOff + yRemaining - strokeWidth,
                       xOff + xRemaining - (yRemaining - smlMetrics.size) / 2, yOff + yRemaining)

    -- meter lines overlay
    setNextStrokeColor(overlayLayer, table.unpack(overlayColor))
    setNextStrokeWidth(overlayLayer, strokeWidth / 2)
    addLine(overlayLayer, xQuarter, yOff + medMetrics.size + strokeWidth, xQuarter, yOff + yRemaining - strokeWidth)
    setNextStrokeColor(overlayLayer, table.unpack(overlayColor))
    setNextStrokeWidth(overlayLayer, strokeWidth / 2)
    addLine(overlayLayer, xHalf, yOff + medMetrics.size + strokeWidth, xHalf, yOff + yRemaining - strokeWidth)
    setNextStrokeColor(overlayLayer, table.unpack(overlayColor))
    setNextStrokeWidth(overlayLayer, strokeWidth / 2)
    addLine(overlayLayer, xThreeQuarter, yOff + smlMetrics.size + strokeWidth, xThreeQuarter, yOff + yRemaining - strokeWidth)
end

if persistent.view == "fuel" then
    local message
    if false then
        if persistent.optionsUpdateTime > OPTIONS_TIMEOUT then
            setNextFillColor(interfaceLayer, 1, 0, 0, 1)
            message = "Controller disconnected!"
        end
    else
        setNextFillColor(interfaceLayer, 0, 1, 0, 1)
        message = nil
    end
    if message then
        local font = loadCachedFont(DEFAULT_FONT, uiSize)
        local _, descender = getFontMetrics(font)
        addText(interfaceLayer, font, message, -descender, Y_RES + descender)

        yRemaining = yRemaining - uiSize -- mark room used for status message
    end

    local showAtmo, showSpace, showRocket
    local rootCount = 0
    if input.fuel.atmo and not persistent.fuelOptions.excludeA then
        showAtmo = true
        rootCount = rootCount + 1
    end
    if input.fuel.space and not persistent.fuelOptions.excludeS then
        showSpace = true
        rootCount = rootCount + 1
    end
    if input.fuel.rocket and not persistent.fuelOptions.excludeR then
        showRocket = true
        rootCount = rootCount + 1
    end

    local rootPadding = 2 * VH
    local rootSize = (yRemaining - rootPadding) / rootCount
    if showAtmo then
        drawMeter(backgroundLayer, maskingLayer, {xOff + rootPadding, yOff + rootPadding, xRemaining - rootPadding * 2, rootSize - rootPadding}, input.fuel.atmo, ATMO_COLOR)
        yOff = yOff + rootSize
    end
    if showSpace then
        drawMeter(backgroundLayer, maskingLayer, {xOff + rootPadding, yOff + rootPadding, xRemaining - rootPadding * 2, rootSize - rootPadding}, input.fuel.space, SPACE_COLOR)
        yOff = yOff + rootSize
    end
    if showRocket then
        drawMeter(backgroundLayer, maskingLayer, {xOff + rootPadding, yOff + rootPadding, xRemaining - rootPadding * 2, rootSize - rootPadding}, input.fuel.rocket, ROCKET_COLOR)
        yOff = yOff + rootSize
    end

elseif persistent.view == "options" then
    yRemaining = yRemaining - uiSize -- leave room for status message
    local foreground = {0, 1, 0, 1}
    local oX, oY, oW, oH = drawGroup(backgroundLayer, "Options", 2 * VH, VH / 2, 2 * VH, BACKGROUND_COLOR, foreground, xOff, yOff, xRemaining, yRemaining, 4 * VH)

    local g1X, g1Y, g1W, g1H = drawGroup(backgroundLayer, "Fuel", 2 * VH, VH / 2, 2 * VH, BACKGROUND_COLOR, foreground, oX, oY, oW / 2, oH, 3 * VH)
    local fuelOptions = {
        -- {"groupByPrefix", "Group Tanks"}, -- TODO implement and enable
        {"showNames", "Show Tank Names"},
    }
    -- TODO implement and enable
    -- if persistent.fuelOptions.groupByPrefix then
    --     table.insert(fuelOptions, 2, {"showWidget", "Show Widget"})
    -- end
    -- only show exclude options for available tanks and when there is another tank type that could be shown
    if input.fuel and input.fuel.atmo and (input.fuel.space or input.fuel.rocket) then
        table.insert(fuelOptions, {"excludeA", "Exclude Atmo"})
    end
    if input.fuel and input.fuel.space and (input.fuel.atmo or input.fuel.rocket) then
        table.insert(fuelOptions, {"excludeS", "Exclude Space"})
    end
    if input.fuel and input.fuel.rocket and (input.fuel.atmo or input.fuel.space) then
        table.insert(fuelOptions, {"excludeR", "Exclude Rocket"})
    end
    addOptions(interfaceLayer, persistent.fuelOptions, fuelOptions, 10, {g1X, g1Y, g1W, g1H})

    local g2X, g2Y, g2W, g2H = drawGroup(backgroundLayer, "General", 2 * VH, VH / 2, 2 * VH, BACKGROUND_COLOR, foreground, oX + oW / 2, oY, oW / 2, oH, 3 * VH)
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
end

if cX >= 0 then
    requestAnimationFrame(5)
else
    requestAnimationFrame(40)
end


if debug then
    logMessage(string.format("Final render cost: %d / %d", getRenderCost(), getRenderCostMax()))
    logMessage(string.format("Timers: optionsUpdate: %f", persistent.optionsUpdateTime or -1))
end

-- rebuild and report output
setOutput(json.encode(output))

