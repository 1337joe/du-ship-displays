#!/usr/bin/env lua
--- Display tests for fuel.screen.lua

package.path = "src/?.lua;" .. package.path -- add src directory
package.path = "test/?.lua;" .. package.path -- add test directory
package.path = package.path .. ";../du-mocks/src/?.lua" -- add fallback to du-mocks project (if not installed on path)
package.path = "../game-data-lua/?.lua;" .. package.path -- add link to Dual Universe/Game/data/lua/ directory

local lu = require("luaunit")
local json = require("dkjson")

require("CommonScreen")
local SVG_SAMPLE_OUTPUT_FILE = IMAGE_OUTPUT_DIR .. "fuel.svg"
local HTML_ALL_OUTPUT_FILE = IMAGE_OUTPUT_DIR .. "fuel-all.html"

local mockRenderScript = require("dumocks.RenderScript")

_G.TestFuelScreen = {}

--- Generate screen images for various configurations, saving as a sample image and grid of test outputs.
function _G.TestFuelScreen:testDisplay()

    local defaultFuelTanks = {
        atmo = {
            name = "Atmo",
            children = {{
                name = "Tank 1",
                maxVol = 100,
                vol = 70
            }, {
                name = "Tank 2",
                maxVol = 400,
                vol = 325,
                timeLeft = 100
            }},
            maxVol = 500,
            vol = 395,
            timeLeft = 100
        },
        space = {
            name = "Tank 3",
            maxVol = 10000,
            vol = 570
        },
        rocket = {
            name = "Tank 4",
            maxVol = 1024,
            vol = 250,
            timeLeft = 32
        },
        options = {}
    }

    local function setOptions(fuelTanks, options)
        local fuelWithOptions = {}
        for type, data in pairs(fuelTanks) do
            fuelWithOptions[type] = data
        end
        fuelWithOptions.options = options
        return fuelWithOptions
    end

    local sampleDisplayConfiguration = 1
    local displayConfigurations = {
        function(renderScript)
            renderScript.input = json.encode({
                options = {},
                fuel = defaultFuelTanks
            })
            return "Sample, Default Settings"
        end,
        function(renderScript)
            renderScript.input = json.encode({
                options = {
                    header = true,
                },
                fuel = defaultFuelTanks
            })
            return "Sample, Header On"
        end,
        function(renderScript)
            renderScript.input = json.encode({
                options = {
                    header = true,
                    uiSmall = true
                },
                fuel = defaultFuelTanks
            })
            return "Sample, Small Header"
        end,
        function(renderScript, environment)
            renderScript.input = json.encode({
                options = {},
                fuel = defaultFuelTanks
            })
            environment.persistent = {
                power = true,
                view = "options"
            }
            return "Menu, Default Settings"
        end,
        function(renderScript, environment)
            renderScript.input = json.encode({
                options = {},
                fuel = defaultFuelTanks
            })
             environment.persistent = {
                power = true,
                view = "options",
                fuelOptions = {
                    showNames = true
                }
            }
            return "Menu, Modified"
        end,
        function(renderScript, environment)
            renderScript.input = json.encode({
                options = {},
                fuel = defaultFuelTanks
            })
            environment.persistent = {
                power = true,
                view = "options",
                fuelOptions = {
                    showNames = true
                }
            }
            -- TODO fix condition mocking
            return "Menu, Save Timeout"
        end,
        function(renderScript)
            renderScript.input = json.encode({
                options = {},
                fuel = setOptions(defaultFuelTanks, {showNames = true})
            })
            return "Sample, Labels On"
        end,
        function(renderScript, environment)
            renderScript.input = json.encode({
                options = {},
                fuel = setOptions(defaultFuelTanks, {showNames = true})
            })
            environment.persistent = {
                power = true,
                view = "options"
            }
            return "Menu, Labels On"
        end,
        function(renderScript)
            renderScript.input = json.encode({
                options = {},
                fuel = setOptions(defaultFuelTanks, {excludeA = true})
            })
            return "Sample, Exclude Atmo"
        end,
        function(renderScript, environment)
            renderScript.input = json.encode({
                options = {},
                fuel = setOptions(defaultFuelTanks, {excludeA = true})
            })
            environment.persistent = {
                power = true,
                view = "options"
            }
            return "Menu, Exclude Atmo"
        end,
        function(renderScript)
            renderScript.input = json.encode({
                options = {},
                fuel = setOptions(defaultFuelTanks, {excludeS = true})
            })
            return "Sample, Exclude Space"
        end,
        function(renderScript, environment)
            renderScript.input = json.encode({
                options = {},
                fuel = setOptions(defaultFuelTanks, {excludeS = true})
            })
            environment.persistent = {
                power = true,
                view = "options"
            }
            return "Menu, Exclude Space"
        end,
        function(renderScript)
            renderScript.input = json.encode({
                options = {},
                fuel = setOptions(defaultFuelTanks, {excludeR = true})
            })
            return "Sample, Exclude Rocket"
        end,
        function(renderScript, environment)
            renderScript.input = json.encode({
                options = {},
                fuel = setOptions(defaultFuelTanks, {excludeR = true})
            })
            environment.persistent = {
                power = true,
                view = "options"
            }
            return "Menu, Exclude Rocket"
        end,
        function(renderScript)
            renderScript.input = json.encode({
                options = {},
                fuel = {atmo = defaultFuelTanks.atmo}
            })
            return "Sample, Only Atmo"
        end,
        function(renderScript, environment)
            renderScript.input = json.encode({
                options = {},
                fuel = {atmo = defaultFuelTanks.atmo}
            })
            environment.persistent = {
                power = true,
                view = "options"
            }
            return "Menu, Only Atmo"
        end,
        function(renderScript)
            renderScript.input = json.encode({
                options = {},
                fuel = {rocket = defaultFuelTanks.rocket}
            })
            return "Sample, Only Rocket"
        end,
        function(renderScript, environment)
            renderScript.input = json.encode({
                options = {},
                fuel = {rocket = defaultFuelTanks.rocket}
            })
            environment.persistent = {
                power = true,
                view = "options"
            }
            return "Menu, Only Rocket"
        end,

        -- setup error states
        function(renderScript)
            renderScript.input = ""
            return "Empty Input"
        end,
        -- TODO element links missing (generic error message)
    }

    local allSvg = {}
    allSvg[#allSvg + 1] = HTML_HEADER

    local renderScript, environment, script
    local name, result, msg, actual, label
    for configKey, configuration in pairs(displayConfigurations) do


        renderScript = mockRenderScript:new()
        environment = renderScript:mockGetEnvironment()

        name = configuration(renderScript, environment)
        label = string.format("%s (%s)", configKey, name)

        result, script = pcall(loadfile, "src/fuel/fuel.screen.lua", "t", environment)
        lu.assertTrue(result, string.format("%s produced error: %s", label, script))

        result, msg = pcall(script)
        lu.assertTrue(result, string.format("%s produced error: %s", label, msg))

        -- TODO remove debug line, add tests for expected results of state/input/output combinations
        -- print(renderScript.output)

        actual = renderScript:mockGenerateSvg()
        lu.assertFalse(actual:len() == 0, string.format("%s produced no output.", label))

        if configKey == sampleDisplayConfiguration then
            -- save as file
            local outputHandle, errorMsg = io.open(SVG_SAMPLE_OUTPUT_FILE, "w")
            if errorMsg then
                error(errorMsg)
            else
                io.output(outputHandle):write(actual)
                outputHandle:close()
            end
        end

        allSvg[#allSvg + 1] = string.format(SVG_WRAPPER_TEMPLATE, label, actual)
    end

    allSvg[#allSvg + 1] = HTML_FOOTER

    -- save as file
    local outputHandle, errorMsg = io.open(HTML_ALL_OUTPUT_FILE, "w")
    if errorMsg then
        error(errorMsg)
    else
        io.output(outputHandle):write(table.concat(allSvg, "\n"))
        outputHandle:close()
    end
end

os.exit(lu.LuaUnit.run())
