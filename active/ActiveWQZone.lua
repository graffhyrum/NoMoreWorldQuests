local NMWQ = _G.NoMoreWorldQuests

local ActiveWQZone = {}
NMWQ.ActiveWQZone = ActiveWQZone

local eventFrame
local inZone = false
local listeners = {}

function ActiveWQZone.RegisterListener(fn)
	listeners[#listeners + 1] = fn
end

local function notify()
	for i = 1, #listeners do
		listeners[i](inZone)
	end
end

function ActiveWQZone:Evaluate()
	local found = NMWQ.QuestUtil.HasSuppressedWorldQuestInArea()
	if found ~= inZone then
		inZone = found
		notify()
		if inZone and NMWQ.Controller:IsEnabled() then
			NMWQ.Controller:RefreshSurfaces()
		end
	end
	return inZone
end

function ActiveWQZone:IsInActiveZone()
	return inZone
end

local function onEvent()
	ActiveWQZone:Evaluate()
end

function ActiveWQZone:Init()
	if eventFrame then
		return
	end
	eventFrame = CreateFrame("Frame")
	eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	eventFrame:RegisterEvent("ZONE_CHANGED")
	eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	eventFrame:RegisterEvent("QUEST_LOG_UPDATE")
	eventFrame:RegisterEvent("QUEST_ACCEPTED")
	eventFrame:RegisterEvent("QUEST_POI_UPDATE")
	eventFrame:SetScript("OnEvent", onEvent)
	C_Timer.After(1, onEvent)
end
