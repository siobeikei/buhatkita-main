# Author: Keiran
# Description: This script allows players to "pasan" (carry) each other in the game.
-- This script is designed to work with the ESX framework in FiveM.

ESX = nil
  
Citizen.CreateThread(function()
	while ESX == nil do
		ESX = exports["es_extended"]:getSharedObject()
		Citizen.Wait(0)
	end
end)
  
local pasan = {
	InProgress = false,
	targetSrc = -1,
	type = "",
	personPasaning = {
		animDict = "move_m@casual@a",
		anim = "",
		flag = 49,
	},
	personBeingPasaned = {
		animDict = "anim@heists@fleeca_bank@hostages@intro",
		anim = "intro_loop_ped_a",
		animDict = "mp_cop_miss",
		anim = "dazed",
		attachX = 0.00,
		attachY = -0.45,
		attachZ = 0.10,
		flag = 33,
	}
}

RegisterCommand("buhatkita",function(source, args)
	if not pasan.InProgress then
		local closestPlayer = GetClosestPlayer(3)
		if closestPlayer then
			local targetSrc = GetPlayerServerId(closestPlayer)
			if targetSrc ~= -1 then
				pasan.InProgress = true
				pasan.targetSrc = targetSrc
				TriggerServerEvent("BuhatKitaa:sync",targetSrc)
				ensureAnimDict(pasan.personPasaning.animDict)
				pasan.type = "pasaning"
			else
				drawNativeNotification("~r~No one nearby to pasan!")
			end
		else
			drawNativeNotification("~r~No one nearby to pasan!")
		end
	else
		pasan.InProgress = false
		ClearPedSecondaryTask(PlayerPedId())
		DetachEntity(PlayerPedId(), true, false)
		TriggerServerEvent("BuhatKitaa:stop",pasan.targetSrc)
		pasan.targetSrc = 0
	end
end,false)

RegisterNetEvent("BuhatKitaa:syncTarget")
AddEventHandler("BuhatKitaa:syncTarget", function(targetSrc)
	local playerPed = PlayerPedId()
	local targetPed = GetPlayerPed(GetPlayerFromServerId(targetSrc))
	pasan.InProgress = true
	ensureAnimDict(pasan.personBeingPasaned.animDict)
	AttachEntityToEntity(PlayerPedId(), targetPed, 0, pasan.personBeingPasaned.attachX, pasan.personBeingPasaned.attachY, pasan.personBeingPasaned.attachZ, 0.5, 0.5, 180, false, false, false, false, 2, false)
	pasan.type = "beingPasaned"
end)

RegisterNetEvent("BuhatKitaa:cl_stop")
AddEventHandler("BuhatKitaa:cl_stop", function()
	pasan.InProgress = false
	ClearPedSecondaryTask(PlayerPedId())
	DetachEntity(PlayerPedId(), true, false)
end)

Citizen.CreateThread(function()
	while true do
		if pasan.InProgress then
			if pasan.type == "beingPasaned" then
				if not IsEntityPlayingAnim(PlayerPedId(), pasan.personBeingPasaned.animDict, pasan.personBeingPasaned.anim, 3) then
					TaskPlayAnim(PlayerPedId(), pasan.personBeingPasaned.animDict, pasan.personBeingPasaned.anim, 8.0, -8.0, 100000, pasan.personBeingPasaned.flag, 0, false, false, false)
				end
			elseif pasan.type == "pasaning" then
				if not IsEntityPlayingAnim(PlayerPedId(), pasan.personPasaning.animDict, pasan.personPasaning.anim, 3) then
					TaskPlayAnim(PlayerPedId(), pasan.personPasaning.animDict, pasan.personPasaning.anim, 8.0, -8.0, 100000, pasan.personPasaning.flag, 0, false, false, false)
				end
			end
		end
		Wait(0)
	end
end)

function GetClosestPlayer(radius)
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = PlayerPedId()
    local plyCoords = GetEntityCoords(ply, 0)

    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = GetDistanceBetweenCoords(targetCoords['x'], targetCoords['y'], targetCoords['z'], plyCoords['x'], plyCoords['y'], plyCoords['z'], true)
            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
    print("closest player is dist: " .. tostring(closestDistance))
    if closestDistance <= radius then
        return closestPlayer
    else
        return nil
    end
end

function ensureAnimDict(animDict)
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(0)
        end        
    end
    return animDict
end
