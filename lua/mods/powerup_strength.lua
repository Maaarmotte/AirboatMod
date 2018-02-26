local mod = {}

mod.Name      	= "powerup.strength"
mod.FullName  	= "Strength"
mod.Type 		= "powerup"
mod.BaseAmount	= 1
mod.Duration  	= 4
mod.ReloadTime	= 0

mod.Model      	= "models/pickups/pickup_powerup_strength.mdl"
mod.ModelScale 	= 1.6
mod.ModelOffset	= -Vector(0,0,36*mod.ModelScale)

function mod:Mount(amBoat)
end

function mod:Unmount(amBoat)
end

function mod:Run(amPly, amBoat)
	if self.isRuning then return end

	self.isRuning = true
	self.startTime = CurTime()
end

function mod:Think(amBoat)
	if self.isRuning and CurTime() - self.startTime > self.Duration then
		amBoat:UnmountPowerUp()
	end
end

function mod:OnAttack(amBoat, target, amount)
	if self.isRuning then
		return amount*2
	end
end

AMMods.Register(mod)
