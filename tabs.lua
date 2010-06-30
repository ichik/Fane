local Fane = CreateFrame'Frame'
local inherit = GameFontNormalSmall
local _, class = UnitClass('player')
local color = {RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b}
local colorHighlight = {RAID_CLASS_COLORS[class].r / 2.5, RAID_CLASS_COLORS[class].g / 2.5, RAID_CLASS_COLORS[class].b / 2.5}

local updateFS = function(self, inc, flags, ...)
	local fstring = self:GetFontString()

	local font, fontSize = inherit:GetFont()
	if(inc) then
		fstring:SetFont(font, fontSize + 1, flags)
	else
		fstring:SetFont(font, fontSize, flags)
	end

	if((...)) then
		fstring:SetTextColor(...)
	end
end

local OnEnter = function(self)
	local emphasis = _G["ChatFrame"..self:GetID()..'TabFlash']:IsShown()
	updateFS(self, nil, nil, unpack(colorHighlight))
end

local OnLeave = function(self)
	local r, g, b
	local id = self:GetID()
	local emphasis = _G["ChatFrame"..id..'TabFlash']:IsShown()

	if (_G["ChatFrame"..id] == SELECTED_CHAT_FRAME) then
		r, g, b = unpack(colorHighlight)
	elseif emphasis then
		r, g, b = unpack(color)
	else
		r, g, b = unpack(color)
	end

	updateFS(self, nil, nil, r, g, b)
end

local ChatFrame2_SetAlpha = function(self, alpha)
	if(CombatLogQuickButtonFrame_Custom) then
		CombatLogQuickButtonFrame_Custom:SetAlpha(alpha)
	end
end

local ChatFrame2_GetAlpha = function(self)
	if(CombatLogQuickButtonFrame_Custom) then
		return CombatLogQuickButtonFrame_Custom:GetAlpha()
	end
end

local faneifyTab = function(frame, sel)
	local i = frame:GetID()

	if(not frame.Fane) then
		frame.leftTexture:Hide()
		frame.middleTexture:Hide()
		frame.rightTexture:Hide()

		frame.leftSelectedTexture:Hide()
		frame.middleSelectedTexture:Hide()
		frame.rightSelectedTexture:Hide()

		frame.leftSelectedTexture.Show = frame.leftSelectedTexture.Hide
		frame.middleSelectedTexture.Show = frame.middleSelectedTexture.Hide
		frame.rightSelectedTexture.Show = frame.rightSelectedTexture.Hide

		frame.leftHighlightTexture:Hide()
		frame.middleHighlightTexture:Hide()
		frame.rightHighlightTexture:Hide()

		frame:HookScript('OnEnter', OnEnter)
		frame:HookScript('OnLeave', OnLeave)

		frame:SetAlpha(1)

		if(i ~= 2) then
			-- Might not be the best solution, but we avoid hooking into the UIFrameFade
			-- system this way.
			frame.SetAlpha = UIFrameFadeRemoveFrame
		else
			frame.SetAlpha = ChatFrame2_SetAlpha
			frame.GetAlpha = ChatFrame2_GetAlpha

			-- We do this here as people might be using AddonLoader together with Fane.
			if(CombatLogQuickButtonFrame_Custom) then
				CombatLogQuickButtonFrame_Custom:SetAlpha(.4)
			end
		end

		frame.Fane = true
	end

	-- We can't trust sel. :(
	if(i == SELECTED_CHAT_FRAME:GetID()) then
		updateFS(frame, nil, nil, unpack(colorHighlight))
	else
		updateFS(frame, nil, nil, unpack(color))
	end
end

hooksecurefunc('FCF_StartAlertFlash', function(frame)
	local tab = _G['ChatFrame' .. frame:GetID() .. 'Tab']
	updateFS(tab, true, nil, 1, 0, 0)
end)

hooksecurefunc('FCFTab_UpdateColors', faneifyTab)

for i=1,7 do
	faneifyTab(_G['ChatFrame' .. i .. 'Tab'])
end

function Fane:ADDON_LOADED(event, addon)
	if(addon == 'Blizzard_CombatLog') then
		self:UnregisterEvent(event)
		self[event] = nil

		return CombatLogQuickButtonFrame_Custom:SetAlpha(.4)
	end
end
Fane:RegisterEvent'ADDON_LOADED'

Fane:SetScript('OnEvent', function(self, event, ...)
	return self[event](self, event, ...)
end)
