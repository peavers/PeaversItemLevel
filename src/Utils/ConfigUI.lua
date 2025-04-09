local _, PIL = ...
local Config = PIL.Config
local UI = PIL.UI
local ConfigUI = {}

-- Initialize ConfigUI namespace
PIL.Config.UI = ConfigUI

-- Creates and initializes the options panel
function ConfigUI:InitializeOptions()
	if not UI then
		print("ERROR: UI module not loaded. Cannot initialize options.")
		return
	end

	local panel = CreateFrame("Frame")
	panel.name = "PeaversItemLevel"

	local scrollFrame, content = UI:CreateScrollFrame(panel)
	local yPos = 0

	-- Golden ratio for spacing (approximately 1.618)
	local goldenRatio = 1.618
	local baseSpacing = 25
	local sectionSpacing = baseSpacing * goldenRatio -- ~40px

	-- Create header and description
	local title = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", baseSpacing, yPos)
	title:SetText("Peavers Dynamic Stats")
	title:SetTextColor(1, 0.84, 0) -- Gold color for main title
	title:SetFont(title:GetFont(), 24, "OUTLINE")
	yPos = yPos - (baseSpacing * goldenRatio)

	local subtitle = content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	subtitle:SetPoint("TOPLEFT", baseSpacing, yPos)
	subtitle:SetText("Configuration options for the dynamic stats display")
	subtitle:SetFont(subtitle:GetFont(), 14)
	yPos = yPos - sectionSpacing

	-- Add a separator after the header
	local _, newY = UI:CreateSeparator(content, baseSpacing, yPos)
	yPos = newY - baseSpacing


	-- Bar settings section (removed Display Options section as it had no content)

	-- Create bar settings
	yPos = self:CreateBarOptions(content, yPos, baseSpacing, sectionSpacing)

	-- Add a separator between major sections
	local _, newY = UI:CreateSeparator(content, baseSpacing, yPos)
	yPos = newY - baseSpacing

	-- Create visual settings
	yPos = self:CreateVisualOptions(content, yPos, baseSpacing, sectionSpacing)

	-- Update content height based on the last element position
	content:SetHeight(math.abs(yPos) + 50)

	-- Register with the Interface Options using the latest API
	Config.categoryID = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
	Settings.RegisterAddOnCategory(Config.categoryID)

	return panel
end

-- Creates bar settings
function ConfigUI:CreateBarOptions(content, yPos, baseSpacing, sectionSpacing)
	baseSpacing = baseSpacing or 25
	sectionSpacing = sectionSpacing or 40
	local controlIndent = baseSpacing + 15
	local subControlIndent = controlIndent + 15
	local sliderWidth = 400

	-- Bar Settings section header
	local header, newY = UI:CreateSectionHeader(content, "Bar Settings", baseSpacing, yPos)
	header:SetFont(header:GetFont(), 18)
	yPos = newY - 10

	-- Create a container for dimensions settings
	local dimensionsLabel, newY = UI:CreateLabel(content, "Dimensions:", controlIndent, yPos, "GameFontNormalSmall")
	dimensionsLabel:SetTextColor(0.9, 0.9, 0.9)
	yPos = newY - 5

	-- Bar spacing slider
	local spacingContainer = CreateFrame("Frame", nil, content)
	spacingContainer:SetSize(sliderWidth, 50)
	spacingContainer:SetPoint("TOPLEFT", controlIndent, yPos)

	local spacingLabel = spacingContainer:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	spacingLabel:SetPoint("TOPLEFT", 0, 0)
	spacingLabel:SetText("Bar Spacing: " .. Config.barSpacing)

	local spacingSlider = CreateFrame("Slider", "PeaversSpacingSlider", spacingContainer, "OptionsSliderTemplate")
	spacingSlider:SetPoint("TOPLEFT", 0, -20)
	spacingSlider:SetWidth(sliderWidth)
	spacingSlider:SetMinMaxValues(-5, 10)
	spacingSlider:SetValueStep(1)
	spacingSlider:SetValue(Config.barSpacing)

	-- Hide default slider text
	local sliderName = spacingSlider:GetName()
	if sliderName then
		local lowText = _G[sliderName .. "Low"]
		local highText = _G[sliderName .. "High"]
		local valueText = _G[sliderName .. "Text"]

		if lowText then
			lowText:SetText("")
		end
		if highText then
			highText:SetText("")
		end
		if valueText then
			valueText:SetText("")
		end
	end

	spacingSlider:SetScript("OnValueChanged", function(self, value)
		local roundedValue = math.floor(value + 0.5)
		spacingLabel:SetText("Bar Spacing: " .. roundedValue)
		Config.barSpacing = roundedValue
		Config:Save()
		if PIL.BarManager and PIL.Core and PIL.Core.contentFrame then
			PIL.BarManager:CreateBars(PIL.Core.contentFrame)
			PIL.Core:AdjustFrameHeight()
		end
	end)

	yPos = yPos - 55

	-- Bar height slider
	local heightContainer = CreateFrame("Frame", nil, content)
	heightContainer:SetSize(sliderWidth, 50)
	heightContainer:SetPoint("TOPLEFT", controlIndent, yPos)

	local heightLabel = heightContainer:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	heightLabel:SetPoint("TOPLEFT", 0, 0)
	heightLabel:SetText("Bar Height: " .. Config.barHeight)

	local heightSlider = CreateFrame("Slider", "PeaversHeightSlider", heightContainer, "OptionsSliderTemplate")
	heightSlider:SetPoint("TOPLEFT", 0, -20)
	heightSlider:SetWidth(sliderWidth)
	heightSlider:SetMinMaxValues(10, 40)
	heightSlider:SetValueStep(1)
	heightSlider:SetValue(Config.barHeight)

	-- Hide default slider text
	local sliderName = heightSlider:GetName()
	if sliderName then
		local lowText = _G[sliderName .. "Low"]
		local highText = _G[sliderName .. "High"]
		local valueText = _G[sliderName .. "Text"]

		if lowText then
			lowText:SetText("")
		end
		if highText then
			highText:SetText("")
		end
		if valueText then
			valueText:SetText("")
		end
	end

	heightSlider:SetScript("OnValueChanged", function(self, value)
		local roundedValue = math.floor(value + 0.5)
		heightLabel:SetText("Bar Height: " .. roundedValue)
		Config.barHeight = roundedValue
		Config:Save()
		if PIL.BarManager and PIL.Core and PIL.Core.contentFrame then
			PIL.BarManager:CreateBars(PIL.Core.contentFrame)
			PIL.Core:AdjustFrameHeight()
		end
	end)

	yPos = yPos - 55

	-- Frame width slider
	local widthContainer = CreateFrame("Frame", nil, content)
	widthContainer:SetSize(sliderWidth, 50)
	widthContainer:SetPoint("TOPLEFT", controlIndent, yPos)

	local widthLabel = widthContainer:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	widthLabel:SetPoint("TOPLEFT", 0, 0)
	widthLabel:SetText("Frame Width: " .. Config.frameWidth)

	local widthSlider = CreateFrame("Slider", "PeaversWidthSlider", widthContainer, "OptionsSliderTemplate")
	widthSlider:SetPoint("TOPLEFT", 0, -20)
	widthSlider:SetWidth(sliderWidth)
	widthSlider:SetMinMaxValues(150, 400)
	widthSlider:SetValueStep(10)
	widthSlider:SetValue(Config.frameWidth)

	-- Hide default slider text
	local sliderName = widthSlider:GetName()
	if sliderName then
		local lowText = _G[sliderName .. "Low"]
		local highText = _G[sliderName .. "High"]
		local valueText = _G[sliderName .. "Text"]

		if lowText then
			lowText:SetText("")
		end
		if highText then
			highText:SetText("")
		end
		if valueText then
			valueText:SetText("")
		end
	end

	widthSlider:SetScript("OnValueChanged", function(self, value)
		local roundedValue = math.floor(value / 10 + 0.5) * 10
		widthLabel:SetText("Frame Width: " .. roundedValue)
		Config.frameWidth = roundedValue
		Config.barWidth = roundedValue - 20
		Config:Save()
		if PIL.Core and PIL.Core.frame then
			PIL.Core.frame:SetWidth(roundedValue)
			if PIL.BarManager then
				PIL.BarManager:ResizeBars()
			end
		end
	end)

	yPos = yPos - 55

	-- Add a thin separator with more spacing
	local _, newY = UI:CreateSeparator(content, baseSpacing + 15, yPos, 400)
	yPos = newY - 15  -- Increased spacing after separator

	-- Create a container for layout settings
	local layoutLabel, newY = UI:CreateLabel(content, "Layout:", controlIndent, yPos, "GameFontNormalSmall")
	layoutLabel:SetTextColor(0.9, 0.9, 0.9)
	yPos = newY - 8  -- Slightly increased spacing

	-- Group by role checkbox
	local groupByRoleCheckbox, newY = UI:CreateCheckbox(
		content,
		"PeaversGroupByRoleCheckbox",
		"Group Players by Role",
		subControlIndent,
		yPos,
		Config.groupByRole,
		{ 1, 1, 1 },
		function(self)
			Config.groupByRole = self:GetChecked()
			Config:Save()
			if PIL.BarManager and PIL.Core and PIL.Core.contentFrame then
				PIL.BarManager:CreateBars(PIL.Core.contentFrame)
				PIL.Core:AdjustFrameHeight()
			end
		end
	)
	yPos = newY - 12  -- Increased spacing

	-- Add a thin separator
	local _, newY = UI:CreateSeparator(content, baseSpacing + 15, yPos, 400)
	yPos = newY - 15  -- Increased spacing after separator

	-- Create a container for appearance settings
	local appearanceLabel, newY = UI:CreateLabel(content, "Appearance:", controlIndent, yPos, "GameFontNormalSmall")
	appearanceLabel:SetTextColor(0.9, 0.9, 0.9)
	yPos = newY - 8  -- Slightly increased spacing

	-- Bar background opacity slider
	local barBgOpacityContainer = CreateFrame("Frame", nil, content)
	barBgOpacityContainer:SetSize(sliderWidth, 50)
	barBgOpacityContainer:SetPoint("TOPLEFT", controlIndent, yPos)

	local barBgOpacityLabel = barBgOpacityContainer:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	barBgOpacityLabel:SetPoint("TOPLEFT", 0, 0)
	barBgOpacityLabel:SetText("Bar Background Opacity: " .. math.floor(Config.barBgAlpha * 100) .. "%")

	local barBgOpacitySlider = CreateFrame("Slider", "PeaversBarBgOpacitySlider", barBgOpacityContainer, "OptionsSliderTemplate")
	barBgOpacitySlider:SetPoint("TOPLEFT", 0, -20)
	barBgOpacitySlider:SetWidth(sliderWidth)
	barBgOpacitySlider:SetMinMaxValues(0, 1)
	barBgOpacitySlider:SetValueStep(0.05)
	barBgOpacitySlider:SetValue(Config.barBgAlpha)

	-- Hide default slider text
	local sliderName = barBgOpacitySlider:GetName()
	if sliderName then
		local lowText = _G[sliderName .. "Low"]
		local highText = _G[sliderName .. "High"]
		local valueText = _G[sliderName .. "Text"]

		if lowText then
			lowText:SetText("")
		end
		if highText then
			highText:SetText("")
		end
		if valueText then
			valueText:SetText("")
		end
	end

	barBgOpacitySlider:SetScript("OnValueChanged", function(self, value)
		local roundedValue = math.floor(value * 20 + 0.5) / 20
		barBgOpacityLabel:SetText("Bar Background Opacity: " .. math.floor(roundedValue * 100) .. "%")
		Config.barBgAlpha = roundedValue
		Config:Save()
		if PIL.BarManager then
			PIL.BarManager:ResizeBars()
		end
	end)

	yPos = yPos - 55

	-- Add a thin separator with more spacing
	local _, newY = UI:CreateSeparator(content, baseSpacing + 15, yPos, 400)
	yPos = newY - 15  -- Increased spacing after separator

	-- Create a container for item level step settings
	local ilvlStepLabel, newY = UI:CreateLabel(content, "Item Level Progress:", controlIndent, yPos, "GameFontNormalSmall")
	ilvlStepLabel:SetTextColor(0.9, 0.9, 0.9)
	yPos = newY - 8  -- Slightly increased spacing

	-- Item level step percentage slider
	local ilvlStepContainer = CreateFrame("Frame", nil, content)
	ilvlStepContainer:SetSize(sliderWidth, 50)
	ilvlStepContainer:SetPoint("TOPLEFT", controlIndent, yPos)

	local ilvlStepValueLabel = ilvlStepContainer:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	ilvlStepValueLabel:SetPoint("TOPLEFT", 0, 0)
	ilvlStepValueLabel:SetText("Item Level Step: " .. Config.ilvlStepPercentage .. "% per level")

	local ilvlStepSlider = CreateFrame("Slider", "PeaversIlvlStepSlider", ilvlStepContainer, "OptionsSliderTemplate")
	ilvlStepSlider:SetPoint("TOPLEFT", 0, -20)
	ilvlStepSlider:SetWidth(sliderWidth)
	ilvlStepSlider:SetMinMaxValues(0.5, 5)
	ilvlStepSlider:SetValueStep(0.1)
	ilvlStepSlider:SetValue(Config.ilvlStepPercentage)

	-- Hide default slider text
	local sliderName = ilvlStepSlider:GetName()
	if sliderName then
		local lowText = _G[sliderName .. "Low"]
		local highText = _G[sliderName .. "High"]
		local valueText = _G[sliderName .. "Text"]

		if lowText then
			lowText:SetText("")
		end
		if highText then
			highText:SetText("")
		end
		if valueText then
			valueText:SetText("")
		end
	end

	ilvlStepSlider:SetScript("OnValueChanged", function(self, value)
		local roundedValue = math.floor(value * 10 + 0.5) / 10
		ilvlStepValueLabel:SetText("Item Level Step: " .. roundedValue .. "% per level")
		Config.ilvlStepPercentage = roundedValue
		Config:Save()
		if PIL.BarManager then
			-- Force update all bars when the step percentage changes
			PIL.BarManager:UpdateBarsWithSorting(true)
		end
	end)

	-- The problematic step explanation - moved it further down with proper spacing
	yPos = yPos - 55  -- Space after the slider

	-- Add explanation for Item Level Step Percentage with proper spacing and width
	local ilvlStepExplanation = content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	ilvlStepExplanation:SetPoint("TOPLEFT", controlIndent, yPos)
	ilvlStepExplanation:SetWidth(sliderWidth)  -- Use the same width as the slider
	ilvlStepExplanation:SetJustifyH("LEFT")
	ilvlStepExplanation:SetText("Controls how much of the progress bar is filled based on item level differences. " ..
		"Higher values make the bars more sensitive to small item level differences, " ..
		"Lower values make the bars more gradual")

	-- Calculate the height of the explanation text (approximately 3 lines)
	local explanationHeight = 40  -- Estimated height for 3 lines of text
	yPos = yPos - explanationHeight - 15  -- Add extra padding after the explanation

	-- Sort options dropdown container with more space
	local sortContainer = CreateFrame("Frame", nil, content)
	sortContainer:SetSize(400, 60)
	sortContainer:SetPoint("TOPLEFT", subControlIndent, yPos)

	local sortLabel = sortContainer:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	sortLabel:SetPoint("TOPLEFT", 0, 0)
	sortLabel:SetText("Sort Players By")

	local sortOptions = {
		["ILVL_DESC"] = "Item Level (Highest to Lowest)",
		["ILVL_ASC"] = "Item Level (Lowest to Highest)",
		["NAME_ASC"] = "Name (A to Z)",
		["NAME_DESC"] = "Name (Z to A)"
	}

	local currentOption = sortOptions[Config.sortOption] or "Name (A to Z)"

	local sortDropdown = CreateFrame("Frame", "PeaversSortDropdown", sortContainer, "UIDropDownMenuTemplate")
	sortDropdown:SetPoint("TOPLEFT", 0, -20)
	UIDropDownMenu_SetWidth(sortDropdown, 345)
	UIDropDownMenu_SetText(sortDropdown, currentOption)

	UIDropDownMenu_Initialize(sortDropdown, function(self, level)
		local info = UIDropDownMenu_CreateInfo()
		for value, text in pairs(sortOptions) do
			info.text = text
			info.checked = (value == Config.sortOption)
			info.func = function()
				Config.sortOption = value
				UIDropDownMenu_SetText(sortDropdown, text)
				Config:Save()
				-- Update player order and refresh bars
				if PIL.Players then
					PIL.Players:ScanGroup()
					if PIL.BarManager then
						PIL.BarManager:UpdateBarsWithSorting(true)
					end
				end
			end
			UIDropDownMenu_AddButton(info)
		end
	end)

	local newY = yPos - 65
	yPos = newY - 10  -- Added extra spacing after dropdown

	return yPos
end

-- Creates visual settings with improved spacing
function ConfigUI:CreateVisualOptions(content, yPos, baseSpacing, sectionSpacing)
	baseSpacing = baseSpacing or 25
	sectionSpacing = sectionSpacing or 40
	local controlIndent = baseSpacing + 15
	local subControlIndent = controlIndent + 15

	-- Visual Settings section header
	local header, newY = UI:CreateSectionHeader(content, "Visual Settings", baseSpacing, yPos)
	header:SetFont(header:GetFont(), 18)
	yPos = newY - 12  -- Slightly more spacing

	-- Group 1: Layout controls
	local layoutLabel, newY = UI:CreateLabel(content, "Layout Options:", controlIndent, yPos, "GameFontNormalSmall")
	layoutLabel:SetTextColor(0.9, 0.9, 0.9)
	yPos = newY - 8  -- Slightly more spacing

	-- Show title bar checkbox
	local titleBarCheckbox, newY = UI:CreateCheckbox(
		content,
		"PeaversTitleBarCheckbox",
		"Show Title Bar",
		subControlIndent,
		yPos,
		Config.showTitleBar,
		{ 1, 1, 1 },
		function(self)
			Config.showTitleBar = self:GetChecked()
			Config:Save()
			if PIL.Core then
				PIL.Core:UpdateTitleBarVisibility()
			end
		end
	)
	yPos = newY - 3  -- Small spacing between checkboxes

	-- Lock position checkbox
	local lockPositionCheckbox, newY = UI:CreateCheckbox(
		content,
		"PeaversLockPositionCheckbox",
		"Lock Frame Position",
		subControlIndent,
		yPos,
		Config.lockPosition,
		{ 1, 1, 1 },
		function(self)
			Config.lockPosition = self:GetChecked()
			Config:Save()
			if PIL.Core then
				PIL.Core:UpdateFrameLock()
			end
		end
	)
	yPos = newY - 3  -- Small spacing between checkboxes

	-- Hide out of combat checkbox
	local hideOutOfCombatCheckbox, newY = UI:CreateCheckbox(
		content,
		"PeaversHideOutOfCombatCheckbox",
		"Hide When Out of Combat",
		subControlIndent,
		yPos,
		Config.hideOutOfCombat,
		{ 1, 1, 1 },
		function(self)
			Config.hideOutOfCombat = self:GetChecked()
			Config:Save()
			-- Apply the change immediately if out of combat
			if PIL.Core and PIL.Core.frame then
				local inCombat = InCombatLockdown()
				if self:GetChecked() and not inCombat then
					PIL.Core.frame:Hide()
				elseif not self:GetChecked() and not PIL.Core.frame:IsShown() then
					PIL.Core.frame:Show()
				end
			end
		end
	)
	yPos = newY - 12  -- Extra spacing before dropdown

	-- Display mode dropdown container
	local displayModeContainer = CreateFrame("Frame", nil, content)
	displayModeContainer:SetSize(400, 60)
	displayModeContainer:SetPoint("TOPLEFT", subControlIndent, yPos)

	local displayModeLabel = displayModeContainer:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	displayModeLabel:SetPoint("TOPLEFT", 0, 0)
	displayModeLabel:SetText("Display Mode")

	local displayModeOptions = {
		["ALWAYS"] = "Always Show",
		["PARTY_ONLY"] = "Show in Party Only",
		["RAID_ONLY"] = "Show in Raid Only"
	}

	local currentDisplayMode = displayModeOptions[Config.displayMode] or "Always Show"

	local displayModeDropdown = CreateFrame("Frame", "PeaversDisplayModeDropdown", displayModeContainer, "UIDropDownMenuTemplate")
	displayModeDropdown:SetPoint("TOPLEFT", 0, -20)
	UIDropDownMenu_SetWidth(displayModeDropdown, 345)
	UIDropDownMenu_SetText(displayModeDropdown, currentDisplayMode)

	UIDropDownMenu_Initialize(displayModeDropdown, function(self, level)
		local info = UIDropDownMenu_CreateInfo()
		for value, text in pairs(displayModeOptions) do
			info.text = text
			info.checked = (value == Config.displayMode)
			info.func = function()
				Config.displayMode = value
				UIDropDownMenu_SetText(displayModeDropdown, text)
				Config:Save()
				-- Apply the change immediately
				if PIL.Core and PIL.Core.frame then
					PIL.Core:UpdateFrameVisibility()
				end
			end
			UIDropDownMenu_AddButton(info)
		end
	end)

	yPos = yPos - 65 - 10  -- Extra space after dropdown

	-- Add a thin separator with more spacing
	local _, newY = UI:CreateSeparator(content, baseSpacing + 15, yPos, 400)
	yPos = newY - 15  -- More space after separator

	-- Group 2: Background settings
	local bgLabel, newY = UI:CreateLabel(content, "Background:", controlIndent, yPos, "GameFontNormalSmall")
	bgLabel:SetTextColor(0.9, 0.9, 0.9)
	yPos = newY - 8  -- Slightly more spacing

	-- Background opacity slider
	local opacityContainer = CreateFrame("Frame", nil, content)
	opacityContainer:SetSize(400, 50)
	opacityContainer:SetPoint("TOPLEFT", subControlIndent, yPos)

	local opacityLabel = opacityContainer:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	opacityLabel:SetPoint("TOPLEFT", 0, 0)
	opacityLabel:SetText("Opacity: " .. math.floor(Config.bgAlpha * 100) .. "%")

	local opacitySlider = CreateFrame("Slider", "PeaversOpacitySlider", opacityContainer, "OptionsSliderTemplate")
	opacitySlider:SetPoint("TOPLEFT", 0, -20)
	opacitySlider:SetWidth(400)
	opacitySlider:SetMinMaxValues(0, 1)
	opacitySlider:SetValueStep(0.05)
	opacitySlider:SetValue(Config.bgAlpha)

	-- Hide default slider text
	local sliderName = opacitySlider:GetName()
	if sliderName then
		local lowText = _G[sliderName .. "Low"]
		local highText = _G[sliderName .. "High"]
		local valueText = _G[sliderName .. "Text"]

		if lowText then
			lowText:SetText("")
		end
		if highText then
			highText:SetText("")
		end
		if valueText then
			valueText:SetText("")
		end
	end

	opacitySlider:SetScript("OnValueChanged", function(self, value)
		local roundedValue = math.floor(value * 20 + 0.5) / 20
		opacityLabel:SetText("Opacity: " .. math.floor(roundedValue * 100) .. "%")
		Config.bgAlpha = roundedValue
		Config:Save()
		if PIL.Core and PIL.Core.frame then
			PIL.Core.frame:SetBackdropColor(
				Config.bgColor.r,
				Config.bgColor.g,
				Config.bgColor.b,
				Config.bgAlpha
			)
			PIL.Core.frame:SetBackdropBorderColor(0, 0, 0, Config.bgAlpha)
			if PIL.Core.titleBar then
				PIL.Core.titleBar:SetBackdropColor(
					Config.bgColor.r,
					Config.bgColor.g,
					Config.bgColor.b,
					Config.bgAlpha
				)
				PIL.Core.titleBar:SetBackdropBorderColor(0, 0, 0, Config.bgAlpha)
			end
		end
	end)

	yPos = yPos - 55 - 10  -- Extra space after slider

	-- Add a thin separator with more spacing
	local _, newY = UI:CreateSeparator(content, baseSpacing + 15, yPos, 400)
	yPos = newY - 15  -- More space after separator

	-- Group 3: Font selection
	local textStyleLabel, newY = UI:CreateLabel(content, "Text Style:", controlIndent, yPos, "GameFontNormalSmall")
	textStyleLabel:SetTextColor(0.9, 0.9, 0.9)
	yPos = newY - 8  -- Slightly more spacing

	-- Font dropdown container
	local fontContainer = CreateFrame("Frame", nil, content)
	fontContainer:SetSize(400, 60)
	fontContainer:SetPoint("TOPLEFT", subControlIndent, yPos)

	local fontLabel = fontContainer:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	fontLabel:SetPoint("TOPLEFT", 0, 0)
	fontLabel:SetText("Font")

	local fonts = Config:GetFonts()
	local currentFont = fonts[Config.fontFace] or "Default"

	local fontDropdown = CreateFrame("Frame", "PeaversFontDropdown", fontContainer, "UIDropDownMenuTemplate")
	fontDropdown:SetPoint("TOPLEFT", 0, -20)
	UIDropDownMenu_SetWidth(fontDropdown, 345)
	UIDropDownMenu_SetText(fontDropdown, currentFont)

	UIDropDownMenu_Initialize(fontDropdown, function(self, level)
		local info = UIDropDownMenu_CreateInfo()
		for path, name in pairs(fonts) do
			info.text = name
			info.checked = (path == Config.fontFace)
			info.func = function()
				Config.fontFace = path
				UIDropDownMenu_SetText(fontDropdown, name)
				Config:Save()
				if PIL.BarManager and PIL.Core and PIL.Core.contentFrame then
					PIL.BarManager:CreateBars(PIL.Core.contentFrame)
					PIL.Core:AdjustFrameHeight()
				end
			end
			UIDropDownMenu_AddButton(info)
		end
	end)

	yPos = yPos - 65 - 5  -- Extra space after dropdown

	-- Font outline checkbox
	local outlineCheckbox, newY = UI:CreateCheckbox(
		content,
		"PeaversFontOutlineCheckbox",
		"Outlined Font",
		subControlIndent,
		yPos,
		Config.fontOutline == "OUTLINE",
		{ 1, 1, 1 },
		function(self)
			Config.fontOutline = self:GetChecked() and "OUTLINE" or ""
			Config:Save()
			if PIL.BarManager and PIL.Core and PIL.Core.contentFrame then
				PIL.BarManager:CreateBars(PIL.Core.contentFrame)
				PIL.Core:AdjustFrameHeight()
			end
		end
	)
	yPos = newY - 3  -- Small spacing between checkboxes

	-- Font shadow checkbox
	local shadowCheckbox, newY = UI:CreateCheckbox(
		content,
		"PeaversFontShadowCheckbox",
		"Font Shadow",
		subControlIndent,
		yPos,
		Config.fontShadow,
		{ 1, 1, 1 },
		function(self)
			Config.fontShadow = self:GetChecked()
			Config:Save()
			if PIL.BarManager and PIL.Core and PIL.Core.contentFrame then
				PIL.BarManager:CreateBars(PIL.Core.contentFrame)
				PIL.Core:AdjustFrameHeight()
			end
		end
	)
	yPos = newY - 12  -- More space before slider

	-- Font size slider
	local fontSizeContainer = CreateFrame("Frame", nil, content)
	fontSizeContainer:SetSize(400, 50)
	fontSizeContainer:SetPoint("TOPLEFT", subControlIndent, yPos)

	local fontSizeLabel = fontSizeContainer:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	fontSizeLabel:SetPoint("TOPLEFT", 0, 0)
	fontSizeLabel:SetText("Font Size: " .. Config.fontSize)

	local fontSizeSlider = CreateFrame("Slider", "PeaversFontSizeSlider", fontSizeContainer, "OptionsSliderTemplate")
	fontSizeSlider:SetPoint("TOPLEFT", 0, -20)
	fontSizeSlider:SetWidth(400)
	fontSizeSlider:SetMinMaxValues(6, 18)
	fontSizeSlider:SetValueStep(1)
	fontSizeSlider:SetValue(Config.fontSize)

	-- Hide default slider text
	local sliderName = fontSizeSlider:GetName()
	if sliderName then
		local lowText = _G[sliderName .. "Low"]
		local highText = _G[sliderName .. "High"]
		local valueText = _G[sliderName .. "Text"]

		if lowText then
			lowText:SetText("")
		end
		if highText then
			highText:SetText("")
		end
		if valueText then
			valueText:SetText("")
		end
	end

	fontSizeSlider:SetScript("OnValueChanged", function(self, value)
		local roundedValue = math.floor(value + 0.5)
		fontSizeLabel:SetText("Font Size: " .. roundedValue)
		Config.fontSize = roundedValue
		Config:Save()
		if PIL.BarManager and PIL.Core and PIL.Core.contentFrame then
			PIL.BarManager:CreateBars(PIL.Core.contentFrame)
			PIL.Core:AdjustFrameHeight()
		end
	end)

	yPos = yPos - 55 - 10  -- Extra space after slider

	-- Add a thin separator with more spacing
	local _, newY = UI:CreateSeparator(content, baseSpacing + 15, yPos, 400)
	yPos = newY - 15  -- More space after separator

	-- Group 4: Bar texture
	local barAppLabel, newY = UI:CreateLabel(content, "Bar Appearance:", controlIndent, yPos, "GameFontNormalSmall")
	barAppLabel:SetTextColor(0.9, 0.9, 0.9)
	yPos = newY - 8  -- Slightly more spacing

	-- Texture dropdown container
	local textureContainer = CreateFrame("Frame", nil, content)
	textureContainer:SetSize(400, 60)
	textureContainer:SetPoint("TOPLEFT", subControlIndent, yPos)

	local textureLabel = textureContainer:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	textureLabel:SetPoint("TOPLEFT", 0, 0)
	textureLabel:SetText("Bar Texture")

	local textures = Config:GetBarTextures()
	local currentTexture = textures[Config.barTexture] or "Default"

	local textureDropdown = CreateFrame("Frame", "PeaversTextureDropdown", textureContainer, "UIDropDownMenuTemplate")
	textureDropdown:SetPoint("TOPLEFT", 0, -20)
	UIDropDownMenu_SetWidth(textureDropdown, 345)
	UIDropDownMenu_SetText(textureDropdown, currentTexture)

	UIDropDownMenu_Initialize(textureDropdown, function(self, level)
		local info = UIDropDownMenu_CreateInfo()
		for path, name in pairs(textures) do
			info.text = name
			info.checked = (path == Config.barTexture)
			info.func = function()
				Config.barTexture = path
				UIDropDownMenu_SetText(textureDropdown, name)
				Config:Save()
				if PIL.BarManager then
					PIL.BarManager:ResizeBars()
				end
			end
			UIDropDownMenu_AddButton(info)
		end
	end)

	yPos = yPos - 65 - 10  -- Extra space after dropdown

	return yPos
end

-- Opens the configuration panel
function ConfigUI:OpenOptions()
	-- No need to initialize options panel here, it's already initialized in Main.lua
	Settings.OpenToCategory("PeaversItemLevel")
end

-- Attach the ConfigUI to the Config namespace is already done at the top of the file

-- Handler for the /pil config command
PIL.Config.OpenOptionsCommand = function()
	ConfigUI:OpenOptions()
end

return ConfigUI
