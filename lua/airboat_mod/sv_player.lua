AMPlayer = {}
AMPlayer_mt = {__index = function(tab, key) return AMPlayer[key] end}

AMPlayer.DefaultMods = { shift="boost", space="jump", mouse1="", skin="" }
AMPlayer.DefaultOwnedMods = { shift="boost", space="jump", mouse1="", skin="" }

-- Constructor
function AMPlayer.New(ply)
	local self = {}
	setmetatable(self, AMPlayer_mt)

	local playerInfo = AMDatabase.Player.FindOrCreate(ply)

	if playerInfo.name ~= ply:Name() then
		self:Update({
			name = self:Name()
		})
	end

	self.Entity = ply
	self.AMBoat = nil
	
	self.Mods = table.Merge(table.Copy(AMPlayer.DefaultMods), playerInfo.mods)
	self.OwnedMods = { "boost", "jump", "boost2", "flamethrower", "freezer", "cage", "bathroom", "combine" }
	self.Color = playerInfo.color
	
	self.Points = playerInfo.points

	self.GlobalKills = playerInfo.kills
	self.GlobalDeaths = playerInfo.deaths

	self.SessionKills = 0
	self.SessionDeaths = 0
	
	self.Health = 15
	self.Playing = false
	self.Alive = false

	self.PlayTime = playerInfo.playTime
	self.playTimeReference = nil

	ply.AMPlayer = self

	return self
end

-- Static methods
function AMPlayer.GetPlayer(ply)
	if IsValid(ply) then
		if not ply.AMPlayer then
			ply.AMPlayer = AMPlayer.New(ply)
		end
		return ply.AMPlayer
	end
end

-- Getters
function AMPlayer:GetEntity()
	if IsValid(self.Entity) and self.Entity:IsPlayer() then
		return self.Entity
	end
end

function AMPlayer:GetAirboat()
	return self.AMBoat
end

-- Setters
function AMPlayer:SetAirboat(amBoat)
	self.AMBoat = amBoat
end

-- Members methods
function AMPlayer:CheckKey(key)
	return self.Entity:KeyDown(key)
end

function AMPlayer:Respawn()
	AMMenu.ShowMenu(self.Entity)
end

function AMPlayer:SetPlaying(value)
	self.Playing = value

	if value then
		self.playTimeReference = CurTime()
	else
		local timePlayed = CurTime() - self.playTimeReference
		self.playTimeReference = null

		self.PlayTime = self.PlayTime + timePlayed

		self:Update({
			playTime = self.PlayTime
		})
	end
end

function AMPlayer:GetPlaying()
	return self.Playing
end

function AMPlayer:GetMods()
	return self.Mods
end

function AMPlayer:SetInfo(settings)
	settings.Color.a = 255
	self.Color = settings.Color

	for key, mod in pairs(settings.Mods) do
		if not AMMods.Mods[mod] then
			self:UnsetKey(key)
		else
			self:SetMod(mod)
		end
	end
end

function AMPlayer:Spawn()
	local ply = self.Entity

	if not ply:Alive() then
		ply:Spawn()
	end

	self.Alive = true
	self.WantToDie = false

	local amBoat = self:GetAirboat() or AMBoat.New()

	if not amBoat:GetEntity() or not amBoat:GetEntity():IsValid() then
		self:SetAirboat(amBoat)
		amBoat:SetPlayer(self)
		amBoat:Initialize()
	end

	local boat = amBoat:GetEntity()

	AMMenu.Send(ply, "Main", "SetStatus", "playing", {})

	self:SetPlaying(true)
	ply:EnterVehicle(boat)
	ply:EmitSound("ui/itemcrate_smash_ultrarare_short.wav")
	ParticleEffectAttach("ghost_smoke", PATTACH_ABSORIGIN_FOLLOW, boat, 0)

	amBoat:Spawn()
    
    hook.Call("AirboatMod.PostPlayerSpawn", nil, ply)
end

function AMPlayer:CanRespawn()
	if self:IsAlive() then
		return false
	elseif CurTime() - self.LastDeath >= AMMain.RespawnTime then
		return true
	end

	return false
end

function AMPlayer:IsOwningMod(modid)
	return table.HasValue(self.OwnedMods, modid)
end

function AMPlayer:SetMod(modid)
	local mod = AMMods.Mods[modid]
	if not mod then return end

	if mod.Type == "powerup" then return end

	if self:IsOwningMod(modid) then
		self.Mods[mod.Type] = modid

		self:Update({
			mods = self.Mods
		})
	else
		print("[AM] Player " .. self.Entity:Name() .. " doesn't have access to " .. modid)
	end
end

function AMPlayer:SetColor(color)
	color.a = 255

	self.Color = color

	self:Update({
		color = self.Color
	})
end

function AMPlayer:UnsetKey(key)
	self.Mods[key] = ""
end

function AMPlayer:Leave()
	local ply = self:GetEntity()

	if self:GetPlaying() then
		self:SetPlaying(false)

		AMMenu.Send(ply, "Main", "SetStatus", "notplaying", {})

		if self:GetAirboat() then
			self.Entity:ExitVehicle()
			self:GetAirboat():GetEntity():Remove()

			self.Entity:Spawn()

			self:GetAirboat():Synchronize()
		end

        hook.Call("AirboatMod.PostPlayerLeft", nil, ply)
	end
end

function AMPlayer:IsAlive()
	return self.Alive
end

function AMPlayer:Kill()
	local ply = self:GetEntity()
	local amBoat = self:GetAirboat()
	local boat = amBoat:GetEntity()

	self.Alive = false
	self.LastDeath = CurTime()

	self.WantToDie = false

	amBoat:ExplodeEffect()

	-- Make it invulnerable et respawn player
	boat:SetRenderMode(RENDERMODE_TRANSALPHA)

	local color = boat:GetColor()
	color.a = 100
	boat:SetColor(color)

	AMMenu.Send(ply, "Main", "SetStatus", "dead", {RespawnTime = AMMain.RespawnTime, CanRespawn = false})

	timer.Simple(AMMain.RespawnTime, function()
		if self:GetPlaying() then
			AMMenu.Send(ply, "Main", "SetStatus", "dead", {RespawnTime = 0, CanRespawn = self:CanRespawn()})
		end
	end)
end

function AMPlayer:Suicide()
	if not self:IsAlive() or self.WantToDie then return end
	local ply = self:GetEntity()

	self.WantToDie = true
	self.SuicideCountdown = CurTime()

	AMMenu.Send(ply, "Main", "SetStatus", "suicide", {SuicideTime = AMMain.SuicideTime})

	timer.Simple(AMMain.SuicideTime, function()
		if CurTime() - self.SuicideCountdown >= AMMain.SuicideTime and self.WantToDie then
			self:Kill()
		end
	end)
end

function AMPlayer:CancelSuicide()
	local ply = self:GetEntity()

	self.WantToDie = false

	AMMenu.Send(ply, "Main", "SetStatus", "playing", {})
end

function AMPlayer:GetSessionKills()
	return self.SessionKills
end

function AMPlayer:GetSessionDeaths()
	return self.SessionDeaths
end

function AMPlayer:IncrementKill()
	self.SessionKills = self.SessionKills + 1
	self.GlobalKills = self.GlobalKills + 1

	self:Update({
		kills = self.GlobalKills
	})

    hook.Call("AirboatMod.PostPlayerKilled", nil, self.Entity)
end

function AMPlayer:IncrementDeath()
	self.SessionDeaths = self.SessionDeaths + 1
	self.GlobalDeaths = self.GlobalDeaths + 1

	self:Update({
		deaths = self.GlobalDeaths
	})
end


function AMPlayer:Update(values)
	AMDatabase.Player.Update(self.Entity:SteamID(), values)
end
