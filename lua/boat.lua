AMBoat = {}
AMBoat_mt = { __index = AMBoat }

function AMBoat.New()
	local self = {}
	self.Entity = nil
	self.AMPlayer = nil
	self.Mods = { shift=AMMods.Instantiate("boost"), space=AMMods.Instantiate("jump") }
	self.Weapons = {}
	self.SmokeEntity = nil
	self.LastBump = 0
	self.Health = 15
	setmetatable(self, AMBoat_mt)
	return self
end

function AMBoat:SetPlayer(amPly)
	self.AMPlayer = amPly
end

function AMBoat:SetHealth(value)
	self.Health = value
end

function AMBoat:GetPlayer()
	return self.AMPlayer
end

function AMBoat:GetEntity()
	return self.Entity
end

function AMBoat:GetSmokeEntity()
	return self.SmokeEntity
end

function AMBoat:Spawn()
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
	self.Entity:CPPISetOwner(self.AMPlayer:GetEntity())
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

function AMBoat:Tick()
	if self:IsPlaying() then
		self:CheckKeys()
	end
end

function AMBoat:CheckKeys()
	if self.AMPlayer:CheckKey(IN_SPEED) then
		self.Mods["shift"]:Activate(self.AMPlayer, self)
	elseif self.AMPlayer:CheckKey(IN_JUMP) then
		self.Mods["space"]:Activate(self.AMPlayer, self)
	end
end

function AMBoat:IsPlaying()
	return self.Entity and self.Entity:IsValid() and self.AMPlayer and self.AMPlayer:GetEntity() and self.AMPlayer:GetEntity():IsValid() and self.Entity:GetDriver() == self.AMPlayer:GetEntity()
end

function AMBoat:Damage(amount, attacker)
	self.Health = math.max(0, self.Health - amount)
	if self.Health == 0 then
		self:OnDeath(attacker)
	end
end

function AMBoat:AddInvulnerableTime(value)
	self.LastCollision = CurTime() + value
	self.Entity:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.Entity:SetColor(Color(255, 255, 255, 100))
	
	timer.Create("invul" .. self.Entity:EntIndex(), value, 1, function()
		self.Entity:SetColor(Color(255, 255, 255, 255))
	end)
end

function AMBoat:OnDeath(attacker)
	-- Kill the player
	self.AMPlayer:GetEntity():Kill()

	-- Play effects and sounds
	local other = attacker.AMBoat
	
	self.Entity:EmitSound("items/cart_explode.wav")
	self.Entity:EmitSound("weapons/demo_charge_hit_flesh_range1.wav")
	
	ParticleEffectAttach("asplode_hoodoo_flash", PATTACH_ABSORIGIN_FOLLOW, self.Entity, 0)
	ParticleEffectAttach("asplode_hoodoo_shockwave", PATTACH_ABSORIGIN_FOLLOW, self.Entity, 0)
	ParticleEffectAttach("asplode_hoodoo_embers", PATTACH_ABSORIGIN_FOLLOW, self.Entity, 0)
	ParticleEffectAttach("asplode_hoodoo_dust", PATTACH_ABSORIGIN_FOLLOW, self.Entity, 0)
	ParticleEffectAttach("asplode_hoodoo", PATTACH_ABSORIGIN_FOLLOW, self.Entity, 0)
	
	if other and other:IsPlaying() then
		other:GetEntity():EmitSound("ambient/bumper_car_cheer" .. math.random(3) .. ".wav")
		timer.Simple(1, function() other:GetEntity():EmitSound("items/samurai/tf_conch.wav") end)
	end
	
	-- Make it invulnerable et respawn player	
	self.Entity:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.Entity:SetColor(Color(255, 255, 255, 100))
	
	timer.Simple(2.5, function() 
		self.AMPlayer:Respawn()
	end)
	
	timer.Simple(2.75, function()
		local ply = self.AMPlayer:GetEntity()
		ply:EnterVehicle(self.Entity)
	end)
end

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
		if selfVel > otherVel and not otherEntity:IsWorld() then
			self:Damage(1, otherEntity)
		else
			self:Damage(5, otherEntity)
		end
		boat:EmitSound("weapons/bumper_car_hit" .. math.random(1, 8) .. ".wav")
		
		-- Add a small invulnerability time if hit
		self.LastBump = CurTime()
	end
end