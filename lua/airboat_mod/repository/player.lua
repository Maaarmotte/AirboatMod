local Player = {}
Player.TABLE = "AMMod_players"

function Player.Build(data)
    local colorTab = util.JSONToTable(data.color)

    return {
        steamid = data.steamid,
        name = data.name,
        kills = tonumber(data.kills),
        deaths = tonumber(data.deaths),
        points = tonumber(data.points),
        playTime = tonumber(data.play_time),
        color = Color(colorTab.r, colorTab.g, colorTab.b, colorTab.a),
        mods = util.JSONToTable(data.mods) or {},
        ownedMods = util.JSONToTable(data.owned_mods) or {}
    }
end

function Player.Serialize(ply)
    return AMDatabase.safeData({
        steamid = ply.steamid,
        name = ply.name,
        kills = ply.kills,
        deaths = ply.deaths,
        points = ply.points,
        play_time = ply.playTime,
        color = util.TableToJSON(ply.color),
        mods = util.TableToJSON(ply.mods),
        ownedMods = util.TableToJSON(ply.owned_mods)
    })
end

function Player.FindBySteamId(steamid)
    return AMDatabase.request([[
        SELECT * FROM %s
            WHERE steamid=%s;
    ]], Player.TABLE, steamid, function(rep)
        return rep and #rep > 0 and Player.Build(rep[1]) or nil
    end)
end

function Player.FindHighScore(limit)
    limit = limit or 10

    return AMDatabase.request([[
        SELECT * FROM %s
            ORDER BY kills desc
            LIMIT %d;
    ]], Player.TABLE, limit, function(rep)
        local spawns = {}

        for _, data in pairs(rep or {}) do
            table.insert(spawns, Spawn.Build(data))
        end

        return spawns
    end)
end

function Player.FindLeaderboard()
    return AMDatabase.request([[
        SELECT * FROM %s
            ORDER BY kills desc
            LIMIT %d;
    ]], Player.TABLE, 3, function(rep)
        local players = {}

        for _, data in pairs(rep or {}) do
            table.insert(players, Player.Build(data))
        end

        return players
    end)
end

function Player.FindOrCreate(gmPly)
    local ply = Player.FindBySteamId(gmPly:SteamID())

    if not ply then
        ply = {
            steamid = gmPly:SteamID(),
            name = gmPly:Name(),
            kills = 0,
            deaths = 0,
            points = 0,
            playTime = 0,
            color = Color(196, 185, 155),
            mods = {},
            ownedMods = {}
        }

        Player.Create(ply)
    end

    return ply
end

function Player.Create(values)
    AMDatabase.Create(Player.TABLE, Player.Serialize(values))
end

function Player.Update(steamid, values)
    AMDatabase.Update(Player.TABLE, steamid, Player.Serialize(values), 'steamid')
end

function Player.Delete(steamid)
    AMDatabase.request([[
		DELETE FROM AMMod_players WHERE steamid = %d
    ]], steamid)
end

function Player.InitTable()
    AMDatabase.request([[
        CREATE TABLE AMMod_players(
            steamid TEXT PRIMARY KEY,
            name TEXT,
            kills INTEGER,
            deaths INTEGER,
            points INTEGER,
            play_time INTEGER,
            color TEXT,
            mods TEXT,
            owned_mods TEXT
        );
    ]])
end

if not sql.TableExists("AMMod_players") then
    Player.InitTable()
end

AMDatabase = AMDatabase or {}
AMDatabase.Player = Player