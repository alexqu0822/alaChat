--[=[
	FILTERMANAGER
--]=]

local __addon, __private = ...;
local L = __private.L;

local type = type;

local ChatFrame_AddMessageEventFilter, ChatFrame_RemoveMessageEventFilter = ChatFrame_AddMessageEventFilter, ChatFrame_RemoveMessageEventFilter;

--
local _FilterKeyList = {
	"chattypeblocked",
	"chatfilter",
	"chathyperlink",
	"emote",
	"highlight",
};
local _FilterKeyNum = #_FilterKeyList;
for index = 1, _FilterKeyNum do
	_FilterKeyList[_FilterKeyList[index]] = index;
end
local CHATTYPELIST = {
	"CHAT_MSG_CHANNEL",
	-- "CHAT_MSG_CHANNEL_JOIN",
	-- "CHAT_MSG_CHANNEL_LEAVE",
	"CHAT_MSG_COMMUNITIES_CHANNEL",
	"CHAT_MSG_SAY",
	"CHAT_MSG_YELL",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_BN_WHISPER_INFORM",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_OFFICER",
	-- "CHAT_MSG_AFK",
	"CHAT_MSG_EMOTE",
	-- "CHAT_MSG_DND",
};
local CHATTYPENUM = #CHATTYPELIST;
local _FilterFuncList = {  };
for index = 1, CHATTYPENUM do
	_FilterFuncList[CHATTYPELIST[index]] = {  };
end

if __private.__is_dev then
	__private:BuildEnv("_FilterManager");
end

function __private:AddMessageFilterAllChatTypes(which, Func)
	local POS = _FilterKeyList[which];
	if POS ~= nil then
		for index = 1, CHATTYPENUM do
			local Type = CHATTYPELIST[index];
			local FilterFunc = _FilterFuncList[Type];
			if FilterFunc[which] ~= Func then
				for j = POS, _FilterKeyNum do
					local Func2 = FilterFunc[_FilterKeyList[j]];
					if Func2 ~= nil then
						ChatFrame_RemoveMessageEventFilter(Type, Func2);
					end
				end
				ChatFrame_AddMessageEventFilter(Type, Func);
				FilterFunc[which] = Func;
				for j = POS + 1, _FilterKeyNum do
					local Func2 = FilterFunc[_FilterKeyList[j]];
					if Func2 ~= nil then
						ChatFrame_AddMessageEventFilter(Type, Func2);
					end
				end
			end
		end
	end
end
function __private:DelMessageFilterAllChatTypes(which)
	if _FilterKeyList[which] ~= nil then
		for index = 1, CHATTYPENUM do
			local Type = CHATTYPELIST[index];
			local FilterFunc = _FilterFuncList[Type];
			local Func = FilterFunc[which];
			if Func ~= nil then
				ChatFrame_RemoveMessageEventFilter(Type, Func);
				FilterFunc[which] = nil;
			end
		end
	end
end
function __private:AddMessageFilter(Type, which, Func)
	local POS = _FilterKeyList[which];
	if POS ~= nil then
		local FilterFunc = _FilterFuncList[Type];
		if FilterFunc[which] ~= Func then
			for j = POS, _FilterKeyNum do
				local Func2 = FilterFunc[_FilterKeyList[j]];
				if Func2 ~= nil then
					ChatFrame_RemoveMessageEventFilter(Type, Func2);
				end
			end
			ChatFrame_AddMessageEventFilter(Type, Func);
			FilterFunc[which] = Func;
			for j = POS, _FilterKeyNum do
				local Func2 = FilterFunc[_FilterKeyList[j]];
				if Func2 ~= nil then
					ChatFrame_AddMessageEventFilter(Type, Func2);
				end
			end
		end
	end
end
function __private:DelMessageFilter(Type, which)
	local FilterFunc = _FilterFuncList[Type];
	local Func = FilterFunc[which];
	if Func ~= nil then
		ChatFrame_RemoveMessageEventFilter(Type, Func);
		FilterFunc[which] = nil;
	end
end


--	__ala_meta__.chatv2.__dev:FilterPullAll()
function __private.__dev:FilterPullAll()
	for index = 1, #CHATTYPELIST do
		local Type = CHATTYPELIST[index];
		local _, _, T1, T2 = strsplit("_", Type);
		local T = strsub(T1, 1, 1) .. (T2 == nil and "_" or strsub(T2, 1, 1));
		local FilterFunc = _FilterFuncList[Type];
		local out = "";
		if index < 10 then
			out = out .. "0" .. index;
		else
			out = out .. index;
		end
		for j = 1, #_FilterKeyList do
			if FilterFunc[_FilterKeyList[j]] ~= nil then
				out = out .. "-" .. "|cff00ff00T|r";
			else
				out = out .. "-" .. "|cffff0000F|r";
			end
		end
		print(out);
	end
end
