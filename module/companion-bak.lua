
local __addon, __private = ...;
local L = __private.L;

local time = time;
local print = print;
local xpcall = xpcall;
local geterrorhandler = geterrorhandler;
local tonumber = tonumber;
local next = next;
local strsplit, strtrim, strmatch, gsub, format = string.split, string.trim, string.match, string.gsub, string.format;
local random = random;
local C_Timer_After = C_Timer.After;
local Ambiguate = Ambiguate;
local UnitIsPlayer = UnitIsPlayer;
local UnitGUID, UnitName, UnitClassBase, UnitLevel, UnitFactionGroup, UnitSex = UnitGUID, UnitName, UnitClassBase, UnitLevel, UnitFactionGroup, UnitSex;
local GetPlayerInfoByGUID = GetPlayerInfoByGUID;
local IsInGuild, GetGuildInfo, GuildRoster = IsInGuild, GetGuildInfo, C_GuildInfo ~= nil and C_GuildInfo.GuildRoster or GuildRoster;
local GetNumGuildMembers, GetGuildRosterInfo = GetNumGuildMembers, GetGuildRosterInfo;
local GetNumFriends = C_FriendList ~= nil and C_FriendList.GetNumFriends or GetNumFriends;
local GetFriendInfoByIndex = C_FriendList ~= nil and C_FriendList.GetFriendInfoByIndex or GetFriendInfoByIndex;
local IsInGroup, IsInRaid, GetNumGroupMembers, GetRaidRosterInfo = IsInGroup, IsInRaid, GetNumGroupMembers, GetRaidRosterInfo;
local GetNumWhoResults, GetWhoInfo = C_FriendList.GetNumWhoResults, C_FriendList.GetWhoInfo;
local BNGetNumFriends, BNGetNumFriendGameAccounts, BNGetFriendGameAccountInfo = BNGetNumFriends, BNGetNumFriendGameAccounts, BNGetFriendGameAccountInfo;
local SendChatMessage = SendChatMessage;
local CreateFrame = CreateFrame;
local BNET_CLIENT_WOW = BNET_CLIENT_WOW;
local WOW_PROJECT_ID = WOW_PROJECT_ID;
local _G = _G;

local _Driver = nil;
local _tPlayerInfo = {  };		--	[name] = { GUID, class, level, time, src, }
local _isInGuild = IsInGuild();
local _isInGroup = IsInGroup();
local _isInRaid = IsInRaid();

local __companion = {  };
local _db = {  };

local __PLFStr_LI = nil;
local __PLFStr_L = nil;
local __PLFStr_I = nil;
local __PLFStr_ = nil;
local __WelStrSet = nil;
local _nWelStrList = 0;
local _tWelStrList = {  };
local __NoticeStr = nil;
local _tGuildPreQueue = {  };
local _tGuildMsgQueue = {  };
local LOCALIZED_CLASS_NAMES_HASH = {  };
for k, v in next, LOCALIZED_CLASS_NAMES_FEMALE do
	LOCALIZED_CLASS_NAMES_HASH[v] = k;
end
for k, v in next, LOCALIZED_CLASS_NAMES_MALE do
	LOCALIZED_CLASS_NAMES_HASH[v] = k;
end
local _tSubGroup = {  };

local _PLAYER = UnitName('player');
local _PREALM = GetRealmName();
local _FULLPLAYER = _PLAYER .. "-" .. _PREALM;
local _PCLASS = UnitClassBase('player');
local _PRACE = UnitRace('player');
local _PFACTION = UnitFactionGroup('player');
local _PLEVEL = UnitLevel('player');
local _GUILD = GetGuildInfo('player');

if __private.__is_dev then
	__private:BuildEnv("companion");
end

--[=[
	--	/run for k,v in next,_G do if type(v)=='string' and strmatch(v,"开除出公会") then print(k,v) end end
	ERR_GUILD_JOIN_S == "%s加入了公会。"
	GUILDEVENT_TYPE_JOIN == "%s加入了公会。"
	ERR_GUILD_LEAVE_S == "%s离开了公会。"
	ERR_GUILD_LEAVE_RESULT == "你离开了公会"
	GUILDEVENT_TYPE_QUIT == "%s离开了公会"
	ERR_GUILD_REMOVE_SS == "%s被%s开除出公会。"
	ERR_GUILD_REMOVE_SELF == "你被开除出公会"
--]=]
-->		Method
	local function AddPlayerInfo(fullName, GUID, class, level, src, now)
		local pinfo = _tPlayerInfo[fullName];
		if pinfo == nil then
			pinfo = {
				GUID ~= "" and GUID or nil,
				class ~= "" and class or nil,
				level or 0,
				now,
				src,
			};
			_tPlayerInfo[fullName] = pinfo;
			-- if __private.__is_dev then
			-- 	print("|cff00ff00++++|r", fullName, pinfo[2], pinfo[3]);
			-- end
		else
			pinfo[1] = GUID ~= "" and GUID or pinfo[1];
			pinfo[2] = class ~= "" and class or pinfo[2];
			pinfo[3] = level ~= 0 and level or pinfo[3];
			pinfo[4] = now;
			pinfo[5] = src;
			-- if __private.__is_dev then
			-- 	print("|cffffff00****|r", fullName, pinfo[2], pinfo[3]);
			-- end
		end
	end
--		level and subGroup
	local PlayerLinkStaticString = {
		["#NAME#"] = "%1$s",
		["#LEVEL#"] = "%2$s",
		["#INDEX#"] = "%3$s",
	};
	local PlayerLinkVariableString = {
		["#([^#]*)NAME([^#]*)#"] = "%1%%1$s%2",
		["#([^#]*)LEVEL([^#]*)#"] = "%1%%2$s%2",
		["#([^#]*)INDEX([^#]*)#"] = "%1%%3$s%2",
	};
	local function InitPlayerLinkFormatStr()
		local SSET = _db.PlayerLinkFormat;
		if SSET ~= nil then
			SSET = strsplit("\n", gsub(SSET, "^[\t\n ]+", ""));
			if strtrim(SSET) == "" then
				__PLFStr_LI = "%s";
			else
				local SSET_L = gsub(SSET, "[ ]*#([^#]*)INDEX([^#]*)#[ ]*", "");
				local SSET_I = gsub(SSET, "[ ]*#([^#]*)LEVEL([^#]*)#[ ]*", "");
				local SSET_ = gsub(gsub(SSET, "[ ]*#([^#]*)LEVEL([^#]*)#[ ]*", ""), "[ ]*#([^#]*)INDEX([^#]*)#[ ]*", "");
				if not _db.ShowLevel then
					if not _db.ShowSubGroup then
						SSET = SSET_;
					else
						SSET = SSET_I;
					end
				elseif not _db.ShowSubGroup then
					SSET = SSET_L;
				end
				-- SSET = gsub(SSET, "#.-#", PlayerLinkStaticString);
				for pat, rep in next, PlayerLinkVariableString do
					SSET = gsub(SSET, pat, rep);
					SSET_L = gsub(SSET_L, pat, rep);
					SSET_I = gsub(SSET_I, pat, rep);
					SSET_ = gsub(SSET_, pat, rep);
				end
				if strtrim(SSET) == "" then
					__PLFStr_LI = "%s";
					__PLFStr_L = "%s";
					__PLFStr_I = "%s";
					__PLFStr_ = "%s";
				else
					__PLFStr_LI = SSET;
					__PLFStr_L = SSET_L;
					__PLFStr_I = SSET_I;
					__PLFStr_ = SSET_;
				end
			end
		end
	end
--		WelToGuild
	local WelToGuildStaticString = {
		["#PLAYER#"] = _PLAYER,
		["#PCLASS#"] = (UnitSex('player') == 3 and LOCALIZED_CLASS_NAMES_FEMALE or LOCALIZED_CLASS_NAMES_MALE)[_PCLASS],
		["#PRACE#"] = _PRACE,
		["#PFACTION#"] = _PFACTION,
		["#PREALM#"] = _PREALM,
		["#GUILD#"] = "%1$s",
		["#NAME#"] = "%2$s",
		["#CLASS#"] = "%3$s",
		["#LEVEL#"] = "%4$s",
		["#AREA#"] = "%5$s",
	};
	local function InitWelWelStrList()
		local SSET = _db.WelToGuildStrSet;
		if SSET ~= nil then
			SSET = gsub(gsub(gsub(gsub(SSET, "\n[\t\n ]*\n", "\n"), "^[\t\n ]+", ""), "[\t\n ]+$", ""), "#.-#", WelToGuildStaticString);
			if SSET ~= nil and __WelStrSet ~= SSET then
				__WelStrSet = SSET;
				local list = { strsplit("\n", SSET) };
				_nWelStrList = 0;
				_tWelStrList = {  };
				local hash = {  };
				for index = 1, #list do
					local str = strtrim(list[index]);
					if str ~= nil and str ~= "" and hash[str] == nil then
						_nWelStrList = _nWelStrList + 1;
						_tWelStrList[_nWelStrList] = str;
						hash[str] = index;
					end
				end
			end
		end
	end
	local function InitNoticeStr()
		local SSET = _db.NewMemberNoticeStr;
		if SSET ~= nil then
			SSET = gsub(strsplit("\n", gsub(SSET, "^[\t\n ]+", "")), "#.-#", WelToGuildStaticString);
			if SSET ~= nil and __NoticeStr ~= SSET then
				__NoticeStr = SSET;
			end
		end
	end
	--
	local function OnRosterInfo(fullName, class, level, rank, classStr, zoneStr, rankStr, GUID)
		local name = Ambiguate(fullName, 'none');
		if _db.NewMemberNotice then
			SendChatMessage(format(__NoticeStr, _GUILD, name, classStr, level, zoneStr), "GUILD");
		end
		if _nWelStrList > 0 then
			local v = _tWelStrList[random(1, _nWelStrList)];
			local msg = format(v, _GUILD, name, classStr, level, zoneStr);
			if _db.WelToGuildDelay then
				_tGuildMsgQueue[fullName] = { time() + 1.0 + random(2.0, 6.0), msg, };
			else
				SendChatMessage(msg, "GUILD");
			end
		end
	end
--		shared
	--
	local method = {
		guild = function()
			local now = time();
			for index = 1, GetNumGuildMembers() do
				local name, rankStr, rank, level, classStr, zoneStr, _, _, _, _, class, _, _, _, _, _, GUID = GetGuildRosterInfo(index);
				if name ~= nil and name ~= "" then
					local fullName = strmatch(name, "-") == nil and (name .. "-" .. _PREALM) or name;
					AddPlayerInfo(fullName, GUID, class, level, 'guild', now);
					if _tGuildPreQueue[fullName] ~= nil then
						_tGuildPreQueue[fullName] = nil;
						OnRosterInfo(fullName, class, level, rank, classStr, zoneStr, rankStr, GUID);
					end
				end
			end
			for fullName, val in next, _tGuildPreQueue do
				if val > 1 then
					_tGuildPreQueue[fullName] = val - 1;
				else
					_tGuildPreQueue[fullName] = nil;
					if __private.__is_dev then
						print("Guild |cffff0000remove|r queue", fullName);
					end
				end
			end
		end,
		friend = function()
			local now = time();
			for index = 1, GetNumFriends() do
				local info = GetFriendInfoByIndex(index);
				if info.connected then
					local name = info.name;
					if name ~= nil and name ~= "" then
						local fullName = strmatch(name, "-") == nil and (name .. "-" .. _PREALM) or name;
						AddPlayerInfo(fullName, info.guid, LOCALIZED_CLASS_NAMES_HASH[info.className], info.level, 'friend', now);
					end
				end
			end
		end,
		group = function()
			local now = time();
			_tSubGroup = {  };
			for index = 1, GetNumGroupMembers() do
				local name, rank, subGroup, level, classStr, class, zone, online, dead, role, isML, combatRole = GetRaidRosterInfo(index);
				if name ~= nil and name ~= "" then
					local fullName = strmatch(name, "-") == nil and (name .. "-" .. _PREALM) or name;
					AddPlayerInfo(fullName, UnitGUID(name), class, (level == nil or level == 0) and UnitLevel(name) or level, 'group', now);
					_tSubGroup[fullName] = subGroup;
				end
			end
		end,
		who = function()
			local now = time();
			for index = 1, GetNumWhoResults() do
				local info = GetWhoInfo(index);
				local name = info.fullName;
				if name ~= nil and name ~= "" then
					local fullName = strmatch(name, "-") == nil and (name .. "-" .. _PREALM) or name;
					AddPlayerInfo(fullName, nil, info.filename, info.level, 'who', now);
				end
			end
		end,
		unit = function(unit)
			if UnitIsPlayer(unit) then
				local name, realm = UnitName(unit);
				if name ~= nil and name ~= "" then
					local fullName = name .. "-" .. (realm ~= nil and realm ~= "" and realm or _PREALM);
					AddPlayerInfo(fullName, UnitGUID(unit), UnitClassBase(unit), UnitLevel(unit), 'unit', time());
				end
			end
		end,
	};
	if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
		local C_BattleNet_GetFriendNumGameAccounts = C_BattleNet.GetFriendNumGameAccounts;
		local C_BattleNet_GetFriendGameAccountInfo = C_BattleNet.GetFriendGameAccountInfo;
		method.battlenet = function()
			local now = time();
			local _, online = BNGetNumFriends();
			for index = 1, online do
				for index2 = 1, C_BattleNet_GetFriendNumGameAccounts(index) do
					local info = C_BattleNet_GetFriendGameAccountInfo(index, index2);
					local name = info.characterName;
					local realm = info.realmName;
					if info.clientProgram == BNET_CLIENT_WOW and info.wowProjectID == WOW_PROJECT_ID then
						if name ~= nil and name ~= "" then
							if realm ~= nil and realm ~= "" and realm ~= _PREALM then
								AddPlayerInfo(name .. "-" .. realm, info.playerGuid, LOCALIZED_CLASS_NAMES_HASH[info.className], info.characterLevel, 'battlenet', now);
							else
								AddPlayerInfo(name .. "-" .. _PREALM, info.playerGuid, LOCALIZED_CLASS_NAMES_HASH[info.className], info.characterLevel, 'battlenet', now);
							end
						end
					end
				end
			end
		end
	else
		local BNGetNumFriendGameAccounts = BNGetNumFriendGameAccounts;
		local BNGetFriendGameAccountInfo = BNGetFriendGameAccountInfo;
		method.battlenet = function()
			local now = time();
			local _, _online = BNGetNumFriends();
			for index = 1, _online do
				for index2 = 1, BNGetNumFriendGameAccounts(index) do
					local isOnline, name, client, realm, realmID, faction, race, classStr, _, zone1, level, zone2, _, _, _, _, _, _, _, GUID, wowProjectID, r2 = BNGetFriendGameAccountInfo(index, index2);
					if client == BNET_CLIENT_WOW and wowProjectID == WOW_PROJECT_ID then
						if name ~= nil and name ~= "" then
							if realm ~= nil and realm ~= "" and realm ~= _PREALM then
								AddPlayerInfo(name .. "-" .. realm, GUID, LOCALIZED_CLASS_NAMES_HASH[classStr], tonumber(level), 'battlenet', now);
							else
								AddPlayerInfo(name .. "-" .. _PREALM, GUID, LOCALIZED_CLASS_NAMES_HASH[classStr], tonumber(level), 'battlenet', now);
							end
						end
					end
				end
			end
		end
	end
	local B_isDelayUpdateInSchdule = false;
	local T_MarkToUpdate = {  };
	local function DelayUpdateHandler()
		B_isDelayUpdateInSchdule = false;
		for key, val in next, T_MarkToUpdate do
			T_MarkToUpdate[key] = nil;
			xpcall(method[key], geterrorhandler());
		end
	end
	local function ScheduleDelayUpdate(which)
		T_MarkToUpdate[which] = true;
		if not B_isDelayUpdateInSchdule then
			B_isDelayUpdateInSchdule = true;
			C_Timer_After(0.1, DelayUpdateHandler);
		end
	end
	local function ScheduleDelayUpdateAll()
		T_MarkToUpdate.guild = true;
		T_MarkToUpdate.friend = true;
		T_MarkToUpdate.group = true;
		T_MarkToUpdate.battlenet = true;
		T_MarkToUpdate.who = true;
		if not B_isDelayUpdateInSchdule then
			B_isDelayUpdateInSchdule = true;
			C_Timer_After(0.1, DelayUpdateHandler);
		end
		method.unit('player');
		method.unit('target');
		method.unit('focus');
		method.unit('mouseover');
	end
	--		GUILD
	local B_HaltingGuildProcess = false;
	local B_isGuildProcessRunning = false;
	local function GuildProcessHandler()
		if not B_HaltingGuildProcess then
			C_Timer_After(1.0, GuildProcessHandler);
		else
			B_isGuildProcessRunning = false;
		end
		if _isInGuild then
			if _db.WelToGuild and next(_tGuildMsgQueue) ~= nil then
				local now = time();
				for fullName, val in next, _tGuildMsgQueue do
					if now >= val[1] then
						_tGuildMsgQueue[fullName] = nil;
						SendChatMessage(val[2], "GUILD");
					end
				end
			end
			if next(_tGuildPreQueue) ~= nil then
				GuildRoster();
			end
		end
	end
	--		CHAT_MSG_SYSTEM
	local _ERR_GUILD_JOIN_S = nil;
	local _ERR_GUILD_LEAVE_S = nil;
	local _ERR_GUILD_REMOVE_SS = nil;
	local _WHO_LIST_FORMAT = nil;
	local _WHO_LIST_GUILD_FORMAT = nil;
	local _PATJOIN = nil;
	local _PATLEAVE = nil;
	local _PATREMOVED = nil;
	local _PATWHO = nil;
	local _PATWHOG = nil;
	local _tLineCache = {  };
	local function ProcessSystemMessage(msg, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, line, ...)
		if _tLineCache[line] ~= nil then
			return;
		end
		_tLineCache[line] = true;
		if _db.WelToGuild then
			local name = nil;
			--	join
			if _ERR_GUILD_JOIN_S ~= ERR_GUILD_JOIN_S then
				_ERR_GUILD_JOIN_S = ERR_GUILD_JOIN_S;
				_PATJOIN = gsub(_ERR_GUILD_JOIN_S, "%%s", "(.+)");
			end
			name = strmatch(msg, _PATJOIN);
			if name ~= nil then
				local fullName = strmatch(name, "-") == nil and (name .. "-" .. _PREALM) or name;
				if fullName ~= _FULLPLAYER then
					if _tGuildMsgQueue[fullName] == nil then
						_tGuildPreQueue[fullName] = 8;
						if __private.__is_dev then
							print("Guild |cff00ff00add|r queue", fullName);
						end
					end
				end
				return true;
			end
			--	leave
			if _ERR_GUILD_LEAVE_S ~= ERR_GUILD_LEAVE_S then
				_ERR_GUILD_LEAVE_S = ERR_GUILD_LEAVE_S;
				_PATLEAVE = gsub(_ERR_GUILD_LEAVE_S, "%%s", "(.+)");
			end
			name = strmatch(msg, _PATLEAVE);
			if name ~= nil then
				local fullName = strmatch(name, "-") == nil and (name .. "-" .. _PREALM) or name;
				_tGuildMsgQueue[fullName] = nil;
				_tGuildPreQueue[fullName] = nil;
				return;
			end
			--	kicked
			if _ERR_GUILD_REMOVE_SS ~= ERR_GUILD_REMOVE_SS then
				_ERR_GUILD_REMOVE_SS = _ERR_GUILD_REMOVE_SS;
				_PATREMOVED = gsub(ERR_GUILD_REMOVE_SS, "%%s", "(.+)");
			end
			name = strmatch(msg, _PATREMOVED);
			if name ~= nil then
				local fullName = strmatch(name, "-") == nil and (name .. "-" .. _PREALM) or name;
				_tGuildMsgQueue[fullName] = nil;
				_tGuildPreQueue[fullName] = nil;
				return;
			end
		end
		if _db.ShowLevel then
			--	who
			if _WHO_LIST_GUILD_FORMAT ~= WHO_LIST_GUILD_FORMAT then
				_WHO_LIST_GUILD_FORMAT = WHO_LIST_GUILD_FORMAT;
				_PATWHOG = gsub(gsub(_WHO_LIST_GUILD_FORMAT, "[%^%$%%%.%+%-%*%?%[%]%(%)]", "%%%1"), "%%%%[ds]", "(.+)");
			end
			local name, nameApp, level, race, classStr, guild, area = strmatch(msg, _PATWHOG);
			if name ~= nil then
				level = tonumber(level);
				local class = LOCALIZED_CLASS_NAMES_HASH[classStr];
				if level ~= nil and class ~= nil then
					local fullName = strmatch(name, "-") == nil and (name .. "-" .. _PREALM) or name;
					AddPlayerInfo(fullName, nil, class, level, 'who', time());
				end
				return;
			end
			if _WHO_LIST_FORMAT ~= WHO_LIST_FORMAT then
				_WHO_LIST_FORMAT = WHO_LIST_FORMAT;
				_PATWHO = gsub(gsub(_WHO_LIST_FORMAT, "[%^%$%%%.%+%-%*%?%[%]%(%)]", "%%%1"), "%%%%[ds]", "(.+)");
			end
			local name, nameApp, level, race, classStr, area = strmatch(msg, _PATWHO);
			if name ~= nil then
				level = tonumber(level);
				local class = LOCALIZED_CLASS_NAMES_HASH[classStr];
				if level ~= nil and class ~= nil then
					local fullName = strmatch(name, "-") == nil and (name .. "-" .. _PREALM) or name;
					AddPlayerInfo(fullName, nil, class, level, 'who', time());
				end
				return;
			end
		end
	end
	--
	local function OnEvent(self, event, ...)
		if event == "UPDATE_MOUSEOVER_UNIT" then
			method.unit('mouseover');
		elseif event == "PLAYER_TARGET_CHANGED" then
			method.unit('target');
		elseif event == "UNIT_NAME_UPDATE" or event == "UNIT_LEVEL" then
			method.unit(...);
			if IsInGroup() then
				ScheduleDelayUpdate('group');
			end
		elseif event == "TRADE_SHOW" then
			method.unit('npc');
		elseif event == "NAME_PLATE_UNIT_ADDED" then
			method.unit(...);
		elseif event == "CHAT_MSG_SYSTEM" then
			if ProcessSystemMessage(...) and not B_isGuildProcessRunning then
				B_isGuildProcessRunning = true;
				GuildProcessHandler();
			end
		elseif event == "FRIENDLIST_UPDATE" then
			ScheduleDelayUpdate('friend');
		elseif event == "GROUP_ROSTER_UPDATE" then
			ScheduleDelayUpdate('group');
		elseif event == "BN_CONNECTED" or event == "BN_FRIEND_LIST_SIZE_CHANGED" or event == "BN_FRIEND_INFO_CHANGED" then
			ScheduleDelayUpdate('battlenet');
		elseif event == "WHO_LIST_UPDATE" then
			ScheduleDelayUpdate('who');
		elseif event == "PLAYER_GUILD_UPDATE" then
			if IsInGuild() then
				if not _isInGuild then
					_isInGuild = true;
					_GUILD = GetGuildInfo('player');
					ScheduleDelayUpdate('guild');
				end
			else
				_isInGuild = false;
			end
		elseif event == "GUILD_ROSTER_UPDATE" then
			if _isInGuild then
				ScheduleDelayUpdate('guild');
			end
		elseif event == "PLAYER_LEVEL_CHANGED" then
			local _;
			_, _PLEVEL = ...;
		else
			-- print(event);
			if IsInGuild() then
				_isInGuild = true;
				_GUILD = GetGuildInfo('player');
			else
				_isInGuild = false;
			end
			self:UnregisterEvent(event);
		end
	end
-->

-->		Init
	local B_Initialized = false;
	local function Init()
		B_Initialized = true;
		_Driver = CreateFrame('FRAME');
		_Driver:SetScript("OnEvent", OnEvent);
	end
	local __GetPlayerLink = nil;
	local function HookGetPlayerLink()
		if __GetPlayerLink == nil then
			__GetPlayerLink = _G.GetPlayerLink;
			function _G.GetPlayerLink(fullName, nameApp, lineId, cType, cTarget, ...)
				local short, realm = strsplit("-", fullName);
				-- local name = Ambiguate(fullName, 'none');
				fullName = realm == nil and (short .. "-" .. _PREALM) or fullName;
				local info = _tPlayerInfo[fullName];
				if _db.ShowLevel and info ~= nil and info[3] > 0 then
					local level = nil;
					local diff = _PLEVEL - info[3];
					if diff >= 10 then
						level = "|cff00ff00" .. info[3] .. "|r";
					elseif diff > 0 then
						level = format("|cff%.2xff00%d|r", diff * 25.5, info[3]);
					elseif diff == 0 then
						level = "|cffffff00" .. info[3] .. "|r";
					elseif diff > -10 then
						level = format("|cffff%.2x00%d|r", 255 + diff * 25.5, info[3]);
					else
						level = "|cffff0000" .. info[3] .. "|r";
					end
					local pat = gsub(fullName, "[%%%.%+%-%*%?%[%]%(%)%^%$]", "%%%1");
					if strmatch(nameApp, pat) ~= nil then
						local repl = _db.ShowSubGroup and _tSubGroup[fullName] ~= nil and format(__PLFStr_LI, fullName, level, _tSubGroup[fullName]) or format(__PLFStr_L, fullName, level, "");
						nameApp = gsub(nameApp, pat, repl);
					elseif strmatch(nameApp, short) ~= nil then
						local repl = _db.ShowSubGroup and _tSubGroup[fullName] ~= nil and format(__PLFStr_LI, short, level, _tSubGroup[fullName]) or format(__PLFStr_L, short, level, "");
						nameApp = gsub(nameApp, short, repl);
					end
					-- if _db.ShowSubGroup and _tSubGroup[fullName] ~= nil then
					-- 	nameApp = gsub(nameApp, name, format(__PLFStr_LI, name, level, _tSubGroup[fullName]));
					-- else
					-- 	nameApp = gsub(nameApp, name, format(__PLFStr_L, name, level, ""));
					-- end
					return "|Hplayer:" .. fullName .. ":" .. (lineId or 0) .. ":" .. (cType or 0) .. ":" .. (cTarget or "") .. "|h" .. nameApp .. "|h";
				elseif _db.ShowSubGroup and _tSubGroup[fullName] ~= nil then
					local pat = gsub(fullName, "[%%%.%+%-%*%?%[%]%(%)%^%$]", "%%%1");
					if strmatch(nameApp, pat) ~= nil then
						local repl = format(__PLFStr_I, fullName, "", _tSubGroup[fullName]);
						nameApp = gsub(nameApp, pat, repl);
					elseif strmatch(nameApp, short) ~= nil then
						local repl = format(__PLFStr_I, short, "", _tSubGroup[fullName]);
						nameApp = gsub(nameApp, short, repl);
					end
					-- nameApp = gsub(nameApp, name, format(__PLFStr_I, name, "", _tSubGroup[fullName]));
					return "|Hplayer:" .. fullName .. ":" .. (lineId or 0) .. ":" .. (cType or 0) .. ":" .. (cTarget or "") .. "|h" .. nameApp .. "|h";
				else
					return __GetPlayerLink(fullName, nameApp, lineId, cType, cTarget, ...);
				end
			end
		end
	end
	local function CheckState()
		if _db.ShowLevel then
			if _Driver ~= nil then
				_Driver:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
				_Driver:RegisterEvent("PLAYER_TARGET_CHANGED");
				_Driver:RegisterEvent("UNIT_NAME_UPDATE");
				_Driver:RegisterEvent("UNIT_LEVEL");
				_Driver:RegisterEvent("TRADE_SHOW");
				_Driver:RegisterEvent("NAME_PLATE_UNIT_ADDED");
				_Driver:RegisterEvent("CHAT_MSG_SYSTEM");
				_Driver:RegisterEvent("FRIENDLIST_UPDATE");
				_Driver:RegisterEvent("GROUP_ROSTER_UPDATE");
				_Driver:RegisterEvent("BN_CONNECTED");
				_Driver:RegisterEvent("BN_FRIEND_LIST_SIZE_CHANGED");
				_Driver:RegisterEvent("BN_FRIEND_INFO_CHANGED");
				_Driver:RegisterEvent("WHO_LIST_UPDATE");
				_Driver:RegisterUnitEvent("PLAYER_GUILD_UPDATE", 'player');
				_Driver:RegisterEvent("GUILD_ROSTER_UPDATE");
				if IsInGuild() then
					_isInGuild = true;
					_GUILD = GetGuildInfo('player');
				else
					_isInGuild = false;
				end
				_Driver:RegisterEvent("PLAYER_LEVEL_CHANGED");
			else
				if IsInGuild() then
					_isInGuild = true;
					_GUILD = GetGuildInfo('player');
				else
					_isInGuild = false;
				end
			end
			B_HaltingGuildProcess = false;
			if not B_isGuildProcessRunning then
				B_isGuildProcessRunning = true;
				GuildProcessHandler();
			end
			ScheduleDelayUpdateAll();
		elseif _db.WelToGuild or _db.ShowSubGroup then
			if _Driver ~= nil then
				_Driver:UnregisterEvent("UPDATE_MOUSEOVER_UNIT");
				_Driver:UnregisterEvent("PLAYER_TARGET_CHANGED");
				_Driver:UnregisterEvent("TRADE_SHOW");
				_Driver:UnregisterEvent("NAME_PLATE_UNIT_ADDED");
				_Driver:UnregisterEvent("FRIENDLIST_UPDATE");
				_Driver:UnregisterEvent("BN_CONNECTED");
				_Driver:UnregisterEvent("BN_FRIEND_LIST_SIZE_CHANGED");
				_Driver:UnregisterEvent("BN_FRIEND_INFO_CHANGED");
				_Driver:UnregisterEvent("WHO_LIST_UPDATE");
				_Driver:UnregisterEvent("PLAYER_LEVEL_CHANGED");
			end
			if _db.WelToGuild then
				if _Driver ~= nil then
					_Driver:RegisterUnitEvent("PLAYER_GUILD_UPDATE", 'player');
					_Driver:RegisterEvent("GUILD_ROSTER_UPDATE");
					-- _Driver:RegisterEvent("PLAYER_ENTERING_WORLD");
					if IsInGuild() then
						_isInGuild = true;
						_Driver:RegisterEvent("CHAT_MSG_SYSTEM");
						_GUILD = GetGuildInfo('player');
					else
						_isInGuild = false;
						_Driver:UnregisterEvent("CHAT_MSG_SYSTEM");
					end
				else
					if IsInGuild() then
						_isInGuild = true;
						_GUILD = GetGuildInfo('player');
					else
						_isInGuild = false;
					end
				end
				_tGuildMsgQueue = {  };
				B_HaltingGuildProcess = false;
				if not B_isGuildProcessRunning then
					B_isGuildProcessRunning = true;
					GuildProcessHandler();
				end
				ScheduleDelayUpdate('guild');
			else
				if _Driver ~= nil then
					_Driver:UnregisterEvent("PLAYER_GUILD_UPDATE");
					_Driver:UnregisterEvent("GUILD_ROSTER_UPDATE");
					-- _Driver:UnregisterEvent("PLAYER_ENTERING_WORLD");
					_Driver:UnregisterEvent("CHAT_MSG_SYSTEM");
				end
				_tGuildPreQueue = {  };
				_tGuildMsgQueue = {  };
				if B_isGuildProcessRunning then
					B_HaltingGuildProcess = true;
				end
			end
			if _db.ShowSubGroup then
				if _Driver ~= nil then
					_Driver:RegisterEvent("UNIT_NAME_UPDATE");
					_Driver:RegisterEvent("UNIT_LEVEL");
					_Driver:RegisterEvent("GROUP_ROSTER_UPDATE");
				end
				ScheduleDelayUpdate('group');
			else
				if _Driver ~= nil then
					_Driver:UnregisterEvent("UNIT_NAME_UPDATE");
					_Driver:UnregisterEvent("UNIT_LEVEL");
					_Driver:UnregisterEvent("GROUP_ROSTER_UPDATE");
				end
			end
		else
			if _Driver ~= nil then
				_Driver:UnregisterEvent("UPDATE_MOUSEOVER_UNIT");
				_Driver:UnregisterEvent("PLAYER_TARGET_CHANGED");
				_Driver:UnregisterEvent("UNIT_NAME_UPDATE");
				_Driver:UnregisterEvent("UNIT_LEVEL");
				_Driver:UnregisterEvent("TRADE_SHOW");
				_Driver:UnregisterEvent("NAME_PLATE_UNIT_ADDED");
				_Driver:UnregisterEvent("FRIENDLIST_UPDATE");
				_Driver:UnregisterEvent("GROUP_ROSTER_UPDATE");
				_Driver:UnregisterEvent("BN_CONNECTED");
				_Driver:UnregisterEvent("BN_FRIEND_LIST_SIZE_CHANGED");
				_Driver:UnregisterEvent("BN_FRIEND_INFO_CHANGED");
				_Driver:UnregisterEvent("WHO_LIST_UPDATE");
				_Driver:UnregisterEvent("PLAYER_GUILD_UPDATE");
				_Driver:UnregisterEvent("GUILD_ROSTER_UPDATE");
				_Driver:UnregisterEvent("CHAT_MSG_SYSTEM");
				_Driver:UnregisterEvent("PLAYER_LEVEL_CHANGED");
			end
			_tGuildPreQueue = {  };
			_tGuildMsgQueue = {  };
			if B_isGuildProcessRunning then
				B_HaltingGuildProcess = true;
			end
		end
	end
-->

-->		Module
	function __companion.SavedInDB(value, loading)
		if not loading then
			_db._tPlayerInfo = value and _tPlayerInfo or nil;
		end
	end
	function __companion.ShowLevel(value, loading)
		if value then
			if not B_Initialized then
				Init();
			end
			HookGetPlayerLink();
		end
		CheckState();
		InitPlayerLinkFormatStr();
	end
	function __companion.ShowSubGroup(value, loading)
		if value then
			if not B_Initialized then
				Init();
			end
			HookGetPlayerLink();
		end
		CheckState();
		InitPlayerLinkFormatStr();
	end
	function __companion.PlayerLinkFormat(value, loading)
		if not loading then
			InitPlayerLinkFormatStr();
		end
	end
	function __companion.WelToGuild(value, loading)
		if value then
			if not B_Initialized then
				Init();
			end
			InitWelWelStrList();
			if _db.NewMemberNotice then
				InitNoticeStr();
			end
		end
		CheckState();
	end
	function __companion.WelToGuildStrSet(value, loading)
		if not loading then
			InitWelWelStrList();
		end
	end
	function __companion.NewMemberNotice(value, loading)
		if not loading then
			InitNoticeStr();
		end
	end
	function __companion.NewMemberNoticeStr(value, loading)
		if not loading then
			InitNoticeStr();
		end
	end
	function __companion.__init(db, loading)
		_db = db;
		if _db.SavedInDB then
			if _db._tPlayerInfo ~= nil then
				_tPlayerInfo = _db._tPlayerInfo;
				local expired = time() + 3600;
				local minLv = 60;
				for fullName, info in next, _tPlayerInfo do
					if info[3] < minLv and info[4] < expired then
						_tPlayerInfo[fullName] = nil;
					end
				end
				if _tPlayerInfo['*'] == nil then
					local old = _tPlayerInfo;
					_tPlayerInfo = {
						['*'] = { 1.0, "ALA", 65535, 4294967295, },
					};
					_db._tPlayerInfo = _tPlayerInfo;
					local _, R, _ = strsplit("-", UnitGUID('player'));
					for _name, _info in next, old do
						local GUID = _info[1];
						if GUID ~= nil then
							local _, r, _ = strsplit("-", GUID);
							if R == r then
								if strmatch(_name, "-") == nil then
									_tPlayerInfo[_name .. "-" .. _PREALM] = _info;
								else
									_tPlayerInfo[_name] = _info;
								end
								old[_name] = nil;
							else
								local _, class, _, race, gender, name, realm = GetPlayerInfoByGUID(GUID);
								if name ~= nil and name ~= "" and realm ~= nil and realm ~= "" then
									_tPlayerInfo[name .. "-" .. realm] = _info;
									old[_name] = nil;
								end
							end
						else
							old[_name] = nil;
						end
					end
					if next(old) ~= nil then
						local Ticker = nil;
						local function func()
							for _name, _info in next, old do
								local GUID = _info[1];
								local _, class, _, race, gender, name, realm = GetPlayerInfoByGUID(GUID);
								if name ~= nil and name ~= "" and realm ~= nil and realm ~= "" then
									local fullName = name .. "-" .. realm;
									if _tPlayerInfo[fullName] ~= nil then
										_tPlayerInfo[name .. "-" .. realm] = _info;
									end
									old[_name] = nil;
								end
							end
							if next(old) == nil then
								print("|cffff0000alachat db upgraded|r")
								Ticker:Cancel();
							end
						end
						Ticker = C_Timer.NewTicker(2.0, func);
					else
						print("|cffff0000alachat db upgraded|r")
					end
				end
			else
				_db._tPlayerInfo = _tPlayerInfo;
			end
		end
	end

	function __companion.__callback(which, value, loading)
		if __companion[which] ~= nil then
			return __companion[which](value, loading);
		end
	end
	function __companion.__setting()
		__private:AddSetting("COMPANION", { "companion", "SavedInDB", 'boolean', });
		__private:AddSetting("COMPANION", { "companion", "ShowLevel", 'boolean', });
		__private:AddSetting("COMPANION", { "companion", "ShowSubGroup", 'boolean', });
		-- __private:AddSetting("COMPANION", { "companion", "PlayerLinkFormat", 'editor', "PlayerLinkFormattip", }, 1);
		__private:AddSetting("COMPANION", { "companion", "PlayerLinkFormat", 'input-list',
			{
				"#INDEX.##NAME##LEVEL#", "#INDEX.##NAME##:LEVEL#", "#INDEX.##NAME##(LEVEL)#",
				"#(INDEX)##NAME##LEVEL#", "#(INDEX)##NAME##:LEVEL#",
				"#LEVEL:##NAME## INDEX#"
			},
			nil,
			nil,
			function(val)
				return format(__PLFStr_LI, "Alex", 1, "|cffffff0070|r");
			end,
		}, 1);
		--
		__private:AlignSetting("COMPANION", 0.5);
		__private:AddSetting("COMPANION", { "companion", "WelToGuild", 'boolean', });
		__private:AddSetting("COMPANION", { "companion", "WelToGuildStrSet", 'editor', "WelToGuildStrSetTip", }, 1);
		__private:AddSetting("COMPANION", { "companion", "WelToGuildDelay", 'boolean', }, 1);
		__private:AddSetting("COMPANION", { "companion", "NewMemberNotice", 'boolean', }, 1);
		__private:AddSetting("COMPANION", { "companion", "NewMemberNoticeStr", 'editor', "NewMemberNoticeStrTip", }, 2);
	end

	__private.__module["companion"] = __companion;
-->
