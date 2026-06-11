local wow_api = require("Tests.mocks.wow_api")

local M = {}

local loaded = {}

local function root()
	return os.getenv("NMWQ_ROOT") or "."
end

local function loadfile_at(path)
	local chunk, err = loadfile(path)
	if not chunk then
		error(err or ("failed to load " .. path))
	end
	return chunk
end

function M.reset()
	wow_api.reset()
	loaded = {}
	for key in pairs(package.loaded) do
		if key:match("^core/") or key:match("^surfaces/") or key:match("^Tests%.") then
			package.loaded[key] = nil
		end
	end
end

function M.load(relativePath, ...)
	local path = root() .. "/" .. relativePath:gsub("\\", "/")
	if loaded[path] then
		return
	end
	local chunk = loadfile_at(path)
	chunk(...)
	loaded[path] = true
end

function M.load_core()
	M.load("core/SuppressionPolicy.lua")
	M.load("core/QuestUtil.lua")
	M.load("core/VisibilityRule.lua", "NoMoreWorldQuests")
	M.load("core/WorldQuestRule.lua")
end

function M.load_objective_tracker_surface()
	M.load_core()
	M.load("core/Controller.lua", "NoMoreWorldQuests")
	M.load("surfaces/ObjectiveTrackerSurface.lua")
end

function M.nmwq()
	return _G.NoMoreWorldQuests
end

return M
