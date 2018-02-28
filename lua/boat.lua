util.AddNetworkString("am_boat_update")

AMBoat = {}
AMBoat_mt = {__index = function(tab, key) return AMBoat[key] end}

-- Constructor
function AMBoat.New()
	local self      	= {}
	self.Entity     	= nil
	self.AMPlayer   	= nil
	self.AMPowerUp  	= nil
	self.Mods       	= { shift=AMMods.Instantiate("boost"), space=AMMods.Instantiate("jump") }
	self.Weapons    	= {}
	self.SmokeEntity	= nil
	self.LastBump   	= 0
	self.Health     	= 15
	setmetatable(self, AMBoat_mt)

	return self
end

-- Static methods
function AMBoat.GetBoat(boat)
	if boat and boat:IsValid() then
		if not boat.AMBoat then
			boat.AMBoat = AMBoat.New()
		end
		return boat.AMBoat
	end
end

-- Getters
function AMBoat:GetPlayer()
	return self.AMPlayer
end

function AMBoat:GetEntity()
	return self.Entity
end

function AMBoat:GetHealth()
	return self.Health
end

function AMBoat:GetPowerUp()
	return self.AMPowerUp
end

function AMBoat:GetSmokeEntity()
	return self.SmokeEntity
end

-- Setters
function AMBoat:SetPlayer(amPly)
	self.AMPlayer = amPly
end

function AMBoat:SetHealth(value)
	self.Health = value
end

function AMBoat:MountPowerUp(name)
	self.Mods["powerup"] = AMMods.Instantiate(name)
	self.Mods["powerup"]:Mount(self)

	self:Synchronize()
end


function AMBoat:UnmountPowerUp()
	self.Mods["powerup"]:Unmount(self)
	self.Mods["powerup"] = nil
	self.PowerUpInfo = {}

	self:Synchronize()
end

-- Member methods
function AMBoat:ParentHolo(model, pos, ang, scale, material, color)
	if not color then color = Color(255, 255, 255, 255) end

	if IsValid(self.Entity) then
		local ent = ents.Create("prop_physics")
		ent:SetModel(model)
		ent:SetMoveType(MOVETYPE_NONE)
		ent:PhysicsInit(SOLID_NONE)
		ent:SetPos(self.Entity:LocalToWorld(pos))
		ent:SetAngles(self.Entity:LocalToWorldAngles(ang))
		ent:SetModelScale(scale, 0)
		ent:SetMaterial(material)
		ent:SetColor(color)
		ent:SetParent(self.Entity)
		ent:Spawn()
		ent:Activate()
		return ent
	end
end

function AMBoat:Initialize()
	if not self.AMPlayer then
		print("[Airboat] Can't spawn airboat without owner !")
		return
	end
	if self.Entity and self.Entity:IsValid() then
		self.Entity:Remove()
	end
	self.Entity = ents.Create("prop_vehicle_airboat")
	self.Entity:SetModel("models/airboat.mdl")
	self.Entity:SetPos(AMUtils.AimPosClamp(self.AMPlayer:GetEntity(), 250))
	if CPPI then self.Entity:CPPISetOwner(self.AMPlayer:GetEntity()) end
	self.Entity:Spawn()
	self.Entity:Activate()
	self.Entity:AddCallback("PhysicsCollide", AMBoat.CollisionCallback)
	self.Entity.AMBoat = self
	self.Entity.Use = function(self, activator, caller, useType, value) activator:ChatPrint("Coming soon !") end

	self.SmokeEntity = ents.Create("prop_physics")
	self.SmokeEntity:SetModel("models/props_junk/PopCan01a.mdl")
	self.SmokeEntity:SetPos(self.Entity:LocalToWorld(Vector(0, -110, 25)))
	self.SmokeEntity:SetNotSolid(true)
	self.SmokeEntity:Spawn()
	self.SmokeEntity:SetParent(self.Entity)
	self.SmokeEntity:SetColor(Color(0, 0, 0, 0))
	self.SmokeEntity:SetRenderMode(RENDERMODE_TRANSALPHA)

	self.Entity:EmitSound("ui/itemcrate_smash_ultrarare_short.wav")
	ParticleEffectAttach("ghost_smoke", PATTACH_ABSORIGIN_FOLLOW, self.Entity, 0)
end

function AMBoat:Spawn()
	local ply = self.AMPlayer.Entity
	local boat = self:GetEntity()

	self:AddInvulnerableTime(3)
	self:SetHealth(15)
	self:UnmountMods()

	for key, modid in pairs(self.Mods) do
		if modid ~= "" then
			self:SetMod(modid)
		else
			self:UnsetKey(key)
		end
	end

	self:UnsetKey("powerup")

	self:MountMods()

	self:Synchronize()

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

function AMBoat:SetMod(modid)
	local mod = AMMods.Mods[modid]
	if not mod then return end

	local key = mod.Type

	if self.Mods[key] then
		self:UnsetKey(key)
	end

	self.Mods[key] = AMMods.Instantiate(modid)
	-- self.Mods[key]:Mount(self)
end

function AMBoat:UnsetKey(key)
	-- self.Mods[key]:Unmount(self)
	self.Mods[key] = nil
end

function AMBoat:MountMods()
	if IsValid(self.Entity) then
		for _,v in pairs(self.Mods) do
			v:Mount(self)
		end
	end
end

function AMBoat:UnmountMods()
	if IsValid(self.Entity) then
		for _,v in pairs(self.Mods) do
			v:Unmount(self)
		end
	end
end

function AMBoat:CheckKeys()
	if self.AMPlayer:CheckKey(IN_SPEED) and self.Mods["shift"] then
		self.Mods["shift"]:Activate(self.AMPlayer, self)
	end
	if self.AMPlayer:CheckKey(IN_JUMP) and self.Mods["space"] then
		self.Mods["space"]:Activate(self.AMPlayer, self)
	end
	if self.AMPlayer:CheckKey(IN_ATTACK) and self.Mods["mouse1"] then
		self.Mods["mouse1"]:Activate(self.AMPlayer, self)
	end
	if self.AMPlayer:CheckKey(IN_WALK) and self.Mods["powerup"] then
		self.Mods["powerup"]:Activate(self.AMPlayer, self)
	end
end

function AMBoat:IsPlaying()
	return IsValid(self.Entity) and self.AMPlayer and IsValid(self.AMPlayer:GetEntity()) and self.AMPlayer:GetPlaying()
end

function AMBoat:Damage(amount, attacker)
	for _, mod in pairs(self.Mods) do
		if mod.OnDamage then
			amount = mod:OnDamage(self, attacker, amount)
		end
	end

	if attacker.AMBoat then
		for _, mod in pairs(attacker.AMBoat.Mods) do
			if mod.OnDamage then
				amount = mod:OnAttack(attacker.AMBoat, self, amount)
			end
		end
	end

	if self:IsPlaying() and self.Health > 0 then
		self.Health = math.max(0, self.Health - amount)
		if self.Health == 0 then
			self:OnDeath(attacker)
		end
		self:Synchronize()
	end
end

function AMBoat:AddInvulnerableTime(value)
	if not IsValid(self.Entity) then return end
	self.LastBump = CurTime() + value
	self.Entity:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.Entity:SetColor(Color(255, 255, 255, 100))

	timer.Create("invul" .. self.Entity:EntIndex(), value, 1, function()
		if not IsValid(self.Entity) then return end
		self.Entity:SetColor(Color(255, 255, 255, 255))
	end)
end

function AMBoat:Synchronize()
	if self.AMPlayer and self.AMPlayer:GetEntity() then
		local mods = {}

		for key, mod in pairs(self.Mods) do
			mods[key] = {
				Name = mod.Name,
				FullName = mod.FullName,
				Info = mod.ClientInfo or {}
			}
		end

		print("cc", self:IsPlaying())

		net.Start("am_boat_update")
			net.WriteTable({
				Entity	= self.Entity,
				Health	= self.Health,
				Player	= self.AMPlayer:GetEntity(),
				Playing	= self:IsPlaying(),
				Mods	= mods
			})
		net.Send(self.AMPlayer:GetEntity())
	end
end

function AMBoat:ExplodeEffect()
	self.Entity:EmitSound("items/cart_explode.wav")
	self.Entity:EmitSound("weapons/demo_charge_hit_flesh_range1.wav")

	ParticleEffectAttach("asplode_hoodoo_flash", PATTACH_ABSORIGIN_FOLLOW, self.Entity, 0)
	ParticleEffectAttach("asplode_hoodoo_shockwave", PATTACH_ABSORIGIN_FOLLOW, self.Entity, 0)
	ParticleEffectAttach("asplode_hoodoo_embers", PATTACH_ABSORIGIN_FOLLOW, self.Entity, 0)
	ParticleEffectAttach("asplode_hoodoo_dust", PATTACH_ABSORIGIN_FOLLOW, self.Entity, 0)
	ParticleEffectAttach("asplode_hoodoo", PATTACH_ABSORIGIN_FOLLOW, self.Entity, 0)
end

-- Hooks
function AMBoat:OnDeath(attacker)
	-- Kill the player
	self.AMPlayer:GetEntity():Kill()

	-- Play effects and sounds
	local other = attacker.AMBoat

	self:ExplodeEffect()

	if other and other:IsPlaying() then
		other:GetEntity():EmitSound("ambient/bumper_car_cheer" .. math.random(3) .. ".wav")
		timer.Simple(1, function() other:GetEntity():EmitSound("items/samurai/tf_conch.wav") end)
	end

	-- Make it invulnerable et respawn player
	self.Entity:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.Entity:SetColor(Color(255, 255, 255, 100))

	timer.Simple(4, function()
		if not self.AMPlayer.Entity:Alive() then
			self.AMPlayer:Respawn()
		end
	end)

	-- timer.Simple(2.75, function()
	-- 	local ply = self.AMPlayer:GetEntity()
	-- 	ply:EnterVehicle(self.Entity)
	-- end)
end

function AMBoat:Tick()
	if self:IsPlaying() then
		self:CheckKeys()

		for _,mod in pairs(self.Mods) do
			mod:Think(self)
		end
	end
end

-- Callbacks
function AMBoat.CollisionCallback(boat, data)
	-- Be sure that this boat is valid and currently playing
	local self = boat.AMBoat
	if not self or not boat:IsValid() or not self:IsPlaying() then return end

	-- Don't take too much collisions at the same time
	if CurTime() - self.LastBump < 0.5 then return end

	-- Retrieve the entity hit and try to retrieve its boat structure
	local otherEntity = data.HitEntity
	local other = otherEntity.AMBoat

	-- Compute the damage this boat is taking
	local selfVel = 0
	local otherVel = 0

	if otherEntity:IsWorld() then
		selfVel = data.OurOldVelocity:Dot(data.HitNormal)
	elseif other and otherEntity:IsValid() and other:IsPlaying() then
		local collisionAxis = (boat:LocalToWorld(boat:OBBCenter()) - otherEntity:LocalToWorld(otherEntity:OBBCenter())):GetNormalized()
		selfVel = data.OurOldVelocity:Dot(collisionAxis)
		otherVel = data.TheirOldVelocity:Dot(collisionAxis)
	end

	-- Apply the damage if the velocity is big enough
	if math.max(selfVel, otherVel) > 500 then
		if otherEntity:IsWorld() then
			self:Damage(5, otherEntity)
			self.LastBump = CurTime()
		else
			if selfVel > otherVel then
				self:Damage(1, otherEntity)
				other:Damage(5, boat)
			else
				self:Damage(5, otherEntity)
				other:Damage(1, boat)

				-- Add a small invulnerability time if hit
				self.LastBump = CurTime()
				other.LastBump = CurTime()

				otherEntity:EmitSound("weapons/bumper_car_hit" .. math.random(1, 8) .. ".wav")
			end
		end
		boat:EmitSound("weapons/bumper_car_hit" .. math.random(1, 8) .. ".wav")
	end
end
