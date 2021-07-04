AMDatabase = AMDatabase or {}

function AMDatabase.request(req, ...)
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

function AMDatabase.safeData(data)
    local safeData = {}

    for k, v in pairs(data) do
        safeData[k] = isstring(v) and sql.SQLStr(v) or tostring(v)
    end

    return safeData
end

function AMDatabase.extractKeyValues(obj)
    local keys = {}
    local values = {}

    for k, v in pairs(obj) do
        table.insert(keys, k)
        table.insert(values, v)
    end

    return keys, values
end

function AMDatabase.Create(tableName, values)
    local keys, values = AMDatabase.extractKeyValues(values)

    AMDatabase.request([[
		INSERT INTO
			`]] .. tableName .. [[`(]] .. table.concat(keys, ', ') .. [[)
			VALUES(]] .. table.concat(values, ', ') .. [[);
	]])
end

function AMDatabase.Update(tableName, id, values, pk)
    pk = pk or "id"
    local dataString = {}

    for k, v in pairs(values) do
        table.insert(dataString, k .. " = " .. v)
    end

    AMDatabase.request([[
		UPDATE `]] .. tableName .. [[`
			SET ]] .. table.concat(dataString, ", ") .. [[
			WHERE ]] .. pk .. [[ = %s
	]], tostring(id))
end
