
local __addon, __private = ...;
local L = __private.L;

local TEXTURE_PATH = __private.TEXTURE_PATH;
local PIN_ORDER_OFFSET = 97;

local time = time;
local next = next;
local strbyte, strsub, strlower, strupper, strsplit, strtrim, strfind, strmatch, format, gsub = string.byte, string.sub, string.lower, string.upper, string.split, string.trim, string.find, string.match, string.format, string.gsub;
local C_Timer = C_Timer;
local IsAltKeyDown = IsAltKeyDown;
local Ambiguate = Ambiguate;
local GetPlayerInfoByGUID = GetPlayerInfoByGUID;

local __chatfilter = {  };
local _db = {  };

local __STRSET = "";
local __NAMESET = "";
local _nStrPatList = 0;
local _tStrPatList = {  };
local _tStrPatDisplay = {  };
local _nNamePatList = 0;
local _tNamePatList = {  };
local _tNamePatDisplay = {  };
local _tNameHash = {  };
local _tMSGCache = {  };	--	[msg] = { time, line, filtered, sender, actually_displayed_msg, repeated_filtered, }
local _tSenderCache = {  };

local PLAYER = UnitName('player');
local LOCALE = GetLocale();

if __private.__is_dev then
	__private:BuildEnv("chatfilter");
end

-->		MessageFilter
	local repeated_check_min = 0;
	if LOCALE == 'zhCN' or LOCALE == 'zhTW' or LOCALE == 'koKR' then
		repeated_check_min = 3 * 4;
	elseif L.Locale == 'enUS' or L.Locale == 'enGB' then
		repeated_check_min = 1 * 8;
	else
		repeated_check_min = 2 * 6;
	end
	local repeated_check_len = repeated_check_min * 2;
	local function CutRepeatedSentence(msg, sender, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, line, arg12, arg13, arg14, ...)
		local len = #msg;
		if len > repeated_check_len then
			local new = msg;
			local n = len * 0.5 / repeated_check_min;
			n = n - n % 1.0;
			local count = 0;
			while n >= 1 do
				local cut = nil;
				local start = repeated_check_min * n;
				for i = start, start + 7 do
					--	ASCII	0xxx xxxx
					--	UTF-8	11xx xxxx 1xxx xxxx
					--	UTF-8	111x xxxx 1xxx xxxx 1xxx xxxx
					--	UTF-8	...
					local c = strbyte(new, i, i);
					if c < 0x80 then		--	1000 0000
						cut = i;
						break;
					elseif c > 0xc0 then	--	1100 0000
						cut = i -1;
						break;
					end
				end
				if cut ~= nil then
					local pat = gsub(strsub(new, 1, cut), "[%^%$%%%.%+%-%*%?%[%]%(%)]", "%%%1");
					local pos = strfind(new, pat, cut + 1);
					local temp1, temp2;
					if pos ~= nil then
						local single = strtrim(strsub(new, 1, pos - 1));
						pat = gsub(single, "[%^%$%%%.%+%-%*%?%[%]%(%)]", "%%%1");
						temp1, temp2 = gsub(new, pat, "");
						if temp2 > 1 then
							temp1 = strtrim(temp1);
							if strmatch(single, gsub(temp1, "[%^%$%%%.%+%-%*%?%[%]%(%)]", "%%%1")) then
								new = single;
							else
								new = single .. temp1;
							end
							local cache = _tMSGCache[new];
							if cache ~= nil then
								if cache[3] then
									_tMSGCache[msg] = { cache[1], line, true, sender, };
								else
									_tMSGCache[msg] = { cache[1], line, false, sender, nil, true, };
								end
								return true;
							end
							len = #new;
							if len <= repeated_check_len then
								break;
							end
							n = len / repeated_check_min;
							n = n - n % 1.0;
						end
					end
					count = count + 1;
					if count > 7 then
						break;
					end
				end
				n = n * 0.5;
				n = n - n % 1.0;
			end
			if new ~= msg then
				return false, new;
			else
				return false;
			end
		end
		return false;
	end
	local function ChatMessageFilter(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, line, arg12, arg13, arg14, ...)
		if _db._TemporaryDisabled then
			return false;
		end
		local sender = Ambiguate(arg2, 'none');
		if sender == PLAYER then
			return false;
		end
		if _tNameHash[sender] then
			return true;
		end
		local msg = strtrim(arg1);
		local cache = _tMSGCache[msg];
		if cache ~= nil then
			if cache[3] or cache[6] then
				return true;
			else
				if _db.Rep and _db.RepInterval > 0 and cache[2] ~= line then
					-- if __private.__is_dev then print("REP", sender, msg); end
					cache[6] = true;	--	上一条消息的事件在这一条消息的事件前，已经处理完毕
					return true;
				elseif cache[5] ~= nil then
					return false, cache[5], sender, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, line, arg12, arg13, arg14, ...;
				else
					return false;
				end
			end
		end
		if _nNamePatList > 0 and _tSenderCache[sender] == nil then
			_tSenderCache[sender] = line;
			for index = 1, _nNamePatList do
				if strmatch(sender, _tNamePatList[index]) ~= nil then
					_tNameHash[sender] = true;
					-- if __private.__is_dev then
					-- 	local class, classFile, race, raceFile, sex = GetPlayerInfoByGUID(arg12);
					-- 	if classFile ~= nil then
					-- 		local color = RAID_CLASS_COLORS[classFile];
					-- 		if color ~= nil then
					-- 			print("BL " .. GetPlayerLink(arg2, format("[|cff%.2x%.2x%.2x%s|r] ", color.r * 255, color.g * 255, color.b * 255, sender), line) .. msg);
					-- 		else
					-- 			print("BL " .. GetPlayerLink(arg2, "[" .. sender .. "] ", line) .. msg);
					-- 		end
					-- 	else
					-- 		print("BL " .. GetPlayerLink(arg2, "[" .. sender .. "] ", line) .. msg);
					-- 	end
					-- end
					return true;
				end
			end
		end
		if _nStrPatList > 0 then
			for index = 1, _nStrPatList do
				if strmatch(msg, _tStrPatList[index]) ~= nil then
					-- if __private.__is_dev then
					-- 	local str = _tStrPatList[index];
					-- 	str = _tStrPatDisplay[str] or str;
					-- 	local class, classFile, race, raceFile, sex = GetPlayerInfoByGUID(arg12);
					-- 	if classFile ~= nil then
					-- 		local color = RAID_CLASS_COLORS[classFile];
					-- 		if color ~= nil then
					-- 			print("KW " .. GetPlayerLink(arg2, format("[|cff%.2x%.2x%.2x%s|r]", color.r * 255, color.g * 255, color.b * 255, sender), line) .. "[[|cffff3f00" .. str .. "|r]] " .. msg);
					-- 		else
					-- 			print("KW " .. GetPlayerLink(arg2, "[" .. sender .. "]", line) .. "[[|cffff3f00" .. str .. "|r]] " .. msg);
					-- 		end
					-- 	else
					-- 		print("KW " .. GetPlayerLink(arg2, "[" .. sender .. "]", line) .. "[[|cffff3f00" .. str .. "|r]] " .. msg);
					-- 	end
					-- end
					_tMSGCache[msg] = { time(), line, true, sender, };
					return true;
				end
			end
		end
		--[=[		--	导致长度很短的消息一直被其他消息包含一直被过滤
		if _db.Rep and _db.RepInterval > 0 then
			local m1 = gsub(msg, "[%^%$%%%.%+%-%*%?%[%]%(%)]", "");
			for m2, cache in next, _tMSGCache do
				if strmatch(m2, m1) then
					_tMSGCache[msg] = { time(), line, false, sender, nil, true, };
					-- if __private.__is_dev then print("REP", sender, msg, m2); end
					return true;
				end
			end
		end
		--]=]
		if _db.RepeatedSentence then
			local filtered, new = CutRepeatedSentence(msg, sender, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, line, arg12, arg13, arg14, ...);
			if filtered then
				-- if __private.__is_dev then print("s", sender, msg); end
				return true;
			end
			if new ~= nil then
				_tMSGCache[msg] = { time(), line, false, sender, new, };
				_tMSGCache[new] = { time(), line, false, sender, };
				-- if __private.__is_dev then print("[[" .. new .. "]]", msg, sender); end
				return false, new, sender, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, line, arg12, arg13, arg14, ...;
			end
		end
		_tMSGCache[msg] = { time(), line, false, sender, };
		return false;
	end
-->

-->		Method
	local function NoCaseRep(w)
		return "[" .. strlower(w) .. strupper(w) .. "]";
	end
	local function NoCase(str)
		return gsub(str, "%a", NoCaseRep);
	end
	local function InitStrPatList()
		local StrSet = _db.StrSet;
		if StrSet ~= nil then
			StrSet = gsub(gsub(gsub(StrSet, "^[\t\n ]+", ""), "[\t\n ]+$", ""), "\n\n", "\n");
			StrSet = gsub(StrSet, "[%^%$%%%.%+%-%*%?%[%]%(%)]", "%%%1");
			local SSET =  _db.CaseInsensitive and NoCase(StrSet) or StrSet;
			if __STRSET ~= SSET then
				__STRSET = SSET;
				local list = { strsplit("\n", SSET) };
				local display = { strsplit("\n", StrSet) };
				_nStrPatList = 0;
				_tStrPatList = {  };
				for index = 1, #list do
					local str = strtrim(list[index]);
					if str ~= "" and _tStrPatList[str] == nil then
						_nStrPatList = _nStrPatList + 1;
						_tStrPatList[_nStrPatList] = str;
						_tStrPatList[str] = true;
						_tStrPatDisplay[str] = strtrim(display[index]);
					end
				end
				if _nStrPatList > 0 then
					for msg, cache in next, _tMSGCache do
						if cache[3] then
							cache[3] = false;
							for index = 1, _nStrPatList do
								if strmatch(msg, _tStrPatList[index]) ~= nil then
									cache[3] = true;
								end
							end
						end
					end
				else
					for msg, cache in next, _tMSGCache do
						if cache[3] then
							cache[3] = false;
						end
					end
				end
			end
		end
	end
	local function InitNamePatList()
		local NameSet = _db.NameSet;
		if NameSet ~= nil then
			NameSet = gsub(gsub(gsub(NameSet, "^[\t\n ]+", ""), "[\t\n ]+$", ""), "\n\n", "\n");
			NameSet = gsub(NameSet, "[%^%$%%%.%+%-%*%?%[%]%(%)]", "%%%1");
			local NSET = _db.CaseInsensitive and NoCase(NameSet) or NameSet;
			if __NAMESET ~= NSET then
				__NAMESET = NSET;
				local list = { strsplit("\n", NSET) };
				local display = { strsplit("\n", NameSet) };
				_nNamePatList = 0;
				_tNamePatList = {  };
				_tNameHash = {  };
				for index = 1, #list do
					local str = strtrim(list[index]);
					if str ~= "" then
						if strmatch(str, "[#*]") then
							str = gsub(str, "[#*]", "");
							if str ~= "" and _tNamePatList[str] == nil then
								_nNamePatList = _nNamePatList + 1;
								_tNamePatList[_nNamePatList] = str;
								_tNamePatDisplay[str] = gsub(display[index], "[#*]", "");
							end
						else
							_tNameHash[str] = true;
							_tNamePatDisplay[str] = display[index];
						end
					end
				end
			end
		end
	end
	local function UpdateCache()
		if _db.Rep and _db.RepInterval > 0 then
			local dead = time() - _db.RepInterval;
			for msg, cache in next, _tMSGCache do
				if cache[3] ~= true and cache[1] <= dead then
					_tMSGCache[msg] = nil;
				end
			end
		end
		C_Timer.After(1.0, UpdateCache);
	end
-->

-->		GUI
	--
	local function ButtonOnClick(Button, button)
		if button == "LeftButton" then
			_db._TemporaryDisabled = not _db._TemporaryDisabled;
			Button.Blocked:SetShown(_db._TemporaryDisabled);
		elseif button == "RightButton" then
			if IsAltKeyDown() then
				__private:OpenSettingTo("chatfilter", "NameSet");
			else
				__private:OpenSettingTo("chatfilter", "StrSet");
			end
		end
	end
	local function ButtonSetStyle(Button, style)
		if _db.PinStyle == "char.blz" then
			Button:SetTextBLZFont();
			Button:SetNormalTexture(TEXTURE_PATH .. "blz_text_normal");
			Button:SetPushedTexture(TEXTURE_PATH .. "blz_text_pushed");
		else
			Button:SetTextFont();
			-- Button:SetNormalTexture("");
			local Texture = Button:GetNormalTexture(); if Texture ~= nil then Texture:SetColorTexture(0.0, 0.0, 0.0, 0.0); end
			-- Button:SetPushedTexture("");
			local Texture = Button:GetPushedTexture(); if Texture ~= nil then Texture:SetColorTexture(0.0, 0.0, 0.0, 0.0); end
		end
	end
	local function CreateGUI()
		local Button = __private.__docker:CreatePin(PIN_ORDER_OFFSET);
		-- Button:SetAlpha(0.8);
		Button.Text:SetText("F");
		Button:SetTip(L.TIP.chatfilter, L.DETAILEDTIP.chatfilter);
		local Blocked = Button:CreateTexture(nil, "OVERLAY", nil, 7);
		Blocked:SetAllPoints();
		Blocked:SetTexture(TEXTURE_PATH .. "Blocked");
		Blocked:SetVertexColor(1.0, 0.0, 0.0, 0.5);
		Blocked:Hide();
		Button.Blocked = Blocked;
		-- Button:SetScript("OnDragStart", function() if self:IsMovable() and IsControlKeyDown() then self:StartMoving(); end end);
		-- Button:SetScript("OnDragStop", function() if self:IsMovable() then self:StopMovingOrSizing(); end end);
		Button:SetScript("OnClick", ButtonOnClick);
		ButtonSetStyle(Button, _db.PinStyle);
		Button.Blocked:SetShown(_db._TemporaryDisabled);
		__chatfilter.Button = Button;
	end
-->

-->		Init
	local B_Initialized = false;
	local function Init()
		B_Initialized = true;
		UpdateCache();
		CreateGUI();
	end
-->

-->		Module
	function __chatfilter.StrSet(value, loading)
		if not loading and _db.toggle then
			InitStrPatList();
		end
	end
	function __chatfilter.NameSet(value, loading)
		if not loading and _db.toggle then
			InitNamePatList();
		end
	end
	function __chatfilter.CaseInsensitive(value, loading)
		if not loading and _db.toggle then
			InitStrPatList();
			InitNamePatList();
		end
	end
	function __chatfilter.ButtonInDock(value, loading)
		if not loading and _db.toggle then
			if value then
				__private.__docker:ShowPin(__chatfilter.Button);
			else
				__private.__docker:HidePin(__chatfilter.Button);
			end
		end
	end
	function __chatfilter.PinStyle(value, loading)
		if B_Initialized and not loading then
			if value ~= "char.blz" then
				value = "char";
				_db.PinStyle = "char";
			end
			ButtonSetStyle(__chatfilter.Button, value);
		end
	end
	function __chatfilter.toggle(value, loading)
		if value then
			if not B_Initialized then
				Init();
			end
			InitStrPatList();
			InitNamePatList();
			__private:AddMessageFilter("CHAT_MSG_CHANNEL", "chatfilter", ChatMessageFilter);
			__private:AddMessageFilter("CHAT_MSG_SAY", "chatfilter", ChatMessageFilter);
			__private:AddMessageFilter("CHAT_MSG_YELL", "chatfilter", ChatMessageFilter);
			if _db.ButtonInDock then
				__private.__docker:ShowPin(__chatfilter.Button);
			else
				__private.__docker:HidePin(__chatfilter.Button);
			end
		elseif not loading then
			__private:DelMessageFilter("CHAT_MSG_CHANNEL", "chatfilter", ChatMessageFilter);
			__private:DelMessageFilter("CHAT_MSG_SAY", "chatfilter", ChatMessageFilter);
			__private:DelMessageFilter("CHAT_MSG_YELL", "chatfilter", ChatMessageFilter);
			__private.__docker:HidePin(__chatfilter.Button);
		end
	end
	function __chatfilter.__init(db, loading)
		_db = db;
	end

	function __chatfilter.__callback(which, value, loading)
		if __chatfilter[which] ~= nil then
			return __chatfilter[which](value, loading);
		end
	end
	function __chatfilter.__setting()
		__private:AddSetting("CHATFILTER", { "chatfilter", "toggle", 'boolean', });
		--
		__private:AddSetting("CHATFILTER", { "chatfilter", "CaseInsensitive", 'boolean', }, 1);
		__private:AddSetting("CHATFILTER", { "chatfilter", "StrSet", 'editor', "StrSetTip", }, 1);
		__private:AddSetting("CHATFILTER", { "chatfilter", "NameSet", 'editor', "NameSetTip", }, 1);
		__private:AddSetting("CHATFILTER", { "chatfilter", "Rep", 'boolean', }, 1);
		__private:AddSetting("CHATFILTER", { "chatfilter", "RepInterval", 'number', { 0, 240, 5, }, nil, 6, }, 2);
		__private:AddSetting("CHATFILTER", { "chatfilter", "RepeatedSentence", 'boolean', }, 1);
		__private:AddSetting("CHATFILTER", { "chatfilter", "ButtonInDock", 'boolean', }, 1);
		__private:AddSetting("CHATFILTER", { "chatfilter", "PinStyle", 'list', { "char", "char.blz", }, }, 2);
	end

	__private.__module["chatfilter"] = __chatfilter;
-->
