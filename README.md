# DU Ship Displays

Info and control screens for Dual Universe ships.

Only the basic screens are linked here. For full galleries of available screens view my [project web page](https://du.w3asel.com/du-ship-displays).

## Antigravity

[<img src="https://du.w3asel.com/du-ship-displays/images/antigravity-basic.svg" width="50%" alt="Basic Anti-Gravity Display">](https://du.w3asel.com/du-ship-displays/templates/antigravity-basic.json)

### Features/Controls:

* All anti-gravity measurements and controls on one screen.
* Set target altitude by dragging the arrow on the left side of the altitude scale or with the up and down arrows. Left/right arrows select the digit to change to step at anywhere from 1 to 10,000 m increments.
  * The altitude scale is logarithmic for more control at lower altitudes.
* Snap target altitude to current altitude in one click on the current altitude slider.
* Lock controls to prevent accidental clicks by clicking on the lock icon.
* Power on and unlock protected by a drag-to-activate mechanism to prevent accidental disabling.

### Requirements:

* Anti-Gravity Generator (of appropriate size for ship core and with the appropriate number of pulsors linked to it)
* 1x Programming Board
* 1x Screen
* Databank (optional, for remembering controller state between sessions)

### Install/Use Instructions:

[Pre-built lua config](https://du.w3asel.com/du-ship-displays/templates/antigravity-basic.json)

1. Either build a json configuration (see Building from a Template below) or copy the one above and paste it as a Lua configuration into the programming board.
2. Link the screen to the agScreen slot.
3. Add links to the Anti-Gravity Generator, the Dynamic Core Unit, and the Databank if you have one. Order doesn't matter unless you edit the unit start handler to specify what slot is what instead of allowing it to autodetect them.
4. Activate the programming board, either directly or with a signal.
5. Get in the control seat of the ship so the ship is under control, then use the screen to adjust the antigravity.

### Troubleshooting:

#### Anti-Gravity Generator doesn't lift ship:

* Make sure it's activated: if the power button on the top right section has a red ring instead of a green bar click on it to turn on the Anti-Gravity Generator element.
* Make sure you have enough pulsors placed and that they are linked to the Anti-Gravity Generator.
* Make sure you're at no less than 1,000m altitude.
* Make sure the current base altitude is within 500m of ship altitude. It may take some time to get there.
* The ship isn't under active control: either sit in the controller seat or activate a remote controller.
* In some cases it may be necessary to unlink the pulsors from the Anti-Gravity Generator and re-link them if nothing else works.

#### Can't edit altitude:

* Make sure the programming board is turned on: either enable it before you get in the control seat or use a switch or other element to send an on signal to it.
* If a green lock icon is in the top left corner then the controls are locked. Click on it and drag to the right to unlock.

## _Semi-Abandoned / Work in Progress_ Ship Health

[<img src="https://du.w3asel.com/du-ship-displays/images/ship-health-basic.svg" width="50%" alt="Basic Ship Health Display">](https://du.w3asel.com/du-ship-displays/templates/ship-health-basic.json)

### Features/Controls:

* View health of elements in tabular or graphical/point cloud views.
* Filter to only view broken/damaged/healthy elements.
* Select elements (table only) to highlight them in graphical views and display arrows pointing to them in 3d space.
* Table view can be sorted by any column.
* Element loading handles large ships, rendering may or may not. (batching not yet fully implemented)
* Custom ship outlines possible for drawing under the point cloud representation. (documentation not written)

### Requirements:

* 1x Programming Board
* 1x Screen
* Databank (optional but highly recommended, for remembering controller state between sessions)

### Install/Use Instructions:

[Pre-built lua config](https://du.w3asel.com/du-ship-displays/templates/ship-health-basic.json)

1. Either build a json configuration (see Building from a Template below) or copy the one above and paste it as a Lua configuration into the programming board.
2. Link the screen to the hpScreen slot.
3. Add links to the Dynamic Core Unit and the Databank if you have one. Order of these doesn't matter unless you edit the unit start handler to specify what slot is what instead of allowing it to autodetect them.
4. Activate the programming board, either directly or with a signal.
5. TODO complete

### Advanced Usage: Custom Ship Outlines

TODO explain process, link to example

## Building from a Template

This project is designed to be used with my other Dual Universe project [DU Bundler](https://github.com/1337joe/du-bundler), which can be installed by calling `luarocks install du-bundler`.

Documentation of the bundler is at the above link, but to put it simply you need to be able to run Lua scripts and simply call `bundleTemplate.lua template.json` (with appropriate paths for file locations) and it will build a json configuration based on the template. On Linux this can be piped to `xclip -selection c` to put it directly on the clipboard, while on Windows piping to `clip.exe` should do the same thing. Alternately, you can write it to a file and copy from there.

If you don't have a Lua runtime set up the easiest solution is to copy from the configurations hosted on the [project page on my website](https://du.w3asel.com/du-ship-displays/). Each template included in the repository is built automatically on update and uploaded there. The alternative is manually replacing the tags (`${tag}`) according to the rules of the templater.

`logo.svg` may be replaced with your organization logo (or any other logo you like) to embed that logo in the screens on build from template. To keep git from tracking changes to this file run `git update-index --assume-unchanged logo.svg`. If you want to update the logo without using the templater simply paste your logo SVG into the value of the LOGO_SVG variable in-game or use find-replace on the exported json.

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
