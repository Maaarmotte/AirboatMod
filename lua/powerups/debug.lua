local powerup = {}

-- Le nom du powerup
powerup.Name = "debug"
-- Le nom complet du powerup
powerup.FullName	= "Debug"

-- Le nombre de fois que le powerup pourra etre utilisé
powerup.BaseAmount	= 1
-- Le temps en seconde que le powerup va durer après son activation
powerup.Duration	= 1
-- Le temps de recharge après l'activation
powerup.ReloadTime	= 2
-- Si true, utilise le powerup quand il se fait prendre
powerup.UseOnTake	= false

-- Le model a l'interieur de la boite
powerup.Model	= "models/class_menu/random_class_icon.mdl"
-- Son scale
powerup.ModelScale	= 2
-- La posission par raport au centre de la boite
powerup.ModelOffset	= Vector(0,0,-5)

-- Est appelé lorsque le powerup se fait prendre
function powerup:Take(amBoat)
	local ply = amBoat:GetPlayer():GetEntity()
	ply:ChatPrint(table.ToString(self, "PowerUp", true ))
	ply:ChatPrint("[Debug] PowerUp - Take")

	self.tick	= 0
end

-- Est appelé lorsque le powerup se fait activer
function powerup:Run(amBoat)
	local ply = amBoat:GetPlayer():GetEntity()

	ply:ChatPrint("[Debug] PowerUp - Run")
end 

-- Est appelé à la fin de la durée du powerup
function powerup:End(amBoat)
	local ply = amBoat:GetPlayer():GetEntity()
	ply:ChatPrint("[Debug] PowerUp - Tick: " .. self.tick)
	ply:ChatPrint("[Debug] PowerUp - End")
end

-- Est appelé a tout les ticks le temps que le powerup est activé
function powerup:Tick(amBoat)
	self.tick = self.tick + 1
end
-- (N'importe quel hook peut etre vu, ex: powerup:PlayerSay(ply, text, team) )


AMPowerUps.Register(powerup)