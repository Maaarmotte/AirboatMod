
AMMain.Spawns["gm_construct_flatgrass_v6-2"] = { Vector(12607.637695, -7303.835938, -737.583374), Vector(7220.501465, -3177.291260, -168.961502) }

function AMMain.InitPlayer(ply)
	local amPly = ply.AMPlayer or AMPlayer.New(ply)
	local amBoat = amPly.AMBoat or AMBoat.New()
	amPly:SetAirboat(amBoat)
	amBoat:SetPlayer(amPly)
	amBoat:Spawn()
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

if not AMMain.HookCall then AMMain.HookCall = hook.Call end
hook.Call = function( name, gm, ... )
	for _,ply in ipairs(player.GetAll()) do
		if ply.AMPlayer then
			local boat = ply.AMPlayer:GetAirboat()
			if boat then
				local powerup = boat:GetPowerUp()
				if powerup and powerup.InRun then
					if powerup[name] and type(powerup[name]) == "function" then
						local var = powerup[name](powerup, boat, ...)

						if var then
							return var
						end
					end
				end
			end
		end
	end

	return AMMain.HookCall( name, gm, ... )
end

