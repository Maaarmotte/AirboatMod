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

-- Concommands
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
	amBoat:UnmountMods()
	amBoat:MountMods()
	
	amBoat:Synchronize()
	
	if not AMMain.Spawns[game.GetMap()] then return end
	
	-- Move the boat to a random spot in the area
	local rand = VectorRand()
	rand.x = math.abs(rand.x)
	rand.y = math.abs(rand.y)
	rand.z = math.abs(rand.z)
	local areaV1 = AMMain.Spawns[game.GetMap()][1]
	local areaV2 = AMMain.Spawns[game.GetMap()][2]
	local pos = areaV1 + rand*(areaV2 - areaV1)
	pos.z = (areaV1.z + areaV2.z)/2
	boat:SetPos(pos)
end)

concommand.Add("am_mod", function(ply, cmd, args)
	local name = args[1]
	local mod = AMMods.Mods[name]

	local amPlayer = ply.AMPlayer
	if not amPlayer then return end

	local amBoat = amPlayer:GetAirboat()
	if not amBoat then return end
	
	if mod and table.HasValue(amPlayer.Mods, name) then
		local key = mod.Type

		if amBoat.Mods[key] then
			amBoat.Mods[key]:Unmount(amBoat)
		end
		amBoat.Mods[key] = AMMods.Instantiate(name)
		amBoat.Mods[key]:Mount(amBoat)
	else
		print("[AM] Player " .. ply:Name() .. " doesn't have access to " .. mod)
	end
end)