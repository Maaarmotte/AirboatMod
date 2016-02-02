local powerup = {} 

powerup.Name      	= "strength"
powerup.FullName  	= "Strength"
powerup.BaseAmount	= 1
powerup.Duration  	= 15
powerup.ReloadTime	= 0
powerup.UseOnTake 	= true

powerup.Model      	= "models/pickups/pickup_powerup_strength.mdl"
powerup.ModelScale 	= 1.6
powerup.ModelOffset	= -Vector(0,0,36*powerup.ModelScale)

function powerup:AMBoat_Damage(amBoat, target, amount, attacker)
	if attacker then 
		if amBoat:GetEntity() == attacker:GetEntity() then
			return amount*2
		end
	end
end

AMPowerUps.Register(powerup)