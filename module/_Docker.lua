--	TODO Binding
local __addon, __private = ...;
local L = __private.L;

local TEXTURE_PATH = __private.TEXTURE_PATH;

local pcall, xpcall, geterrorhandler = pcall, xpcall, geterrorhandler;
local setmetatable = setmetatable;
local type = type;
local rawget, rawset = rawget, rawset;
local next, tinsert, tremove = next, table.insert, table.remove;
local IsControlKeyDown = IsControlKeyDown;
local CreateFrame = CreateFrame;
local GetMouseFocus = GetMouseFocus;
local GameTooltip = GameTooltip;
local UIParent = UIParent;

local __docker = {  };
local _db = {  };

if __private.__is_dev then
	__private:BuildEnv("_Docker");
end

--[=[
	-->>	MIN = 1
	--	emote = 1
	--	channeltab = 8 ~ 71
	--	highlight = 96
	--	utils = 120
	--<<	MAX = 127
--]=]

-->		Data
	--
-->

-->		GUI
	local Docker = CreateFrame('FRAME', nil, UIParent);
	local _T_Pins = {  };
	local _T_DockerPins = {  };
	local _I_DockerPins = 0;
	local _T_ThemeMethod = setmetatable(
		{
			["#"] = 0,
			__add = function(tbl, key, val)
				if tbl[key] == nil then
					tbl["#"] = tbl["#"] + 1;
					rawset(tbl, tbl["#"], key);
					rawset(tbl, key, val);
				end
			end,
			__del = function(tbl, key)
				if tbl[key] ~= nil then
					for index = 1, tbl["#"] do
						if tbl[index] == key then
							tremove(tbl, index);
							tbl["#"] = tbl["#"] - 1;
							break;
						end
					end
					tbl[key] = nil;
				end
			end,
			__wipe = function(tbl)
				tbl["#"] = 0;
			end,
			__deepwipe = function(tbl)
				for index = tbl["#"], 1, -1 do
					tbl[tbl[index]] = nil;
					tbl[index] = nil;
				end
				tbl["#"] = 0;
			end,
		},
		{
			__newindex = function(tbl, key, val)
				tbl["#"] = tbl["#"] + 1;
				rawset(tbl, tbl["#"], key);
				rawset(tbl, key, val);
			end,
		}
	);
	local function DockerOnUpdate(Docker, elapsed)
		if Docker.__anim == "FadeOutDelay" then
			Docker.__delay = Docker.__delay - elapsed;
			if Docker.__delay <= 0.0 then
				Docker.__anim = "fadeout";
			end
		elseif Docker.__anim == "fadeout" then
			local alpha = Docker.__alpha - elapsed * Docker.__fadeoutspeed;
			if alpha - _db.FadedAlpha > 0.01 then
				Docker:SetAlpha(alpha);
			else
				Docker:SetAlpha(_db.FadedAlpha);
				Docker:SetScript("OnUpdate", nil);
				Docker.__anim = nil;
			end
		elseif Docker.__anim == "fadein" then
			local alpha = Docker.__alpha + elapsed * Docker.__fadeinspeed;
			if _db.alpha - alpha > 0.01 then
				Docker:SetAlpha(alpha);
			else
				Docker:SetAlpha(_db.alpha);
				Docker:SetScript("OnUpdate", nil);
				Docker.__anim = nil;
			end
		else
			if F == Docker or _T_Pins[F] ~= nil then
				Docker:SetAlpha(_db.alpha);
			else
				Docker:SetAlpha(_db.FadedAlpha);
			end
			Docker:SetScript("OnUpdate", nil);
			Docker.__anim = nil;
		end
	end
	local function DockerOnEnter(Docker)
		if _db.FadInTime > 0.0 and _db.alpha - Docker.__alpha > 0.01 then
			Docker:SetScript("OnUpdate", DockerOnUpdate);
			Docker.__anim = "fadein";
		else
			Docker:SetAlpha(_db.alpha);
			Docker:SetScript("OnUpdate", nil);
			Docker.__anim = nil;
		end
	end
	local function DockerOnLeave(Docker)
		if _db.FadeOutTime > 0.0 and Docker.__alpha - _db.FadedAlpha > 0.01 then
			Docker:SetScript("OnUpdate", DockerOnUpdate);
			if Docker.__anim ~= "fadein" and _db.FadeOutDelay > 0 then
				Docker.__anim = "FadeOutDelay";
				Docker.__delay = _db.FadeOutDelay;
			else
				Docker.__anim = "fadeout";
			end
		else
			Docker:SetAlpha(_db.FadedAlpha);
			Docker:SetScript("OnUpdate", nil);
			Docker.__anim = nil;
		end
	end
	local function DockerOnDragStart(Docker)
		-- if _db.Position == "manual" and IsControlKeyDown() then
		-- 	-- Docker:SetClampedToScreen(false);
		-- 	Docker:StartMoving();
		-- end
		if IsControlKeyDown() then
			if _db.Position ~= "manual" then
				-- __docker.Position("manual", false, true);
				__private:SetDB("docker", 'Position', "manual", false, true);
			end
			Docker:StartMoving();
		end
	end
	local function DockerOnDragStop(Docker)
		Docker:StopMovingOrSizing();
		if _db.Position == "manual" then
			Docker:SaveManualPosition();
		end
	end
	local _DockerSetAlpha = Docker.SetAlpha;
	function Docker:SetAlpha(alpha)
		Docker.__alpha = alpha;
		_DockerSetAlpha(Docker, alpha);
	end
	function Docker:SaveManualPosition(new)
		if new then
			Docker:ClearAllPoints();
			_db._manualPosition = { "BOTTOMLEFT", "UIParent", "BOTTOMLEFT", Docker:GetLeft(), Docker:GetBottom(), };
		else
			local pos = { Docker:GetPoint() };
			if pos[2] ~= nil then
				pos[2] = pos[2]:GetName();
			end
			_db._manualPosition = pos;
		end
	end
	function Docker:LoadManualPosition()
		local pos = _db._manualPosition;print("LOAD", pos)
		if pos ~= nil then
			-- Docker:SetClampedToScreen(true);
			Docker:ClearAllPoints();
			Docker:SetPoint(pos[1], pos[2], pos[3], pos[4], pos[5]);
		end
	end
	function Docker:SetFade()
		Docker.__hasAnim = _db.alpha > _db.FadedAlpha;
		if Docker.__hasAnim then
			if _db.FadInTime > 0 then
				Docker.__fadeinspeed = (_db.alpha - _db.FadedAlpha) / _db.FadInTime;
			else
				Docker.__fadeinspeed = 0.0;
			end
			if _db.FadeOutTime > 0 then
				Docker.__fadeoutspeed = (_db.alpha - _db.FadedAlpha) / _db.FadeOutTime;
			else
				Docker.__fadeoutspeed = 0.0;
			end
			Docker:SetScript("OnEnter", DockerOnEnter);
			Docker:SetScript("OnLeave", DockerOnLeave);
			local F = GetMouseFocus();
			if F == Docker or _T_Pins[F] ~= nil then
				if Docker.__alpha - _db.alpha > 0.01 then
					Docker:SetScript("OnUpdate", DockerOnUpdate);
					Docker.__anim = "fadeind";
				else
					Docker:SetAlpha(_db.alpha);
					Docker:SetScript("OnUpdate", nil);
					Docker.__anim = nil;
				end
			else
				Docker:SetScript("OnUpdate", DockerOnUpdate);
				Docker.__anim = "fadeout";
			end
		else
			Docker:SetAlpha(_db.alpha);
			Docker:SetScript("OnEnter", nil);
			Docker:SetScript("OnLeave", nil);
			Docker:SetScript("OnUpdate", nil);
			Docker.__anim = nil;
		end
	end
	function Docker:ResizeDocker()
		if _db.Direction == "UP" or _db.Direction == "DOWN" then
			Docker:SetSize(_db.PinSize + _db.XToBorder * 2, _db.PinSize * _I_DockerPins + _db.PinInt * (_I_DockerPins - 1) + _db.YToBorder * 2);
		else
			Docker:SetSize(_db.PinSize * _I_DockerPins + _db.PinInt * (_I_DockerPins - 1) + _db.XToBorder * 2, _db.PinSize + _db.YToBorder * 2);
		end
	end
	function Docker:ReLayoutPins()
		Docker:PlaceFirst(_T_DockerPins[1]);
		for index = 2, _I_DockerPins do
			Docker:PlaceTo(_T_DockerPins[index], _T_DockerPins[index - 1]);
		end
		Docker:ResizeDocker();
	end
	function Docker:SetPinSize(Size)
		Docker:SetHeight(Size);
		for Pin, order in next, _T_Pins do
			Pin:SetSize(Size, Size);
			Pin:RefreshTextFont();
		end
		Docker:ResizeDocker();
	end
	function Docker:SetPinInt(Int)
		for index = 2, _I_DockerPins do
			Docker:PlaceTo(_T_DockerPins[index], _T_DockerPins[index - 1]);
		end
		Docker:ResizeDocker();
	end
	function Docker:PlaceFirst(Pin)
		Pin:Show();
		Pin:ClearAllPoints();
		if _db.Direction == "UP" then
			Pin:SetPoint("BOTTOM", _db.XToBorder, _db.YToBorder);
		elseif _db.Direction == "DOWN" then
			Pin:SetPoint("TOP", _db.XToBorder, -_db.YToBorder);
		elseif _db.Direction == "LEFT" then
			Pin:SetPoint("RIGHT", -_db.XToBorder, _db.YToBorder);
		else
			Pin:SetPoint("LEFT", _db.XToBorder, _db.YToBorder);
		end
	end
	function Docker:PlaceTo(Pin, to)
		Pin:Show();
		Pin:ClearAllPoints();
		if _db.Direction == "UP" then
			Pin:SetPoint("BOTTOM", to, "TOP", 0, _db.PinInt);
		elseif _db.Direction == "DOWN" then
			Pin:SetPoint("TOP", to, "BOTTOM", 0, -_db.PinInt);
		elseif _db.Direction == "LEFT" then
			Pin:SetPoint("RIGHT", to, "LEFT", -_db.PinInt, 0);
		else
			Pin:SetPoint("LEFT", to, "RIGHT", _db.PinInt, 0);
		end
	end
	--	Tip
		local function PinHeaderTipNil(Pin)
			GameTooltip:SetOwner(Pin, "ANCHOR_TOPLEFT");
		end
		local function PinHeaderTipStr(Pin)
			GameTooltip:SetOwner(Pin, "ANCHOR_TOPLEFT");
			GameTooltip:SetText(Pin.__headertipval, 1.0, 1.0, 1.0);
			GameTooltip:Show();
		end
		local function PinHeaderTipTable(Pin)
			GameTooltip:SetOwner(Pin, "ANCHOR_TOPLEFT");
			local Tip = Pin.__headertipval;
			GameTooltip:SetText(Tip[1], 1.0, 1.0, 1.0);
			for index = 2, #Tip do
				GameTooltip:AddLine(Tip[index]);
			end
			GameTooltip:Show();
		end
		local function PinDetailedTip(Pin)
			local val = Pin.__detailedtipval;
			for index = 1, #val do
				GameTooltip:AddLine(val[index]);
			end
			GameTooltip:Show();
		end
		local function PinOnEnter(Pin)
			Pin.__headertip(Pin);
			if Pin.__detailedtip ~= nil and __private.__db.general.detailedtip then
				Pin.__detailedtip(Pin);
			end
			if __private.__db.general.detailedtip then
				GameTooltip:AddLine(L.DETAILEDTIP.DockerDrag[1]);
				GameTooltip:Show();
			end
			if Docker.__hasAnim then
				DockerOnEnter(Docker);
			end
		end
		local function PinOnLeave(Pin)
			if Pin.__onleave ~= nil then
				Pin:__onleave();
			end
			GameTooltip:Hide();
			if Docker.__hasAnim then
				DockerOnLeave(Docker);
			end
		end
		local function PinSetTip(Pin, HeaderTip, DetailedTip, OnLeave)
			Pin.__headertip = nil;
			Pin.__detailedtip = nil;
			Pin.__onleave = OnLeave;
			if HeaderTip == nil then
				if DetailedTip ~= nil then
					Pin.__headertip = PinHeaderTipNil;
					if type(DetailedTip) == 'table' then
						Pin.__detailedtip = PinDetailedTip;
						Pin.__detailedtipval = DetailedTip;
					elseif type(DetailedTip) == 'string' then
						Pin.__detailedtip = PinDetailedTip;
						Pin.__detailedtipval = { DetailedTip, };
					end
				end
			elseif type(HeaderTip) == 'function' then
				Pin.__headertip = HeaderTip;
				if DetailedTip ~= nil then
					if type(DetailedTip) == 'table' then
						Pin.__detailedtip = PinDetailedTip;
						Pin.__detailedtipval = DetailedTip;
					elseif type(DetailedTip) == 'string' then
						Pin.__detailedtip = PinDetailedTip;
						Pin.__detailedtipval = { DetailedTip, };
					end
				end
			elseif type(HeaderTip) == 'table' then
				Pin.__headertip = PinHeaderTipTable;
				Pin.__headertipval = HeaderTip;
				if DetailedTip ~= nil then
					if type(DetailedTip) == 'table' then
						Pin.__detailedtip = PinDetailedTip;
						Pin.__detailedtipval = DetailedTip;
					elseif type(DetailedTip) == 'string' then
						Pin.__detailedtip = PinDetailedTip;
						Pin.__detailedtipval = { DetailedTip, };
					end
				end
			elseif type(HeaderTip) == 'string' then
				Pin.__headertip = PinHeaderTipStr;
				Pin.__headertipval = HeaderTip;
				if DetailedTip ~= nil then
					if type(DetailedTip) == 'table' then
						Pin.__detailedtip = PinDetailedTip;
						Pin.__detailedtipval = DetailedTip;
					elseif type(DetailedTip) == 'string' then
						Pin.__detailedtip = PinDetailedTip;
						Pin.__detailedtipval = { DetailedTip, };
					end
				end
			end
		end
	--	Font
		local function PinSetTextFont(Pin)
			Pin.Text:SetFont(__private.PinTextFont, _db.PinSize - 4, "");
			Pin.Text.__blz = false;
		end
		local function PinSetTextBLZFont(Pin)
			Pin.Text:SetFont(__private.PinTextBLZFont, _db.PinSize - 9, "");
			Pin.Text.__blz = true;
		end
		local function PinRefreshTextFont(Pin)
			local Text = Pin.Text;
			if Text.__blz then
				Text:SetFont(__private.PinTextBLZFont, _db.PinSize - 9, "");
			else
				Text:SetFont(__private.PinTextFont, _db.PinSize - 4, "");
			end
		end
	--	Drag
		local function PinOnDragStart(Pin)
			DockerOnDragStart(Docker);
		end
		local function PinOnDragStop(Pin)
			DockerOnDragStop(Docker);
		end
	--
		local function PinSetOrder(Pin, order, refresh)
			_T_Pins[Pin] = order;
			if refresh ~= false and Pin:IsShown() then
				Docker:HidePin(Pin);
				Docker:ShowPin(Pin);
			end
		end
	--
	function Docker:CreatePin(order)
		order = order or 1023;
		local Pin = CreateFrame('Button', nil, Docker);
		Pin:SetWidth(_db.PinSize);
		Pin:SetHeight(_db.PinSize);
		Pin:Show();
		Pin:SetHighlightTexture(TEXTURE_PATH .. [[HLCircle]]);
		Pin:EnableMouse(true);
		Pin:SetMovable(true);
		Pin:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		Pin:RegisterForDrag("LeftButton", "RightButton");
		Pin:SetScript("OnEnter", PinOnEnter);
		Pin:SetScript("OnLeave", PinOnLeave);
		Pin:SetScript("OnDragStart", PinOnDragStart);
		Pin:SetScript("OnDragStop", PinOnDragStop);
		local Text = Pin:CreateFontString(nil, "ARTWORK", nil, 7);
		Text:SetPoint("CENTER");
		Text:SetJustifyH("CENTER");
		Text:SetJustifyV("CENTER");
		Pin.Text = Text;
		local Icon = Pin:CreateTexture(nil, "ARTWORK", nil, 7);
		Icon:SetAllPoints();
		Pin.Icon = Icon;
		_T_Pins[Pin] = order;
		Pin.SetTip = PinSetTip;
		Pin.SetTextFont = PinSetTextFont;
		Pin.SetTextBLZFont = PinSetTextBLZFont;
		Pin.RefreshTextFont = PinRefreshTextFont;
		Pin.SetOrder = PinSetOrder;
		Pin.__theme = {  };
		for index = 1, #_T_ThemeMethod do
			local method = _T_ThemeMethod[_T_ThemeMethod[index]];
			if method ~= nil then
				xpcall(method, geterrorhandler(), "__add", Pin, Pin.__theme);
			end
		end
		Pin:SetTextFont();
		return Pin;
	end
	function Docker:ShowPin(Pin)
		local order = _T_Pins[Pin];
		if order ~= nil and _T_DockerPins[Pin] == nil then
			Pin:Show();
			_T_DockerPins[Pin] = order;
			if _I_DockerPins == 0 then
				_I_DockerPins = 1;
				_T_DockerPins[1] = Pin;
				Docker:PlaceFirst(Pin);
			elseif _I_DockerPins == 1 then
				_I_DockerPins = 2;
				local Pin1 = _T_DockerPins[1];
				if order < _T_Pins[Pin1] then
					_T_DockerPins[1] = Pin;
					_T_DockerPins[2] = Pin1;
					Docker:PlaceFirst(Pin);
					Docker:PlaceTo(Pin1, Pin);
				else
					_T_DockerPins[2] = Pin;
					Docker:PlaceTo(Pin, Pin1);
				end
			else
				local Pin1 = _T_DockerPins[1];
				local PinN = _T_DockerPins[_I_DockerPins];
				if order < _T_Pins[Pin1] then
					_I_DockerPins = _I_DockerPins + 1;
					Docker:PlaceFirst(Pin);
					Docker:PlaceTo(Pin1, Pin);
					tinsert(_T_DockerPins, 1, Pin);
				elseif order >= _T_Pins[PinN] then
					_I_DockerPins = _I_DockerPins + 1;
					_T_DockerPins[_I_DockerPins] = Pin;
					Docker:PlaceTo(Pin, PinN);
				else
					for index = 2, _I_DockerPins do
						local PinI = _T_DockerPins[index];
						if order < _T_Pins[PinI] then
							_I_DockerPins = _I_DockerPins + 1;
							Docker:PlaceTo(Pin, _T_DockerPins[index - 1]);
							Docker:PlaceTo(PinI, Pin);
							tinsert(_T_DockerPins, index, Pin);
							break;
						end
					end
				end
			end
			Docker:ResizeDocker();
		end
	end
	function Docker:HidePin(Pin)
		if _T_DockerPins[Pin] ~= nil then
			Pin:Hide();
			Pin:ClearAllPoints();
			_T_DockerPins[Pin] = nil;
			if Pin == _T_DockerPins[1] then
				if _T_DockerPins[2] ~= nil then
					Docker:PlaceFirst(_T_DockerPins[2]);
				end
				tremove(_T_DockerPins, 1);
				_I_DockerPins = _I_DockerPins - 1;
			elseif Pin == _T_DockerPins[_I_DockerPins] then
				_T_DockerPins[_I_DockerPins] = nil;
				_I_DockerPins = _I_DockerPins - 1;
			elseif _I_DockerPins > 2 then
				for index = 2, _I_DockerPins - 1 do
					if _T_DockerPins[index] == Pin then
						Docker:PlaceTo(_T_DockerPins[index + 1], _T_DockerPins[index - 1]);
						tremove(_T_DockerPins, index);
						_I_DockerPins = _I_DockerPins - 1;
						break;
					end
				end
			end
			Docker:ResizeDocker();
		end
	end
	--
	function Docker:AddThemeMethod(which, method)
		_T_ThemeMethod:__add(which, method);
		for Pin, order in next, _T_Pins do
			xpcall(method, geterrorhandler(), "__add", Pin, Pin.__theme);
		end
	end
	function Docker:DelThemeMethod(which)
		_T_ThemeMethod:__del(which);
		for Pin, order in next, _T_Pins do
			xpcall(method, geterrorhandler(), "__sub", Pin, Pin.__theme);
		end
	end
	function Docker:SetThemeMethod(which, method)
		for index = 1, #_T_ThemeMethod do
			local method = _T_ThemeMethod[_T_ThemeMethod[index]];
			if method ~= nil then
				for Pin, order in next, _T_Pins do
					xpcall(method, geterrorhandler(), "__sub", Pin, Pin.__theme);
				end
			end
		end
		_T_ThemeMethod:__deepwipe();
		Docker:AddThemeMethod(which, method);
	end
	--
	local _ChatFrameSetPoint = ChatFrame1.SetPoint;
	local _ChatFrameEditBoxSetPoint = ChatFrame1EditBox.SetPoint;
	function Docker:RefreshPosition(EditBox)
		Docker.__ActiveEditBox = EditBox;
		if _db.Position == "below.editbox" then
			Docker:ClearAllPoints();
			Docker:SetPoint("TOPLEFT", EditBox, "BOTTOMLEFT", 5, 2);
			if _db.AutoAdjustEditBox then
				local EBH = EditBox:GetHeight();
				local DH = _db.PinSize + _db.YToBorder * 2;
				local ChatFrame = EditBox.chatFrame;
				local B = ChatFrame:GetBottom();
				if B > EBH + DH - 2 then
					if EditBox.__manualset then
						EditBox:ClearAllPoints();
						EditBox:SetPoint("TOPLEFT", ChatFrame, "BOTTOMLEFT", -5, -2);
						EditBox:SetPoint("TOPRIGHT", ChatFrame, "BOTTOMRIGHT", 5, -2);
						EditBox.__manualset = nil;
					end
				elseif EditBox:GetBottom() < B or EditBox.__manualset then
					EditBox:ClearAllPoints();
					EditBox:SetPoint("LEFT", ChatFrame, "LEFT", -5, 0);
					EditBox:SetPoint("RIGHT", ChatFrame, "RIGHT", 5, 0);
					EditBox:SetPoint("BOTTOM", ChatFrame.__Tab, "TOP", 0, DH - 2);
					EditBox.__manualset = true;
				end
			end
		elseif _db.Position == "above.editbox" then
			Docker:ClearAllPoints();
			Docker:SetPoint("BOTTOMLEFT", EditBox, "TOPLEFT", 5, -2);
			if _db.AutoAdjustEditBox then
				EditBox.__manualset = true;
				local EBH = EditBox:GetHeight();
				local DH = _db.PinSize + _db.YToBorder * 2;
				local ChatFrame = EditBox.chatFrame;
				local B = ChatFrame:GetBottom();
				if B > EBH + DH then
					EditBox:ClearAllPoints();
					EditBox:SetPoint("TOPLEFT", ChatFrame, "BOTTOMLEFT", -5, -6 - DH);
					EditBox:SetPoint("TOPRIGHT", ChatFrame, "BOTTOMRIGHT", 5, -6 - DH);
				else
					EditBox:ClearAllPoints();
					EditBox:SetPoint("LEFT", ChatFrame, "LEFT", -5, 0);
					EditBox:SetPoint("RIGHT", ChatFrame, "RIGHT", 5, 0);
					EditBox:SetPoint("BOTTOM", ChatFrame.__Tab, "TOP", 0, -2);
				end
			end
		elseif _db.Position == "manual" then
			Docker.__ActiveEditBox = nil;
		end
	end
	hooksecurefunc("ChatEdit_SetLastActiveWindow", function(EditBox)
		if Docker.__ActiveEditBox ~= EditBox then
			Docker:RefreshPosition(EditBox);
		end
	end);
	hooksecurefunc("SetChatWindowSavedPosition", function(id)
		if Docker.__ActiveEditBox ~= nil then
			Docker:RefreshPosition(Docker.__ActiveEditBox);
		end
	end);
	hooksecurefunc("SetChatWindowSavedDimensions", function(id)
		if Docker.__ActiveEditBox ~= nil then
			Docker:RefreshPosition(Docker.__ActiveEditBox);
		end
	end);
	hooksecurefunc("FCFTab_OnUpdate", function(Tab)
		if Docker.__ActiveEditBox ~= nil then
			Docker:RefreshPosition(Docker.__ActiveEditBox);
		end
	end);
	-- local function ClickAnywhereButtonOnClick()
	-- end
	-- for index = 1, NUM_CHAT_WINDOWS do
	-- 	local c = _G["ChatFrame" .. index .. "ClickAnywhereButton"];
	-- 	if c ~= nil then
	-- 		c:HookScript("OnClick", ClickAnywhereButtonOnClick);
	-- 	end
	-- end
	--
	local ChatFrames = __private.__chatFrames;
	for index = 1, NUM_CHAT_WINDOWS do
		local F = ChatFrames[index];
		F:HookScript("OnSizeChanged", function(F)
			local EditBox = F.editBox;
			if EditBox == Docker.__ActiveEditBox then
				Docker:RefreshPosition(EditBox);
			end
		end);
	end
	local function InitDocker()
		Docker:SetClampedToScreen(true);
		Docker:SetMovable(true);
		Docker:RegisterForDrag("LeftButton", "RightButton");
		Docker:SetScript("OnDragStart", DockerOnDragStart);
		Docker:SetScript("OnDragStop", DockerOnDragStop);
		Docker:SetAlpha(_db.alpha);
		Docker:SetSize(1, _db.PinSize);
		Docker:SetFade();
		Docker:RefreshPosition(ChatEdit_ChooseBoxForSend());
		if _db.Position == "manual" then
			Docker:LoadManualPosition();
		end
		local _Backdrop = Docker:CreateTexture(nil, "BACKGROUND");
		_Backdrop:SetAllPoints();
		local color = _db.BackdropColor;
		local alpha = _db.BackdropAlpha;
		_Backdrop:SetColorTexture(color[1], color[2], color[3], alpha);
		_Backdrop:SetShown(_db.Backdrop);
		Docker._Backdrop = _Backdrop;
		Docker.__ActiveEditBox = SELECTED_CHAT_FRAME ~= nil and SELECTED_CHAT_FRAME.editBox;
	end
	Docker.PinList = _T_DockerPins;
	__private.__docker = Docker;
-->

-->		Method
	--
-->

-->		Init
	local B_Initialized = false;
	local function Init()
		B_Initialized = true;
		InitDocker();
	end
-->

-->		Module
	function __docker.Position(value, loading, interacting)
		if Docker.__ActiveEditBox ~= nil then
			Docker:RefreshPosition(Docker.__ActiveEditBox);
		end
		if value == "manual" then
			Docker.__isAttachedToEditBox = false;
			if not loading then
				Docker:SaveManualPosition(interacting ~= true);
				local ChatFrames = __private.__chatFrames;
				for index = 1, NUM_CHAT_WINDOWS do
					local F = ChatFrames[index];
					local EditBox = F.editBox;
					EditBox:ClearAllPoints();
					EditBox:SetPoint("TOPLEFT", F, "BOTTOMLEFT", -5, -2);
					EditBox:SetPoint("TOPRIGHT", F, "BOTTOMRIGHT", 5, -2);
				end
			end
		else
			Docker.__isAttachedToEditBox = true;
		end
	end
	function __docker.AutoAdjustEditBox(value, loading)
		if not loading and Docker.__ActiveEditBox ~= nil then
			Docker:RefreshPosition(Docker.__ActiveEditBox);
		end
	end
	function __docker.Direction(value, loading)
		if not loading then
			Docker:ReLayoutPins();
		end
	end
	function __docker.alpha(value, loading)
		if not loading then
			Docker:SetFade();
		end
	end
	function __docker.FadedAlpha(value, loading)
		if not loading then
			Docker:SetFade();
		end
	end
	function __docker.FadeOutTime(value, loading)
		if not loading then
			Docker:SetFade();
		end
	end
	function __docker.FadeOutDelay(value, loading)
		if not loading then
			Docker:SetFade();
		end
	end
	function __docker.FadInTime(value, loading)
		if not loading then
			Docker:SetFade();
		end
	end
	function __docker.Backdrop(value, loading)
		if not loading then
			Docker._Backdrop:SetShown(value);
		end
	end
	function __docker.BackdropColor(value, loading)
		if not loading then
			local alpha = _db.BackdropAlpha;
			Docker._Backdrop:SetColorTexture(value[1], value[2], value[3], alpha);
		end
	end
	function __docker.BackdropAlpha(value, loading)
		if not loading then
			local color = _db.BackdropColor;
			Docker._Backdrop:SetColorTexture(color[1], color[2], color[3], value);
		end
	end
	function __docker.PinSize(value, loading)
		if not loading then
			Docker:SetPinSize(value);
		end
	end
	function __docker.PinInt(value, loading)
		if not loading then
			Docker:SetPinInt(value);
		end
	end
	function __docker.PinStyle(value, loading)
		if not loading then
			__private:SetDBAllModulesExceptOne("PinStyle", value, "docker", false);
			__private:SetDB("channeltab", "UseColor", value ~= "char.blz", false);
		end
	end
	function __docker.__init(db, loading)
		_db = db;
		if not B_Initialized then
			Init();
		end
	end

	function __docker.__callback(which, value, loading)
		if __docker[which] ~= nil then
			return __docker[which](value, loading);
		end
	end
	function __docker.__setting()
		__private:AddSetting("GENERAL", { "docker", "Position", 'list', { "below.editbox", "above.editbox", "manual", }, });
		__private:AddSetting("GENERAL", { "docker", "AutoAdjustEditBox", 'boolean', });
		__private:AddSetting("GENERAL", { "docker", "Direction", 'list', { "RIGHT", "LEFT", "DOWN", "UP", }, });
		__private:AlignSetting("GENERAL");
		__private:AddSetting("GENERAL", { "docker", "alpha", 'number', { 0.0, 1.0, 0.05, }, nil, 2, });
		__private:AddSetting("GENERAL", { "docker", "FadInTime", 'number', { 0.0, 4.0, 0.25, }, nil, 2, }, 2, 2);
		__private:AddSetting("GENERAL", { "docker", "FadedAlpha", 'number', { 0.0, 1.0, 0.05, }, nil, 2, });
		__private:AddSetting("GENERAL", { "docker", "FadeOutTime", 'number', { 0.0, 8.0, 0.5, }, nil, 2, }, 2, 2);
		__private:AddSetting("GENERAL", { "docker", "FadeOutDelay", 'number', { 0.0, 8.0, 0.5, }, nil, 2, }, 2, 2);
		__private:AlignSetting("GENERAL");
		__private:AddSetting("GENERAL", { "docker", "Backdrop", 'boolean', });
		__private:AddSetting("GENERAL", { "docker", "BackdropColor", 'color', }, 1);
		__private:AddSetting("GENERAL", { "docker", "BackdropAlpha", 'number', { 0.0, 1.0, 0.05, }, nil, 2, }, 1);
		__private:AlignSetting("GENERAL");
		__private:AddSetting("GENERAL", { "docker", "PinSize", 'number', { 12, 48, 1, }, nil, 0, });
		__private:AddSetting("GENERAL", { "docker", "PinInt", 'number', { -8, 16, 1, }, nil, 0, }, 2, 2);
		__private:AddSetting("GENERAL", { "docker", "PinStyle", 'list', { "char", "char.blz", "circle.blur", "circle", "square.blur", "square", }, });
	end

	__private.__module["docker"] = __docker;
-->
