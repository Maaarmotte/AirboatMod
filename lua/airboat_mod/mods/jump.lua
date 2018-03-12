local mod = {}

mod.Name = "jump"
mod.FullName = "Jump Boost"
mod.Delay = 3
mod.Type = "space"

function mod.Draw(info, w, y, amBoat, amPlayer)

	return 0
end

function mod:Mount(amBoat)
	print("[AM] Mounting mod: " .. mod.Name)

	self.LastJump = 0
	self.Pole = self:MountHolo(amBoat, "models/props_docks/dock01_pole01a_128.mdl", Vector(0, -25, 65), Angle(0, 90, 0), 0.5)
	self.Propeller = self:MountHolo(amBoat, "models/props_citizen_tech/windmill_blade004a.mdl", Vector(0, -28, 97), Angle(-90, 90, 00), 0.5)
	self.Propeller:SetParent(self.Pole)
end

function mod:Unmount(amBoat)
end

function mod:Think(amBoat)
	local t = CurTime()
	local yaw = 5
	if t - self.LastJump < 1 then
		yaw = yaw + 10
	else
		yaw = yaw + math.max(2 - (t - self.LastJump), 0)*10
	end

	local ang = self.Pole:GetAngles()
	ang:RotateAroundAxis(amBoat:GetEntity():GetUp(), yaw)
	self.Pole:SetAngles(ang)
end

function mod:Run(amPly, amBoat)
	local boat = amBoat:GetEntity()
	local physobj = boat:GetPhysicsObject()
    physobj:SetVelocity(boat:GetVelocity() + boat:GetUp()*350)
    boat:EmitSound("weapons/bumper_car_jump.wav")
    self.LastJump = CurTime()
end

AMMods.Register(mod)
