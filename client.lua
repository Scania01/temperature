-- Temperature pattern is a sine wave
-- a: Amplitude, variance in temp (max temp is a + d, min temp is a - d)  
-- b: Time period, shouldn't change this as it ensures continuity
-- c: Offset
-- d: Average temp.

local b = (math.pi)/12

local params = {
  --['WEATHER_NAME'] = [a, b, c, d]
    ['EXTRASUNNY'] = {6, -1.9, 24},
    ['default'] = {3, -1.9, 20}
}

function getCurrentTempParams()
    return params['EXTRASUNNY']
end

function temperature(x)
    a, c, d = table.unpack(getCurrentTempParams())
    return a*(math.sin(b*x+c))+d
end

Citizen.CreateThread(function()
    while true do
        local x = GetClockHours()
        local minutes = GetClockMinutes()
        x = x + (minutes / 60)
        Citizen.Trace(temperature(x) .. '\n')
        Citizen.Wait(5000)
    end
end)