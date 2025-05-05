local addonName, PDS = ...

-- Initialize Utils namespace
PDS.Utils = {}
local Utils = PDS.Utils

-- Access PeaversCommons utilities
local PeaversCommons = _G.PeaversCommons
local CommonUtils = PeaversCommons.Utils

-- Print a message to the chat frame with addon prefix
function Utils.Print(message)
    if not message then return end
    CommonUtils.Print(PDS, message)
end

-- Debug print only when debug mode is enabled
function Utils.Debug(message)
    if not message then return end
    CommonUtils.Debug(PDS, message)
end

-- Safely access global variables by name
function Utils:GetGlobal(name)
    return CommonUtils.GetGlobal and CommonUtils.GetGlobal(name) or _G[name]
end

-- Format a number as a percentage with 2 decimal places
function Utils:FormatPercent(value)
    return CommonUtils.FormatPercent(value)
end

-- Format a change value with a + or - sign and 2 decimal places
function Utils:FormatChange(value)
    return CommonUtils.FormatChange(value)
end

-- Round a number to the nearest decimal place
function Utils:Round(value, decimals)
    return CommonUtils.Round(value, decimals)
end

-- Check if a table contains a value
function Utils:TableContains(table, value)
    return CommonUtils.TableContains(table, value)
end

-- Format a time duration in seconds into a human-readable string
function Utils:FormatTime(seconds)
    return CommonUtils.FormatTime(seconds)
end

-- Get player info
function Utils:GetPlayerInfo()
    return CommonUtils.GetPlayerInfo()
end

-- Get character key for saved variables
function Utils:GetCharacterKey()
    return CommonUtils.GetCharacterKey()
end
