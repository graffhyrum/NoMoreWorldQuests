dofile("Tests/bootstrap.lua")
local load_addon = require("Tests.helpers.load_addon")

describe("VisibilityRule", function()
	local requested = {}

	before_each(function()
		load_addon.reset()
		requested = {}
		_G.C_QuestLog.RequestLoadQuestByID = function(questID)
			requested[#requested + 1] = questID
		end
		load_addon.load("core/QuestUtil.lua")
		load_addon.load("core/VisibilityRule.lua", "NoMoreWorldQuests")
	end)

	local rule = function()
		return load_addon.nmwq().VisibilityRule
	end

	it("returns false for nil questID", function()
		assert.is_false(rule().ShouldSuppress(nil))
	end)

	it("returns true when a registered rule matches", function()
		rule().Register({
			Matches = function(_, questID)
				return questID == 7
			end,
		})
		assert.is_true(rule().ShouldSuppress(7))
	end)

	it("requests quest data when no rule matches and data missing", function()
		_G.HaveQuestData = function()
			return false
		end
		assert.is_false(rule().ShouldSuppress(55))
		assert.same({ 55 }, requested)
	end)
end)
