local mod = {}

mod.Name = "boost2"
mod.FullName = "Longer, Slower Boost"
mod.Delay = 5
mod.Type = "shift"

function mod:Run(amPly, amBoat)
	local boat = amBoat:GetEntity()
	local physobj = boat:GetPhysicsObject()

	boat:EmitSound("weapons/bumper_car_speed_boost_start.wav")
    ParticleEffectAttach("smoke_whitebillow", PATTACH_ABSORIGIN_FOLLOW, amBoat:GetSmokeEntity(), 0)

	timer.Create("boost2" .. self.Entity:EntIndex(), 0.25, 0, function()
		physobj:SetVelocity(boat:GetVelocity() + boat:GetForward()*500)
	end)
    timer.Simple(5, function()
        amBoat:GetSmokeEntity():StopParticles()
        timer.Destroy("boost2" .. self.Entity:EntIndex())
    end)
end

AMMods.Register(mod)