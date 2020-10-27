# DU Ship Displays

Info and control screens for Dual Universe ships.

## Antigravity

<TODO> image
<TODO> features

Requirements:

* Anti-Gravity Generator (of appropriate size for ship core and with the appropriate number of pulsors linked to it)
* 1x Programming Board
* 1x Screen
* Databank (optional, for remembering controller state between sessions)

Install/Use Instructions:

1. Either build a json configuration (see Building from a Template below) or copy the one [TODO link](here) and paste it as a Lua configuration into the programming board.
2. Link the screen to the agScreen slot.
3. Add links to the Anti-Gravity Generator, the Dynamic Core Unit, and the Databank if you have one. Order doesn't matter unless you edit the unit start handler to specify what slot is what instead of allowing it to autodetect themj.
4. Activate the programming board, either directly or with a signal.
5. Get in the control seat of the ship so the ship is under control, then use the screen to adjust the antigravity.

Troubleshooting:

Anti-Gravity Generator doesn't lift ship:

* Make sure it's activated: if the power button on the top right section has a red ring instead of a green bar click on it to turn on the Anti-Gravity Generator element.
* Make sure you have enough pulsors placed and that they are linked to the Anti-Gravity Generator.
* Make sure you're at no less than 1,000m altitude.
* Bring the base altitude down to your current altitude, then raise it back up once the anti-gravity effect kicks in.
* The ship isn't under active control: either sit in the controller seat or activate a remote controller.

Can't edit altitude:

* Make sure the programming board is turned on: either enable it before you get in the control seat or use a switch or other element to send an on signal to it.
* If a green lock icon is in the top left corner then the controls are locked. Click on it and drag to the right to unlock.

## Building from a Template

This project is designed to be used with my other du project, [https://github.com/1337joe/du-bundler](DU Bundler).

Documentation of the bundler is at the above link, but to put it simply you need to be able to run Lua scripts and simply call `bundleTemplate.lua template.json` and it will build a json configuration based on the template. On Linux this can be piped to `xclip -selection c` to put it directly on the clipboard, while on Windows piping to `clip.exe` should do the same thing. Alternately, you can write it to a file and copy from there.

If you don't have a Lua runtime set up the easiest solution is to copy from the configurations hosted on [TODO link] my website. Each template included in the repository is built automatically on update and uploaded there. The alternative is manually replacing the tags (`${tag}`) according to the rules of the templater.

`logo.svg` may be replaced with your corporation logo (or any other logo you like) to embed that logo in the screens on build from template. To keep git from tracking changes to this file run `git update-index --assume-unchanged logo.svg`. If you want to update the logo without using the templater simply paste your logo SVG into the value of the LOGO_SVG variable in-game or use find-replace on the exported json.

## Developer Dependencies

lunit (for testing)
du-mocks (for testing)
du-bundler (for exporting to json)

## Support

If you encounter bugs or any of my instructions don't work either send me a message or file a GitHub Issue (or fork the project, fix it, and send me a pull request).

Discord: 1337joe#6186
In-Game: W3asel

My game/coding time is limited so I can't promise a quick response.
