dofile("Tests/bootstrap.lua")
local load_addon = require("Tests.helpers.load_addon")

describe("WorldQuestRule", function()
	before_each(function()
		load_addon.reset()
		_G.C_QuestLog.IsWorldQuest = function(questID)
			return questID == 100
		end
		load_addon.load("core/QuestUtil.lua")
		load_addon.load("core/VisibilityRule.lua", "NoMoreWorldQuests")
		load_addon.load("core/WorldQuestRule.lua")
	end)

	local wqRule = function()
		return load_addon.nmwq().WorldQuestRule
	end

	it("uses C_QuestLog when quest data is available", function()
		_G.HaveQuestData = function()
			return true
		end
		assert.is_true(wqRule():Matches(100))
		assert.is_false(wqRule():Matches(200))
	end)

	it("falls back to task table", function()
		_G.HaveQuestData = function()
			return false
		end
		_G.GetTasksTable = function()
			return { 42 }
		end
		assert.is_true(wqRule():Matches(42))
	end)
end)
