AMPowerUp = {}
AMPowerUp_mt = {  __index = function(t, k) return AMPowerUps.PowerUps[t.Name][k] or AMPowerUp[k] end }

function AMPowerUp.New()
	local self = {}
	setmetatable(self, AMPowerUp_mt)
	self.InRun = false
	self.Amount = 0

	return self
end

function AMPowerUp:Run(amBoat)
end 

function AMPowerUp:End(amBoat)
end

function AMPowerUp:Take(amBoat)
end

function AMPowerUp:Think()
end

function AMPowerUp:Tick()
end

///////////////////
///////////////////
function AMPowerUps.Instantiate(name)
	local powerup 	= AMPowerUp.New()
	powerup.Name  	= AMPowerUps.PowerUps[name].Name
	powerup.Amount	= AMPowerUps.PowerUps[name].PAmount

	return powerup
end

function AMPowerUps.Use(amPowerup, amBoat)
	if not amPowerup.InRun then
		local boat = amBoat:GetEntity()
		amPowerup.InRun = true
		amPowerup:Run(amBoat)

		timer.Create("AMPowerUp_Countdown_"..amBoat:GetEntity():EntIndex(), amPowerup.Duration, 1, function()
			amPowerup.Amount = amPowerup.Amount - 1
			amPowerup.InRun = false
			amPowerup:End(amBoat)

			if amPowerup.Amount <= 0 then
				amBoat:UnsetPowerUp()
			end
		end)
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


local hooklist = {"Tick", "Think"}

for _,h in pairs(hooklist) do
	hook.Add(h, "AMPowerUps_"..h, function(...)
		for _,ply in ipairs(player.GetAll()) do
			if ply.AMPlayer then
				local boat = ply.AMPlayer:GetAirboat()
				if boat then
					local powerup = boat:GetPowerUp()
					if powerup then
						if powerup.InRun then
							powerup[h](boat, ...)
						end
					end
				end
			end
		end
	end)
end
