std = "lua51"
max_line_length = 160

globals = {
	"LibStub",
	"CreateFrame",
	"GetTime",
	"UnitGUID",
	"UnitName",
	"GetRealmName",
	"LoadAddOn",
	"HaveQuestData",
	"GetTasksTable",
	"GetTaskInfo",
	"WorldQuestObjectiveTracker",
	"ObjectiveTrackerTopBannerMixin",
	"AutoQuestPopupTrackerMixin",
	"QuestUtil",
	"NoMoreWorldQuests",
	"NoMoreWorldQuestsDB",
}

read_globals = {
	"C_AddOns",
	"C_Map",
	"C_QuestLog",
	"C_TaskQuest",
	"C_Timer",
	"C_EventToastManager",
	"Enum",
}

exclude_files = {
	"libs/**",
	"repos/**",
}
