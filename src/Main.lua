local addonName, PIL = ...

-- Access the PeaversCommons library
local PeaversCommons = _G.PeaversCommons

-- Initialize addon namespace and modules
PIL = PIL or {}

-- Module namespaces
PIL.Core = {}
PIL.UI = {}
PIL.Utils = {}
PIL.Config = {}
PIL.Players = {}

-- Version information
local function getAddOnMetadata(name, key)
    return C_AddOns.GetAddOnMetadata(name, key)
end

PIL.version = getAddOnMetadata(addonName, "Version") or "1.0.5"
PIL.addonName = addonName
PIL.name = addonName

-- Function to toggle the item level display
function ToggleItemLevelDisplay()
    if PIL.Core.frame:IsShown() then
        PIL.Core.frame:Hide()
    else
        PIL.Core.frame:Show()
    end
end

-- Make the function globally accessible
_G.ToggleItemLevelDisplay = ToggleItemLevelDisplay

-- Register slash commands
PeaversCommons.SlashCommands:Register(addonName, "pil", {
    default = function()
        ToggleItemLevelDisplay()
    end,
})

-- Initialize addon using the PeaversCommons Events module
PeaversCommons.Events:Init(addonName, function()
    -- Initialize configuration
    PIL.Config:Initialize()

    -- Initialize configuration UI
    if PIL.ConfigUI and PIL.ConfigUI.Initialize then
        PIL.ConfigUI:Initialize()
    end

    -- Initialize support UI
    if PIL.SupportUI and PIL.SupportUI.Initialize then
        PIL.SupportUI:Initialize()
    end

    -- Initialize core components
    PIL.Core:Initialize()

    -- Register event handlers
    PeaversCommons.Events:RegisterEvent("GROUP_ROSTER_UPDATE", function(event, ...)
        -- Group composition changed, rescan group
        PIL.Players:ScanGroup()
        -- Update bars with proper sorting
        PIL.BarManager:UpdateBarsWithSorting()
        -- Update frame visibility based on new group state
        PIL.Core:UpdateFrameVisibility()
    end)

    PeaversCommons.Events:RegisterEvent("UNIT_NAME_UPDATE", function(event, unit)
        if unit and (UnitInParty(unit) or UnitInRaid(unit)) then
            PIL.BarManager:UpdateBarsWithSorting(true) -- Force update to refresh names
        end
    end)

    PeaversCommons.Events:RegisterEvent("UNIT_INVENTORY_CHANGED", function()
        PIL.BarManager:UpdateBarsWithSorting()
    end)

    PeaversCommons.Events:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", function()
        PIL.BarManager:UpdateBarsWithSorting()
    end)

    PeaversCommons.Events:RegisterEvent("INSPECT_READY", function()
        PIL.BarManager:UpdateBarsWithSorting()
    end)

    PeaversCommons.Events:RegisterEvent("PLAYER_REGEN_DISABLED", function()
        PIL.Core.inCombat = true
        PIL.Core:UpdateFrameVisibility()
    end)

    PeaversCommons.Events:RegisterEvent("PLAYER_REGEN_ENABLED", function()
        PIL.Core.inCombat = false
        PIL.Core:UpdateFrameVisibility()
    end)

    PeaversCommons.Events:RegisterEvent("PLAYER_LOGOUT", function()
        PIL.Config:Save()
    end)

    -- Set up OnUpdate handler
    PeaversCommons.Events:RegisterOnUpdate(1.0, function(elapsed)
        local interval = PIL.Core.inCombat and PIL.Config.combatUpdateInterval or 3.0
        PIL.BarManager:UpdateAllBars(false, not PIL.Core.inCombat)
    end, "PIL_Update")

    -- Show frame if configured to show on login
    if PIL.Config.showOnLogin then
        PIL.Core.frame:Show()
    else
        PIL.Core.frame:Hide()
    end
    
    -- DIRECT REGISTRATION APPROACH
    -- This ensures the addon appears in Options > Addons regardless of PeaversCommons logic
    C_Timer.After(0.5, function()
        -- Create the main panel (Support UI as landing page)
        local mainPanel = CreateFrame("Frame")
        mainPanel.name = "PeaversItemLevel"
        
        -- Required callbacks
        mainPanel.OnRefresh = function() end
        mainPanel.OnCommit = function() end
        mainPanel.OnDefault = function() end
        
        -- Get addon version
        local version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "1.0.0"
        
        -- Add background image
        local ICON_ALPHA = 0.1
        local iconPath = "Interface\\AddOns\\" .. addonName .. "\\src\\Media\\Icon"
        local largeIcon = mainPanel:CreateTexture(nil, "BACKGROUND")
        largeIcon:SetTexture(iconPath)
        largeIcon:SetPoint("TOPLEFT", mainPanel, "TOPLEFT", 0, 0)
        largeIcon:SetPoint("BOTTOMRIGHT", mainPanel, "BOTTOMRIGHT", 0, 0)
        largeIcon:SetAlpha(ICON_ALPHA)
        
        -- Create header and description
        local titleText = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        titleText:SetPoint("TOPLEFT", 16, -16)
        titleText:SetText("Peavers Item Level")
        titleText:SetTextColor(1, 0.84, 0)  -- Gold color for title
        
        -- Version information
        local versionText = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        versionText:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 0, -8)
        versionText:SetText("Version: " .. version)
        
        -- Support information
        local supportInfo = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        supportInfo:SetPoint("TOPLEFT", 16, -70)
        supportInfo:SetPoint("TOPRIGHT", -16, -70)
        supportInfo:SetJustifyH("LEFT")
        supportInfo:SetText("Tracks and displays item levels for group members. If you enjoy this addon and would like to support its development, or if you need help, stop by the website.")
        supportInfo:SetSpacing(2)
        
        -- Website URL
        local websiteLabel = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        websiteLabel:SetPoint("TOPLEFT", 16, -120)
        websiteLabel:SetText("Website:")
        
        local websiteURL = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        websiteURL:SetPoint("TOPLEFT", websiteLabel, "TOPLEFT", 70, 0)
        websiteURL:SetText("https://peavers.io")
        websiteURL:SetTextColor(0.3, 0.6, 1.0)
        
        -- Additional info
        local additionalInfo = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        additionalInfo:SetPoint("BOTTOMRIGHT", -16, 16)
        additionalInfo:SetJustifyH("RIGHT")
        additionalInfo:SetText("Thank you for using Peavers Addons!")
        
        -- Now create/prepare the settings panel
        local settingsPanel
        
        if PIL.ConfigUI and PIL.ConfigUI.panel then
            -- Use existing ConfigUI panel
            settingsPanel = PIL.ConfigUI.panel
            -- Print debug message to confirm we're using the proper panel
            if PeaversCommons and PeaversCommons.Utils and PeaversCommons.Utils.Debug then
                PeaversCommons.Utils.Debug(PIL, "Using ConfigUI panel with name: " .. (settingsPanel.name or "nil"))
            end
        else
            -- Create a simple settings panel with commands
            settingsPanel = CreateFrame("Frame")
            settingsPanel.name = "Settings"
            
            -- Required callbacks
            settingsPanel.OnRefresh = function() end
            settingsPanel.OnCommit = function() end
            settingsPanel.OnDefault = function() end
            
            -- Add content
            local settingsTitle = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
            settingsTitle:SetPoint("TOPLEFT", 16, -16)
            settingsTitle:SetText("Settings")
            
            -- Add commands section
            local commandsTitle = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
            commandsTitle:SetPoint("TOPLEFT", settingsTitle, "BOTTOMLEFT", 0, -16)
            commandsTitle:SetText("Available Commands:")
            
            local commandsList = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
            commandsList:SetPoint("TOPLEFT", commandsTitle, "BOTTOMLEFT", 10, -8)
            commandsList:SetJustifyH("LEFT")
            commandsList:SetText(
                "/pil - Toggle display\n" ..
                "/pil config - Open settings"
            )
        end
        
        -- Register with the Settings API
        if Settings then
            -- Register main category
            local category = Settings.RegisterCanvasLayoutCategory(mainPanel, mainPanel.name)
            
            -- This is the CRITICAL line to make it appear in Options > Addons
            Settings.RegisterAddOnCategory(category)
            
            -- Store the category
            PIL.directCategory = category
            PIL.directPanel = mainPanel
            
            -- In case the ConfigUI panel wasn't properly initialized before, try to initialize it now
            if not PIL.ConfigUI.panel and PIL.ConfigUI.InitializeOptions then
                PIL.ConfigUI.panel = PIL.ConfigUI:InitializeOptions()
                if PIL.ConfigUI.panel then
                    settingsPanel = PIL.ConfigUI.panel
                end
            end
            
            -- Register settings panel as subcategory
            local settingsCategory = Settings.RegisterCanvasLayoutSubcategory(category, settingsPanel, settingsPanel.name)
            PIL.directSettingsCategory = settingsCategory
            
            -- Debug output
            if PeaversCommons and PeaversCommons.Utils and PeaversCommons.Utils.Debug then
                PeaversCommons.Utils.Debug(PIL, "Direct registration complete")
            end
        end
    end)
end, {
	announceMessage = "Type /pil config for options."
})
