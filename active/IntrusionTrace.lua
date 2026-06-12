local NMWQ = _G.NoMoreWorldQuests

local IntrusionTrace = {}
NMWQ.IntrusionTrace = IntrusionTrace

local PREFIX = "|cff33cc99NMWQ trace|r"
local frame
local playCurrentHooked

local WATCH_EVENTS = {
	"TALKINGHEAD_REQUESTED",
	"TALKINGHEAD_CLOSE",
	"VIGNETTES_UPDATED",
	"VIGNETTE_MINIMAP_UPDATED",
	"SUPER_TRACKING_CHANGED",
	"QUEST_LOG_UPDATE",
	"QUEST_POI_UPDATE",
	"QUEST_DATA_LOAD_RESULT",
	"ZONE_CHANGED",
	"ZONE_CHANGED_NEW_AREA",
	"PLAYER_INSIDE_QUEST_BLOB_STATE_CHANGED",
	"UI_INFO_MESSAGE",
}

local function isEnabled()
	NoMoreWorldQuestsDB = NoMoreWorldQuestsDB or {}
	return NoMoreWorldQuestsDB.debugIntrusion == true
end

local function talkingHeadSnapshot()
	if not C_TalkingHead or not C_TalkingHead.GetCurrentLineInfo then
		return "line=?"
	end
	local displayInfo, _, vo, _, lineNumber, numLines, name, text = C_TalkingHead.GetCurrentLineInfo()
	local bits = {}
	if name and name ~= "" then
		bits[#bits + 1] = "name=" .. tostring(name)
	end
	if lineNumber then
		bits[#bits + 1] = "line=" .. tostring(lineNumber) .. "/" .. tostring(numLines or "?")
	end
	if vo then
		bits[#bits + 1] = "vo=" .. tostring(vo)
	end
	if text and #text > 0 then
		local short = #text > 40 and (strsub(text, 1, 37) .. "...") or text
		bits[#bits + 1] = "text=" .. short
	end
	if displayInfo then
		bits[#bits + 1] = "display=" .. tostring(displayInfo)
	end
	return table.concat(bits, " ")
end

function IntrusionTrace.ContextLine()
	local parts = {}
	parts[#parts + 1] = "suppression=" .. (NMWQ.Controller:IsEnabled() and "ON" or "OFF")
	if NMWQ.ActiveWQZone then
		parts[#parts + 1] = "activeWQZone=" .. (NMWQ.ActiveWQZone:IsInActiveZone() and "yes" or "no")
	end
	if NMWQ.QuestUtil and NMWQ.QuestUtil.HasSuppressedWorldQuestInArea then
		parts[#parts + 1] = "wqInArea=" .. (NMWQ.QuestUtil.HasSuppressedWorldQuestInArea() and "yes" or "no")
	end
	if C_SuperTrack then
		if C_SuperTrack.GetSuperTrackedQuestID then
			parts[#parts + 1] = "superQuest=" .. tostring(C_SuperTrack.GetSuperTrackedQuestID() or 0)
		end
		if C_SuperTrack.GetSuperTrackedVignette then
			parts[#parts + 1] = "superVignette=" .. tostring(C_SuperTrack.GetSuperTrackedVignette() or "nil")
		end
	end
	if TalkingHeadFrame then
		parts[#parts + 1] = "thShown=" .. (TalkingHeadFrame:IsShown() and "yes" or "no")
		parts[#parts + 1] = "thPlaying=" .. tostring(TalkingHeadFrame.isPlaying)
	end
	return table.concat(parts, " | ")
end

function IntrusionTrace.Log(tag, detail)
	if not isEnabled() then
		return
	end
	DEFAULT_CHAT_FRAME:AddMessage(string.format("%s |cffaaaaaa[%s]|r %s", PREFIX, tag, detail or ""))
	DEFAULT_CHAT_FRAME:AddMessage(string.format("%s |cff888888%s|r", PREFIX, IntrusionTrace.ContextLine()))
end

local function formatEventArgs(event, ...)
	local n = select("#", ...)
	if n == 0 then
		return ""
	end
	local chunks = {}
	for i = 1, n do
		chunks[#chunks + 1] = tostring(select(i, ...))
	end
	return " args=" .. table.concat(chunks, ", ")
end

local function onTraceEvent(_, event, ...)
	if not isEnabled() then
		return
	end
	local detail = event .. formatEventArgs(event, ...)
	if event == "TALKINGHEAD_REQUESTED" or event == "TALKINGHEAD_CLOSE" then
		detail = detail .. " | " .. talkingHeadSnapshot()
	end
	if event == "VIGNETTE_MINIMAP_UPDATED" then
		local vignetteGUID, onMinimap = ...
		detail = detail .. " onMinimap=" .. tostring(onMinimap)
		if vignetteGUID and C_VignetteInfo and C_VignetteInfo.GetVignetteInfo then
			local info = C_VignetteInfo.GetVignetteInfo(vignetteGUID)
			if info then
				detail = detail .. " rewardQuest=" .. tostring(info.rewardQuestID) .. " name=" .. tostring(info.name)
			end
		end
	end
	if event == "QUEST_DATA_LOAD_RESULT" then
		local questID, success = ...
		detail = detail .. " loaded=" .. tostring(success)
		if questID and C_QuestLog then
			detail = detail .. " isWQ=" .. tostring(C_QuestLog.IsWorldQuest(questID))
		end
	end
	IntrusionTrace.Log("event", detail)
	if NMWQ.IntrusionSurface and NMWQ.IntrusionSurface.LogBlockDecision then
		NMWQ.IntrusionSurface:LogBlockDecision(event)
	end
end

local function installPlayCurrentTraceHook()
	if playCurrentHooked or not TalkingHeadFrameMixin or not TalkingHeadFrameMixin.PlayCurrent then
		return
	end
	playCurrentHooked = true
	hooksecurefunc(TalkingHeadFrameMixin, "PlayCurrent", function(self)
		if not isEnabled() then
			return
		end
		IntrusionTrace.Log(
			"PlayCurrent",
			"entered voHandle=" .. tostring(self.voHandle) .. " | " .. talkingHeadSnapshot()
		)
	end)
end

function IntrusionTrace.Start()
	if frame then
		return
	end
	frame = CreateFrame("Frame")
	for i = 1, #WATCH_EVENTS do
		frame:RegisterEvent(WATCH_EVENTS[i])
	end
	frame:SetScript("OnEvent", onTraceEvent)
	installPlayCurrentTraceHook()
	IntrusionTrace.Log("trace", "started — walk into a WQ area and watch event order")
end

function IntrusionTrace.Stop()
	if frame then
		frame:UnregisterAllEvents()
		frame:SetScript("OnEvent", nil)
		frame = nil
	end
end

function IntrusionTrace.SetEnabled(enabled)
	NoMoreWorldQuestsDB = NoMoreWorldQuestsDB or {}
	NoMoreWorldQuestsDB.debugIntrusion = enabled
	if enabled then
		IntrusionTrace.Start()
	else
		IntrusionTrace.Stop()
		DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. " stopped")
	end
end

function IntrusionTrace.Init()
	if isEnabled() then
		IntrusionTrace.Start()
	end
end
