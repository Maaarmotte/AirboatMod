AMMod = {}
AMMod_mt = { __index = function(tab, key) return AMMod[key] end}

function AMMod.New()
	local self = {}
	setmetatable(self, AMMod_mt)
	self.Name = "none"
	self.LastActivation = 0
	self.Delay = 1
	self.Type = "none"
	self.Mounted = false
	self.Data = nil
	self.Props = {}
	self.ClientInfo = {}
	return self
end

function AMMod:Activate(amPly, amBoat)
	if CurTime() - self.LastActivation > self.Delay then
		self:Run(amPly, amBoat)
		self.LastActivation = CurTime()
	end
end

function AMMod:MountHolo(amBoat, model, pos, ang, scale, material, color)
	if SERVER then
		local ent = amBoat:ParentHolo(model, pos, ang, scale, material, color)
		table.insert(self.Props, ent)
		return ent
	else
		local ent = AMMenu.MountHolo(amBoat, model, pos, ang, scale, material, color)
		return ent
	end
end

function AMMod:SendInfoToClent(amBoat, info)
	self.ClientInfo = istable(info) and info or {}

	amBoat:Synchronize()
end

-- Will be overrided !
function AMMod:Mount()
end

-- Will be overrided !
function AMMod:Unmount()
end

-- Will be overrided !
function AMMod:Run()
end

-- Will be overrided !
function AMMod:Think()
end

function AMMods.Instantiate(name)
	local mod = AMMod.New()

	for k,v in pairs(AMMods.Mods[name]) do
		mod[k] = v
	end

	mod.Mount = function(self, amBoat)
		if not self.Mounted then
			self.Mounted = true
			return AMMods.Mods[name].Mount(self, amBoat)
		end
	end

	mod.Unmount = function(self, amBoat)
		if self.Mounted then
			self.Mounted = false

			-- Remove props/holograms assocaited to the mod
			for _,prop in pairs(self.Props) do
				if IsValid(prop) then
					prop:Remove()
				end
			end

			local func = AMMods.Mods[name].Unmount or mod.Unmount
			return func(self, amBoat)
		end
	end

	return mod
end

function AMMods.Register(mod)
	AMMods.Mods[mod.Name] = mod
end


-- PowerUp

function AMMods.GetRandomPowerUp()
	local keys	= {}

	for id, mod in pairs(AMMods.Mods) do
		if mod.Type == "powerup" then
			table.insert(keys, id)
		end
	end

	local id = math.random(1, #keys)

	return AMMods.Mods[keys[id]]
end
