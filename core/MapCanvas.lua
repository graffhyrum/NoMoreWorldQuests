local NMWQ = _G.NoMoreWorldQuests

local MapCanvas = {}
NMWQ.MapCanvas = MapCanvas

function MapCanvas.ForEach(fn)
	if not WorldMapFrame then
		return
	end
	if WorldMapFrame.GetMap then
		local map = WorldMapFrame:GetMap()
		if map then
			fn(map)
		end
	end
	if WorldMapFrame.EnumeratePinsByTemplate then
		fn(WorldMapFrame)
	end
	local providers = WorldMapFrame.dataProviders
	if not providers then
		return
	end
	for _, provider in pairs(providers) do
		if type(provider) == "table" and provider.GetMap then
			local map = provider:GetMap()
			if map then
				fn(map)
			end
		end
	end
end

function MapCanvas.ForEachPinByTemplates(templates, fn)
	MapCanvas.ForEach(function(map)
		if not map.EnumeratePinsByTemplate then
			return
		end
		for t = 1, #templates do
			for pin in map:EnumeratePinsByTemplate(templates[t]) do
				fn(pin)
			end
		end
	end)
end
