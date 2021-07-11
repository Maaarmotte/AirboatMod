local mod = {}

mod.Name = "flamethrower"
mod.FullName = "Flamethrower"
mod.Delay = 0
mod.Type = "mouse1"
mod.Range = 375
mod.RangeSqr = mod.Range*mod.Range
mod.Damage = 0.5
mod.DamageDelay = 0.25
mod.StartReloadDelay = 1
mod.ReloadDelay = 0.125
mod.PushForce = 50

mod.Anchor = Vector(18.026478, 27.837114, 47.955334)
mod.Turret = nil
mod.Burning = false
mod.Loop = false

mod.Start = 0
mod.StopBurningTime = 0
mod.LastBurningTick = 0
mod.LastReloadTick = 0

mod.BaseAmount = 15


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

function mod:Initialize()
	self.Amount = self.BaseAmount
	self:SendInfoToClent({Amount = self.Amount})
end

function mod:OnMount()
	self.Turret = self:MountHolo("models/workshop_partner/weapons/c_models/c_ai_flamethrower/c_ai_flamethrower.mdl", self.Anchor, Angle(0, 90, 0), 1)
	self.Flames = self:MountHolo("models/props_junk/PopCan01a.mdl", self.Anchor + Vector(0, 50, 3), Angle(0, 90, 0), 0)
	self.Flames:SetParent(self.Turret)
end

mod.LastAmount = 1
function mod.Draw(info, w, y)
	surface.SetFont("am_hud_title")
	surface.SetTextColor(235, 235, 235, 255)
	surface.SetTextPos(12, y)
	surface.DrawText(mod.FullName)

	local bw = w - 20
	local amount = info.Amount / mod.BaseAmount

	mod.LastAmount = mod.LastAmount + (amount - mod.LastAmount) / 60
	
	surface.SetDrawColor(75, 75, 75, 255)
	surface.DrawRect(10, y + 20, bw, 20)

	surface.SetDrawColor(255, 191, 0, 255)
	surface.DrawRect(10, y + 20, bw * mod.LastAmount, 20)

	return 40
end


function mod:OnUnmount()
	if IsValid(self.Turret) then
		self.Turret:Remove()
	end
end

function mod:Think()
	local amPly = self.AMBoat:GetPlayer()

	if amPly:GetPlaying() and IsValid(self.Turret) then
		local ang = amPly:GetEntity():EyeAngles()
		local boat = self.AMBoat:GetEntity()

		if IsValid(boat) then
			self.Turret:SetPos(boat:LocalToWorld(self.Anchor) + ang:Forward() * 11)
			self.Turret:SetAngles(ang)
		end
	end

	local now = CurTime()

	if not self.Burning and  self.Amount < mod.BaseAmount then
		if now - self.StopBurningTime > mod.StartReloadDelay and now - self.LastReloadTick > mod.ReloadDelay then
			self.Amount = self.Amount + 1
			self:SendInfoToClent({Amount = self.Amount})

			self.LastReloadTick = now
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
	
	self.StopBurningTime = CurTime();
end

function mod:Run()
	local t = CurTime()

	if self.Amount <= 0 then
		return
	end

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

	local ply = self.AMBoat:GetPlayer():GetEntity()
	if IsValid(ply) and t - self.LastBurningTick > self.DamageDelay then
		local tr = util.TraceLine({
			start = self.Turret:GetPos(),
			endpos = self.Turret:GetPos() + self.Turret:GetForward()*self.Range,
			filter = self.Turret
		})

		local target = tr.Entity
		local targetAmBoat = AMBoat.GetBoat(target)

		if IsValid(target) and (self.AMBoat:GetEntity():GetPos() - target:GetPos()):LengthSqr() < self.RangeSqr then
			if targetAmBoat and targetAmBoat:GetHealth() > 0 then
				target.AMBoat:Damage(self.Damage, self.AMBoat:GetEntity())
				target:EmitSound("flamethrower_hit")
			end

			local physobj = target:GetPhysicsObject()
			if IsValid(physobj) then
				physobj:SetVelocity(physobj:GetVelocity() + self.Turret:GetForward() * mod.PushForce)
			end
		end

		self.Amount = self.Amount - 1
		self:SendInfoToClent({Amount = self.Amount})
		
		self.LastBurningTick = t
	end

	timer.Create("flames" .. tostring(self), math.max(self.LastBurningTick + self.DamageDelay - t, 0.05), 1, self.StopFlamesFunc)
end

AMMods.Register(mod)
