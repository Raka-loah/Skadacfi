--[[
Skada Chat Frame Integrator by Raka@Raka.Rocks
Embed Skada Damage Meter window to a Chat window named 'Skada'

Usage:
1. Create a chat window named 'Skada', not case sensitive, you can use 'SKADA' or 'SkAdA' or whatever.
2. Unsubscribe all chat messages from that chat window. Or just keep them to mess with your own eyes, your call.
3. Reload ui (using slash command /reload of course).
4. Whenever in doubt, reload ui.
]]
local Skada = Skada

--Find Chat Tab named 'Skada'
local skadatabindex = 0
for i = 1, NUM_CHAT_WINDOWS do
	name, _, _, _, _, _, _, _, _, _ = GetChatWindowInfo(i)
	if string.lower(name) == 'skada' then
		skadatabindex = i
		break
	end
end

if skadatabindex ~= 0 then
	local chattab = _G['ChatFrame' .. skadatabindex]
	hooksecurefunc(chattab, 'Show', function()
		for i, win in ipairs(Skada:GetWindows()) do
			if i == 1 then
				win.db.hidden = false
				win:Show()
			end
		end
	end)
	hooksecurefunc(chattab, 'Hide', function()
		for i, win in ipairs(Skada:GetWindows()) do
			if i == 1 then
				win:Hide()
			end
		end
	end)

	local frame = CreateFrame('Frame', nil)
	frame:RegisterEvent('PLAYER_ENTERING_WORLD')
	frame:SetScript('OnEvent', function(self,event)
		local shown = false
		_, _, _, _, _, _, shown, _, _, _ = GetChatWindowInfo(skadatabindex)
		for i, win in ipairs(Skada:GetWindows()) do
			if i == 1 then
				win.db.barwidth = chattab:GetWidth()
				win.bargroup:ClearAllPoints()
				if win.db.enabletitle then
					win.db.background.height = chattab:GetHeight() - win.db.barheight + 3
				else
					win.db.background.height = chattab:GetHeight() + 3
				end
				if win.db.reversegrowth then
					win.bargroup:SetPoint('TOP', chattab, 'TOP', 0, 0)
				else
					win.bargroup:SetPoint('TOP', chattab, 'TOP', 0, (win.db.enabletitle and -1 * win.db.barheight) or 0)
				end
				win.db.hidden = not shown
				win.db.barslocked = true
				win:UpdateDisplay(true)
			end
		end
		frame:UnregisterAllEvents()
	end)
	
else
	print('Please Create a new chat tab called "Skada" then /reload.')
end