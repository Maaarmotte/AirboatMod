AMMod = {}
AMMod_mt = { __index = AMMod }

function AMMod.New()
	local self = {}
	setmetatable(self, AMMod_mt)
	self.Name = "none"
	self.LastActivation = 0
	self.Delay = 1
	self.Type = "none"
	return self
end

function AMMod:Activate(amPly, amBoat)
	if CurTime() - self.LastActivation > self.Delay then
		self:Run(amPly, amBoat)
		self.LastActivation = CurTime()	
	end
end

AMMods = {}
AMMods.Mods = {}

function AMMods.Instantiate(name)
	local mod = AMMod.New()
	mod.Name = AMMods.Mods[name].Name
	mod.Delay = AMMods.Mods[name].Delay
	mod.Run = AMMods.Mods[name].Run
	return mod
end

function AMMods.Register(mod)
	AMMods.Mods[mod.Name] = mod
end