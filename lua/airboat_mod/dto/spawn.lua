local Spawn = {}
Spawn.TABLE = "AMMod_spawns"

function Spawn.Build(data)
    return {
        id = tonumber(data.id),
        enabled = tonumber(data.enabled) == 1,
        min = Vector(data.minX, data.minY, data.minZ),
        max = Vector(data.maxX, data.maxY, data.maxZ),
        settings = util.JSONToTable(data.settings) or {}
    }
end

function Spawn.Serialize(spawn)
    return AMDatabase.safeData({
        -- id = spawn.id,
        map = spawn.map,
        minX = spawn.min and spawn.min.x or nil,
        minY = spawn.min and spawn.min.y or nil,
        minZ = spawn.min and spawn.min.z or nil,
        maxX = spawn.max and spawn.max.x or nil,
        maxY = spawn.max and spawn.max.y or nil,
        maxZ = spawn.max and spawn.max.z or nil,
        settings = spawn.settings and util.TableToJSON(spawn.settings) or nil
    })
end

function Spawn.FindByMap(map)
    return AMDatabase.request("SELECT * FROM AMMod_spawns WHERE map=%s;", map, function(rep)
        local spawns = {}

        for _, data in pairs(rep or {}) do
            table.insert(spawns, Spawn.Build(data))
        end

        return spawns
    end)
end

function Spawn.Create(values)
    AMDatabase.Create(Spawn.TABLE, Spawn.Serialize(values))
end

function Spawn.Update(id, values)
    AMDatabase.Update(Spawn.TABLE, id, Spawn.Serialize(values))
end

function Spawn.Delete(id)
    AMDatabase.request([[
		DELETE FROM AMMod_spawns WHERE id = %d
    ]], id)
end

function Spawn.Enable(id, enable)
    AMDatabase.request([[
		UPDATE AMMod_spawns SET enabled = %d WHERE id = %d
    ]], enable and 1 or 0, id)
end

function Spawn.InitTable()
    AMDatabase.request([[
		CREATE TABLE AMMod_spawns(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			map TEXT,
			enabled INTEGER DEFAULT 1,
			minX INTEGER, minY INTEGER, minZ INTEGER,
			maxX INTEGER, maxY INTEGER, maxZ INTEGER,
			settings TEXT DEFAULT "{}"
		)
    ]])

    Spawn.Create({
        map = "gm_construct_flatgrass_v6-2",
        min = Vector(12607, -7303, -507),
        max = Vector(7220, -3177, -168)
    })
    Spawn.Create({
        map = "gm_excess_waters",
        min = Vector(-1042, -10021, 654),
        max = Vector(-2733, -8171, 454)
    })
    Spawn.Create({
        map = "gm_excess_construct_13",
        min = Vector(2038, -10431, -34),
        max = Vector(5736, -12471, 166)
    })
end

if not sql.TableExists("AMMod_spawns") then
    Spawn.InitTable()
end

AMDatabase.Spawn = Spawn