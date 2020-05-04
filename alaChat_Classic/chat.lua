--[[--
	alex@0
--]]--
-- do return; end
----------------------------------------------------------------------------------------------------
local ADDON, NS = ...;

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
local math, table, string, pairs, type, select, tonumber, unpack = math, table, string, pairs, type, select, tonumber, unpack;
local _G = _G;
----------------------------------------------------------------------------------------------------
local SC_DATA1 = L.SC_DATA1;
local SC_DATA2 = L.SC_DATA2;
local SC_DATA3 = L.SC_DATA3;
if not SC_DATA1 or not SC_DATA2 or not SC_DATA3 then return;end
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------short Channel Name
----------------------------------------------------------------------------------------------------short Channel Name Format
local control_shortChannelName = false;
local backup_shortChannelName = {  };

local short_name_hash = {  };
for _, v in pairs(SC_DATA2) do
	short_name_hash[v[1]] = v[4];
end
local function _ChatFrame_ResolvePrefixedChannelName_NW(communityChannel)
	local prefix, communityChannel = communityChannel:match("(%d+). ([^ ]*)");
	communityChannel = control_shortChannelName and short_name_hash[communityChannel] or communityChannel;
	return prefix .. "." .. ChatFrame_ResolveChannelName(communityChannel);
end
local function _ChatFrame_ResolvePrefixedChannelName_N(communityChannel)
	local prefix, communityChannel = communityChannel:match("(%d+). ([^ ]*)");
	return prefix;
end
local function _ChatFrame_ResolvePrefixedChannelName_W(communityChannel)
	local prefix, communityChannel = communityChannel:match("(%d+). ([^ ]*)");
	communityChannel = control_shortChannelName and short_name_hash[communityChannel] or communityChannel;
	return ChatFrame_ResolveChannelName(communityChannel);
end
local function set_shortChannelNameFormat(value)
	-- do return end
	if value == "NW" then
		_G.ChatFrame_ResolvePrefixedChannelName = _ChatFrame_ResolvePrefixedChannelName_NW;
	elseif value == "N" then
		_G.ChatFrame_ResolvePrefixedChannelName = _ChatFrame_ResolvePrefixedChannelName_N;
	elseif value == "W" then
		_G.ChatFrame_ResolvePrefixedChannelName = _ChatFrame_ResolvePrefixedChannelName_W;
	end
end
FUNC.SETVALUE.shortChannelNameFormat = set_shortChannelNameFormat;

local function shortChannelName_ToggleOn()
	if control_shortChannelName then
		return;
	end
	control_shortChannelName = true;
	for get, str in pairs(SC_DATA1) do
		backup_shortChannelName[get] = _G[get];
		_G[get] = str;
	end
	return control_shortChannelName;
end
local function shortChannelName_ToggleOff()
	if not control_shortChannelName then
		return;
	end
	control_shortChannelName = false;
	for get, str in pairs(backup_shortChannelName) do
		_G[get] = str;
	end
	return control_shortChannelName;
end
FUNC.ON.shortChannelName = shortChannelName_ToggleOn;
FUNC.OFF.shortChannelName = shortChannelName_ToggleOff;
----------------------------------------------------------------------------------------------------level
-- do return end
local control_level = false;
local memCache = {  };
local function cache_MemInfo()
	for i=1,GetNumGuildMembers() do
		local name,rank,rankindex0,level,class,area,_,_,_,_,eClass,ach=GetGuildRosterInfo(i);
		if name then
			name=string.split("-",name);
			memCache[name]=level;
		end
	end
end

local pRealm = GetRealmName();
local _GetPlayerLink = _G.GetPlayerLink;
_G.GetPlayerLink = function(fullName, nameApp, lineId, cType, cTarget)
	if control_level then
		local sender, realm = string.split("-", fullName);
		if not realm or realm == pRealm then
			local level = memCache[sender];
			if level then
				--nameApp = nameApp .. level;
				nameApp = string.gsub(nameApp, sender, sender .. ":" .. level);
			end
		end
		cTarget = cTarget or "";
		return "\124Hplayer:" .. fullName .. ":" .. lineId .. ":" .. cType .. "\124h" .. nameApp .. "\124h";
	else
		return _GetPlayerLink(fullName, nameApp, lineId, cType, cTarget);
	end
end

local repeat_cache=nil;
local function level_ToggleOn()
	if control_level then
		return;
	end
	control_level=true;
	cache_MemInfo();
	repeat_cache=C_Timer.NewTicker(4, cache_MemInfo);
end
local function level_ToggleOff()
	if not control_level then
		return;
	end
	control_level=false;
	if repeat_cache then
		repeat_cache:Cancel();
		repeat_cache = nil;
	end
end
FUNC.ON.level=level_ToggleOn;
FUNC.OFF.level=level_ToggleOff;
----------------------------------------------------------------------------------------------------colored name
FUNC.ON.ColorNameByClass = function()
	SetCVar("chatClassColorOverride", "0");
end
FUNC.OFF.ColorNameByClass = function()
	SetCVar("chatClassColorOverride", "1");
end
----------------------------------------------------------------------------------------------------editBox tab
local control_editBoxTab = false;

local __ChatEdit_CustomTabPressed = ChatEdit_CustomTabPressed;
--local chatType = { "SAY", "EMOTE", "YELL", "GUILD", "OFFICER", "WHISPER", "PARTY", "RAID", "RAID_WARNING", --[["INSTANCE", ]]};
--local chatHeader = { "/s ", "/e ", "/y ", "/g ", "/o ", "/w ", "/p ", "/raid ", "/rw ", "/bg " };
local chatType = { "SAY", "PARTY", "GUILD", "RAID", --[["INSTANCE", ]]};
local chatHeader = { "/s ", "/p ", "/g ", "/raid ", };
local function OnTabPressed(self)
	local cType = self:GetAttribute("chatType");
	if cType ~= "WHISPER" and cType ~= "BN_WHISPER" then
		for i = 1, #chatType do
			if cType == chatType[i] then
				if i == #chatType then
					self:SetAttribute("chatType", chatType[1]);
					ChatEdit_UpdateHeader(self);
					--self:Insert(chatHeader[1]);
					--print(chatType[1]);
				else
					self:SetAttribute("chatType", chatType[i + 1]);
					ChatEdit_UpdateHeader(self);
					--self:Insert(chatHeader[i + 1]);
					--print(chatType[i + 1]);
				end
				return true;
			end
		end
		self:SetAttribute("chatType", "SAY");
		ChatEdit_UpdateHeader(self);
	end
	-- end
end
local function editBoxTab_ToggleOn()
	if not control_editBoxTab then
		for i=1,NUM_CHAT_WINDOWS do
			local editbox=_G["ChatFrame"..i.."EditBox"];
			--editbox:SetScript("OnTabPressed", OnTabPressed);
			_G.ChatEdit_CustomTabPressed = OnTabPressed;
		end
		control_editBoxTab = true;
	end
end
local function editBoxTab_ToggleOff()
	if control_editBoxTab then
		for i=1,NUM_CHAT_WINDOWS do
			local editbox=_G["ChatFrame"..i.."EditBox"];
			--editbox:SetScript("OnTabPressed", ChatEdit_OnTabPressed);
			_G.ChatEdit_CustomTabPressed = __ChatEdit_CustomTabPressed;
		end
		control_editBoxTab = false;
	end
end
FUNC.ON.editBoxTab = editBoxTab_ToggleOn
FUNC.OFF.editBoxTab = editBoxTab_ToggleOff
----------------------------------------------------------------------------------------------------
-- local control_restoreAfterWhisper = false;
FUNC.ON.restoreAfterWhisper = function()
	--control_restoreAfterWhisper = true;
	ChatTypeInfo["WHISPER"].sticky = 0;
	ChatTypeInfo["BN_WHISPER"].sticky = 0;
end
FUNC.OFF.restoreAfterWhisper = function()
	--control_restoreAfterWhisper = false;
	ChatTypeInfo["WHISPER"].sticky = 1;
	ChatTypeInfo["BN_WHISPER"].sticky = 1;
end
----------------------------------------------------------------------------------------------------
-- local restoreAfterChannel = false;
FUNC.ON.restoreAfterChannel = function()
	--restoreAfterChannel = true;
	ChatTypeInfo["CHANNEL"].sticky = 0;
end
FUNC.OFF.restoreAfterChannel = function()
	--restoreAfterChannel = false;
	ChatTypeInfo["CHANNEL"].sticky	= 1;
end
----------------------------------------------------------------------------------------------------shamanColor
local control_shamanColor = false;
local orig_shamanColor_r = RAID_CLASS_COLORS.SHAMAN.r;
local orig_shamanColor_g = RAID_CLASS_COLORS.SHAMAN.g;
local orig_shamanColor_b = RAID_CLASS_COLORS.SHAMAN.b;
local retail_r = 0.0;
local retail_g = 0.4392147064209;
local retail_b = 0.86666476726532;
local function shamanColor_ToggleOn()
	if not control_shamanColor then
		RAID_CLASS_COLORS.SHAMAN.r = retail_r;
		RAID_CLASS_COLORS.SHAMAN.g = retail_g;
		RAID_CLASS_COLORS.SHAMAN.b = retail_b;
		control_shamanColor = true;
	end
end
local function shamanColor_ToggleOff()
	if control_shamanColor then
		RAID_CLASS_COLORS.SHAMAN.r = orig_shamanColor_r;
		RAID_CLASS_COLORS.SHAMAN.g = orig_shamanColor_g;
		RAID_CLASS_COLORS.SHAMAN.b = orig_shamanColor_b;
		control_shamanColor = false;
	end
end
--string.format("\124cff%.2x%.2x%.2x", 0, 0.4392147064209 * 255, 0.86666476726532 * 255)
--string.format("\124cff%.2x%.2x%.2x", 0.96 * 255, 0.55 * 255, 0.73 * 255)
FUNC.ON.shamanColor = shamanColor_ToggleOn;
FUNC.OFF.shamanColor = shamanColor_ToggleOff;
----------------------------------------------------------------------------------------------------
local ICON_PATH = NS.ICON_PATH;

local bfwName = "大脚世界频道";
local bfwLen = strlen(bfwName);
local function find_bfw()
	local t = {GetChannelList()};
	for i = 1, #t/3 do
		if t[i*3-1] == bfwName then
			return t[i*3-2];
		end
	end
	return -1;
end

local control_channel_Ignore_Switch = false;
local control_channel_Ignore = false;
local pcBtn = nil;

local function _cf_channel_Ignore(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, ...)
	if strsub(arg9, 1, bfwLen) ~= bfwName then
	-- if arg8 ~= find_bfw() then
		return true;
	end
	return false, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, ...;
end
local function channel_Ignore_ToggleOn()
	control_channel_Ignore = true;
	if not control_channel_Ignore_Switch then
		return;
	end
	NS.ala_add_message_event_filter("CHAT_MSG_CHANNEL", "channel_Ignore", _cf_channel_Ignore);
		if pcBtn then
			-- pcBtn:SetNormalTexture(ICON_PATH.."pc");
			-- pcBtn:SetPushedTexture(ICON_PATH.."pc");
			pcBtn:GetNormalTexture():SetVertexColor(1.0, 0.0, 0.0, 1.0);
			pcBtn:GetPushedTexture():SetVertexColor(0.25, 0.0, 0.0, 0.5);
			pcBtn:GetHighlightTexture():SetVertexColor(1.0, 0.0, 0.0, 1.0);
		end
end
local function channel_Ignore_ToggleOff(loading)
	control_channel_Ignore = false;
	if not control_channel_Ignore_Switch then
		return;
	end
	NS.ala_remove_message_event_filter("CHAT_MSG_CHANNEL", "channel_Ignore");
	if not loading then
		if pcBtn then
			-- pcBtn:SetNormalTexture(ICON_PATH.."pc");
			-- pcBtn:SetPushedTexture(ICON_PATH.."pc");
			pcBtn:GetNormalTexture():SetVertexColor(1.0, 1.0, 1.0, 1.0);
			pcBtn:GetPushedTexture():SetVertexColor(0.25, 0.25, 0.25, 0.5);
			pcBtn:GetHighlightTexture():SetVertexColor(1.0, 1.0, 1.0, 1.0);
		end
	end
end
local function channel_Ignore_Init()
	pcBtn = CreateFrame("Button", nil, GeneralDockManager);
	pcBtn:SetWidth(28);
	pcBtn:SetHeight(28);
	pcBtn:SetNormalTexture(ICON_PATH.."pc");
	pcBtn:SetPushedTexture(ICON_PATH.."pc");
	pcBtn:GetPushedTexture():SetVertexColor(0.25, 0.25, 0.25, 0.25);
	pcBtn:SetHighlightTexture(ICON_PATH.."pc");
	pcBtn:GetHighlightTexture():SetBlendMode("ADD");
	pcBtn:SetAlpha(0.75);
	pcBtn:SetFrameLevel(ChatFrame1:GetFrameLevel()+1);
	pcBtn:SetMovable(false);
	pcBtn:EnableMouse(true);
	pcBtn:ClearAllPoints();
	pcBtn:SetPoint("TOPRIGHT", ChatFrame1, "TOPRIGHT", -4, -4);
	pcBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	pcBtn:SetScript("OnClick", function()
			if control_channel_Ignore then
				channel_Ignore_ToggleOff();
				FUNC._CONFIGSET("channel_Ignore", false);
			else
				channel_Ignore_ToggleOn();
				FUNC._CONFIGSET("channel_Ignore", true);
			end
		end);
	pcBtn._timer = 0;
	pcBtn._counting = false;
	pcBtn._fadding = false;
	pcBtn._faddingAlpha = 0.75;
	pcBtn:SetScript("OnUpdate", function(_, elapsed)
			if pcBtn._counting then
				pcBtn._timer = pcBtn._timer-elapsed;
				if pcBtn._timer <= 0 then
					pcBtn._fadding = true;
					pcBtn._counting = false;
				end
			end
			if pcBtn._fadding then
				pcBtn._faddingAlpha = pcBtn._faddingAlpha-elapsed*0.5;
				if pcBtn._faddingAlpha <= 0.25 then
					pcBtn:SetAlpha(0.25);
					pcBtn._fadding = false;
				else
					pcBtn:SetAlpha(pcBtn._faddingAlpha);
				end
			end
		end)
	pcBtn:SetScript("OnEnter", function()
			pcBtn._timer = 1;
			pcBtn._counting = false;
			pcBtn:SetAlpha(0.75);
			pcBtn._fadding = false;
			pcBtn._faddingAlpha = 0.75;
		end)
	pcBtn:SetScript("OnLeave", function()
			pcBtn._timer = 1;
			pcBtn._counting = true;
			pcBtn._fadding = false;
			pcBtn._faddingAlpha = 0.75
		end)
	pcBtn:Show();
end
FUNC.INIT.channel_Ignore_Switch = channel_Ignore_Init;
FUNC.ON.channel_Ignore_Switch = function(loading)
	if pcBtn then
		pcBtn:Show();
		control_channel_Ignore_Switch = true;
		if control_channel_Ignore then
			channel_Ignore_ToggleOn(loading);
		else
			channel_Ignore_ToggleOff(loading);
		end
	end
end;
FUNC.OFF.channel_Ignore_Switch = function(loading)
	if pcBtn then
		pcBtn:Hide();
		control_channel_Ignore_Switch = false;
	end
	NS.ala_remove_message_event_filter("CHAT_MSG_CHANNEL", _cf_channel_Ignore);
end

FUNC.ON.channel_Ignore = channel_Ignore_ToggleOn;
FUNC.OFF.channel_Ignore = channel_Ignore_ToggleOff;

local locale_match = GetLocale() == "zhCN" or GetLocale() == "zhTW";
local bfwBtn = nil;
if locale_match then
	--大脚世界频道开关按钮
	local control_bfWorld_Ignore_Switch = false;
	local control_bfWorld_Ignore = false;
	local function _cf_bgWorld_Toggle(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, ...)
		--if control_bfWorld_Ignore and control_bfWorld_Ignore_Switch then
			if strsub(arg9, 1, bfwLen) == bfwName then
			-- if arg8 == find_bfw() then
				return true;
			end
		--end
		return false, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, ...;
	end
	local function bfWorld_Ignore_ToggleOn()
		control_bfWorld_Ignore = true;
		if not control_bfWorld_Ignore_Switch then
			return;
		end
		NS.ala_add_message_event_filter("CHAT_MSG_CHANNEL", "bfWorld_Ignore", _cf_bgWorld_Toggle);
			if bfwBtn then
				-- bfwBtn:SetNormalTexture(ICON_PATH.."bfw");
				-- bfwBtn:SetPushedTexture(ICON_PATH.."bfw");
				bfwBtn:GetNormalTexture():SetVertexColor(1.0, 0.0, 0.0, 1.0);
				bfwBtn:GetPushedTexture():SetVertexColor(0.25, 0.0, 0.0, 0.5);
				bfwBtn:GetHighlightTexture():SetVertexColor(1.0, 0.0, 0.0, 1.0);
			end
	end
	local function bfWorld_Ignore_ToggleOff(loading)
		control_bfWorld_Ignore = false;
		if not control_bfWorld_Ignore_Switch then
			return;
		end
		NS.ala_remove_message_event_filter("CHAT_MSG_CHANNEL", "bfWorld_Ignore");
		if not loading then
			if find_bfw()<0 then
				JoinPermanentChannel(bfwName, nil, DEFAULT_CHAT_FRAME:GetID());
				if not find_bfw() then
					local ticker = C_Timer.NewTicker(0.5, function()
						JoinPermanentChannel(bfwName, nil, DEFAULT_CHAT_FRAME:GetID());
						if not find_bfw() then
							ChatFrame_AddChannel(DEFAULT_CHAT_FRAME, bfwName);
							ticker:Cancel();
						end
					end);
				end
				ChatFrame_AddChannel(DEFAULT_CHAT_FRAME, bfwName);
			end
			if bfwBtn then
				-- bfwBtn:SetNormalTexture(ICON_PATH.."bfw");
				-- bfwBtn:SetPushedTexture(ICON_PATH.."bfw");
				bfwBtn:GetNormalTexture():SetVertexColor(1.0, 1.0, 1.0, 1.0);
				bfwBtn:GetPushedTexture():SetVertexColor(0.25, 0.25, 0.25, 0.5);
				bfwBtn:GetHighlightTexture():SetVertexColor(1.0, 1.0, 1.0, 1.0);
			end
		end
	end
	--alaChatConfig.bfWorld_Ignore

	local function bfWorld_Ignore_Init()
		bfwBtn = CreateFrame("Button", nil, GeneralDockManager);
		bfwBtn:SetWidth(28);
		bfwBtn:SetHeight(28);
		bfwBtn:SetNormalTexture(ICON_PATH.."bfw");
		bfwBtn:SetPushedTexture(ICON_PATH.."bfw");
		bfwBtn:GetPushedTexture():SetVertexColor(0.25, 0.25, 0.25, 0.25);
		bfwBtn:SetHighlightTexture(ICON_PATH.."bfw");
		bfwBtn:GetHighlightTexture():SetBlendMode("ADD");
		bfwBtn:SetAlpha(0.75);
		bfwBtn:SetFrameLevel(ChatFrame1:GetFrameLevel()+1);
		bfwBtn:SetMovable(false);
		bfwBtn:EnableMouse(true);
		bfwBtn:ClearAllPoints();
		bfwBtn:SetPoint("RIGHT", pcBtn, "LEFT", -4, 0);
		bfwBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		bfwBtn:SetScript("OnClick", function()
				if control_bfWorld_Ignore then
					bfWorld_Ignore_ToggleOff();
					FUNC._CONFIGSET("bfWorld_Ignore", false);
				else
					bfWorld_Ignore_ToggleOn();
					FUNC._CONFIGSET("bfWorld_Ignore", true);
				end
			end);
		bfwBtn._timer = 0;
		bfwBtn._counting = false;
		bfwBtn._fadding = false;
		bfwBtn._faddingAlpha = 0.75;
		bfwBtn:SetScript("OnUpdate", function(_, elapsed)
				if bfwBtn._counting then
					bfwBtn._timer = bfwBtn._timer-elapsed;
					if bfwBtn._timer <= 0 then
						bfwBtn._fadding = true;
						bfwBtn._counting = false;
					end
				end
				if bfwBtn._fadding then
					bfwBtn._faddingAlpha = bfwBtn._faddingAlpha-elapsed*0.5;
					if bfwBtn._faddingAlpha <= 0.25 then
						bfwBtn:SetAlpha(0.25);
						bfwBtn._fadding = false;
					else
						bfwBtn:SetAlpha(bfwBtn._faddingAlpha);
					end
				end
			end)
		bfwBtn:SetScript("OnEnter", function()
				bfwBtn._timer = 1;
				bfwBtn._counting = false;
				bfwBtn:SetAlpha(0.75);
				bfwBtn._fadding = false;
				bfwBtn._faddingAlpha = 0.75;
			end)
		bfwBtn:SetScript("OnLeave", function()
				bfwBtn._timer = 1;
				bfwBtn._counting = true;
				bfwBtn._fadding = false;
				bfwBtn._faddingAlpha = 0.75
			end)
		bfwBtn:Show();
	end

	FUNC.INIT.bfWorld_Ignore_Switch = bfWorld_Ignore_Init;
	FUNC.ON.bfWorld_Ignore_Switch = function(loading)
		if bfwBtn then
			bfwBtn:Show();
			control_bfWorld_Ignore_Switch = true;
			if control_bfWorld_Ignore then
				bfWorld_Ignore_ToggleOn(loading);
			else
				bfWorld_Ignore_ToggleOff(loading);
			end
		end
	end;
	FUNC.OFF.bfWorld_Ignore_Switch = function(loading)
		if bfwBtn then
			bfwBtn:Hide();
			control_bfWorld_Ignore_Switch = false;
		end
		NS.ala_remove_message_event_filter("CHAT_MSG_CHANNEL", _cf_bgWorld_Toggle);
	end

	FUNC.ON.bfWorld_Ignore = bfWorld_Ignore_ToggleOn;
	FUNC.OFF.bfWorld_Ignore = bfWorld_Ignore_ToggleOff;
	--FUNC.INIT.bfWorld_Ignore_Switch;
end
FUNC.SETVALUE.channel_Ignore_BtnSize = function(size, init)
	if pcBtn then
		pcBtn:SetSize(size, size);
	end
		
	if bfwBtn then
		bfwBtn:SetSize(size, size);
	end
end
----------------------------------------------------------------------------------------------------
