AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName     	= "AMHolo"
ENT.Author        	= "Sir Taupe"
ENT.Contact       	= "NO!"
ENT.Purpose       	= ""
ENT.Instructions  	= ""
ENT.Spawnable     	= false
ENT.AdminSpawnable	= true
ENT.RenderGroup   	= RENDERGROUP_TRANSLUCENT


function ENT:SetupDataTables()
	self:NetworkVar("Vector", 0, "HoloScale")

end

if SERVER then
	function ENT:Initialize()
	end

	function ENT:SetScale(scale)
		local scaleVec = isnumber(scale) and Vector(scale, scale, scale) or scale

		print(scaleVec)

		self:SetHoloScale(scaleVec)
	end
else
	function ENT:Initialize()
		self:DrawModel()
	end

	function ENT:OnScaleChange(scale)
		print(scale)
		self.customScale = scale

		local mat = Matrix()
		mat:Scale(scale)

		self:EnableMatrix("RenderMultiply", mat)
	end

	function ENT:Think()
		if not self._oldScale or self._oldScale ~= self:GetHoloScale() then
			self._oldScale = self:GetHoloScale()

			self:OnScaleChange(self._oldScale)
		end
	end



	
	-- net.Receive("AirboatMod.Holo.SetScale", function()
	-- 	local ent = net.ReadEntity()
	-- 	local scale = net.ReadVector()

	-- 	print("wtwqertwert")
	-- 	print(ent)

	-- 	ent:SetScale(scale)
	-- end)
end
