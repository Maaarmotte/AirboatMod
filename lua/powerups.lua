AMPowerUp = {}
AMPowerUp_mt = {  __index = function(t, k) return AMPowerUps.PowerUps[t.Name][k] or AMPowerUp[k] end }

function AMPowerUp.New()
	local self = {}
	setmetatable(self, AMPowerUp_mt)
	table.insert(AMPowerUps.Instances, self)


	return self
end

function AMPowerUp:Take()
	print('asd')
end

function AMPowerUp:Use()
	local boat = self.Boat
	self:Run()
	self = nil
end

function AMPowerUp:Think()

end

function AMPowerUp:Tick()

end


///////////////////
///////////////////

function AMPowerUps.Instantiate(name, boat)
	local amBoat = boat.AMBoat
	if amBoat then
		local powerup 	= AMPowerUp.New()
		powerup.Boat  	= boat
		powerup.AMBoat	= amBoad
		powerup.Name  	= AMPowerUps.PowerUps[name].Name

		powerup:Take()
		if powerup.UseOnTake then
			powerup:Use()
		end

		return powerup
	end
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
