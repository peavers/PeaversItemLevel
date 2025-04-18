local addonName, PIL = ...
local Core = PIL.Core

local updateTimer = 0
local inCombat = false

-- Handles WoW events to update the addon state
function Core:OnEvent(event, ...)
	if event == "GROUP_ROSTER_UPDATE" then
		-- Group composition changed, rescan group
		PIL.Players:ScanGroup()
		-- Update bars with proper sorting
		PIL.BarManager:UpdateBarsWithSorting()
		-- Update frame visibility based on new group state
		self:UpdateFrameVisibility()
	elseif event == "UNIT_NAME_UPDATE" then
		-- A unit's name was updated, update the display
		local unit = ...
		if unit and (UnitInParty(unit) or UnitInRaid(unit)) then
			PIL.BarManager:UpdateBarsWithSorting(true) -- Force update to refresh names
		end
	elseif event == "UNIT_INVENTORY_CHANGED" then
		-- Unit's equipment changed, update bars with proper sorting
		PIL.BarManager:UpdateBarsWithSorting()
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		-- Player's equipment changed, update bars with proper sorting
		PIL.BarManager:UpdateBarsWithSorting()
	elseif event == "INSPECT_READY" then
		-- Inspection data is ready, update bars with proper sorting
		PIL.BarManager:UpdateBarsWithSorting()
	elseif event == "PLAYER_REGEN_DISABLED" then
		inCombat = true
		-- Update frame visibility when entering combat
		self:UpdateFrameVisibility()
	elseif event == "PLAYER_REGEN_ENABLED" then
		inCombat = false
		-- Update frame visibility when leaving combat
		self:UpdateFrameVisibility()
	end
end

-- Handles periodic updates with different intervals for combat/non-combat
function Core:OnUpdate(elapsed)
	updateTimer = updateTimer + elapsed

	-- Longer interval when out of combat to reduce updates
	local interval = inCombat and PIL.Config.combatUpdateInterval or 3.0 -- 3 seconds when out of combat

	if updateTimer >= interval then
		-- Use noAnimation when doing periodic updates
		PIL.BarManager:UpdateAllBars(false, not inCombat) -- Use animations only in combat
		updateTimer = 0
	end
end
