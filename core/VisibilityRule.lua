local addonName = ...
local NMWQ = _G.NoMoreWorldQuests or {}
_G.NoMoreWorldQuests = NMWQ

local VisibilityRule = {}
NMWQ.VisibilityRule = VisibilityRule

local rules = {}
local pendingQuestLoads = {}

function VisibilityRule.Register(rule)
	rules[#rules + 1] = rule
end

function VisibilityRule.ShouldSuppress(questID)
	if not questID or questID == 0 then
		return false
	end
	for i = 1, #rules do
		local rule = rules[i]
		if rule.Matches and rule:Matches(questID) then
			return true
		end
	end
	if not NMWQ.QuestUtil.HaveQuestData(questID) and not pendingQuestLoads[questID] then
		pendingQuestLoads[questID] = true
		C_QuestLog.RequestLoadQuestByID(questID)
	end
	return false
end

function VisibilityRule.OnQuestDataLoaded(questID)
	pendingQuestLoads[questID] = nil
end
