local mod = {}

mod.Name		= "powerup.haste"
mod.FullName	= "Haste"
mod.Type		= "powerup"
mod.BaseAmount	= 3
mod.Delay 		= 1

mod.Model		= "models/pickups/pickup_powerup_haste.mdl"
mod.ModelScale	= 1.6
mod.ModelOffset	= -Vector(0,0,36*mod.ModelScale)

function mod:Mount(amBoat)
	self.Amount = self.BaseAmount
end

function mod:Unmount(amBoat)
end

function mod:Run(amPly, amBoat)
	local boat   	= amBoat:GetEntity()
	local physobj	= boat:GetPhysicsObject()
	self.Amount = self.Amount - 1

	physobj:SetVelocity(boat:GetVelocity() + boat:GetForward()*1000)
	boat:EmitSound("weapons/bumper_car_speed_boost_start.wav")

print(self.Amount)
	if self.Amount <= 0 then
		amBoat:UnmountPowerUp()
	end
end

AMMods.Register(mod)
