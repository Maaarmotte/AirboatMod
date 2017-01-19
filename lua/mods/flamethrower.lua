local mod = {}

mod.Name = "flamethrower"
mod.FullName = "Flamethrower"
mod.Delay = 0
mod.Type = "mouse1"

mod.Anchor = Vector(18.026478, 27.837114, 47.955334)
mod.Turret = nil

function mod:Mount(amBoat)
	print("[AM] Mounting mod: " .. mod.Name)

	local boat = amBoat:GetEntity()
	local ent = ents.Create("prop_physics")
	ent:SetAngles(boat:LocalToWorldAngles(Angle(0, 90, 0)))
	ent:SetPos(boat:LocalToWorld(self.Anchor) - ent:LocalToWorld(Vector(11, 0, 0)))
	ent:SetModel("models/workshop/weapons/c_models/c_ai_flamethrower/c_ai_flamethrower.mdl")
	ent:SetParent(boat)
	ent:Spawn()
	ent:Activate()

	self.Turret = ent
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

function mod:Run(amPly, amBoat)
	--[[local boat = amBoat:GetEntity()
	local physobj = boat:GetPhysicsObject()

	boat:EmitSound("weapons/bumper_car_speed_boost_start.wav")
    ParticleEffectAttach("smoke_whitebillow", PATTACH_ABSORIGIN_FOLLOW, amBoat:GetSmokeEntity(), 0)

	timer.Create("boost2" .. amBoat:GetEntity():EntIndex(), 0.25, 0, function()
		physobj:SetVelocity(boat:GetVelocity() + boat:GetForward()*100)
	end)
    timer.Simple(5, function()
        amBoat:GetSmokeEntity():StopParticles()
        timer.Destroy("boost2" .. amBoat:GetEntity():EntIndex())
    end)]]--
end

AMMods.Register(mod)