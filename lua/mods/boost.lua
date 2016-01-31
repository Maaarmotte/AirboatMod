local mod = {}

mod.Name = "boost"
mod.FullName = "Speed Boost"
mod.Delay = 5
mod.Type = "shift"

function mod:Run(amPly, amBoat)
	local boat = amBoat:GetEntity()
	local physobj = boat:GetPhysicsObject()
    physobj:SetVelocity(boat:GetVelocity() + boat:GetForward()*1000)
    boat:EmitSound("weapons/bumper_car_speed_boost_start.wav")
    ParticleEffectAttach("smoke_whitebillow", PATTACH_ABSORIGIN_FOLLOW, amBoat:GetSmokeEntity(), 0)
    timer.Simple(1, function()
        amBoat:GetSmokeEntity():StopParticles()
    end)
end

AMMods.Register(mod)