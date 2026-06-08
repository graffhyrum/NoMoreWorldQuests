local NMWQ = _G.NoMoreWorldQuests

local Slash = {}
NMWQ.Slash = Slash

local function printStatus()
	local on = NMWQ.Controller:IsEnabled()
	DEFAULT_CHAT_FRAME:AddMessage(
		"|cff33cc99No More World Quests|r suppression is "
			.. (on and "|cff00ff00ON|r" or "|cffff6666OFF|r")
	)
end

local function onSlash(msg)
	msg = strtrim(msg or ""):lower()
	if msg == "status" then
		printStatus()
		return
	end
	if msg == "trace on" or msg == "trace" then
		if NMWQ.IntrusionTrace then
			local on = not (NoMoreWorldQuestsDB and NoMoreWorldQuestsDB.debugIntrusion)
			if msg == "trace on" then
				on = true
			end
			NMWQ.IntrusionTrace.SetEnabled(on)
		end
		return
	end
	if msg == "trace off" then
		if NMWQ.IntrusionTrace then
			NMWQ.IntrusionTrace.SetEnabled(false)
		end
		return
	end
	NMWQ.Controller:Toggle()
	printStatus()
end

function Slash:Init()
	SLASH_NOMOREWORLDQUESTS1 = "/nmwq"
	SlashCmdList["NOMOREWORLDQUESTS"] = onSlash
end
