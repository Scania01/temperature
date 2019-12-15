# Temperature
FiveM resource that exports functions for simulating temperature based on time of day, weather and location.

The temperature follows a sine wave pattern to simulate a peak and trough throughout the day. Each weather cycle in GTA 5 has its own pattern, which you can configure.

## Exported functions

This doesn't actually display anything to the user, it just exports functions which you'll have to use in your own resource, for example drawing it on a HUD.

* `getCurrentTemperature(unit)`

    **`unit` argument is optional**, if not specified then it will return the user's preference

    Returns a rounded temperature with the unit specified after, e.g. `21.2 °C`

* `getRawTemperature()`

    Returns the raw and live calculated temperature (celsius)

