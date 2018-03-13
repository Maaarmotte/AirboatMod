AMPlayer = {}
AMPlayer_mt = {__index = function(tab, key) return AMPlayer[key] end}

-- Constructor
function AMPlayer.New(ply)
	local self = {}
	setmetatable(self, AMPlayer_mt)

	self.Entity = ply
	self.AMBoat = nil
	self.Playing = false

	return self
end

-- Static methods
function AMPlayer.GetPlayer(ply)
	if ply and ply:IsValid() then
		if not ply.AMPlayer then
			ply.AMPlayer = AMPlayer.New(ply)
		end
		return ply.AMPlayer
	end
end

-- Getters
function AMPlayer:GetAirboat()
	return self.AMBoat
end

function AMPlayer:GetEntity()
	return self.Entity
end

-- Setters
function AMPlayer:SetAirboat(amBoat)
	self.AMBoat = amBoat
end

function AMPlayer:GetPlaying()
	return self.Playing
end

function AMPlayer:SetPlaying(value)
	self.Playing = value
end

