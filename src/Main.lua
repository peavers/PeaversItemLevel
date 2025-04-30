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

-- Register slash commands
PeaversCommons.SlashCommands:Register(addonName, "pil", {
    default = function()
        if PIL.Core.frame:IsShown() then
            PIL.Core.frame:Hide()
        else
            PIL.Core.frame:Show()
        end
    end,
})

-- Initialize addon using the PeaversCommons Events module
PeaversCommons.Events:Init(addonName, function()
    -- Initialize configuration
    PIL.Config:Initialize()

    -- Initialize configuration UI
    if PIL.Config.UI and PIL.Config.UI.InitializeOptions then
        PIL.Config.UI:InitializeOptions()
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
end, {
	announceMessage = "Type /pil config for options."
})
