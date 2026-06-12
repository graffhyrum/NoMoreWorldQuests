local NMWQ = _G.NoMoreWorldQuests

describe("QuestUtil (sandbox)", function()
	local util = NMWQ.QuestUtil

	it("parses quest id from link", function()
		assert.equals(12345, util.QuestIDFromLink("|Hquest:12345:90|h[Quest]|h|r"))
	end)
end)
