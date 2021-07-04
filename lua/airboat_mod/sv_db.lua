
local function request(req, ...)
	local args = {...}
	local succ, err

	if isfunction(args[#args - 1]) then
		succ = table.remove(args, #args - 1)
		err = table.remove(args, #args)
	elseif isfunction(args[#args]) then
		succ = table.remove(args, #args)
	end

	for key, value in pairs(args) do
		args[key] = isstring(value) and sql.SQLStr(value) or value
	end

	local freq = string.format(req, unpack(args))
	local rep = sql.Query(freq)

	if rep == false then
		if not (isfunction(err) and err(freq, sql.LastError()) ~= nil) then
			error("Airboat SQL error - " .. freq .. " - " .. sql.LastError())
		end
	else
		if isfunction(succ) then
			return succ(rep)
		end
	end
end


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
	return request("SELECT * FROM AMMod_spawns WHERE map=%s;", map, function(rep)
		local spawns = {}

		for _, data in pairs(rep or {}) do
			table.insert(spawns, {
				id = tonumber(data.id),
				enabled = tonumber(data.enabled) == 1,
				min = Vector(data.minX, data.minY, data.minZ),
				max = Vector(data.maxX, data.maxY, data.maxZ),
				settings = util.JSONToTable(data.settings) or {}
			})
		end

		return spawns
	end)
end

function AMDatabase.NewSpawn(map, min, max, settings)
	local jsonSettings = util.TableToJSON(settings)

	request([[
		INSERT INTO
			AMMod_spawns(map, minX, minY, minZ, maxX, maxY, maxZ, settings)
			VALUES(%s, %d, %d, %d, %d, %d, %d, %s);]],
		map, min.x, min.y, min.z, max.x, max.y, max.z, jsonSettings)
end

function AMDatabase.EditSpawn(id, min, max, settings)
	local jsonSettings = util.TableToJSON(settings)

	request([[
		UPDATE AMMod_spawns
			SET minX = %d, minY = %d, minZ = %d, maxX = %d, maxY = %d, maxZ = %d, settings = %s
			WHERE id = %d]],
		min.x, min.y, min.z, max.x, max.y, max.z, jsonSettings, id)
end

function AMDatabase.RemoveSpawn(id)
	request([[
		DELETE FROM AMMod_spawns WHERE id = %d]],
		id)
end

function AMDatabase.EnableSpawn(id, enable)
	request([[
		UPDATE AMMod_spawns SET enabled = %d WHERE id = %d]],
		enable and 1 or 0, id)
end

if not sql.TableExists("AMMod_spawns") then
	request([[
		CREATE TABLE AMMod_spawns(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			map TEXT,
			enabled INTEGER DEFAULT 1,
			minX INTEGER, minY INTEGER, minZ INTEGER,
			maxX INTEGER, maxY INTEGER, maxZ INTEGER,
			settings TEXT DEFAULT "{}"
		)]])

	AMDatabase.NewSpawn("gm_construct_flatgrass_v6-2", Vector(12607, -7303, -507), Vector(7220, -3177, -168))
	AMDatabase.NewSpawn("gm_excess_waters", Vector(-1042, -10021, 654), Vector(-2733, -8171, 454))
	AMDatabase.NewSpawn("gm_excess_construct_13", Vector(2038, -10431, -34), Vector(5736, -12471, 166))
end
