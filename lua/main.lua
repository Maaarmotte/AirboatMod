
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

AMSpawn = {}
AMSpawns = {}

function AMSpawn.Update()
	AMSpawns = AMDatabase.GetSpawns(game.GetMap())
end

function AMSpawn.GetByID(id)
	print("ixi", id)
	for _, spawn in pairs(AMSpawns) do
		print(type(spawn.id), type(id))
		if spawn.id == id then
			print("coouou")
			return spawn
		end
	end
end

function AMSpawn.New(min, max)
	AMDatabase.NewSpawn(game.GetMap(), min, max)
	AMSpawn.Update()

	return AMSpawns[#AMSpawns]
end

function AMSpawn.Edit(id, min, max)
	AMDatabase.EditSpawn(id, min, max)
	AMSpawn.Update()

	return AMSpawn.GetByID(id)
end

function AMSpawn.Remove(id)
	AMDatabase.RemoveSpawn(id)
	AMSpawn.Update()
end

AMSpawn.Update()
