local powerup = {}

powerup.Name     	= "debug"
powerup.FullName 	= "Debug"
powerup.PAmount  	= 1
powerup.Duration 	= 2
powerup.UseOnTake	= false

powerup.Model      	= "models/class_menu/random_class_icon.mdl"
powerup.ModelScale 	= 2
powerup.ModelOffset	= Vector(0,0,-5)


function AMPowerUp:Run(amBoat)
	print(amBoat:GetPlayer():GetEntity():Name(), "Run")
end 

function AMPowerUp:End(amBoat)
	print(amBoat:GetPlayer():GetEntity():Name(), "End")
end

function AMPowerUp:Take(amBoat)
	print(amBoat:GetPlayer():GetEntity():Name(), "Take")
end

AMPowerUps.Register(powerup)