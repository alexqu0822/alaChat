--	TODO Bingding
local __addon, __private = ...;
local L = __private.L;

local SHORTNAME_NORMALGLOBALFORMAT = L.SHORTNAME_NORMALGLOBALFORMAT;
local SHORTNAME_CHANNELHASH = L.SHORTNAME_CHANNELHASH;

local next = next;
local strmatch = string.match;
local _G = _G;
local ChatFrame_ResolveChannelName = ChatFrame_ResolveChannelName;

local __shortchattype = {  };
local _db = {  };

local chat_global_format_backup = {  };

if __private.__is_dev then
	__private:BuildEnv("shortchattype");
end

-->		Method
	-- Detect which API is available (11.2+ uses ChatFrameUtil namespace)
	local OriginalResolvePrefixedChannelName = (ChatFrameUtil and ChatFrameUtil.ResolvePrefixedChannelName) or _G.ChatFrame_ResolvePrefixedChannelName;
	local UseChatFrameUtil = ChatFrameUtil and ChatFrameUtil.ResolvePrefixedChannelName ~= nil;
	
	-- Helper: Resolve channel name to short form using hash or fallback
	local function ResolveShortChannelName(rest)
		if not SHORTNAME_CHANNELHASH then
			-- No hash available (non-Chinese locale), use fallback
			local short = strmatch(rest, "^([^%s%-]+)");
			return short and ChatFrame_ResolveChannelName(short);
		end
		-- Try to find a known short name in the hash
		for name, shortName in next, SHORTNAME_CHANNELHASH do
			local s = string.find(rest, name, 1, true);
			if s then
				local pre = string.sub(rest, 1, s - 1);
				-- Ensure only whitespace/punctuation before the match
				if not string.find(pre, "[^%s%p]") then
					return ChatFrame_ResolveChannelName(shortName);
				end
			end
		end
		-- Fallback: extract first word (stop at space or hyphen)
		local short = strmatch(rest, "^([^%s%-]+)");
		return short and ChatFrame_ResolveChannelName(short);
	end
	
	local method = {
		["*"] = OriginalResolvePrefixedChannelName;
		["n.w"] = function(communityChannel)
			local prefix, rest = strmatch(communityChannel, "^(%d+)%.%s*(.*)");
			if prefix and rest then
				local shortName = ResolveShortChannelName(rest);
				if shortName then
					return prefix .. "." .. shortName;
				end
			end
			return communityChannel;
		end,
		["n"] = function(communityChannel)
			local prefix = strmatch(communityChannel, "^(%d+)%.");
			return prefix or communityChannel;
		end,
		["w"] = function(communityChannel)
			local prefix, rest = strmatch(communityChannel, "^(%d+)%.%s*(.*)");
			if rest then
				local shortName = ResolveShortChannelName(rest);
				if shortName then
					return shortName;
				end
			end
			return communityChannel;
		end,
	};
-->

-->		Init
	local B_Initialized = false;
	local function Init()
		B_Initialized = true;
		for key, val in next, SHORTNAME_NORMALGLOBALFORMAT do
			chat_global_format_backup[key] = val;
		end
	end
-->

-->		Module
	-- Helper to set the hook on the correct API location
	local function SetResolvePrefixedChannelNameHook(func)
		if UseChatFrameUtil then
			ChatFrameUtil.ResolvePrefixedChannelName = func;
		else
			_G.ChatFrame_ResolvePrefixedChannelName = func;
		end
	end
	
	function __shortchattype.format(value, loading)
		if not loading and _db.toggle then
			SetResolvePrefixedChannelNameHook(value and method[_db.format] or method["*"]);
		end
	end
	function __shortchattype.toggle(value, loading)
		if value then
			if not B_Initialized then
				Init();
			end
			for key, val in next, SHORTNAME_NORMALGLOBALFORMAT do
				_G[key] = val;
			end
			SetResolvePrefixedChannelNameHook(method[_db.format or "n.w"]);
		elseif not loading then
			if B_Initialized then
				for key, val in next, chat_global_format_backup do
					_G[key] = val;
				end
			end
			SetResolvePrefixedChannelNameHook(method["*"]);
		end
	end
	function __shortchattype.__init(db, loading)
		_db = db;
	end

	function __shortchattype.__callback(which, value, loading)
		if __shortchattype[which] ~= nil then
			return __shortchattype[which](value, loading);
		end
	end
	function __shortchattype.__setting()
		__private.__SettingUI:AddSetting("MISC", { "shortchattype", "toggle", 'boolean', });
		--
		__private.__SettingUI:AddSetting("MISC", { "shortchattype", "format", 'list', { "n.w", "n", "w", }, }, 1);
	end

	__private.__module["shortchattype"] = __shortchattype;

-->
