local powerup = {} 

powerup.Name      	= "haste"
powerup.FullName  	= "Haste"
powerup.BaseAmount	= 3
powerup.Duration  	= 0.1
powerup.ReloadTime	= 2
powerup.UseOnTake 	= false

powerup.Model      	= "models/pickups/pickup_powerup_haste.mdl"
powerup.ModelScale 	= 1.6
powerup.ModelOffset	= -Vector(0,0,36*powerup.ModelScale)

function powerup:Run(amBoat)
	local boat   	= amBoat:GetEntity()
	local physobj	= boat:GetPhysicsObject()
	
	physobj:SetVelocity(boat:GetVelocity() + boat:GetForward()*1000)
	boat:EmitSound("weapons/bumper_car_speed_boost_start.wav")
end

AMPowerUps.Register(powerup)