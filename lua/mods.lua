AMMod = {}
AMMod_mt = { __index = AMMod }

AMMods = {}
AMMods.Mods = {}

local AMMods = AMMods

function AMMod.New()
	local self = {}
	setmetatable(self, AMMod_mt)
	self.Name = "none"
	self.LastActivation = 0
	self.Delay = 1
	self.Type = "none"
	self.Mounted = false
	self.Data = nil
	return self
end

function AMMod:Activate(amPly, amBoat)
	if CurTime() - self.LastActivation > self.Delay then
		self:Run(amPly, amBoat)
		self.LastActivation = CurTime()	
	end
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
			return AMMods.Mods[name].Unmount(self, amBoat)
		end
	end

	return mod
end

function AMMods.Register(mod)
	AMMods.Mods[mod.Name] = mod
end