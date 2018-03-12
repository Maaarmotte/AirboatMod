
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