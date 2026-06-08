# API Research Report — NoMoreWorldQuests v1

See agent research session. Key decisions for implementation:

- **WQ ID:** `C_QuestLog.IsWorldQuest(questID)` (+ `HaveQuestData` / `QUEST_DATA_LOAD_RESULT`)
- **Active WQ zone:** `GetTasksTable()` + `IsWorldQuest` + `GetTaskInfo(questID)` → `isInArea`; backup `C_TaskQuest.IsActive`
- **Map filter sync:** `GetCVarBool("questPOIWQ")` / `SetCVar("questPOIWQ", "0"|"1")` on suppression toggle only (NOT `C_Map.SetMapPinFilter`)
- **World map:** Hook `WorldQuestDataProviderMixin` (`AddWorldQuest`, `ShouldShowQuest`, or post-`RefreshAllData` hide WQ pins)
- **Minimap:** `hooksecurefunc` on `QuestPOIUpdateIcons` / task POI creation; hide frames with WQ `questID`; **WQ area blobs:** `Minimap:SetTaskBlob*Alpha(0)` + `Minimap:DrawBlob(questID, false)` when available; refresh on `PLAYER_INSIDE_QUEST_BLOB_STATE_CHANGED` (`C_Minimap.IsInsideQuestBlob`)
- **Tracker:** `LoadAddOn("Blizzard_ObjectiveTracker")`; pre-gate `WorldQuestObjectiveTracker:AddQuest` (skip layout when suppressed); pre-gate `ObjectiveTrackerTopBannerMixin:DisplayForQuest` for WQ zone-entry banner; `MarkDirty` on toggle (no post-`Show` hide)
- **Talking head:** `LoadWith: Blizzard_TalkingHeadUI`; pre-hook `TalkingHeadFrameMixin:OnEvent` + `PlayCurrent` (before `PlaySound`); `IgnoreCurrentTalkingHead` then `CloseImmediately`; block when suppression on and WQ in task table / on map / in area / super-tracked (zone-entry TH often precedes `isInArea`); `ActiveWQZone:Evaluate` on request; event-frame fallback only; debug: `/nmwq trace on`
- **Vignettes:** `ShouldShowVignette` pre-hook; map pins + `VIGNETTE_MINIMAP_UPDATED` (super-track clear, optional runtime hide APIs via pcall); `rewardQuestID` → `ShouldSuppress` with task-table WQ fast path
- **Event toasts:** Pre-hook `EventToastManagerFrameMixin:DisplayToast` + `DISPLAY_EVENT_TOASTS` → `QuestUtil.DrainSuppressedEventToasts()` (`RemoveCurrentToast` loop); match WQ via `toastInfo.link` (`quest:ID`) or title; never drain `EventToastEventType.QuestTurnedIn`
- **Auto quest popup / watch:** Pre-gate `QuestUtil.TrackWorldQuest`, `AutoQuestPopupTrackerMixin:ShouldDisplayAutoQuest` / `AddAutoQuestPopUp` (skip `OFFER`/discovery only); `UI_INFO_MESSAGE` via `UIErrorsMixin:TryDisplayMessage` when message names a suppressed WQ
- **Do NOT suppress:** `QuestFrame`, turn-in, `QUEST_TURNED_IN` UI, loot/toasts, `AUTO_QUEST_POPUP` type `COMPLETE`, `EventToastEventType.QuestTurnedIn`
- **Events:** `QUEST_LOG_UPDATE`, `QUEST_POI_UPDATE`, `ZONE_CHANGED_NEW_AREA`, `SUPER_TRACKING_CHANGED`, `VIGNETTES_UPDATED`, etc.

Full report with confidence levels and checklist was produced in research pass; verify minimap frame names and talking-head quest ID in-game.
