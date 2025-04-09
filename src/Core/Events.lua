local addonName, PIL = ...
local Core = PIL.Core

local updateTimer = 0
local inCombat = false

-- Handles WoW events to update the addon state
-- Let's also modify the OnEvent function in Events.lua to handle player name updates
function Core:OnEvent(event, ...)
	if event == "GROUP_ROSTER_UPDATE" then
		-- Group composition changed, rescan group
		PIL.Players:ScanGroup()
		-- Use the new function that handles sorting properly
		PIL.BarManager:UpdateBarsWithSorting()
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
		-- Always show the frame when entering combat if hideOutOfCombat is enabled
		if PIL.Config.hideOutOfCombat and not PIL.Core.frame:IsShown() then
			PIL.Core.frame:Show()
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		inCombat = false
		-- Hide the frame when leaving combat if hideOutOfCombat is enabled
		if PIL.Config.hideOutOfCombat and PIL.Core.frame:IsShown() then
			PIL.Core.frame:Hide()
		end
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
