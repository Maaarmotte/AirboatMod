AMPowerUp = {}
AMPowerUp_mt = {  __index = function(t, k) return AMPowerUps.PowerUps[t.Name][k] or AMPowerUp[k] end }

function AMPowerUp.New()
	local self = {}
	setmetatable(self, AMPowerUp_mt)
	self.InRun  	= false
	self.Amount 	= 0
	self.LastUse	= 0

	return self
end

function AMPowerUp:Take(amBoat)
end

function AMPowerUp:Run(amBoat)
end 

function AMPowerUp:End(amBoat)
end

function AMPowerUp:Stop(amBoat)
	AMPowerUps.Stop(self, amBoat)
end

///////////////////
///////////////////

function AMPowerUps.Instantiate(name)
	local powerup 	= AMPowerUp.New()
	powerup.Name  	= AMPowerUps.PowerUps[name].Name
	powerup.Amount	= AMPowerUps.PowerUps[name].BaseAmount

	return powerup
end

function AMPowerUps.Initalite(amPowerup, amBoat)
	amPowerup:Take(amBoat)

	if amPowerup.UseOnTake then
		AMPowerUps.Use(amPowerup, amBoat)
	end
end

function AMPowerUps.Stop(amPowerup, amBoat)
	amPowerup.Amount = amPowerup.Amount - 1
	amPowerup.InRun = false
	amPowerup:End(amBoat)

	if amPowerup.Amount <= 0 then
		amBoat:UnsetPowerUp()
	end
end

function AMPowerUps.Use(amPowerup, amBoat)
	if not amPowerup.InRun then
		if CurTime() - amPowerup.LastUse > amPowerup.ReloadTime then
			local boat       	= amBoat:GetEntity()
			amPowerup.LastUse	= CurTime()
			amPowerup.InRun  	= true
			amPowerup:Run(amBoat)

			if amPowerup.Duration > 0 then
				timer.Create("AMPowerUp_Countdown_"..amBoat:GetEntity():EntIndex(), amPowerup.Duration, 1, function()
					AMPowerUps.Stop(amPowerup, amBoat)
				end)
			end
		end
	end
end
 
function AMPowerUps.GetRandom()
	local Keys	= table.GetKeys(AMPowerUps.PowerUps)
	local id  	= math.random(1, #Keys)

	return AMPowerUps.PowerUps[Keys[id]]
end

function AMPowerUps.Register(powerup)
	AMPowerUps.PowerUps[powerup.Name] = powerup
end

