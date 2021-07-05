-- Helper methods
local function computeTextSize(font, text)
	surface.SetFont(font)
	return surface.GetTextSize(text)
end

local function clampString(text, size)
	local result = string.Left(text, size)
	
	if string.len(result) ~= string.len(text) then
		result = result .. "..."
	end
	
	return result
end

-- Create and load resources
surface.CreateFont("AMFontTitle", {size = 64})
surface.CreateFont("AMFontEntry", {size = 48})

local textColor = Color(200, 200, 200, 255)
local goldColor = Color(255, 215, 0, 255)
local silverColor = Color(192, 192, 192, 255)
local bronzeColor = Color(205, 127, 50, 255)

local center = Vector(13271, -3071, -7576)
local size = Vector(1600, 1000, 0)
local margin = 20
local spacing = 25

local textLeaderboard = "-= LEADERBOARD =-"
local textLeaderboardSize = computeTextSize("AMFontTitle", textLeaderboard)
local tabSize = computeTextSize("AMFontEntry", "        ")

-- Logic
local leaderboardTexts = {}		-- {text:string, size:int}
local scoreboardNames = {}		-- {text:string, size:int}
local scoreboardPoints = {}		-- {text:string, size:int}
local maxScoresSize = 0
local maxNamesSize = 0

net.Receive("AirboatMod.Scoreboard.Update", function(len)
	local leaderboard = net.ReadTable() or {}		-- {name:string, score:float}
	local scoreboard = net.ReadTable() or {}		-- {name:string, score:float}
	
	-- Sanitize names and compute text size
	leaderboardTexts = {}
	for i, s in ipairs(leaderboard) do
		local text = clampString(s.name, 20) .. " - " .. s.score .. " pts"
		local size = computeTextSize("AMFontEntry", text)
		
		table.insert(leaderboardTexts, {text=text, size=size})
	end
	
	scoreboardNames = {}
	scoreboardPoints = {}
	maxScoresSize = 0
	maxNamesSize = 0
	for i, s in ipairs(scoreboard) do
		local name = clampString(s.name, 40)
		local nameSize = computeTextSize("AMFontEntry", name)
		local score = s.score .. " pts"
		local scoreSize = computeTextSize("AMFontEntry", score)
		
		if nameSize > maxNamesSize then
			maxNamesSize = nameSize
		end
		
		if scoreSize > maxScoresSize then
			maxScoresSize = scoreSize
		end
		
		table.insert(scoreboardNames, {text=name, size=size})
		table.insert(scoreboardPoints, {text=score, size=scoreSize})
	end		
end)

hook.Add("PostDrawTranslucentRenderables", "AirboatMod.Scoreboard.DrawScoreboard", function()
	render.SetColorMaterial()

	cam.Start3D2D(center + Vector(0, size.x, size.y)/2, Angle(0, -90, 90), 1)
		-- Draw background
		draw.RoundedBox(0, 0, 0, size.x, size.y, Color(0, 0, 0, 240))
		
		-- Draw leaderboard
		draw.DrawText("-= LEADERBOARD =-", "AMFontTitle", size.x/2 - textLeaderboardSize/2, spacing*3, textColor)

		if leaderboardTexts[1] then draw.DrawText(leaderboardTexts[1].text, "AMFontEntry", size.x/2 - leaderboardTexts[1].size/2, spacing*7, goldColor) end
		if leaderboardTexts[2] then draw.DrawText(leaderboardTexts[2].text, "AMFontEntry", size.x/4 - leaderboardTexts[2].size/2, spacing*9, silverColor) end
		if leaderboardTexts[3] then draw.DrawText(leaderboardTexts[3].text, "AMFontEntry", size.x*3/4 - leaderboardTexts[3].size/2, spacing*9, bronzeColor) end
		
		-- Draw scoreboard			
		local maxSize = maxNamesSize + maxScoresSize + tabSize
		
		draw.DrawText("-= SCOREBOARD =-", "AMFontTitle", size.x/2 - textLeaderboardSize/2, spacing*13, textColor)
		for i, p in ipairs(scoreboardNames) do
			draw.DrawText(p.text, "AMFontEntry", size.x/2 - maxSize/2, spacing*(15 + i*2), textColor)
		end
		
		for i, s in ipairs(scoreboardPoints) do
			draw.DrawText(s.text, "AMFontEntry", size.x/2 + maxSize/2 - s.size, spacing*(15 + i*2), textColor)
		end
	cam.End3D2D()
end)
