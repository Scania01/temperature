# Temperature
FiveM resource that exports functions for simulating temperature based on time of day, weather and location.

The temperature follows a sine wave pattern to simulate a peak and trough throughout the day. Each weather cycle in GTA 5 has its own pattern, which you can configure.

Calculated temperatures will stay consistent for each player as long as the time is synchronised.

This resource is only for the client, none of the functions are available on the server.

## Exported functions

This doesn't actually display anything to the user, it just exports functions which you'll have to use in your own resource, for example drawing it on a HUD.

* `getCurrentTemperature(unit)`

    **`unit` argument is optional**, if not specified then it will return the user's preference

    Returns a rounded temperature with the unit specified after, e.g. `21.2 °C`

* `getRawTemperature(unit)`

    **`unit` argument is optional**, celsius by default

    Returns the raw and live calculated temperature.

### Example

Command:
```lua
RegisterCommand('temp', function(source, args)
    local msg = exports.temperature.getCurrentTemperature()
    TriggerEvent("chat:addMessage", { args = { msg }, color = {210,210,210} })
end, false)
```

Don't use this in a loop that runs every tick (`Citizen.Wait(0)`)!!! The temperature is only calculated once every 10 seconds, so this is not worth doing. 

Cache the result like this:

```lua
local temp = nil
Citizen.CreateThread(function()
    while true do
        temp = exports.temperature.getCurrentTemperature()
        Citizen.Wait(10000)
    end
end)
```
