local addonName = ...
local NMWQ = _G.NoMoreWorldQuests or {}
_G.NoMoreWorldQuests = NMWQ

local Controller = {}
NMWQ.Controller = Controller
NMWQ.ADDON_NAME = addonName

local surfaces = {}
local enabled = false
local callbacks = {}

function Controller.RegisterSurface(surface)
	surfaces[#surfaces + 1] = surface
end

function Controller.RegisterCallback(fn)
	callbacks[#callbacks + 1] = fn
end

function Controller:GetCharDB()
	NoMoreWorldQuestsDB = NoMoreWorldQuestsDB or {}
	local db = NoMoreWorldQuestsDB
	db.char = db.char or {}
	local key = UnitGUID("player") or (UnitName("player") .. "-" .. (GetRealmName() or ""))
	db.char[key] = db.char[key] or { suppressionEnabled = false }
	return db.char[key]
end

function Controller:IsEnabled()
	return enabled
end

local function fireCallbacks()
	for i = 1, #callbacks do
		callbacks[i](enabled)
	end
end

local function setSurfacesActive(active)
	for i = 1, #surfaces do
		local surface = surfaces[i]
		if active then
			surface:Enable()
		else
			surface:Disable()
		end
	end
end

function Controller:ApplyFromSaved()
	local charDB = self:GetCharDB()
	enabled = charDB.suppressionEnabled == true
	setSurfacesActive(enabled)
	fireCallbacks()
end

function Controller:Enable()
	if enabled then
		return
	end
	enabled = true
	local charDB = self:GetCharDB()
	charDB.suppressionEnabled = true
	setSurfacesActive(true)
	fireCallbacks()
end

function Controller:Disable()
	if not enabled then
		return
	end
	enabled = false
	local charDB = self:GetCharDB()
	charDB.suppressionEnabled = false
	setSurfacesActive(false)
	fireCallbacks()
end

function Controller:Toggle()
	if self:IsEnabled() then
		self:Disable()
		NMWQ.MapFilterSync.ApplyForSuppression(false)
	else
		self:Enable()
		NMWQ.MapFilterSync.ApplyForSuppression(true)
	end
end

function Controller:RefreshSurfaces()
	if not enabled then
		return
	end
	for i = 1, #surfaces do
		local surface = surfaces[i]
		if surface.Refresh then
			surface:Refresh()
		end
	end
end
