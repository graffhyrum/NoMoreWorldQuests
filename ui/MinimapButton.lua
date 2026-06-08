local NMWQ = _G.NoMoreWorldQuests

local MinimapButton = {}
NMWQ.MinimapButton = MinimapButton

local ICON = "Interface\\AddOns\\NoMoreWorldQuests\\assets\\logo\\logo-64.tga"

local function tooltipText(tooltip)
	if not tooltip or not tooltip.AddLine then
		return
	end
	tooltip:AddLine("No More World Quests")
	tooltip:AddLine("Left-click: toggle suppression")
	tooltip:AddLine("Right-click: settings")
	local on = NMWQ.Controller:IsEnabled()
	local status = on and "ON" or "OFF"
	tooltip:AddLine("Suppression: " .. status, on and 0 or 1, on and 1 or 0, on and 0 or 1)
end

local function refreshTooltipIfShown()
	local icon = LibStub("LibDBIcon-1.0", true)
	if not icon then
		return
	end
	local button = icon:GetMinimapButton("NoMoreWorldQuests")
	if not button or not GameTooltip:IsShown() or GameTooltip:GetOwner() ~= button then
		return
	end
	local onEnter = button:GetScript("OnEnter")
	if onEnter then
		onEnter(button)
	end
end

function MinimapButton:Init()
	if self.initialized then
		return
	end
	self.initialized = true

	NoMoreWorldQuestsDB = NoMoreWorldQuestsDB or {}
	NoMoreWorldQuestsDB.minimap = NoMoreWorldQuestsDB.minimap or { hide = false }

	local ldb = LibStub("LibDataBroker-1.1"):NewDataObject("NoMoreWorldQuests", {
		type = "launcher",
		text = "No More World Quests",
		icon = ICON,
		OnClick = function(_, button)
			if button == "RightButton" then
				NMWQ.Settings:Toggle()
			else
				NMWQ.Controller:Toggle()
			end
		end,
		OnTooltipShow = tooltipText,
	})

	local icon = LibStub("LibDBIcon-1.0")
	icon:Register("NoMoreWorldQuests", ldb, NoMoreWorldQuestsDB.minimap)
	icon:Show("NoMoreWorldQuests")

	NMWQ.Controller.RegisterCallback(refreshTooltipIfShown)
end
