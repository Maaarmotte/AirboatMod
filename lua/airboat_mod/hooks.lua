-- Command to enter the game
hook.Add("PlayerSay", "Airboat", function(ply, text, isTeam)
	if text == "!boat" then
		local amPlayer = AMMain.NewPlayer(ply)
		AMMenu.ShowMenu(ply)
	end
end)

concommand.Add("airboatmod_play", function(ply, cmd, args)
	local amPlayer = AMMain.NewPlayer(ply)
	AMMenu.ShowMenu(ply)
end)

-- Main game ticks
hook.Add("Tick", "Airboat", AMMain.Tick)

hook.Add("CanPlayerEnterVehicle", "Airboat", function(ply, boat)
	local amPlayer = ply.AMPlayer
	local amBoat = boat.AMBoat

	if amBoat and amBoat:GetEntity():IsValid() and amPlayer and amPlayer:GetEntity():IsValid() then
		if amBoat:GetPlayer() and ply == amBoat:GetPlayer():GetEntity() then
			if amPlayer:GetPlaying() then
				return true
			end
			AMMenu.ShowMenu(ply)
			return false
		else
			return false
		end
	end
end)

-- Stop the game when the player left or is killed
hook.Add("CanExitVehicle", "Airboat", function(boat, ply)
	local amPlayer = ply.AMPlayer

	if amPlayer and amPlayer.AMBoat and amPlayer.AMBoat.Entity and amPlayer.AMBoat.Entity == boat then
		AMMenu.ShowMenu(ply)
		return false
	end
end)

-- Disable damages for player in airboat
hook.Add("EntityTakeDamage", "Airboat", function(ply, dmg)
	if not ply or not ply:IsValid() or not ply:IsPlayer() or not ply.AMPlayer then return end
	local amPlayer = ply.AMPlayer

	if amPlayer:GetPlaying() then
		return true
	end
end)

hook.Add("PlayerSpawn", "AirboatMod", function(ply)
	local amPlayer = ply.AMPlayer

	if amPlayer and amPlayer:GetPlaying() then
		amPlayer:Spawn()
	end
end)

hook.Add("VehicleMove", "AirboatMod", function(ply, veh, mv)
	local amPly = ply.AMPlayer

	if amPly and amPly:GetPlaying() then
		if not amPly:IsAlive() or amPly.WantToDie then
			veh:SetSteering(0, 0)
			veh:SetThrottle(0)
		end
	end
end)


hook.Add("CanPlayerSuicide", "AirboatMod", function(ply)
	local amPly = ply.AMPlayer

	if amPly and amPly:GetPlaying() then
		amPly:Suicide()
		return false
	end
end)
