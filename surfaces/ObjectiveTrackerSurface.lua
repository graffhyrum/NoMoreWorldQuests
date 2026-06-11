local NMWQ = _G.NoMoreWorldQuests

local ObjectiveTrackerSurface = {}
NMWQ.ObjectiveTrackerSurface = ObjectiveTrackerSurface

local hooksInstalled = false
local trackerLoaded = false
local originalAddQuest
local originalDisplayForQuest
local originalShouldDisplayAutoQuest
local originalAddAutoQuestPopUp
local originalTrackWorldQuest

local function worldQuestModule()
	return WorldQuestObjectiveTracker
end

local function shouldSkipQuest(questID)
	return NMWQ.SuppressionPolicy.ShouldSkipQuest(
		NMWQ.Controller:IsEnabled(),
		questID,
		NMWQ.VisibilityRule.ShouldSuppress
	)
end

local function shouldSkipAutoQuestPopup(questID, popUpType)
	return NMWQ.SuppressionPolicy.ShouldSkipAutoQuestPopup(questID, popUpType, shouldSkipQuest)
end

local function markModuleDirty()
	local module = worldQuestModule()
	if module and module.MarkDirty then
		module:MarkDirty()
	end
end

local function ensureTracker()
	if trackerLoaded then
		return true
	end
	if C_AddOns and C_AddOns.LoadAddOn then
		local loaded = C_AddOns.LoadAddOn("Blizzard_ObjectiveTracker")
		trackerLoaded = loaded or (C_AddOns.IsAddOnLoaded("Blizzard_ObjectiveTracker") == true)
	else
		local loaded = LoadAddOn("Blizzard_ObjectiveTracker")
		trackerLoaded = loaded
	end
	return trackerLoaded
end

local function installTopBannerHook()
	if originalDisplayForQuest then
		return
	end
	if not ObjectiveTrackerTopBannerMixin or not ObjectiveTrackerTopBannerMixin.DisplayForQuest then
		return
	end
	originalDisplayForQuest = ObjectiveTrackerTopBannerMixin.DisplayForQuest
	function ObjectiveTrackerTopBannerMixin:DisplayForQuest(questID, module)
		if
			NMWQ.Controller:IsEnabled()
			and module
			and module.showWorldQuests
			and questID
			and NMWQ.VisibilityRule.ShouldSuppress(questID)
		then
			return false
		end
		return originalDisplayForQuest(self, questID, module)
	end
end

local function installTrackerPresentationHooks()
	if QuestUtil and QuestUtil.TrackWorldQuest and not originalTrackWorldQuest then
		originalTrackWorldQuest = QuestUtil.TrackWorldQuest
		function QuestUtil.TrackWorldQuest(questID, watchType)
			if shouldSkipQuest(questID) then
				return
			end
			return originalTrackWorldQuest(questID, watchType)
		end
	end
	if
		AutoQuestPopupTrackerMixin
		and AutoQuestPopupTrackerMixin.ShouldDisplayAutoQuest
		and not originalShouldDisplayAutoQuest
	then
		originalShouldDisplayAutoQuest = AutoQuestPopupTrackerMixin.ShouldDisplayAutoQuest
		function AutoQuestPopupTrackerMixin:ShouldDisplayAutoQuest(questID)
			if shouldSkipQuest(questID) then
				return false
			end
			return originalShouldDisplayAutoQuest(self, questID)
		end
	end
	if
		AutoQuestPopupTrackerMixin
		and AutoQuestPopupTrackerMixin.AddAutoQuestPopUp
		and not originalAddAutoQuestPopUp
	then
		originalAddAutoQuestPopUp = AutoQuestPopupTrackerMixin.AddAutoQuestPopUp
		function AutoQuestPopupTrackerMixin:AddAutoQuestPopUp(questID, popUpType, itemID)
			if shouldSkipAutoQuestPopup(questID, popUpType) then
				return false
			end
			return originalAddAutoQuestPopUp(self, questID, popUpType, itemID)
		end
	end
end

local function installHooks()
	if hooksInstalled then
		return
	end
	if not ensureTracker() then
		return
	end
	local module = worldQuestModule()
	if not module or not module.AddQuest then
		return
	end
	hooksInstalled = true
	originalAddQuest = module.AddQuest
	function module:AddQuest(questID, isTrackedWorldQuest)
		if shouldSkipQuest(questID) then
			return true
		end
		return originalAddQuest(self, questID, isTrackedWorldQuest)
	end
	installTopBannerHook()
	installTrackerPresentationHooks()
end

function ObjectiveTrackerSurface:Enable()
	installHooks()
	markModuleDirty()
end

function ObjectiveTrackerSurface:Disable()
	markModuleDirty()
end

function ObjectiveTrackerSurface:Refresh()
	if not NMWQ.Controller:IsEnabled() then
		return
	end
	installHooks()
	markModuleDirty()
end
