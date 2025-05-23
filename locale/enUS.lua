﻿
local __addon, __private = ...;
__private.L = __private.L or { EMOTE = {}, };
local L = __private.L;

L.EMOTE["enUS"] = {
    Angel = "Angel",
    Angry = "Angry",
    Biglaugh = "Biglaugh",
    Clap = "Clap",
    Cool = "Cool",
    Cry = "Cry",
    Cute = "Cute",
    Despise = "Despise",
    Dreamsmile = "Dreamsmile",
    Embarras = "Embarras",
    Evil = "Evil",
    Excited = "Excited",
    Faint = "Faint",
    Fight = "Fight",
    Flu = "Flu",
    Freeze = "Freeze",
    Frown = "Frown",
    Greet = "Greet",
    Grimace = "Grimace",
    Growl = "Growl",
    Happy = "Happy",
    Heart = "Heart",
    Horror = "Horror",
    Ill = "Ill",
    Innocent = "Innocent",
    Kongfu = "Kongfu",
    Love = "Love",
    Mail = "Mail",
    Makeup = "Makeup",
    Mario = "Mario",
    Meditate = "Meditate",
    Miserable = "Miserable",
    Okay = "Okay",
    Pretty = "Pretty",
    Puke = "Puke",
    Shake = "Shake",
    Shout = "Shout",
    Silent = "Silent",
    Shy = "Shy",
    Sleep = "Sleep",
    Smile = "Smile",
    Suprise = "Suprise",
    Surrender = "Surrender",
    Sweat = "Sweat",
    Tear = "Tear",
    Tears = "Tears",
    Think = "Think",
    Titter = "Titter",
    Ugly = "Ugly",
    Victory = "Victory",
    Volunteer = "Volunteer",
    Wronged = "Wronged",
};

if L.Locale ~= nil and L.Locale ~= "" then
	return;
end
L.Locale = "enUS";
L.ExactLocale = GetLocale() == "enUS";

L.TABSHORT = {
	SAY = "S",
	PARTY = "P",
	RAID = "R",
	RAID_WARNING = "W",
	INSTANCE_CHAT = "B",
	GUILD = "G",
	YELL = "Y",
	WHISPER = "W",
	OFFICER = "O",
	GENERAL = "G",
	TRADE = "T",
	LOCAL_DEFENSE = "D",
	LOOK_FOR_GROUP = "L",
	-- BF_WORLD = "W",
};
L.LocalizedChannelName = {
	GENERAL = GENERAL,
	TRADE = TRADE,
	LOCAL_DEFENSE = "LocalDefense",
	LOOK_FOR_GROUP = "LookingForGroup",
	-- BF_WORLD = "大脚世界频道",
};
L.SHORTNAME_NORMALGLOBALFORMAT = {
	CHAT_WHISPER_GET = "[W]%s: ",
	CHAT_WHISPER_INFORM_GET = "[W]to%s: ",
	CHAT_MONSTER_WHISPER_GET = "[W]%s: ",
	CHAT_BN_WHISPER_GET = "[W]%s: ",
	CHAT_BN_WHISPER_INFORM_GET = "[W]to%s: ",
	CHAT_BN_CONVERSATION_GET = "%s:",
	CHAT_BN_CONVERSATION_GET_LINK = "|Hchannel:BN_CONVERSATION:%d|h[%s.C]|h",
	CHAT_SAY_GET = "[S]%s: ",
	CHAT_MONSTER_SAY_GET = "[S]%s: ",
	CHAT_YELL_GET = "[Y]%s: ",
	CHAT_MONSTER_YELL_GET = "[Y]%s: ",
	CHAT_GUILD_GET = "|Hchannel:GUILD|h[G]|h%s: ",
	CHAT_OFFICER_GET = "|Hchannel:OFFICER|h[O]|h%s: ",
	CHAT_PARTY_GET = "|Hchannel:PARTY|h[P]|h%s: ",
	CHAT_PARTY_LEADER_GET = "|Hchannel:PARTY|h[P]|h%s: ",
	CHAT_MONSTER_PARTY_GET = "|Hchannel:PARTY|h[P]|h%s: ",
	CHAT_PARTY_GUIDE_GET = "|Hchannel:PARTY|h[I]|h%s: ",
	CHAT_INSTANCE_CHAT_GET = "|Hchannel:BG|h[I]|h%s: ",
	CHAT_INSTANCE_CHAT_LEADER_GET = "|Hchannel:BG|h[I]|h%s: ",
	CHAT_RAID_GET = "|Hchannel:RAID|h[R]|h%s: ",
	CHAT_RAID_LEADER_GET = "|Hchannel:RAID|h[R]|h%s: ",
	CHAT_RAID_WARNING_GET = "[R]%s: ",

	CHAT_AFK_GET = "[AFK]%s: ",
	CHAT_DND_GET = "[DND]%s: ",
	CHAT_EMOTE_GET = "%s: ",
	CHAT_PET_BATTLE_INFO_GET = "|Hchannel:PET_BATTLE_INFO|h[Pet]|h: ",
	CHAT_PET_BATTLE_COMBAT_LOG_GET = "|Hchannel:PET_BATTLE_COMBAT_LOG|h[Pet]|h: ",
	CHAT_CHANNEL_LIST_GET = "|Hchannel:CHANNEL:%d|h[%s]|h",
	CHAT_CHANNEL_GET = "%s: ",
}
L.SHORTNAME_CHANNELHASH = {
	["General"] = "G",
	["Trade"] = "T",
	["LocalDefense"] = "D",
	["LookingForGroup"] = "L",
	["大脚世界频道"] = "世",
	["大脚世界频道1"] = "世",
	["大脚世界频道2"] = "世",
	["大脚世界频道3"] = "世",
	["大脚世界频道4"] = "世",
	["大脚世界频道5"] = "世",
	["大脚世界频道6"] = "世",
	["大脚世界频道7"] = "世",
	["大脚世界频道8"] = "世",
	["大脚世界频道9"] = "世",
	["大脚世界频道10"] = "世",
};


L.SETTINGCATEGORY = {
	GENERAL = "Apperance",
	MISC = "Detail",
	CHANNELTAB = "ChannelBar",
	CHATFILTER = "Filters",
	HIGHLIGHT = "Highlight",
	COPY = "CopyChat",
	COMPANION = "Social",
	UTILS = "Utils",
};
L.SETTING = {
	general = {
		detailedtip = "Detailed tips in GameTooltip",
	},
	docker = {
		Position = "Position",
		AutoAdjustEditBox = "Automatic ajust position of editbox",
		Direction = "Growth direction",
		alpha = "Alpha",
		FadInTime = "Fading in time `in second",
		FadedAlpha = "Faded alpha",
		FadeOutTime = "Fading out time `in second",
		FadeOutDelay = "Fading out delay `in second",
		Backdrop = "Bar backdrop",
		BackdropColor = "Backdrop color",
		BackdropAlpha = "Backdrop alpha",
		PinSize = "Size of buttons",
		PinInt = "Space between buttons",
		PinStyle = "Style `Global setting of all similar settings.",
		--
		["below.editbox"] = "Below Editbox",
		["above.editbox"] = "Above Editbox",
		["manual"] = "Mouse Drag `Modifier: CTRL",
		["RIGHT"] = "Left to right",
		["LEFT"] = "Right to left",
		["DOWN"] = "Up to down",
		["UP"] = "Down to up",
		["manual"] = "Manual move",
		["char"] = "Text",
		["char.blz"] = "Blizzard",
		["circle.blur"] = "Blur circle",
		["circle"] = "Circle",
		["square.blur"] = "Blur square",
		["square"] = "Square",
	},
	channeltab = {
		toggle = "Enable chat type changing buttons ",
		--
		SAY = "|cffffffff" .. SAY .. "|r",
		PARTY = "|cffaaaaff" .. PARTY .. "|r",
		RAID = "|cffff7f00" .. RAID .. "|r",
		RAID_WARNING = "|cffff4800" .. RAID_WARNING .. "|r",
		INSTANCE_CHAT = "|cffff7f00" .. INSTANCE_CHAT .. "|r",
		GUILD = "|cff40ff40" .. GUILD .. "|r",
		YELL = "|cffff4040" .. YELL .. "|r",
		WHISPER = "|cffff80ff" .. WHISPER .. "|r",
		OFFICER = "|cff40c040" .. OFFICER .. "|r",
		GENERAL = "|cffffc0c0" .. GENERAL .. "|r",
		TRADE = "|cffffc0c0" .. TRADE .. "|r",
		LOCAL_DEFENSE = "|cffffc0c0" .. L.LocalizedChannelName.LOCAL_DEFENSE .. "|r",
		LOOK_FOR_GROUP = "|cffffc0c0" .. L.LocalizedChannelName.LOOK_FOR_GROUP .. "|r",
		BF_WORLD = "|cffffc0c0BF_WORLD|r",
		UNMANAGEDCHANNEL = "|cffffc0c0Other channels|r",
		PinStyle = "Button style",
		UseColor = "Color button by channel",
		LeaveChannelModifier = "Modifier of leaving channel (Leave channel by modified click)",
		AutoJoinWorld = "Auto join bf-world",
		AutoAddChannelToDefaultChatFrame = "When joining any channel, add it to the first chatframe.",
		ChannelBlockButton_BLZ = "Button to block all channels temporily",
		ChannelBlockButton_World = "Button to block bf-world channel temporily",
		ChannelBlockButton_Size = "Size of switcher",
		--
		["none"] = "Donot use it",
		["char"] = "Text",
		["char.blz"] = "Blizzard",
		["circle.blur"] = "Blur circle",
		["circle"] = "Circle",
		["square.blur"] = "Blur square",
		["square"] = "Square",
	},
	chatfilter = {
		toggle = "Chat message filters",
		--
		CaseInsensitive = "Case |cff00ff00in|rsensitive",
		StrSet = "Blocked words",
		StrSetTip = "Each word occupies one line",
		NameSet = "Blacklist",
		NameSetTip = "Each name occupies one line\nMessages sent by players whose name include listed words beginning with |cff00ff00#|r will be blocked",
		Rep = "Block repeated message",
		RepInterval = "Minimum interval of repeated message",
		RepeatedSentence = "Delete repeated sentence in one message",
		ButtonInDock = "Show button in bar",
		PinStyle = "Button style",
		--
		["char"] = "Icon",
		["char.blz"] = "Blizzard",
	},
	emote = {
		toggle = "Emote icon in chat",
		--
		IconInEditBox = "Show emote icon in chat input box",
		PinStyle = "Button style",
		--
		["char"] = "Icon",
		["char.blz"] = "Blizzard",
		["circle.blur"] = "Blizzard",
		["circle"] = "Blizzard",
		["square.blur"] = "Blizzard",
		["square"] = "Blizzard",
	},
	highlight = {
		toggle = "Highlight key words",
		--
		CaseInsensitive = "Case |cff00ff00in|rsensitive",
		StrSet = "Key words",
		StrSetTip = "Each word occupies one line\nThe following color hex starts with # will make it differen color. 4 example: Raid#FF0000 makes 'Raid' highlighted tp '|cffff0000Raid|r'",
		color = "Color",
		format = "Format",
		ShowMatchedOnly = "Block not matching message `Auto closed each time entering world or reloading",
		["ShowMatchedOnly.CHANNEL"] = "Block |cffffc0c0[channel]|r",
		["ShowMatchedOnly.SAY-YELL"] = "Block |cffffffff[say]|r、|cffff4040[yell]|r",
		["ShowMatchedOnly.NORMAL"] = "Block any other. (|cffff80ff[whisper]|r, |cff40ff40[guild]|r, |cffaaaaff[party]|r, |cffff7f00[raid]|r etc)",
		KeepShowMatchedOnly = "Diabled auto-closed. `|cffff0000Do you have a good memory ?|r",
		ButtonInDock = "Show button in bar",
		PinStyle = "Button style",
		--
		["#HL#"] = "NAXX",
		[">>#HL#<<"] = ">>NAXX<<",
		["**#HL#**"] = "**NAXX**",
		["[[#HL#]]"] = "[[NAXX]]",
		["char"] = "Text",
		["char.blz"] = "Blizzard",
	},
	copy = {
		toggle = "Chat copy `By clicking timestamp",
		--
		color = "Color",
		format = "Format",
		--
		["none"] = "*",
		["%H:%M"] = "15:27",
		["%H:%M:%S"] = "15:27:32",
		["%I:%M"] = "03:27",
		["%I:%M:%S"] = "03:27:32",
		["%I:%M %p"] = "03:27 PM",
		["%I:%M:%S %p"] = "03:27:32 PM",
	},
	shortchattype = {
		toggle = "Short channel name",
		--
		format = "Format",
		--
		["n.w"] = "number.short-name (1.G)",
		["n"] = "number (1)",
		["w"] = "short-name (G)",
	},
	misc = {
		Font = "Font",
		FontFlag = "Outline",
		ChatFrameToBorder = "Allow dragging chatframe close to edge of the game window",
		ColoredPlayerName = "Color players' name in chat",
		HoverHyperlink = "Show tooltip when hovering hyperlink in chat frame",
		ChatHyperlink = "Use hyperlink in General and LookingForGroup",
		TabChangeChatType = "Change chat type by clicking tab",
		StickyWhisper = "Sticky whisper `Keep the editbox in |cffff80ffwhisper|r after sending message",
		StickyBNWhisper = "Sticky BNWhisper `Keep the editbox in |cff00fff6bn whisper|r after sending message",
		StickyChannel = "Sticky channel `Keep the editbox in |cffffc0c0channel|r after sending message",
		ArrowKey = "When editbox activated, use arrows to move cursor insted of control character",
		ArrowHistory = "Use UP and DOWN to resend history msg (instead of alt + arrow)",
		--
		["none"] = "No outline",
		["OUTLINE"] = "Thin outline",
		["THICKOUTLINE"] = "Thick outline",
	},
	utils = {
		StatReport = "Stat report",
		DBMPull = "DBM pull",
		DBMPullLen = "Time length of DBM pull",
		roll = "ROLL",
		ReadyCheck = "Do ready Check",
	},
	companion = {
		SavedInDB = "Save info of players to disk `It will increase memory usage",
		ShowLevel = "Show level of players in chat",
		ShowSubGroup = "Show group index of raid members.",
		PlayerLinkFormat = "Format",
		WelToGuild = "Welcome new guild member by sending a message",
		WelToGuildStrSet = "Welcome messsage",
		WelToGuildStrSetTip = "Each message occupies one line. Send a random one if there is more than one line. \n`Dict: |cff7fff7f#PLAYER#|r = My Name |cff7fff7f#PCLASS#|r = My Class |cff7fff7f#PRACE#|r = My Race |cff7fff7f#NAME#|r = Name |cff7fff7f#CLASS#|r = Class |cff7fff7f#LEVEL#|r = Level |cff7fff7f#AREA#|r = Where she/he is",
		WelToGuildDelay = "Send message after a short break `Random between 2 - 6 seconds",
		NewMemberNotice = "Send a notice to guild for new guild member",
		NewMemberNoticeStr = "Format",
		NewMemberNoticeStrTip = "Use the first valid line. \n`Dict: |cff7fff7f#NAME#|r = Name |cff7fff7f#CLASS#|r = Class |cff7fff7f#LEVEL#|r = Level |cff7fff7f#AREA#|r = Where she/he is",
		--
		["#INDEX.##NAME##LEVEL#"] = "1.Alex|cffffff0070|r",
		["#INDEX.##NAME##:LEVEL#"] = "1.Alex:|cffffff0070|r",
		["#INDEX.##NAME##(LEVEL)#"] = "1.Alex(|cffffff0070|r)",
		["#(INDEX)##NAME##LEVEL#"] = "(1)Alex|cffffff0070|r",
		["#(INDEX)##NAME##:LEVEL#"] = "(1)Alex:|cffffff0070|r",
		["#LEVEL:##NAME## INDEX#"] = "|cffffff0070|r:Alex 1",
		--
		["def.WelToGuildStrSet"] = "Hey #NAME#, Nice to meet u !",
		["def.NewMemberNoticeStr"] = "** Lv#LEVEL# #CLASS# #NAME# Joins us **",
	},
};

L.STATREPORT = {
	melee = "Melee DPS",
	spell = "Caster DPS",
	ranged = "Ranged DPS",
	tank = "Tank",
	heal = "Healder",
	SHAPESHIFTFORMFIRST = "Use it in cat or bear form",
	["163UI"] = "Stat Report: ",
	ItemLevel = "ItemLevel",
};

L.TIP = {
	-- channeltab = "",
	chatfilter = "Chat message filters",
	emote = "Emote",
	highlight = "Words highlight",
	StatReport = "Stat Report",
	DBMPull = "DBM Pull",
	roll = "ROLL",
	ReadyCheck = "Ready Check",
};
L.DETAILEDTIP = {
	DockerDrag = { "CTRL-Drag to move", },
	channeltab = { "LeftButton: Open to chat", "RightButton: Block this channel", },
	channeltabjoin = { "Click to join" };
	chatfilter = { "LeftButton: Toggle on/off", "RightButton: Set key words", "ALT-RightButton: Set blacklist", },
	-- emote = "",
	highlight = { "LeftButton: Toggle on/off", "RightButton: Set key words", },
	StatReport = { "LeftButton: Automatic gen stat report", "RightButton: Choose a different role", },
	DBMPull = { "LeftButton: Start counting down", "RightButton: Stop counting down", },
	-- roll = "ROLL",
	-- ReadyCheck = "就位确认",
};

L["Find profiles of alaChat_Classic. Do you want to upgrade it and overwrite current setting?"] = "Find profiles of alaChat_Classic. Do you want to upgrade it and overwrite current setting?";
