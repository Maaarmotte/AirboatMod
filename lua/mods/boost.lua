local mod = {}

mod.Name = "boost"
mod.FullName = "Standard Boost"
mod.Delay = 5
mod.Type = "shift"

function mod:Mount(amBoat)
	print("[AM] Mounting mod: " .. mod.Name)

	self:MountHolo(amBoat, "models/xqm/jetengine.mdl", Vector(35, -30, 50), Angle(0, 90, 0), 0.8)
	self:MountHolo(amBoat, "models/xqm/jetengine.mdl", Vector(-35, -30, 50), Angle(0, 90, 0), 0.8)
	self:MountHolo(amBoat, "models/props_trainstation/mount_connection001a.mdl", Vector(25, -40, 40), Angle(0, 0, 0), 0.5, "models/props_canal/metalwall005b")
	self:MountHolo(amBoat, "models/props_trainstation/mount_connection001a.mdl", Vector(-25, -40, 40), Angle(0, -180, 0), 0.5, "models/props_canal/metalwall005b")
end

function mod:Unmount(amBoat)
end

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