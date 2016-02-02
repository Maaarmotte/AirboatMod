AMPlayer = {}
AMPlayer_mt = { __index = AMPlayer }

-- Constructor
function AMPlayer.New(ply)
	local self = {}
	setmetatable(self, AMPlayer_mt)

	self.Entity = ply
	self.AMBoat = nil
	
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
