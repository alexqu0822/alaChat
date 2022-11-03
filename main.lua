--[=[
	CORE
--]=]

local __addon, __private = ...;
__ala_meta__.chatv2 = __private;

local pcall, xpcall, geterrorhandler = pcall, xpcall, geterrorhandler;
local type = type;
local rawget, rawset = rawget, rawset;
local next = next;
local C_Timer = C_Timer;
local CreateFrame = CreateFrame;
local _G = _G;

__private.__toc = select(4, GetBuildInfo());
local __modulelist = {  };
local __module = setmetatable(
	{  },
	{
		__newindex = function(tbl, key, val)
			if type(val) == 'table' then
				__modulelist[#__modulelist + 1] = key;
			end
			rawset(tbl, key, val);
		end,
	}
);
function __module:callback(modulename, which, value, loading)
	local module = __module[modulename];
	if module ~= nil and module.__callback ~= nil then
		xpcall(module.__callback, geterrorhandler(), which, value, loading);
	end
end
__private.__module = __module;
__private.__dev = {  };

__private.__is_dev = select(2, GetAddOnInfo("!!!!!DebugMe")) ~= nil;
__private.__is_163 = select(2, GetAddOnInfo("!!!163UI!!!")) ~= nil;

__private.SELFGUID = UnitGUID('player');

__private.TEXTURE_PATH = [[Interface\AddOns\]] .. __addon .. [[\Media\Texture\]];

__private.PinTextFont = GameFontNormal:GetFont();
__private.PinTextBLZFont = NumberFont_Shadow_Med:GetFont();

-->		Dev
	local setfenv = setfenv;
	local rawset = rawset;
	local next = next;
	local _GlobalRef = {  };
	local _GlobalAssign = {  };
	function __private:BuildEnv(category)
		local _G = _G;
		_GlobalRef[category] = _GlobalRef[category] or {  };
		_GlobalAssign[category] = _GlobalAssign[category] or {  };
		local Ref = _GlobalRef[category];
		local Assign = _GlobalAssign[category];
		setfenv(2, setmetatable(
			{  },
			{
				__index = function(tbl, key, val)
					Ref[key] = (Ref[key] or 0) + 1;
					return _G[key];
				end,
				__newindex = function(tbl, key, value)
					rawset(tbl, key, value);
					Assign[key] = (Assign[key] or 0) + 1;
					return value;
				end,
			}
		));
	end
	function __private:MergeGlobal(DB)
		local _Ref = DB._GlobalRef;
		if _Ref ~= nil then
			for category, db in next, _Ref do
				local to = _GlobalRef[category];
				if to == nil then
					_GlobalRef[category] = db;
				else
					for key, val in next, db do
						to[key] = (to[key] or 0) + val;
					end
				end
			end
		end
		DB._GlobalRef = _GlobalRef;
		local _Assign = DB._GlobalAssign;
		if _Assign ~= nil then
			for category, db in next, _Assign do
				local to = _GlobalAssign[category];
				if to == nil then
					_GlobalAssign[category] = db;
				else
					for key, val in next, db do
						to[key] = (to[key] or 0) + val;
					end
				end
			end
		end
		DB._GlobalAssign = _GlobalAssign;
	end
-->

local L = __private.L;

local __default = {
	general = {
		detailedtip = true,
	},
	docker = {
		Position = "below.editbox",
		Direction = "RIGHT",
		AutoAdjustEditBox = true,
		alpha = 0.9,
		FadInTime = 0.5,
		FadedAlpha = 0.5,
		FadeOutTime = 2.0,
		FadeOutDelay = 1.0,
		Backdrop = true,
		BackdropColor = { 0.0, 0.0, 0.0, 0.0, },
		BackdropAlpha = 0.25,
		PinSize = 24,
		PinInt = 2,
		PinStyle = "char",
		XToBorder = 0,
		YToBorder = 0,
	},
	emote = {
		toggle = true,
		--
		IconInEditBox = false,
		PinStyle = "char",
	},
	channeltab = {
		toggle = true,
		--
		SAY = true,
		PARTY = true,
		RAID = true,
		RAID_WARNING = true,
		INSTANCE_CHAT = true,
		GUILD = true,
		YELL = true,
		WHISPER = false,
		OFFICER = false,
		GENERAL = true,
		TRADE = true,
		LOCAL_DEFENSE = false,
		LOOK_FOR_GROUP = true,
		BF_WORLD = true,
		UNMANAGEDCHANNEL = true,
		_chatblocked = {  },
		_channelblocked = {  },
		_bfworldcf = {  },
		PinStyle = "char",
		UseColor = true,
		LeaveChannelModifier = "none",
		--
		AutoAddChannelToDefaultChatFrame = false,
		ChannelBlockButton_BLZ = true,
		ChannelBlockButton_World = true,
		ChannelBlockButton_Size = 28,
		AutoJoinWorld = false,	--	L.Locale == "zhCN" or L.Locale == "zhTW",
	},
	chatfilter = {
		toggle = true,
		--
		CaseInsensitive = true,
		StrSet = "",
		NameSet = "",
		Rep = true,
		RepInterval = 30,
		RepeatedSentence = true,
		ButtonInDock = true,
		PinStyle = "char",
		_TemporaryDisabled = false,
	},
	copy = {
		toggle = true,
		--
		format = (function()
			local fmt = GetCVar("showTimestamps");
			local fmt2 = strmatch(fmt, "|h(.+)|h");
			if fmt2 == nil then
				return fmt;
			elseif fmt2 == "*" then
				return "none";
			else
				return fmt2;
			end
		end)(),
		color = { 1.0, 0.5, 0.0, },
	},
	shortchattype = {
		toggle = true,
		--
		format = 'n.w',
	},
	highlight = {
		toggle = false,
		--
		CaseInsensitive = true,
		StrSet = "",
		color = { 0.0, 1,0, 0.0, },
		format = "#HL#",
		ShowMatchedOnly = false,
		["ShowMatchedOnly.CHANNEL"] = true,
		["ShowMatchedOnly.SAY-YELL"] = true,
		["ShowMatchedOnly.NORMAL"] = false,
		KeepShowMatchedOnly = false,
		ButtonInDock = true,
		PinStyle = "char",
		_TemporaryDisabled = false,
	},
	utils = {
		StatReport = true,
		DBMPull = true,
		DBMPullLen = 6,
		roll = true,
		ReadyCheck = true,
	},
	misc = {
		Font = ChatFontNormal:GetFont(),
		FontFlag = "none",
		ChatFrameToBorder = true,
		ColoredPlayerName = true,
		HoverHyperlink = true,
		ChatHyperlink = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE,
		TabChangeChatType = false,
		StickyWhisper = ChatTypeInfo["WHISPER"].sticky == 1,
		StickyBNWhisper = ChatTypeInfo["BN_WHISPER"].sticky == 1,
		StickyChannel = ChatTypeInfo["CHANNEL"].sticky == 1,
		ArrowKey = false,
		ArrowHistory = false,
	},
	companion = {
		ShowLevel = true,
		ShowSubGroup = true,
		PlayerLinkFormat = "#INDEX.##NAME##:LEVEL#",
		WelToGuild = false,
		WelToGuildStrSet = L.SETTING.companion["def.WelToGuildStrSet"],
		WelToGuildDelay = true,
		NewMemberNotice = false,
		NewMemberNoticeStr = L.SETTING.companion["def.NewMemberNoticeStr"],
	},
};
if L.Locale == 'zhCN' and WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
	__default.chatfilter.StrSet =
		"HclubTicket:\n航空\n航班\n专机\n直达\n直飞\n安全便捷\n收米\n出米\n托管\n公众号\n大米\n"
		-- .. "--------\n========\n~~~~~~\n````````\n········\n"		--	++++++++\n
		-- .. "........\n,,,,,,,,\n;;;;;;;;\n"							--	
		-- .. "。。。。。。。。\n，，，，，，，，\n；；；；；；；；\n"		--	
		-- .. "————\n一一一一\n"										--	
		-- .. "、、、、、、、、\n"										--	
	;
	__default.chatfilter.NameSet = "#加基森\n#冬泉谷\n#玛拉顿\n#斯坦索姆\n#航空\n#航班\n#飞机\n#专机\n#直达\n#直飞\n";
end
if __private.__is_163 then
	for _, v in next, __default do
		if v.PinStyle ~= nil then
			v.PinStyle = "char.blz";
		end
	end
	__default.channeltab.UseColor = false;
end

local __db = __default;

if __private.__is_dev then
	__private:BuildEnv("main");
end

-->		All ChatFrames
	local ChatFrames = {  };
	for index = 1, NUM_CHAT_WINDOWS do
		local F = _G["ChatFrame" .. index];
		ChatFrames[index] = F;
		F.__Tab = F.__Tab or _G["ChatFrame" .. index .. "Tab"];
		F.editBox = F.editBox or _G["ChatFrame" .. index .. "EditBox"];
	end
	__private.__chatFrames = ChatFrames;
-->

-->		Init
	local function CheckDB(db, def)
		for key, val in next, def do
			if type(val) == 'table' then
				if db[key] == nil then
					db[key] = val;
				else
					CheckDB(db[key], val);
				end
			else
				if db[key] == nil then
					db[key] = val;
				end
			end
		end
	end
	local function InitSingleModule(key, module)
		xpcall(module.__callback, geterrorhandler(), "__init", __db[key], true);
		local db = __db[key];
		if db == nil or db.toggle == true then
			xpcall(module.__callback, geterrorhandler(), "toggle", true, true);
		elseif db.toggle == false then
			xpcall(module.__callback, geterrorhandler(), "toggle", false, true);
		end
		if db ~= nil then
			for k, v in next, db do
				if k ~= "toggle" then
					xpcall(module.__callback, geterrorhandler(), k, v, true);
				end
			end
		end
		xpcall(module.__callback, geterrorhandler(), "__setting");
	end
	local function InitModules(when)
		local hasOne = false;
		for index = 1, #__modulelist do
			local key = __modulelist[index];
			local module = __module[key];
			if module.__initialized == nil and module.__initat == when then
				if module.__callback ~= nil then
					if module.__initafter == nil or module.__initafter() then
						InitSingleModule(key, module);
					else
						local function func()
							if module.__initafter() then
								InitSingleModule(key, module);
							else
								C_Timer.After(1.0, func);
							end
						end
						C_Timer.After(1.0, func);
					end
				end
				module.__initialized = true;
				hasOne = true;
			end
		end
		return hasOne;
	end
	local function DisableOldVersion()
		if _G.GLOBAL_CORE_SAVED ~= nil then
			for _, profile in next, GLOBAL_CORE_SAVED.profiles do
				if profile.addons_state ~= nil then
					profile.addons_state.alachat_classic = false;
				end
			end
			for _, profile in next, GLOBAL_CORE_SAVED.auto do
				if profile.addons_state ~= nil then
					profile.addons_state.alachat_classic = false;
				end
			end
		end
	end
	local function OldVersionCompatible(__db, enquiry)
		if select(2, GetAddOnInfo("alaChat_Classic")) ~= nil then
			local version = GetAddOnMetadata("alaChat_Classic", "Version");
			if __private.__is_dev then print("ACC Version", version); end
			if version >= "205r.210711" then
				EnableAddOn("alaChat_Classic");
				LoadAddOn("alaChat_Classic");
				local base = _G.alaBaseData;
				local old = _G.alaChatConfig;
				if enquiry and old ~= nil then
					__db.__upgraded = true;
					C_Timer.After(4.0, function()
						StaticPopup_Show("ALACHAT_UPGRADE", nil, nil, {  });
					end);
					return;
				end
				if base ~= nil then
					__db.docker.UserPlacedPosition = base.pos;
					_G.alaBaseData = nil;
				end
				if old ~= nil then
					__db.docker.Position = old["position"] == "BELOW_EDITBOX" and "below.editbox" or "above.editbox";	--	"BELOW_EDITBOX", "ABOVE_EDITOBX", "ABOVE_CHATFRAME"
					if old["channelBarStyle"] == "CIRCLE" then			--	"CHAR", "CIRCLE", "SQUARE"
						__db.docker.PinStyle = "circle.blur";
						__db.channeltab.PinStyle = "circle.blur";
						if old["barStyle"] == "blz" then	--	"ala", "blz"
							__db.channeltab.UseColor = false;
							__db.emote.PinStyle = "char.blz";
						else
							__db.channeltab.UseColor = true;
							__db.emote.PinStyle = "char";
						end
					elseif old["channelBarStyle"] == "SQUARE" then
						__db.docker.PinStyle = "square.blur";
						__db.channeltab.PinStyle = "square.blur";
						if old["barStyle"] == "blz" then
							__db.channeltab.UseColor = false;
							__db.emote.PinStyle = "char.blz";
						else
							__db.channeltab.UseColor = true;
							__db.emote.PinStyle = "char";
						end
					elseif old["barStyle"] == "blz" then
						__db.docker.PinStyle = "char.blz";
						__db.channeltab.PinStyle = "char.blz";
						__db.channeltab.UseColor = false;
						__db.emote.PinStyle = "char.blz";
					else
						__db.docker.PinStyle = "char";
						__db.channeltab.PinStyle = "char";
						__db.channeltab.UseColor = true;
						__db.emote.PinStyle = "char";
					end
					__db.docker.Direction = old["direction"] == "HORIZONTAL" and "RIGHT" or "DOWN";					--	"HORIZONTAL", "VERTICAL"
					__db.docker.PinSize = floor(24 * (old["scale"] or 1.0) + 0.5);
					__db.docker.alpha = old["alpha"] and (old["alpha"] - old["alpha"] % 0.01) or 1.0;
					-- __db.shortchattype.toggle = not not old["shortChannelName"];
					if old["shortChannelNameFormat"] == "N" then
						__db.shortchattype.format = "n";
					elseif old["shortChannelNameFormat"] == "W" then
						__db.shortchattype.format = "w";
					else--if old["shortChannelNameFormat"] == "NW" then
						__db.shortchattype.format = "n.w";
					end
					-- __db.emote.toggle = not not (old["chatEmote"] or old["chatEmote_channel"]);
					__db.utils.StatReport = not not old["statReport"];
					__db.misc.ChatHyperlink = not not old["hyperLinkEnhanced"];
					__db.misc.ColoredPlayerName = not not old["ColorNameByClass"];
					--	shamanColor
					local channelBarChannel = old["channelBarChannel"];
					if channelBarChannel ~= nil then
						local list = { "SAY", "PARTY", "RAID", "RAID_WARNING", "INSTANCE_CHAT", "GUILD", "YELL", "WHISPER", "OFFICER", "GENERAL", "TRADE", "LOCAL_DEFENSE", "LOOK_FOR_GROUP", "BF_WORLD" };
						for index = 1, #channelBarChannel do
							__db.channeltab[list[index]] = not not channelBarChannel[index];
						end
					end
					__db.channeltab.ChannelBlockButton_BLZ = not not old["channel_Ignore_Switch"];
					__db.channeltab.ChannelBlockButton_World = not not old["bfWorld_Ignore_Switch"];
					__db.channeltab.ChannelBlockButton_Size = floor((old["channel_Ignore_BtnSize"] or 27.9) + 0.5);
					__db.copy.toggle = not not old["copy"];
					__db.copy.color = old["copyTagColor"] or __db.copy.color;
					__db.copy.format = old["copyTagFormat"];
					__db.companion.NewMemberNotice = not not old["broadCastNewMember"];
					__db.companion.WelToGuild = not not old["welcomeToGuild"];
					__db.companion.WelToGuildStrSet = old["welcometoGuildMsg"] or __db.companion.WelToGuildStrSet;
					__db.utils.roll = not not old["roll"];
					__db.utils.DBMPull = not not old["DBMCountDown"];
					__db.utils.ReadyCheck = not not old["ReadyCheck"];
					__db.companion.ShowLevel = not not old["level"];
					__db.misc.TabChangeChatType = not not old["editBoxTab"];
					__db.misc.StickyWhisper = not not old["restoreAfterWhisper"];
					__db.misc.StickyBNWhisper = not not old["restoreAfterWhisper"];
					__db.misc.StickyChannel = not not old["restoreAfterChannel"];
					__db.misc.HoverHyperlink = not not old["hyperLinkHoverShow"];
					__db.highlight.toggle = not not old["keyWordHighlight"];
					__db.highlight.StrSet = old["keyWord"] or __db.highlight.StrSet;
					__db.highlight.color = old["keyWordColor"] or __db.highlight.color;
					__db.highlight.ShowMatchedOnly = not not old["keyWordHighlight_Exc"];
					__db.chatfilter.toggle = not not old["chat_filter"];
					local OldFilteredSet = old["chat_filter_word"];
					if OldFilteredSet ~= nil and OldFilteredSet ~= "" then
						local defStrSet = gsub(gsub(gsub(__default.chatfilter.StrSet, "^[\t\n ]+", ""), "[\t\n ]+$", ""), "\n\n", "\n");
						local defNameSet = gsub(gsub(gsub(__default.chatfilter.NameSet, "^[\t\n ]+", ""), "[\t\n ]+$", ""), "\n\n", "\n");
						local defStr = { strsplit("\n", defStrSet) };
						local defName = { strsplit("\n", defNameSet) };
						--
						local oldDefSet = GetLocale() == "zhCN" and ("HclubTicket:\n航空\n航班\n飞机\n专机\n直达\n直飞\n安全便捷\n拉人\n收米\n出米\n托管\n包团\n实惠\n公众号\nG团\n老板\n大米\n"
							.. "++++++\n————\n一一一一\n~~~~~~\n------\n======\n``````\n"
							.. "!!!!!!!!!!\n??????????\n！！！！！！！！！！\n？？？？？？？？？？\n。。。。。。。。。。\n，，，，，，，，，，\n··········\n；；；；；；；；；；\n、、、、、、、、、、\n"
							.. "#加基森\n#冬泉谷\n#玛拉顿\n#斯坦索姆\n#航空\n#飞机\n#专机\n#直达\n#直飞\n") or "HclubTicket:\n\n++++++\n——————\n~~~~~~\n------\n======\n``````\n";
						oldDefSet = gsub(gsub(gsub(oldDefSet, "^[\t\n ]+", ""), "[\t\n ]+$", ""), "\n\n", "\n");
						local oldDef = { strsplit("\n", oldDefSet) };
						OldFilteredSet = gsub(gsub(gsub(OldFilteredSet, "^[\t\n ]+", ""), "[\t\n ]+$", ""), "\n\n", "\n");
						local oldf = { strsplit("\n", OldFilteredSet) };
						--
						local defStrH = {  };
						local defNameH = {  };
						local oldDefH = {  };
						for i = 1, #defStr do defStrH[defStr[i]] = true; end
						for i = 1, #defName do defNameH[defName[i]] = true; end
						for i = 1, #oldDef do oldDefH[oldDef[i]] = true; end
						--
						for i = 1, #oldf do
							local w = oldf[i];
							print(w, oldDefH[w], defNameH[w], defStrH[w])
							if oldDefH[w] == nil then
								if strsub(w, 1, 1) == "#" then
									if defNameH[w] == nil then
										defName[#defName + 1] = w;
									end
								else
									if defStrH[w] == nil then
										defStr[#defStr + 1] = w;
									end
								end
							end
						end
						__db.chatfilter.StrSet = table.concat(defStr, "\n");
						__db.chatfilter.NameSet = table.concat(defName, "\n");
					end
					__db.chatfilter.Rep = old["chat_filter_rep_interval"] ~= nil and old["chat_filter_rep_interval"] > 0 or false;
					__db.chatfilter.RepInterval= old["chat_filter_rep_interval"] ~= nil and old["chat_filter_rep_interval"] > 0 and old["chat_filter_rep_interval"] or __db.chatfilter.RepInterval;
					__db.chatfilter.RepeatedSentence = not not old["chat_filter_repeated_words"];
					_G.alaChatConfig = nil;
				end
				DisableAddOn("alaChat_Classic");
				SaveAddOns();
			else
				DisableAddOn("alaChat_Classic");
				SaveAddOns();
			end
		end
		__db.__upgraded = true;
	end
	StaticPopupDialogs['ALACHAT_UPGRADE'] = {
		preferredIndex = 3,
		text = L["Find profiles of alaChat_Classic. Do you want to upgrade it and overwrite current setting?"],
		button1 = YES,
		button2 = NO,
		OnAccept = function(self, data)
			OldVersionCompatible(__db);
			_G.alaBaseData = nil;
			_G.alaChatConfig = nil;
			ReloadUI();
		end,
		hideOnEscape = 1,
		timeout = 0,
		exclusive = 1,
		whileDead = 1,
	};
	local function InitDB()
		__db = _G.alaChatSV;
		if __db == nil then
			__db = {  };
			local function CopyTable(dst, src)
				for k, v in next, src do
					if type(v) == 'table' then
						dst[k] = {  };
						CopyTable(dst[k], v);
					else
						dst[k] = v;
					end
				end
			end
			CopyTable(__db, __default);
			_G.alaChatSV = __db;
			OldVersionCompatible(__db);
			__db.__AppliedDBVersion = {  };
		else
			if __db.__upgraded ~= true then
				OldVersionCompatible(__db, true);
			end
			if __db.__version == nil or __db.__version < 210711.04 then
				if L.Locale == 'zhCN' then
					__db.chatfilter.StrSet = __db.chatfilter.StrSet ~= nil and gsub(__db.chatfilter.StrSet, "\n拉人\n", "\n") or "";
				end
			end
			if __db.__version < 210726.01 then
				__db.channeltab.AutoAddChannelToDefaultChatFrame = false;
				__db.channeltab._bfworldcf = {  };
			end
			if __db.__version < 220118.01 then
				local StrSet = __db.highlight.StrSet;
				if StrSet ~= nil then
					__db.highlight.StrSet = gsub(StrSet, "#[^\n]+\n", "");
				end
			end
			if __db.__version < 221020.01 then
				__db.__AppliedDBVersion = {  };
			end
		end
		DisableOldVersion();
		__db.__version = 221020.01;
		CheckDB(__db, __default);
		if not __db.highlight.KeepShowMatchedOnly then
			__db.highlight.ShowMatchedOnly = false;
		end
		__private.__db = __db;
		__private:MergeGlobal(__db);
		if __db.__overridedev == false then
			__private.__is_dev = false;
		end
	end
-->

local _TriggeredEvents = {  };
local _Driver = CreateFrame('FRAME');
_Driver:RegisterEvent("ADDON_LOADED");
-- _Driver:RegisterEvent("PLAYER_ENTERING_WORLD");
_Driver:RegisterEvent("LOADING_SCREEN_DISABLED");
_Driver:RegisterEvent("ZONE_CHANGED_NEW_AREA");
_Driver:SetScript("OnEvent", function(self, event, param)
	if event == "ADDON_LOADED" then
		if param == __addon then
			self:UnregisterEvent("ADDON_LOADED");
			InitDB();
			__private:InitSettingUI(__db, __default, __modulelist, __module);
			InitModules();
			for index = 1, #__modulelist do
				local key = __modulelist[index];
				local module = __module[key];
				if module.__initat ~= nil then
					pcall(_Driver.RegisterEvent, _Driver, module.__initat);
					_TriggeredEvents[module.__initat] = false;
				end
			end
		end
	else
		self:UnregisterEvent(event);
		InitModules(event);
		_TriggeredEvents[event] = true;
		if event == "LOADING_SCREEN_DISABLED" then
			C_Timer.After(8, function()
				for event, triggered in next, _TriggeredEvents do
					if triggered ~= true then
						if InitModules(event) and __private.__is_dev then
							print("|cff00ff00Manal Trigger " .. tostring(event));
						end
					end
				end
			end);
			__db.__AppliedDBVersion = __db.__AppliedDBVersion or {  };
			if __db.__AppliedDBVersion[__private.SELFGUID] == nil or __db.__AppliedDBVersion[__private.SELFGUID] < 221020.01 then
				__db.__AppliedDBVersion[__private.SELFGUID] = 221020.01;
				C_Timer.After(2, function()
					if __db.misc.ColoredPlayerName then
						__private.__module["misc"].ColoredPlayerName(true);
					end
				end);
			end
		end
	end
end);

