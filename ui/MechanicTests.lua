local NMWQ = _G.NoMoreWorldQuests

local MechanicTests = {}
NMWQ.MechanicTests = MechanicTests

local tests = {
	{
		id = "suppression_toggle",
		name = "Suppression toggle",
		category = "Controller",
		type = "auto",
		description = "Enable and disable suppression without errors.",
	},
	{
		id = "tracker_hooks_installed",
		name = "Tracker hooks installed",
		category = "Surfaces",
		type = "auto",
		description = "Objective tracker surface installs AddQuest hook when enabled.",
	},
	{
		id = "objective_tracker_addon_loaded",
		name = "Objective tracker addon loaded",
		category = "Surfaces",
		type = "auto",
		description = "Blizzard_ObjectiveTracker loads successfully.",
	},
}

function MechanicTests:GetAll()
	return tests
end

function MechanicTests:Run(id)
	local startTime = debugprofilestop and debugprofilestop() or 0
	local result = self:GetResult(id)
	if type(result) == "table" and debugprofilestop then
		result.duration = (debugprofilestop() - startTime) / 1000
		result.id = id
	end
	return result
end

function MechanicTests:GetResult(id)
	if id == "suppression_toggle" then
		local ok, err = pcall(function()
			NMWQ.Controller:Enable()
			NMWQ.Controller:Disable()
		end)
		return {
			passed = ok,
			message = ok and "Toggle OK" or tostring(err),
			details = {
				{
					label = "Enable/Disable",
					value = ok and "pass" or tostring(err),
					status = ok and "pass" or "fail",
				},
			},
		}
	end

	if id == "tracker_hooks_installed" then
		local before = WorldQuestObjectiveTracker and WorldQuestObjectiveTracker.AddQuest
		local ok, err = pcall(function()
			NMWQ.Controller:Enable()
			NMWQ.ObjectiveTrackerSurface:Enable()
		end)
		local after = WorldQuestObjectiveTracker and WorldQuestObjectiveTracker.AddQuest
		local hooked = after ~= nil and (before == nil or before ~= after)
		return {
			passed = ok and hooked,
			message = ok and (hooked and "Hook installed" or "Hook not installed") or tostring(err),
			details = {
				{
					label = "AddQuest hook",
					value = hooked and "installed" or "missing",
					status = (ok and hooked) and "pass" or "fail",
				},
			},
		}
	end

	if id == "objective_tracker_addon_loaded" then
		local loaded = false
		if C_AddOns and C_AddOns.IsAddOnLoaded then
			loaded = C_AddOns.IsAddOnLoaded("Blizzard_ObjectiveTracker") == true
		end
		if not loaded and C_AddOns and C_AddOns.LoadAddOn then
			loaded = C_AddOns.LoadAddOn("Blizzard_ObjectiveTracker") == true
		end
		return {
			passed = loaded,
			message = loaded and "Loaded" or "Not loaded",
			details = {
				{
					label = "Blizzard_ObjectiveTracker",
					value = loaded and "loaded" or "not loaded",
					status = loaded and "pass" or "fail",
				},
			},
		}
	end

	return { passed = false, message = "Unknown test: " .. tostring(id) }
end

local MechanicLib = LibStub and LibStub("MechanicLib-1.0", true)
if MechanicLib then
	local version = "1.0.0"
	if C_AddOns and C_AddOns.GetAddOnMetadata then
		version = C_AddOns.GetAddOnMetadata("NoMoreWorldQuests", "Version") or version
	end
	MechanicLib:Register("NoMoreWorldQuests", {
		version = version,
		tests = {
			getAll = function()
				return MechanicTests:GetAll()
			end,
			getCategories = function()
				return { "Controller", "Surfaces" }
			end,
			run = function(id)
				return MechanicTests:Run(id)
			end,
			getResult = function(id)
				return MechanicTests:GetResult(id)
			end,
		},
	})
end
