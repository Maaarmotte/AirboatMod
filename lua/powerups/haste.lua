local powerup = {} 

powerup.Name    	= "haste"
powerup.FullName	= "Haste"
powerup.duration	= 5

powerup.Model      	= "models/pickups/pickup_powerup_haste.mdl"
powerup.ModelScale 	= 1.6
powerup.ModelOffset	= -Vector(0,0,36*powerup.ModelScale)



AMPowerUps.Register(powerup)