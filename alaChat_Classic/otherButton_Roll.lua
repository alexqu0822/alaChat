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
local CB_DATA=L.CHATBAR;
if not CB_DATA then return;end
----------------------------------------------------------------------------------------------------
local alaBaseBtn=__alaBaseBtn;
if not alaBaseBtn then
	return;
end

local btnPackIndex = 8;
--------------------------------------------------roll
local control_roll=false;
local btnRoll=nil;
local function Roll_On()
	if control_roll then
		return;
	end
	local ICON_PATH = NS.ICON_PATH;
	control_roll=true;
	if btnRoll then
		alaBaseBtn:AddBtn(btnPackIndex,-1,btnRoll,true,false,true);
	else
		btnRoll=alaBaseBtn:CreateBtn(
				btnPackIndex,
				-1,
				nil,
				ICON_PATH .. "roll_nor",
				ICON_PATH .. "roll_push",
				ICON_PATH .. "roll_highlight",
				function (self)
					RandomRoll("1","100");
					if GameTooltip:GetOwner()==self then
						GameTooltip:Hide();
					end
				end,
				{
					"\124cffffffffROLL\124r",
				}
		);
	end
	return control_roll;
end
local function Roll_Off()
	if not control_roll then
		return;
	end
	control_roll=false;
	alaBaseBtn:RemoveBtn(btnRoll,true);
	return control_roll;
end
FUNC.ON.roll=Roll_On;
FUNC.OFF.roll=Roll_Off;
----------------------------------------------------------------------------------------------------
