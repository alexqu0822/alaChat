
local __addon, __private = ...;
local L = __private.L;

local hooksecurefunc = hooksecurefunc;
local date = date;
local format, gsub = string.format, string.gsub;
local GetCVar, SetCVar = GetCVar, SetCVar;
local ChatEdit_ChooseBoxForSend, ChatEdit_ActivateChat = ChatEdit_ChooseBoxForSend, ChatEdit_ActivateChat;
local ItemRefTooltip = ItemRefTooltip;
local _G = _G;

local __copy = {  };
local _db = {  };

local __TAG = "";
local __FMT = "";
local __CLR = { 1.0, 1.0, 1.0, };

if __private.__is_dev then
	__private:BuildEnv("copy");
end

-->		Method
	local function SetTimeStamp()
		--	"|cff" .. CLR .. "|Haccopy:-1|h" .. FMT .. "|h|r"
		__TAG = format("|cff%.2x%.2x%.2x|Haccopy:-1|h%s|h|r", __CLR[1] * 255, __CLR[2] * 255, __CLR[3] * 255, (__FMT == nil or __FMT == "" or __FMT == "none") and "*" or __FMT);
		if GetCVar("showTimestamps") ~= __TAG then
			SetCVar("showTimestamps", __TAG);
			_G.CHAT_TIMESTAMP_FORMAT = __TAG;
		end
	end
-->

-->		Init
	local B_Initialized = false;
	local function Init()
		B_Initialized = true;
		local _ItemRefTooltip_SetHyperlink = ItemRefTooltip.SetHyperlink;
		function ItemRefTooltip:SetHyperlink(link, ...)
			if link == "accopy:-1" then
				local focus = GetMouseFocus();
				if not focus:IsObjectType("FontString") then
					focus = focus:GetParent();
					if not focus:IsObjectType("FontString") then
						return;
					end
				end
				local tx = focus:GetText();
				if tx == nil or tx == "" then
					return;
				end
				-- tx = gsub(tx, "|cff%x%x%x%x%x%x|H[^:]+[1-9-:]+|h(.*)|h|r")
				-- tx = gsub(tx, "|cffffffff|H[^:]+[1-9-:]+|h(.*)|h|r", "%1");
				-- tx = gsub(tx, gsubfmt, "");
				tx = gsub(tx, "|H.-|h", "");
				tx = gsub(tx, "|c%x%x%x%x%x%x%x%x", "");
				tx = gsub(tx, "|[Hhr]", "");
				local editBox = ChatEdit_ChooseBoxForSend();
				if not editBox:HasFocus() then
					ChatEdit_ActivateChat(editBox);
				end
				editBox:SetText(tx);
				return;
			end
			return _ItemRefTooltip_SetHyperlink(self, link, ...);
		end
		if InterfaceOptionsSocialPanelTimestamps ~= nil and InterfaceOptionsSocialPanelTimestamps.SetValue ~= nil then
			hooksecurefunc(InterfaceOptionsSocialPanelTimestamps, "SetValue", function(self, value)
				__private:SetDB("copy", "toggle", false);
			end);
		end
	end
-->

-->		Module
	function __copy.color(value, loading)
		if not loading and _db.toggle then
			if value ~= nil and( __CLR[1] ~= value[1] or __CLR[2] ~= value[2] or __CLR[3] ~= value[3]) then
				__CLR = { value[1], value[2], value[3], };
				SetTimeStamp();
			end
		end
	end
	function __copy.format(value, loading)
		if not loading and _db.toggle then
			if value ~= nil and __FMT ~= value then
				__FMT = value;
				SetTimeStamp();
			end
		end
	end
	function __copy.toggle(value, loading)
		if value then
			if not B_Initialized then
				Init();
			end
			local c = _db.color;
			local f = _db.format;
			__FMT = f;
			__CLR = { c[1], c[2], c[3], };
			SetTimeStamp();
		elseif loading then
			local fmt = GetCVar("showTimestamps");
			if fmt ~= "none" then
				local fmt2 = strmatch(fmt, "|h(.+)|h");
				if fmt2 ~= nil then
					SetCVar("showTimestamps", fmt2);
					_G.CHAT_TIMESTAMP_FORMAT = fmt2;
				end
			end
		else
			if __FMT == "none" or __FMT == "" or __FMT == nil then
				if GetCVar("showTimestamps") ~= "none" then
					SetCVar("showTimestamps", "none");
					_G.CHAT_TIMESTAMP_FORMAT = nil;
				end
			else
				if GetCVar("showTimestamps") ~= __FMT then
					SetCVar("showTimestamps", __FMT);
					_G.CHAT_TIMESTAMP_FORMAT = __FMT;
				end
			end
		end
	end
	function __copy.__init(db, loading)
		_db = db;
	end

	function __copy.__callback(which, value, loading)
		if __copy[which] ~= nil then
			return __copy[which](value, loading);
		end
	end
	function __copy.__setting()
		__private:AddSetting("COPY", { "copy", "toggle", 'boolean', });
		--
		__private:AddSetting("COPY", { "copy", "color", 'color', }, 1);
		__private:AddSetting("COPY", { "copy", "format", 'input-list',
			{ "none", "%H:%M", "%H:%M:%S", "%I:%M", "%I:%M:%S", "%I:%M %p", "%I:%M:%S %p", },
			nil,
			nil,
			function(val)
				if val == nil or val == "" or val == "none" then
					return "*";
				end
				return date(val, 86400 + 55652 - 3600 * date("%H", 0));
			end,
		}, 1);
	end

	__copy.__initat = "PLAYER_ENTERING_WORLD";
	__private.__module["copy"] = __copy;
-->
