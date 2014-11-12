--[[
Skada Chat Frame Integrator by Raka@Raka.Rocks
Embed Skada Damage Meter window to a Chat window named 'Skada'

Usage:
1. Create a chat window named 'Skada', not case sensitive, you can use 'SKADA' or 'SkAdA' or whatever.
2. Unsubscribe all chat messages from that chat window. Or just keep them to mess with your own eyes, your call.
3. Use /skadacfi or /scfi to manually embed.
4. Whenever in doubt, reload ui.
]]
local Skada = Skada

--locale
local L = {}
if (GetLocale() == 'zhCN') then
	L = {
		'SkadaCFI: 请新建一个新的"Skada"聊天窗口，然后执行/skadacfi或/scfi。',
		'SkadaCFI: 整合失败。请手动/skadacfi或/scfi再试一次。',
		'SkadaCFI: 执行整合中……',
		'整合到聊天窗口'
	}
else
	L = {
		'SkadaCFI: Please Create a new chat tab called "Skada" then /skadacfi or /scfi.',
		'SkadaCFI: Integrate failed. Please manually /skadacfi or /scfi to try again.',
		'SkadaCFI: Embedding...',
		'Embed to Chat window'
	}
end

local function GetSkadaChatFrame() --Find Chat Tab named 'Skada'
	local skadatabindex = 0
	for i = 1, NUM_CHAT_WINDOWS do
		name, _, _, _, _, _, _, _, _, _ = GetChatWindowInfo(i)
		if string.lower(name) == 'skada' then
			skadatabindex = i
			break
		end
	end
	
	return skadatabindex
end

local function EmbedSkada(index)
	local shown = false
	local chattab = _G['ChatFrame' .. index]
	_, _, _, _, _, _, shown, _, _, _ = GetChatWindowInfo(index)	-- we don't want skada to overlay the main chat window at start up
	if index == 0 then
		print(L[1])	-- for bastards who never read READMEs
		return
	end	
	if #Skada:GetWindows() == 0 then
		print(L[2])
		return
	end
	for i, win in ipairs(Skada:GetWindows()) do	-- we want it to work with a non-docked, sole chat window too(but why would anyone do this?)
		if i == 1 then				-- so we need to know if 'Skada' chat window is shown or not
			win.db.barwidth = chattab:GetWidth()						-- then we hack the first skada window
			if win.db.enabletitle then
				win.db.background.height = chattab:GetHeight() - win.db.barheight + 3
			else
				win.db.background.height = chattab:GetHeight() + 3
			end
			win.db.hidden = not shown
			win.db.barslocked = true
			Skada:ApplySettings()
			win.bargroup:ClearAllPoints()
			if win.db.reversegrowth then
				win.bargroup:SetPoint('TOP', chattab, 'TOP', 0, 0)
			else
				win.bargroup:SetPoint('TOP', chattab, 'TOP', 0, (win.db.enabletitle and -1 * win.db.barheight) or 0)
			end
			win:UpdateDisplay(true)
		end
	end
end

local function BindSkadaToChatFrame(index)
	local chattab = _G['ChatFrame' .. index]	-- that tab
	chattab:HookScript('OnShow', function()	-- make the first skada window show and hide with the chat window itself
		for i, win in ipairs(Skada:GetWindows()) do	-- neat, isn't it
			if i == 1 then
				if win.db.hidden then
					win.db.hidden = false
				end
				win.bargroup:ClearAllPoints()
				if win.db.reversegrowth then
					win.bargroup:SetPoint('TOP', chattab, 'TOP', 0, 0)
				else
					win.bargroup:SetPoint('TOP', chattab, 'TOP', 0, (win.db.enabletitle and -1 * win.db.barheight) or 0)
				end
				win:Show()
			end
		end
	end)
	chattab:HookScript('OnHide', function()
		for i, win in ipairs(Skada:GetWindows()) do
			if i == 1 then
				win:Hide()
			end
		end
	end)
end

--Try to embed on startup
if GetSkadaChatFrame() ~= 0 then
	local frame = CreateFrame('Frame', nil)				-- to make skada window the same size as the chat window
	frame:RegisterEvent('PLAYER_ENTERING_WORLD')		-- we can't do this before skada windows are loaded, so just wait to the last moment
	frame:SetScript('OnEvent', function(self,event)
		self:UnregisterAllEvents()
		self = nil
		EmbedSkada(GetSkadaChatFrame())
		BindSkadaToChatFrame(GetSkadaChatFrame())	-- job is done
	end)
end

--Manually embed
SLASH_SCFI1, SLASH_SCFI2 = '/skadacfi', '/scfi'
local function aphandler(msg)
	if GetSkadaChatFrame() ~= 0 then
		print(L[3])
		EmbedSkada(GetSkadaChatFrame())
		BindSkadaToChatFrame(GetSkadaChatFrame())
	end
	for i, win in ipairs(Skada:GetWindows()) do
		win:UpdateDisplay(true)
	end
end
SlashCmdList['SCFI'] = aphandler