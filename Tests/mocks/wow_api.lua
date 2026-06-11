local M = {}

function M.reset()
	_G.NoMoreWorldQuests = {}
	_G.NoMoreWorldQuestsDB = {}
	_G.C_QuestLog = {
		RequestLoadQuestByID = function() end,
		IsWorldQuest = function()
			return false
		end,
		GetQuestsOnMap = function()
			return nil
		end,
		GetTitleForQuestID = function()
			return nil
		end,
	}
	_G.C_Map = {
		GetBestMapForUnit = function()
			return nil
		end,
	}
	_G.C_TaskQuest = nil
	_G.C_Timer = {
		NewTimer = function(_, fn)
			local timer = { cancelled = false }
			function timer:Cancel()
				self.cancelled = true
			end
			if fn then
				fn()
			end
			return timer
		end,
	}
	_G.C_AddOns = {
		LoadAddOn = function()
			return true
		end,
		IsAddOnLoaded = function()
			return true
		end,
		GetAddOnMetadata = function(_, key)
			if key == "Version" then
				return "1.0.0"
			end
			return nil
		end,
	}
	_G.Enum = {
		EventToastEventType = { QuestTurnedIn = 1 },
	}
	_G.UnitGUID = function()
		return "Player-1-00000001"
	end
	_G.UnitName = function()
		return "Testchar"
	end
	_G.GetRealmName = function()
		return "TestRealm"
	end
	_G.HaveQuestData = function()
		return true
	end
	_G.GetTasksTable = function()
		return nil
	end
	_G.WorldQuestObjectiveTracker = nil
	_G.ObjectiveTrackerTopBannerMixin = nil
	_G.AutoQuestPopupTrackerMixin = nil
	_G.QuestUtil = nil
	_G.LoadAddOn = function()
		return true
	end
	_G.CreateFrame = function()
		return {
			RegisterEvent = function() end,
			SetScript = function() end,
		}
	end
end

return M
