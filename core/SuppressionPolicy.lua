local NMWQ = _G.NoMoreWorldQuests

local SuppressionPolicy = {}
NMWQ.SuppressionPolicy = SuppressionPolicy

function SuppressionPolicy.ShouldSkipQuest(suppressionEnabled, questID, shouldSuppress)
	if not suppressionEnabled or not questID then
		return false
	end
	return shouldSuppress(questID) == true
end

function SuppressionPolicy.ShouldSkipAutoQuestPopup(questID, popUpType, shouldSkipQuest)
	if popUpType == "COMPLETE" then
		return false
	end
	return shouldSkipQuest(questID)
end
