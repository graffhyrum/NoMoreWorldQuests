std = "lua51"
max_line_length = 160

-- WoW event/method handlers use unused `self` / `event` arguments by convention.
ignore = {
	"212",
}

-- Frames and mixins the addon assigns to or hooks.
globals = {
	"LibStub",
	"SlashCmdList",
	"SLASH_NOMOREWORLDQUESTS1",
	"WorldMapFrame",
	"TalkingHeadFrame",
	"TalkingHeadFrameMixin",
	"VignetteDataProviderMixin",
	"VignettePinBaseMixin",
	"UIErrorsMixin",
	"EventToastManagerFrameMixin",
	"WorldQuestDataProviderMixin",
	"QuestPOIButtonMixin",
	"TaskPOIButtonMixin",
	"WorldQuestObjectiveTracker",
	"ObjectiveTrackerTopBannerMixin",
	"AutoQuestPopupTrackerMixin",
	"QuestUtil",
	"NoMoreWorldQuests",
	"NoMoreWorldQuestsDB",
}

-- Read-only WoW APIs and frames. Declared explicitly (no std=wow blanket).
read_globals = {
	"CreateFrame",
	"GetTime",
	"UnitGUID",
	"UnitName",
	"GetRealmName",
	"LoadAddOn",
	"HaveQuestData",
	"GetTasksTable",
	"GetTaskInfo",
	"C_AddOns",
	"C_Map",
	"C_QuestLog",
	"C_TaskQuest",
	"C_Timer",
	"C_EventToastManager",
	"C_SuperTrack",
	"C_TalkingHead",
	"C_VignetteInfo",
	"Enum",
	"Minimap",
	"MinimapPOIFrame",
	"GameTooltip",
	"UIParent",
	"DEFAULT_CHAT_FRAME",
	"hooksecurefunc",
	"debugprofilestop",
	"QuestPOIUpdateIcons",
	"QuestPOIGetNumQuestPOIs",
	"QuestPOIGetIconInfo",
	"GetCVar",
	"SetCVar",
	"StopSound",
	"strtrim",
	"strsub",
}

exclude_files = {
	"libs/**",
	"repos/**",
	"Tests/**",
	"**/*_spec.lua",
	"**/*_busted.lua",
	"scripts/**",
}
