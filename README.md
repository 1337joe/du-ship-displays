# DU Ship Displays

[![Tests](https://github.com/1337joe/du-ship-displays/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/1337joe/du-ship-displays/actions/workflows/test.yml)
[![Coverage](https://codecov.io/gh/1337joe/du-ship-displays/branch/main/graph/badge.svg)](https://codecov.io/gh/1337joe/du-ship-displays)

Info and control screens for Dual Universe ships.

Only the basic screens are linked here. For feature lists, full galleries of available screens, or troubleshooting tips view the [project page](https://1337joe.github.io/du-ship-displays) or click on the screen section headers.

## [Antigravity Controller](https://1337joe.github.io/du-ship-displays#antigravity)

[<img src="https://1337joe.github.io/du-ship-displays/images/antigravity-basic.svg" width="50%" alt="Basic Anti-Gravity Display">](https://1337joe.github.io/du-ship-displays/templates/antigravity-basic.json)

### Install/Use Instructions

1. Either build a json configuration (see Building from a Template below) or copy the one linked from the above image and paste it as a Lua configuration into the programming board.
2. Link the screen to the agScreen slot.
3. Add links to the Anti-Gravity Generator, the Dynamic Core Unit, and the Databank if you have one. Order doesn't matter unless you edit the unit start handler to specify what slot is what instead of allowing it to autodetect them.
4. Activate the programming board, either directly or with a signal.
5. Get in the control seat of the ship so the ship is under control, then use the screen to adjust the antigravity.

## [_Work-in-Progress_ Fuel Display](https://1337joe.github.io/du-ship-displays#fuel)

[<img src="https://1337joe.github.io/du-ship-displays/images/fuel.svg" width="50%" alt="Fuel Display">](https://1337joe.github.io/du-ship-displays/templates/fuel-basic.json)

### Install/Use Instructions

1. Either build a json configuration (see Building from a Template below) or copy the one linked from the above image and paste it as a Lua configuration into the programming board.
2. Copy src/fuel/fuel.screen.lua to a screen and set it to Lua mode.
3. Link the programming board to the screen, Core Unit, Databank if you have one, and (optional) at least one of each type of fuel tank to be monitored.
4. Activate the programming board, either directly or with a signal.

## [_Semi-Abandoned / Work in Progress_ Ship Health Display](https://1337joe.github.io/du-ship-displays#ship-health)

[<img src="https://1337joe.github.io/du-ship-displays/images/ship-health-basic.svg" width="50%" alt="Basic Ship Health Display">](https://1337joe.github.io/du-ship-displays/templates/ship-health-basic.json)

### Install/Use Instructions

1. Either build a json configuration (see Building from a Template below) or copy the one linked from the above image and paste it as a Lua configuration into the programming board.
2. Link the screen to the hpScreen slot.
3. Add links to the Dynamic Core Unit and the Databank if you have one. Order of these doesn't matter unless you edit the unit start handler to specify what slot is what instead of allowing it to autodetect them.
4. Activate the programming board, either directly or with a signal.
5. Interact with the screen to access the data.

## Building from a Template

This project is designed to be used with my other Dual Universe project [DU Bundler](https://github.com/1337joe/du-bundler), which can be installed by calling `luarocks install du-bundler`.

Documentation of the bundler is at the above link, but to put it simply you need to be able to run Lua scripts and simply call `bundleTemplate.lua template.json` (with appropriate paths for file locations) and it will build a json configuration based on the template. On Linux this can be piped to `xclip -selection c` to put it directly on the clipboard, while on Windows piping to `clip.exe` should do the same thing. Alternately, you can write it to a file and copy from there.

If you don't have a Lua runtime set up the easiest solution is to copy from the configurations hosted on the [project page](https://1337joe.github.io/du-ship-displays/). Each template included in the repository is built automatically on update and uploaded there. The alternative is manually replacing the tags (`${tag}`) according to the rules of the templater.

## Developer Dependencies

Luarocks can be used to install all dependencies besides `game-data-lua`: `luarocks install --only-deps du-ship-displays-scm-0.rockspec`

* [luaunit](https://github.com/bluebird75/luaunit): For automated testing.

* [luacov](https://keplerproject.github.io/luacov/): For tracking code coverage when running all tests. Can be removed from `runTests.sh` if not desired. To view results using luacov-html (which is a separate package) simply run `luacov -r html` after running tests and open `luacov-html/index.html`.

* [DU Mocks](https://github.com/1337joe/du-mocks): For automated testing. This will fall back to (from the project root) `../du-mocks` if not installed.

* [du-bundler](https://github.com/1337joe/du-bundler): For exporting templates to json to paste into Dual Universe.

* Dual Universe/Game/data/lua: For automated testing, link or copy your C:\ProgramData\Dual Universe\Game\data\lua directory to ../game-data-lua relative to within the root directory of the project.

## Support

If you encounter bugs or any of my instructions don't work either send me a message or file a GitHub Issue (or fork the project, fix it, and send me a pull request).

Discord channel: [du-ship-displays on DU Open Source Initiative](https://discord.gg/uhXRgw86k7)

Discord: 1337joe#6186

In-Game: W3asel

My game/coding time is often limited so I can't promise a quick response.
