
local __addon, __private = ...;
local L = __private.L;

local TEXTURE_PATH = __private.TEXTURE_PATH;
local PIN_ORDER_OFFSET = 96;

local time = time;
local strbyte, strlen, strsub, strupper, strlower, strsplit, strtrim, strfind, strmatch, format, gsub
	= string.byte, string.len, string.sub, string.upper, string.lower, string.split, string.trim, string.find, string.match, string.format, string.gsub;
local Ambiguate = Ambiguate;

local __highlight = {  };
local _db = {  };

local __STRSET = "";
local __CLR = {  };
local __FMT = "";
local __CS = nil;
local _nStrPatList = 0;
local _tStrPatList = {  };
local _tStrRepList = {  };
local __PAT = "#HL#";
local _BlockNoMatching = {  };

if __private.__is_dev then
	__private:BuildEnv("highlight");
end

-->		MessageFilter
	local function ChatMessageFilter(self, event, msg, sender, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, line, arg12, arg13, arg14, ...)
		if _db._TemporaryDisabled then
			return false;
		end
		if _nStrPatList > 0 then
			local hasMatched = false;
			for index = 1, _nStrPatList do
				local pat = _tStrPatList[index];
				if strmatch(msg, pat) then
					local num = nil;
					msg, num = gsub(msg, pat, _tStrRepList[index]);
					local c = 1;
					while num > 0 and c < 16 do
						msg, num = gsub(msg, pat, _tStrRepList[index]);
						c = c + 1;
					end
					hasMatched = true;
				end
			end
			if hasMatched then
				return false, msg, sender, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, line, arg12, arg13, arg14, ...;
			else
				return _db.ShowMatchedOnly and _BlockNoMatching[event] == true;
			end
		end
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
	local function InitStrPatList(force)
		local SSET = _db.StrSet;
		local fmt = _db.format;
		local clr = _db.color;
		if SSET ~= nil and fmt ~= nil and clr ~= nil then
			SSET = gsub(gsub(gsub(SSET, "^[\t\n ]+", ""), "[\t\n ]+$", ""), "\n\n", "\n");
			SSET = gsub(SSET, "[%^%$%%%.%+%-%*%?%[%]%(%)]", "%%%1");
			-- if _db.CaseInsensitive then
			-- 	SSET = NoCase(SSET);
			-- end
			if strmatch(fmt, __PAT) == nil then
				fmt = "";
			else
				fmt = gsub(gsub(fmt, "^[\t\n ]+\n", ""), "\n[\t\n ]+$", "");
				if fmt == __PAT then
					fmt = "";
				end
			end
			if (SSET ~= nil and __STRSET ~= SSET)
				or (clr ~= nil and (clr[1] ~= __CLR[1] or clr[2] ~= __CLR[2] or clr[3] ~= __CLR[3]))
				or (fmt ~= nil and __FMT ~= fmt)
				or (__CS ~= _db.CaseInsensitive)
			then
				__STRSET = SSET;
				__CLR = clr;
				__FMT = fmt;
				__CS = _db.CaseInsensitive;
				local list = { strsplit("\n", SSET) };
				_nStrPatList = 0;
				_tStrPatList = {  };
				local hash = {  };
				local hex = format("%.2x%.2x%.2x", clr[1] * 255, clr[2] * 255, clr[3] * 255);
				for index = 1, #list do
					local str = strtrim(list[index]);
					local str, c = strsplit("#", str);
					if str ~= "" and hash[str] == nil then
						if _db.CaseInsensitive then
							str = NoCase(str);
						end
						if c ~= nil then
							local len = strlen(c);
							if len < 6 then
								c = hex;
							else
								if len > 6 then
									c = strsub(c, 1, 6);
								end
								if strmatch(c, "[^0-9a-fA-F]") ~= nil then
									c = hex;
								end
							end
						else
							c = hex;
						end
						_nStrPatList = _nStrPatList + 1;
						_tStrPatList[_nStrPatList] = "^([^|]-)(" .. str .. ")";
						_tStrRepList[_nStrPatList] = "%1|cff" .. c .. (fmt == "" and "%2" or gsub(fmt, __PAT, "%%2")) .. "|r";
						_nStrPatList = _nStrPatList + 1;
						_tStrPatList[_nStrPatList] = "(|[^HTc][^|]-)(" .. str .. ")";
						_tStrRepList[_nStrPatList] = "%1|cff" .. c .. (fmt == "" and "%2" or gsub(fmt, __PAT, "%%2")) .. "|r";
						hash[str] = index;
					end
				end
			end
		end
	end
-->

-->		GUI
	--
	local function ButtonOnClick(Button, button)
		if button == "LeftButton" then
			_db._TemporaryDisabled = not _db._TemporaryDisabled;
			Button.Blocked:SetShown(_db._TemporaryDisabled);
		elseif button == "RightButton" then
			__private:OpenSettingTo("highlight", "StrSet");
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
		Button.Text:SetText("K");
		Button:SetTip(L.TIP.highlight, L.DETAILEDTIP.highlight);
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
		__highlight.Button = Button;
	end
-->

-->		Init
	local B_Initialized = false;
	local function Init()
		B_Initialized = true;
		CreateGUI();
	end
-->

-->		Module
	function __highlight.StrSet(value, loading)
		if not loading and _db.toggle then
			InitStrPatList();
		end
	end
	function __highlight.color(value, loading)
		if not loading and _db.toggle then
			InitStrPatList();
		end
	end
	function __highlight.format(value, loading)
		if not loading and _db.toggle then
			InitStrPatList();
		end
	end
	function __highlight.CaseInsensitive(value, loading)
		if not loading and _db.toggle then
			InitStrPatList();
		end
	end
	__highlight["ShowMatchedOnly.CHANNEL"] = function(value, loading)
		_BlockNoMatching["CHAT_MSG_CHANNEL"] = value;
	end
	__highlight["ShowMatchedOnly.SAY-YELL"] = function(value, loading)
		_BlockNoMatching["CHAT_MSG_SAY"] = value;
		_BlockNoMatching["CHAT_MSG_YELL"] = value;
	end
	__highlight["ShowMatchedOnly.NORMAL"] = function(value, loading)
		-- _BlockNoMatching["CHAT_MSG_CHANNEL"] = value;
		_BlockNoMatching["CHAT_MSG_COMMUNITIES_CHANNEL"] = value;
		-- _BlockNoMatching["CHAT_MSG_SAY"] = value;
		-- _BlockNoMatching["CHAT_MSG_YELL"] = value;
		_BlockNoMatching["CHAT_MSG_WHISPER"] = value;
		_BlockNoMatching["CHAT_MSG_BN_WHISPER"] = value;
		_BlockNoMatching["CHAT_MSG_WHISPER_INFORM"] = value;
		_BlockNoMatching["CHAT_MSG_BN_WHISPER_INFORM"] = value;
		_BlockNoMatching["CHAT_MSG_RAID"] = value;
		_BlockNoMatching["CHAT_MSG_RAID_LEADER"] = value;
		_BlockNoMatching["CHAT_MSG_RAID_WARNING"] = value;
		_BlockNoMatching["CHAT_MSG_PARTY"] = value;
		_BlockNoMatching["CHAT_MSG_PARTY_LEADER"] = value;
		_BlockNoMatching["CHAT_MSG_INSTANCE_CHAT"] = value;
		_BlockNoMatching["CHAT_MSG_INSTANCE_CHAT_LEADER"] = value;
		_BlockNoMatching["CHAT_MSG_GUILD"] = value;
		_BlockNoMatching["CHAT_MSG_OFFICER"] = value;
		_BlockNoMatching["CHAT_MSG_EMOTE"] = value;
	end
	function __highlight.ButtonInDock(value, loading)
		if not loading and _db.toggle then
			if value then
				__private.__docker:ShowPin(__highlight.Button);
			else
				__private.__docker:HidePin(__highlight.Button);
			end
		end
	end
	function __highlight.PinStyle(value, loading)
		if B_Initialized and not loading then
			if value ~= "char.blz" then
				value = "char";
				_db.PinStyle = "char";
			end
			ButtonSetStyle(__highlight.Button, value);
		end
	end
	function __highlight.toggle(value, loading)
		if value then
			if not B_Initialized then
				Init();
			end
			InitStrPatList();
			__private:AddMessageFilterAllChatTypes("highlight", ChatMessageFilter);
			if _db.ButtonInDock then
				__private.__docker:ShowPin(__highlight.Button);
			else
				__private.__docker:HidePin(__highlight.Button);
			end
		elseif not loading then
			__private:DelMessageFilterAllChatTypes("highlight", ChatMessageFilter);
			__private.__docker:HidePin(__highlight.Button);
		end
	end
	function __highlight.__init(db, loading)
		_db = db;
	end

	function __highlight.__callback(which, value, loading)
		if __highlight[which] ~= nil then
			return __highlight[which](value, loading);
		end
	end
	function __highlight.__setting()
		__private:AlignSetting("HIGHLIGHT", 0.5);
		__private:AddSetting("HIGHLIGHT", { "highlight", "toggle", 'boolean', });
		--
		__private:AddSetting("HIGHLIGHT", { "highlight", "CaseInsensitive", 'boolean', }, 1);
		__private:AddSetting("HIGHLIGHT", { "highlight", "StrSet", 'editor', "StrSetTip", }, 1);
		__private:AddSetting("HIGHLIGHT", { "highlight", "color", 'color', }, 1);
		__private:AddSetting("HIGHLIGHT", { "highlight", "format", 'input-list', { "#HL#", ">>#HL#<<", "**#HL#**", "[[#HL#]]", }, nil, nil,
			function(val)
				if strmatch(val, __PAT) == nil then
					return "NAXX";
				end
				return gsub(val, __PAT, "NAXX");
			end,
		}, 1);
		__private:AddSetting("HIGHLIGHT", { "highlight", "ShowMatchedOnly", 'boolean', }, 1);
		__private:AddSetting("HIGHLIGHT", { "highlight", "ShowMatchedOnly.CHANNEL", 'boolean', }, 2);
		__private:AddSetting("HIGHLIGHT", { "highlight", "ShowMatchedOnly.SAY-YELL", 'boolean', }, 2);
		__private:AddSetting("HIGHLIGHT", { "highlight", "ShowMatchedOnly.NORMAL", 'boolean', }, 2);
		__private:AddSetting("HIGHLIGHT", { "highlight", "KeepShowMatchedOnly", 'boolean', }, 2);
		__private:AddSetting("HIGHLIGHT", { "highlight", "ButtonInDock", 'boolean', }, 1);
		__private:AddSetting("HIGHLIGHT", { "highlight", "PinStyle", 'list', { "char", "char.blz", }, }, 2);
	end

	__private.__module["highlight"] = __highlight;
-->
