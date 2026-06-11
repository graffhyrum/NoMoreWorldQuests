local NMWQ = _G.NoMoreWorldQuests

describe("SuppressionPolicy (sandbox)", function()
	local policy = NMWQ.SuppressionPolicy

	it("skips when suppression enabled and quest matches", function()
		assert.is_true(policy.ShouldSkipQuest(true, 42, function()
			return true
		end))
	end)

	it("does not skip COMPLETE popups", function()
		assert.is_false(policy.ShouldSkipAutoQuestPopup(42, "COMPLETE", function()
			return true
		end))
	end)
end)
