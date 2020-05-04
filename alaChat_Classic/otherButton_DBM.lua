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

local btnPackIndex = 9;
--------------------------------------------------dbm pull
local control_dbmCountDown=false;
local btnDBMCountDown=nil;
local function DBMCountDown_On()
	if control_dbmCountDown then
		return;
	end
	control_dbmCountDown=true;
	local ICON_PATH = NS.ICON_PATH;
	if btnDBMCountDown then
		alaBaseBtn:AddBtn(btnPackIndex,-1,btnDBMCountDown,true,false,true);
	else
		btnDBMCountDown=alaBaseBtn:CreateBtn(
				btnPackIndex,
				-1,
				nil,
				ICON_PATH .. "dbm_nor",
				ICON_PATH .. "dbm_push",
				ICON_PATH .. "dbm_highlight",
				function(self,button)
					if button=="LeftButton" then
						if SlashCmdList["DEADLYBOSSMODS"] then
							SlashCmdList["DEADLYBOSSMODS"]("pull 6");
						elseif SlashCmdList["DEADLYBOSSMODSPULL"] then
						    SlashCmdList["DEADLYBOSSMODSPULL"]("6");

						elseif not IsAddOnLoaded("BigWigs_Plugins") then
							LoadAddOn("BigWigs_Plugins");
							if SlashCmdList["BIGWIGSPULL"] then
								SlashCmdList["BIGWIGSPULL"]("6");
							end
						elseif SlashCmdList["BIGWIGSPULL"] then
							SlashCmdList["BIGWIGSPULL"]("6");

						else
							DEFAULT_CHAT_FRAME:AddMessage("|cffFFFF88 DBM or BigWigs is off. |r",1,1,0);
						end
						--if GameTooltip:GetOwner()==self then GameTooltip:Hide();end
					elseif button=="RightButton" then
						if SlashCmdList["DEADLYBOSSMODS"] then
							SlashCmdList["DEADLYBOSSMODS"]("pull 0");
						elseif SlashCmdList["DEADLYBOSSMODSPULL"] then
						    SlashCmdList["DEADLYBOSSMODSPULL"]("0");

						elseif not IsAddOnLoaded("BigWigs_Plugins") then
							LoadAddOn("BigWigs_Plugins");
							if SlashCmdList["BIGWIGSPULL"] then
								SlashCmdList["BIGWIGSPULL"]("0");
							end
						elseif SlashCmdList["BIGWIGSPULL"] then
							SlashCmdList["BIGWIGSPULL"]("0");
						else
							DEFAULT_CHAT_FRAME:AddMessage("|cffFFFF88 DBM or BigWigs is off. |r",1,1,0);
						end
						--if GameTooltip:GetOwner()==self then GameTooltip:Hide();end
					end
				end,
				{
					CB_DATA.LINE_DBM1,
					CB_DATA.LINE_DBM2,
					CB_DATA.LINE_DBM3,
				}
		);
	end
	return control_dbmCountDown;
end
local function DBMCountDown_Off()
	if not control_dbmCountDown then
		return;
	end
	control_dbmCountDown=false;
	alaBaseBtn:RemoveBtn(btnDBMCountDown,true);
	return control_dbmCountDown;
end
FUNC.ON.DBMCountDown=DBMCountDown_On;
FUNC.OFF.DBMCountDown=DBMCountDown_Off;
----------------------------------------------------------------------------------------------------
