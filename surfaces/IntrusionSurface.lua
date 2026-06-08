local NMWQ = _G.NoMoreWorldQuests

local IntrusionSurface = {}
NMWQ.IntrusionSurface = IntrusionSurface

local talkingHeadOnEventHooked = false
local talkingHeadPlayCurrentHooked = false
local eventToastHookInstalled = false
local uiErrorsHookInstalled = false
local vignetteHooksInstalled = false
local eventFrame
local hookAttemptFrame

local VIGNETTE_PIN_TEMPLATES = {
	"VignettePinTemplate",
	"VignettePinPOIButtonTemplate",
	"FyrakkFlightVignettePinTemplate",
}

local function vignetteQuestID(vignetteInfo)
	if not vignetteInfo then
		return nil
	end
	local questID = vignetteInfo.rewardQuestID
	if questID and questID > 0 then
		return questID
	end
	return nil
end

local function shouldSuppressVignetteInfo(vignetteInfo)
	local questID = vignetteQuestID(vignetteInfo)
	return questID and NMWQ.VisibilityRule.ShouldSuppress(questID)
end

local function hideVignettePin(pin)
	if not pin then
		return
	end
	if pin.Hide then
		pin:Hide()
	end
	if pin.SetAlpha then
		pin:SetAlpha(0)
	end
	if pin.SetShown then
		pin:SetShown(false)
	end
end

local function hideWQVignettePins()
	NMWQ.MapCanvas.ForEachPinByTemplates(VIGNETTE_PIN_TEMPLATES, function(pin)
		local questID = pin.GetRewardQuestID and pin:GetRewardQuestID()
			or vignetteQuestID(pin.vignetteInfo)
		if questID and NMWQ.VisibilityRule.ShouldSuppress(questID) then
			hideVignettePin(pin)
		end
	end)
end

local function restoreVignettePins()
	NMWQ.MapCanvas.ForEachPinByTemplates(VIGNETTE_PIN_TEMPLATES, function(pin)
		if pin.Show then
			pin:Show()
		end
		if pin.SetAlpha then
			pin:SetAlpha(1)
		end
		if pin.SetShown then
			pin:SetShown(true)
		end
	end)
end

local function scheduleVignetteHide()
	if not NMWQ.Controller:IsEnabled() then
		return
	end
	NMWQ.Debounce.After("intrusion-vignettes", hideWQVignettePins)
end

local function suppressMinimapVignette(vignetteGUID)
	if not vignetteGUID or not C_VignetteInfo.GetVignetteInfo then
		return
	end
	local info = C_VignetteInfo.GetVignetteInfo(vignetteGUID)
	if not info or not shouldSuppressVignetteInfo(info) then
		return
	end
	if C_SuperTrack and C_SuperTrack.GetSuperTrackedVignette then
		if C_SuperTrack.GetSuperTrackedVignette() == vignetteGUID then
			C_SuperTrack.SetSuperTrackedVignette(0)
		end
	end
	if info.vignetteID and C_VignetteInfo.SetVignetteVisible then
		pcall(C_VignetteInfo.SetVignetteVisible, info.vignetteID, false)
	end
	if info.objectGUID and C_VignetteInfo.HideVignette then
		pcall(C_VignetteInfo.HideVignette, info.objectGUID)
	end
end

local function suppressAllMinimapVignettes()
	if not C_VignetteInfo.GetVignettes then
		return
	end
	for _, vignetteGUID in ipairs(C_VignetteInfo.GetVignettes()) do
		local info = C_VignetteInfo.GetVignetteInfo(vignetteGUID)
		if info and info.onMinimap then
			suppressMinimapVignette(vignetteGUID)
		end
	end
end

local function installVignetteProviderHook()
	if not VignetteDataProviderMixin or VignetteDataProviderMixin._NMWQShouldShowHooked then
		return
	end
	local original = VignetteDataProviderMixin.ShouldShowVignette
	VignetteDataProviderMixin._NMWQShouldShowHooked = true
	function VignetteDataProviderMixin:ShouldShowVignette(vignetteInfo)
		if NMWQ.Controller:IsEnabled() and shouldSuppressVignetteInfo(vignetteInfo) then
			return false
		end
		return original(self, vignetteInfo)
	end
end

local function installVignetteHooks()
	if vignetteHooksInstalled then
		return true
	end
	if not VignettePinBaseMixin then
		return false
	end
	vignetteHooksInstalled = true
	installVignetteProviderHook()

	hooksecurefunc(VignettePinBaseMixin, "OnAcquired", function(pin, _, vignetteInfo)
		if not NMWQ.Controller:IsEnabled() or not shouldSuppressVignetteInfo(vignetteInfo) then
			return
		end
		hideVignettePin(pin)
	end)

	hooksecurefunc(VignettePinBaseMixin, "UpdatePosition", function(pin)
		if NMWQ.Controller:IsEnabled() and pin.vignetteInfo and shouldSuppressVignetteInfo(pin.vignetteInfo) then
			hideVignettePin(pin)
		end
	end)

	if VignetteDataProviderMixin then
		hooksecurefunc(VignetteDataProviderMixin, "RefreshAllData", function()
			scheduleVignetteHide()
		end)
	end

	return true
end

local function ensureVignetteHooks()
	if installVignetteHooks() then
		return
	end
	pcall(LoadAddOn, "Blizzard_WorldMap")
	pcall(LoadAddOn, "Blizzard_SharedMapDataProviders")
	if installVignetteHooks() then
		return
	end
	if not hookAttemptFrame then
		hookAttemptFrame = CreateFrame("Frame")
		hookAttemptFrame:RegisterEvent("ADDON_LOADED")
		hookAttemptFrame:SetScript("OnEvent", function(_, _, addonName)
			if addonName == "Blizzard_WorldMap" or addonName == "Blizzard_SharedMapDataProviders" then
				if installVignetteHooks() then
					hookAttemptFrame:UnregisterAllEvents()
					if NMWQ.Controller:IsEnabled() then
						hideWQVignettePins()
						suppressAllMinimapVignettes()
					end
				end
			end
		end)
	end
end

local function refreshActiveWQZoneState()
	if NMWQ.ActiveWQZone and NMWQ.ActiveWQZone.Evaluate then
		NMWQ.ActiveWQZone:Evaluate()
	end
end

local function shouldBlockTalkingHead()
	if not NMWQ.Controller:IsEnabled() then
		return false
	end
	if NMWQ.ActiveWQZone and NMWQ.ActiveWQZone:IsInActiveZone() then
		return true
	end
	if NMWQ.QuestUtil.HasSuppressedWorldQuestInArea() then
		return true
	end
	if NMWQ.QuestUtil.HasSuppressedWorldQuestInTaskTable() then
		return true
	end
	if NMWQ.QuestUtil.HasSuppressedWorldQuestOnMap() then
		return true
	end
	if C_SuperTrack and C_SuperTrack.GetSuperTrackedQuestID then
		local questID = C_SuperTrack.GetSuperTrackedQuestID()
		if questID and questID > 0 and NMWQ.VisibilityRule.ShouldSuppress(questID) then
			return true
		end
	end
	return false
end

local function logTalkingHeadBlock(phase, detail)
	if NMWQ.IntrusionTrace and NMWQ.IntrusionTrace.Log then
		local verdict = shouldBlockTalkingHead() and "BLOCK" or "allow"
		NMWQ.IntrusionTrace.Log(phase, (detail or "") .. " => " .. verdict)
	end
end

local function blockTalkingHeadFrame(frame)
	if C_TalkingHead and C_TalkingHead.IgnoreCurrentTalkingHead then
		C_TalkingHead.IgnoreCurrentTalkingHead()
	end
	if not frame then
		return
	end
	if frame.CloseImmediately then
		frame:CloseImmediately()
		return
	end
	if frame.voHandle then
		StopSound(frame.voHandle)
		frame.voHandle = nil
	end
	frame.isPlaying = false
	if frame.UpdateShownState then
		frame:UpdateShownState()
	else
		frame:Hide()
	end
end

local function onTalkingHeadRequested(frame)
	if not NMWQ.Controller:IsEnabled() then
		return false
	end
	refreshActiveWQZoneState()
	if not shouldBlockTalkingHead() then
		return false
	end
	logTalkingHeadBlock("block", "TALKINGHEAD_REQUESTED")
	blockTalkingHeadFrame(frame)
	return true
end

local function installTalkingHeadOnEventHook()
	if talkingHeadOnEventHooked or not TalkingHeadFrameMixin or not TalkingHeadFrameMixin.OnEvent then
		return
	end
	talkingHeadOnEventHooked = true
	local originalOnEvent = TalkingHeadFrameMixin.OnEvent
	function TalkingHeadFrameMixin:OnEvent(event, ...)
		if event == "TALKINGHEAD_REQUESTED" and onTalkingHeadRequested(self) then
			return
		end
		return originalOnEvent(self, event, ...)
	end
end

local function installTalkingHeadPlayCurrentHook()
	if talkingHeadPlayCurrentHooked then
		return
	end
	local original
	if TalkingHeadFrameMixin and TalkingHeadFrameMixin.PlayCurrent then
		original = TalkingHeadFrameMixin.PlayCurrent
		function TalkingHeadFrameMixin:PlayCurrent(...)
			if onTalkingHeadRequested(self) then
				return
			end
			return original(self, ...)
		end
		talkingHeadPlayCurrentHooked = true
	elseif TalkingHeadFrame and TalkingHeadFrame.PlayCurrent then
		original = TalkingHeadFrame.PlayCurrent
		TalkingHeadFrame.PlayCurrent = function(self, ...)
			if onTalkingHeadRequested(self) then
				return
			end
			return original(self, ...)
		end
		talkingHeadPlayCurrentHooked = true
	end
end

local function installTalkingHeadHook()
	installTalkingHeadOnEventHook()
	installTalkingHeadPlayCurrentHook()
end

local function installEventToastHook()
	if eventToastHookInstalled or not EventToastManagerFrameMixin or not EventToastManagerFrameMixin.DisplayToast then
		return
	end
	eventToastHookInstalled = true
	local originalDisplayToast = EventToastManagerFrameMixin.DisplayToast
	function EventToastManagerFrameMixin:DisplayToast(firstToast)
		if NMWQ.Controller:IsEnabled() then
			NMWQ.QuestUtil.DrainSuppressedEventToasts()
		end
		return originalDisplayToast(self, firstToast)
	end
end

local function installUIErrorsHook()
	if uiErrorsHookInstalled or not UIErrorsMixin or not UIErrorsMixin.TryDisplayMessage then
		return
	end
	uiErrorsHookInstalled = true
	local originalTryDisplayMessage = UIErrorsMixin.TryDisplayMessage
	function UIErrorsMixin:TryDisplayMessage(messageType, message, r, g, b)
		if NMWQ.QuestUtil.ShouldSuppressUIInfoMessage(message) then
			return
		end
		return originalTryDisplayMessage(self, messageType, message, r, g, b)
	end
end

local function installPresentationHooks()
	installEventToastHook()
	installUIErrorsHook()
end

function IntrusionSurface:LogBlockDecision(triggerEvent)
	logTalkingHeadBlock("policy", triggerEvent)
end

local function onSuperTrackChanged()
	if not NMWQ.Controller:IsEnabled() or not C_SuperTrack then
		return
	end
	refreshActiveWQZoneState()
	if TalkingHeadFrame and TalkingHeadFrame:IsShown() and shouldBlockTalkingHead() then
		blockTalkingHeadFrame(TalkingHeadFrame)
	end
	local vignetteGUID = C_SuperTrack.GetSuperTrackedVignette and C_SuperTrack.GetSuperTrackedVignette()
	if vignetteGUID then
		local info = C_VignetteInfo.GetVignetteInfo(vignetteGUID)
		if shouldSuppressVignetteInfo(info) then
			C_SuperTrack.SetSuperTrackedVignette(0)
			local questID = C_SuperTrack.GetSuperTrackedQuestID()
			if questID and questID > 0 and NMWQ.VisibilityRule.ShouldSuppress(questID) then
				C_SuperTrack.SetSuperTrackedQuestID(0)
			end
			scheduleVignetteHide()
		end
	end
end

local function onEvent(_, event, arg1)
	if event == "VIGNETTES_UPDATED" then
		if NMWQ.Controller:IsEnabled() then
			suppressAllMinimapVignettes()
			scheduleVignetteHide()
		end
	elseif event == "VIGNETTE_MINIMAP_UPDATED" then
		if NMWQ.Controller:IsEnabled() then
			suppressMinimapVignette(arg1)
			scheduleVignetteHide()
		end
	elseif event == "SUPER_TRACKING_CHANGED" then
		onSuperTrackChanged()
	elseif event == "TALKINGHEAD_REQUESTED" then
		refreshActiveWQZoneState()
		if shouldBlockTalkingHead() then
			logTalkingHeadBlock("eventFrame", "TALKINGHEAD_REQUESTED fallback")
			blockTalkingHeadFrame(TalkingHeadFrame)
		end
	elseif event == "DISPLAY_EVENT_TOASTS" then
		if NMWQ.Controller:IsEnabled() then
			NMWQ.QuestUtil.DrainSuppressedEventToasts()
		end
	elseif event == "QUEST_DATA_LOAD_RESULT" then
		local questID = arg1
		if questID then
			NMWQ.VisibilityRule.OnQuestDataLoaded(questID)
		end
		if NMWQ.Controller:IsEnabled() then
			refreshActiveWQZoneState()
			suppressAllMinimapVignettes()
			scheduleVignetteHide()
			if TalkingHeadFrame and TalkingHeadFrame:IsShown() and shouldBlockTalkingHead() then
				blockTalkingHeadFrame(TalkingHeadFrame)
			end
		end
	end
end

function IntrusionSurface:Enable()
	if not eventFrame then
		eventFrame = CreateFrame("Frame")
		eventFrame:RegisterEvent("VIGNETTES_UPDATED")
		eventFrame:RegisterEvent("VIGNETTE_MINIMAP_UPDATED")
		eventFrame:RegisterEvent("SUPER_TRACKING_CHANGED")
		eventFrame:RegisterEvent("TALKINGHEAD_REQUESTED")
		eventFrame:RegisterEvent("QUEST_DATA_LOAD_RESULT")
		eventFrame:RegisterEvent("DISPLAY_EVENT_TOASTS")
		eventFrame:SetScript("OnEvent", onEvent)
	end
	installPresentationHooks()
	installTalkingHeadHook()
	refreshActiveWQZoneState()
	ensureVignetteHooks()
	self:Refresh()
end

function IntrusionSurface:Disable()
	restoreVignettePins()
end

function IntrusionSurface:Refresh()
	if not NMWQ.Controller:IsEnabled() then
		return
	end
	installPresentationHooks()
	installTalkingHeadHook()
	refreshActiveWQZoneState()
	if TalkingHeadFrame and TalkingHeadFrame:IsShown() and shouldBlockTalkingHead() then
		blockTalkingHeadFrame(TalkingHeadFrame)
	end
	ensureVignetteHooks()
	suppressAllMinimapVignettes()
	hideWQVignettePins()
end

installPresentationHooks()
installTalkingHeadHook()
