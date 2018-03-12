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
