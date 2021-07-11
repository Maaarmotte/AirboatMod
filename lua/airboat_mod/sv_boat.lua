-- /!\ This class is too big and should be split
util.AddNetworkString("am_boat_update")

AMBoat = AMBoat or {}
AMBoat_mt = AMBoat_mt or {
	__index = function(tab, key) return AMBoat[key] end,
	type = "AMBoat"
}

AMBoat.LastTouchedDelayForKill = 2.5
AMBoat.InvulnerableTimeAfterDamage = 0.5

-- Constructor
function AMBoat.New()
	local self = {}

	self.Entity = nil
	self.AMPlayer = nil
	self.AMPowerUp = nil
	self.Mods = {}
	self.Weapons = {}
	self.SmokeEntity = nil
	self.InvulnerableUntil = 0
	self.Health = 15
	setmetatable(self, AMBoat_mt)

	self.LastTouchedTime = nil
	self.LastTouchedBoat = nil
	
	return self
end

-- Static methods
function AMBoat.GetBoat(boat)
	if boat and boat:IsValid() then
		return boat.AMBoat
	end
end

function AMBoat.IsBoat(boat)
	return boat and getmetatable(boat) and getmetatable(boat).type == AMBoat_mt.type
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

function AMBoat:GetMods()
	return self.Mods
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
	self.Mods["powerup"] = AMMods.Instantiate(name, self)
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
		local ent = ents.Create("am_holo")
		ent:SetModel(model)
		ent:SetMoveType(MOVETYPE_NONE)
		ent:PhysicsInit(SOLID_NONE)
		ent:SetPos(self.Entity:LocalToWorld(pos))
		ent:SetAngles(self.Entity:LocalToWorldAngles(ang))

		-- ent:SetModelScale(scale, 0)
		-- local scaleVec = isnumber(scale) and Vector(scale, scale, scale) or scale
		-- local mat = Matrix()
		-- mat:Scale(scaleMat)
		-- print(ent)
		
		ent:SetMaterial(material)
		ent:SetColor(color)
		ent:SetParent(self.Entity)
		ent:Spawn()
		ent:Activate()
		ent:SetScale(scale)
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

	self.Entity:SetSubMaterial(0, "models/airboat-mod/airboat001")

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

function AMBoat:FindSpawn(attempt)
	if #AMSpawns == 0 or attempt == 100 then return end

	local validspawn = {}

	for _, spawn in pairs(AMSpawns) do
		if spawn.enabled and spawn.min ~= Vector(0,0,0) and spawn.max ~= Vector(0,0,0) then
			table.insert(validspawn, spawn)
		end
	end

	if #validspawn == 0 then return end

	local spawn = validspawn[math.random(1, #validspawn)]

	-- Move the boat to a random spot in the area
	local rand = VectorRand()
	rand.x = math.abs(rand.x)
	rand.y = math.abs(rand.y)
	local pos = spawn.min + rand*(spawn.max - spawn.min)

	local tr = util.TraceHull({
		start = Vector(pos.x, pos.y, spawn.max.z),
		endpos = Vector(pos.x, pos.y, spawn.min.z),
		mins = Vector(-100, -100, 0),
		maxs = Vector(100, 100, 150),
		mask = MASK_ALL
	})

	if tr.HitPos:Distance(tr.StartPos) == 0 then
		local attempt = (attempt or 0) + 1
		return self:FindSpawn(attempt)
	end

	return tr.HitPos
end

function AMBoat:Spawn()
	local amPly = self.AMPlayer
	local ply = amPly.Entity
	local boat = self:GetEntity()
	local phys = boat:GetPhysicsObject()

	self.Entity:SetColor(amPly.Color)

	self:AddInvulnerableTime(3)
	self:SetHealth(15)
	self:UnmountMods()

	for key, modid in pairs(amPly:GetMods()) do
		if modid ~= "" then
			self:SetMod(modid)
		else
			self:UnsetKey(key)
		end
	end

	self:UnsetKey("powerup")
	self:MountMods()
	self:Synchronize()

	boat:SetAngles(Angle(0, boat:GetAngles().yaw, 0))
	phys:SetVelocity(Vector(0, 0, 100))
	phys:AddAngleVelocity(-phys:GetAngleVelocity())
	local pos = self:FindSpawn()

	if pos then
		boat:SetPos(pos)
	end
end

function AMBoat:SetMod(modid)
	local mod = AMMods.Mods[modid]
	if not mod then return end

	local key = mod.Type

	if self.Mods[key] then
		self:UnsetKey(key)
	end

	self.Mods[key] = AMMods.Instantiate(modid, self)
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
	local amPly = self.AMPlayer

	if amPly:IsAlive() and not amPly.WantToDie then
		if amPly:CheckKey(IN_SPEED) and self.Mods["shift"] then
			self.Mods["shift"]:Activate(amPly, self)
		end
		if amPly:CheckKey(IN_JUMP) and self.Mods["space"] then
			self.Mods["space"]:Activate(amPly, self)
		end
		if amPly:CheckKey(IN_ATTACK) and self.Mods["mouse1"] then
			self.Mods["mouse1"]:Activate(amPly, self)
		end
		if amPly:CheckKey(IN_WALK) and self.Mods["powerup"] then
			self.Mods["powerup"]:Activate(amPly, self)
		end
	else
		if amPly:CheckKey(IN_JUMP) or amPly:CheckKey(IN_ATTACK) then
			if not amPly:IsAlive() then
				if CurTime() - amPly.LastDeath > AMMain.RespawnTime then
					amPly:Spawn()
				end
			elseif amPly.WantToDie then
				if CurTime() - amPly.SuicideCountdown < AMMain.SuicideTime then
					amPly:CancelSuicide()
				end
			end
		end
	end
end

function AMBoat:IsPlaying()
	return IsValid(self.Entity) and self.AMPlayer and IsValid(self.AMPlayer:GetEntity()) and self.AMPlayer:GetPlaying()
end

function AMBoat:Damage(amount, attacker)
	if AMBoat.IsBoat(attacker) then
		attacker = attacker:GetEntity()
	end

	for _, mod in pairs(self.Mods) do
		if mod.OnDamage then
			amount = mod:OnDamage(attacker, amount) or amount
		end
	end

	amBoat = AMBoat.GetBoat(attacker)
	if amBoat then
		for _, mod in pairs(amBoat:GetMods()) do
			if isfunction(mod.OnAttack) then
				amount = mod:OnAttack(amBoat, amount) or amount
			end
		end

		self.LastTouchedTime = CurTime()
		self.LastTouchedBoat = amBoat
	end

	if self:IsPlaying() and self.Health > 0 then
		self.Health = math.max(0, self.Health - amount)
		if self.Health == 0 then
			self:OnDeath(attacker)
		end
		self:Synchronize()
	end
end

function AMBoat:AddInvulnerableTime(value, transparendEffect)
	if not IsValid(self.Entity) then return end
	transparendEffect = true

	self.InvulnerableUntil = CurTime() + value

	local color = self.Entity:GetColor()

	if transparendEffect then
		self.Entity:SetRenderMode(RENDERMODE_TRANSALPHA)

		color.a = 100
		self.Entity:SetColor(color)
	end

	timer.Create("invul" .. self.Entity:EntIndex(), value, 1, function()
		if not IsValid(self.Entity) or not self:IsAlive() then return end

		color.a = 255
		self.Entity:SetColor(color)
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

		net.Start("am_boat_update")
			net.WriteTable({
				EntityId = self.Entity:EntIndex(),
				Health	 = self.Health,
				Player	 = self.AMPlayer:GetEntity(),
				Playing	 = self:IsPlaying(),
				Mods	 = mods
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
	local amPly = self.AMPlayer
	local ply = amPly:GetEntity()

	-- Kill the player
	amPly:Kill()

	-- Play effects and sounds
	local other = AMBoat.GetBoat(attacker)

	if not other and self.LastTouchedBoat and self.LastTouchedBoat:IsPlaying() and CurTime() - self.LastTouchedTime < AMBoat.LastTouchedDelayForKill then
		other = self.LastTouchedBoat
	end

	if other and other:IsPlaying() then
		other:GetEntity():EmitSound("ambient/bumper_car_cheer" .. math.random(3) .. ".wav")
		timer.Simple(1, function() other:GetEntity():EmitSound("items/samurai/tf_conch.wav") end)
	end

	-- Update score
	if IsValid(ply) then
		amPly:IncrementDeath()

		if other then
			local otherAmPly = other:GetPlayer()
			local otherPly = otherAmPly:GetEntity()

			if otherPly ~= ply then
				otherAmPly:IncrementKill()
			end

			if LogBox then
				LogBox:Broadcast(team.GetColor(otherPly:Team()), otherPly:Name() .. " (" .. otherAmPly:GetSessionKills() .. ")",
					Color(255, 255, 255), " completely destroyed ", team.GetColor(ply:Team()), ply:Name() .. " (" .. amPlay:GetSessionKills() .. ")")
			end
		else
			if LogBox then
				LogBox:Broadcast(team.GetColor(ply:Team()), ply:Name() .. " (" .. amPlay:GetSessionKills() .. ")",
					Color(255, 255, 255), " crushed himself into a wall !")
			end
		end
	end

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
	local self = AMBoat.GetBoat(boat)
	if not self or not boat:IsValid() or not self:IsPlaying() or not self:IsAlive() then return end

	-- Don't take too much collisions at the same time
	if CurTime() < self.InvulnerableUntil then return end

	-- Retrieve the entity hit and try to retrieve its boat structure
	local otherEntity = data.HitEntity
	local other = AMBoat.GetBoat(otherEntity)

	-- No damage if the other player is dead
	if other and not other:IsAlive() then return end

	-- Compute the damage this boat is taking
	local selfVel = 0
	local otherVel = 0

	local isWorld = otherEntity:IsWorld() or otherEntity:GetPersistent()

	if isWorld then
		selfVel = data.OurOldVelocity:Dot(data.HitNormal)
	elseif other and otherEntity:IsValid() and other:IsPlaying() then
		local collisionAxis = (boat:LocalToWorld(boat:OBBCenter()) - otherEntity:LocalToWorld(otherEntity:OBBCenter())):GetNormalized()
		selfVel = data.OurOldVelocity:Dot(collisionAxis)
		otherVel = data.TheirOldVelocity:Dot(collisionAxis)

		self.LastTouchedTime = CurTime()
		self.LastTouchedBoat = other
	end

	-- Apply the damage if the velocity is big enough
	if math.max(selfVel, otherVel) > 500 then
		if isWorld then
			self:Damage(5, otherEntity)
			self:AddInvulnerableTime(AMBoat.InvulnerableTimeAfterDamage)
		else
			if selfVel > otherVel then
				self:Damage(1, otherEntity)
				other:Damage(5, boat)
			else
				self:Damage(5, otherEntity)
				other:Damage(1, boat)
			end

			-- Add a small invulnerability time if hitam_boat_update
			self:AddInvulnerableTime(AMBoat.InvulnerableTimeAfterDamage)
			other:AddInvulnerableTime(AMBoat.InvulnerableTimeAfterDamage)

			otherEntity:EmitSound("weapons/bumper_car_hit" .. math.random(1, 8) .. ".wav")
		end
		
		boat:EmitSound("weapons/bumper_car_hit" .. math.random(1, 8) .. ".wav")
	end
end

function AMBoat:IsAlive()
	return self:GetPlayer() and self:GetPlayer():IsAlive()
end
