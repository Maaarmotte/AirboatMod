hook.Add("PlayerSay", "Airboat", function(ply, text, isTeam)
	if text == "!boat" then
		AMMain.InitPlayer(ply)
	end
end)

hook.Add("Tick", "Airboat", AMMain.Tick)

hook.Add("CanPlayerEnterVehicle", "Airboat", function(ply, boat)
	local amPlayer = ply.AMPlayer
	local amBoat = boat.AMBoat
	
	if amBoat and amBoat:GetEntity():IsValid() and amPlayer and amPlayer:GetEntity():IsValid() then
		if amPlayer:GetPlaying() then
			return true
		end
		AMMenu.SendMenu(amPlayer, amBoat)
		return false
	end
end)

hook.Add("PlayerLeaveVehicle", "Airboat", function(ply, boat)
	local amPlayer = ply.AMPlayer
	if amPlayer then
		amPlayer:SetPlaying(false)
	end
end)

concommand.Add("am_play", function(ply)
	local amPlayer = ply.AMPlayer
	if not amPlayer then return end
	
	local amBoat = amPlayer:GetAirboat()
	if not amBoat or not amBoat:GetEntity() or not amBoat:GetEntity():IsValid() then return end

	local boat = amBoat:GetEntity()

	amPlayer:SetPlaying(true)
	ply:EnterVehicle(boat)
	ply:EmitSound("ui/itemcrate_smash_ultrarare_short.wav")
	ParticleEffectAttach("ghost_smoke", PATTACH_ABSORIGIN_FOLLOW, boat, 0)
	
	amBoat:AddInvulnerableTime(3)
	amBoat:SetHealth(15)
	
	if not  AMMain.Spawns[game.GetMap()] then return end
	
	-- Move the boat to a random spot in the area
	local rand = VectorRand()
	rand.x = math.abs(rand.x)
	rand.y = math.abs(rand.y)
	rand.z = math.abs(rand.z)
	local areaV1 = AMMain.Spawns[game.GetMap()][1]
	local areaV2 = AMMain.Spawns[game.GetMap()][2]
	local pos = areaV1 + rand*(areaV2 - areaV1)
	pos.z = (areaV1.z + areaV2.z)/4
	boat:SetPos(pos)
end)