-- Command to enter the game
hook.Add("PlayerSay", "Airboat", function(ply, text, isTeam)
	if text == "!boat" then
		amPlayer = AMMain.NewPlayer(ply)
		AMMenu.SendMenu(amPlayer)
	end
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
			AMMenu.SendMenu(amPlayer)
			return false
		else
			return false
		end
	end
end)

-- Stop the game when the player left or is killed
hook.Add("CanExitVehicle", "Airboat", function(boat, ply)
	local amPlayer = ply.AMPlayer
	print(amPlayer)
	if amPlayer then
		AMMenu.SendMenu(amPlayer)
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
