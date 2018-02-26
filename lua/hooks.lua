-- Command to enter the game
hook.Add("PlayerSay", "Airboat", function(ply, text, isTeam)
	if text == "!boat" then
		AMMain.InitPlayer(ply)
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
			AMMenu.SendMenu(amPlayer, amBoat)
			return false
		else
			return false
		end
	end
end)

-- Stop the game when the player left or is killed
hook.Add("PlayerLeaveVehicle", "Airboat", function(ply, boat)
	local amPlayer = ply.AMPlayer
	if amPlayer then
		amPlayer:SetPlaying(false)

		if amPlayer:GetAirboat() then
			timer.Simple(0.1, function() amPlayer:GetAirboat():Synchronize() end)
		end
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
