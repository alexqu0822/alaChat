--[[--
	alex/ALA	Please Keep WOW Addon open-source & Reduce barriers for others.
--]]--
----------------------------------------------------------------------------------------------------
local ADDON, NS = ...;
_G.__ala_meta__ = _G.__ala_meta__ or {  };
__ala_meta__.chat = NS;
local _G = _G;

do
	local _G = _G;
	if NS.__fenv == nil then
		NS.__fenv = setmetatable({  },
				{
					__index = _G,
					__newindex = function(t, key, value)
						rawset(t, key, value);
						print("acc assign global", key, value);
						return value;
					end,
				}
			);
	end
	setfenv(1, NS.__fenv);
end

NS.FUNC = NS.FUNC or { ON = { }, OFF = { }, INIT = { }, TOOLTIPS = { }, SETVALUE = { }, SETSTYLE = {  }, };
local FUNC = NS.FUNC;
local L = NS.L;
if not L then return;end
----------------------------------------------------------------------------------------------------upvalue LUA
local math, table, string, bit = math, table, string, bit;
local type = type;
local assert, collectgarbage, date, difftime, error, getfenv, getmetatable, loadstring, next, newproxy, pcall, select, setfenv, setmetatable, time, type, unpack, xpcall, rawequal, rawget, rawset =
		assert, collectgarbage, date, difftime, error, getfenv, getmetatable, loadstring, next, newproxy, pcall, select, setfenv, setmetatable, time, type, unpack, xpcall, rawequal, rawget, rawset;
local abs, acos, asin, atan, atan2, ceil, cos, deg, exp, floor, fmod, frexp,ldexp, log, log10, max, min, mod, rad, random, sin, sqrt, tan, fastrandom =
		abs, acos, asin, atan, atan2, ceil, cos, deg, exp, floor, fmod or math.fmod, frexp,ldexp, log, log10, max, min, mod, rad, random, sin, sqrt, tan, fastrandom;
local format, gmatch, gsub, strbyte, strchar, strfind, strlen, strlower, strmatch, strrep, strrev, strsub, strupper, tonumber, tostring =
		format, gmatch, gsub, strbyte, strchar, strfind, strlen, strlower, strmatch, strrep, strrev, strsub, strupper, tonumber, tostring;
local strcmputf8i, strlenutf8, strtrim, strsplit, strjoin, strconcat, tostringall = strcmputf8i, strlenutf8, strtrim, strsplit, strjoin, strconcat, tostringall;
local ipairs, pairs, sort, tContains, tinsert, tremove, wipe = ipairs, pairs, sort, tContains, tinsert, tremove, wipe;
local gcinfo, foreach, foreachi, getn = gcinfo, foreach, foreachi, getn;	-- Deprecated
----------------------------------------------------------------------------------------------------
local _ = nil;
----------------------------------------------------------------------------------------------------
local GameTooltip = GameTooltip;
----------------------------------------------------------------------------------------------------
local LCONFIG = L.CONFIG;
if not LCONFIG then
	return;
end
----------------------------------------------------------------------------------------------------main
local alaBaseBtn = __alaBaseBtn;
if not alaBaseBtn then
	return;
end

local NAME = "alaChat_Classic";
local btnPackIndex = 16;

local function debug(...)
	print("\124cffff0000alaChat addon:\124r",...);
end
local function FUNC_CALL(t,k,...)
	if FUNC[t] then
		if FUNC[t][k] then
			return FUNC[t][k](...);
		elseif t ~= "INIT" and k ~= "_version" then
			debug("Missing FUNC handler",t,k);
		end
	elseif t ~= "_version" then
		debug("Missing FUNC table",t);
	end
	return nil;
end
--------------------------------------------------
local configFrame = CreateFrame("Frame",nil,UIParent);
configFrame:Hide();
NS.configFrame = configFrame;

local titleHeight = 30;

local CBLineHeight = 28;

local MCLineHeight0 = 24;
local MCLineHeight1 = 20;
local MCLineHeight2 = 20;
local MCLineHeight3 = 24;
local MCWidth = 24;
local MCInter = 16;

local SLLineHeight = 36;
local SLWidth = 120;

local DDLineHeight = 24;

local INLineHeight = 24;

local OptionsCheckButtonSize = 26;
local OptionsSetButtonWidth = 45;
local space_Header_Label = 4;
local space_Label_Obejct = 8;
local space_SubConfig = 12;
local borderWidth = 6;
local borderHeight = 4;
--local labelTexture = "interface\\minimap\\templeofkotmogu_ball_orange";
local labelTexture = "interface\\minimap\\raid";

local config = nil;

local key = {
	"printWel",
	"position",
	"direction",
	"scale",
	"alpha",
	"barStyle",
	
	"shortChannelName",
	"shortChannelNameFormat",
	"hyperLinkEnhanced",
	"chatEmote",
	"chatEmote_channel",
	"ColorNameByClass",
	"shamanColor",
	"channelBarChannel",
	"channelBarStyle",
	
	"channel_Ignore_Switch",
	"channel_Ignore",
	"bfWorld_Ignore_Switch",
	"bfWorld_Ignore",
	"channel_Ignore_BtnSize",
	
	"welcomeToGuild",
	"welcometoGuildMsg",
	"broadCastNewMember",
	"statReport",
	"roll",
	"DBMCountDown",
	"ReadyCheck",
	"level",
	"copy",
	"copyTagColor",
	"copyTagFormat",
	
	"editBoxTab",
	"restoreAfterWhisper",
	"restoreAfterChannel",
	"hyperLinkHoverShow",

	"keyWordHighlight",
	"keyWordColor",
	"keyWord",
	"keyWordHighlight_Exc",
	"chat_filter",
	"chat_filter_word",
	"chat_filter_rep_interval",
	"chat_filter_repeated_words",
	"chat_filter_repeated_words_deep",
	"chat_filter_repeated_words_info",
};
local default = {
	_version				 = 200226.0,
	_overrideVersion		 = 200226.0,

	printWel				 = true,
	position				 = "BELOW_EDITBOX",
	direction				 = "HORIZONTAL",
	scale					 = 0.9,
	alpha					 = 1.0,
	barStyle				 = "blz",

	shortChannelName		 = true,
	shortChannelNameFormat	 = "NW",
	hyperLinkEnhanced		 = true,
	chatEmote				 = true,
	chatEmote_channel		 = true,
	ColorNameByClass		 = true,
	shamanColor				 = false,
	-- SAY, PARTY, RAID, RAID_WARNING, INSTANCE_CHAT, GUILD, YELL, WHISPER, OFFICER, GENERAL, TRADE, LOCAL_DEFENSE, LOOK_FOR_GROUP, "WORLD"
	channelBarChannel		 = { true,true,true,true,true,true,true,false,false,true,true,false,true,true },
	channelBarStyle			 = "CHAR",

	channel_Ignore_Switch 	 = true,
	channel_Ignore			 = false,
	bfWorld_Ignore_Switch	 = true,
	bfWorld_Ignore			 = false,
	channel_Ignore_BtnSize	 = 28,

	--chatFrameScroll			 = false,
	welcomeToGuild			 = false,
	welcometoGuildMsg		 = L.WTG_STRING and L.WTG_STRING.FORMAT_WELCOME or "Welcome!",
	broadCastNewMember		 = false,
	roll 					 = true,
	DBMCountDown			 = true,
	ReadyCheck				 = true,
	statReport				 = true,
	level					 = false,
	copy					 = true,
	copyTagColor			 = { 0.25, 0.25, 1.00 },
	copyTagFormat			 = "[%H:%M:%S]";

	--hideConfBtn				 = true,
	editBoxTab				 = true,
	restoreAfterWhisper		 = false,
	restoreAfterChannel		 = false,
	hyperLinkHoverShow		 = true,

	keyWordHighlight		 = true,
	keyWordColor			 = { 0.00, 1.00, 0.00 },
	keyWord					 = "",
	keyWordHighlight_Exc	 = false,
	chat_filter				 = true,
	chat_filter_word		 = "",
	chat_filter_repeated_words = true,
	chat_filter_repeated_words_deep = true;
	chat_filter_repeated_words_info = false,
	chat_filter_rep_interval = 30,
};
if GetAddOnInfo('!!!163UI!!!') then
	default.printWel = false;
	default.chatEmote = false;
	default.chatEmote_channel = false;
	default.chat_filter_repeated_words = false;
end
local override = {
	_version				 = 200212.0,
};
local buttons = {
	--[[1]]	{ 				type = "CheckButton"	,label = LCONFIG.printWel				,key = "printWel"				, },
	--[[1]]	{ 				type = "DropDownMenu"	,label = LCONFIG.position				,key = "position"				,value = { "BELOW_EDITBOX", "ABOVE_EDITOBX", "ABOVE_CHATFRAME" }, },
	--[[1]]	{ sub = true,	type = "DropDownMenu"	,label = LCONFIG.direction				,key = "direction"				,value = { "HORIZONTAL", "VERTICAL" }, },
	--[[2]]	{ 				type = "Slider"			,label = LCONFIG.scale					,key = "scale"					,minRange = 0.1	,maxRange = 2.0	,stepSize = 0.1	, },
	--[[3]]	{ sub = true,	type = "Slider"			,label = LCONFIG.alpha					,key = "alpha"					,minRange = 0.0	,maxRange = 1.0	,stepSize = 0.05	, },
	--[[4]] { sub = true,	type = "DropDownMenu"	,label = LCONFIG.barStyle				,key = "barStyle"				,value = { "ala", "blz" }, },

	--[[5]]	{ 				type = "CheckButton"	,label = LCONFIG.shortChannelName		,key = "shortChannelName"		, },
	--[[5]]	{ sub = true,	type = "DropDownMenu"	,label = LCONFIG.shortChannelNameFormat	,key = "shortChannelNameFormat"	,value = { "NW", "N", "W", }, },
	--[[7]]	{ sub = true,	type = "CheckButton"	,label = LCONFIG.chatEmote				,key = "chatEmote"				, },
	--[[7]]	{ sub = true,	type = "CheckButton"	,label = LCONFIG.chatEmote_channel		,key = "chatEmote_channel"				, },
	--[[17]]{				type = "CheckButton"	,label = LCONFIG.statReport				,key = "statReport"				, },
	--[[6]]	{ sub = true,	type = "CheckButton"	,label = LCONFIG.hyperLinkEnhanced		,key = "hyperLinkEnhanced"		, },
	--[[8]]	{ 				type = "CheckButton"	,label = LCONFIG.ColorNameByClass		,key = "ColorNameByClass"		, },
	--[[9]]	{ sub = true,	type = "CheckButton"	,label = LCONFIG.shamanColor			,key = "shamanColor"			, },
	--[[10]]{ 				type = "DropDownMenu"	,label = LCONFIG.channelBarStyle		,key = "channelBarStyle"			,value = { "CHAR", "CIRCLE", "SQUARE" }, },
	--[[11]]{ 				type = "MultiCB"		,label = LCONFIG.channelBarChannel		,key = "channelBarChannel"		, },
	--[[12]]{ 				type = "CheckButton"	,label = LCONFIG.channel_Ignore_Switch	,key = "channel_Ignore_Switch"	, },
	--[[12]]{ sub = true,	type = "CheckButton"	,label = LCONFIG.bfWorld_Ignore_Switch	,key = "bfWorld_Ignore_Switch"	, },
	--[[13]]{ sub = true,	type = "Slider"			,label = LCONFIG.channel_Ignore_BtnSize	,key = "channel_Ignore_BtnSize"	,minRange = 12	,maxRange = 96	,stepSize = 4		, },

	--[[21]]{ 				type = "CheckButton"	,label = LCONFIG.copy					,key = "copy"					, },
	--[[22]]{ sub = true,	type = "ColorSelect"	,label = LCONFIG.copyTagColor			,key = "copyTagColor"			, },
	--[[23]]{ sub = true,	type = "Input"			,label = LCONFIG.copyTagFormat			,key = "copyTagFormat"			,note = LCONFIG.copyTagFormatNotes		,multiLine = false	,width = 240,  },
			{ sub = true,	type = "DropDownMenu"	,label = LCONFIG.copyTagFormat			,key = "copyTagFormat", value = { "", "%I:%M", "%I:%M:%S", "%I:%M %p", "%I:%M:%S %p", "%H:%M", "%H:%M:%S", }, text = { "NONE", "03:27", "03:27:32", "03:27 PM", "03:27:32 PM", "15:27", "15:27:32", }, list = true, },
	--[[14]]{ 				type = "CheckButton"	,label = LCONFIG.broadCastNewMember		,key = "broadCastNewMember"		, },
	--[[15]]{ sub = true,	type = "CheckButton"	,label = LCONFIG.welcomeToGuild			,key = "welcomeToGuild"			, },
	--[[16]]{ sub = true,	type = "Input"			,label = LCONFIG.welcometoGuildMsg		,key = "welcometoGuildMsg"		,note = L.WTG_STRING.WELCOME_NOTES	,multiLine = true	,width = 640,  },
	--[[18]]{ 				type = "CheckButton"	,label = LCONFIG.roll					,key = "roll"					, },
	--[[19]]{ sub = true,	type = "CheckButton"	,label = LCONFIG.DBMCountDown			,key = "DBMCountDown"			, },
	--[[20]]{ sub = true,	type = "CheckButton"	,label = LCONFIG.ReadyCheck				,key = "ReadyCheck"				, },
	--[[24]]{ sub = true,	type = "CheckButton"	,label = LCONFIG.level					,key = "level"					, },
	--[[25]]{ 				type = "CheckButton"	,label = LCONFIG.editBoxTab				,key = "editBoxTab"				, },
	--[[26]]{ sub = true,	type = "CheckButton"	,label = LCONFIG.restoreAfterWhisper	,key = "restoreAfterWhisper"	, },
	--[[26]]{ sub = true,	type = "CheckButton"	,label = LCONFIG.restoreAfterChannel	,key = "restoreAfterChannel"	, },
	--[[27]]{ 				type = "CheckButton"	,label = LCONFIG.hyperLinkHoverShow		,key = "hyperLinkHoverShow"		, },

	--[[28]]{ 				type = "CheckButton"	,label = LCONFIG.keyWordHighlight		,key = "keyWordHighlight"		, },
	--[[28]]{ sub = true,	type = "Input"			,label = LCONFIG.keyWord				,key = "keyWord"				, multiLine = true	,},
	--[[29]]{ sub = true,	type = "ColorSelect"	,label = LCONFIG.keyWordColor			,key = "keyWordColor"			, },
	--[[28]]{ sub = true,	type = "CheckButton"	,label = LCONFIG.keyWordHighlight_Exc	,key = "keyWordHighlight_Exc"	, },

	--[[28]]{ 				type = "CheckButton"	,label = LCONFIG.chat_filter			,key = "chat_filter"			, },
	--[[29]]{ sub = true,	type = "Input"			,label = LCONFIG.chat_filter_word		,key = "chat_filter_word"		,note = LCONFIG.chat_filter_word_NOTES, multiLine = true	,width = 320,  },
	--[[13]]{ 				type = "Slider"			,label = LCONFIG.chat_filter_rep_interval	,key = "chat_filter_rep_interval"	,minRange = 0	,maxRange = 3600	,stepSize = 5		, },
	--[[28]]{ 				type = "CheckButton"	,label = LCONFIG.chat_filter_repeated_words	,key = "chat_filter_repeated_words"	, },
	--[[28]]{ sub = true,	type = "CheckButton"	,label = LCONFIG.chat_filter_repeated_words_deep	,key = "chat_filter_repeated_words_deep"	, },
	--[[28]]{ sub = true,	type = "CheckButton"	,label = LCONFIG.chat_filter_repeated_words_info	,key = "chat_filter_repeated_words_info"	, },
	--{ type = "CheckButton"	,label = LCONFIG.hideConfBtn				,key = "hideConfBtn"				, },
};
local config_zh = {
	channel_Ignore_BtnSize = 1,
	bfWorld_Ignore_Switch = 1,
	bfWorld_Ignore = 1,
};
if GetLocale() ~= "zhCN" and GetLocale() ~= "zhTW" then
	for i = #key, 1, -1 do
		if config_zh[key[i]] then
			tremove(key, i);
		end
	end
	for key, _ in pairs(config_zh) do
		default[key] = nil;
		override[key] = nil;
	end
	for i = #buttons, 1, -1 do
		if config_zh[buttons[i].key] then
			tremove(buttons, i);
		end
	end
end
if GetLocale() == "zhCN" then
	default.chat_filter_word = "HclubTicket:\n航空\n航班\n飞机\n专机\n直达\n直飞\n3G\n安全便捷\n拉人\n收米\n出米\n托管\n包团\n实惠\n公众号\nG团\n老板\n大米\nRO点\nMMMMMM\n"
							.. "++++++\n————\n一一一一\n~~~~~~\n------\n======\n``````\n"
							.. "!!!!!!!!!!\n??????????\n！！！！！！！！！！\n？？？？？？？？？？\n。。。。。。。。。。\n，，，，，，，，，，\n··········\n；；；；；；；；；；\n、、、、、、、、、、\n"
							.. "#加基森\n#冬泉谷\n#玛拉顿\n#斯坦索姆\n#航空\n#直飞\n#直达\n";
else
	default.chat_filter_word = "HclubTicket:\n\n++++++\n——————\n~~~~~~\n------\n======\n``````\nMMMMMM\n"
end

do
	local function resetButtonOnClick()
		for k, v in pairs(default) do
			if config[k] ~= v then
				if type(v) == "boolean" then
					config[k] = v;
					if v then
						FUNC_CALL("ON", k);
					else
						FUNC_CALL("OFF", k);
					end
				elseif type(v) == "table" then
					config[k] = { };
					for k1, v1 in pairs(v) do
						config[k][k1] = v1;
						if type(v1) == "boolean" then
							if v1 then
								FUNC_CALL("ON", k, k1);
							else
								FUNC_CALL("OFF", k, k1);
							end
						else
							FUNC_CALL("SETVALUE", k, k1, v1);
						end
					end
				else
					config[k] = v;
					FUNC_CALL("SETVALUE", k, v);
				end
				local object = configFrame.objects[k];
				if object then
					if object.type == "CheckButton" then
						object.object:SetChecked(config[k]);
					elseif object.type == "MultiCB" then
						for i = 1, #v.object do
							object.object[i]:SetChecked(config[k][i]);
						end
					elseif object.type == "Slider" or object.type == "DropDownMenu" then
						object.object:SetValue(config[k]);
					end
				end
			end
		end
	end
	local function closeButtonOnClick()
		configFrame:Hide();
	end

	local function MultiCheckButtonOnClick(self)
		if config[self.key][self.idx] then
			config[self.key][self.idx] = false;
			FUNC_CALL("OFF", self.key, self.idx);
		else
			config[self.key][self.idx] = true;
			FUNC_CALL("ON", self.key, self.idx);
		end
	end
	local function CheckButtonOnClick(self)
		if self:GetChecked() then
			config[self.key] = true;
			FUNC_CALL("ON", self.key);
		else
			config[self.key] = false;
			FUNC_CALL("OFF", self.key);
		end
	end
	local function CheckButtonOnEnter(self)
		if self.tooltipText then
			GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_RIGHT");
			if type(self.tooltipText) == "string" then
				GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true);
			elseif type(self.tooltipText) == "function" then
				GameTooltip:SetText(self.tooltipText(), nil, nil, nil, nil, true);
			end
		end
	end
	local function sliderDisable(self)
		self.text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
		self.Low:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
		self.High:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
		self.valueBox:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
		self.valueBox:SetEnabled(false)
	end
	local function sliderEnable(self)
		self.Text:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		self.Low:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		self.High:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		self.valueBox:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		self.valueBox:SetEnabled(true)
	end
	local function sliderRefresh(self)
		self:SetValue(config[self.key]);
		self.valueBox:SetText(config[self.key]);
	end
	local function sliderOnValueChanged(self, value, userInput)
		local value = floor(value / self.stepSize + 0.5) * self.stepSize;
		if userInput then
			config[self.key] = value;
			FUNC_CALL("SETVALUE", self.key, value);
		end
		self.valueBox:SetText(value);
	end
	local function sliderValueBoxOnEscapePressed(self)
		self:SetText(config[self.parent.key]);
		self:ClearFocus();
	end
	local function sliderValueBoxOnEnterPressed(self)
		local value = tonumber(self:GetText()) or 0.0
		value = floor(value / self.parent.stepSize + 0.5) * self.parent.stepSize
		value = max(self.parent.minRange, min(self.parent.maxRange, value))
		self.parent:SetValue(value)
		config[self.parent.key] = value;
		self:SetText(value);
		FUNC_CALL("SETVALUE", self.parent.key, value);
		self:ClearFocus();
	end
	local function sliderValueBoxOnOnChar(self)
		self:SetText(self:GetText():gsub("[^%.0-9]+", ""):gsub("(%..*)%.", "%1"))
	end
	local function dropOnClick(button, drop, funcIndex, key, val, ...)
		if drop.label then
			drop.label:SetText(val);
		end
		config[key] = val;
		FUNC_CALL(funcIndex, key, val, ...);
	end

	local function configFrame_Init(configFrame)

		local objects = { };
		configFrame.objects = objects;

		local maxWidth = - 1;

		local yOfs = 10;

		local prevAnchorObj = nil;
		local prevWidth = 0;

		for _, t in pairs(buttons) do
			if t.type == "CheckButton" then
				local cb = CreateFrame("CheckButton", nil, configFrame, "OptionsBaseCheckButtonTemplate");
				cb:SetHitRectInsets(0, 0, 0, 0);
				cb:GetNormalTexture():SetVertexColor(0.0, 1.0, 0.0, 1.0);
				cb:GetPushedTexture():SetVertexColor(0.0, 1.0, 0.0, 1.0);
				cb:GetCheckedTexture():SetVertexColor(0.0, 1.0, 0.0, 1.0);
				cb.key = t.key;
				cb.tooltipText = t.text;

				cb:ClearAllPoints();

				cb:SetScript("OnClick", CheckButtonOnClick);

				local label = configFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
				label:SetText(t.label);
				cb.label = label;

				label:SetPoint("LEFT", cb, "RIGHT", space_Header_Label, 0);

				objects[t.key] = { type = t.type, head = cb, object = cb, label = label, };
				if t.sub and prevAnchorObj then
					cb:SetPoint("LEFT", prevAnchorObj, "RIGHT", space_SubConfig, 0);
					prevWidth = prevWidth + space_SubConfig + OptionsCheckButtonSize + space_Header_Label + label:GetWidth();
					maxWidth = max(maxWidth, prevWidth);
				else
					cb:SetPoint("TOPLEFT", configFrame, "TOPLEFT", borderWidth, - yOfs);
					yOfs = yOfs + CBLineHeight;
					prevWidth = OptionsCheckButtonSize + space_Header_Label + label:GetWidth();
					maxWidth = max(maxWidth, prevWidth);
				end
				prevAnchorObj = label;
			elseif t.type == "MultiCB" then
				local cfg = config[t.key];
				local num = #cfg;

				local texture = configFrame:CreateTexture(nil, "ARTWORK");
				texture:SetSize(OptionsCheckButtonSize, OptionsCheckButtonSize);
				texture:SetTexture(labelTexture);
				texture:SetPoint("TOPLEFT", configFrame, "TOPLEFT", borderWidth, - yOfs);

				local label = configFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
				label:SetText(t.label.label);
				label:SetPoint("LEFT", texture, "RIGHT", space_Header_Label, 0);

				objects[t.key] = { type = t.type, object = { }, label = label, }

				local xOfs = 0;
				local anchor = nil;
				if t.sub and prevAnchorObj then
					anchor = { "LEFT", prevAnchorObj, "RIGHT", space_SubConfig, 0 };
					xOfs = space_SubConfig;
					prevWidth = prevWidth + space_SubConfig + MCWidth * num + MCInter * (num - 1) + 30;
					maxWidth = max(maxWidth, prevWidth);
				else
					anchor = { "TOPLEFT", configFrame, "TOPLEFT", 30 + borderWidth, - yOfs - MCLineHeight0 - MCLineHeight1 };
					xOfs = 0;
					yOfs = yOfs + (MCLineHeight0 + MCLineHeight1 + MCLineHeight2 + MCLineHeight3);
					prevWidth = MCWidth * num + MCInter * (num - 1) + 30;
					maxWidth = max(maxWidth, prevWidth);
				end

				for i = 1, num do

					local cb = CreateFrame("CheckButton", nil, configFrame, "OptionsBaseCheckButtonTemplate");
					cb:GetNormalTexture():SetVertexColor(0.0, 1.0, 0.0, 1.0);
					cb:GetPushedTexture():SetVertexColor(0.0, 1.0, 0.0, 1.0);
					cb:GetCheckedTexture():SetVertexColor(0.0, 1.0, 0.0, 1.0);
					cb:SetHitRectInsets(0, 0, 0, 0);
					cb.key = t.key;
					cb.idx = i;
					cb.tooltipText = t.text;

					cb:ClearAllPoints();
					if i == 1 then
						cb:SetPoint(unpack(anchor));
					else
						cb:SetPoint("LEFT", objects[t.key].object[i - 1], "RIGHT", MCInter, 0);
					end

					cb:SetScript("OnClick", MultiCheckButtonOnClick);

					local subLabel = configFrame:CreateFontString(nil, "ARTWORK");
					local font, size = GameFontHighlight:GetFont();
					subLabel:SetFont(font, size - 2, "OUTLINE");
					subLabel:SetText(t.label[i]);
					cb.label = subLabel;

					if i%2 == 0 then
						subLabel:SetPoint("TOP", cb, "BOTTOM", 0, space_Header_Label);
					else
						subLabel:SetPoint("BOTTOM", cb, "TOP", 0, space_Header_Label);
					end

					objects[t.key].object[i] = cb;
				end

				prevAnchorObj = objects[t.key].object[num];
				objects[t.key].head = objects[t.key].object[1];
			elseif t.type == "Slider" then
				local texture = configFrame:CreateTexture(nil, "ARTWORK");
				texture:SetSize(OptionsCheckButtonSize, OptionsCheckButtonSize);
				texture:SetTexture(labelTexture);

				local label = configFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
				label:SetText(t.label);

				label:SetPoint("LEFT", texture, "RIGHT", space_Header_Label, 0);

				local slider = CreateFrame("Slider", nil, configFrame, "OptionsSliderTemplate");
				slider.key = t.key;

				slider:ClearAllPoints();
				slider:SetPoint("LEFT", label, "RIGHT", space_Label_Obejct, 0);
				slider:SetWidth(SLWidth);
				slider:SetHeight(20);

				slider:SetScript("OnShow", sliderRefresh);
				slider:HookScript("OnValueChanged", sliderOnValueChanged)
				slider:HookScript("OnDisable", sliderDisable)
				slider:HookScript("OnEnable", sliderEnable)
				slider.stepSize = t.stepSize;
				slider:SetValueStep(t.stepSize);
				slider:SetObeyStepOnDrag(true);

				slider:SetMinMaxValues(t.minRange, t.maxRange)
				slider.minRange = t.minRange;
				slider.maxRange = t.maxRange;
				slider.Low:SetText(t.minRange)
				slider.High:SetText(t.maxRange)
				--slider.text:SetText(t.label);

				local valueBox = CreateFrame("EditBox", nil, slider);
				valueBox:SetPoint("TOP", slider, "BOTTOM", 0, 0);
				valueBox:SetSize(60, 14);
				valueBox:SetFontObject(GameFontHighlightSmall);
				valueBox:SetAutoFocus(false);
				valueBox:SetJustifyH("CENTER");
				valueBox:SetScript("OnEscapePressed", sliderValueBoxOnEscapePressed);
				valueBox:SetScript("OnEnterPressed", sliderValueBoxOnEnterPressed);
				valueBox:SetScript("OnChar", sliderValueBoxOnOnChar);
				valueBox:SetMaxLetters(5)

				valueBox:SetBackdrop({
					bgFile = "Interface/ChatFrame/ChatFrameBackground", 
					edgeFile = "Interface/ChatFrame/ChatFrameBackground", 
					tile = true, edgeSize = 1, tileSize = 5, 
				})
				valueBox:SetBackdropColor(0, 0, 0, 0.5)
				valueBox:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
				valueBox.parent = slider;

				slider.valueBox = valueBox

				objects[t.key] = { type = t.type, head = texture, object = slider, label = label, object2 = valueBox, };
				if t.sub and prevAnchorObj then
					texture:SetPoint("LEFT", prevAnchorObj, "RIGHT", space_SubConfig, 0);
					prevWidth = prevWidth + space_Header_Label + OptionsCheckButtonSize + space_Header_Label + label:GetWidth() + space_Label_Obejct + slider:GetWidth();
					maxWidth = max(maxWidth, prevWidth);
				else
					texture:SetPoint("TOPLEFT", configFrame, "TOPLEFT", borderWidth, - yOfs);
					yOfs = yOfs + SLLineHeight;
					prevWidth = OptionsCheckButtonSize + space_Header_Label + label:GetWidth() + space_Label_Obejct + slider:GetWidth();
					maxWidth = max(maxWidth, prevWidth);
				end
				prevAnchorObj = slider;
			elseif t.type == "DropDownMenu" then
				if t.list then
					local drop = CreateFrame("Button", nil, configFrame);
					drop:SetSize(28, 28)
					drop:EnableMouse(true);
					drop:SetNormalTexture("interface\\mainmenubar\\ui-mainmenu-scrolldownbutton-up")
					--drop:GetNormalTexture():SetTexCoord(0.0, 1.0, 0.0, 0.5);
					drop:SetPushedTexture("interface\\mainmenubar\\ui-mainmenu-scrolldownbutton-down")
					--drop:GetPushedTexture():SetTexCoord(0.0, 1.0, 0.0, 0.5);
					drop:SetHighlightTexture("Interface\\mainmenubar\\ui-mainmenu-scrolldownbutton-highlight");
					drop:SetPoint("LEFT", label, "RIGHT", space_Label_Obejct, 0);

					drop.key = t.key;
					local db = {
						handler = dropOnClick, 
						elements = { }, 
					};
					for i = 1, #t.value do
						db.elements[i] = {
							para = { drop, "SETVALUE", t.key, t.value[i], };
							text = t.text and t.text[i] or t.value[i];
						};
					end
					drop:SetScript("OnClick", function(self) ALADROP(self, "BOTTOMRIGHT", db); end);
					function drop:SetValue(val)
					end

					objects[t.key] = objects[t.key] or {  };
					objects[t.key].list = drop;

					drop:SetPoint("LEFT", prevAnchorObj, "RIGHT", space_SubConfig, 0);
					prevWidth = prevWidth + space_SubConfig + 28;
					maxWidth = max(maxWidth, prevWidth);
					prevAnchorObj = drop;
				else
					local texture = configFrame:CreateTexture(nil, "ARTWORK");
					texture:SetSize(OptionsCheckButtonSize, OptionsCheckButtonSize);
					texture:SetTexture(labelTexture);
					--texture:SetPoint("TOPLEFT", configFrame, "TOPLEFT", borderWidth, - yOfs);

					local label = configFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
					label:SetText(t.label);

					label:SetPoint("LEFT", texture, "RIGHT", space_Header_Label, 0);

					local drop = CreateFrame("Button", nil, configFrame);
					drop:SetSize(28, 28)
					drop:EnableMouse(true);
					drop:SetNormalTexture("interface\\mainmenubar\\ui-mainmenu-scrolldownbutton-up")
					--drop:GetNormalTexture():SetTexCoord(0.0, 1.0, 0.0, 0.5);
					drop:SetPushedTexture("interface\\mainmenubar\\ui-mainmenu-scrolldownbutton-down")
					--drop:GetPushedTexture():SetTexCoord(0.0, 1.0, 0.0, 0.5);
					drop:SetHighlightTexture("Interface\\mainmenubar\\ui-mainmenu-scrolldownbutton-highlight");
					drop:SetPoint("LEFT", label, "RIGHT", space_Label_Obejct, 0);

					local dropfs = configFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
					dropfs:SetPoint("LEFT", drop, "RIGHT", 0, 0);
					drop.label = dropfs;

					drop.key = t.key;
					local db = {
						handler = dropOnClick, 
						elements = { }, 
					};
					local dropfsWidth = 0;
					for i = 1, #t.value do
						db.elements[i] = {
							para = { drop, "SETVALUE", t.key, t.value[i], };
							text = t.text and t.text[i] or t.value[i];
						};
						dropfs:SetText(t.value[i]);
						dropfsWidth = max(dropfsWidth, dropfs:GetWidth());
					end
					dropfs:SetText(config and config[t.key] or "");
					drop:SetScript("OnClick", function(self) ALADROP(self, "BOTTOMRIGHT", db); end);
					function drop:SetValue(val)
						self.label:SetText(val);
					end

					objects[t.key] = { type = t.type, head = texture, object = drop, label = label, object2 = dropfs, };

					if t.sub and prevAnchorObj then
						texture:SetPoint("LEFT", prevAnchorObj, "RIGHT", space_SubConfig, 0);
						prevWidth = prevWidth + space_SubConfig + OptionsCheckButtonSize + space_Header_Label + label:GetWidth() + space_Label_Obejct + 28 + dropfsWidth;
						maxWidth = max(maxWidth, prevWidth);
					else
						texture:SetPoint("TOPLEFT", configFrame, "TOPLEFT", borderWidth, - yOfs);
						yOfs = yOfs + DDLineHeight;
						prevWidth = OptionsCheckButtonSize + space_Header_Label + label:GetWidth() + space_Label_Obejct + 28 + dropfsWidth;
						maxWidth = max(maxWidth, prevWidth);
					end
					prevAnchorObj = dropfs;
				end
			elseif t.type == "Input" then
				local texture = configFrame:CreateTexture(nil, "ARTWORK");
				texture:SetSize(OptionsCheckButtonSize, OptionsCheckButtonSize);
				texture:SetTexture(labelTexture);

				local label = configFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
				label:SetText(t.label);
				label:SetPoint("LEFT", texture, "RIGHT", space_Header_Label, 0);

				local button = CreateFrame("Button", nil, configFrame);
				button:SetSize(OptionsSetButtonWidth, 20);
				button:SetPoint("LEFT", label, "RIGHT", space_Label_Obejct, 0);

				button:SetNormalTexture("Interface\\Buttons\\ui-panel-button-up");
				button:SetPushedTexture("Interface\\Buttons\\ui-panel-button-up");
				button:GetNormalTexture():SetTexCoord(1 / 128, 79 / 128, 1 / 32, 22 / 32);
				button:GetPushedTexture():SetTexCoord(1 / 128, 79 / 128, 1 / 32, 22 / 32);
				button:SetHighlightTexture("Interface\\Buttons\\ui-panel-minimizebutton-highlight");
				button:SetScript("OnEnter", function(self)
					if self.note then
						GameTooltip:ClearAllPoints();
						GameTooltip:SetOwner(self, "ANCHOR_LEFT");
						GameTooltip:SetText(self.note, 1.0, 1.0, 1.0);
					end
				end);
				button:SetScript("OnLeave", function(self)	if GameTooltip:IsOwned(self) then GameTooltip:Hide();end end);
				button.note = t.note;
				local fontString = button:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
				fontString:SetText("\124cff00ff00SET\124r");
				fontString:SetPoint("CENTER");
				button.fontString = fontString;

				-- local f = CreateFrame("Frame", nil, configFrame);
				-- f:EnableMouse(true);
				-- f:SetBackdrop({
				-- 	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
				-- 	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", 
				-- 	tile = true, 
				-- 	tileSize = 2, 
				-- 	edgeSize = 2, 
				-- 	insets = { left = 2, right = 2, top = 2, bottom = 2 }
				-- });
				-- f:SetBackdropColor(1, 1, 1, 1)

				local editBox = CreateFrame("EditBox", nil, configFrame);
				editBox:SetWidth(min(t.width or 320, GetScreenWidth()));
				editBox:SetFontObject(GameFontHighlightSmall);
				editBox:SetAutoFocus(false);
				editBox:SetJustifyH("LEFT");
				editBox:Hide();
				editBox:SetMultiLine(true);
				editBox:EnableMouse(true);
				editBox:SetBackdrop({
					bgFile = "Interface\\Buttons\\WHITE8X8";	-- "Interface\\Tooltips\\UI-Tooltip-Background", 
					edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", 
					tile = true, 
					tileSize = 2, 
					edgeSize = 2, 
					insets = { left = 2, right = 2, top = 2, bottom = 2 }
				});
				editBox:SetBackdropColor(0.05, 0.05, 0.05, 1.0);
				--editBox:SetScript("OnEnterPressed", function(self)
					--self:SetText(self:GetText().."\n");
				--end);
				if not t.multiLine then
					editBox:SetScript("OnEnterPressed", function(self)
						self:SetText(gsub(self:GetText(), "\n", ""));
					end);
				end
				editBox:SetScript("OnEscapePressed", function(self)
					self:ClearFocus();
					self:SetText(config[t.key] or "");
					self:Hide();
				end);
				-- editBox:SetScript("OnChar", function()
				-- 	editBox:SetText(gsub(editBox:GetText(), "%%", ""));
				-- end);
				editBox:SetPoint("LEFT", button, "RIGHT", 4, 0);
				editBox:SetFrameStrata("FULLSCREEN_DIALOG");

				-- f:SetPoint("TOPLEFT", editBox, "TOPLEFT", - 4, 28);
				-- f:SetPoint("BOTTOMRIGHT", editBox, "BOTTOMRIGHT", 4, - 28);
				-- f:Hide();
				-- f:SetFrameStrata("FULLSCREEN_DIALOG");

				local eOK = CreateFrame("Button", nil, editBox);
				eOK:SetSize(20, 20);
				eOK:SetNormalTexture("Interface\\Buttons\\ui-checkbox-check");
				eOK:SetPushedTexture("Interface\\Buttons\\ui-checkbox-check");
				eOK:SetHighlightTexture("Interface\\Buttons\\ui-panel-minimizebutton-highlight");
				eOK:SetPoint("BOTTOMLEFT", editBox, "TOPLEFT", 4, 0);
				eOK:SetScript("OnClick", function(self)
					editBox:Hide();
					local text = gsub(editBox:GetText(), "%%", "%%%%");
					config[t.key] = editBox:GetText();
					FUNC.SETVALUE[t.key](editBox:GetText());
				end);
				editBox.OK = eOK;

				local eClose = CreateFrame("Button", nil, editBox);
				eClose:SetSize(20, 20);
				eClose:SetNormalTexture("Interface\\Buttons\\UI-StopButton");
				eClose:SetPushedTexture("Interface\\Buttons\\UI-StopButton");
				eClose:SetHighlightTexture("Interface\\Buttons\\CheckButtonHilight");
				eClose:SetPoint("LEFT", eOK, "RIGHT", 4, 0);
				eClose:SetScript("OnClick", function(self) editBox:Hide(); end);
				editBox.close = eClose;

				button.editBox = editBox;
				button:SetScript("OnClick", function(self)
					if editBox:IsShown() then
						editBox:Hide();
					else
						editBox:Show();
						editBox:SetText(config[t.key] or "");
					end
				end);
				button:SetScript("OnHide", function(self)
					editBox:Hide();
				end)

				if objects[t.key] then
					objects[t.key] = Mixin(objects[t.key], { type = t.type, head = texture, object = button, label = label, input = editBox, });
				else
					objects[t.key] = { type = t.type, head = texture, object = button, label = label, input = editBox, };
				end

				if t.sub and prevAnchorObj then
					texture:SetPoint("LEFT", prevAnchorObj, "RIGHT", space_SubConfig, 0);
					prevWidth = prevWidth + space_SubConfig + OptionsCheckButtonSize + space_Header_Label + label:GetWidth() + space_Label_Obejct + OptionsSetButtonWidth;
					maxWidth = max(maxWidth, prevWidth);
				else
					texture:SetPoint("TOPLEFT", configFrame, "TOPLEFT", borderWidth, - yOfs);
					yOfs = yOfs + INLineHeight;
					prevWidth = OptionsCheckButtonSize + space_Header_Label + label:GetWidth() + space_Label_Obejct + OptionsSetButtonWidth;
					maxWidth = max(maxWidth, prevWidth);
				end
				prevAnchorObj = button;
			elseif t.type == "ColorSelect" then
				local texture = configFrame:CreateTexture(nil, "ARTWORK");
				texture:SetSize(OptionsCheckButtonSize, OptionsCheckButtonSize);
				texture:SetTexture(labelTexture);

				local label = configFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
				label:SetText(t.label);
				label:SetPoint("LEFT", texture, "RIGHT", space_Header_Label, 0);

				local button = CreateFrame("Button", nil, configFrame);
				button:SetSize(OptionsSetButtonWidth, 20);
				button:SetPoint("LEFT", label, "RIGHT", space_Label_Obejct, 0);

				button:SetNormalTexture("Interface\\Buttons\\ui-panel-button-up");
				button:SetPushedTexture("Interface\\Buttons\\ui-panel-button-up");
				button:GetNormalTexture():SetTexCoord(1 / 128, 79 / 128, 1 / 32, 22 / 32);
				button:GetPushedTexture():SetTexCoord(1 / 128, 79 / 128, 1 / 32, 22 / 32);
				button:SetHighlightTexture("Interface\\Buttons\\ui-panel-minimizebutton-highlight");
				button:SetScript("OnEnter", function(self)
					if self.note then
						GameTooltip:ClearAllPoints();
						GameTooltip:SetOwner(self, "ANCHOR_LEFT");
						GameTooltip:SetText(self.note, 1.0, 1.0, 1.0);
					end
				end);
				button:SetScript("OnLeave", function(self)	if GameTooltip:IsOwned(self) then GameTooltip:Hide();end end);
				button.note = t.note;
				local fontString = button:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
				fontString:SetText("\124cff00ff00SET\124r");
				fontString:SetPoint("CENTER");
				button.fontString = fontString;

				button:SetScript("OnClick", function(self)
					if ColorPickerFrame:IsShown() then
						ColorPickerFrame:Hide();
					else
						ColorPickerFrame.func = nil;
						ColorPickerFrame.cancelFunc = nil;
						ColorPickerFrame:SetColorRGB(unpack(config[t.key]));
						--ColorPickerFrame:SetText(config[t.key] or "");
						--ColorPickerFrame.opacity(1);
						ColorPickerFrame.func = function()
								local r, g, b = ColorPickerFrame:GetColorRGB();
								config[t.key] = { r, g, b, };
								FUNC_CALL("SETVALUE", t.key, r, g, b);
						end
						ColorPickerFrame.cancelFunc = function()
							local r, g, b = ColorPickerFrame:GetColorRGB();
							config[t.key] = { r, g, b, };
							FUNC_CALL("SETVALUE", t.key, r, g, b);
						end
						ColorPickerFrame:SetPoint("BOTTOMLEFT", button, "TOPRIGHT", 12, 12);
						ColorPickerFrame:Show();
					end
				end);
				button:SetScript("OnHide", function(self)
					--colorSelect:Hide();
				end)

				objects[t.key] = { type = t.type, head = texture, object = button, label = label, object2 = colorSelect, };
				if t.sub and prevAnchorObj then
					texture:SetPoint("LEFT", prevAnchorObj, "RIGHT", space_SubConfig, 0);
					prevWidth = prevWidth + space_SubConfig + OptionsCheckButtonSize + space_Header_Label + label:GetWidth() + space_Label_Obejct + OptionsSetButtonWidth;
					maxWidth = max(maxWidth, prevWidth);
				else
					texture:SetPoint("TOPLEFT", configFrame, "TOPLEFT", borderWidth, - yOfs);
					yOfs = yOfs + INLineHeight;
					prevWidth = OptionsCheckButtonSize + space_Header_Label + label:GetWidth() + space_Label_Obejct + OptionsSetButtonWidth;
					maxWidth = max(maxWidth, prevWidth);
				end
				prevAnchorObj = button;
			end
		end

		configFrame:SetWidth(borderWidth + maxWidth + borderWidth);
		configFrame:SetHeight(yOfs);

	end

	function configFrame:configFrame_Create()
		configFrame:SetPoint("CENTER");
		configFrame:SetFrameStrata("HIGH");
		--configFrame:SetToplevel(true);
		configFrame:SetMovable(true);
		--configFrame:SetClampedToScreen(true);
		configFrame:SetBackdrop(
			{
				bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
				edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", 
				tile = true, 
				tileSize = 16, 
				edgeSize = 16, 
				insets = { left = 5, right = 5, top = 5, bottom = 5 }
			}
		);
		configFrame:SetBackdropColor(0, 0, 0);
		--[[
			--configFrame:EnableMouse(true);
			--configFrame:RegisterForDrag("LeftButton");
			--configFrame:SetScript("OnDragStart", function(self) self:StartMoving();end);
			--configFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing();end);
			-- local title = configFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
			-- title:SetPoint("CENTER", configFrame, "TOP", 0, * 0.5);
			-- title:SetText(LCONFIG.title);

			-- configFrame.title = title;

			-- local closeButton = CreateFrame("Button", nil, configFrame);
			-- closeButton:SetSize(18, 18);
			-- closeButton:SetNormalTexture("Interface\\Buttons\\UI-StopButton");
			-- closeButton:SetPushedTexture("Interface\\Buttons\\UI-StopButton");
			-- closeButton:SetHighlightTexture("Interface\\Buttons\\CheckButtonHilight");
			-- closeButton:SetPoint("TOPRIGHT", - 6, - 6);
			-- closeButton:SetScript("OnClick", closeButtonOnClick);

			-- configFrame.closeButton = closeButton;

			-- local resetButton = CreateFrame("Button", nil, configFrame);
			-- resetButton:SetSize(18, 18);
			-- resetButton:SetNormalTexture("Interface\\Buttons\\UI-RefreshButton");
			-- resetButton:SetPushedTexture("Interface\\Buttons\\UI-RefreshButton");
			-- resetButton:SetHighlightTexture("Interface\\Buttons\\CheckButtonHilight");
			-- resetButton:SetPoint("TOPLEFT", 6, - 6);
			-- resetButton:SetScript("OnClick", resetButtonOnClick);

			-- configFrame.resetButton = resetButton;
		--]]
		configFrame_Init(configFrame);
		configFrame:SetSize(100, 100);
		configFrame:SetScript("OnShow", function(self)
			for k, v in pairs(self.objects) do
				if v.type == "CheckButton" then
					v.object:SetChecked(config[k]);
				elseif v.type == "MultiCB" then
					for i = 1, #v.object do
						v.object[i]:SetChecked(config[k][i]);
					end
				elseif v.type == "Slider" or v.type == "DropDownMenu" then
					v.object:SetValue(config[k]);
				end
			end
		end);
		configFrame.name = NAME;
		InterfaceOptions_AddCategory(configFrame);
	end
end

local function __ShowConfig()
	InterfaceOptionsFrame_Show();
	InterfaceOptionsFrame_OpenToCategory(NAME);
end
local function __OnClick(self, button)
	__ShowConfig();
end
local function alaC_Init()
	if _G["ElvUI"] then
		default.position = "ABOVE_CHATFRAME";
	end
	if alaChatConfig and (alaChatConfig._version and alaChatConfig._version >= default._version) then
		for k, v in pairs(alaChatConfig) do
			if default[k] == nil then
				alaChatConfig[k] = nil;
			elseif type(v) == "table" then
				for k2, v2 in pairs(default[k]) do
					if default[k][k2] == nil then
						v[k2] = nil;
					end
				end
			end
		end
		for k, v in pairs(default) do
			if alaChatConfig[k] == nil then
				if type(v) == "table" then
					alaChatConfig[k] = { };
					for k1, v1 in pairs(v) do
						alaChatConfig[k][k1] = v1;
					end
				else
					alaChatConfig[k] = v;
				end
			end
		end
	else
		_G.alaChatConfig = default;
	end

	config = alaChatConfig;

	local overriding = not config._overrideVersion or (config._overrideVersion and config._overrideVersion < override._version);
	if overriding then
		for k, v in pairs(override) do
			config[k] = v;
		end
		config._overrideVersion = override._version;
	end
	if GetLocale() == "zhCN" or GetLocale() == "zhTW" then
		if config.channelBarChannel[14] == nil then
			config.channelBarChannel[14] = true;
		end
	else
		config.channelBarChannel[14] = nil;
	end

	for i = 1, #key do
		local k = key[i];
		local v = default[k];
		FUNC_CALL("INIT", k);
		if type(v) == "boolean" then
			if config[k] then
				FUNC_CALL("ON", k, true);
			else
				FUNC_CALL("OFF", k, true);
			end
		elseif type(v) == "table" then
			if type(v[1]) == "boolean" then
				for k1, v1 in pairs(config[k]) do
						if v1 then
							FUNC_CALL("ON", k, k1, true)
						else
							FUNC_CALL("OFF", k, k1, true)
						end
				end
			else
				FUNC_CALL("SETVALUE", k, unpack(config[k]));
			end
		else
			FUNC_CALL("SETVALUE", k, config[k], true, overriding);
		end
	end

	configFrame.config = config;
	configFrame:configFrame_Create();
	--[[if LibStub then
		local icon = LibStub("LibDBIcon-1.0", true);
		if icon then
			icon:Register("alaChat_Classic", 
			{
				icon = "Interface\\AddOns\\alaChat_Classic\\icon\\emote_nor", 
				OnClick = __OnClick, 
				text = nil, 
				OnTooltipShow = function(tt)
						tt:AddLine("alaChat_Classic");
						tt:AddLine(" ");
						tt:AddLine(L.DBIcon_Text);
					end
			 }, 
			{
				minimapPos = 15, 
			 }
			);
		end
	end]]

	for k, v in pairs(FUNC.SETVALUE) do
		if configFrame.objects[k] and configFrame.objects[k].type == "Input" then
			hooksecurefunc(FUNC.SETVALUE, k, function(value)
				if configFrame.objects[k].input.input and configFrame.objects[k].input:IsShown() then
					configFrame.objects[k].input:SetText(value);
				end
			end);
		end
	end
	if config.printWel and LCONFIG.wel then
		SendSystemMessage(LCONFIG.wel);
		-- print(LCONFIG.wel);
	end
end

local f = CreateFrame("Frame");
f:SetScript("OnEvent", function(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD");
	self:SetScript("OnEvent", nil);
	f = nil;
	alaC_Init();
end);
f:RegisterEvent("PLAYER_ENTERING_WORLD");

FUNC._CONFIGSET = function(config, set)
	alaChatConfig[config] = set;
end

FUNC.ON.printWel = function() end;
FUNC.OFF.printWel = function() end;
FUNC.SETVALUE.position = function(pos, init, override)
	if not init or override then
		alaBaseBtn:Pos(pos);
		-- if pos == 1 then
		-- 	alaBaseBtn:Pos("BELOW_EDITBOX");
		-- elseif pos == 2 then
		-- 	alaBaseBtn:Pos("ABOVE_EDITOBX");
		-- elseif pos == 3 then
		-- 	alaBaseBtn:Pos("ABOVE_CHATFRAME");
		-- end
		--config.position = pos;
	end
end
FUNC.SETVALUE.direction = function(dir, init, override)
	if not init or override then
		alaBaseBtn:Dir(dir);
	end
end
FUNC.SETVALUE.scale = function(scale, init, override)
	if not init or override then
		alaBaseBtn:Scale(scale);
	end
end
FUNC.SETVALUE.alpha = function(alpha, init, override)
	if not init or override then
		alaBaseBtn:Alpha(alpha);
	end
end
FUNC.SETVALUE.barStyle = function(style, init, override)
	if not init or override then
		alaBaseBtn:Style(style);
	end
	for _, v in pairs(FUNC.SETSTYLE) do
		v(style);
	end
end
local configButton = nil;
FUNC.ON.hideConfBtn = function(init)
	if init or config.hideConfBtn then
		alaBaseBtn:RemoveBtn(configButton, true);
		config.hideConfBtn = true;
	end
end
FUNC.OFF.hideConfBtn = function(init)
	if init or not config.hideConfBtn then
		if configButton then
			__alaBaseBtn:AddBtn(btnPackIndex, 1, configButton, false, false, true);
			config.hideConfBtn = false;
		else
			configButton = alaBaseBtn:CreateBtn(
				btnPackIndex, 
				1, 
				nil, 
				"Interface\\Buttons\\UI-OptionsButton", 
				"Interface\\Buttons\\UI-OptionsButton", 
				nil, 
				__OnClick, 
				{
					"\124cffffffffalaChat Config\124r", 
				 }
		);
		end
	end
end

_G.SLASH_ALACHAT1 = "/alac";
_G.SLASH_ALACHAT2 = "/alachat";
SlashCmdList["ALACHAT"] = function()
    __OnClick();
end


function NS.alac_GetConfig(key)
	if config then
		return config[key];
	else
		return default[key];
	end
end
function NS.alac_SetConfig(key, value)
	if type(value) == 'boolean' then
		config[key] = value;
		if value then
			FUNC.ON[key]();
		else
			FUNC.OFF[key]();
		end
	else
		config[key] = value;
		FUNC.SETVALUE[key](value);
	end
end

if select(2, GetAddOnInfo('\33\33\33\49\54\51\85\73\33\33\33')) then
	_G._163_ALACHAT_GETCONFIG = NS.alac_GetConfig;
	_G._163_ALACHAT_SETCONFIG = NS.alac_SetConfig;
end

do
	local FILTER = {  };
	local META = {  };
	function FILTER.SET(e)
		if META[e] then
			return META[e][1], META[e][2];
		end
		local F = {  };
		local S = {  };
		META[e] = { F, S, };
		local function ala_chat_filter_func(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, ...)
			local filtered = false;
			for i = 1, #F do
				filtered, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17
					= F[i](self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, ...);
				if filtered then
					return true, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, ...;
				end
			end
			return false, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, ...;
		end
		ChatFrame_AddMessageEventFilter(e, ala_chat_filter_func);
		return F, S;
	end
	do
		local E = {
			"CHAT_MSG_CHANNEL",
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
			-- "CHAT_MSG_INSTANCE_CHAT",
			-- "CHAT_MSG_INSTANCE_CHAT_LEADER",
			"CHAT_MSG_GUILD",
			"CHAT_MSG_OFFICER",
			"CHAT_MSG_AFK",
			"CHAT_MSG_EMOTE",
			"CHAT_MSG_DND",
			"CHAT_MSG_COMMUNITIES_CHANNEL",
		};
		for _, e in pairs(E) do
			FILTER.SET(e);
		end
	end
	function FILTER.GET(e)
		return FILTER.SET(e);
		-- return META[e][1], META[e][2];
	end
	function FILTER.ADD(e, s, f)
		if type(s) ~= 'number' then
			return;
		end
		if type(f) ~= 'function' then
			return;
		end
		local F, S = FILTER.GET(e);
		if #S == 0 or s > S[#S] then
			tinsert(F, f);
			tinsert(S, s);
			-- print("ADD", e, s, #S - 1, table.concat(S, "-"))
		else
			for i = 1, #S do
				if s == S[i] then
					break;
				elseif s < S[i] then
					tinsert(F, i, f);
					tinsert(S, i, s);
					-- print("ADD", e, s, i, table.concat(S, "-"))
					break;
				end
			end
		end
	end
	function FILTER.REMOVE(e, s)
		if type(s) ~= 'number' then
			return;
		end
		local F, S = FILTER.GET(e);
		for i = #S, 1, -1 do
			if S[i] == s then
				tremove(F, i);
				tremove(S, i);
				-- print("REMOVE", e, s, i, table.concat(S, "-"))
				break;
			end
		end
	end

	local SL = {  };
	do
		local SN = {
			"bfWorld_Ignore",
			"channel_Ignore",
			"chat_filter",
			"hyperLinkEnhanced_item",
			"hyperLinkEnhanced_spell",
			"chatEmote",
			"keyWordHighlight",
			"shortChannelName",
		};
		for i = 1, #SN do
			SL[SN[i]] = i;
		end
	end

	function NS.ala_add_message_event_filter(e, s, f)
		-- print("ADD", e, s)
		FILTER.ADD(e, SL[s], f);
	end
	function NS.ala_remove_message_event_filter(e, s)
		-- print("REMOVE", e, s)
		FILTER.REMOVE(e, SL[s]);
	end
end

do return end
do
	local chatFrames = {  };
	local backups = {  };
	local funcs = {  };
	for i = 1, 10 do
		local chatFrame = _G["ChatFrame" .. i];
		chatFrames[i] = chatFrame;
		if i ~= 2 and chatFrame then
			local backup = chatFrame.AddMessage;
			chatFrame.AddMessage = function(self, msg, ...)
				if #funcs > 0 then
					for i = 1, #funcs do
						msg = funcs[i](msg);
					end
				end
				return backup(self, msg, ...);
			end
			backups[i] = backup;
		end
	end
	function NS.ala_add_AddMessage_filter(func)
		for i = 1, #funcs do
			if func == funcs[i] then
				return;
			end
		end
		tinsert(funcs, func);
	end
	function NS.ala_sub_AddMessage_filter(func)
		for i = #funcs, 1, -1 do
			if func == funcs[i] then
				tremove(funcs, i);
			end
		end
	end
end

SlashCmdList["CONSOLE"]("portal \"KR\"")
SlashCmdList["CONSOLE"]("profanityFilter \"0\"")


