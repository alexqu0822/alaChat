--	TODO Binding
local __addon, __private = ...;
local L = __private.L;

local __general = {  };
local _db = {  };

-->		Data
	--
-->

-->		GUI
	--
-->

-->		Method
	--
-->

-->		Init
	local B_Initialized = false;
	local function Init()
		B_Initialized = true;
	end
-->

-->		Module
	function __general.__init(db, loading)
		_db = db;
	end

	function __general.__callback(which, value, loading)
		if __general[which] ~= nil then
			return __general[which](value, loading);
		end
	end
	function __general.__setting()
		__private:AddSetting("GENERAL", { "general", "detailedtip", 'boolean', });
	end

	__private.__module["general"] = __general;
-->
