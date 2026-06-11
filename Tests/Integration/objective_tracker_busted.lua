dofile("Tests/bootstrap.lua")
local load_addon = require("Tests.helpers.load_addon")

describe("ObjectiveTrackerSurface", function()
	before_each(function()
		load_addon.reset()
		_G.WorldQuestObjectiveTracker = {
			AddQuest = function()
				return false
			end,
			MarkDirty = function() end,
			showWorldQuests = true,
		}
		_G.AutoQuestPopupTrackerMixin = {
			ShouldDisplayAutoQuest = function()
				return true
			end,
		}
		load_addon.load_objective_tracker_surface()
		load_addon.nmwq().VisibilityRule.Register({
			Matches = function(_, questID)
				return questID == 999
			end,
		})
	end)

	local surface = function()
		return load_addon.nmwq().ObjectiveTrackerSurface
	end

	local controller = function()
		return load_addon.nmwq().Controller
	end

	it("Enable does not error when AddAutoQuestPopUp is missing", function()
		local ok, err = pcall(function()
			controller():Enable()
			surface():Enable()
		end)
		assert.is_true(ok, err)
	end)

	it("skips AddQuest for suppressed world quests when enabled", function()
		local added
		_G.WorldQuestObjectiveTracker.AddQuest = function(_, questID)
			added = questID
			return false
		end
		controller():Enable()
		surface():Enable()
		_G.WorldQuestObjectiveTracker:AddQuest(999, true)
		assert.is_nil(added)
	end)

	it("hooks AddQuest when mixin methods exist", function()
		local original = _G.WorldQuestObjectiveTracker.AddQuest
		controller():Enable()
		surface():Enable()
		assert.is_not.equal(_G.WorldQuestObjectiveTracker.AddQuest, original)
	end)
end)
