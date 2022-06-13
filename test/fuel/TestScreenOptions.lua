#!/usr/bin/env lua
--- Display tests for general options

package.path = "src/?.lua;" .. package.path -- add src directory
package.path = "test/?.lua;" .. package.path -- add test directory
package.path = package.path .. ";../du-mocks/src/?.lua" -- add fallback to du-mocks project (if not installed on path)
package.path = "../game-data-lua/?.lua;" .. package.path -- add link to Dual Universe/Game/data/lua/ directory

local lu = require("luaunit")
local json = require("dkjson")

require("CommonScreen")
local HTML_ALL_OUTPUT_FILE = IMAGE_OUTPUT_DIR .. "options-all.html"

local mockRenderScript = require("dumocks.RenderScript")

_G.TestScreenOptions = {}

--- Generate screen images for various configurations, saving as a sample image and grid of test outputs.
function _G.TestScreenOptions:testDisplay()

    local displayConfigurations = {
        function(renderScript, environment)
            renderScript.input = json.encode({
                options = {}
            })
            environment.persistent = {
                power = false,
                view = "options"
            }
            return "Power Off"
        end,
        function(renderScript, environment)
            renderScript.input = json.encode({
                options = {
                    uiSmall = true
                }
            })
            environment.persistent = {
                power = false,
                view = "options"
            }
            return "Power Off, Small UI"
        end,
        function(renderScript, environment)
            renderScript.input = json.encode({
                options = {}
            })
            environment.persistent = {
                power = false,
                view = "options"
            }
            renderScript.mouseX = renderScript.resolution.x * 0.98
            renderScript.mouseY = renderScript.resolution.y * 0.98
            return "Power Off, Mouseover"
        end,
        function(renderScript, environment)
            renderScript.input = json.encode({
                options = {
                    powerToggle = true
                }
            })
            environment.persistent = {
                power = true,
                view = "options"
            }
            renderScript.mouseX = renderScript.resolution.x * 0.98
            renderScript.mouseY = renderScript.resolution.y * 0.98
            return "Power On, Mouseover"
        end,
        function(renderScript, environment)
            renderScript.input = json.encode({
                options = {}
            })
            environment.persistent = {
                power = true,
                view = "options"
            }
            renderScript.mouseX = renderScript.resolution.x * 0.98
            renderScript.mouseY = renderScript.resolution.y * 0.02
            return "Menu Button, Mouseover"
        end,
        function(renderScript, environment)
            renderScript.input = json.encode({
                options = {
                    header = true
                }
            })
            environment.persistent = {
                power = true,
                view = "options"
            }
            return "Options, Header On"
        end,
        function(renderScript, environment)
            renderScript.input = json.encode({
                options = {
                    header = true
                }
            })
            environment.persistent = {
                power = true,
                view = "options"
            }
            renderScript.mouseX = renderScript.resolution.x * 0.98
            renderScript.mouseY = renderScript.resolution.y * 0.02
            return "Header Menu Button, Mouseover"
        end,
        function(renderScript, environment)
            renderScript.input = json.encode({
                options = {
                    powerToggle = true
                }
            })
            environment.persistent = {
                power = true,
                view = "options"
            }
            return "Options, Power Button Enabled"
        end,
        function(renderScript, environment)
            renderScript.input = json.encode({
                options = {
                    toggleInactive = true
                }
            })
            environment.persistent = {
                power = true,
                view = "options"
            }
            return "Options, Toggle with Controller"
        end,
        function(renderScript, environment)
            renderScript.input = json.encode({
                options = {
                    header = true,
                    powerToggle = true,
                    uiSmall = true
                }
            })
            environment.persistent = {
                power = true,
                view = "options"
            }
            return "Options, Small UI"
        end,
        function(renderScript, environment)
            renderScript.input = json.encode({
                options = {
                    header = false
                }
            })
            environment.persistent = {
                power = true,
                view = "options",
                options = {
                    header = true
                }
            }
            return "Options, Modified"
        end,
        function(renderScript, environment)
            renderScript.input = json.encode({
                options = {
                    header = false
                }
            })
            environment.persistent = {
                power = true,
                view = "options",
                options = {
                    header = true
                }
            }
            -- TODO fix condition mocking
            renderScript.deltaTime = 15
            return "Options, Save Timeout"
        end,
        -- TODO mouseover option item (selected and not)
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
