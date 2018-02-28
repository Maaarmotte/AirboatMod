AMPlayer = {}
AMPlayer_mt = {__index = function(tab, key) return AMPlayer[key] end}

-- Constructor
function AMPlayer.New(ply)
	local self = {}
	setmetatable(self, AMPlayer_mt)

	self.Entity = ply
	self.AMBoat = nil
	self.Health = 15
	self.Playing = false
	self.Mods = {shift="boost", space="jump", mouse1=""}
	self.OwnedMods = { "boost", "jump", "boost2", "flamethrower", "freezer" }
	self.Score = 0

	ply.AMPlayer = self

	return self
end

-- Static methods
function AMPlayer.GetPlayer(ply)
	if ply and ply:IsValid() then
		if not ply.AMPlayer then
			ply.AMPlayer = AMPlayer.New(ply)
		end
		return ply.AMPlayer
	end
end

-- Getters
function AMPlayer:GetEntity()
	if self.Entity and self.Entity:IsValid() and self.Entity:IsPlayer() then
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
	self.Entity:Spawn()
end

function AMPlayer:SetPlaying(value)
	self.Playing = value
end

function AMPlayer:GetPlaying()
	return self.Playing
end

function AMPlayer:SetSettings(settings)
	for key, mod in pairs(settings.Mods) do
		if not AMMods.Mods[mod] then
			amPlayer:UnsetKey(key)
		else
			amPlayer:SetMod(mod)
		end
	end
end

function AMPlayer:Spawn()
	local ply = self.Entity

	if not ply:Alive() then
		ply:Spawn()
	end

	local amBoat = self:GetAirboat() or AMBoat.New()

	if not amBoat or not amBoat:GetEntity() or not amBoat:GetEntity():IsValid() then
		self:SetAirboat(amBoat)
		amBoat:SetPlayer(self)
		amBoat:Spawn()
	end

	local boat = amBoat:GetEntity()

	self:SetPlaying(true)
	ply:EnterVehicle(boat)
	ply:EmitSound("ui/itemcrate_smash_ultrarare_short.wav")
	ParticleEffectAttach("ghost_smoke", PATTACH_ABSORIGIN_FOLLOW, boat, 0)

	amBoat:AddInvulnerableTime(3)
	amBoat:SetHealth(15)
	amBoat:UnmountMods()

	for key, modid in pairs(self.Mods) do
		if modid ~= "" then
			amBoat:SetMod(modid)
		else
			amBoat:UnsetKey(key)
		end
	end

	amBoat:MountMods()

	amBoat:Synchronize()

	if not AMMain.Spawns[game.GetMap()] then return end

	-- Move the boat to a random spot in the area
	local rand = VectorRand()
	rand.x = math.abs(rand.x)
	rand.y = math.abs(rand.y)
	rand.z = math.abs(rand.z)
	local areaV1 = AMMain.Spawns[game.GetMap()][1]
	local areaV2 = AMMain.Spawns[game.GetMap()][2]
	local pos = areaV1 + rand*(areaV2 - areaV1)
	pos.z = (areaV1.z + areaV2.z)/2
	boat:SetPos(pos)
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
	else
		print("[AM] Player " .. self.Entity:Name() .. " doesn't have access to " .. modid)
	end
end

function AMPlayer:UnsetKey(key)
	self.Mods[key] = ""
end

function AMPlayer:Leave()
	if self:GetPlaying() then
		self:SetPlaying(false)

		if self:GetAirboat() then
			self.Entity:ExitVehicle()
			self:GetAirboat().Entity:Remove()

			self.Entity:Spawn()

			self:GetAirboat():Synchronize()
		end
	end
end
