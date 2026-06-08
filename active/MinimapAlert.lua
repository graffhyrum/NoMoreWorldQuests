local NMWQ = _G.NoMoreWorldQuests

local MinimapAlert = {}
NMWQ.MinimapAlert = MinimapAlert

local pulseFrame
local pulseOn = false
local pulseState = false
local elapsed = 0
local PULSE_INTERVAL = 0.6

local function getMinimapButton()
	local icon = LibStub and LibStub("LibDBIcon-1.0", true)
	if icon and icon.GetMinimapButton then
		return icon:GetMinimapButton("NoMoreWorldQuests")
	end
	return nil
end

local function updatePulse(_, dt)
	if not pulseOn then
		return
	end
	elapsed = elapsed + dt
	if elapsed < PULSE_INTERVAL then
		return
	end
	elapsed = 0
	pulseState = not pulseState
	local button = getMinimapButton()
	if button then
		local alpha = pulseState and 1 or 0.35
		button:SetAlpha(alpha)
	end
end

local function stopPulse()
	pulseOn = false
	pulseState = false
	elapsed = 0
	local button = getMinimapButton()
	if button then
		button:SetAlpha(1)
	end
end

local function refreshPulse()
	local shouldPulse = NMWQ.Controller:IsEnabled()
		and NMWQ.ActiveWQZone
		and NMWQ.ActiveWQZone:IsInActiveZone()
	if shouldPulse == pulseOn then
		return
	end
	if shouldPulse then
		pulseOn = true
		elapsed = 0
	else
		stopPulse()
	end
end

function MinimapAlert:Init()
	if pulseFrame then
		return
	end
	pulseFrame = CreateFrame("Frame")
	pulseFrame:SetScript("OnUpdate", updatePulse)
	NMWQ.Controller.RegisterCallback(refreshPulse)
	NMWQ.ActiveWQZone.RegisterListener(refreshPulse)
	NMWQ.ActiveWQZone:Evaluate()
	refreshPulse()
end
