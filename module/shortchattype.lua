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
	local method = {
		["*"] = _G.ChatFrame_ResolvePrefixedChannelName;
		["n.w"] = function(communityChannel)
			local prefix, short = strmatch(communityChannel, "(%d+). ([^ ]*)");
			return prefix .. "." .. ChatFrame_ResolveChannelName(SHORTNAME_CHANNELHASH[short] or short);
		end,
		["n"] = function(communityChannel)
			local prefix, short = strmatch(communityChannel, "(%d+). ([^ ]*)");
			return prefix;
		end,
		["w"] = function(communityChannel)
			local prefix, short = strmatch(communityChannel, "(%d+). ([^ ]*)");
			return ChatFrame_ResolveChannelName(SHORTNAME_CHANNELHASH[short] or short);
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
	function __shortchattype.format(value, loading)
		if not loading and _db.toggle then
			_G.ChatFrame_ResolvePrefixedChannelName = value and method[_db.format] or method["*"];
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
			_G.ChatFrame_ResolvePrefixedChannelName = method[_db.format] or method["*"];
		elseif not loading then
			if B_Initialized then
				for key, val in next, chat_global_format_backup do
					_G[key] = val;
				end
			end
			_G.ChatFrame_ResolvePrefixedChannelName = method["*"];
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
		__private:AddSetting("MISC", { "shortchattype", "toggle", 'boolean', });
		--
		__private:AddSetting("MISC", { "shortchattype", "format", 'list', { "n.w", "n", "w", }, }, 1);
	end

	__private.__module["shortchattype"] = __shortchattype;
-->
