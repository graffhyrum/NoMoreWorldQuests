local NMWQ = _G.NoMoreWorldQuests

local Settings = {}
NMWQ.Settings = Settings

local frame

local function syncCheckbox()
	if not frame or not frame.checkbox then
		return
	end
	frame.checkbox:SetChecked(NMWQ.Controller:IsEnabled())
end

local function buildFrame()
	if frame then
		return frame
	end
	frame = CreateFrame("Frame", "NoMoreWorldQuestsSettings", UIParent, "BackdropTemplate")
	frame:SetSize(360, 220)
	frame:SetPoint("CENTER")
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		tileSize = 32,
		edgeSize = 32,
		insets = { left = 8, right = 8, top = 8, bottom = 8 },
	})
	frame:SetBackdropColor(0, 0, 0, 0.9)
	frame:Hide()
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

	local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
	title:SetPoint("TOP", 0, -16)
	title:SetText("No More World Quests")

	local checkbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
	checkbox:SetPoint("TOPLEFT", 24, -52)
	checkbox.text = checkbox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	checkbox.text:SetPoint("LEFT", checkbox, "RIGHT", 4, 0)
	checkbox.text:SetText("Suppress world quest presentation")
	checkbox:SetScript("OnClick", function(self)
		if self:GetChecked() then
			NMWQ.Controller:Enable()
			NMWQ.MapFilterSync.ApplyForSuppression(true)
		else
			NMWQ.Controller:Disable()
			NMWQ.MapFilterSync.ApplyForSuppression(false)
		end
		syncCheckbox()
	end)
	frame.checkbox = checkbox

	local about = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	about:SetPoint("TOPLEFT", 24, -92)
	about:SetWidth(312)
	about:SetJustifyH("LEFT")
	about:SetText(
		"Hides during-quest world quest UI on the minimap, world map, objective tracker, and intrusion prompts. "
			.. "Completion UI (turn-in, rewards, toasts) is never hidden. "
			.. "v1 — retail only."
	)

	local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -4, -4)

	NMWQ.Controller.RegisterCallback(syncCheckbox)
	return frame
end

function Settings:Toggle()
	buildFrame()
	if frame:IsShown() then
		frame:Hide()
	else
		syncCheckbox()
		frame:Show()
	end
end

function Settings:Hide()
	if frame then
		frame:Hide()
	end
end
