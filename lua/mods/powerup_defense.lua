local mod = {}

mod.Name      	= "powerup.defense"
mod.FullName  	= "Defense"
mod.Type 		= "powerup"
mod.BaseAmount	= 1
mod.Duration  	= 5
mod.ReloadTime	= 0

mod.Model      	= "models/pickups/pickup_powerup_defense.mdl"
mod.ModelScale 	= 1.6
mod.ModelOffset	= -Vector(0,0,36*mod.ModelScale)

function mod:Mount(amBoat)
end

function mod:Unmount(amBoat)
	local boat = amBoat:GetEntity()
	boat:SetMaterial(self.oldmat)
end

function mod:Run(amPly, amBoat)
	if self.isRuning then return end

	local boat	= amBoat:GetEntity()
	self.oldmat = boat:GetMaterial()
	self.isRuning = true
	self.startTime = CurTime()

	boat:SetMaterial("debug/env_cubemap_model")
end

function mod:OnDamage(amBoat, attacker, amount)
	if self.isRuning then
		return amount/2
	end
end

function mod:Think(amBoat)
	if self.isRuning and CurTime() - self.startTime > self.Duration then
		amBoat:UnmountPowerUp()
	end
end

AMMods.Register(mod)
