--[[
Skada Chat Frame Integrator by Raka@Raka.Rocks
Embed Skada Damage Meter window to a Chat window.

Usage:
1. Create chat windows you want Skada window to fit in.
2. Unsubscribe all chat messages from the chat windows you just created, or leave them there to mess with your own eyes, your call.
3. By default, the first Skada window will be embedded into "Skada" chat window, but there're more options now, see below.
3-1. You can manually embed a Skada window to any Chat window you want by using command: /scfi n x , where n is the number of Skada Window, x is the name of the chat window. For example, if you want to embed the second Skada window into Chat window called "Threat", use command /scfi 2 threat .
3-2. The addon will automatically remember this operation and save it to a per-character settings file.
3-3. After that you can use /scfi to embed all windows you previously done embedding.
3-4. If you don't know the numbers of Skada Windows, use command "/scfi stat" to get them.
3-5. If you want to reset all the settings you have done before, use command "/scfi reset" and addon will fall back to its default behaviors after a UI reload.
4. If this addon failed to embed Skada windows, use /skadacfi or /scfi to manually embed.
5. When in doubt, /reload.
]]
local Skada = Skada

if not ScfiDB then
	ScfiDB = {
		[1] = 'skada'
	}
end

--locale
local L = {}
if (GetLocale() == 'zhCN') then
	L = {
		'SkadaCFI: 请新建一个新的"%s"聊天窗口，然后执行/skadacfi或/scfi。',
		'SkadaCFI: 整合失败。请手动/skadacfi或/scfi再试一次。',
		'SkadaCFI: 执行整合中……',
		'SkadaCFI: 尝试整合Skada窗口 %d 到聊天窗口 %s ...',
		'===SCFI:当前Skada窗口===',
		'窗口ID：%d ，窗口标题：%s '
	}
else
	L = {
		'SkadaCFI: Please Create a new chat tab called "%s" then /skadacfi or /scfi.',
		'SkadaCFI: Integrate failed. Please manually /skadacfi or /scfi to try again.',
		'SkadaCFI: Embedding...',
		'SkadaCFI: Trying to embed Skada Window %d to Chat window %s ...',
		'===SCFI: Current Skada Windows===',
		'Window ID： %d , Window Title: %s '
	}
end

local function GetSkadaChatFrame(cname) --Find Chat Tab named cname
	local skadatabindex = 0
	for i = 1, NUM_CHAT_WINDOWS do
		name, _, _, _, _, _, _, _, _, _ = GetChatWindowInfo(i)
		if string.lower(name) == string.lower(cname) then
			skadatabindex = i
			break
		end
	end
	
	if skadatabindex == 0 then
		print(string.format(L[1], cname))
	end
	
	return skadatabindex
end

local function EmbedSkada(index, windex)
	local shown = false
	local chattab = _G['ChatFrame' .. index]
	local sw = Skada:GetWindows()
	_, _, _, _, _, _, shown, _, _, _ = GetChatWindowInfo(index)
	if #sw == 0 then
		print(L[2])
		return
	end
	sw[windex].db.barwidth = chattab:GetWidth()						
	if sw[windex].db.enabletitle then
		sw[windex].db.background.height = chattab:GetHeight() - sw[windex].db.barheight + 3
	else
		sw[windex].db.background.height = chattab:GetHeight() + 3
	end
	sw[windex].db.hidden = not shown
	sw[windex].db.barslocked = true
	Skada:ApplySettings()
	sw[windex].bargroup:ClearAllPoints()
	if sw[windex].db.reversegrowth then
		sw[windex].bargroup:SetPoint('TOP', chattab, 'TOP', 0, 0)
	else
		sw[windex].bargroup:SetPoint('TOP', chattab, 'TOP', 0, (sw[windex].db.enabletitle and -1 * sw[windex].db.barheight) or 0)
	end
	sw[windex]:UpdateDisplay(true)
end

function ShowSkadaWindow(cindex)
	if not cindex then return end
	local chattab = _G['ChatFrame' .. cindex]
	local windex = IDtoSW(cindex)
	local sw = Skada:GetWindows()
	if sw[windex].db.hidden then
		sw[windex].db.hidden = false
	end
	sw[windex].bargroup:ClearAllPoints()
	if sw[windex].db.reversegrowth then
		sw[windex].bargroup:SetPoint('TOP', chattab, 'TOP', 0, 0)
	else
		sw[windex].bargroup:SetPoint('TOP', chattab, 'TOP', 0, (sw[windex].db.enabletitle and -1 * sw[windex].db.barheight) or 0)
	end
	sw[windex]:Show()
end

function HideSkadaWindow(cindex)
	if not cindex then return end
	local windex = IDtoSW(cindex)
	local sw = Skada:GetWindows()
	sw[windex]:Hide()
end

function IDtoSW(cindex)
	for k, v in ipairs(ScfiDB) do
		local i = GetSkadaChatFrame(v)
		if tonumber(i) == tonumber(cindex) then
			return k
		end
	end
	return 0
end

local function BindSkadaToChatFrame(index)
	local chattab = _G['ChatFrame' .. index]	-- that tab
	local sw = Skada:GetWindows()
	chattab:HookScript('OnShow', function(self)
		ShowSkadaWindow(self:GetName():match('[%d-]$'))
	end)
	chattab:HookScript('OnHide', function(self)
		HideSkadaWindow(self:GetName():match('[%d-]$'))
	end)
end

function ScfiCoreFunction()
	if not ScfiDB then return end
	for k, v in ipairs(ScfiDB) do
		local i = GetSkadaChatFrame(v)
		EmbedSkada(i, k)
		BindSkadaToChatFrame(i)	-- job is done
	end
end

--Try to embed on startup
local frame = CreateFrame('Frame', nil)				-- to make skada window the same size as the chat window
frame:RegisterEvent('PLAYER_ENTERING_WORLD')		-- we can't do this before skada windows are loaded, so just wait to the last moment
frame:SetScript('OnEvent', function(self, event)
	ScfiCoreFunction()
	self:UnregisterAllEvents()
	self = nil
end)

--Manually embed
SLASH_SCFI1, SLASH_SCFI2 = '/skadacfi', '/scfi'
local function aphandler(msg)
	local arg1, arg2 = msg:match('^(%S*)%s*(.-)$')
	if string.len(arg1) > 0 and string.len(arg2) > 0 then
		print(string.format(L[4], arg1, arg2))
		local i = GetSkadaChatFrame(arg2)
		if i ~= 0 then
			EmbedSkada(i, tonumber(arg1))
			BindSkadaToChatFrame(i)
			ScfiDB[tonumber(arg1)] = arg2
		else
			print(string.format(L[1], arg2))
		end
	elseif string.lower(arg1) == 'reset' then
		ScfiDB = {
			[1] = 'skada'
		}
		ReloadUI()
	elseif string.lower(arg1) == 'stat' then
		print(L[5])
		for i, win in ipairs(Skada:GetWindows()) do
			print(string.format(L[6], i, win.db.name or 'Skada'))
		end
	else
		print(L[3])
		ScfiCoreFunction()
	end
	for i, win in ipairs(Skada:GetWindows()) do
		win:UpdateDisplay(true)
	end
end
SlashCmdList['SCFI'] = aphandler