local isPeacetime = false
local inProgress = false
local onHold = false
local currentCooldownTime = 0
local resetPCD = false
local currentAOP = "Sandy Shores"

function msg(src, text)
    TriggerClientEvent('chat:addMessage', src, { args = { text } })
end

RegisterCommand("setaop", function(source, args, rawCommand)
    if IsPlayerAceAllowed(source, "command.PookieHud.aop") then
        if #args > 0 then
            currentAOP = table.concat(args, " ")
            TriggerClientEvent('blrp:setAOP', -1, currentAOP)
            TriggerClientEvent('chat:addMessage', -1, { args = { "AOP set to: " .. currentAOP } })
        else
            TriggerClientEvent('chat:addMessage', source, { args = { '^1ERROR: Usage /setaop <AOP>' } })
        end
    else
        TriggerClientEvent('chat:addMessage', source, { args = { '^1You do not have permission to use /setaop' } })
    end
end, true)

RegisterCommand("peacetime", function(source)
    if IsPlayerAceAllowed(source, "command.PookieHud.peacetime") then
        isPeacetime = not isPeacetime
        TriggerClientEvent("peacetime:setState", -1, isPeacetime)
        print("Peacetime is now " .. (isPeacetime and "ENABLED" or "DISABLED"))
        TriggerClientEvent('chat:addMessage', -1, { args = { "Peacetime is now " .. (isPeacetime and "ENABLED" or "DISABLED") } })
    else
        TriggerClientEvent('chat:addMessage', source, { args = { '^1You do not have permission to use /peacetime' } })
    end
end, true)

RegisterCommand("resetpcd", function(source, args, rawCommand)
    if IsPlayerAceAllowed(source, "command.PookieHud.priority") then
        onHold = false
        inProgress = false
        resetPCD = true
        currentCooldownTime = 0
        TriggerClientEvent('BLRSP_Peacetime:PriorityUpdate', -1, inProgress, onHold, currentCooldownTime)
        TriggerClientEvent('chat:addMessage', -1, { args = { "Priority Cooldown Reset" } })
    else
        TriggerClientEvent('chat:addMessage', source, { args = { '^1You do not have permission to use /resetpcd' } })
    end
end, true)

RegisterCommand("inprogress", function(source, args, rawCommand)
    if IsPlayerAceAllowed(source, "command.PookieHud.priority") then
        onHold = false
        inProgress = true
        resetPCD = false
        currentCooldownTime = 0
        TriggerClientEvent('BLRSP_Peacetime:PriorityUpdate', -1, inProgress, onHold, currentCooldownTime)
        TriggerClientEvent('chat:addMessage', -1, { args = { "Priority In Progress" } })
    else
        TriggerClientEvent('chat:addMessage', source, { args = { '^1You do not have permission to use /inprogress' } })
    end
end, true)

RegisterCommand("onhold", function(source, args, rawCommand)
    if IsPlayerAceAllowed(source, "command.PookieHud.priority") then
        inProgress = false
        onHold = true
        resetPCD = false
        currentCooldownTime = 0
        TriggerClientEvent('BLRSP_Peacetime:PriorityUpdate', -1, inProgress, onHold, currentCooldownTime)
        TriggerClientEvent('chat:addMessage', -1, { args = { "Priority On Hold" } })
    else
        TriggerClientEvent('chat:addMessage', source, { args = { '^1You do not have permission to use /onhold' } })
    end
end, true)

RegisterCommand("cooldown", function(source, args, rawCommand)
    if IsPlayerAceAllowed(source, "command.PookieHud.priority") then
        if #args > 0 and tonumber(args[1]) then
            local coold = tonumber(args[1])
            currentCooldownTime = coold
            inProgress = false
            onHold = false
            resetPCD = false
            TriggerClientEvent('BLRSP_Peacetime:PriorityUpdate', -1, inProgress, onHold, currentCooldownTime)
            TriggerClientEvent('chat:addMessage', -1, { args = { ("Priority Cooldown set to %s minutes"):format(args[1]) } })
        else
            TriggerClientEvent('chat:addMessage', source, { args = { '^1ERROR: Usage /cooldown <minutes>' } })
        end
    else
        TriggerClientEvent('chat:addMessage', source, { args = { '^1You do not have permission to use /cooldown' } })
    end
end, true)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        if currentCooldownTime > 0 and not inProgress and not onHold and not resetPCD then
            currentCooldownTime = currentCooldownTime - 1
            TriggerClientEvent('BLRSP_Peacetime:PriorityUpdate', -1, inProgress, onHold, currentCooldownTime)
        end
    end
end)
