﻿
local __addon, __private = ...;
__private.L = __private.L or { EMOTE = {}, };
local L = __private.L;

L.EMOTE["zhTW"] = {
    Angel = "天使",
    Angry = "生氣",
    Biglaugh = "大笑",
    Clap = "鼓掌",
    Cool = "酷",
    Cry = "哭",
    Cute = "可愛",
    Despise = "鄙視",
    Dreamsmile = "美夢",
    Embarras = "尷尬",
    Evil = "邪惡",
    Excited = "興奮",
    Faint = "暈",
    Fight = "打架",
    Flu = "流感",
    Freeze = "呆",
    Frown = "皺眉",
    Greet = "致敬",
    Grimace = "鬼臉",
    Growl = "齜牙",
    Happy = "開心",
    Heart = "心",
    Horror = "恐懼",
    Ill = "生病",
    Innocent = "無辜",
    Kongfu = "功夫",
    Love = "花癡",
    Mail = "郵件",
    Makeup = "化妝",
    Mario = "馬里奧",
    Meditate = "沉思",
    Miserable = "可憐",
    Okay = "好",
    Pretty = "漂亮",
    Puke = "吐",
    Shake = "握手",
    Shout = "喊",
    Silent = "閉嘴",
    Shy = "害羞",
    Sleep = "睡覺",
    Smile = "微笑",
    Suprise = "吃驚",
    Surrender = "失敗",
    Sweat = "流汗",
    Tear = "流淚",
    Tears = "悲劇",
    Think = "想",
    Titter = "偷笑",
    Ugly = "猥瑣",
    Victory = "勝利",
    Volunteer = "雷鋒",
    Wronged = "委屈",
};

if GetLocale() ~= "zhTW" then
	return;
end
L.Locale = "zhTW";
L.ExactLocale = true;

L.TABSHORT = {
	SAY = "說",
	PARTY = "隊",
	RAID = "團",
	RAID_WARNING = "通",
	INSTANCE_CHAT = "副",
	GUILD = "會",
	YELL = "喊",
	WHISPER = "密",
	OFFICER = "官",
	GENERAL = "綜",
	TRADE = "交",
	LOCAL_DEFENSE = "本",
	LOOK_FOR_GROUP = "組",
	BF_WORLD = "世",
};
L.LocalizedChannelName = {
	GENERAL = GENERAL,
	TRADE = TRADE,
	LOCAL_DEFENSE = "本地防務",
	LOOK_FOR_GROUP = LOOK_FOR_GROUP,
	BF_WORLD = "大脚世界频道",
};
L.SHORTNAME_NORMALGLOBALFORMAT = {
	CHAT_WHISPER_GET = "[密]%s説: ",
	CHAT_WHISPER_INFORM_GET = "[密]对%s説: ",
	CHAT_MONSTER_WHISPER_GET = "[密]%s説: ",
	CHAT_BN_WHISPER_GET = "[密]%s説: ",
	CHAT_BN_WHISPER_INFORM_GET = "[密]对%s説: ",
	CHAT_BN_CONVERSATION_GET = "%s:",
	CHAT_BN_CONVERSATION_GET_LINK = "|Hchannel:BN_CONVERSATION:%d|h[%s.對話]|h",
	CHAT_SAY_GET = "[説]%s: ",
	CHAT_MONSTER_SAY_GET = "[説]%s: ",
	CHAT_YELL_GET = "[喊]%s: ",
	CHAT_MONSTER_YELL_GET = "[喊]%s: ",
	CHAT_GUILD_GET = "|Hchannel:GUILD|h[會]|h%s: ",
	CHAT_OFFICER_GET = "|Hchannel:OFFICER|h[官]|h%s: ",
	CHAT_PARTY_GET = "|Hchannel:PARTY|h[隊]|h%s: ",
	CHAT_PARTY_LEADER_GET = "|Hchannel:PARTY|h[隊]|h%s: ",
	CHAT_MONSTER_PARTY_GET = "|Hchannel:PARTY|h[隊]|h%s: ",
	CHAT_PARTY_GUIDE_GET = "|Hchannel:PARTY|h[副]|h%s: ",
	CHAT_INSTANCE_CHAT_GET = "|Hchannel:BG|h[副]|h%s: ",
	CHAT_INSTANCE_CHAT_LEADER_GET = "|Hchannel:BG|h[副]|h%s: ",
	CHAT_RAID_GET = "|Hchannel:RAID|h[團]|h%s: ",
	CHAT_RAID_LEADER_GET = "|Hchannel:RAID|h[團]|h%s: ",
	CHAT_RAID_WARNING_GET = "[團]%s: ",

	CHAT_AFK_GET = "[AFK]%s: ",
	CHAT_DND_GET = "[DND]%s: ",
	CHAT_EMOTE_GET = "%s: ",
	CHAT_PET_BATTLE_INFO_GET = "|Hchannel:PET_BATTLE_INFO|h[寵]|h: ",
	CHAT_PET_BATTLE_COMBAT_LOG_GET = "|Hchannel:PET_BATTLE_COMBAT_LOG|h[寵]|h: ",
	CHAT_CHANNEL_LIST_GET = "|Hchannel:頻道:%d|h[%s]|h",
	CHAT_CHANNEL_GET = "%s: ",
};
L.SHORTNAME_CHANNELHASH = {
	["綜合"] = "綜",
	["交易"] = "交",
	["本地防務"] = "本",
	["尋求組隊"] = "尋",
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
	GENERAL = "外觀設置",
	MISC = "聊天細節",
	CHANNELTAB = "頻道切換",
	CHATFILTER = "聊天過濾",
	HIGHLIGHT = "聊天高亮",
	COPY = "聊天複製",
	COMPANION = "公會好友",
	UTILS = "其它工具",
};
L.SETTING = {
	general = {
		detailedtip = "按鈕提示中顯示詳細提示【關閉前請確定已經瞭解所有操作】",
	},
	docker = {
		Position = "按鈕欄位置",
		AutoAdjustEditBox = "自動調整輸入框位置",
		Direction = "按鈕欄方向",
		alpha = "透明度",
		FadInTime = "漸顯時間/秒",
		FadedAlpha = "漸隱透明度",
		FadeOutTime = "漸隱時間/秒",
		FadeOutDelay = "漸隱延遲",
		Backdrop = "按鈕欄背景",
		BackdropColor = "背景顏色",
		BackdropAlpha = "背景透明度",
		PinSize = "按鈕大小",
		PinInt = "按鈕間距",
		PinStyle = "按鈕風格(自動更改其它標簽中的風格設置)",
		--
		["below.editbox"] = "輸入框下方",
		["above.editbox"] = "輸入框上方",
		["manual"] = "自由拖動 `快捷鍵: CTRL",
		["RIGHT"] = "由左向右",
		["LEFT"] = "由右向左",
		["DOWN"] = "由上到下",
		["UP"] = "由下到上",
		["manual"] = "自由拖動",
		["char"] = "文字",
		["char.blz"] = "暴雪",
		["circle.blur"] = "毛邊圓",
		["circle"] = "圓圈",
		["square.blur"] = "毛邊方塊",
		["square"] = "方塊",
	},
	channeltab = {
		toggle = "打開頻道切換按鈕",
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
		BF_WORLD = "|cffffc0c0世界頻道|r",
		UNMANAGEDCHANNEL = "|cffffc0c0其它頻道|r",
		PinStyle = "按鈕風格",
		UseColor = "按聊天著色按鈕",
		LeaveChannelModifier = "離開頻道案件 (按住此按鍵點擊頻道切換按鈕將離開頻道)",
		AutoJoinWorld = "自動加入世界頻道",
		AutoAddChannelToDefaultChatFrame = "加入任何一個頻道時，自動將其添加到第一個聊天窗口中",
		ChannelBlockButton_BLZ = "公共頻道開關",
		ChannelBlockButton_World = "世界頻道開關",
		ChannelBlockButton_Size = "開關按鈕大小",
		--
		["none"] = "關閉此功能",
		["char"] = "文字",
		["char.blz"] = "暴雪",
		["circle.blur"] = "毛邊圓",
		["circle"] = "圓圈",
		["square.blur"] = "毛邊方塊",
		["square"] = "方塊",
	},
	chatfilter = {
		toggle = "打開聊天過濾",
		--
		CaseInsensitive = "忽略大小寫",
		StrSet = "設置關鍵詞",
		StrSetTip = "每行一個關鍵詞",
		NameSet = "設置黑名單",
		NameSetTip = "每行一個名字\n|cff00ff00#|r開頭表示模糊匹配名字",
		Rep = "打開重複信息過濾",
		RepInterval = "重複信息最短間隔",
		RepeatedSentence = "合并單條聊天中的重複語句",
		ButtonInDock = "在聊天條裏顯示按鈕",
		PinStyle = "按鈕風格",
		--
		["char"] = "圖片",
		["char.blz"] = "暴雪",
	},
	emote = {
		toggle = "打開聊天表情",
		--
		IconInEditBox = "在聊天輸入框中顯示圖標",
		PinStyle = "聊天切換條按鈕風格",
		--
		["char"] = "圖片",
		["char.blz"] = "暴雪",
		["circle.blur"] = "暴雪",
		["circle"] = "暴雪",
		["square.blur"] = "暴雪",
		["square"] = "暴雪",
	},
	highlight = {
		toggle = "打開關鍵詞高亮",
		--
		CaseInsensitive = "忽略大小寫",
		StrSet = "設置關鍵詞",
		StrSetTip = "每行一個關鍵詞",
		color = "設置著色",
		format = "設置格式",
		ShowMatchedOnly = "只顯示包含關鍵詞的聊天 `每次登錄或重載插件都會自動關閉",
		["ShowMatchedOnly.CHANNEL"] = "過濾 |cffffc0c0[頻道]",
		["ShowMatchedOnly.SAY-YELL"] = "過濾 |cffffffff[說]|r、|cffff4040[喊]|r",
		["ShowMatchedOnly.NORMAL"] = "過濾所有其它消息類型(|cffff80ff悄悄話|r、|cff40ff40公會|r、|cffaaaaff隊伍|r、|cffff7f00團隊|r等)",
		KeepShowMatchedOnly = "禁止自動關閉【|cffff0000你記得住你點過這個嗎？|r】",
		ButtonInDock = "在聊天條裏顯示按鈕",
		PinStyle = "按鈕風格",
		--
		["#HL#"] = "NAXX",
		[">>#HL#<<"] = ">>NAXX<<",
		["**#HL#**"] = "**NAXX**",
		["[[#HL#]]"] = "[[NAXX]]",
		["char"] = "圖片",
		["char.blz"] = "暴雪",
	},
	copy = {
		toggle = "打開聊天複製功能，點擊時間戳複製",
		--
		color = "設置著色",
		format = "設置格式",
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
		toggle = "打開短頻道名",
		--
		format = "設置頻道格式",
		--
		["n.w"] = "數字.短名 (1.綜)",
		["n"] = "數字 (1)",
		["w"] = "短名 (綜)",
	},
	misc = {
		Font = "字體",
		FontFlag = "陰影",
		ChatFrameToBorder = "允許將聊天框拖動到緊靠游戲邊緣",
		ColoredPlayerName = "按職業著色聊天框中的玩家名",
		HoverHyperlink = "鼠標指向時顯示聊天物品信息",
		ChatHyperlink = "在不支持超鏈接的頻道中使用|cff1eff00[物品]|r/|cff71d5ff[法術]|r鏈接",
		TabChangeChatType = "TAB鍵切換輸入框頻道",
		StickyWhisper = "聊天框保持上一次的|cffff80ff私聊|r狀態",
		StickyBNWhisper = "聊天框保持上一次的|cff00fff6戰網聊天|r狀態",
		StickyChannel = "聊天框保持上一次的頻道聊天狀態",
		ArrowKey = "聊天框激活時使用方向鍵移動光標（而不是控制角色移動）",
		ArrowHistory = "使用上下箭頭來自動輸入歷史消息（不用按ALT）",
		--
		["none"] = "無陰影",
		["OUTLINE"] = "薄陰影",
		["THICKOUTLINE"] = "厚陰影",
	},
	utils = {
		StatReport = "屬性報告",
		DBMPull = "倒計時按鈕",
		DBMPullLen = "倒計時時長",
		roll = "ROLL點按鈕",
		ReadyCheck = "就位確認按鈕",
	},
	companion = {
		SavedInDB = "將緩存的玩家保存到設置文件中【將增加内存占用】",
		ShowLevel = "顯示玩家等級",
		ShowSubGroup = "顯示團隊成員小隊編號",
		PlayerLinkFormat = "玩家鏈接格式",
		WelToGuild = "打開公會新成員自動歡迎",
		WelToGuildStrSet = "設置歡迎語",
		WelToGuildStrSetTip = "每行一句。每次隨機選擇一行。\n|cff7fff7f#PLAYER#|r = 自己的名字 |cff7fff7f#PCLASS#|r = 自己的職業 |cff7fff7f#PRACE#|r = 自己的種族 |cff7fff7f#NAME#|r = 名字 |cff7fff7f#CLASS#|r = 職業 |cff7fff7f#LEVEL#|r = 等級 |cff7fff7f#AREA#|r = 位置",
		WelToGuildDelay = "延遲發送歡迎語",
		NewMemberNotice = "新成員通知",
		NewMemberNoticeStr = "設置通知格式",
		NewMemberNoticeStrTip = "使用首個有效的行。\n|cff7fff7f#NAME#|r = 名字 |cff7fff7f#CLASS#|r = 職業 |cff7fff7f#LEVEL#|r = 等級 |cff7fff7f#AREA#|r = 位置",
		--
		["#INDEX.##NAME##LEVEL#"] = "1.Alex|cffffff0070|r",
		["#INDEX.##NAME##:LEVEL#"] = "1.Alex:|cffffff0070|r",
		["#INDEX.##NAME##(LEVEL)#"] = "1.Alex(|cffffff0070|r)",
		["#(INDEX)##NAME##LEVEL#"] = "(1)Alex|cffffff0070|r",
		["#(INDEX)##NAME##:LEVEL#"] = "(1)Alex:|cffffff0070|r",
		["#LEVEL:##NAME## INDEX#"] = "|cffffff0070|r:Alex 1",
		--
		["def.WelToGuildStrSet"] = "歡迎 #NAME# ！",
		["def.NewMemberNoticeStr"] = "** 新公會成員：Lv#LEVEL# #CLASS# #NAME# **",
	},
};

L.STATREPORT = {
	melee = "近戰",
	spell = "法術",
	ranged = "遠程",
	tank = "沙包",
	heal = "補師",
	SHAPESHIFTFORMFIRST = "先變熊或者貓",
	["163UI"] = "有愛屬性通報: ",
};

L.TIP = {
	-- channeltab = "",
	chatfilter = "聊天過濾",
	emote = "表情",
	highlight = "關鍵詞高亮",
	StatReport = "屬性報告",
	DBMPull = "倒計時按鈕",
	roll = "ROLL",
	ReadyCheck = "就位確認",
};
L.DETAILEDTIP = {
	DockerDrag = { "按住CTRL拖動來移動位置", },
	channeltab = { "左鍵：切換頻道", "右鍵：屏蔽該頻道", "ALT右鍵：設置黑名單", },
	channeltabjoin = { "點擊加入頻道" };
	chatfilter = { "左鍵：啓用/關閉", "右鍵：設置關鍵詞" },
	-- emote = "",
	highlight = { "左鍵：啓用/關閉", "右鍵：設置關鍵詞" },
	StatReport = { "左鍵：自動匹配生成報告", "右鍵：手選報告類型", },
	DBMPull = { "左鍵：開始倒計時", "右鍵：取消倒計時", },
	-- roll = "ROLL",
	-- ReadyCheck = "就位确认",
};

L["Find profiles of alaChat_Classic. Do you want to upgrade it and overwrite current setting?"] = "發現alaChat_Classic舊版本的配置，是否使用它覆蓋當前設置？";
