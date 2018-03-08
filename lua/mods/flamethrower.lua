local mod = {}

mod.Name = "flamethrower"
mod.FullName = "Flamethrower"
mod.Delay = 0
mod.Type = "mouse1"
mod.Range = 375
mod.RangeSqr = mod.Range*mod.Range
mod.Damage = 0.5
mod.DamageDelay = 0.25

mod.Anchor = Vector(18.026478, 27.837114, 47.955334)
mod.Turret = nil
mod.Start = 0
mod.Burning = false
mod.Loop = false
mod.LastDamage = 0

sound.Add({
	name = "flamethrower_start",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = 100,
	sound = "weapons/flame_thrower_start.wav"
})

sound.Add({
	name = "flamethrower_loop",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = 100,
	sound = "weapons/flame_thrower_loop.wav"
})

sound.Add({
	name = "flamethrower_hit",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = 100,
	sound = "weapons/3rd_degree_hit_01.wav"
})

function mod:Mount(amBoat)
	print("[AM] Mounting mod: " .. mod.Name)

	self.Turret = self:MountHolo(amBoat, "models/workshop_partner/weapons/c_models/c_ai_flamethrower/c_ai_flamethrower.mdl", self.Anchor, Angle(0, 90, 0), 1)
	self.Flames = self:MountHolo(amBoat, "models/props_junk/PopCan01a.mdl", self.Anchor + Vector(0, 50, 3), Angle(0, 90, 0), 0)
	self.Flames:SetParent(self.Turret)
end

function mod:Unmount(amBoat)
	if IsValid(self.Turret) then
		self.Turret:Remove()
	end
end

function mod:Think(amBoat)
	local amPly = amBoat:GetPlayer()

	if amPly:GetPlaying() and IsValid(self.Turret) then
		local aim = amPly:GetEntity():GetAimVector()
		local ang = aim:Angle()
		local boat = amBoat:GetEntity()

		if IsValid(boat) then
			self.Turret:SetPos(self.Anchor + boat:WorldToLocal(boat:GetPos() - aim)*11)
			self.Turret:SetAngles(ang) 
		end
	end
end

function mod:StopFlames()
	self.Burning = false
	self.Loop = false
	if IsValid(self.Flames) then
		self.Flames:StopParticles()
		self.Flames:StopSound("flamethrower_start")
		self.Flames:StopSound("flamethrower_loop")
	end
end

function mod:Run(amPly, amBoat)
	local t = CurTime()

	if not self.Burning then
		ParticleEffectAttach("flamethrower", PATTACH_ABSORIGIN_FOLLOW, self.Flames, 0)
		self.Flames:EmitSound("flamethrower_start")
		self.Burning = true
		self.Start = t
	end

	if not self.Loop and t - self.Start > 3.6 then
		self.Flames:EmitSound("flamethrower_loop")
		self.Loop = true
	end

	if not self.StopFlamesFunc then
		self.StopFlamesFunc = function() self:StopFlames() end
	end

	local ply = amPly:GetEntity()
	if IsValid(ply) and t - self.LastDamage > self.DamageDelay then
		local tr = util.TraceLine({
			start = self.Turret:GetPos(),
			endpos = self.Turret:GetPos() + self.Turret:GetForward()*self.Range,
			filter = self.Turret
		})

		local target = tr.Entity
		local targetAmBoat = AMBoat.GetBoat(target)

		if target and targetAmBoat and targetAmBoat:GetHealth() > 0 and (amBoat:GetEntity():GetPos() - target:GetPos()):LengthSqr() < self.RangeSqr then
			target.AMBoat:Damage(self.Damage, amBoat:GetEntity())
			target:EmitSound("flamethrower_hit")
			self.LastDamage = t
		end
	end

	timer.Create("flames" .. tostring(self), 0.05, 1, self.StopFlamesFunc)
end

AMMods.Register(mod)