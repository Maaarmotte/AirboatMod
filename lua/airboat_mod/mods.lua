AMMod = {}
AMMod_mt = { __index = function(tab, key) return AMMods.Mods[tab.Name][key] or AMMod[key] end}

function AMMods.Instantiate(name, amBoat)
	return AMMod.New(name, amBoat)
end


function AMMods.Register(mod)
	AMMods.Mods[mod.Name] = mod
end


function AMMod.New(name, amBoat)
	local self = {}
	setmetatable(self, AMMod_mt)
	self.Name = name
	self.Mounted = false
	self.Data = nil
	self.Props = {}
	self.ClientInfo = {}
	self.AMBoat = amBoat
	self.LastActivation = 0
	self.Amount = self.BaseAmount or 0

	return self
end

function AMMod:Activate()
	if not self.Delay or CurTime() - self.LastActivation > self.Delay then
		self:Run()
		self.LastActivation = CurTime()
	end
end

function AMMod:MountHolo(model, pos, ang, scale, material, color)
	if SERVER then
		local ent = self.AMBoat:ParentHolo(model, pos, ang, scale, material, color)
		table.insert(self.Props, ent)

		return ent
	else
		local ent = AMMenu.SubMenus["mods"].MountHolo(model, pos, ang, scale, material, color)
		return ent
	end
end

function AMMod:SendInfoToClent(info)
	self.ClientInfo = info

	self.AMBoat:Synchronize()
end

-- Will be overrided !
function AMMod:Initialize()
end

-- Will be overrided !
function AMMod:OnMount()
end

-- Will be overrided !
function AMMod:OnUnmount()
end

-- Will be overrided !
function AMMod:Run()
end

-- Will be overrided !
function AMMod:Think()
end

function AMMod:Mount()
	if not self.Mounted then
		self.Mounted = true

		self:Initialize()
		self:OnMount()
	end
end

function AMMod:Unmount()
	if self.Mounted then
		self.Mounted = false

		-- Remove props/holograms assocaited to the mod
		for _,prop in pairs(self.Props) do
			if IsValid(prop) then
				prop:Remove()
			end
		end

		self:OnUnmount()
	end
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
