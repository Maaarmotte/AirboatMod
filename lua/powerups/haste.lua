local powerup = {} 

powerup.Name     	= "haste"
powerup.FullName 	= "Haste"
powerup.Duration 	= 5
powerup.UseOnTake	= true

powerup.Model      	= "models/pickups/pickup_powerup_haste.mdl"
powerup.ModelScale 	= 1.6
powerup.ModelOffset	= -Vector(0,0,36*powerup.ModelScale)

function powerup:Run()
	PrintTable(self)
	local boat   	= self.Boat
	local amBoat 	= boat.AMBoat
	local physobj	= boat:GetPhysicsObject()
	physobj:SetVelocity(boat:GetVelocity() + boat:GetForward()*1000)
	boat:EmitSound("weapons/bumper_car_speed_boost_start.wav")
	ParticleEffectAttach("smoke_whitebillow", PATTACH_ABSORIGIN_FOLLOW, amBoat:GetSmokeEntity(), 0)
	timer.Simple(1, function()
		amBoat:GetSmokeEntity():StopParticles()
	end)
end

AMPowerUps.Register(powerup)