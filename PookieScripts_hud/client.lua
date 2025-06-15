local peacetimeActive = false
local aop = "Sandy Shores"
local priority = { text = "Available", class = "hud-prio-available" }
local prioCooldown = 0
local prioInProgress = false
local prioOnHold = false
local displaysHidden = false
local postal = "N/A"
local streetName = "Unknown"
local zone = "Unknown"
local peacetimeStatus = "Peacetime: Disabled"
local speedText = "0 MPH"

RegisterNetEvent("peacetime:setState", function(isEnabled)
    peacetimeActive = isEnabled

    -- Show notification
    if isEnabled then
        TriggerEvent("okokNotify:Alert", "Peacetime Enabled", "You can not Shoot or do violent Rp", 10000, "info")
    else
        TriggerEvent("okokNotify:Alert", "Peacetime Disabled", "You can now Shoot and do violent Rp", 10000, "warning")
    end

    -- Update UI
    SendNUIMessage({
        type = "peacetimeUI",
        state = isEnabled
    })
end)

-- Disable shooting if peacetime is active
Citizen.CreateThread(function()
    while true do
        if peacetimeActive then
            -- Disable firing and weapon usage
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 140, true) -- Melee attack
            DisableControlAction(0, 142, true) -- Melee attack alt
            DisableControlAction(0, 257, true) -- Melee (R key)
            DisableControlAction(0, 263, true) -- Disable free-aim
            DisablePlayerFiring(PlayerPedId(), true)
        end
        Wait(0)
    end
end)

RegisterNetEvent('blrp:setAOP')
AddEventHandler('blrp:setAOP', function(newAOP)
    aop = newAOP
end)

RegisterNetEvent('BLRSP_Peacetime:PriorityUpdate')
AddEventHandler('BLRSP_Peacetime:PriorityUpdate', function(inProgress, onHold, cooldown)
    prioInProgress = inProgress
    prioOnHold = onHold
    prioCooldown = cooldown
    if prioInProgress then
        priority = { text = "In Progress", class = "hud-prio-inprogress" }
    elseif prioOnHold then
        priority = { text = "On Hold", class = "hud-prio-onhold" }
    elseif prioCooldown > 0 then
        priority = { text = ("Cooldown: %d min"):format(prioCooldown), class = "hud-prio-cooldown" }
    else
        priority = { text = "Available", class = "hud-prio-available" }
    end
end)

RegisterCommand("setaop", function(source, args)
    if #args > 0 then
        aop = table.concat(args, " ")
        TriggerEvent('chat:addMessage', {
            color = { 0, 255, 0 },
            multiline = true,
            args = { "^2AOP", "AOP set to: " .. aop }
        })
    end
end, false)

-- Death screen logic
local deadCheck = false
Citizen.CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        if IsEntityDead(ped) then
            -- Death screen display
            Draw2DText(0.5, 0.05, "~r~You have been rendered dead or unconscious!", 0.8, true)
            Draw2DText(0.5, 0.1, "~w~If you were knocked out, you may use ~g~/revive~w~!", 0.8, true)
            Draw2DText(0.5, 0.15, "~w~If you are dead, you must use ~g~/respawn~w~!", 0.8, true)
            if not deadCheck then
                deadCheck = true
                -- Optionally trigger server event here if needed
            end
        else
            deadCheck = false
        end
    end
end)

-- Postal, zone, speed, peacetime status update (no street)
Citizen.CreateThread(function()
    -- Wait for Postals table to be loaded and valid
    while Postals == nil or type(Postals) ~= "table" or #Postals == 0 do
        Citizen.Wait(100)
    end
    while true do
        Citizen.Wait(500)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        -- Postal logic (find nearest, using correct x/y)
        local nearest, nearestDist = nil, math.huge
        for _, p in ipairs(Postals) do
            local dist = (coords.x - p.x) ^ 2 + (coords.y - p.y) ^ 2
            if dist < nearestDist then
                nearest = p
                nearestDist = dist
            end
        end
        if nearest and nearest.code then
            postal = tostring(nearest.code)
        else
            postal = "N/A"
        end

        zone = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
        peacetimeStatus = peacetimeActive and "Peacetime: Enabled" or "Peacetime: Disabled"
        local speed = math.floor(GetEntitySpeed(ped) * 2.236936)
        speedText = string.format("%d MPH", speed)

        -- Only send postal (no street/location) to UI
        SendNUIMessage({
            type = "updateHUD",
            aop = aop,
            priority = priority,
            postal = postal,
            zone = string.format("%s | %s", zone, peacetimeStatus),
            speed = speedText
        })
    end
end)

-- Postal, zone, speed, peacetime status update (with street)
Citizen.CreateThread(function()
    -- Wait for Postals table to be loaded and valid
    while Postals == nil or type(Postals) ~= "table" or #Postals == 0 do
        Citizen.Wait(100)
    end
    while true do
        Citizen.Wait(500)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        -- Postal logic (find nearest, using correct x/y)
        local nearest, nearestDist = nil, math.huge
        for _, p in ipairs(Postals) do
            local dist = (coords.x - p.x) ^ 2 + (coords.y - p.y) ^ 2
            if dist < nearestDist then
                nearest = p
                nearestDist = dist
            end
        end
        if nearest and nearest.code then
            postal = tostring(nearest.code)
        else
            postal = "N/A"
        end

        streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
        zone = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
        peacetimeStatus = peacetimeActive and "Peacetime: Enabled" or "Peacetime: Disabled"
        local speed = math.floor(GetEntitySpeed(ped) * 2.236936)
        speedText = string.format("%d MPH", speed)

        -- Always send postal and street to UI
        SendNUIMessage({
            type = "updateHUD",
            aop = aop,
            priority = priority,
            postal = postal,
            location = streetName,
            zone = string.format("%s | %s", zone, peacetimeStatus),
            speed = speedText
        })
        -- Debug print
        -- print("Postal:", postal, "Coords:", coords.x, coords.y, "Nearest:", nearest and (nearest.x .. "," .. nearest.y .. " " .. nearest.code) or "nil")
    end
end)
