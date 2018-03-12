-- Make sure tables already exist
if not sql.TableExists("AMMod_scores") then
	sql.Query("CREATE TABLE AMMod_scores(steamid TEXT PRIMARY KEY, kills INTEGER, deaths INTEGER);")
end

AMDatabase = {}
AMDatabase.Cache = {}

function AMDatabase.CheckPlayer(ply)
	if not (IsValid(ply) and ply:IsPlayer()) then
		return false
	end

	-- Already cached ?
	if AMDatabase.Cache[ply] then
		return true
	end

	-- Already in database ?
	if sql.QueryValue("SELECT kills FROM AMMod_scores WHERE steamid='" .. ply:SteamID() .. "';") then
		AMDatabase.Cache[ply] = {}
		return true
	end

	-- Does not exist yet !
	AMDatabase.InitPlayerTables(ply)
	AMDatabase.Cache[ply] = {}
	return true
end

-- Put initial table insertions here
function AMDatabase.InitPlayerTables(ply)
	sql.Query("INSERT INTO AMMod_scores(steamid, kills, deaths) VALUES('" .. ply:SteamID() .. "', 0, 0);")
end

-- tpe can only be "kills" or "deaths"
function AMDatabase.GetPlayerScore(ply, tpe)
	if not AMDatabase.CheckPlayer(ply) or (tpe ~= "kills" and tpe ~= "deaths") then return end

	if AMDatabase.Cache[ply][tpe] then
		return AMDatabase.Cache[ply][tpe]
	end

	local result = sql.QueryValue("SELECT " .. tpe .. " FROM AMMod_scores WHERE steamid='" .. ply:SteamID() .. "';")
	AMDatabase.Cache[ply][tpe] = result
	return result
end

-- tpe can only be "kills" or "deaths"
function AMDatabase.IncPlayerScore(ply, tpe)
	if not AMDatabase.CheckPlayer(ply) or (tpe ~= "kills" and tpe ~= "deaths") then return end

	local score = (AMDatabase.Cache[ply][tpe] or 0) + 1
	sql.Query("UPDATE AMMod_scores SET " .. tpe .. "=" .. score .. " WHERE steamid='" .. ply:SteamID() .. "';")

	AMDatabase.Cache[ply][tpe] = score

	return score
end



function AMDatabase.GetSpawns(map)
	local rep = sql.Query("SELECT * FROM AMMod_spawns WHERE map='" .. map .. "';")

	local spawns = {}

	for _, data in pairs(rep) do
		table.insert(spawns, {
			id = tonumber(data.id),
			min = Vector(data.minX, data.minY, data.minZ),
			max = Vector(data.maxX, data.maxY, data.maxZ)
		})
	end

	return spawns
end

function AMDatabase.NewSpawn(map, min, max)
	sql.Query(string.format([[
		INSERT INTO
			AMMod_spawns(map, minX, minY, minZ, maxX, maxY, maxZ)
			VALUES('%s', %d, %d, %d, %d, %d, %d);]],
		map, min.x, min.y, min.z, max.x, max.y, max.z))
end

function AMDatabase.EditSpawn(id, min, max)
	sql.Query(string.format([[
		UPDATE AMMod_spawns SET minX = %d, minY = %d, minZ = %d, maxX = %d, maxY = %d, maxZ = %d WHERE id = %d]],
		min.x, min.y, min.z, max.x, max.y, max.z, id))
end

function AMDatabase.RemoveSpawn(id)
	sql.Query(string.format([[
		DELETE FROM AMMod_spawns WHERE id = %d]],
		id))
end


if not sql.TableExists("AMMod_spawns") then
	sql.Query([[
		CREATE TABLE AMMod_spawns(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			map TEXT,
			minX INTEGER, minY INTEGER, minZ INTEGER,
			maxX INTEGER, maxY INTEGER, maxZ INTEGER
		)]])

	AMDatabase.NewSpawn("gm_construct_flatgrass_v6-2", Vector(12607, -7303, -507), Vector(7220, -3177, -168))
	AMDatabase.NewSpawn("gm_excess_waters", Vector(-1042, -10021, 654), Vector(-2733, -8171, 454))
	AMDatabase.NewSpawn("gm_excess_construct_13", Vector(2038, -10431, -34), Vector(5736, -12471, 166))
end
