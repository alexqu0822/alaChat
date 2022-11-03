--	TODO Binding
local __addon, __private = ...;
local L = __private.L;

local TEXTURE_PATH = __private.TEXTURE_PATH;
local PIN_ORDER_OFFSET = 8;

local TABSHORT = L.TABSHORT;

local hooksecurefunc = hooksecurefunc;
local select = select;
local next = next;
local tinsert = table.insert;
local strtrim, gsub = string.trim, string.gsub;
local C_Timer = C_Timer;
local IsAltKeyDown = IsAltKeyDown;
local GetChannelList = GetChannelList;
local JoinPermanentChannel, LeaveChannelByName = JoinPermanentChannel, LeaveChannelByName;
local EnumerateServerChannels = EnumerateServerChannels;
local C_ChatInfo = C_ChatInfo;
local CreateFrame = CreateFrame;
local GetMouseFocus = GetMouseFocus;
local GameTooltip = GameTooltip;
local ChatEdit_ActivateChat, ChatEdit_DeactivateChat = ChatEdit_ActivateChat, ChatEdit_DeactivateChat;
local ChatTypeInfo = ChatTypeInfo;
local _G = _G;

local PLAYER_GUID = UnitGUID('player');
local __channeltab = {  };
local _db = {  };
local _bfworldcf = {  };

local __pins1 = {  };	--	Normal
local __pins2 = {  };	--	Channel
local __pins3 = {  };	--	Join Channel	[Key] = Pin
local __KeyPins = {  };	--	[Key] = { [Type] = Pin, ... };[Auxiliary Var for Settings]
local __cblocks = {  };
local __channelKey2 = {  };
local __enabledChannelKey2 = {  };
local __channelBlocked = {  };
local __ModifierFunc = nil;
local _ExecuteAutoJoin = true;

if __private.__is_dev then
	__private:BuildEnv("channeltab");
end

--[==[
	SwapChatChannelByLocalID
	C_ChatInfo.SwapChatChannelsByChannelIndex
	ChangeChatColor(channel, r, g, b)
--]==]

-->		Data
	local CHATTYPE = {
		"SAY",
		"PARTY",
		"RAID",
		"RAID_WARNING",
		"INSTANCE_CHAT",
		"GUILD",
		"YELL",
		"WHISPER",
		"OFFICER",
	};
	local CHATTYPEEVENT = {
		["SAY"] = "CHAT_MSG_SAY",
		["PARTY"] = "CHAT_MSG_PARTY",
		["RAID"] = "CHAT_MSG_RAID",
		["RAID_WARNING"] = "CHAT_MSG_RAID_WARNING",
		["INSTANCE_CHAT"] = "CHAT_MSG_INSTANCE_CHAT",
		["GUILD"] = "CHAT_MSG_GUILD",
		["YELL"] = "CHAT_MSG_YELL",
		["WHISPER"] = "CHAT_MSG_WHISPER",
		["OFFICER"] = "CHAT_MSG_OFFICER",
	};
	local CHANNELLIST = nil;
	local CHANNELHASH = {  };
	local HEADER = {
		SAY = "/s ",
		PARTY = "/p ",
		RAID = "/raid ",
		RAID_WARNING = "/rw ",
		INSTANCE_CHAT = "/bg ",
		GUILD = "/g ",
		YELL = "/y ",
		WHISPER = "/w ",
		OFFICER = "/o ",
	};
	for index = 1, 64 do
		HEADER[index] = "/" .. index .. " ";
	end
	local ChannelHasJoinButton = {
		"GENERAL",
		"TRADE",
		"LOOK_FOR_GROUP",
	};
	local ChannelPinOrder = {
		GENERAL = -5,
		TRADE = -4,
		LOCAL_DEFENSE = -3,
		LOOK_FOR_GROUP = -2,
	};
	local HashBFWORLD = {  };
	local function BuildTable()
		if L.ExactLocale then
			CHANNELLIST = {
				GENERAL = GENERAL,
				TRADE = TRADE,
				LOCAL_DEFENSE = L.LocalizedChannelName.LOCAL_DEFENSE,
				LOOK_FOR_GROUP = L.LocalizedChannelName.LOOK_FOR_GROUP,
			};
			tinsert(ChannelHasJoinButton, 3, "LOCAL_DEFENSE");
			if L.Locale == "zhCN" or L.Locale == "zhTW" then
				CHANNELLIST.BF_WORLD = "大脚世界频道";
				CHANNELHASH["大脚世界频道"] = "BF_WORLD";
				HashBFWORLD["大脚世界频道"] = 0;
				HashBFWORLD.BF_WORLD = 0;
				for index = 1, 10 do
					CHANNELHASH["大脚世界频道" .. index] = "BF_WORLD" .. index;
					__KeyPins["BF_WORLD" .. index] = {  };
					HashBFWORLD["大脚世界频道" .. index] = index;
					HashBFWORLD["BF_WORLD" .. index] = index;
				end
				__KeyPins.BF_WORLD = {  };
				ChannelHasJoinButton[#ChannelHasJoinButton + 1] = "BF_WORLD";
				ChannelPinOrder.BF_WORLD = -1;
			end
		else
			CHANNELLIST = {  };
			local FuzzyName = {
				GENERAL = GENERAL,
				TRADE = TRADE,
				LOOK_FOR_GROUP = LOOK_FOR_GROUP,
			};
			local list = { EnumerateServerChannels() };
			local LevenshteinDistance;
			if CalculateStringEditDistance ~= nil then
				LevenshteinDistance = CalculateStringEditDistance;
			else
				--	credit https://gist.github.com/Badgerati/3261142
				local strbyte, min = strbyte, math.min;
				function LevenshteinDistance(str1, str2)
					-- quick cut-offs to save time
					if str1 == "" then
						return #str2;
					elseif str2 == "" then
						return #str1;
					elseif str1 == str2 then
						return 0;
					end

					local len1 = #str1;
					local len2 = #str2;
					local matrix = {  };

					-- initialise the base matrix values
					for i = 0, len1 do
						matrix[i] = {  };
						matrix[i][0] = i;
					end
					for j = 0, len2 do
						matrix[0][j] = j;
					end

					-- actual Levenshtein algorithm
					for i = 1, len1 do
						for j = 1, len2 do
							if strbyte(str1, i) == strbyte(str2, j) then
								matrix[i][j] = min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1, matrix[i - 1][j - 1]);
							else
								matrix[i][j] = min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1, matrix[i - 1][j - 1] + 1)
							end
						end
					end

					-- return the last value - this is the Levenshtein distance
					return matrix[len1][len2];
				end
			end
			if list[1] ~= nil then
				for which, fuzzy in next, FuzzyName do
					local best = 1;
					if list[1] ~= fuzzy then
						local co = LevenshteinDistance(list[1], fuzzy);
						for index = 2, #list do
							local c = list[index];
							if c == fuzzy then
								best = index;
								break;
							else
								local co2 = LevenshteinDistance(list[index], fuzzy);
								if co2 < co then
									co = co2;
									best = index;
								end
							end
						end
					end
					CHANNELLIST[which] = list[best];
				end
			end
		end
		for key, channelName in next, CHANNELLIST do
			__KeyPins[key] = {  };
			CHANNELHASH[channelName] = key;
		end
		__KeyPins.UNMANAGEDCHANNEL = {  };
	end
-->

-->		MessageFilter
	local function ChatMessageBlock()
		return true;
	end
	local function ChatChannelMessageBlock(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, channelIndex, ...)
		local Key2 = __channelKey2[channelIndex];
		if __channelBlocked[Key2] then
			return true;
		else
			return false;
		end
	end
-->

-->		GUI
	--	Type:		SAY, PARTY, ..., CHANNEL1, CHANNEL2, ...
	--	isChannel:	boolean
	--	Target:		SAY, PARTY, ...,        1,        2, ...
	--	Key:		SAY, PARTY, ...,							GENERAL, TRADE, ...							--	key of __pin3. (Pin.Key)
	--	Key2:													General, Trade, ... channelName				--	for _db._channelblocked & __channelBlocked. (Pin.Key2)
	local function SetEditBoxHeader(isChannel, Target)
		local editBox = ChatEdit_ChooseBoxForSend();
		if isChannel then
			if editBox:HasFocus() then
				if editBox:GetAttribute("chatType") == "CHANNEL" and editBox:GetAttribute("channelTarget") == Target then
					ChatEdit_DeactivateChat(editBox);
				else
					editBox:SetText(HEADER[Target] .. editBox:GetText():gsub("^/[^ ]+[ ]+", ""));
				end
			else
				ChatEdit_ActivateChat(editBox);
				editBox:SetText(HEADER[Target]);
			end
		else
			if Target == "INSTANCE_CHAT" and not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
				if IsInRaid() then
					Target = "RAID";
				elseif IsInGroup() then
					Target = "PARTY";
				else
					return;
				end
			end
			if editBox:HasFocus() then
				if editBox:GetAttribute("chatType") == Target or (Target == "WHISPER" and strtrim(editBox:GetText()) == "/w") then
					ChatEdit_DeactivateChat(editBox);
				else
					editBox:SetText(HEADER[Target] .. editBox:GetText():gsub("^/[^ ]+ ", ""));
				end
			else
				ChatEdit_ActivateChat(editBox);
				editBox:SetText(HEADER[Target]);
			end
		end
	end
	local function IsChannelJoined(channel, ...)
		local num = select("#", ...);
		num = num - num % 1.0;
		for index = 1, num do
			if select(index * 3 - 1) == channel then
				return true;
			end
		end
		return false;
	end
	--
	local function ChannelBlockButtonOnUpdate(Button, elapsed)
		if Button._fadding then
			Button._faddingAlpha = Button._faddingAlpha - elapsed * 0.5;
			if Button._faddingAlpha <= Button.__alpha0 then
				Button:SetScript("OnUpdate", nil);
				Button:SetAlpha(Button.__alpha0);
				Button._fadding = false;
			else
				Button:SetAlpha(Button._faddingAlpha);
			end
		else
			Button._timer = Button._timer - elapsed;
			if Button._timer <= 0 then
				Button._fadding = true;
			end
		end
	end
	local function ChannelBlockButtonOnEnter(Button)
		Button:SetScript("OnUpdate", nil);
		Button:SetAlpha(Button.__alpha1);
	end
	local function ChannelBlockButtonOnLeave(Button)
		Button._timer = 1.0;
		Button._fadding = false;
		Button._faddingAlpha = Button.__alpha1;
		Button:SetScript("OnUpdate", ChannelBlockButtonOnUpdate);
	end
	local function ChannelBlockButtonOnClick(Button)
		local __Mode = Button.__Mode;
		if Button.isBlocked then
			Button:GetNormalTexture():SetVertexColor(1.0, 1.0, 1.0, 1.0);
			Button:GetPushedTexture():SetVertexColor(1.0, 1.0, 1.0, 0.5);
			Button.isBlocked = nil;
			if __Mode == "CHANNEL" then
				for Key, Pins in next, __KeyPins do
					if HashBFWORLD[Key] == nil then
						for Type, Pin in next, Pins do
							local Key2 = Pin.Key2;
							if __channelBlocked[Key2] then
								_db._channelblocked[Key2] = nil;
								__channelBlocked[Key2] = nil;
								Pin.Blocked:Hide();
							end
						end
					end
				end
			elseif __Mode == "BFWORLD" then
				for Key, Pins in next, __KeyPins do
					if HashBFWORLD[Key] ~= nil then
						for Type, Pin in next, Pins do
							local Key2 = Pin.Key2;
							if __channelBlocked[Key2] then
								_db._channelblocked[Key2] = nil;
								__channelBlocked[Key2] = nil;
								Pin.Blocked:Hide();
							end
						end
					end
				end
				if not IsChannelJoined("大脚世界频道", GetChannelList()) then
					JoinPermanentChannel("大脚世界频道");
				end
			end
			Button.__alpha0 = 0.25;
			if GetMouseFocus() ~= Button then
				Button._fadding = true;
				Button._faddingAlpha = Button:GetAlpha();
				Button:SetScript("OnUpdate", ChannelBlockButtonOnUpdate);
			end
		else
			Button:GetNormalTexture():SetVertexColor(1.0, 0.0, 0.0, 1.0);
			Button:GetPushedTexture():SetVertexColor(1.0, 0.0, 0.0, 0.5);
			Button.isBlocked = true;
			if __Mode == "CHANNEL" then
				for Key, Pins in next, __KeyPins do
					if HashBFWORLD[Key] == nil then
						for Type, Pin in next, Pins do
							local Key2 = Pin.Key2;
							if __channelBlocked[Key2] == nil then
								_db._channelblocked[Key2] = true;
								__channelBlocked[Key2] = true;
								Pin.Blocked:Show();
							end
						end
					end
				end
			elseif __Mode == "BFWORLD" then
				for Key, Pins in next, __KeyPins do
					if HashBFWORLD[Key] ~= nil then
						for Type, Pin in next, Pins do
							local Key2 = Pin.Key2;
							if __channelBlocked[Key2] == nil then
								_db._channelblocked[Key2] = true;
								__channelBlocked[Key2] = true;
								Pin.Blocked:Show();
							end
						end
					end
				end
			end
			Button:SetAlpha(1.0);
			Button.__alpha0 = 1.0;
			Button:SetScript("OnUpdate", nil);
		end
	end
	local function CreateChannelBlockButton(TEXTURE, Mode)
		local Button = CreateFrame('BUTTON', nil, GeneralDockManager);
		Button:SetWidth(_db.ChannelBlockButton_Size);
		Button:SetHeight(_db.ChannelBlockButton_Size);
		Button:SetNormalTexture(TEXTURE);
		Button:SetPushedTexture(TEXTURE);
		Button:SetHighlightTexture(TEXTURE);
		Button:GetHighlightTexture():SetVertexColor(1.0, 1.0, 1.0, 0.25);
		Button:SetAlpha(1.0);
		Button:SetFrameLevel(ChatFrame1:GetFrameLevel() + 1);
		Button:SetMovable(false);
		Button:EnableMouse(true);
		Button:ClearAllPoints();
		Button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		Button.__Mode = Mode;
		Button:SetScript("OnClick", ChannelBlockButtonOnClick);
		Button.__alpha1 = 1.0;
		Button.__alpha0 = 0.25;
		Button._timer = 0;
		Button._fadding = false;
		Button._faddingAlpha = Button.__alpha0;
		Button:SetScript("OnEnter", ChannelBlockButtonOnEnter);
		Button:SetScript("OnLeave", ChannelBlockButtonOnLeave);
		Button:Show();
		return Button;
	end
	local function CreateChannelBlockButtons()
		local CB = CreateChannelBlockButton(TEXTURE_PATH .. "channel", "CHANNEL");
		CB:SetPoint("TOPRIGHT", ChatFrame1, "TOPRIGHT", -4, -4);
		__cblocks[".Button-Channel"] = CB;
		CB:SetShown(_db.ChannelBlockButton_BLZ);
		if L.Locale == "zhCN" or L.Locale == "zhTW" then
			local WB = CreateChannelBlockButton(TEXTURE_PATH .. "bfworld", "BFWORLD");
			WB:SetPoint("RIGHT", CB, "LEFT", -4, 0);
			__cblocks[".Button-BfWorld"] = WB;
			WB:SetShown(_db.ChannelBlockButton_World);
		end
	end
	local function UpdateBlockButtonStatus()
		local Channel = __cblocks[".Button-Channel"];
		if Channel ~= nil then
			local total, red = 0, 0;
			for index = 1, #__enabledChannelKey2 do
				local Key2 = __enabledChannelKey2[index];
				if HashBFWORLD[Key2] == nil then
					total = total + 1;
					if __channelBlocked[Key2] then
						red = red + 1;
					end
				end
			end
			for index = 1, #ChannelHasJoinButton do
				local Key2 = ChannelHasJoinButton[index];
				if HashBFWORLD[Key2] == nil and __enabledChannelKey2[Key2] == nil then
					total = total + 1;
					if _db._channelblocked[Key2] then
						red = red + 1;
					end
				end
			end
			if red == 0 then
				Channel:GetNormalTexture():SetVertexColor(1.0, 1.0, 1.0, 1.0);
				Channel:GetPushedTexture():SetVertexColor(1.0, 1.0, 1.0, 0.5);
				Channel.isBlocked = nil;
				Channel.__alpha0 = 0.25;
				Channel._fadding = true;
				Channel._faddingAlpha = Channel:GetAlpha();
				Channel:SetScript("OnUpdate", ChannelBlockButtonOnUpdate);
			elseif red < total then
				Channel:GetNormalTexture():SetVertexColor(1.0, 1.0, 0.0, 1.0);
				Channel:GetPushedTexture():SetVertexColor(1.0, 1.0, 0.0, 0.5);
				Channel.isBlocked = nil;
				Channel:SetAlpha(1.0);
				Channel.__alpha0 = 1.0;
				Channel:SetScript("OnUpdate", nil);
			else
				Channel:GetNormalTexture():SetVertexColor(1.0, 0.0, 0.0, 1.0);
				Channel:GetPushedTexture():SetVertexColor(1.0, 0.0, 0.0, 0.5);
				Channel.isBlocked = true;
				Channel:SetAlpha(1.0);
				Channel.__alpha0 = 1.0;
				Channel:SetScript("OnUpdate", nil);
			end
		end
		local BfWorld = __cblocks[".Button-BfWorld"];
		if BfWorld ~= nil then
			local total, red = 0, 0;
			for index = 1, #__enabledChannelKey2 do
				local Key2 = __enabledChannelKey2[index];
				if HashBFWORLD[Key2] ~= nil then
					total = total + 1;
					if __channelBlocked[Key2] then
						red = red + 1;
					end
				end
			end
			for index = 1, #ChannelHasJoinButton do
				local Key2 = ChannelHasJoinButton[index];
				if HashBFWORLD[Key2] ~= nil and __enabledChannelKey2[Key2] == nil then
					total = total + 1;
					if _db._channelblocked[Key2] then
						red = red + 1;
					end
				end
			end
			if red == 0 then
				BfWorld:GetNormalTexture():SetVertexColor(1.0, 1.0, 1.0, 1.0);
				BfWorld:GetPushedTexture():SetVertexColor(1.0, 1.0, 1.0, 0.5);
				BfWorld.isBlocked = nil;
				BfWorld.__alpha0 = 0.25;
				BfWorld._fadding = true;
				BfWorld._faddingAlpha = BfWorld:GetAlpha();
				BfWorld:SetScript("OnUpdate", ChannelBlockButtonOnUpdate);
			elseif red < total then
				BfWorld:GetNormalTexture():SetVertexColor(1.0, 1.0, 0.0, 1.0);
				BfWorld:GetPushedTexture():SetVertexColor(1.0, 1.0, 0.0, 0.5);
				BfWorld.isBlocked = nil;
				BfWorld:SetAlpha(1.0);
				BfWorld.__alpha0 = 1.0;
				BfWorld:SetScript("OnUpdate", nil);
			else
				BfWorld:GetNormalTexture():SetVertexColor(1.0, 0.0, 0.0, 1.0);
				BfWorld:GetPushedTexture():SetVertexColor(1.0, 0.0, 0.0, 0.5);
				BfWorld.isBlocked = true;
				BfWorld:SetAlpha(1.0);
				BfWorld.__alpha0 = 1.0;
				BfWorld:SetScript("OnUpdate", nil);
			end
		end
	end
	--
	local function PinOnClick(Pin, button)
		if Pin.isChannel and __ModifierFunc ~= nil and __ModifierFunc() then
			LeaveChannelByName(Pin.channelName);
			_ExecuteAutoJoin = false;
			return;
		end
		if Pin["*Type.Join"] == true then
			_db._channelblocked[Pin.Type] = nil;
			__channelBlocked[Pin.Type] = nil;
			JoinPermanentChannel(Pin.channelName);
		elseif button == "LeftButton" then
			SetEditBoxHeader(Pin.isChannel, Pin.Target);
		else
			if Pin.isChannel then
				local Key = Pin.Key;
				local Key2 = Pin.Key2;
				if __channelBlocked[Key2] then
					_db._channelblocked[Key2] = nil;
					__channelBlocked[Key2] = nil;
					if Key ~= nil then
						local PinsOfChannelType = __KeyPins[Key];
						for _, Pin2 in next, PinsOfChannelType do
							Pin2.Blocked:Hide();
						end
					end
					Pin.Blocked:Hide();
				else
					_db._channelblocked[Key2] = true;
					__channelBlocked[Key2] = true;
					if Key ~= nil then
						local PinsOfChannelType = __KeyPins[Key];
						for _, Pin2 in next, PinsOfChannelType do
							Pin2.Blocked:Show();
						end
					end
					Pin.Blocked:Show();
				end
				UpdateBlockButtonStatus();
			else
				local Type = Pin.Type;
				if _db._chatblocked[Type] then
					__private:DelMessageFilter(CHATTYPEEVENT[Type], "chattypeblocked", ChatMessageBlock);
					Pin.Blocked:Hide();
					_db._chatblocked[Type] = nil;
				else
					__private:AddMessageFilter(CHATTYPEEVENT[Type], "chattypeblocked", ChatMessageBlock);
					Pin.Blocked:Show();
					_db._chatblocked[Type] = true;
				end
			end
		end
	end
	local function PinHeaderTip(Pin)
		GameTooltip:SetOwner(Pin, "ANCHOR_TOPLEFT");
		local Type = Pin.Type;
		local color = Pin.Color or ChatTypeInfo[Type];
		local tip = Pin.channelName;
		if color ~= nil then
			GameTooltip:SetText(tip, color.r, color.g, color.b);
		else
			GameTooltip:SetText(tip, 1.0, 1.0, 1.0);
		end
		GameTooltip:Show();
	end
	--
	local function RefreshPinColor(Pin)
		local color = ChatTypeInfo[Pin.Type];
		if _db.UseColor and color ~= nil then
			Pin.Text:SetTextColor(color.r, color.g, color.b);
			Pin.Icon:SetVertexColor(color.r, color.g, color.b);
		elseif _db.PinStyle == "char.blz" then
			Pin.Text:SetTextColor(1.0, 0.75, 0.25);
			Pin.Icon:SetVertexColor(1.0, 0.75, 0.25);
		else
			Pin.Text:SetTextColor(1.0, 1.0, 1.0);
			Pin.Icon:SetVertexColor(1.0, 1.0, 1.0);
		end
	end
	local function RefreshPinStyle(Pin)
		if _db.PinStyle == "char.blz" then
			Pin:SetTextBLZFont();
			Pin:SetNormalTexture(TEXTURE_PATH .. "blz_text_normal");
			Pin:SetPushedTexture(TEXTURE_PATH .. "blz_text_pushed");
			Pin:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]]);
			Pin.Text:Show();
			Pin.Icon:Hide();
		else
			Pin:SetTextFont();
			-- Pin:SetNormalTexture("");
			local Texture = Pin:GetNormalTexture(); if Texture ~= nil then Texture:SetColorTexture(0.0, 0.0, 0.0, 0.0); end
			-- Pin:SetPushedTexture("");
			local Texture = Pin:GetPushedTexture(); if Texture ~= nil then Texture:SetColorTexture(0.0, 0.0, 0.0, 0.0); end
			if _db.PinStyle == "char" then
				Pin:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]]);
				Pin.Text:Show();
				Pin.Icon:Hide();
			else
				Pin.Text:Hide();
				Pin.Icon:Show();
				if _db.PinStyle == "circle.blur" then
					Pin:SetHighlightTexture(TEXTURE_PATH .. [[HLCircle]]);
					Pin.Icon:SetTexture(TEXTURE_PATH .. [[channeltabCircleBlur]]);
				elseif _db.PinStyle == "circle" then
					Pin:SetHighlightTexture(TEXTURE_PATH .. [[HLCircle]]);
					Pin.Icon:SetTexture(TEXTURE_PATH .. [[channeltabCircle]]);
				elseif _db.PinStyle == "square.blur" then
					Pin:SetHighlightTexture(TEXTURE_PATH .. [[HLSquare]]);
					Pin.Icon:SetTexture(TEXTURE_PATH .. [[channeltabSquareBlur]]);
				elseif _db.PinStyle == "square" then
					Pin:SetHighlightTexture(TEXTURE_PATH .. [[HLSquare]]);
					Pin.Icon:SetTexture(TEXTURE_PATH .. [[channeltabSquare]]);
				end
			end
		end
	end
	local function CreatePin(order, Type, isChannel, Target, DetailedTip)
		local Pin = __private.__docker:CreatePin(order);
		local Blocked = Pin:CreateTexture(nil, "OVERLAY", nil, 7);
		Blocked:SetAllPoints();
		Blocked:SetTexture(TEXTURE_PATH .. "Blocked");
		Blocked:SetVertexColor(1.0, 0.0, 0.0, 0.5);
		Blocked:Hide();
		Pin.Blocked = Blocked;
		Pin.Type = Type;
		Pin.isChannel = isChannel;
		Pin.Target = Target;
		Pin:SetScript("OnClick", PinOnClick);
		Pin:SetTip(PinHeaderTip, DetailedTip);
		RefreshPinStyle(Pin);
		return Pin;
	end
	local function CheckChatPin()
		for Type, Pin in next, __pins1 do
			__private.__docker:HidePin(Pin);
		end
		for index = 1, #CHATTYPE do
			local Type = CHATTYPE[index];
			local Pin = __pins1[Type];
			if Pin == nil then
				Pin = CreatePin(PIN_ORDER_OFFSET + index, Type, false, Type, L.DETAILEDTIP.channeltab);
				__pins1[Type] = Pin;
			end
			Pin.channelName = _G[Type] or Type;
			RefreshPinColor(Pin)
			Pin.Text:SetText(TABSHORT[Type]);
			if _db[Type] then
				__private.__docker:ShowPin(Pin);
				if _db._chatblocked[Type] then
					__private:AddMessageFilter(CHATTYPEEVENT[Type], "chattypeblocked", ChatMessageBlock);
					Pin.Blocked:Show();
				else
					__private:DelMessageFilter(CHATTYPEEVENT[Type], "chattypeblocked", ChatMessageBlock);
					Pin.Blocked:Hide();
				end
			else
				__private.__docker:HidePin(Pin);
				__private:DelMessageFilter(CHATTYPEEVENT[Type], "chattypeblocked", ChatMessageBlock);
			end
		end
	end
	local function CheckChannelPin(...)
		for Type, Pin in next, __pins2 do
			__private.__docker:HidePin(Pin);
		end
		for Key, tbl in next, __KeyPins do
			__KeyPins[Key] = {  };
		end
		for Type, Pin in next, __pins3 do
			__private.__docker:HidePin(Pin);
		end
		for index = 1, #ChannelHasJoinButton do
			ChannelHasJoinButton[ChannelHasJoinButton[index]] = nil;
		end
		__channelKey2 = {  };
		__enabledChannelKey2 = {  };
		__channelBlocked = {  };
		local num = select("#", ...) / 3;
		num = num - num % 1.0;
		local OrderOfs = PIN_ORDER_OFFSET + #CHATTYPE + 16;
		for index = 1, num do
			local id = select(index * 3 - 2, ...);
			local channelName = select(index * 3 - 1, ...);
			local Key = CHANNELHASH[channelName];
			local Key2 = Key or channelName;
			__channelKey2[id] = Key2;
			if Key ~= nil then
				ChannelHasJoinButton[Key] = true;
			end
			if not select(index * 3, ...) then
				__enabledChannelKey2[#__enabledChannelKey2 + 1] = Key2;
				__enabledChannelKey2[Key2] = id;
				local Type = "CHANNEL" .. id;
				local Pin = __pins2[Type];
				if Pin == nil then
					Pin = CreatePin(OrderOfs + index, Type, true, id, L.DETAILEDTIP.channeltab);
					__pins2[Type] = Pin;
				end
				local order2 = ChannelPinOrder[Key];
				if order2 ~= nil then
					Pin:SetOrder(OrderOfs + order2);
				else
					Pin:SetOrder(OrderOfs + index);
				end
				Pin.Text:SetText(Key and TABSHORT[Key] or id);
				Pin.channelName = channelName;
				Pin.Key = Key;
				Pin.Key2 = Key2;
				RefreshPinColor(Pin);
				if HashBFWORLD[channelName] ~= nil then
					Key = "BF_WORLD";
				else
					Key = Key or "UNMANAGEDCHANNEL";
				end
				if _db[Key] then
					__private.__docker:ShowPin(Pin);
					if _db._channelblocked[Key2] then
						Pin.Blocked:Show();
						__channelBlocked[Key2] = true;
					else
						Pin.Blocked:Hide();
						__channelBlocked[Key2] = nil;
					end
				else
					__private.__docker:HidePin(Pin);
				end
				__KeyPins[Key][Type] = Pin;
			end
		end
		local OrderOfs2 = OrderOfs + 16;
		for index = 1, #ChannelHasJoinButton do
			local Key = ChannelHasJoinButton[index];
			if ChannelHasJoinButton[Key] == nil then
				local Pin = __pins3[Key];
				if Pin == nil then
					local order2 = ChannelPinOrder[Key];
					Pin = CreatePin(order2 ~= nil and (OrderOfs + order2) or (OrderOfs2 + index), Key, true, Key, L.DETAILEDTIP.channeltabjoin);
					Pin.Blocked:Show();
					__pins3[Key] = Pin;
					Pin.Text:SetTextColor(1.0, 0.75294125080109, 0.75294125080109);
					Pin.Text:SetText(TABSHORT[Key] or index);
					Pin.channelName = L.LocalizedChannelName[Key] or Key;
					Pin["*Type.Join"] = true;
				end
				if _db[Key] then
					__private.__docker:ShowPin(Pin);
					if _db._channelblocked[Key] then
						Pin.Blocked:SetVertexColor(1.0, 0.0, 0.0, 0.5);
					else
						Pin.Blocked:SetVertexColor(1.0, 0.5, 0.0, 0.5);
					end
				else
					__private.__docker:HidePin(Pin);
				end
			end
		end
		UpdateBlockButtonStatus();
	end
	--
-->

-->		Method
	local method = {
		["SHIFT"] = function()
			return IsShiftKeyDown();
		end,
		["ALT"] = function()
			return IsAltKeyDown();
		end,
		["CTRL"] = function()
			return IsControlKeyDown();
		end,
		["SHIFT+CTRL"] = function()
			return IsShiftKeyDown() and IsControlKeyDown();
		end,
		["SHIFT+ALT"] = function()
			return IsShiftKeyDown() and IsAltKeyDown();
		end,
		["CTRL+ALT"] = function()
			return IsControlKeyDown() and IsAltKeyDown();
		end,
	};
	local function HookChangeChatColor(Type, r, g, b)
		if _db.UseColor then
			local Pin = __pins1[Type] or __pins2[Type];
			if Pin ~= nil then
				RefreshPinColor(Pin);
			end
		end
	end
	local function UpdatePin()
		CheckChatPin();
		CheckChannelPin(GetChannelList());
	end
	local CHANNEL_PASSWORD_REQUEST = nil;
	local function AutoJoinTicker()
		if ChannelHasJoinButton.BF_WORLD == nil then
			if _ExecuteAutoJoin then
				C_Timer.After(1.0, AutoJoinTicker);
				JoinPermanentChannel("大脚世界频道");
			end
		end
	end
	local function SetAutoJoinWorld()
		if _db.AutoJoinWorld then
			if ChannelHasJoinButton.BF_WORLD == nil then
				_ExecuteAutoJoin = true;
				C_Timer.After(1.0, AutoJoinTicker);
			end
			if CHANNEL_PASSWORD_REQUEST == nil then
				CHANNEL_PASSWORD_REQUEST = CreateFrame('FRAME');
				CHANNEL_PASSWORD_REQUEST:SetScript("OnEvent", function(self, event, channel)
					if channel == "大脚世界频道" then
						_ExecuteAutoJoin = false;
						DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00>|ralachat: 世界频道有密码，停止自动加入。");
					end
				end);
			end
			CHANNEL_PASSWORD_REQUEST:RegisterEvent("CHANNEL_PASSWORD_REQUEST");
		else
			_ExecuteAutoJoin = false;
			if CHANNEL_PASSWORD_REQUEST ~= nil then
				CHANNEL_PASSWORD_REQUEST:UnregisterEvent("CHANNEL_PASSWORD_REQUEST");
			end
		end
	end
-->

-->		Init
	local B_Initialized = false;
	local function Init()
		B_Initialized = true;
		__private:AddMessageFilter("CHAT_MSG_CHANNEL", "chattypeblocked", ChatChannelMessageBlock);
		local CHANNEL_UI_UPDATE = CreateFrame('FRAME');
		CHANNEL_UI_UPDATE:RegisterEvent("CHANNEL_UI_UPDATE");
		CHANNEL_UI_UPDATE:SetScript("OnEvent", UpdatePin);
		hooksecurefunc("ChangeChatColor", HookChangeChatColor);
		if SwapChatChannelByLocalID ~= nil then
			hooksecurefunc("SwapChatChannelByLocalID", UpdatePin);
		end
		if C_ChatInfo ~= nil and C_ChatInfo.SwapChatChannelsByChannelIndex ~= nil then
			hooksecurefunc(C_ChatInfo, "SwapChatChannelsByChannelIndex", UpdatePin);
		end
		CreateChannelBlockButtons();
		__ModifierFunc = method[_db.LeaveChannelModifier];
		hooksecurefunc("AddChatWindowChannel", function(id, channel)
			if HashBFWORLD[channel] ~= nil then
				_bfworldcf[id] = true;
			end
		end);
		hooksecurefunc("RemoveChatWindowChannel", function(id, channel)
			if HashBFWORLD[channel] ~= nil then
				_bfworldcf[id] = nil;
			end
		end);
		local CHAT_MSG_CHANNEL_NOTICE = CreateFrame('FRAME');
		CHAT_MSG_CHANNEL_NOTICE:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE");
		CHAT_MSG_CHANNEL_NOTICE:SetScript("OnEvent", function(self, event, text, _, _, _, _, _, _, index, channel)
			if text == "YOU_CHANGED" then
				local ChatFrames = __private.__chatFrames;
				if HashBFWORLD[channel] ~= nil then
					local hasOne = false;
					for id = 1, NUM_CHAT_WINDOWS do
						if id ~= 2 then
							local F = ChatFrames[id];
							if F:IsShown() or F.isDocked then
								if _bfworldcf[id] then
									ChatFrame_AddChannel(F, channel);
									hasOne = true;
								else
									local channelList = F.channelList;
									if channelList ~= nil then
										for index = 1, #channelList do
											if channelList[index] == channel then
												_bfworldcf[id] = true;
												hasOne = true;
											end
										end
									end
								end
							end
						end
					end
					if not hasOne then
						ChatFrame_AddChannel(ChatFrames[1], channel);
						-- if __private.__is_dev then
						-- 	print("|cffff0000>|r|cff00ff00AddChannel|r 1#1");
						-- end
					end
				end
				if _db.AutoAddChannelToDefaultChatFrame then
					ChatFrame_AddChannel(ChatFrames[1], channel);
					-- if __private.__is_dev then
					-- 	print("|cffff0000>|r|cff00ff00AddChannel|r 2#1");
					-- end
				end
			elseif text == "YOU_LEFT" then
			end
		end);
	end
-->

-->		Module
	local function CreateCallback()
		for index = 1, #CHATTYPE do
			local Type = CHATTYPE[index];
			local TypeEvent = CHATTYPEEVENT[Type];
			__channeltab[Type] = function(value, loading)
				if not loading and _db.toggle then
					local Pin = __pins1[Type];
					if Pin ~= nil then
						if value then
							__private.__docker:ShowPin(Pin);
							if _db._chatblocked[Type] then
								__private:AddMessageFilter(TypeEvent, "chattypeblocked", ChatMessageBlock);
								Pin.Blocked:Show();
								__channelBlocked[Type] = true;
							else
								__private:DelMessageFilter(TypeEvent, "chattypeblocked", ChatMessageBlock);
								Pin.Blocked:Hide();
								__channelBlocked[Type] = nil;
							end
						else
							__private.__docker:HidePin(Pin);
							__private:DelMessageFilter(TypeEvent, "chattypeblocked", ChatMessageBlock);
							Pin.Blocked:Hide();
							__channelBlocked[Type] = nil;
						end
					end
				end
			end
		end
		for Key, Text in next, CHANNELLIST do
			__channeltab[Key] = function(value, loading)
				if not loading and _db.toggle then
					local Pins = __KeyPins[Key];
					if Pins ~= nil then
						local Key2 = Key;
						if value then
							if _db._channelblocked[Key2] then
								__channelBlocked[Key2] = true;
								for Type, Pin in next, Pins do
									__private.__docker:ShowPin(Pin);
									Pin.Blocked:Show();
								end
							else
								__channelBlocked[Key2] = nil;
								for Type, Pin in next, Pins do
									__private.__docker:ShowPin(Pin);
									Pin.Blocked:Hide();
								end
							end
							local Pin = __pins3[Key];
							if Pin ~= nil and ChannelHasJoinButton[Key] == nil then
								__private.__docker:ShowPin(Pin);
							end
						else
							for Type, Pin in next, Pins do
								__private.__docker:HidePin(Pin);
							end
							__channelBlocked[Key2] = nil;
							local Pin = __pins3[Key];
							if Pin ~= nil then
								__private.__docker:HidePin(Pin);
							end
						end
						UpdateBlockButtonStatus();
					end
				end
			end
		end
		function __channeltab.UNMANAGEDCHANNEL(value, loading)
			if not loading and _db.toggle then
				local Pins = __KeyPins.UNMANAGEDCHANNEL;
				if Pins ~= nil then
					if value then
						for Type, Pin in next, Pins do
							__private.__docker:ShowPin(Pin);
							local Key2 = Pin.Key2;
							if _db._channelblocked[Key2] then
								__channelBlocked[Key2] = true;
								Pin.Blocked:Show();
							else
								Pin.Blocked:Hide();
							end
						end
					else
						for Type, Pin in next, Pins do
							__private.__docker:HidePin(Pin);
							-- __channelBlocked[Pin.Key2] = nil;
							Pin.Blocked:Hide();
						end
					end
					UpdateBlockButtonStatus();
				end
			end
		end
	end
	function __channeltab.LeaveChannelModifier(value, loading)
		if not loading then
			__ModifierFunc = method[value];
		end
	end
	function __channeltab.UseColor(value, loading)
		if not loading then
			for _, Pin in next, __pins1 do
				RefreshPinColor(Pin);
			end
			for _, Pin in next, __pins2 do
				RefreshPinColor(Pin);
			end
		end
	end
	function __channeltab.PinStyle(value, loading)
		if B_Initialized and not loading then
			for _, Pin in next, __pins1 do
				RefreshPinStyle(Pin);
				RefreshPinColor(Pin);
			end
			for _, Pin in next, __pins2 do
				RefreshPinStyle(Pin);
				RefreshPinColor(Pin);
			end
			for _, Pin in next, __pins3 do
				RefreshPinStyle(Pin);
				RefreshPinColor(Pin);
			end
		end
	end
	function __channeltab.ChannelBlockButton_BLZ(value, loading)
		if not loading then
			local CB = __cblocks[".Button-Channel"];
			if CB ~= nil then
				CB:SetShown(value);
			end
		end
	end
	function __channeltab.ChannelBlockButton_World(value, loading)
		if not loading then
			local WB = __cblocks[".Button-BfWorld"];
			if WB ~= nil then
				WB:SetShown(value);
			end
		end
	end
	function __channeltab.ChannelBlockButton_Size(value, loading)
		if not loading then
			local CB = __cblocks[".Button-Channel"];
			if CB ~= nil then
				CB:SetWidth(value);
				CB:SetHeight(value);
			end
			local WB = __cblocks[".Button-BfWorld"];
			if WB ~= nil then
				WB:SetWidth(value);
				WB:SetHeight(value);
			end
		end
	end
	function __channeltab.AutoJoinWorld(value, loading)
		if loading then
			C_Timer.After(4, SetAutoJoinWorld);
		else
			SetAutoJoinWorld();
		end
	end
	function __channeltab.toggle(value, loading)
		if value then
			if not B_Initialized then
				Init();
			end
			UpdatePin();
		elseif not loading then
			for Type, Pin in next, __pins1 do
				__private.__docker:HidePin(Pin);
			end
			for Type, Pin in next, __pins2 do
				__private.__docker:HidePin(Pin);
			end
			for Type, Pin in next, __pins3 do
				__private.__docker:HidePin(Pin);
			end
		end
	end
	function __channeltab.__init(db, loading)
		_db = db;
		_bfworldcf = db._bfworldcf[PLAYER_GUID];
		if _bfworldcf == nil then
			_bfworldcf = {  };
			db._bfworldcf[PLAYER_GUID] = _bfworldcf;
		end
		for Key2, value in next, _db._channelblocked do
			__channelBlocked[Key2] = value;
		end
		BuildTable();
		CreateCallback();
	end

	function __channeltab.__callback(which, value, loading)
		if __channeltab[which] ~= nil then
			return __channeltab[which](value, loading);
		end
	end
	function __channeltab.__setting()
		__private:AddSetting("CHANNELTAB", { "channeltab", "toggle", 'boolean', });
		--
		__private:AlignSetting("CHANNELTAB");
		__private:AddSetting("CHANNELTAB", { "channeltab", "SAY", 'boolean', }, 1);
		__private:AddSetting("CHANNELTAB", { "channeltab", "PARTY", 'boolean', }, 1);
		__private:AddSetting("CHANNELTAB", { "channeltab", "RAID", 'boolean', }, 1);
		__private:AddSetting("CHANNELTAB", { "channeltab", "RAID_WARNING", 'boolean', }, 1);
		__private:AddSetting("CHANNELTAB", { "channeltab", "INSTANCE_CHAT", 'boolean', }, 1);
		--
		__private:AddSetting("CHANNELTAB", { "channeltab", "GUILD", 'boolean', }, 1, 2);
		__private:AddSetting("CHANNELTAB", { "channeltab", "YELL", 'boolean', }, 1, 2);
		__private:AddSetting("CHANNELTAB", { "channeltab", "WHISPER", 'boolean', }, 1, 2);
		__private:AddSetting("CHANNELTAB", { "channeltab", "OFFICER", 'boolean', }, 1, 2);
		--
		if CHANNELLIST.GENERAL ~= nil then
			__private:AddSetting("CHANNELTAB", { "channeltab", "GENERAL", 'boolean', }, 1, 3);
		end
		if CHANNELLIST.TRADE ~= nil then
			__private:AddSetting("CHANNELTAB", { "channeltab", "TRADE", 'boolean', }, 1, 3);
		end
		if CHANNELLIST.LOCAL_DEFENSE ~= nil then
			__private:AddSetting("CHANNELTAB", { "channeltab", "LOCAL_DEFENSE", 'boolean', }, 1, 3);
		end
		if CHANNELLIST.LOOK_FOR_GROUP ~= nil then
			__private:AddSetting("CHANNELTAB", { "channeltab", "LOOK_FOR_GROUP", 'boolean', }, 1, 3);
		end
		if (L.Locale == "zhCN" or L.Locale == "zhTW") and CHANNELLIST.BF_WORLD ~= nil then
			__private:AddSetting("CHANNELTAB", { "channeltab", "BF_WORLD", 'boolean', }, 1, 3);
		end
		__private:AddSetting("CHANNELTAB", { "channeltab", "UNMANAGEDCHANNEL", 'boolean', }, 1, 3);
		--
		__private:AlignSetting("CHANNELTAB", 0.5);
		__private:AddSetting("CHANNELTAB", { "channeltab", "PinStyle", 'list', { "char", "char.blz", "circle.blur", "circle", "square.blur", "square", }, }, 1);
		__private:AddSetting("CHANNELTAB", { "channeltab", "UseColor", 'boolean', }, 1);
		__private:AddSetting("CHANNELTAB", { "channeltab", "LeaveChannelModifier", 'list', { "none", "SHIFT", "ALT", "CTRL", "SHIFT+CTRL", "SHIFT+ALT", "CTRL+ALT", }, }, 1);
		--
		__private:AlignSetting("CHANNELTAB", 0.5);
		__private:AddSetting("CHANNELTAB", { "channeltab", "AutoAddChannelToDefaultChatFrame", 'boolean', });
		__private:AddSetting("CHANNELTAB", { "channeltab", "ChannelBlockButton_BLZ", 'boolean', });
		if L.Locale == "zhCN" or L.Locale == "zhTW" then
			__private:AddSetting("CHANNELTAB", { "channeltab", "ChannelBlockButton_World", 'boolean', });
		end
		__private:AddSetting("CHANNELTAB", { "channeltab", "ChannelBlockButton_Size", 'number', { 8, 64, 1, }, nil, 0, }, 1);
		--
		if L.Locale == "zhCN" or L.Locale == "zhTW" then
			__private:AddSetting("CHANNELTAB", { "channeltab", "AutoJoinWorld", 'boolean', });
		end
	end

	__channeltab.__initat = "LOADING_SCREEN_DISABLED";
	__channeltab.__initafter = function() return EnumerateServerChannels() ~= nil end;
	--	"LOADING_SCREEN_DISABLED";
	--	"ZONE_CHANGED_NEW_AREA", "AREA_POIS_UPDATED", "CHANNEL_UI_UPDATE"
	__private.__module["channeltab"] = __channeltab;
-->
