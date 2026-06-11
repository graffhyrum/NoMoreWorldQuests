local addonName = ...
local NMWQ = _G.NoMoreWorldQuests
if not NMWQ or not NMWQ.Controller or not NMWQ.MinimapSurface then
	return
end

NMWQ.Controller.RegisterSurface(NMWQ.MinimapSurface)
NMWQ.Controller.RegisterSurface(NMWQ.WorldMapSurface)
NMWQ.Controller.RegisterSurface(NMWQ.ObjectiveTrackerSurface)
NMWQ.Controller.RegisterSurface(NMWQ.IntrusionSurface)

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, event, name)
	if event ~= "ADDON_LOADED" or name ~= addonName then
		return
	end
	NMWQ.Controller:ApplyFromSaved()
	NMWQ.MinimapButton:Init()
	NMWQ.Slash:Init()
	NMWQ.ActiveWQZone:Init()
	NMWQ.MinimapAlert:Init()
	if NMWQ.IntrusionTrace then
		NMWQ.IntrusionTrace.Init()
	end
end)
