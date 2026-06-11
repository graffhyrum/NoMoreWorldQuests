dofile("Tests/bootstrap.lua")
local load_addon = require("Tests.helpers.load_addon")

describe("SuppressionPolicy", function()
	before_each(function()
		load_addon.reset()
		load_addon.load("core/SuppressionPolicy.lua")
	end)

	local policy = function()
		return load_addon.nmwq().SuppressionPolicy
	end

	it("skips when suppression enabled and quest matches", function()
		assert.is_true(policy().ShouldSkipQuest(true, 42, function()
			return true
		end))
	end)

	it("does not skip when suppression disabled", function()
		assert.is_false(policy().ShouldSkipQuest(false, 42, function()
			return true
		end))
	end)

	it("does not skip COMPLETE popups", function()
		assert.is_false(policy().ShouldSkipAutoQuestPopup(42, "COMPLETE", function()
			return true
		end))
	end)

	it("skips non-COMPLETE popups when shouldSkipQuest is true", function()
		assert.is_true(policy().ShouldSkipAutoQuestPopup(42, "OFFER", function()
			return true
		end))
	end)
end)
