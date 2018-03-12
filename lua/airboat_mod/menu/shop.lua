local MENU = {}

MENU.Name = "shop"
MENU.Title = "Shop"
MENU.Position = 2

if SERVER then

else
	function MENU:Build(pnl)
		function pnl:Paint(w, h)
			surface.SetDrawColor(Color(38, 45, 59, 255))
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(Color(255, 255, 255, 255))
			surface.DrawRect(5, 0, w - 10, h)
		end
	end
end

AMMenu.Register(MENU)
