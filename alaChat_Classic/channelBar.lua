--[[--
	alex@0
--]]--
-- do return; end
----------------------------------------------------------------------------------------------------
local ADDON,NS = ...;

do
	local _G = _G;
	if NS.__fenv == nil then
		NS.__fenv = setmetatable({  },
				{
					__index = _G,
					__newindex = function(t, key, value)
						rawset(t, key, value);
						print("acc assign global", key, value);
						return value;
					end,
				}
			);
	end
	setfenv(1, NS.__fenv);
end

local FUNC = NS.FUNC;
if not FUNC then return;end
local L = NS.L;
if not L then return;end
----------------------------------------------------------------------------------------------------
local math,table,string,pairs,type,select,tonumber,unpack = math,table,string,pairs,type,select,tonumber,unpack;
local _G = _G;
----------------------------------------------------------------------------------------------------
local CB_DATA = L.CHATBAR;
if not CB_DATA then return;end
local SC_DATA2 = L.SC_DATA2
if not SC_DATA2 then return;end
----------------------------------------------------------------------------------------------------
local alaBaseBtn = __alaBaseBtn;
if not alaBaseBtn then
	return;
end

local btnPackIndex = 2;
local ICON_PATH = NS.ICON_PATH;
--------------------------------------------------channel Bar
local channelJoinDelay = 0.5;
local max_change_channel_wait = 6;
local max_try_times = 8;

local CHATTYPE;
local COLOR;
local CHAR;
local INFO;
local PREF;


local function insertEditBox(text)
	local editBox = ChatEdit_ChooseBoxForSend();
	ChatEdit_ActivateChat(editBox);
	editBox:SetText(text);
end
local trying_to_join = false;
local try_times = 0;
local function try_to_join_action(channel)
	JoinPermanentChannel(channel, nil, DEFAULT_CHAT_FRAME:GetID());
	-- JoinPermanentChannel(channel, nil, DEFAULT_CHAT_FRAME:GetID());
	C_Timer.After(channelJoinDelay, function()
		local t = { GetChannelList() };
		-- local str="" for _,v in pairs(t) do str=str..tostring(v);end print(str)
		local editBox = ChatEdit_ChooseBoxForSend();
		for i = 1,#t,3 do
			if t[i+1] == channel then
				if time() - trying_to_join < max_change_channel_wait then
					if editBox:HasFocus() and _chatType == "CHANNEL" and _channelTarget == t[i] then
						ChatEdit_DeactivateChat(editBox);
					else
						if editBox:HasFocus() then
							local text = editBox:GetText():gsub("/[^%s]+%s", "");
							ChatEdit_ActivateChat(editBox);
							editBox:SetText("/"..t[i].." " .. text);
						else
							ChatEdit_ActivateChat(editBox);
							editBox:SetText("/"..t[i].." ");
						end
					end
				else
					print("\124cffff0000JOINED " .. channel .. "\124r");
				end
				trying_to_join = false;
				try_times = 0;
				ChatFrame_AddChannel(DEFAULT_CHAT_FRAME, channel);
				return;
			end
		end
		try_times = try_times + 1;
		if try_times <= max_try_times then
			try_to_join_action(channel);
		else
			trying_to_join = false;
			try_times = 0;
		end
	end);
end
local function try_to_join(channel)
	-- JoinPermanentChannel(channel, nil, DEFAULT_CHAT_FRAME:GetID());
	if trying_to_join then
		return;
	end
	trying_to_join = time();
	try_times = 0;
	try_to_join_action(channel);
end
local function SetEditBoxHeader(idx)
	local chatType = CHATTYPE[idx];
	local editBox = ChatEdit_ChooseBoxForSend();
	if chatType == "CHANNEL" then
		local _chatType = editBox:GetAttribute("chatType");
		local _channelTarget = editBox:GetAttribute("channelTarget");
		local dataIdx = idx - 9;
		local t = { GetChannelList() };
		for i = 1,#t,3 do
			if t[i+1] == SC_DATA2[dataIdx][1] then
				if editBox:HasFocus() and _chatType == "CHANNEL" and _channelTarget == t[i] then
					ChatEdit_DeactivateChat(editBox);
				else
					if editBox:HasFocus() then
						local text = editBox:GetText():gsub("/[^%s]+%s", "");
						ChatEdit_ActivateChat(editBox);
						editBox:SetText("/"..t[i].." " .. editBox:GetText():gsub("^/[^%s]+%s", ""));
						-- ChatEdit_DeactivateChat(editBox);
					else
						ChatEdit_ActivateChat(editBox);
						editBox:SetText("/"..t[i].." ");
					end
					-- ChatEdit_ActivateChat(editBox);
					-- editBox:Insert("/" .. t[i] .. " ");
				end
				return;
			end
		end
		try_to_join(SC_DATA2[dataIdx][1]);
	else
		if chatType == "INSTANCE_CHAT" then
			if C_PvP.IsPVPMap() then
			elseif IsInRaid() then
				chatType = "RAID";
			elseif IsInGroup() then
				chatType = "PARTY";
			else
				return;
			end
		end
		if editBox:HasFocus() and (chatType == editBox:GetAttribute("chatType") or ((chatType == "WHISPER" or chatType == "INSTANCE_CHAT") and editBox:GetText() == PREF[idx])) then
			ChatEdit_DeactivateChat(editBox);
		else
			if editBox:HasFocus() then
				local text = editBox:GetText():gsub("^/[^%s]+%s", "");
				ChatEdit_ActivateChat(editBox);
				editBox:SetText(PREF[idx] .. editBox:GetText():gsub("^/[^%s]+%s", ""));
				-- ChatEdit_DeactivateChat(editBox);
			else
				ChatEdit_ActivateChat(editBox);
				editBox:SetText(PREF[idx]);
			end
			-- ChatEdit_ActivateChat(editBox);
			-- editBox:Insert(PREF[idx]);
		end
	end
end
local ChatTypeInfo = ChatTypeInfo;

local btn = {};
local toggle = {};
local shown = {false,false,false,false,false,false,false,false,false,false};
local function nPrevShown(index)
	local n = 0;
	for i = 1, index - 1 do
		if shown[i] then
			n = n + 1;
		end
	end
	--print(n);
	return n;
end

local control_style = "CHAR";

local function SetStyle(i, style)
	if style == "CHAR" then
		if btn[i] then
			alaBaseBtn:ChangeBtnTexture(btn[i], "char", CHAR[i], nil, COLOR[i]);
		end
	elseif style == "CIRCLE" then
		if btn[i] then
			alaBaseBtn:ChangeBtnTexture(btn[i], ICON_PATH .. "channelBarCircle", nil, nil, COLOR[i]);
		end
	elseif style == "SQUARE" then
		if btn[i] then
			alaBaseBtn:ChangeBtnTexture(btn[i], ICON_PATH .. "channelBarSquare", nil, nil, COLOR[i]);
		end
	else
		return;
	end
end

for idx = 1, 9 do
	toggle[idx] = function(on)
		if (shown[idx] and on) or (not shown[idx] and not on) then
			return
		end
		shown[idx] = on;
		if on then
			if btn[idx] then
				alaBaseBtn:AddBtn(btnPackIndex,nPrevShown(idx) + 1,btn[idx],true,false,true);
			else
				btn[idx] = alaBaseBtn:CreateBtn(
						btnPackIndex,
						nPrevShown(idx) + 1,
						nil,
						"char",
						CHAR[idx],
						nil,
						function(self,button)
							SetEditBoxHeader(idx);
						end,
						{
							INFO[idx],
						},
						nil,
						nil,
						COLOR[idx]
				);
			end
		else
			alaBaseBtn:RemoveBtn(btn[idx],true);
		end
	end
end
for idx = 10, 14 do
	toggle[idx] = function(on)
		if (shown[idx] and on) or (not shown[idx] and not on) then
			return
		end
		shown[idx] = on;
		local dataIdx = idx - 9;
		if on then
			if btn[idx] then
				alaBaseBtn:AddBtn(btnPackIndex,nPrevShown(idx) + 1,btn[idx],true,false,true);
			else
				btn[idx] = alaBaseBtn:CreateBtn(
						btnPackIndex,
						nPrevShown(idx) + 1,
						nil,
						"char",
						CHAR[idx],
						nil,
						function(self,button)
							SetEditBoxHeader(idx);
						end,
						{
							INFO[idx],
						},
						nil,
						nil,
						COLOR[idx]
				);
			end
		else
			alaBaseBtn:RemoveBtn(btn[idx],true);
		end
	end
end

FUNC.ON.channelBarChannel = function(idx)
	toggle[idx](true);
	SetStyle(idx, control_style);
end
FUNC.OFF.channelBarChannel = function(idx)
	toggle[idx](false)
end

local LCONFIG = L.CONFIG;
if not LCONFIG then
	return;
end
FUNC.INIT.channelBarChannel = function()
	CHATTYPE = {
		"SAY",
		"PARTY",
		"RAID",
		"RAID_WARNING",
		"INSTANCE_CHAT",
		"GUILD",
		"YELL",
		"WHISPER",
		"OFFICER",
		"CHANNEL",
		"CHANNEL",
		"CHANNEL",
		"CHANNEL",
		"CHANNEL",
	}
	COLOR = {
		ChatTypeInfo.SAY,
		ChatTypeInfo.PARTY,
		ChatTypeInfo.RAID,
		ChatTypeInfo.RAID_WARNING,
		ChatTypeInfo.INSTANCE_CHAT,
		ChatTypeInfo.GUILD,
		ChatTypeInfo.YELL,
		ChatTypeInfo.WHISPER,
		ChatTypeInfo.OFFICER,
		{ r = 1.0, g = 0.8745, b = 0.7490, },
		{ r = 1.0, g = 0.8745, b = 0.7490, },
		{ r = 1.0, g = 0.8745, b = 0.7490, },
		{ r = 1.0, g = 0.8745, b = 0.7490, },
		{ r = 1.0, g = 0.8745, b = 0.7490, },
	};
	CHAR = {
		CB_DATA.T_SAY,
		CB_DATA.T_PARTY,
		CB_DATA.T_RAID,
		CB_DATA.T_RW,
		CB_DATA.T_INSTANCE_CHAT,
		CB_DATA.T_GUILD,
		CB_DATA.T_YELL,
		CB_DATA.T_WHISPER,
		CB_DATA.T_OFFICER,
		SC_DATA2[1][4],
		SC_DATA2[2][4],
		SC_DATA2[3][4],
		SC_DATA2[4][4],
		"世",
	};
	INFO = {
		string.format("\124cff%.2x%.2x%.2x",ChatTypeInfo.SAY.r*255,ChatTypeInfo.SAY.g*255,ChatTypeInfo.SAY.b*255)..SAY.."\124r",
		string.format("\124cff%.2x%.2x%.2x",ChatTypeInfo.PARTY.r*255,ChatTypeInfo.PARTY.g*255,ChatTypeInfo.PARTY.b*255)..PARTY.."\124r",
		string.format("\124cff%.2x%.2x%.2x",ChatTypeInfo.RAID.r*255,ChatTypeInfo.RAID.g*255,ChatTypeInfo.RAID.b*255)..RAID.."\124r",
		string.format("\124cff%.2x%.2x%.2x",ChatTypeInfo.RAID_WARNING.r*255,ChatTypeInfo.RAID_WARNING.g*255,ChatTypeInfo.RAID_WARNING.b*255)..RAID_WARNING.."\124r",
		string.format("\124cff%.2x%.2x%.2x",ChatTypeInfo.INSTANCE_CHAT.r*255,ChatTypeInfo.INSTANCE_CHAT.g*255,ChatTypeInfo.INSTANCE_CHAT.b*255)..INSTANCE_CHAT.."\124r",
		string.format("\124cff%.2x%.2x%.2x",ChatTypeInfo.GUILD.r*255,ChatTypeInfo.GUILD.g*255,ChatTypeInfo.GUILD.b*255)..GUILD.."\124r",
		string.format("\124cff%.2x%.2x%.2x",ChatTypeInfo.YELL.r*255,ChatTypeInfo.YELL.g*255,ChatTypeInfo.YELL.b*255)..YELL.."\124r",
		string.format("\124cff%.2x%.2x%.2x",ChatTypeInfo.WHISPER.r*255,ChatTypeInfo.WHISPER.g*255,ChatTypeInfo.WHISPER.b*255)..WHISPER.."\124r",
		string.format("\124cff%.2x%.2x%.2x",ChatTypeInfo.OFFICER.r*255,ChatTypeInfo.OFFICER.g*255,ChatTypeInfo.OFFICER.b*255)..OFFICER.."\124r",
		"\124cffffdfbf" .. SC_DATA2[1][1] .."\124r",
		"\124cffffdfbf" .. SC_DATA2[2][1] .."\124r",
		"\124cffffdfbf" .. SC_DATA2[3][1] .."\124r",
		"\124cffffdfbf" .. SC_DATA2[4][1] .."\124r",
		"\124cffffdfbf大脚世界频道\124r",
	};
	PREF = {
		"/s ",
		"/p ",
		"/raid ",
		"/rw ",
		"/bg ",
		"/g ",
		"/y ",
		"/w ",
		"/o ",
	};
	-- for i = 1, 13 do
	-- 	LCONFIG.channelBarChannel[i] = INFO[i];
	-- end
	-- if GetLocale() == "zhCN" or GetLocale() == "zhTW" then
	-- 	LCONFIG.channelBarChannel[14] = INFO[14];
	-- end
end

FUNC.SETVALUE.channelBarStyle = function(style)
	if control_style ~= style then
		if style == "CHAR" then
			for i = 1, 14 do
				if btn[i] then
					alaBaseBtn:ChangeBtnTexture(btn[i], "char", CHAR[i], nil, COLOR[i]);
				end
			end
		elseif style == "CIRCLE" then
			for i = 1, 14 do
				if btn[i] then
					alaBaseBtn:ChangeBtnTexture(btn[i], ICON_PATH .. "channelBarCircle", nil, nil, COLOR[i]);
				end
			end
		elseif style == "SQUARE" then
			for i = 1, 14 do
				if btn[i] then
					alaBaseBtn:ChangeBtnTexture(btn[i], ICON_PATH .. "channelBarSquare", nil, nil, COLOR[i]);
				end
			end
		else
			return;
		end
		control_style = style;
	end
end
FUNC.INIT.channelBarStyle = function()
end

_G.alaChatChannelBarBindingFunc_ToggleChannel = function(channel)
	if channel > 0 and (channel <= 13 or (channel <= 14 and GetLocale() == "zhCN" or GetLocale() == "zhTW")) then
		SetEditBoxHeader(channel);
	end
end

_G.BINDING_HEADER_ALAC_CHANNELBAR = CB_DATA.ALAC_CHANNELBAR;
_G.BINDING_NAME_ALAC_SAY = SAY;
_G.BINDING_NAME_ALAC_PARTY = PARTY;
_G.BINDING_NAME_ALAC_RAID = RAID;
_G.BINDING_NAME_ALAC_RAID_WARING = RAID_WARNING;
_G.BINDING_NAME_ALAC_INSTANCE_CHAT = INSTANCE_CHAT;
_G.BINDING_NAME_ALAC_GUILD = GUILD;
_G.BINDING_NAME_ALAC_YELL = YELL;
_G.BINDING_NAME_ALAC_WHISPER = WHISPER;
_G.BINDING_NAME_ALAC_OFFICER = OFFICER;
_G.BINDING_NAME_ALAC_GENERAL = GENERAL;
_G.BINDING_NAME_ALAC_TRADE = TRADE;
_G.BINDING_NAME_ALAC_LOCALDEFENSE = SC_DATA2[3][1];
_G.BINDING_NAME_ALAC_LOOKINGFORGROUP = SC_DATA2[4][1];
if GetLocale() == "zhCN" or GetLocale() == "zhTW" then
	_G.BINDING_NAME_ALAC_CUSTOM = SC_DATA2[5][1];
else
	_G.BINDING_NAME_ALAC_CUSTOM = "NOTHING TO DO HERE";
end
----------------------------------------------------------------------------------------------------
