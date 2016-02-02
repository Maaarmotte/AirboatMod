AMPlayer = {}
AMPlayer_mt = { __index = AMPlayer }

function AMPlayer.New(ply)
	local self = {}
	setmetatable(self, AMPlayer_mt)
	self.Player = ply
	self.AMBoat = nil
	self.Health = 15
	self.Playing = false
	self.Mods = { "boost", "jump", "boost2" }
	ply.AMPlayer = self
	
	return self
end

function AMPlayer:GetEntity()
	return self.Player
end

function AMPlayer:SetAirboat(amBoat)
	self.AMBoat = amBoat
end

function AMPlayer:GetAirboat()
	return self.AMBoat
end

function AMPlayer:CheckKey(key)
	return self.Player:KeyDown(key)
end

function AMPlayer:Respawn()
	self.Player:Spawn()
end

function AMPlayer:SetPlaying(value)
	self.Playing = value
end

function AMPlayer:GetPlaying()
	return self.Playing
end