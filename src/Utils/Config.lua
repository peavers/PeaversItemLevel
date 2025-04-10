local addonName, PIL = ...

-- Initialize Config namespace with default values
PIL.Config = {
	-- Frame settings
	frameWidth = 250,
	frameHeight = 300,
	framePoint = "RIGHT",
	frameX = -20,
	frameY = 0,
	lockPosition = false,

	-- Bar settings
	barWidth = 230,
	barHeight = 20,
	barSpacing = 2,
	barBgAlpha = 0.7,
	barAlpha = 1.0,

	-- Visual settings
	fontFace = "Fonts\\FRIZQT__.TTF",
	fontSize = 8,
	fontOutline = "OUTLINE",
	fontShadow = false,

	-- Other settings
	barTexture = "Interface\\TargetingFrame\\UI-StatusBar",
	bgAlpha = 0.8,
	bgColor = { r = 0, g = 0, b = 0 },
	updateInterval = 0.5,
	combatUpdateInterval = 0.2,
	showOnLogin = true,
	showTitleBar = true,
	showStats = {},
	customColors = {},
	hideOutOfCombat = false, -- Hide the addon when out of combat
	ilvlStepPercentage = 2.0, -- Percentage per item level difference for progress bar
	sortOption = "NAME_ASC", -- Sorting option: ILVL_DESC, ILVL_ASC, NAME_ASC, NAME_DESC
	groupByRole = false, -- Group players by their role (Tank, Healer, DPS)
	displayMode = "ALWAYS" -- Display mode: ALWAYS, PARTY_ONLY, RAID_ONLY
}

-- Initialize default showStats values
PIL.Config.showStats = {
    ["ITEM_LEVEL"] = true
}

local Config = PIL.Config

-- Saves all configuration values to the SavedVariables database
function Config:Save()
	if not PeaversItemLevelDB then
		PeaversItemLevelDB = {}
	end


	-- Create data to save
	local saveData = {
		fontFace = self.fontFace,
		fontSize = self.fontSize,
		fontOutline = self.fontOutline,
		fontShadow = self.fontShadow,
		framePoint = self.framePoint,
		frameX = self.frameX,
		frameY = self.frameY,
		frameWidth = self.frameWidth,
		barWidth = self.barWidth,
		barHeight = self.barHeight,
		barTexture = self.barTexture,
		barBgAlpha = self.barBgAlpha,
		barAlpha = self.barAlpha,
		bgAlpha = self.bgAlpha,
		bgColor = self.bgColor,
		showStats = self.showStats,
		barSpacing = self.barSpacing,
		showTitleBar = self.showTitleBar,
		lockPosition = self.lockPosition,
		customColors = self.customColors,
		hideOutOfCombat = self.hideOutOfCombat,
		ilvlStepPercentage = self.ilvlStepPercentage,
		sortOption = self.sortOption,
		groupByRole = self.groupByRole,
		displayMode = self.displayMode
	}

	-- Save data to the database
	for key, value in pairs(saveData) do
		PeaversItemLevelDB[key] = value
	end
end

-- Loads settings from a specific profile or database
function Config:LoadSettings(source)
	if not source then
		return
	end

	if source.fontFace then
		self.fontFace = source.fontFace
	end
	if source.fontSize then
		self.fontSize = source.fontSize
	end
	if source.fontOutline then
		self.fontOutline = source.fontOutline
	end
	if source.fontShadow ~= nil then
		self.fontShadow = source.fontShadow
	end
	if source.framePoint then
		self.framePoint = source.framePoint
	end
	if source.frameX then
		self.frameX = source.frameX
	end
	if source.frameY then
		self.frameY = source.frameY
	end
	if source.frameWidth then
		self.frameWidth = source.frameWidth
	end
	if source.barWidth then
		self.barWidth = source.barWidth
	end
	if source.barHeight then
		self.barHeight = source.barHeight
	end
	if source.barTexture then
		self.barTexture = source.barTexture
	end
	if source.barBgAlpha then
		self.barBgAlpha = source.barBgAlpha
	end
	if source.barAlpha then
		self.barAlpha = source.barAlpha
	end
	if source.bgAlpha then
		self.bgAlpha = source.bgAlpha
	end
	if source.bgColor then
		self.bgColor = source.bgColor
	end
	if source.showStats then
		self.showStats = source.showStats
	end
	if source.barSpacing then
		self.barSpacing = source.barSpacing
	end
	if source.showTitleBar ~= nil then
		self.showTitleBar = source.showTitleBar
	end
	if source.lockPosition ~= nil then
		self.lockPosition = source.lockPosition
	end
	if source.customColors then
		self.customColors = source.customColors
	end
	if source.hideOutOfCombat ~= nil then
		self.hideOutOfCombat = source.hideOutOfCombat
	end
	if source.ilvlStepPercentage ~= nil then
		self.ilvlStepPercentage = source.ilvlStepPercentage
	end
	if source.sortOption ~= nil then
		self.sortOption = source.sortOption
	elseif source.sortByIlvl ~= nil then
		-- Convert old boolean setting to new string setting
		self.sortOption = source.sortByIlvl and "ILVL_DESC" or "NAME_ASC"
	end
	if source.groupByRole ~= nil then
		self.groupByRole = source.groupByRole
	end
	if source.displayMode ~= nil then
		self.displayMode = source.displayMode
	end
end

-- Loads configuration values from the SavedVariables database
function Config:Load()
	if not PeaversItemLevelDB then
		return
	end

	-- Load settings directly from the database
	self:LoadSettings(PeaversItemLevelDB)
end

-- Returns a sorted table of available fonts, including those from LibSharedMedia
function Config:GetFonts()
	local fonts = {
		["Fonts\\ARIALN.TTF"] = "Arial Narrow",
		["Fonts\\FRIZQT__.TTF"] = "Default",
		["Fonts\\MORPHEUS.TTF"] = "Morpheus",
		["Fonts\\SKURRI.TTF"] = "Skurri"
	}

	if LibStub and LibStub:GetLibrary("LibSharedMedia-3.0", true) then
		local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")
		if LSM then
			for name, path in pairs(LSM:HashTable("font")) do
				fonts[path] = name
			end
		end
	end

	local sortedFonts = {}
	for path, name in pairs(fonts) do
		table.insert(sortedFonts, { path = path, name = name })
	end

	table.sort(sortedFonts, function(a, b)
		return a.name < b.name
	end)

	local result = {}
	for _, font in ipairs(sortedFonts) do
		result[font.path] = font.name
	end

	return result
end

-- Returns a sorted table of available statusbar textures from various sources
function Config:GetBarTextures()
	local textures = {
		["Interface\\TargetingFrame\\UI-StatusBar"] = "Default",
		["Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar"] = "Skill Bar",
		["Interface\\PVPFrame\\UI-PVP-Progress-Bar"] = "PVP Bar",
		["Interface\\RaidFrame\\Raid-Bar-Hp-Fill"] = "Raid"
	}

	if LibStub and LibStub:GetLibrary("LibSharedMedia-3.0", true) then
		local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")
		if LSM then
			for name, path in pairs(LSM:HashTable("statusbar")) do
				textures[path] = name
			end
		end
	end

	if _G.Details and _G.Details.statusbar_info then
		for i, textureTable in ipairs(_G.Details.statusbar_info) do
			if textureTable.file and textureTable.name then
				textures[textureTable.file] = textureTable.name
			end
		end
	end

	local sortedTextures = {}
	for path, name in pairs(textures) do
		table.insert(sortedTextures, { path = path, name = name })
	end

	table.sort(sortedTextures, function(a, b)
		return a.name < b.name
	end)

	local result = {}
	for _, texture in ipairs(sortedTextures) do
		result[texture.path] = texture.name
	end

	return result
end

-- Initialize the configuration when the addon loads
function Config:Initialize()
    -- Load saved configuration
    self:Load()

    -- Ensure item level stat is in the showStats table
    if self.showStats["ITEM_LEVEL"] == nil then
        -- Enable item level stat by default
        self.showStats["ITEM_LEVEL"] = true
    end


    -- Ensure hideOutOfCombat is disabled by default
    if self.hideOutOfCombat == nil then
        self.hideOutOfCombat = false
    end

    -- Ensure ilvlStepPercentage has a default value
    if self.ilvlStepPercentage == nil then
        self.ilvlStepPercentage = 2.0
    end

    -- Ensure sortOption has a default value
    if self.sortOption == nil then
        self.sortOption = "NAME_ASC"
    end

    -- Ensure groupByRole has a default value
    if self.groupByRole == nil then
        self.groupByRole = false
    end

    -- Ensure displayMode has a default value
    if self.displayMode == nil then
        self.displayMode = "ALWAYS"
    end
end
