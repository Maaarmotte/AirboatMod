AMBoat = {}
AMBoat_mt = { __index = AMBoat }

-- Constructor
function AMBoat.New()
	local self      	= {}
	self.Entity     	= nil
	self.Health     	= 15
	self.Playing 		= false
	self.AMPlayer 		= nil
	setmetatable(self, AMBoat_mt)

	return self
end

-- Static methods
function AMBoat.GetBoat(boat)
	if boat and boat:IsValid() then
		if not boat.AMBoat then
			boat.AMBoat = AMBoat.New()
		end
		return boat.AMBoat
	end
end

-- Getters
function AMBoat:GetPlayer(amPly)
	return self.AMPlayer
end

function AMBoat:GetHealth(value)
	return self.Health
end

function AMBoat:IsPlaying()
	return self.Playing
end

function AMBoat:GetEntity()
	return self.Entity
end

-- Setters
function AMBoat:SetPlayer(amPly)
	self.AMPlayer = amPly
end

function AMBoat:SetHealth(value)
	self.Health = value
end

function AMBoat:SetPlaying(bool)
	self.Playing = bool
end

-- Hooks
net.Receive("am_boat_update", function(len)
	local data = net.ReadTable()
	local amBoat = AMBoat.GetBoat(data.Entity)
	local amPlayer = AMPlayer.GetPlayer(data.Player)

	if amBoat and amPlayer then
		amBoat:SetPlayer(amPlayer)
		amBoat:SetHealth(data.Health)
		amBoat:SetPlaying(data.Playing)

		amPlayer:SetAirboat(amBoat)
	end
end)
