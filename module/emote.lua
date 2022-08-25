
local _G = _G;
local __ala_meta__ = _G.__ala_meta__;
local uireimp = __ala_meta__.uireimp;

local __addon, __private = ...;
local L = __private.L;

local TEXTURE_PATH = __private.TEXTURE_PATH;
local EMOTE_PATH = __private.TEXTURE_PATH .. [[Emote\]];
local PANEL_HIDE_PERIOD = 1.5;

local EMOTE_STRING = L.EMOTE;
local EMOTE_LOCALE_STRING = EMOTE_STRING[L.Locale] or EMOTE_STRING.enUS or select(2, next(EMOTE_STRING));

local next = next;
local strsub, strlen, gsub = string.sub, string.len, string.gsub;
local CreateFrame = CreateFrame;
local ChatEdit_ChooseBoxForSend, ChatEdit_ActivateChat = ChatEdit_ChooseBoxForSend, ChatEdit_ActivateChat;
local UIParent = UIParent;
local GameTooltip = GameTooltip;

local toc = select(4, GetBuildInfo());
local isRetail = toc >= 80300;
local isBCC = toc >= 20500 and toc < 30000;
local isWLK = toc >= 30400 and toc < 40000;

local __emote = {  };
local _db = {  };

if __private.__is_dev then
	__private:BuildEnv("emote");
end

-->		Data
	local T_SystemIconTable = {
		{ ICON_TAG_RAID_TARGET_STAR1,		[[Interface\TargetingFrame\UI-RaidTargetingIcon_1]], },
		{ ICON_TAG_RAID_TARGET_CIRCLE1,		[[Interface\TargetingFrame\UI-RaidTargetingIcon_2]], },
		{ ICON_TAG_RAID_TARGET_DIAMOND1,	[[Interface\TargetingFrame\UI-RaidTargetingIcon_3]], },
		{ ICON_TAG_RAID_TARGET_TRIANGLE1,	[[Interface\TargetingFrame\UI-RaidTargetingIcon_4]], },
		{ ICON_TAG_RAID_TARGET_MOON1,		[[Interface\TargetingFrame\UI-RaidTargetingIcon_5]], },
		{ ICON_TAG_RAID_TARGET_SQUARE1,		[[Interface\TargetingFrame\UI-RaidTargetingIcon_6]], },
		{ ICON_TAG_RAID_TARGET_CROSS1,		[[Interface\TargetingFrame\UI-RaidTargetingIcon_7]], },
		{ ICON_TAG_RAID_TARGET_SKULL1,		[[Interface\TargetingFrame\UI-RaidTargetingIcon_8]], },
		-- { ICON_TAG_RAID_TARGET_STAR2,		[[Interface\TargetingFrame\UI-RaidTargetingIcon_1]], },
		-- { ICON_TAG_RAID_TARGET_CIRCLE2,		[[Interface\TargetingFrame\UI-RaidTargetingIcon_2]], },
		-- { ICON_TAG_RAID_TARGET_DIAMOND2,		[[Interface\TargetingFrame\UI-RaidTargetingIcon_3]], },
		-- { ICON_TAG_RAID_TARGET_TRIANGLE2,	[[Interface\TargetingFrame\UI-RaidTargetingIcon_4]], },
		-- { ICON_TAG_RAID_TARGET_MOON2,		[[Interface\TargetingFrame\UI-RaidTargetingIcon_5]], },
		-- { ICON_TAG_RAID_TARGET_SQUARE2,		[[Interface\TargetingFrame\UI-RaidTargetingIcon_6]], },
		-- { ICON_TAG_RAID_TARGET_CROSS2,		[[Interface\TargetingFrame\UI-RaidTargetingIcon_7]], },
		-- { ICON_TAG_RAID_TARGET_SKULL2,		[[Interface\TargetingFrame\UI-RaidTargetingIcon_8]], },
		-- { RAID_TARGET_1,	[[Interface\TargetingFrame\UI-RaidTargetingIcon_1]], },
		-- { RAID_TARGET_2,	[[Interface\TargetingFrame\UI-RaidTargetingIcon_2]], },
		-- { RAID_TARGET_3,	[[Interface\TargetingFrame\UI-RaidTargetingIcon_3]], },
		-- { RAID_TARGET_4,	[[Interface\TargetingFrame\UI-RaidTargetingIcon_4]], },
		-- { RAID_TARGET_5,	[[Interface\TargetingFrame\UI-RaidTargetingIcon_5]], },
		-- { RAID_TARGET_6,	[[Interface\TargetingFrame\UI-RaidTargetingIcon_6]], },
		-- { RAID_TARGET_7,	[[Interface\TargetingFrame\UI-RaidTargetingIcon_7]], },
		-- { RAID_TARGET_8,	[[Interface\TargetingFrame\UI-RaidTargetingIcon_8]], },
	};
	local T_CustomizedIconTable = {
		{ "Angel",		EMOTE_PATH .. "angel", },
		{ "Angry",		EMOTE_PATH .. "angry", },
		{ "Biglaugh",	EMOTE_PATH .. "biglaugh", },
		{ "Clap",		EMOTE_PATH .. "clap", },
		{ "Cool",		EMOTE_PATH .. "cool", },
		{ "Cry",		EMOTE_PATH .. "cry", },
		{ "Cute",		EMOTE_PATH .. "cutie", },
		{ "Despise",	EMOTE_PATH .. "despise", },
		{ "Dreamsmile",	EMOTE_PATH .. "dreamsmile", },
		{ "Embarras",	EMOTE_PATH .. "embarrass", },
		{ "Evil",		EMOTE_PATH .. "evil", },
		{ "Excited",	EMOTE_PATH .. "excited", },
		{ "Faint",		EMOTE_PATH .. "faint", },
		{ "Fight",		EMOTE_PATH .. "fight", },
		{ "Flu",		EMOTE_PATH .. "flu", },
		{ "Freeze",		EMOTE_PATH .. "freeze", },
		{ "Frown",		EMOTE_PATH .. "frown", },
		{ "Greet",		EMOTE_PATH .. "greet", },
		{ "Grimace",	EMOTE_PATH .. "grimace", },
		{ "Growl",		EMOTE_PATH .. "growl", },
		{ "Happy",		EMOTE_PATH .. "happy", },
		{ "Heart",		EMOTE_PATH .. "heart", },
		{ "Horror",		EMOTE_PATH .. "horror", },
		{ "Ill",		EMOTE_PATH .. "ill", },
		{ "Innocent",	EMOTE_PATH .. "innocent", },
		{ "Kongfu",		EMOTE_PATH .. "kongfu", },
		{ "Love",		EMOTE_PATH .. "love", },
		{ "Mail",		EMOTE_PATH .. "mail", },
		{ "Makeup",		EMOTE_PATH .. "makeup", },
		{ "Mario",		EMOTE_PATH .. "mario", },
		{ "Meditate",	EMOTE_PATH .. "meditate", },
		{ "Miserable",	EMOTE_PATH .. "miserable", },
		{ "Okay",		EMOTE_PATH .. "okay", },
		{ "Pretty",		EMOTE_PATH .. "pretty", },
		{ "Puke",		EMOTE_PATH .. "puke", },
		{ "Shake",		EMOTE_PATH .. "shake", },
		{ "Shout",		EMOTE_PATH .. "shout", },
		{ "Silent",		EMOTE_PATH .. "shuuuu", },
		{ "Shy",		EMOTE_PATH .. "shy", },
		{ "Sleep",		EMOTE_PATH .. "sleep", },
		{ "Smile",		EMOTE_PATH .. "smile", },
		{ "Suprise",	EMOTE_PATH .. "suprise", },
		{ "Surrender",	EMOTE_PATH .. "surrender", },
		{ "Sweat",		EMOTE_PATH .. "sweat", },
		{ "Tear",		EMOTE_PATH .. "tear", },
		{ "Tears",		EMOTE_PATH .. "tears", },
		{ "Think",		EMOTE_PATH .. "think", },
		{ "Titter",		EMOTE_PATH .. "titter", },
		{ "Ugly",		EMOTE_PATH .. "ugly", },
		{ "Victory",	EMOTE_PATH .. "victory", },
		{ "Volunteer",	EMOTE_PATH .. "volunteer", },
		{ "Wronged",	EMOTE_PATH .. "wronged", },
	};
	local T_Key2Msg = {  };
	local T_Key2Texture = {  };
	local T_Path2Msg = {  };
	__emote.T_Key2Texture = T_Key2Texture;
	__emote.T_Path2Msg = T_Path2Msg;

	local function BuildTable()
		for _, val in next, T_SystemIconTable do
			local key = val[1];
			local path = val[2];
			local msg = "{" .. key .. "}";
			T_Key2Msg[key] = msg;
			T_Key2Texture[key] = "|T" .. path .. ":0|t";
			T_Path2Msg[path] = msg;
		end
		for _, val in next, T_CustomizedIconTable do
			local key = val[1];
			local path = val[2];
			local msg = "{" .. (EMOTE_LOCALE_STRING[key] or key) .. "}";
			T_Key2Msg[key] = msg;
			T_Key2Texture[key] = "|T" .. path .. ":0|t";
			T_Path2Msg[path] = msg;
		end
		for language, tbl in next, EMOTE_STRING do
			for key, text in next, tbl do
				T_Key2Texture[text] = T_Key2Texture[key];
			end
		end
	end
-->

-->		MessageFilter
	local function ChatMessageFilter(self, event, msg, ...)
		return false, gsub(msg, "{([^{}]+)}", T_Key2Texture), ...;
	end
-->

-->		SendFilter
	local function SendFilter(msg)
		return strsub(gsub(msg, "|T([^:]+):%d+|t", T_Path2Msg), 1, 255);
	end

	local __SendChatMessage = nil;
	local function EmoteSendChatMessage(text, ...)
		__SendChatMessage(SendFilter(text), ...);
	end
	local __BNSendWhisper = nil;
	local function EmoteBNSendWhisper(presenceID, text, ...)
		__BNSendWhisper(presenceID, SendFilter(text), ...);
	end
	local __BNSendConversationMessage = nil;
	local function EmoteBNSendConversationMessage(target, text, ...)
		__BNSendConversationMessage(target, SendFilter(text), ...);
	end
-->

-->		GUI
	local PanelOnEvent, PanelOnUpdate, PanelOnEnter, PanelOnLeave;
	local IconOnEnter, IconOnLeave, IconOnClick;
	local ButtonOnEnter, ButtonOnLeave, ButtonOnClick;
	--
	function ButtonOnEnter(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
		GameTooltip:SetText(L.TIP.emote, 1.0, 1.0, 1.0);
		GameTooltip:Show();
		PanelOnEnter(self.Panel);
	end
	function ButtonOnLeave(self)
		GameTooltip:Hide();
		PanelOnLeave(self.Panel);
	end
	function ButtonOnClick(self)
		if self.Panel:IsShown() then
			self.Panel:Hide();
		else
			local Panel = self.Panel;
			Panel:Show();
			local Docker = __private.__docker;
			if Docker.__isAttachedToEditBox and Docker.__ActiveEditBox ~= nil then
				local ActiveEditBox = Docker.__ActiveEditBox;
				local DockerTop = Docker:GetTop();
				local dist = ActiveEditBox:GetBottom() + 2 - DockerTop;
				if dist > 2 - ActiveEditBox:GetHeight() and dist < Panel:GetHeight() then
					Panel:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, ActiveEditBox:GetTop() - 2 - DockerTop);
				else
					Panel:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 2);
				end
			else
				Panel:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 2);
			end
		end
		GameTooltip:Hide();
	end
	if isRetail or isWLK then
		function PanelOnEvent(self, event)
			if self.__flag == "show" then
				self.__flag = nil;
			else
				self:SetScript("OnUpdate", nil);
				self:SetScript("OnEvent", nil);
				self:Hide();
			end
		end
	else
		function PanelOnEvent(self, event)
			self:SetScript("OnUpdate", nil);
			self:SetScript("OnEvent", nil);
			self:Hide();
		end
	end
	function PanelOnUpdate(self, elapsed)
		self.CountingDownTimer = self.CountingDownTimer - elapsed;
		if self.CountingDownTimer <= 0 then
			self:Hide();
		end
	end
	function PanelOnEnter(self)
		self:SetScript("OnUpdate", nil);
		self:SetScript("OnEvent", nil);
	end
	function PanelOnLeave(self)
		self.CountingDownTimer = PANEL_HIDE_PERIOD;
		self:SetScript("OnUpdate", PanelOnUpdate);
		self:SetScript("OnEvent", PanelOnEvent);
	end
	local function PanelOnShow(self)
		self.CountingDownTimer = PANEL_HIDE_PERIOD + 1.0;
		-- self:SetScript("OnUpdate", PanelOnUpdate);
		self:SetScript("OnEvent", PanelOnEvent);
		self.__flag = "show";
	end
	local function PanelOnHide(self)
		self:SetScript("OnUpdate", nil);
		self:SetScript("OnEvent", nil);
	end
	function IconOnEnter(self)
		GameTooltip:SetOwner(self.Panel, "ANCHOR_TOPLEFT");
		GameTooltip:SetText(self.tip);
		GameTooltip:Show();
		PanelOnEnter(self.Panel);
	end
	function IconOnLeave(self)
		GameTooltip:Hide();
		PanelOnLeave(self.Panel);
	end
	function IconOnClick(self)
		local editBox = ChatEdit_ChooseBoxForSend();
		local i = _db.IconInEditBox and self.texture or self.msg;
		local orig = editBox:GetText();
		if orig == nil or strlen(orig) + strlen(i) <= 255 then
			if not editBox:HasFocus() then
				ChatEdit_ActivateChat(editBox);
			end
			editBox:Insert(i);
			self.Panel:Hide();
		end
	end
	--
	local function CreateIcon(Panel, key, path, px, py)
		local Icon = CreateFrame("Button", nil, Panel);
		Icon:Show();
		Icon:EnableMouse(true);
		Icon:SetWidth(23);
		Icon:SetHeight(23);
		Icon.key = key;
		Icon.tip = EMOTE_LOCALE_STRING[key] or key;
		Icon.texture = T_Key2Texture[key];
		Icon.msg = T_Key2Msg[key];
		Icon:SetNormalTexture(path);
		Icon:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]]);
		-- Icon:GetHighlightTexture():SetBlendMode("ADD");
		Icon:ClearAllPoints();
		Icon.Panel = Panel;
		Icon:SetPoint("TOPLEFT", Panel, "TOPLEFT", (px - 1) * 25 + 5, (1 - py ) * 25 - 5);
		Icon:SetScript("OnClick", IconOnClick);
		Icon:SetScript("OnEnter", IconOnEnter);
		Icon:SetScript("OnLeave", IconOnLeave);

		return Icon;
	end
	local function ButtonSetStyle(Button, style)
		if style == "char.blz" then
			Button:SetNormalTexture(TEXTURE_PATH .. "blz_emote_normal");
			Button:SetPushedTexture(TEXTURE_PATH .. "blz_emote_pushed");
		else
			Button:SetNormalTexture(TEXTURE_PATH .. "emote_normal");
			Button:SetPushedTexture(TEXTURE_PATH .. "emote_pushed");
		end
	end
	local function CreateGUI()
		local Button = __private.__docker:CreatePin(1);
		-- Button:SetAlpha(0.8);
		Button:SetTip(ButtonOnEnter, L.DETAILEDTIP.emote, ButtonOnLeave);
		-- Button:SetScript("OnDragStart", function() if self:IsMovable() and IsControlKeyDown() then self:StartMoving(); end end);
		-- Button:SetScript("OnDragStop", function() if self:IsMovable() then self:StopMovingOrSizing(); end end);
		Button:SetScript("OnClick", ButtonOnClick);
		ButtonSetStyle(Button, _db.PinStyle);

		local Panel = CreateFrame('FRAME', nil, UIParent);
		Panel:SetWidth(260);
		Panel:SetHeight(160);
		Panel:SetMovable(true);
		Panel:EnableMouse(true);
		Panel:Hide();
		Panel:ClearAllPoints();
		Panel:SetPoint("BOTTOMLEFT", Button, "TOPRIGHT", 0, 32);
		uireimp._SetSimpleBackdrop(Panel, 1, 1, 0.0, 0.0, 0.0, 0.9, 1.0, 1.0, 1.0, 0.25);
		Panel:SetClampedToScreen(true);

		-- Panel:SetScript("OnUpdate", PanelOnUpdate);
		-- Panel:SetScript("OnEvent", PanelOnEvent);
		Panel:SetScript("OnEnter", PanelOnEnter);
		Panel:SetScript("OnLeave", PanelOnLeave);
		Panel:SetScript("OnShow", PanelOnShow);
		Panel:SetScript("OnHide", PanelOnHide);
		if isRetail or isWLK then
			Panel:RegisterEvent("GLOBAL_MOUSE_UP");
		elseif isBCC then
			Panel:RegisterEvent("PLAYER_STARTED_LOOKING");
			-- Panel:RegisterEvent("PLAYER_STOPPED_LOOKING");
			Panel:RegisterEvent("PLAYER_STARTED_TURNING");
			-- Panel:RegisterEvent("PLAYER_STOPPED_TURNING");
		else
			Panel:RegisterEvent("CURSOR_UPDATE");
		end

		local IconList = {  };
		local px = 1;
		local py = 1;
		local index = 1;
		for _, val in next, T_SystemIconTable do
			IconList[index] = CreateIcon(Panel, val[1], val[2], px, py);
			index = index + 1;
			px = px + 1;
			if px >= 11 then
			px = 1;
				py = py + 1;
			end
		end
		for _, val in next, T_CustomizedIconTable do
			IconList[index] = CreateIcon(Panel, val[1], val[2], px, py);
			index = index + 1;
			px = px + 1;
			if px >= 11 then
				px = 1;
				py = py + 1;
			end
		end

		Button.Panel = Panel;
		Panel.Button = Button;
		__emote.Panel = Panel;
		__emote.Button = Button;
	end
-->

-->		Init
	local B_Initialized = false;
	local function Init()
		B_Initialized = true;
		BuildTable();
		CreateGUI();
		__SendChatMessage = _G.SendChatMessage;
		_G.SendChatMessage = EmoteSendChatMessage;
		__BNSendWhisper = _G.BNSendWhisper;
		_G.BNSendWhisper = EmoteBNSendWhisper;
		__BNSendConversationMessage = _G.BNSendConversationMessage;
		_G.BNSendConversationMessage = EmoteBNSendConversationMessage;
	end
-->

-->		Module
	function __emote.PinStyle(value, loading)
		if B_Initialized and not loading then
			if value ~= "char.blz" then
				value = "char";
				_db.PinStyle = "char";
			end
			ButtonSetStyle(__emote.Button, value);
		end
	end
	function __emote.toggle(value, loading)
		if value then
			if not B_Initialized then
				Init();
			end
			__private:AddMessageFilterAllChatTypes("emote", ChatMessageFilter);
			__private.__docker:ShowPin(__emote.Button);
		elseif not loading then
			__private:DelMessageFilterAllChatTypes("emote", ChatMessageFilter);
			if B_Initialized then
				__emote.Panel:Hide();
				__private.__docker:HidePin(__emote.Button);
			end
		end
	end
	function __emote.__init(db, loading)
		_db = db;
	end

	function __emote.__callback(which, value, loading)
		if __emote[which] ~= nil then
			return __emote[which](value, loading);
		end
	end
	function __emote.__setting()
		__private:AddSetting("MISC", { "emote", "toggle", 'boolean', }, nil, nil, TEXTURE_PATH .. "emote_normal");
		--
		__private:AddSetting("MISC", { "emote", "IconInEditBox", 'boolean', }, 1);
		__private:AddSetting("MISC", { "emote", "PinStyle", 'list', { "char", "char.blz", }, }, 1);
	end

	__private.__module["emote"] = __emote;
-->
