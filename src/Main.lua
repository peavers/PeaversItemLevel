local addonName, PIL = ...

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

-- Initialize addon when ADDON_LOADED event fires
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Initialize configuration
        PIL.Config:Initialize()

        -- Initialize configuration UI
        if PIL.Config.UI and PIL.Config.UI.InitializeOptions then
            PIL.Config.UI:InitializeOptions()
        end

        -- Initialize core components
        PIL.Core:Initialize()

        -- Register other events after initialization
        PIL.Core:RegisterEvents()

        -- Show frame if configured to show on login
        if PIL.Config.showOnLogin then
            PIL.Core.frame:Show()
        else
            PIL.Core.frame:Hide()
        end

        -- Unregister the ADDON_LOADED event as we don't need it anymore
        self:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_LOGOUT" then
        -- Save configuration on logout
        PIL.Config:Save()
    end
end)
