local mod = {}

mod.Name = "boost"
mod.FullName = "Standard Boost"
mod.Delay = 5
mod.Type = "shift"

function mod:OnMount()
	self:MountHolo("models/xqm/jetengine.mdl", Vector(35, -30, 50), Angle(0, 90, 0), 0.8)
	self:MountHolo("models/xqm/jetengine.mdl", Vector(-35, -30, 50), Angle(0, 90, 0), 0.8)
	self:MountHolo("models/props_trainstation/mount_connection001a.mdl", Vector(25, -40, 40), Angle(0, 0, 0), 0.5, "models/props_canal/metalwall005b")
	self:MountHolo("models/props_trainstation/mount_connection001a.mdl", Vector(-25, -40, 40), Angle(0, -180, 0), 0.5, "models/props_canal/metalwall005b")
end

function mod:OnUnmount()
end

function mod.Draw(info, w, y)
	surface.SetFont("am_hud_title")
	surface.SetTextColor(235, 235, 235, 255)
	surface.SetTextPos(12, y)
	surface.DrawText(mod.FullName)

	local bw = w - 20
	local time = 1

	if info.Start then
		time = math.min((CurTime() - info.Start)/mod.Delay, 1)
	end

	surface.SetDrawColor(75, 75, 75, 255)
	surface.DrawRect(10, y + 20, bw, 20)
	surface.SetDrawColor(200, 31, 19, 255)
	surface.DrawRect(10, y + 20, bw * time, 20)

	return 40
end

function mod:Run()
	local boat = self.AMBoat:GetEntity()
	local physobj = boat:GetPhysicsObject()

	self:SendInfoToClent({Start = CurTime()})

    physobj:SetVelocity(boat:GetVelocity() + boat:GetForward()*1000)
    boat:EmitSound("weapons/bumper_car_speed_boost_start.wav")
    ParticleEffectAttach("smoke_whitebillow", PATTACH_ABSORIGIN_FOLLOW, self.AMBoat:GetSmokeEntity(), 0)
    timer.Simple(1, function()
        self.AMBoat:GetSmokeEntity():StopParticles()
    end)
end

AMMods.Register(mod)
