
local __addon, __private = ...;
local L = __private.L;

local TEXTURE_PATH = __private.TEXTURE_PATH;
local EMOTE_PATH = __private.TEXTURE_PATH .. [[Emote\]];
local PANEL_HIDE_PERIOD = 1.5;

local EMOTE_STRING = L.EMOTE;
local EMOTE_LOCALE_STRING = EMOTE_STRING[L.Locale] or EMOTE_STRING.enUS or select(2, next(EMOTE_STRING));

local gsub = string.gsub;
local ChatEdit_ChooseBoxForSend, ChatEdit_ActivateChat = ChatEdit_ChooseBoxForSend, ChatEdit_ActivateChat;
local GameTooltip = GameTooltip;

local _LB_Event_GLOBAL_MOUSE_UP = select(4, GetBuildInfo()) >= 80300;

local __emote = {  };
local _db = {  };

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
		{ "Angel",		EMOTE_PATH .. "angel.tga", },
		{ "Angry",		EMOTE_PATH .. "angry.tga", },
		{ "Biglaugh",	EMOTE_PATH .. "biglaugh.tga", },
		{ "Clap",		EMOTE_PATH .. "clap.tga", },
		{ "Cool",		EMOTE_PATH .. "cool.tga", },
		{ "Cry",		EMOTE_PATH .. "cry.tga", },
		{ "Cute",		EMOTE_PATH .. "cutie.tga", },
		{ "Despise",	EMOTE_PATH .. "despise.tga", },
		{ "Dreamsmile",	EMOTE_PATH .. "dreamsmile.tga", },
		{ "Embarras",	EMOTE_PATH .. "embarrass.tga", },
		{ "Evil",		EMOTE_PATH .. "evil.tga", },
		{ "Excited",	EMOTE_PATH .. "excited.tga", },
		{ "Faint",		EMOTE_PATH .. "faint.tga", },
		{ "Fight",		EMOTE_PATH .. "fight.tga", },
		{ "Flu",		EMOTE_PATH .. "flu.tga", },
		{ "Freeze",		EMOTE_PATH .. "freeze.tga", },
		{ "Frown",		EMOTE_PATH .. "frown.tga", },
		{ "Greet",		EMOTE_PATH .. "greet.tga", },
		{ "Grimace",	EMOTE_PATH .. "grimace.tga", },
		{ "Growl",		EMOTE_PATH .. "growl.tga", },
		{ "Happy",		EMOTE_PATH .. "happy.tga", },
		{ "Heart",		EMOTE_PATH .. "heart.tga", },
		{ "Horror",		EMOTE_PATH .. "horror.tga", },
		{ "Ill",		EMOTE_PATH .. "ill.tga", },
		{ "Innocent",	EMOTE_PATH .. "innocent.tga", },
		{ "Kongfu",		EMOTE_PATH .. "kongfu.tga", },
		{ "Love",		EMOTE_PATH .. "love.tga", },
		{ "Mail",		EMOTE_PATH .. "mail.tga", },
		{ "Makeup",		EMOTE_PATH .. "makeup.tga", },
		{ "Mario",		EMOTE_PATH .. "mario.tga", },
		{ "Meditate",	EMOTE_PATH .. "meditate.tga", },
		{ "Miserable",	EMOTE_PATH .. "miserable.tga", },
		{ "Okay",		EMOTE_PATH .. "okay.tga", },
		{ "Pretty",		EMOTE_PATH .. "pretty.tga", },
		{ "Puke",		EMOTE_PATH .. "puke.tga", },
		{ "Shake",		EMOTE_PATH .. "shake.tga", },
		{ "Shout",		EMOTE_PATH .. "shout.tga", },
		{ "Silent",		EMOTE_PATH .. "shuuuu.tga", },
		{ "Shy",		EMOTE_PATH .. "shy.tga", },
		{ "Sleep",		EMOTE_PATH .. "sleep.tga", },
		{ "Smile",		EMOTE_PATH .. "smile.tga", },
		{ "Suprise",	EMOTE_PATH .. "suprise.tga", },
		{ "Surrender",	EMOTE_PATH .. "surrender.tga", },
		{ "Sweat",		EMOTE_PATH .. "sweat.tga", },
		{ "Tear",		EMOTE_PATH .. "tear.tga", },
		{ "Tears",		EMOTE_PATH .. "tears.tga", },
		{ "Think",		EMOTE_PATH .. "think.tga", },
		{ "Titter",		EMOTE_PATH .. "titter.tga", },
		{ "Ugly",		EMOTE_PATH .. "ugly.tga", },
		{ "Victory",	EMOTE_PATH .. "victory.tga", },
		{ "Volunteer",	EMOTE_PATH .. "volunteer.tga", },
		{ "Wronged",	EMOTE_PATH .. "wronged.tga", },
	};
	local T_Key2Path = {  };
	local T_Path2Msg = {  };
	__emote.T_Key2Path = T_Key2Path;
	__emote.T_Path2Msg = T_Path2Msg;

	local function BuildTable()
		for _, val in next, T_SystemIconTable do
			local key = val[1];
			local path = val[2];
			T_Key2Path[key] = "|T" .. path .. ":0|t";
			T_Path2Msg[path] = "{" .. key .. "}";
		end
		for _, val in next, T_CustomizedIconTable do
			local key = val[1];
			local path = val[2];
			T_Key2Path[key] = "|T" .. path .. ":0|t";
			T_Path2Msg[path] = "{" .. (EMOTE_LOCALE_STRING[key] or key) .. "}";
		end
		for language, tbl in next, EMOTE_STRING do
			for key, text in next, tbl do
				T_Key2Path[text] = T_Key2Path[key];
			end
		end
	end
-->

-->		MessageFilter
	local function ChatMessageFilter(self, event, msg, ...)
		return false, gsub(msg, "{([^}]+)}", T_Key2Path), ...;
	end
-->

-->		SendFilter
	local function SendFilter(msg)
		return gsub(msg, "|T([^:]+):%d+|t", T_Path2Msg);
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
	local function SetBackdrop(_F, inset, dr, dg, db, da, width, rr, rg, rb, ra)	--	inset > 0 : inner	--	inset < 0 : outter
		local ofs = width + inset;
		local Backdrop = _F:CreateTexture(nil, "BACKGROUND");
		Backdrop:SetPoint("BOTTOMLEFT", _F, "BOTTOMLEFT", ofs, ofs);
		Backdrop:SetPoint("TOPRIGHT", _F, "TOPRIGHT", -ofs, -ofs);
		Backdrop:SetColorTexture(dr or 0.0, dg or 0.0, db or 0.0, da or 1.0);
		local LBorder = _F:CreateTexture(nil, "BACKGROUND", nil, 1);
		local TBorder = _F:CreateTexture(nil, "BACKGROUND", nil, 1);
		local RBorder = _F:CreateTexture(nil, "BACKGROUND", nil, 1);
		local BBorder = _F:CreateTexture(nil, "BACKGROUND", nil, 1);
		if width ~= nil then
			rr, rg, rb, ra = rr or 1.0, rg or 1.0, rb or 1.0, ra or 0.5;
			LBorder:SetWidth(width);
			TBorder:SetHeight(width);
			RBorder:SetWidth(width);
			BBorder:SetHeight(width);
			LBorder:SetColorTexture(rr, rg, rb, ra);
			TBorder:SetColorTexture(rr, rg, rb, ra);
			RBorder:SetColorTexture(rr, rg, rb, ra);
			BBorder:SetColorTexture(rr, rg, rb, ra);
			LBorder:SetPoint("TOPRIGHT", _F, "TOPLEFT", ofs, -ofs);
			LBorder:SetPoint("BOTTOMRIGHT", _F, "BOTTOMLEFT", ofs, inset);
			TBorder:SetPoint("BOTTOMRIGHT", _F, "TOPRIGHT", -ofs, -ofs);
			TBorder:SetPoint("BOTTOMLEFT", _F, "TOPLEFT", inset, -ofs);
			RBorder:SetPoint("BOTTOMLEFT", _F, "BOTTOMRIGHT", -ofs, ofs);
			RBorder:SetPoint("TOPLEFT", _F, "TOPRIGHT", -ofs, -inset);
			BBorder:SetPoint("TOPLEFT", _F, "BOTTOMLEFT", ofs, ofs);
			BBorder:SetPoint("TOPRIGHT", _F, "BOTTOMRIGHT", -inset, ofs);
		end
	end
	--
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
	function PanelOnEvent(self, event)
		self:SetScript("OnUpdate", nil);
		self:SetScript("OnEvent", nil);
		self:Hide();
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
		if not editBox:HasFocus() then
			ChatEdit_ActivateChat(editBox);
		end
		editBox:Insert(self.texture);
		self.Panel:Hide();
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
		Icon.texture = T_Key2Path[key];
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
		SetBackdrop(Panel, 1, 0.0, 0.0, 0.0, 0.9, 1, 1.0, 1.0, 1.0, 0.25);
		Panel:SetClampedToScreen(true);

		-- Panel:SetScript("OnUpdate", PanelOnUpdate);
		-- Panel:SetScript("OnEvent", PanelOnEvent);
		Panel:SetScript("OnEnter", PanelOnEnter);
		Panel:SetScript("OnLeave", PanelOnLeave);
		Panel:SetScript("OnShow", PanelOnShow);
		Panel:SetScript("OnHide", PanelOnHide);
		if _LB_Event_GLOBAL_MOUSE_UP then
			Panel:RegisterEvent("GLOBAL_MOUSE_UP");
		else
			-- Panel:RegisterEvent("CURSOR_UPDATE");
			Panel:RegisterEvent("PLAYER_STARTED_LOOKING");
			-- Panel:RegisterEvent("PLAYER_STOPPED_LOOKING");
			Panel:RegisterEvent("PLAYER_STARTED_TURNING");
			-- Panel:RegisterEvent("PLAYER_STOPPED_TURNING");
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
		__private:AddSetting("MISC", { "emote", "toggle", 'boolean', });
		--
		__private:AddSetting("MISC", { "emote", "PinStyle", 'list', { "char", "char.blz", }, }, 1);
	end

	__private.__module["emote"] = __emote;
-->
