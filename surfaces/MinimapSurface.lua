local NMWQ = _G.NoMoreWorldQuests

local MinimapSurface = {}
NMWQ.MinimapSurface = MinimapSurface

local hooksInstalled = false
local eventFrame = nil
local taskBlobsHidden = false

local TASK_BLOB_RESTORE = {
	insideAlpha = 64,
	outsideAlpha = 128,
	ringAlpha = 255,
	ringScalar = 255,
}

local function clearSuppressedMinimapBlobs()
	if not Minimap or not Minimap.DrawBlob then
		return
	end
	NMWQ.QuestUtil.ForEachRelevantQuestID(function(questID)
		if NMWQ.VisibilityRule.ShouldSuppress(questID) then
			pcall(Minimap.DrawBlob, Minimap, questID, false)
		end
	end)
	if C_SuperTrack and C_SuperTrack.GetSuperTrackedQuestID then
		local questID = C_SuperTrack.GetSuperTrackedQuestID()
		if questID and NMWQ.VisibilityRule.ShouldSuppress(questID) then
			pcall(Minimap.DrawBlob, Minimap, questID, false)
		end
	end
end

local function setTaskBlobVisibility(hidden)
	if not Minimap or not Minimap.SetTaskBlobInsideAlpha then
		return
	end
	if hidden then
		Minimap:SetTaskBlobInsideAlpha(0)
		Minimap:SetTaskBlobOutsideAlpha(0)
		Minimap:SetTaskBlobRingAlpha(0)
		if Minimap.SetTaskBlobRingScalar then
			Minimap:SetTaskBlobRingScalar(0)
		end
		taskBlobsHidden = true
	elseif taskBlobsHidden then
		Minimap:SetTaskBlobInsideAlpha(TASK_BLOB_RESTORE.insideAlpha)
		Minimap:SetTaskBlobOutsideAlpha(TASK_BLOB_RESTORE.outsideAlpha)
		Minimap:SetTaskBlobRingAlpha(TASK_BLOB_RESTORE.ringAlpha)
		if Minimap.SetTaskBlobRingScalar then
			Minimap:SetTaskBlobRingScalar(TASK_BLOB_RESTORE.ringScalar)
		end
		taskBlobsHidden = false
	end
end

local function hideQuestPOIChild(child)
	if not child or not child.Hide then
		return
	end
	local questID = NMWQ.QuestUtil.QuestIDFrom(child)
	if questID and NMWQ.VisibilityRule.ShouldSuppress(questID) then
		child:Hide()
	end
end

local function hideWQQuestPOIs()
	if not NMWQ.Controller:IsEnabled() then
		return
	end
	setTaskBlobVisibility(true)
	clearSuppressedMinimapBlobs()

	if QuestPOIGetIconInfo then
		local num = QuestPOIGetNumQuestPOIs and QuestPOIGetNumQuestPOIs() or 0
		for i = 1, num do
			local questID = select(2, QuestPOIGetIconInfo(i))
			if questID and NMWQ.VisibilityRule.ShouldSuppress(questID) then
				local icon = _G["QuestPOI" .. i]
				if icon and icon.Hide then
					icon:Hide()
				end
			end
		end
	end

	if MinimapPOIFrame and MinimapPOIFrame.pool and MinimapPOIFrame.pool.EnumerateActive then
		for child in MinimapPOIFrame.pool:EnumerateActive() do
			hideQuestPOIChild(child)
		end
	end
end

local function restoreMinimapQuestPOIs()
	if QuestPOIUpdateIcons then
		QuestPOIUpdateIcons()
	end
end

local function installHooks()
	if hooksInstalled then
		return
	end
	hooksInstalled = true

	if QuestPOIUpdateIcons then
		hooksecurefunc("QuestPOIUpdateIcons", hideWQQuestPOIs)
	end
	if Minimap and Minimap.SetQuestPOIs then
		hooksecurefunc(Minimap, "SetQuestPOIs", hideWQQuestPOIs)
	end
	if QuestPOIButtonMixin and QuestPOIButtonMixin.UpdateButton then
		hooksecurefunc(QuestPOIButtonMixin, "UpdateButton", function(button)
			if NMWQ.Controller:IsEnabled() then
				hideQuestPOIChild(button)
			end
		end)
	end
	if TaskPOIButtonMixin and TaskPOIButtonMixin.UpdateButton then
		hooksecurefunc(TaskPOIButtonMixin, "UpdateButton", function(button)
			if NMWQ.Controller:IsEnabled() then
				hideQuestPOIChild(button)
			end
		end)
	end
end

local function onMinimapEvent(_, event, questID)
	if not NMWQ.Controller:IsEnabled() then
		return
	end
	if event == "PLAYER_INSIDE_QUEST_BLOB_STATE_CHANGED" then
		if questID and NMWQ.VisibilityRule.ShouldSuppress(questID) then
			NMWQ.Debounce.After("minimap", hideWQQuestPOIs)
		end
	elseif event == "QUEST_POI_UPDATE" then
		hideWQQuestPOIs()
	end
end

local function installEvents()
	if eventFrame then
		return
	end
	eventFrame = CreateFrame("Frame")
	eventFrame:RegisterEvent("PLAYER_INSIDE_QUEST_BLOB_STATE_CHANGED")
	eventFrame:RegisterEvent("QUEST_POI_UPDATE")
	eventFrame:SetScript("OnEvent", onMinimapEvent)
end

function MinimapSurface:Enable()
	installHooks()
	installEvents()
	self:Refresh()
end

function MinimapSurface:Disable()
	setTaskBlobVisibility(false)
	restoreMinimapQuestPOIs()
end

function MinimapSurface:Refresh()
	if NMWQ.Controller:IsEnabled() then
		hideWQQuestPOIs()
	end
end
