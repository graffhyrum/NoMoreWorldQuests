dofile("Tests/bootstrap.lua")
local load_addon = require("Tests.helpers.load_addon")

describe("QuestUtil", function()
	before_each(function()
		load_addon.reset()
		load_addon.load("core/QuestUtil.lua")
	end)

	local util = function()
		return load_addon.nmwq().QuestUtil
	end

	describe("QuestIDFrom", function()
		it("reads questID", function()
			assert.equals(99, util().QuestIDFrom({ questID = 99 }))
		end)

		it("reads questId alias", function()
			assert.equals(88, util().QuestIDFrom({ questId = 88 }))
		end)

		it("returns nil for missing object", function()
			assert.is_nil(util().QuestIDFrom(nil))
		end)
	end)

	describe("QuestIDFromLink", function()
		it("parses quest id from link", function()
			assert.equals(12345, util().QuestIDFromLink("|Hquest:12345:90|h[Quest]|h|r"))
		end)

		it("returns nil for empty link", function()
			assert.is_nil(util().QuestIDFromLink(""))
		end)
	end)
end)
