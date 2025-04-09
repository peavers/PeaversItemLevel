local addonName, PIL = ...

-- Initialize BarManager namespace
PIL.BarManager = {}
local BarManager = PIL.BarManager

-- Collection to store all created bars
BarManager.bars = {}

-- Creates or recreates all player bars
function BarManager:CreateBars(parent)
    -- Clear existing bars
    for _, bar in ipairs(self.bars) do
        bar.frame:Hide()
    end
    self.bars = {}

    local yOffset = 0
    for _, unit in ipairs(PIL.Players.PLAYER_ORDER) do
        local playerName = PIL.Players:GetName(unit)
        local bar = PIL.StatBar:New(parent, playerName, unit)
        bar:SetPosition(0, yOffset)

        local itemLevel = PIL.Players:GetItemLevel(unit)
        -- Pass true for noAnimation to prevent flashing during initial creation
        bar:Update(itemLevel, nil, nil, true)

        -- Ensure the color is properly applied
        bar:UpdateColor()

        table.insert(self.bars, bar)

        -- When barSpacing is 0, position bars exactly barHeight pixels apart
        if PIL.Config.barSpacing == 0 then
            yOffset = yOffset - PIL.Config.barHeight
        else
            yOffset = yOffset - (PIL.Config.barHeight + PIL.Config.barSpacing)
        end
    end

    return math.abs(yOffset)
end

-- Updates all player bars with latest item levels
function BarManager:UpdateAllBars(forceUpdate, noAnimation)
	if not self.previousValues then
		self.previousValues = {}
	end

	-- Track if any player's item level has changed
	local anyValueChanged = false
	local highestItemLevelChanged = false
	local previousHighestItemLevel = PIL.Players.previousHighestItemLevel or 0
	local currentHighestItemLevel = PIL.Players:GetHighestItemLevel()

	-- Check if the highest item level has changed
	if currentHighestItemLevel ~= previousHighestItemLevel then
		highestItemLevelChanged = true
		PIL.Players.previousHighestItemLevel = currentHighestItemLevel
	end

	-- First pass: Check if any values have changed
	for _, bar in ipairs(self.bars) do
		local unit = bar.statType -- In our case, statType is the unit ID
		local value = PIL.Players:GetItemLevel(unit)

		if not self.previousValues[unit] then
			self.previousValues[unit] = 0
		end

		if value ~= self.previousValues[unit] then
			anyValueChanged = true
			-- Store the new value for next comparison
			self.previousValues[unit] = value
		end
	end

	-- Second pass: Update bars as needed
	if anyValueChanged or highestItemLevelChanged or forceUpdate then
		-- If the highest item level changes, update all bars at once with noAnimation
		-- to prevent staggered flashing
		local useNoAnimation = noAnimation or highestItemLevelChanged

		for _, bar in ipairs(self.bars) do
			local unit = bar.statType
			local value = PIL.Players:GetItemLevel(unit)
			local valueChanged = (self.previousValues[unit] and value ~= self.previousValues[unit])

			-- Only update the bar if:
			-- 1. This specific bar's value has changed, OR
			-- 2. The highest item level has changed (affects percentage calculations), OR
			-- 3. A force update is requested
			if valueChanged or highestItemLevelChanged or forceUpdate then
				-- Calculate the change in value (for display purposes)
				local change = 0
				if valueChanged then
					change = value - self.previousValues[unit]
				end

				-- Update the bar with the new value and change, passing noAnimation parameter
				bar:Update(value, nil, change, useNoAnimation)

				-- Ensure the color is properly applied when updating
				bar:UpdateColor()
			end
		end
	end
end

-- Resizes all bars based on current configuration
function BarManager:ResizeBars()
    for _, bar in ipairs(self.bars) do
        bar:UpdateHeight()
        bar:UpdateWidth()
        bar:UpdateTexture()
        bar:UpdateFont()
        bar:UpdateBackgroundOpacity()
        bar:InitTooltip() -- Reinitialize tooltips to ensure they're correctly set up
    end

    -- Return the total height of all bars for frame adjustment
    local totalHeight = #self.bars * PIL.Config.barHeight
    if PIL.Config.barSpacing > 0 then
        totalHeight = totalHeight + (#self.bars - 1) * PIL.Config.barSpacing
    end

    return totalHeight
end

-- Adjusts the frame height based on number of bars and title bar visibility
function BarManager:AdjustFrameHeight(frame, contentFrame, titleBarVisible)
    local barCount = #self.bars
    local contentHeight

    -- When barSpacing is 0, calculate height without spacing
    if PIL.Config.barSpacing == 0 then
        contentHeight = barCount * PIL.Config.barHeight
    else
        contentHeight = barCount * (PIL.Config.barHeight + PIL.Config.barSpacing) - PIL.Config.barSpacing
    end

    if contentHeight == 0 then
        if titleBarVisible then
            frame:SetHeight(20) -- Just title bar
        else
            frame:SetHeight(10) -- Minimal height
        end
    else
        if titleBarVisible then
            frame:SetHeight(contentHeight + 20) -- Add title bar height
        else
            frame:SetHeight(contentHeight) -- Just content
        end
    end

    -- Content frame position is managed by Core:UpdateTitleBarVisibility
    -- to avoid duplicate repositioning that could cause UI glitches
end

-- Gets a bar by its unit ID
function BarManager:GetBar(unit)
    for _, bar in ipairs(self.bars) do
        if bar.statType == unit then
            return bar
        end
    end
    return nil
end

-- Gets the number of visible bars
function BarManager:GetBarCount()
    return #self.bars
end

-- Updates bars with proper sorting
-- This function will either update the existing bars or recreate them
-- depending on whether sorting by item level is enabled
function BarManager:UpdateBarsWithSorting(forceUpdate)
	-- If sorting by item level, we need to ensure proper order
	if PIL.Config.sortOption == "ILVL_DESC" or PIL.Config.sortOption == "ILVL_ASC" then
		-- Resort the players
		PIL.Players:ScanGroup()

		-- Check if we have any "Unknown" names that need updating
		local hasUnknownPlayers = false
		for _, unit in ipairs(PIL.Players.PLAYER_ORDER) do
			local playerName = PIL.Players:GetName(unit)
			if playerName == "Unknown" then
				hasUnknownPlayers = true
				break
			end
		end

		-- If we have unknown players or no bars yet, do a full rebuild
		if hasUnknownPlayers or #self.bars == 0 or forceUpdate then
			if PIL.Core and PIL.Core.contentFrame then
				self:CreateBars(PIL.Core.contentFrame)
				PIL.Core:AdjustFrameHeight()
			end
			return
		end

		-- Create a temporary mapping of unit to bar
		local barsByUnit = {}
		for _, bar in ipairs(self.bars) do
			barsByUnit[bar.statType] = bar
		end

		-- Clear the bar collection but don't destroy the actual bar frames
		local oldBars = self.bars
		self.bars = {}

		-- Reposition bars according to new player order
		local yOffset = 0
		for _, unit in ipairs(PIL.Players.PLAYER_ORDER) do
			local bar = barsByUnit[unit]
			if bar then
				-- Update the name in case it changed
				local playerName = PIL.Players:GetName(unit)
				if bar.name ~= playerName then
					bar.name = playerName
					bar.frame.nameText:SetText(playerName)
				end

				-- Add this bar back to our collection in the correct order
				table.insert(self.bars, bar)

				-- Position bar at the correct offset
				bar:SetPosition(0, yOffset)

				-- Update value without animation during sorting
				local itemLevel = PIL.Players:GetItemLevel(unit)
				bar:Update(itemLevel, nil, nil, true) -- noAnimation = true

				-- Ensure the color is properly applied
				bar:UpdateColor()

				-- When barSpacing is 0, position bars exactly barHeight pixels apart
				if PIL.Config.barSpacing == 0 then
					yOffset = yOffset - PIL.Config.barHeight
				else
					yOffset = yOffset - (PIL.Config.barHeight + PIL.Config.barSpacing)
				end
			else
				-- Create a new bar for this unit
				local playerName = PIL.Players:GetName(unit)
				local newBar = PIL.StatBar:New(PIL.Core.contentFrame, playerName, unit)
				newBar:SetPosition(0, yOffset)

				local itemLevel = PIL.Players:GetItemLevel(unit)
				-- Pass true for noAnimation to prevent flashing
				newBar:Update(itemLevel, nil, nil, true)

				-- Ensure the color is properly applied
				newBar:UpdateColor()

				table.insert(self.bars, newBar)

				-- When barSpacing is 0, position bars exactly barHeight pixels apart
				if PIL.Config.barSpacing == 0 then
					yOffset = yOffset - PIL.Config.barHeight
				else
					yOffset = yOffset - (PIL.Config.barHeight + PIL.Config.barSpacing)
				end
			end
		end

		-- Hide any bars that aren't in the current player list
		for _, bar in ipairs(oldBars) do
			if not tContains(PIL.Players.PLAYER_ORDER, bar.statType) then
				bar.frame:Hide()
			end
		end

		-- Adjust the frame height after reordering
		if PIL.Core then
			PIL.Core:AdjustFrameHeight()
		end
	else
		-- Just update the bars if not sorting by item level
		self:UpdateAllBars(forceUpdate, true) -- true for noAnimation
	end
end

return BarManager
