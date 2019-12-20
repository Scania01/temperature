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
    [`XMAS`] = {2, -1.9, -4},
    [`SNOWLIGHT`] = {2, -1.9, -2},
    [`BLIZZARD`] = {2, -1.9, -2},
    ['default'] = {3, -1.9, 20}
}

local current_config = config['default']
local current_temp = 0

local weather_refresh_rate = 5000
local temp_refresh_rate = 10000

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

function update()
    local x = GetClockHours()
    local minutes = GetClockMinutes()
    x = x + (minutes / 60)

    current_temp = temperature(x)
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
        update()
        Citizen.Wait(temp_refresh_rate)
    end
end)

local units = { 'Fahrenheit', 'Celsius' }
local suffixes = { ' °F', ' °C' }

-- Units

function setCurrentUnit(x)
    SetResourceKvpInt('unit', x)
end

function getCurrentUnit()
    return GetResourceKvpInt('unit')
end

function getCurrentUnitName()
    return units[getCurrentUnit()]
end

function getCurrentUnitSuffix()
    return suffixes[getCurrentUnit()]
end

-- Helper functions
function celsiusToFahrenheit(x)
    return (9/5)*x + 32
end

function round(num)
    numDecimalPlaces = 1
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
  end

function processOutput(output, unit)
    local suffix = suffixes[unit]
    if unit == nil then
        suffix = getCurrentUnitSuffix()
    end
    return round(output) .. suffix
end


-- Temperatures
function getCurrentTemperatureFahrenheit()
    return processOutput(celsiusToFahrenheit(current_temp), 1)
end

function getCurrentTemperatureCelsius()
    return processOutput(current_temp, 2)
end

function getCurrentTemperature(x)
    if x ~= nil then
        preference = x
    else
        preference = getCurrentUnit()
    end

    if (preference == 1) then
        return getCurrentTemperatureFahrenheit()
    elseif (preference == 2) then
        return getCurrentTemperatureCelsius()
    else
        return getCurrentTemperatureFahrenheit()
    end
end

-- Command

function drawNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(0,1)
end


RegisterCommand("temperature", function(source, args)
    local inputs = { ['F'] = 1, ['C'] = 2 }
    local unit = args[1]

    if inputs[unit] == nil then
        drawNotification('~r~You must use one of the following: C, F')
        return
    else
        setCurrentUnit(inputs[unit])
        update()
        drawNotification('~p~Set unit to ' .. unit)
    end
end)

-- Exports

exports('getCurrentTemperature', getCurrentTemperature)

-- x: F = 1, C = 2
exports('getRawTemperature', function(x)
    if x == 1 then
        return celsiusToFahrenheit(current_temp)
    elseif x == 2 then
        return current_temp
    else
        return current_temp
    end
end)