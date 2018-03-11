
AMMain.Spawns["gm_construct_flatgrass_v6-2"] = { Vector(12607.637695, -7303.835938, -507.583374), Vector(7220.501465, -3177.291260, -168.961502) }
AMMain.Spawns["gm_excess_waters"] = { Vector(-1042, -10021, 654), Vector(-2733, -8171, 454) }
AMMain.Spawns["gm_excess_construct_13"] = { Vector(2038, -10431, -34), Vector(5736, -12471, 166)}

function AMMain.NewPlayer(ply)
	local amPly = ply.AMPlayer or AMPlayer.New(ply)
	-- local amBoat = amPly.AMBoat or AMBoat.New()
	-- amPly:SetAirboat(amBoat)
	-- amBoat:SetPlayer(amPly)
	-- amBoat:Spawn()

	return amPly
end

function AMMain.Tick()
	for _,ply in ipairs(player.GetAll()) do
		if ply.AMPlayer then
			local boat = ply.AMPlayer:GetAirboat()
			if boat then
				boat:Tick()
			end
		end
	end
end

function AMMain.IsPlayerAdmin(ply)
	return ply and ply:IsAdmin()
end
