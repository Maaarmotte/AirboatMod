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
	self.Mods = { "boost", "jump", "boost2", "flamethrower", "freezer" }
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

function AMPlayer:Spawn()
	local ply = self.Entity

	local amBoat = self:GetAirboat()
	if not amBoat or not amBoat:GetEntity() or not amBoat:GetEntity():IsValid() then return end

	local boat = amBoat:GetEntity()

	self:SetPlaying(true)
	ply:EnterVehicle(boat)
	ply:EmitSound("ui/itemcrate_smash_ultrarare_short.wav")
	ParticleEffectAttach("ghost_smoke", PATTACH_ABSORIGIN_FOLLOW, boat, 0)

	amBoat:AddInvulnerableTime(3)
	amBoat:SetHealth(15)
	-- amBoat:UnmountMods()
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

function AMPlayer:SetMod(modid)
	local mod = AMMods.Mods[modid]
	if not mod then return end

	local amBoat = self:GetAirboat()
	if not amBoat then return end

	if mod and table.HasValue(self.Mods, modid) then
		amBoat:SetMod(modid)
	else
		print("[AM] Player " .. self.Entity:Name() .. " doesn't have access to " .. modid)
	end
end

function AMPlayer:UnsetKey(key)
	local amBoat = self:GetAirboat()
	if not amBoat then return end

	amBoat:UnsetKey(key)
end
