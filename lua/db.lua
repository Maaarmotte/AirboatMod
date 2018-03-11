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
	if not AMDatabase.CheckPlayer(ply) or (tpe != "kills" and tpe != "deaths") then return end
	
	if AMDatabase.Cache[ply][tpe] then
		return AMDatabase.Cache[ply][tpe]
	end
	
	local result = sql.QueryValue("SELECT " .. tpe .. " FROM AMMod_scores WHERE steamid='" .. ply:SteamID() .. "';")
	AMDatabase.Cache[ply][tpe] = result
	return result
end

-- tpe can only be "kills" or "deaths"
function AMDatabase.IncPlayerScore(ply, tpe)
	if not AMDatabase.CheckPlayer(ply) or (tpe != "kills" and tpe != "deaths") then return end
	
	local score = (AMDatabase.Cache[ply][tpe] or 0) + 1
	sql.Query("UPDATE AMMod_scores SET " .. tpe .. "=" .. score .. " WHERE steamid='" .. ply:SteamID() .. "';")
	
	AMDatabase.Cache[ply][tpe] = score
	
	return score
end
