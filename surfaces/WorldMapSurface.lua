local NMWQ = _G.NoMoreWorldQuests

local WorldMapSurface = {}
NMWQ.WorldMapSurface = WorldMapSurface

local hooksInstalled = false

local MAP_PIN_TEMPLATES = {
	"WorldQuestPinTemplate",
	"QuestPinTemplate",
}

local function applyToMapPins(map, applyFn)
	if not map or not map.EnumeratePinsByTemplate then
		return
	end
	for t = 1, #MAP_PIN_TEMPLATES do
		for pin in map:EnumeratePinsByTemplate(MAP_PIN_TEMPLATES[t]) do
			applyFn(pin)
		end
	end
end

local function hidePinsOnMap(map)
	applyToMapPins(map, function(pin)
		local questID = NMWQ.QuestUtil.QuestIDFrom(pin)
		if questID and NMWQ.VisibilityRule.ShouldSuppress(questID) then
			pin:Hide()
			if pin.SetAlpha then
				pin:SetAlpha(0)
			end
		end
	end)
end

local function restorePinsOnMap(map)
	applyToMapPins(map, function(pin)
		if pin.Show then
			pin:Show()
		end
		if pin.SetAlpha then
			pin:SetAlpha(1)
		end
	end)
end

local function refreshMapPins()
	NMWQ.MapCanvas.ForEach(hidePinsOnMap)
end

local function restoreMapPins()
	NMWQ.MapCanvas.ForEach(restorePinsOnMap)
end

local function scheduleRefresh()
	NMWQ.Debounce.After("worldmap", refreshMapPins)
end

local function installHooks()
	if hooksInstalled then
		return
	end
	if not WorldQuestDataProviderMixin then
		return
	end
	hooksInstalled = true
	hooksecurefunc(WorldQuestDataProviderMixin, "AddWorldQuest", function(_, questID)
		if not NMWQ.Controller:IsEnabled() then
			return
		end
		if questID and NMWQ.VisibilityRule.ShouldSuppress(questID) then
			scheduleRefresh()
		end
	end)
	hooksecurefunc(WorldQuestDataProviderMixin, "RefreshAllData", function()
		if NMWQ.Controller:IsEnabled() then
			scheduleRefresh()
		end
	end)
end

local function hookMapShow()
	if WorldMapFrame and not WorldMapFrame._NMWQHooked then
		WorldMapFrame._NMWQHooked = true
		WorldMapFrame:HookScript("OnShow", function()
			WorldMapSurface:Refresh()
		end)
	end
end

function WorldMapSurface:Enable()
	installHooks()
	hookMapShow()
	self:Refresh()
end

function WorldMapSurface:Disable()
	restoreMapPins()
end

function WorldMapSurface:Refresh()
	if NMWQ.Controller:IsEnabled() then
		refreshMapPins()
	end
end
