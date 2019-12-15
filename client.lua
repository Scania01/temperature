-- Authored by Jam, December 2019

-- Temperature pattern is a sine wave
-- VARIABLES:
-- a: Amplitude, variance in temp (max temp is a + d, min temp is a - d)  
-- b: Time period, shouldn't change this as it ensures continuity
-- c: Offset
-- d: Average temp.

local b = (math.pi)/12

local params = {
  --[`WEATHER_NAME`] = [a, c, d]
    [`EXTRASUNNY`] = {6, -1.9, 24},
    ['default'] = {3, -1.9, 200}
}

local current_params = params['default']
local current_temp = 0

local weather_refresh_rate = 5000
local temp_refresh_rate = 30000

function getCurrentTempParams()
    local current = params[GetPrevWeatherTypeHashName()]
    if current == nil then
        return params['default']
    end
    return params[GetPrevWeatherTypeHashName()]
end

function temperature(x)
    a, c, d = table.unpack(current_params)
    return a*(math.sin(b*x+c))+d
end

-- Weather refresher
Citizen.CreateThread(function()
    while true do
        current_params = getCurrentTempParams()
        Citizen.Wait(weather_refresh_rate)
    end
end)

-- Temperature refresher
Citizen.CreateThread(function()
    while true do
        local x = GetClockHours()
        local minutes = GetClockMinutes()
        x = x + (minutes / 60)

        current_temp = temperature(x)
        Citizen.Trace(current_temp)

        Citizen.Wait(temp_refresh_rate)
    end
end)

-- Exports
exports('getCurrentTemperature', temperature())