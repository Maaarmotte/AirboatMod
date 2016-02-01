AMPowerUp = {}
AMPowerUp_mt = {  __index = function(t, k) return AMPowerUp[k] end }

function AMPowerUp.New(amboat)
	local self = {}
	setmetatable(self, AMPowerUp_mt)
	table.insert(AMPowerUps.Instances, self)
	self.AMBoat	= amboat

	return self
end
//
function AMPowerUp:Take(amBoat)

end

function AMPowerUp:Use(amBoat)

end

function AMPowerUp:Think()

end

function AMPowerUp:Tick()

end

AMPowerUps          	= {}
AMPowerUps.PowerUps 	= {}
AMPowerUps.Instances	= {}

function AMPowerUps.Instantiate(name, amBoad)
	local powerup = AMPowerUp.New()
	PrintTable(AMPowerUps)
	powerup.Name = AMPowerUps.PowerUps[name].Name
	return powerup
end
 
function AMPowerUps.GetRandom()
	local Keys	= table.GetKeys(AMPowerUps.PowerUps)
	local id  	= math.random(1, #AMPowerUps.PowerUps)

	return AMPowerUps.PowerUps[Keys[id]]
end

function AMPowerUps.Register(powerup)
	AMPowerUps.PowerUps[powerup.Name] = powerup
	PrintTable(AMPowerUps)
end


local hooklist = {"Tick", "Think"}

for _,h in pairs(hooklist) do
	for _,pu in pairs(AMPowerUps.Instances) do
		hook.Add(h, "AMPowerUps_"..h, function(...)
			pu[h](...)
		end)
	end
end
