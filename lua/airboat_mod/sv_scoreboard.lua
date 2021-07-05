util.AddNetworkString("AirboatMod.Scoreboard.Update")

AMScoreBoard = AMScoreBoard or {}

function AMScoreBoard.SendScoreboardUpdate(ply)		
	net.Start("AirboatMod.Scoreboard.Update")
		local data = AMDatabase.Player.FindLeaderboard()
		
		local leaderboard = {}
		for i, p in ipairs(data) do
			table.insert(leaderboard, {name=p.name, score=p.kills})	
		end
		net.WriteTable(leaderboard)
		
		net.WriteTable({
			{name="Marmotte", score=14},
			{name="Un jour je serai le meilleur dresseur !", score=10},
            {name="Still under development :(", score=1}
		})
	if ply and ply:IsValid() then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

hook.Add("PlayerInitialSpawn", "AirboatMod.Scoreboard.PlayerInitialSpawn", function(ply)
	AMScoreBoard.SendScoreboardUpdate(ply)
end)
