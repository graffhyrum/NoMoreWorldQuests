local NMWQ = _G.NoMoreWorldQuests

local QuestUtil = {}
NMWQ.QuestUtil = QuestUtil

function QuestUtil.QuestIDFrom(obj)
	if not obj then
		return nil
	end
	return obj.questID or obj.questId
end

function QuestUtil.HaveQuestData(questID)
	return type(HaveQuestData) == "function" and HaveQuestData(questID)
end

function QuestUtil.ForEachRelevantQuestID(fn)
	local seen = {}
	local function emit(questID)
		if questID and questID > 0 and not seen[questID] then
			seen[questID] = true
			fn(questID)
		end
	end
	if type(GetTasksTable) == "function" then
		local tasks = GetTasksTable()
		if tasks then
			for _, questID in ipairs(tasks) do
				emit(questID)
			end
		end
	end
	local mapID = C_Map.GetBestMapForUnit("player")
	if not mapID then
		return
	end
	if C_TaskQuest and C_TaskQuest.GetQuestsOnMap then
		local taskPOIs = C_TaskQuest.GetQuestsOnMap(mapID)
		if taskPOIs then
			for _, entry in ipairs(taskPOIs) do
				emit(entry.questID)
			end
		end
	end
	if C_QuestLog.GetQuestsOnMap then
		local quests = C_QuestLog.GetQuestsOnMap(mapID)
		if quests then
			for _, entry in ipairs(quests) do
				emit(entry.questID)
			end
		end
	end
end

function QuestUtil.IsInTaskTable(questID)
	if type(GetTasksTable) ~= "function" then
		return false
	end
	local tasks = GetTasksTable()
	if not tasks then
		return false
	end
	for _, id in ipairs(tasks) do
		if id == questID then
			return true
		end
	end
	return false
end

function QuestUtil.MapEntryMarksWorldQuest(questID)
	local mapID = C_Map.GetBestMapForUnit("player")
	if not mapID or not questID then
		return false
	end
	if C_QuestLog.GetQuestsOnMap then
		local quests = C_QuestLog.GetQuestsOnMap(mapID)
		if quests then
			for _, entry in ipairs(quests) do
				if entry.questID == questID and entry.isWorldQuest then
					return true
				end
			end
		end
	end
	if C_TaskQuest and C_TaskQuest.GetQuestsOnMap then
		local taskPOIs = C_TaskQuest.GetQuestsOnMap(mapID)
		if taskPOIs then
			for _, entry in ipairs(taskPOIs) do
				if entry.questID == questID then
					return true
				end
			end
		end
	end
	return false
end

function QuestUtil.TaskIsInArea(questID)
	if C_TaskQuest and C_TaskQuest.GetQuestInfoByQuestID then
		local info = C_TaskQuest.GetQuestInfoByQuestID(questID)
		if type(info) == "table" and info.isInArea ~= nil then
			return info.isInArea
		end
	end
	if type(GetTaskInfo) == "function" then
		local isInArea = GetTaskInfo(questID)
		if isInArea ~= nil then
			return isInArea == true
		end
	end
	if C_TaskQuest and C_TaskQuest.IsActive then
		return C_TaskQuest.IsActive(questID)
	end
	return false
end

function QuestUtil.HasSuppressedWorldQuestInArea()
	local found = false
	QuestUtil.ForEachRelevantQuestID(function(questID)
		if not found and NMWQ.VisibilityRule.ShouldSuppress(questID) and QuestUtil.TaskIsInArea(questID) then
			found = true
		end
	end)
	return found
end

function QuestUtil.HasSuppressedWorldQuestInTaskTable()
	if type(GetTasksTable) ~= "function" then
		return false
	end
	local tasks = GetTasksTable()
	if not tasks then
		return false
	end
	for _, questID in ipairs(tasks) do
		if NMWQ.VisibilityRule.ShouldSuppress(questID) then
			return true
		end
	end
	return false
end

function QuestUtil.HasSuppressedWorldQuestOnMap()
	local found = false
	QuestUtil.ForEachRelevantQuestID(function(questID)
		if not found and NMWQ.VisibilityRule.ShouldSuppress(questID) then
			found = true
		end
	end)
	return found
end

function QuestUtil.QuestIDFromLink(link)
	if not link or link == "" then
		return nil
	end
	local questID = link:match("quest:(%d+)")
	if questID then
		return tonumber(questID)
	end
	return nil
end

function QuestUtil.QuestTitleFor(questID)
	if not questID then
		return nil
	end
	if C_TaskQuest and C_TaskQuest.GetQuestInfoByQuestID then
		local info = C_TaskQuest.GetQuestInfoByQuestID(questID)
		if type(info) == "string" and info ~= "" then
			return info
		end
		if type(info) == "table" then
			local title = info.questName or info.title or info.name
			if title and title ~= "" then
				return title
			end
		end
	end
	if C_QuestLog and C_QuestLog.GetTitleForQuestID then
		local title = C_QuestLog.GetTitleForQuestID(questID)
		if title and title ~= "" then
			return title
		end
	end
	return nil
end

function QuestUtil.ToastTextMatchesSuppressedWorldQuest(title)
	if not title or title == "" then
		return false
	end
	local found = false
	QuestUtil.ForEachRelevantQuestID(function(questID)
		if not found and NMWQ.VisibilityRule.ShouldSuppress(questID) then
			local questTitle = QuestUtil.QuestTitleFor(questID)
			if questTitle and questTitle == title then
				found = true
			end
		end
	end)
	return found
end

function QuestUtil.ShouldSuppressEventToast(toastInfo)
	if not toastInfo or not NMWQ.Controller:IsEnabled() then
		return false
	end
	if toastInfo.eventType == Enum.EventToastEventType.QuestTurnedIn then
		return false
	end
	local questID = QuestUtil.QuestIDFromLink(toastInfo.link)
	if questID and NMWQ.VisibilityRule.ShouldSuppress(questID) then
		return true
	end
	return QuestUtil.ToastTextMatchesSuppressedWorldQuest(toastInfo.title)
end

function QuestUtil.DrainSuppressedEventToasts()
	if not C_EventToastManager or not C_EventToastManager.GetNextToastToDisplay then
		return
	end
	local guard = 0
	while guard < 32 do
		local toastInfo = C_EventToastManager.GetNextToastToDisplay()
		if not toastInfo or not QuestUtil.ShouldSuppressEventToast(toastInfo) then
			break
		end
		guard = guard + 1
		C_EventToastManager.RemoveCurrentToast()
	end
end

function QuestUtil.ShouldSuppressUIInfoMessage(message)
	if not message or message == "" or not NMWQ.Controller:IsEnabled() then
		return false
	end
	return QuestUtil.ToastTextMatchesSuppressedWorldQuest(message)
		or QuestUtil.MessageMentionsSuppressedWorldQuest(message)
end

function QuestUtil.MessageMentionsSuppressedWorldQuest(message)
	local found = false
	QuestUtil.ForEachRelevantQuestID(function(questID)
		if not found and NMWQ.VisibilityRule.ShouldSuppress(questID) then
			local title = QuestUtil.QuestTitleFor(questID)
			if title and title ~= "" and message:find(title, 1, true) then
				found = true
			end
		end
	end)
	return found
end
