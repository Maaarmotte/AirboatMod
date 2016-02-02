local powerup = {} 

powerup.Name      	= "defense"
powerup.FullName  	= "Defense"
powerup.BaseAmount	= 1
powerup.Duration  	= 15
powerup.ReloadTime	= 0
powerup.UseOnTake 	= true

powerup.Model      	= "models/pickups/pickup_powerup_defense.mdl"
powerup.ModelScale 	= 1.6
powerup.ModelOffset	= -Vector(0,0,36*powerup.ModelScale)

function powerup:Run(amBoat)
	local boat	= amBoat:GetEntity()
	self.oldmat = boat:GetMaterial()
	print(boat, self.oldmat)
	boat:SetMaterial("debug/env_cubemap_model")
end

function powerup:End(amBoat)
	local boat = amBoat:GetEntity()
	boat:SetMaterial(self.oldmat)
end

function powerup:AMBoat_Damage(amBoat, target, amount, attacker)
	if amBoat:GetEntity() == target:GetEntity() then
		return amount/2
	end
end

AMPowerUps.Register(powerup)