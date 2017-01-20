util.AddNetworkString("am_boat_update")

AMBoat = {}
AMBoat_mt = { __index = AMBoat }

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

function AMBoat:SetPowerUp(powerupName)
	self.AMPowerUp = AMPowerUps.Instantiate(powerupName)
	AMPowerUps.Initalite(self.AMPowerUp, self)
	self:Synchronize()
end

function AMBoat:UnsetPowerUp()
	self.AMPowerUp = nil
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
	if self.AMPlayer:CheckKey(IN_SPEED) then
		self.Mods["shift"]:Activate(self.AMPlayer, self)
	end
	if self.AMPlayer:CheckKey(IN_JUMP) then
		self.Mods["space"]:Activate(self.AMPlayer, self)
	end
	if self.AMPlayer:CheckKey(IN_WALK) then
		if self.AMPowerUp then
			AMPowerUps.Use(self:GetPowerUp(), self)
		end
	end
end

function AMBoat:IsPlaying()
	return self.Entity and self.Entity:IsValid() and self.AMPlayer and self.AMPlayer:GetEntity() and self.AMPlayer:GetEntity():IsValid() and self.Entity:GetDriver() == self.AMPlayer:GetEntity()
end

function AMBoat:Damage(amount, attacker)
	local amount = hook.Call("AMBoat_Damage", GM, self, amount, attacker.AMBoat) or amount

	if not blockdmg then
		self.Health = math.max(0, self.Health - amount)
		if self.Health == 0 then
			self:OnDeath(attacker)
		end
		self:Synchronize()
	end
end

function AMBoat:AddInvulnerableTime(value)
	self.LastBump = CurTime() + value
	self.Entity:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.Entity:SetColor(Color(255, 255, 255, 100))
	
	timer.Create("invul" .. self.Entity:EntIndex(), value, 1, function()
		self.Entity:SetColor(Color(255, 255, 255, 255))
	end)
end

function AMBoat:Synchronize()
	if self.AMPlayer and self.AMPlayer:GetEntity() then
		local powerup = "None"
		if self:GetPowerUp() then
			powerup = self:GetPowerUp().FullName or "None"
		end
		net.Start("am_boat_update")
			net.WriteTable({ Entity=self.Entity, Health=self.Health, Player=self.AMPlayer:GetEntity(), Playing=self:IsPlaying(), PowerUp=powerup })
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
	
	timer.Simple(2.5, function() 
		self.AMPlayer:Respawn()
	end)
	
	timer.Simple(2.75, function()
		local ply = self.AMPlayer:GetEntity()
		ply:EnterVehicle(self.Entity)
	end)
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