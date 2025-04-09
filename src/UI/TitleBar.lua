local _, PIL = ...
local TitleBar = {}
PIL.TitleBar = TitleBar

-- Creates the title bar with text and version display
function TitleBar:Create(parentFrame)
	local titleBar = CreateFrame("Frame", nil, parentFrame, "BackdropTemplate")
	titleBar:SetHeight(20)
	titleBar:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 0, 0)
	titleBar:SetPoint("TOPRIGHT", parentFrame, "TOPRIGHT", 0, 0)
	titleBar:SetBackdrop({
		bgFile = "Interface\\BUTTONS\\WHITE8X8",
		edgeFile = "Interface\\BUTTONS\\WHITE8X8",
		tile = true, tileSize = 16, edgeSize = 1,
	})

	titleBar:SetBackdropColor(PIL.Config.bgColor.r, PIL.Config.bgColor.g, PIL.Config.bgColor.b, PIL.Config.bgAlpha)
	titleBar:SetBackdropBorderColor(0, 0, 0, PIL.Config.bgAlpha)

	local title = titleBar:CreateFontString(nil, "OVERLAY")
	title:SetFont(PIL.Config.fontFace, PIL.Config.fontSize, PIL.Config.fontOutline)
	title:SetPoint("LEFT", titleBar, "LEFT", 6, 0)
	title:SetText("PIL")
	title:SetTextColor(1, 1, 1)
	if PIL.Config.fontShadow then
		title:SetShadowOffset(1, -1)
	else
		title:SetShadowOffset(0, 0)
	end

	local verticalLine = titleBar:CreateTexture(nil, "ARTWORK")
	verticalLine:SetSize(1, 16)
	verticalLine:SetPoint("LEFT", title, "RIGHT", 5, 0)
	verticalLine:SetColorTexture(0.3, 0.3, 0.3, 0.5)

	local subtitle = titleBar:CreateFontString(nil, "OVERLAY")
	subtitle:SetFont(PIL.Config.fontFace, PIL.Config.fontSize, PIL.Config.fontOutline)
	subtitle:SetPoint("LEFT", verticalLine, "RIGHT", 5, 0)
	subtitle:SetText("v" .. (PIL.version or "1.0.5"))
	subtitle:SetTextColor(0.8, 0.8, 0.8)
	if PIL.Config.fontShadow then
		subtitle:SetShadowOffset(1, -1)
	else
		subtitle:SetShadowOffset(0, 0)
	end

	return titleBar
end

return TitleBar
