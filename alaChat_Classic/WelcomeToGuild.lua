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
local WTG_STRING=L.WTG_STRING or {}
local FORMAT_WELCOME=WTG_STRING.FORMAT_WELCOME or ""
local FORMAT_BROADCAST=WTG_STRING.FORMAT_BROADCAST or ""
local WTG_STRING_1=WTG_STRING.WTG_STRING_1 or ""
local WTG_STRING_2=WTG_STRING.WTG_STRING_2 or ""
local WTG_STRING_3=WTG_STRING.WTG_STRING_3 or ""
local WTG_STRING_ON=WTG_STRING.WTG_STRING_ON or ""
local WTG_STRING_OFF=WTG_STRING.WTG_STRING_OFF or ""
----------------------------------------------------------------------------------------------------
local control_welcome=false;
local control_broadCast=false;
local WTG_delayMin=2;
local WTG_delayAdd=6;
----------------------------------------------------------------------------------------------------
local math,table,string,pairs,type,select,tonumber,unpack=math,table,string,pairs,type,select,tonumber,unpack;
----------------------------------------------------------------------------------------------------
local random=random;
--------------------------------------------------
------------------------
local pName;
local rName;
local fName;
local gName;
--------------------------------------------------
local WelcomeMsg_Format={};
local WelcomeMsg={};
for v in string.gmatch(FORMAT_WELCOME,"%s*([^\n]+)\n") do
	tinsert(WelcomeMsg_Format,v);
end

local function updateMsg(_gName)
	WelcomeMsg={};
	for _,v in pairs(WelcomeMsg_Format) do
		v=gsub(v,"#GUILD#",gName);
		v=gsub(v,"#PLAYER#",pName);
		v=gsub(v,"#REALM#",rName);
		tinsert(WelcomeMsg,v);
		--print(_,v)
	end
end

local function welcometoGuildMsg_SetValue(val)
	-- val = gsub(val, "[%%%.%+%-%*%?%[%]%(%)]", "%%%1");
				val = gsub(val,"#name#","#NAME#");
				val = gsub(val,"#class#","#CLASS#");
				val = gsub(val,"#level#","#LEVEL#");
				val = gsub(val,"#area","#AREA#");
	val = val .. "\n\n";
	WelcomeMsg_Format = {};
	for v in gmatch(val,"%s*([^\n]+)\n") do
		tinsert(WelcomeMsg_Format,v);
	end
	gName=GetGuildInfo("player");
	if gName and gName ~= "" then
		updateMsg();
	end
end

FUNC.SETVALUE.welcometoGuildMsg=welcometoGuildMsg_SetValue;

local function periodicScanAfterNewMem(n,msg,delay)
	-- print(n,msg,delay,GetNumGuildMembers())
	GuildRoster();
	for i=1,GetNumGuildMembers() do
		local name,rank,rankindex0,level,class,area,_,_,_,_,eClass,ach=GetGuildRosterInfo(i);
		name=strsplit("-",name);
		if name==n then
			--print(i,name,rank,level,class,area);
			if control_broadCast then
				SendChatMessage(format(FORMAT_BROADCAST,name,class,level,area,ach),"GUILD");
			end
			if control_welcome and msg then
				msg = gsub(msg,"#NAME#",name);
				msg = gsub(msg,"#CLASS#",class);
				msg = gsub(msg,"#LEVEL#",level);
				msg = gsub(msg,"#AREA#",area);
				C_Timer.After(delay, function()
					SendChatMessage(msg,"GUILD");
				end);
			end
			return;
		end
	end
	C_Timer.After(0.25, function()
		periodicScanAfterNewMem(n,msg,delay);
	end);
end

local gc_Cache={};
local GUILD_JOIN_STR=gsub(ERR_GUILD_JOIN_S,"%%s","%(%.%+%)");
local function processMsg(_,event,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14)
	local msg,sender,line=arg1,arg2,arg11;
	if not gc_Cache[line] then
	    gc_Cache[line]=1;
		local name=strmatch(msg,GUILD_JOIN_STR);
		if name then
			local n,r=strmatch(name,"(.+)%-(.+)");
			if r==rName then
				name=n;
			end
			if name~=pName then
				local msg=nil;
				if control_welcome and #WelcomeMsg > 0 then
					local ind=random(1,#WelcomeMsg);
					msg=WelcomeMsg[ind];
				end
				if control_broadCast or control_welcome then
					local delay = min(WTG_delayMin + WTG_delayAdd * random(0, 100) / 100, WTG_delayMin + WTG_delayAdd);
					print(delay)
					periodicScanAfterNewMem(name,msg,delay);
				end
			end
		end
	end
end

local function Update()
	local _gName=GetGuildInfo("player");
	if _gName then
		if _gName~=gName then
			gName=_gName;
			updateMsg(_gName);
		end
	else
	end
end

local f = CreateFrame("Frame");
f:SetScript("OnEvent", function(_, event, ...)
	if event == "CHAT_MSG_SYSTEM" then
		processMsg(_, event, ...)
	elseif event == "PLAYER_GUILD_UPDATE" then
		C_Timer.After(1.0, Update);
	end
end);
f:RegisterEvent("PLAYER_GUILD_UPDATE");
f:RegisterEvent("CHAT_MSG_SYSTEM");

local function WelcomeToGuild_Init()
	pName=UnitName("player") or "";
	pName=strsplit("-", pName);
	rName=GetRealmName() or "";
	fName=pName.."-"..rName;
end

local function WelcomeToGuild_ToggleOn()
	if control_welcome then
		return;
	end
	control_welcome=true;
	Update();
	return control_welcome;
end
local function WelcomeToGuild_ToggleOff()
	if not control_welcome then
		return;
	end
	control_welcome=false;
	return control_welcome;
end
local function WelcomeToGuild_Tooltips()
	local tips="";
	for i=1,#WelcomeMsg do
		tips=tips.."\n"..format(WelcomeMsg[i],pName);
	end
end
FUNC.INIT.welcomeToGuild=WelcomeToGuild_Init;
FUNC.ON.welcomeToGuild=WelcomeToGuild_ToggleOn;
FUNC.OFF.welcomeToGuild=WelcomeToGuild_ToggleOff;
FUNC.TOOLTIPS.welcomeToGuild=WelcomeToGuild_Tooltips;


local function BroadCastNewMember_ToggleOn()
	if control_broadCast then
		return;
	end
	control_broadCast=true;
	Update();
	return control_broadCast;
end
local function BroadCastNewMember_ToggleOff()
	if not control_broadCast then
		return;
	end
	control_broadCast=false;
	return control_broadCast;
end
local function BroadCastNewMember_Tooltips()
	--format(FORMAT_BROADCAST,name,class,level,area,ach);
end
FUNC.ON.broadCastNewMember=BroadCastNewMember_ToggleOn;
FUNC.OFF.broadCastNewMember=BroadCastNewMember_ToggleOff;
FUNC.TOOLTIPS.broadCastNewMember=BroadCastNewMember_Tooltips;


