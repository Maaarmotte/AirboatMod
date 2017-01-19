local mod = {}

mod.Name = "jump"
mod.FullName = "Jump Boost"
mod.Delay = 3
mod.Type = "space"

function mod:Mount(amBoat)
	print("[AM] Mounting mod: " .. mod.Name)
end

function mod:Unmount(amBoat)
end

function mod:Run(amPly, amBoat)
	local boat = amBoat:GetEntity()
	local physobj = boat:GetPhysicsObject()
    physobj:SetVelocity(boat:GetVelocity() + boat:GetUp()*350)
    boat:EmitSound("weapons/bumper_car_jump.wav")
end

AMMods.Register(mod)