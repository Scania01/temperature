-- Authored by Jam, December 2019

-- Temperature pattern is a sine wave, this is all configured in celsius, but will output to fahrenheit by default
-- VARIABLES:
-- a: Amplitude, variance in temp (max temp is a + d, min temp is a - d)  
-- b: Time period, shouldn't change this as it ensures continuity of temperature between days (no sudden jump at midnight)
-- c: Offset, translates wave left or right, determines when the max and min temperatures occur.
-- d: Average temp.

local b = (math.pi)/12

local config = {
  --[`WEATHER_NAME`] = [a, c, d], use the backtick string literal as these are converted to hashes automatically (no need for GetHashKey())
    [`EXTRASUNNY`] = {6, -1.9, 24},
    [`CLEAR`] = {3, -1.9, 22},
    [`OVERCAST`] = {1, -1.9, 20},
    [`CLOUDS`] = {1, -1.9, 20},
    [`RAIN`] = {0.9, -1.9, 19},
    [`CLEARING`] = {2.1, -1.9, 20},
    [`THUNDER`] = {0.9, -1.9, 19},
    [`SMOG`] = {0.9, -1.9, 19},
    [`FOGGY`] = {0.9, -1.9, 19},
    [`XMAS`] = {2, -1.9, -2},
    [`SNOWLIGHT`] = {2, -1.9, -2},
    [`BLIZZARD`] = {2, -1.9, -2},
    ['default'] = {3, -1.9, 20}
}

local current_config = config['default']
local current_temp = 0

local weather_refresh_rate = 5000
local temp_refresh_rate = 1000

function getCurrentTempParams()
    local current = config[GetPrevWeatherTypeHashName()]
    if current == nil then
        return config['default']
    end
    return current
end

function temperature(x)
    a, c, d = table.unpack(current_config)
    return a*(math.sin(b*x+c))+d
end

-- Weather refresher
Citizen.CreateThread(function()
    while true do
        current_config = getCurrentTempParams()
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
        Citizen.Trace(current_temp .. '\n')
        Citizen.Wait(temp_refresh_rate)
    end
end)

-- Helper functions
function celsiusToFahrenheit(x)
    return (5/9)*(x-32)
end

-- Exports
function getCurrentTemperateCelsius()
    return current_temp
end

function getCurrentTemperatureFahrenheit()
    return celsiusToFahrenheit(current_temp)
end

function getCurrentTemperateKelvin()
    return current_temp + 273.13
end

local functions = {
    getCurrentTemperatureFahrenheit,
    getCurrentTemperatureCelsius,
    getCurrentTemperateKelvin
}

function getUserPreferredFunction()
    local preference = GetResourceKvpInt('unit')
    return functions[preference]
end

exports('getCurrentTemperature', getUserPreferredFunction)

exports('getCurrentTemperatureCelsius', getCurrentTemperateCelsius)

exports('getCurrentTemperatureFahrenheit', getCurrentTemperatureFahrenheit)

exports('getCurrentTemperateKelvin', getCurrentTemperateKelvin)