AMBoat = {}
AMBoat_mt = { __index = AMBoat }

AMBoat.Cache = {}

-- Constructor
function AMBoat.New()
	local self = {}

	self.EntityId 	= nil
	self.Entity		= nil
	self.Health		= 15
	self.Playing	= false
	self.AMPlayer	= nil
	self.AMPowerUp	= { FullName="None" }
	self.Mods 		= {}

	setmetatable(self, AMBoat_mt)

	return self
end

-- Static methods
function AMBoat.GetBoat(boat)
	if IsValid(boat) then
		return AMBoat.GetBoatByIndex(boat:EntIndex())
	end
end

function AMBoat.GetBoatByIndex(boatId)
	local boat = ents.GetByIndex(boatId)
	if not AMBoat.Cache[boatId] then
		amBoat = AMBoat.New()
		amBoat:SetEntityId(boatId)
		amBoat:SetEntity(boat)
		AMBoat.Cache[boatId] = amBoat
	end
	return AMBoat.Cache[boatId]
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
	if not self.Entity then
		self.Entity = ents.GetByIndex(self.EntityId)
    
    if IsValid(self.Entity) then
      self.Entity.AMBoat = self
    end
	end

	return self.Entity
end

function AMBoat:GetEntityId()
	return self.EntityId
end

function AMBoat:GetPowerUp()
	return self.AMPowerUp
end

function AMBoat:GetMods()
	return self.Mods
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

function AMBoat:SetEntity(entity)
	self.Entity = entity
end

function AMBoat:SetEntityId(entityId)
	self.EntityId = entityId
end

function AMBoat:SetPowerUp(name)
	self.AMPowerUp.FullName = name
end

function AMBoat:SetMods(mods)
	self.Mods = mods
end

-- Hooks
net.Receive("am_boat_update", function(len)
	local data = net.ReadTable()
	local amBoat = AMBoat.GetBoatByIndex(data.EntityId)
	local amPlayer = AMPlayer.GetPlayer(data.Player)

	if amBoat and amPlayer then
		amBoat:SetPlayer(amPlayer)
		amBoat:SetHealth(data.Health)
		amBoat:SetPlaying(data.Playing)
		amBoat:SetPowerUp(data.PowerUp)
		amBoat:SetMods(data.Mods)

		amPlayer:SetAirboat(amBoat)
	end

	if amPlayer then
		amPlayer:SetPlaying(data.Playing)

		if amPlayer:GetEntity() == LocalPlayer() then
			if amPlayer:GetPlaying() then
				AMHud.Build()
			else
				AMHud.Remove()
			end
		end
	end
end)
