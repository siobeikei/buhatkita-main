# Author: Keiran
# Description: This script allows players to "pasan" (carry) each other in the game.
-- This script is designed to work with the ESX framework in FiveM.


ESX = exports["es_extended"]:getSharedObject()

local give = false
local usedRope = false

local pasaning = {}
local beingPasaned = {}

RegisterServerEvent("BuhatKitaa:sync")
AddEventHandler("BuhatKitaa:sync", function(targetSrc)
	local source = source
	local sourcePed = GetPlayerPed(source)
    	local sourceCoords = GetEntityCoords(sourcePed)
	local targetPed = GetPlayerPed(targetSrc)
    	local targetCoords = GetEntityCoords(targetPed)
	if #(sourceCoords - targetCoords) <= 3.0 then 
		TriggerClientEvent("BuhatKitaa:syncTarget", targetSrc, source)
		pasaning[source] = targetSrc
		beingPasaned[targetSrc] = source
	end
end)

RegisterServerEvent("BuhatKitaa:stop")
AddEventHandler("BuhatKitaa:stop", function(targetSrc)
	local source = source

	if pasaning[source] then
		TriggerClientEvent("BuhatKitaa:cl_stop", targetSrc)
		pasaning[source] = nil
		beingPasaned[targetSrc] = nil
	elseif beingPasaned[source] then
		TriggerClientEvent("BuhatKitaa:cl_stop", beingPasaned[source])
		beingPasaned[source] = nil
		pasaning[beingPasaned[source]] = nil
	end
end)

AddEventHandler('playerDropped', function(reason)
	local source = source
	
	if pasaning[source] then
		TriggerClientEvent("BuhatKitaa:cl_stop", pasaning[source])
		beingPasaned[pasaning[source]] = nil
		pasaning[source] = nil
	end

	if beingPasaned[source] then
		TriggerClientEvent("BuhatKitaa:cl_stop", beingPasaned[source])
		pasaning[beingPasaned[source]] = nil
		beingPasaned[source] = nil
	end
end)

print('---- Leak By Shiro Morningstar | https://discord.gg/Cb5Ag3kUXd  ----')


