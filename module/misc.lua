
local __addon, __private = ...;
local L = __private.L;

local next = next;
local select = select;
local hooksecurefunc = hooksecurefunc;
local strtrim, strsplit, strupper, strsub, strmatch, gsub = string.trim, string.split, string.upper, string.sub, string.match, string.gsub;
local tremove, wipe = table.remove, table.wipe;
local tostring = tostring;
local C_Timer = C_Timer;
local GetChannelName = GetChannelName;
local IsInGroup, IsInRaid = IsInGroup, IsInRaid;
local GetCVar, SetCVar = GetCVar, SetCVar;
local GameTooltip = GameTooltip;
local ChatTypeInfo = ChatTypeInfo;
local LE_PARTY_CATEGORY_HOME, LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_HOME, LE_PARTY_CATEGORY_INSTANCE;
local _G = _G;
local LSM = LibStub("LibSharedMedia-3.0");

local __misc = {  };
local _db = {  };

local _tLineCache = {  };
local _tHistory = {  };_G._tHistory = _tHistory
local _nHistory = 0;
local _pHistory = 0;

if __private.__is_dev then
	__private:BuildEnv("misc");
end

-->		Data
	local ColorTable = {  };
	if ITEM_QUALITY_COLORS ~= nil then
		local i = 0;
		while true do
			local color = ITEM_QUALITY_COLORS[i];
			if color == nil then
				break;
			end
			local str = tostring(i);
			ColorTable[str] = color.hex;
			ColorTable[color.hex] = str;
			i = i + 1;
		end
	else
		local i = 0;
		while true do
			local r, g, b, hex = GetItemQualityColor(i);
			if hex == nil or ColorTable[hex] ~= nil then
				break;
			end
			local str = tostring(i);
			ColorTable[hex] = str;
			hex = "|c" .. hex;
			ColorTable[str] = hex;
			ColorTable[hex] = str;
			i = i + 1;
		end
	end
	local CrippledChannelHash = {
		[GENERAL] = true,
		[LOOK_FOR_GROUP] = true,
	};
-->

-->		SendFilter
	local function SendFilterReplacer(pat, color, Type, body, text)
		if Type == "item" then
			body = gsub(body, ":[0:]+$", "");
			if strmatch(body, "^:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d$") then
				body = gsub(strsub(body, 1, -2), ":[0:]+$", "");
			end
			local _, _, quality = GetItemInfo(pat);
			return text .. "#" .. (quality or ColorTable[color] or "-1") .. "i" .. body .. "#";
		elseif Type == "spell" then
			return text .. "#0s" .. body .. "#";
		else
			return pat;
		end
	end
	local function SendFilter(msg)
		return gsub(msg, "((|cff%x%x%x%x%x%x)|H([a-z]+)(:[:0-9%-]+)|h(%[[^|]+%])|h|r)", SendFilterReplacer);
	end

	local __SendChatMessage = nil;
	local function HyperlinkSendChatMessage(text, channel, lang, target)
		channel = strupper(channel);
		if _db.ChatHyperlink and channel == "CHANNEL" then
			local _, name = GetChannelName(target);
			if name ~= nil and CrippledChannelHash[strsplit(" ", name)] then
				return __SendChatMessage(SendFilter(text) or text, channel, lang, target);
			end
		end
		return __SendChatMessage(text, channel, lang, target);
	end
	local __BNSendWhisper = nil;
	local function HyperlinkBNSendWhisper(presenceID, text, ...)
		__BNSendWhisper(presenceID, _db.ChatHyperlink and SendFilter(text) or text, ...);
	end
	local __BNSendConversationMessage = nil;
	local function HyperlinkBNSendConversationMessage(target, text, ...)
		__BNSendConversationMessage(target, _db.ChatHyperlink and SendFilter(text) or text, ...);
	end
-->

-->		MessageFilter
	local function ChatMessageFilterReplacer(name, colorID, Type, body)
		if Type == "i" then
			local color = ColorTable[colorID] or "|cffff0000";
			return color .. "|Hitem" .. body .. "|h[" .. name .. "]|h|r";
		else
		end
	end
	local function ChatMessageFilter(self, event, msg, arg2, arg3, arg4, arg5, arg6, arg7, arg8, channelName, arg10, line, ...)
		local new = _tLineCache[line];
		if new == false then
			return false;
		elseif new ~= nil then
			return false, new, arg2, arg3, arg4, arg5, arg6, arg7, arg8, channelName, arg10, line, ...;
		elseif CrippledChannelHash[strsplit(" ", channelName)] then
			new = gsub(msg, "%[([^#]+)%]#(-*[0-9]+)([is])([0-9:]+)#", ChatMessageFilterReplacer);
			if new ~= msg then
				_tLineCache[line] = new;
				return false, new, arg2, arg3, arg4, arg5, arg6, arg7, arg8, channelName, arg10, line, ...;
			else
				_tLineCache[line] = false;
				return false;
			end
		else
			_tLineCache[line] = false;
			return false;
		end
	end
-->

-->		Method
	local function InitFilteredStrPatList()
	end
	--
	---------------- > Show tooltips when hovering a link in chat (credits to Adys for his LinkHover)
	local LinkHoverType = {
		["achievement"] = true,
		["enchant"] = true,
		["glyph"] = true,
		["item"] = true,
		["quest"] = true,
		["spell"] = true,
		["talent"] = true,
		["unit"] = true,
	};
	local function _OnHyperlinkEnter(_this, linkData, link)
		local t = linkData:match("^(.-):");
		if LinkHoverType[t] then
			GameTooltip:SetOwner(_this, "ANCHOR_RIGHT");
			GameTooltip:SetHyperlink(link);
			GameTooltip:Show();
		end
	end
	local function _OnHyperlinkLeave(_this, linkData, link)
		if GameTooltip:IsOwned(_this) then
			GameTooltip:Hide();
		end
	end
	--
	local function UpdateCache()
		_tLineCache = {  };
		C_Timer.After(30.0, UpdateCache);
	end
	--
	local _ChatEdit_CustomTabPressed = _G.ChatEdit_CustomTabPressed;
	local ChatTypeHeader = {
		SAY = "/s ",
		YELL = "/y ",
		WHISPER = "/w ",
		PARTY = "/p ",
		GUILD = "/g ",
		RAID = "/raid ",
		INSTANCE = "/bg ",
	};
	local ChatTypeSequenceList = {
		[1] = { "SAY", "YELL", "WHISPER", "PARTY", "GUILD", "RAID", "INSTANCE", },
		[2] = { "SAY", "YELL", "WHISPER", "PARTY", "GUILD", "RAID",             },
		[3] = { "SAY", "YELL", "WHISPER", "PARTY", "GUILD",         "INSTANCE", },
		[4] = { "SAY", "YELL", "WHISPER", "PARTY", "GUILD",                     },
		[5] = { "SAY", "YELL", "WHISPER",          "GUILD",         "INSTANCE", },
		[6] = { "SAY", "YELL", "WHISPER",          "GUILD",                     },
	};
	for index, val in next, ChatTypeSequenceList do
		val["#"] = #val;
		for i = 1, val["#"] do
			val[val[i]] = i;
		end
	end
	local function ChatFrameEditBox_OnTabPressed(self)
		local seq = nil;
		if IsInRaid(LE_PARTY_CATEGORY_HOME) then
			if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
				seq = ChatTypeSequenceList[1];
			else
				seq = ChatTypeSequenceList[2];
			end
		elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
			if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
				seq = ChatTypeSequenceList[3];
			else
				seq = ChatTypeSequenceList[4];
			end
		else
			if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
				seq = ChatTypeSequenceList[5];
			else
				seq = ChatTypeSequenceList[6];
			end
		end
		local raw = self:GetText();
		local trimmed = strupper(strtrim(raw));
		local chatType = (trimmed == "/W" or trimmed == "/WHISPER") and "WHISPER" or self:GetAttribute("chatType");
		local i = (seq[chatType] or 0) + 1; if i > seq["#"] then i = 1; end
		local to = seq[i];
		if to == "WHISPER" and trimmed ~= "" then
			to = seq[i + 1];
			if to == "WHISPER" or to == nil then
				return;
			end
		end
		self:SetText(ChatTypeHeader[to] .. gsub(raw, "^/[^ ]+[ ]*", ""));
		return true;
	end
	local function hookAddHistoryLine(self, text)
		if text ~= nil and text ~= "" then
			if _nHistory > 0 then
				for index = 1, _nHistory do
					if _tHistory[index] == text then
						_nHistory = _nHistory - 1;
						tremove(_tHistory, index);
						break;
					end
				end
			end
			_nHistory = _nHistory + 1;
			_pHistory = _nHistory + 1;
			_tHistory[_nHistory] = text;
		end
	end
	-- local function hookClearHistory(self)
	-- end
	local function EditBoxOnArrowPressed(self, key)
		if _nHistory > 0 then
			if key == "UP" then
				_pHistory = _pHistory - 1;
				if _pHistory <= 0 then
					_pHistory = _nHistory;
				end
			elseif key == "DOWN" then
				_pHistory = _pHistory + 1;
				if _pHistory > _nHistory then
					_pHistory = 1;
				end
			else
				return;
			end
			self:SetText(_tHistory[_pHistory]);
		end
	end
-->

-->		Init
	local B_Initialized = false;
	local function Init()
		B_Initialized = true;
	end
	local B_InitializedHistory = false;
	local function InitHistory()
		B_InitializedHistory = true;
		local __chatFrames = __private.__chatFrames;
		for index = 1, NUM_CHAT_WINDOWS do
			local eb = __chatFrames[index].editBox;
			if eb ~= nil then
				hooksecurefunc(eb, "AddHistoryLine", hookAddHistoryLine);
				-- hooksecurefunc(eb, "ClearHistory", hookClearHistory);
				if _db.ArrowHistory then
					eb:SetScript("OnArrowPressed", EditBoxOnArrowPressed);
				end
			end
		end
	end
	local B_InitializedChatHyperLink = false;
	local function InitChatHyperLink()
		B_InitializedChatHyperLink = true;
		__SendChatMessage = _G.SendChatMessage;
		_G.SendChatMessage = HyperlinkSendChatMessage;
		-- __BNSendWhisper = _G.BNSendWhisper;
		-- _G.BNSendWhisper = HyperlinkBNSendWhisper;
		-- __BNSendConversationMessage = _G.BNSendConversationMessage;
		-- _G.BNSendConversationMessage = HyperlinkBNSendConversationMessage;
		UpdateCache();
	end
-->

-->		Module
	function __misc.Font(value, loading)
		local ChatFrames = __private.__chatFrames;
		for _, F in next, ChatFrames do
			local _, size, flag = F:GetFont();
			F:SetFont(value, size, flag);
		end
	end
	function __misc.FontFlag(value, loading)
		if value == "none" then
			value = "";
		end
		local ChatFrames = __private.__chatFrames;
		for _, F in next, ChatFrames do
			local font, size, _ = F:GetFont();
			F:SetFont(font, size, value);
		end
	end
	local _ChatFrame2SetClampRectInsets = nil;
	function __misc.ChatFrameToBorder(value, loading)
		if value then
			local ChatFrames = __private.__chatFrames;
			for _, F in next, ChatFrames do
				F:SetClampRectInsets(0, 0, 52, 0);
			end
			if _ChatFrame2SetClampRectInsets == nil then
				_ChatFrame2SetClampRectInsets = ChatFrame2.SetClampRectInsets;
				hooksecurefunc(ChatFrame2, "SetClampRectInsets", function(self)
					if _db.ChatFrameToBorder then
						_ChatFrame2SetClampRectInsets(self, 0, 0, 52, 0);
					end
				end);
			end
		elseif not loading then
			local ChatFrames = __private.__chatFrames;
			for _, F in next, ChatFrames do
				F:SetClampRectInsets(-35, -35, 52, -50);
			end
		end
	end
	function __misc.ColoredPlayerName(value, loading)
		local to = value and "0" or "1";
		if GetCVar("chatClassColorOverride") ~= to then
			SetCVar("chatClassColorOverride", to);
		end
		--	wotlk
		if __private.__toc > 30000 and __private.__toc < 90000 then
			local ToggleChatColorNamesByClassGroup = _G.ToggleChatColorNamesByClassGroup;
			if ToggleChatColorNamesByClassGroup ~= nil then
				for type, info in next, _G.ChatTypeGroup do
					ToggleChatColorNamesByClassGroup(not not value, type);
				end
				local v = _G.getmetatable(_G.ChatTypeInfo);
				v = v.__index and v.__index or _G.ChatTypeInfo;
				for type, info in next, v do
					ToggleChatColorNamesByClassGroup(not not value, type);
				end
			end
		end
	end
	function __misc.HoverHyperlink(value, loading)
		if value then
			for i = 1, NUM_CHAT_WINDOWS do
				local frame = __private.__chatFrames[i];
				frame:SetScript("OnHyperlinkEnter", _OnHyperlinkEnter);
				frame:SetScript("OnHyperlinkLeave", _OnHyperlinkLeave);
			end
		else
			for i = 1, NUM_CHAT_WINDOWS do
				local frame = __private.__chatFrames[i];
				frame:SetScript("OnHyperlinkEnter", nil);
				frame:SetScript("OnHyperlinkLeave", nil);
			end
		end
	end
	function __misc.ChatHyperlink(value, loading)
		if value then
			__private:AddMessageFilter("CHAT_MSG_CHANNEL", "chathyperlink", ChatMessageFilter);
			if not B_InitializedChatHyperLink then
				InitChatHyperLink();
			end
		elseif not loading then
			if B_InitializedChatHyperLink then
				__private:DelMessageFilter("CHAT_MSG_CHANNEL", "chathyperlink");
			end
		end
	end
	function __misc.TabChangeChatType(value, loading)
		if value then
			if _G.ChatEdit_CustomTabPressed ~= ChatFrameEditBox_OnTabPressed then
				_G.ChatEdit_CustomTabPressed = ChatFrameEditBox_OnTabPressed;
			end
		else
			if _G.ChatEdit_CustomTabPressed ~= _ChatEdit_CustomTabPressed then
				_G.ChatEdit_CustomTabPressed = _ChatEdit_CustomTabPressed;
			end
		end
	end
	function __misc.StickyWhisper(value, loading)
		value = value and 1 or 0;
		if ChatTypeInfo["WHISPER"].sticky ~= value then
			ChatTypeInfo["WHISPER"].sticky = value;
		end
	end
	function __misc.StickyBNWhisper(value, loading)
		value = value and 1 or 0;
		if ChatTypeInfo["BN_WHISPER"].sticky ~= value then
			ChatTypeInfo["BN_WHISPER"].sticky = value;
		end
	end
	function __misc.StickyChannel(value, loading)
		value = value and 1 or 0;
		if ChatTypeInfo["CHANNEL"].sticky ~= value then
			ChatTypeInfo["CHANNEL"].sticky = value;
		end
	end
	function __misc.ArrowKey(value, loading)
		value = not value;
		local __chatFrames = __private.__chatFrames;
		for index = 1, NUM_CHAT_WINDOWS do
			local eb = __chatFrames[index].editBox;
			if eb ~= nil and not eb:GetAltArrowKeyMode() ~= not value then
				eb:SetAltArrowKeyMode(value);
			end
		end
	end
	function __misc.ArrowHistory(value, loading)
		if not loading then
			local __chatFrames = __private.__chatFrames;
			for index = 1, NUM_CHAT_WINDOWS do
				local eb = __chatFrames[index].editBox;
				if eb ~= nil then
					eb:SetScript("OnArrowPressed", value and EditBoxOnArrowPressed or nil);
				end
			end
		end
	end
	function __misc.__init(db, loading)
		_db = db;
		if not B_InitializedHistory then
			InitHistory();
		end
	end

	function __misc.__callback(which, value, loading)
		if __misc[which] ~= nil then
			return __misc[which](value, loading);
		end
	end
	local function FontSetButton(button, ele)
		local Text = button.Text;
		local _, size, flag = Text:GetFont();
		Text:SetFont(ele.para[1], size, flag);
	end
	local function FontGetMeta()
		local __list = LSM:HashTable("font");
		local LMODULE = L.SETTING.misc;
		if LMODULE ~= nil then
			for name, val in next, __list do
				LMODULE[val] = name;
			end
		end
		return __list, FontSetButton;
	end
	function __misc.__setting()
		__private:AlignSetting("MISC");
		__private:AddSetting("MISC", { "misc", "Font", 'list', FontGetMeta, });
		__private:AddSetting("MISC", { "misc", "FontFlag", 'list', { "none", "OUTLINE", "THICKOUTLINE", }, }, 2, 2);
		__private:AddSetting("MISC", { "misc", "ChatFrameToBorder", 'boolean', });
		__private:AddSetting("MISC", { "misc", "ColoredPlayerName", 'boolean', });
		__private:AddSetting("MISC", { "misc", "HoverHyperlink", 'boolean', nil, nil, nil, true, });
		if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
			__private:AddSetting("MISC", { "misc", "ChatHyperlink", 'boolean', });
		end
		__private:AddSetting("MISC", { "misc", "TabChangeChatType", 'boolean', });
		__private:AddSetting("MISC", { "misc", "StickyWhisper", 'boolean', });
		__private:AddSetting("MISC", { "misc", "StickyBNWhisper", 'boolean', });
		__private:AddSetting("MISC", { "misc", "StickyChannel", 'boolean', });
		__private:AddSetting("MISC", { "misc", "ArrowKey", 'boolean', });
		__private:AddSetting("MISC", { "misc", "ArrowHistory", 'boolean', }, 1);
	end

	__private.__module["misc"] = __misc;
-->
