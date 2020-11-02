# DU Ship Displays

Info and control screens for Dual Universe ships.

## Antigravity

![basic](https://du.w3asel.com/du-ship-displays/images/antigravity-basic.svg "Basic Anti-Gravity Display")

Features:

* All anti-gravity measurements and controls on one screen.
* Logarithmic altitude scale for more control at lower altitudes.
* Set target altitude with a slider or step at any power of 10 from 1 to 10,000 meters.
* Set target altitude to current altitude in one click.
* Lock controls to prevent accidental clicks.
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
* Bring the base altitude down to your current altitude, then raise it back up once the anti-gravity effect kicks in.
* The ship isn't under active control: either sit in the controller seat or activate a remote controller.

#### Can't edit altitude:

* Make sure the programming board is turned on: either enable it before you get in the control seat or use a switch or other element to send an on signal to it.
* If a green lock icon is in the top left corner then the controls are locked. Click on it and drag to the right to unlock.

#### Altitude displays "N/A" over a certain altitude:

The core unit stops reporting altitude in space, even when the default user hud shows an altitude. This is planned to be fixed in the future by importing the atlas and calculating altitude when it's not provided by the core unit. The antigravity generator will continue to raise the ship under this condition, but clicking on the current side of the slider will reset the target altitude to 0.

## Building from a Template

This project is designed to be used with my other Dual Universe project: [DU Bundler](https://github.com/1337joe/du-bundler).

Documentation of the bundler is at the above link, but to put it simply you need to be able to run Lua scripts and simply call `bundleTemplate.lua template.json` (with appropriate paths for file locations) and it will build a json configuration based on the template. On Linux this can be piped to `xclip -selection c` to put it directly on the clipboard, while on Windows piping to `clip.exe` should do the same thing. Alternately, you can write it to a file and copy from there.

If you don't have a Lua runtime set up the easiest solution is to copy from the configurations hosted on the [project page on my website](https://du.w3asel.com/du-ship-displays/). Each template included in the repository is built automatically on update and uploaded there. The alternative is manually replacing the tags (`${tag}`) according to the rules of the templater.

`logo.svg` may be replaced with your organization logo (or any other logo you like) to embed that logo in the screens on build from template. To keep git from tracking changes to this file run `git update-index --assume-unchanged logo.svg`. If you want to update the logo without using the templater simply paste your logo SVG into the value of the LOGO_SVG variable in-game or use find-replace on the exported json.

## Developer Dependencies

[DU Bundler](https://github.com/1337joe/du-bundler): For exporting to json.

luaunit: For automated testing. Note that this is only available on luarocks for lua 5.3. If your primary lua install is 5.4 you can install against 5.3 but you'll have to modify the `runTests.sh` script to call `lua5.3` instead of `lua`.

[DU Mocks](https://github.com/1337joe/du-mocks): For automated testing. Currently assumes that this is located from the project root at `../du-mocks`.

luacov: For tracking code coverage when running all tests. Can be removed from `runTests.sh` if not desired.

## Support

If you encounter bugs or any of my instructions don't work either send me a message or file a GitHub Issue (or fork the project, fix it, and send me a pull request).

Discord: 1337joe#6186

In-Game: W3asel

My game/coding time is often limited so I can't promise a quick response.
