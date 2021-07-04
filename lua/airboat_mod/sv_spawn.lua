AMSpawn = {}
AMSpawns = {}
AMSpawnsPowerUps = AMSpawnsPowerUps or {}

function AMSpawn.Update()
	AMSpawns = AMDatabase.GetSpawns(game.GetMap())

	for k, spawn in pairs(AMSpawns) do
		AMSpawn.Prepare(spawn)
	end
end

function AMSpawn.GetByID(id)
	for _, spawn in pairs(AMSpawns) do
		if spawn.id == id then
			return spawn
		end
	end
end

function AMSpawn.New(min, max, settings)
	AMDatabase.NewSpawn(game.GetMap(), min, max, settings)
	AMSpawn.Update()

	return AMSpawns[#AMSpawns]
end

function AMSpawn.Edit(id, min, max, settings)
	AMDatabase.EditSpawn(id, min, max, settings)
	AMSpawn.Update()

	return AMSpawn.GetByID(id)
end

function AMSpawn.Enable(id, enable)
	AMDatabase.EnableSpawn(id, enable)
	AMSpawn.Update()

	return AMSpawn.GetByID(id)
end

function AMSpawn.Remove(id)
	AMSpawn.Clean(id)

	AMDatabase.RemoveSpawn(id)
	AMSpawn.Update()
end

function AMSpawn.Prepare(spawn)
	if spawn.settings.autoPowerUpEnabled then
		if not AMSpawnsPowerUps[spawn.id] then
			AMSpawnsPowerUps[spawn.id] = {}
			
			for i = 1, spawn.settings.autoPowerUpCount, 1 do
				local randPos = Vector(
					math.Rand(spawn.min.x, spawn.max.x),
					math.Rand(spawn.min.y, spawn.max.y),
					spawn.max.z
				)

				local powerup = ents.Create("am_powerup")
				powerup:SetPos(randPos)
				powerup:Spawn()

				table.insert(AMSpawnsPowerUps[spawn.id], powerup)
			end
		end
	else
		AMSpawn.Clean(spawn)
	end
end

function AMSpawn.Clean(id)
	if AMSpawnsPowerUps[id] then
		for k, powerup in pairs(AMSpawnsPowerUps[id]) do
			if IsValid(powerup) then
				powerup:Remove()
			end
		end

		AMSpawnsPowerUps[id] = nil
	end
end
