# General

* ???
  * Preferences stored to databank (if available), set useParameterSettings true to override from exported parameters.

# Antigravity

* ???
  * Added minimum g parameter to turn off altitude/vertical velocity data when too far from a planet.
* 2020-11-29
  * Added fix for negative altitude display
  * Fix for current altitude displaying 0 when too far from planet but still within gravity well
  * Vertical velocity now is signed: positive for up, negative for down
* 2020-11-18
  * Added flush handling to quickly set base altitude to target altitude while AGG is turned off
  * Added warning message to explain 0 power level
* 2020-11-13
  * Changed target altitude databank key to match ButtonsHud for interoperability
* 2020-11-11
  * Added bannerless variant
  * Use databank value of targetAltitude if available to allow multiple screens to stay in sync
* 2020-11-02
  * Basic antigravity display published
