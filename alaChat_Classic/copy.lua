--[[--
	alex@0
--]]--
-- do return; end
----------------------------------------------------------------------------------------------------
local ADDON,NS=...;

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

local FUNC=NS.FUNC;
if not FUNC then return;end
local L=NS.L;
if not L then return;end
----------------------------------------------------------------------------------------------------
local math,table,string,pairs,type,select,tonumber,unpack=math,table,string,pairs,type,select,tonumber,unpack;
local _G=_G;
----------------------------------------------------------------------------------------------------
--------------------------------------------------copy
local control_copy=false;
local function insertEditBox(text)
	local editBox=ChatEdit_ChooseBoxForSend();
	ChatEdit_ActivateChat(editBox);
	editBox:SetText(text);
end

local copy_color = "7f7fff";
local stamp_fmt = "[%H:%M:%S]";
--local gsubfmt = "";

local function set(fmt)
	if fmt then
		--\cffffff\Hcopy:id::::\h[time]\h\r
		_G.CHAT_TIMESTAMP_FORMAT="\124cff" .. copy_color .. "\124HalaCCopy:-1\124h" .. fmt .. "\124h\124r";
	else
		_G.CHAT_TIMESTAMP_FORMAT="\124cff" .. copy_color .. "\124HalaCCopy:-1\124h**\124h\124r";
	end
	--gsubfmt = "\124cff" .. copy_color .. "\124HalaCCopy:-1\124h**\124h\124r";
end
local function setColor(r, g, b)
	copy_color = string.format("%.2x%.2x%.2x", r * 255, g * 255, b* 255);
	if control_copy then
		set(stamp_fmt);
	end
end
local function setStamp(fmt)
	fmt = string.gsub(fmt, "\n", "");
	stamp_fmt = fmt;
	if fmt == "" then
		control_copy = false;
		_G.CHAT_TIMESTAMP_FORMAT = nil;
		return;
	elseif NS.alac_GetConfig("copy") then
		control_copy = true;
	end
	if control_copy then
		set(stamp_fmt);
	end
end

local _SetHyperlink = ItemRefTooltip.SetHyperlink;
function ItemRefTooltip.SetHyperlink(self,link)
	if link=="alaCCopy:-1" then
		local m=GetMouseFocus();
		if not m:IsObjectType("FontString") then
			m=m:GetParent();
			if not m:IsObjectType("FontString") then
				return;
			end
		end
		local tx=m:GetText();
		if type(tx)~="string" then
			return;
		end
		--tx=string.gsub(tx,"\124cff%x%x%x%x%x%x\124H[^:]+[1-9-:]+\124h(.*)\124h\124r")
		--tx=string.gsub(tx,"\124cffffffff\124H[^:]+[1-9-:]+\124h(.*)\124h\124r","%1");
		--tx=string.gsub(tx,gsubfmt,"");
		tx=string.gsub(tx,"\124H.-\124h","");
		tx=string.gsub(tx,"\124c%x%x%x%x%x%x%x%x","");
		tx=string.gsub(tx,"\124h","");
		tx=string.gsub(tx,"\124r","");
		insertEditBox(tx);
	else
		return _SetHyperlink(self, link);
	end
end
local function hook_InterfaceOptionsSocialPanelTimestamps()
		hooksecurefunc(InterfaceOptionsSocialPanelTimestamps,"SetValue",function(_,fmt)
				if fmt=="none" then
					stamp_fmt=nil;
				else
					stamp_fmt=fmt;
				end
				NS.alac_SetConfig(stamp_fmt);
				if control_copy then
					set(stamp_fmt);
				end
			end
			);
end
local function copy_Init()
	if InterfaceOptionsSocialPanelTimestamps.SetValue and type(InterfaceOptionsSocialPanelTimestamps.SetValue) == 'function' then
		hook_InterfaceOptionsSocialPanelTimestamps();
	else
		C_Timer.After(1.0, copy_Init);
	end
end
local function copy_ToggleOn()
	if control_copy then
		return;
	end
	control_copy=true;
	set(stamp_fmt);
	return control_copy;
end
local function copy_ToggleOff(loading)
	if not control_copy or loading then
		return;
	end
	control_copy=false;
	_G.CHAT_TIMESTAMP_FORMAT=stamp_fmt;
	return control_copy;
end
FUNC.INIT.copy = copy_Init;
FUNC.ON.copy = copy_ToggleOn;
FUNC.OFF.copy = copy_ToggleOff;

--FUNC.ON.copyTagColor=function()end
--FUNC.OFF.copyTagColor=function()end
FUNC.SETVALUE.copyTagColor = setColor;
FUNC.SETVALUE.copyTagFormat = setStamp;
----------------------------------------------------------------------------------------------------


--------------------------------------------------
do return; end
local control_copy = false;

local copy_format = nil;
local stamp_fmt = "[%H:%M:%S]";
local copy_color = "7f7fff";

local function insertEditBox(text)
	local editBox=ChatEdit_ChooseBoxForSend();
	ChatEdit_ActivateChat(editBox);
	editBox:SetText(text);
end
local _SetHyperlink = ItemRefTooltip.SetHyperlink;
function ItemRefTooltip.SetHyperlink(self,link)
	if link=="alaCCopy:-1" then
		local m=GetMouseFocus();
		if not m:IsObjectType("FontString") then
			m=m:GetParent();
			if not m:IsObjectType("FontString") then
				return;
			end
		end
		local tx=m:GetText();
		if type(tx)~="string" then
			return;
		end
		--tx=string.gsub(tx,"\124cff%x%x%x%x%x%x\124H[^:]+[1-9-:]+\124h(.*)\124h\124r")
		--tx=string.gsub(tx,"\124cffffffff\124H[^:]+[1-9-:]+\124h(.*)\124h\124r","%1");
		--tx=string.gsub(tx,gsubfmt,"");
		tx=string.gsub(tx,"\124H.-\124h","");
		tx=string.gsub(tx,"\124c%x%x%x%x%x%x%x%x","");
		tx=string.gsub(tx,"\124h","");
		tx=string.gsub(tx,"\124r","");
		insertEditBox(tx);
	else
		return _SetHyperlink(self, link);
	end
end

local function set(fmt)
	if fmt and fmt ~= "" then
		copy_format="\124cff" .. copy_color .. "\124HalaCCopy:-1\124h" .. fmt .. "\124h\124r";
	else
		copy_format = nil;
	end
end
local function setColor(r, g, b)
	copy_color = string.format("%.2x%.2x%.2x", r * 255, g * 255, b* 255);
	if control_copy then
		set(stamp_fmt);
	end
end
local function setStamp(fmt)
	-- fmt = string.gsub(fmt, "%%", "%%%%");
	fmt = string.gsub(fmt, "\n", "");
	if fmt == "" then
		fmt = nil;
	end
	stamp_fmt = fmt;
	if control_copy then
		set(stamp_fmt);
	end
end


local function copy_AddMessage_filter(msg)
	return copy_format and (BetterDate(copy_format, time()) .. msg) or msg;
end

local function copy_Init()
	-- hooksecurefunc(InterfaceOptionsSocialPanelTimestamps, "SetValue", function(_, fmt)
	-- 		if fmt == "none" then
	-- 			fmt = "";
	-- 		end
	-- 		_G.CHAT_TIMESTAMP_FORMAT = nil;
	-- 		NS.alac_SetConfig("copyTagFormat", fmt);
	-- 	end);
end
local function copy_ToggleOn()
	if control_copy then
		return;
	end
	control_copy = true;
	if ala_add_AddMessage_filter then
		ala_add_AddMessage_filter(copy_AddMessage_filter);
	end
	-- _G.CHAT_TIMESTAMP_FORMAT = nil;
	return control_copy;
end
local function copy_ToggleOff(loading)
	if not control_copy or loading then
		return;
	end
	control_copy = false;
	if ala_sub_AddMessage_filter then
		ala_sub_AddMessage_filter(copy_AddMessage_filter);
	end
	return control_copy;
end
FUNC.INIT.copy = copy_Init;
FUNC.ON.copy = copy_ToggleOn;
FUNC.OFF.copy = copy_ToggleOff;
FUNC.SETVALUE.copyTagColor = setColor;
FUNC.SETVALUE.copyTagFormat = setStamp;
----------------------------------------------------------------------------------------------------
