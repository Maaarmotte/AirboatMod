local mod = {}

mod.Name = "boost2"
mod.FullName = "Longer Slower Boost"
mod.Delay = 5
mod.Type = "shift"
mod.LastBoost = 0

function mod:Mount(amBoat)
	print("[AM] Mounting mod: " .. mod.Name)

	self:MountHolo(amBoat, "models/props_trainstation/mount_connection001a.mdl", Vector(25, -40, 40), Angle(0, 0, 0), 0.5, "models/props_pipes/pipeset_metal", Color(250, 150, 100))
	self:MountHolo(amBoat, "models/props_trainstation/mount_connection001a.mdl", Vector(-25, -40, 40), Angle(0, -180, 0), 0.5, "models/props_pipes/pipeset_metal", Color(250, 150, 100))
	self:MountHolo(amBoat, "models/props_c17/canister_propane01a.mdl", Vector(40, -30, 50), Angle(0, 0, 90), 0.4, "models/props_pipes/pipeset_metal", Color(250, 150, 100))
	self:MountHolo(amBoat, "models/props_c17/canister_propane01a.mdl", Vector(-40, -30, 50), Angle(0, 0, 90), 0.4, "models/props_pipes/pipeset_metal", Color(250, 150, 100))

	self.PropellerR1 = self:MountHolo(amBoat, "models/props_phx/misc/propeller3x_small.mdl", Vector(40, -55, 50), Angle(0, 0, 90), 0.3, "models/props_pipes/pipeset_metal", Color(250, 150, 100))
	self.PropellerR2 = self:MountHolo(amBoat, "models/props_phx/misc/propeller3x_small.mdl", Vector(40, -55, 50), Angle(45, 0, 90), 0.3, "models/props_pipes/pipeset_metal", Color(250, 150, 100))

	self.PropellerL1 = self:MountHolo(amBoat, "models/props_phx/misc/propeller3x_small.mdl", Vector(-40, -55, 50), Angle(0, 0, 90), 0.3, "models/props_pipes/pipeset_metal", Color(250, 150, 100))
	self.PropellerL2 = self:MountHolo(amBoat, "models/props_phx/misc/propeller3x_small.mdl", Vector(-40, -55, 50), Angle(45, 0, 90), 0.3, "models/props_pipes/pipeset_metal", Color(250, 150, 100))
end

function mod:Unmount(amBoat)
end

function mod.Draw(info, w, y, amBoat, amPlayer)
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

function mod:Think(amBoat)
	local t = CurTime()
	local yaw = 5
	if t - self.LastBoost < self.Delay then
		yaw = yaw + 10
	else
		yaw = yaw + math.max(2 - (t - self.LastBoost - self.Delay), 0)*10
	end

	-- So many propellers !
	local angR1 = self.PropellerR1:GetAngles()
	local angR2 = self.PropellerR2:GetAngles()
	local angL1 = self.PropellerL1:GetAngles()
	local angL2 = self.PropellerL2:GetAngles()

	angR1:RotateAroundAxis(self.PropellerR1:GetUp(), yaw)
	angR2:RotateAroundAxis(self.PropellerR2:GetUp(), -yaw)
	angL1:RotateAroundAxis(self.PropellerL1:GetUp(), yaw)
	angL2:RotateAroundAxis(self.PropellerL2:GetUp(), -yaw)

	self.PropellerR1:SetAngles(angR1)
	self.PropellerR2:SetAngles(angR2)
	self.PropellerL1:SetAngles(angL1)
	self.PropellerL2:SetAngles(angL2)
end

function mod:Run(amPly, amBoat)
	local boat = amBoat:GetEntity()
	local physobj = boat:GetPhysicsObject()

	self:SendInfoToClent(amBoat, {Start = CurTime()})

	boat:EmitSound("weapons/bumper_car_speed_boost_start.wav")
    ParticleEffectAttach("smoke_whitebillow", PATTACH_ABSORIGIN_FOLLOW, amBoat:GetSmokeEntity(), 0)

	timer.Create("boost2" .. amBoat:GetEntity():EntIndex(), 0.25, 0, function()
		physobj:SetVelocity(boat:GetVelocity() + boat:GetForward()*100)
	end)
    timer.Simple(self.Delay, function()
        amBoat:GetSmokeEntity():StopParticles()
        timer.Destroy("boost2" .. amBoat:GetEntity():EntIndex())
    end)

   	self.LastBoost = CurTime()
end

AMMods.Register(mod)
