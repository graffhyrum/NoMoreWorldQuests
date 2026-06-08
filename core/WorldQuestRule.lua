local NMWQ = _G.NoMoreWorldQuests

local WorldQuestRule = {}
NMWQ.WorldQuestRule = WorldQuestRule

function WorldQuestRule:Matches(questID)
	if NMWQ.QuestUtil.HaveQuestData(questID) then
		return C_QuestLog.IsWorldQuest(questID)
	end
	if NMWQ.QuestUtil.IsInTaskTable(questID) then
		return true
	end
	return NMWQ.QuestUtil.MapEntryMarksWorldQuest(questID)
end

NMWQ.VisibilityRule.Register(WorldQuestRule)
