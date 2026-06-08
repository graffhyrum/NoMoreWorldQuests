local NMWQ = _G.NoMoreWorldQuests

local MapFilterSync = {}
NMWQ.MapFilterSync = MapFilterSync

local CVAR = "questPOIWQ"

function MapFilterSync.ApplyForSuppression(suppressionOn)
	local want = suppressionOn and "0" or "1"
	local current = GetCVar(CVAR)
	if current == want then
		return
	end
	pcall(SetCVar, CVAR, want)
end
