local _, PIL = ...
local Core = PIL.Core

-- Register slash command handlers
SLASH_PEAVERSITEMLEVEL1 = "/pil"
SlashCmdList["PEAVERSITEMLEVEL"] = function(msg)
	if msg == "config" or msg == "options" then
		-- Open configuration panel
		if PIL.Config.OpenOptionsCommand then
			PIL.Config.OpenOptionsCommand()
		else
 		-- Open category using the latest API
 		Settings.OpenToCategory("PeaversItemLevel")
		end
	else
		-- Toggle main frame visibility
		if Core.frame:IsShown() then
			Core.frame:Hide()
		else
			Core.frame:Show()
		end
	end
end
