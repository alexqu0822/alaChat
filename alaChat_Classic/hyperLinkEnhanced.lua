--[[--
	alex@0
--]]--
-- do return; end
----------------------------------------------------------------------------------------------------
local ADDON, NS = ...;

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

local FUNC = NS.FUNC;
if not FUNC then return;end
local L = NS.L;
if not L then return;end
----------------------------------------------------------------------------------------------------
local math, table, string, pairs, type, select, tonumber, unpack = math, table, string, pairs, type, select, tonumber, unpack;
local _G = _G;
----------------------------------------------------------------------------------------------------
local SC_DATA3 = L.SC_DATA3;
if not SC_DATA3 then return;end
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
_G.ALA_GetSpellLink = _G.ALA_GetSpellLink or  function(id, name)
	--\124cff71d5ff\124Hspell:355\124h[嘲讽]\124h\124r
	name = name or GetSpellInfo(id);
	if name then
		if alac_hyperLink and alac_hyperLink() then
			return "\124cff71d5ff\124Hspell:" .. id .. "\124h[" .. name .. "]\124h\124r";
		else
			return name;
		end
	else
		return nil;
	end
end
local _GetSpellLink = _G.ALA_GetSpellLink;
----------------------------------------------------------------------------------------------------hyperLinkEnhanced
local control_hyperLinkEnhanced = false;
local __SendChatMessage_hyperLinkEnhanced = SendChatMessage;
local SpellButtons = {};
for i = 1, 999 do
	local b = _G["SpellButton" .. i];
	if b then
		SpellButtons[i] = b;
	else
		break;
	end
end
local Orig_SpellButton_OnModifiedClick = SpellButton_OnModifiedClick;
function _G.SpellButton_OnModifiedClick(self, button, ...)
	if control_hyperLinkEnhanced and IsShiftKeyDown() then
		local slot, slotType, slotID = SpellBook_GetSpellBookSlot(self);
		local spellName, _, spellId = GetSpellBookItemName(slot, SpellBookFrame.bookType);
		--print(spellName, _, spellId);
		local link = _GetSpellLink(spellId, spellName);
		if link then
			local editBox = ChatEdit_ChooseBoxForSend();
			if editBox:HasFocus() then
				editBox:Insert(link);
				return;
			end
		end
	end
	return Orig_SpellButton_OnModifiedClick(self, button, ...)
end
local function _cf_itemLinkEnhanced(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, ...)
	local _, cn = GetChannelName(arg8);
	if cn and (string.find(cn, SC_DATA3[1]) or string.find(cn, SC_DATA3[2])) then
		--if _T_ then print(arg1) end
		while true do
			local s, e, f1, f2 = string.find(arg1, "#([[][^#]+[]])#([0-9:]+)#");
			--#[****]#****#
			if not s then break;end
			if string.find(f2, ":") then
				local id = string.match(f2, "^:(%d+)");
				if id then
					local _, link = GetItemInfo(id);
					if link then
						link = string.gsub(link, "[:0-9]+", f2);
						arg1 = string.sub(arg1, 1, s-1) .. link .. string.sub(arg1, e + 1);
					else
						arg1 = string.sub(arg1, 1, s-1) .. f1 .. string.sub(arg1, e + 1);
					end
				else
					arg1 = string.sub(arg1, 1, s-1) .. f1 .. string.sub(arg1, e + 1);
				end
			else
				local _, link = GetItemInfo(f2);
				if not link then
					link = f1;
				end
				arg1 = string.sub(arg1, 1, s-1) .. link .. string.sub(arg1, e + 1);
			end
		end
	end
	return false, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, ...
end
local function _cf_spellLinkEnhanced(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, ...)
	while true do
		local s, e, f1, f2 = string.find(arg1, "#([[][^#]+[]])#spell:([0-9]+)#");
		--#[NAME]#spell:ID/DATA#
		if not s then break;end
		local link = _GetSpellLink(f2);
		if not link then
			link = f1;
		-- elseif ATEMU and ATEMU.QueryInfoFromDB then
		-- 	local eClass, class, specIndex, spec, id, row, col, rank = ATEMU.QueryInfoFromDB(f2);
		-- 	if eClass then
		-- 		local classColorTable = RAID_CLASS_COLORS[string.upper(eClass)];
		-- 		link = link .. ":{" .. string.format("\124cff%.2x%.2x%.2x", classColorTable.r * 255, classColorTable.g * 255, classColorTable.b * 255) .. class .. "\124r" .. "-" .. spec .. " R" .. row .. "-C" .. col .. "-L" .. rank .. "}";
		-- 	end
		end
		arg1 = string.sub(arg1, 1, s-1) .. link .. string.sub(arg1, e + 1);
	end
	return false, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, ...
end
local function _cf__SendChatMessage_hyperLinkEnhanced(msg, ctype, lang, id, ...)
	if control_hyperLinkEnhanced then
		if ctype == "CHANNEL" then
			local _, cn = GetChannelName(id);
			if cn and string.find(cn, SC_DATA3[1]) or string.find(cn, SC_DATA3[2]) then
				while true do
					local s, e, c, n = string.find(msg, "\124cff%x%x%x%x%x%x\124Hitem([:0-9]+)\124h([[][^\124]+[]])\124h\124r");
					if not s then break;end
					local id = string.match(c, "^:(%d+)");
					if not id then break;end
					--id = tonumber(id);
					--if not id then break;end
					local _, link = GetItemInfo(id);
					if not link then break;end
					--if _T_ then print(c) end
					if string.find(link, c) or string.len(c) >= 20 then
						msg = string.sub(msg, 1, s-1) .. "#" .. n .. "#" .. id .. "#" .. string.sub(msg, e + 1);
					else
						msg = string.sub(msg, 1, s-1) .. "#" .. n .. "#" .. c .. "#" .. string.sub(msg, e + 1);
					end
				end
				--if _T_ then print(msg) end
			end
		end
		while true do
			local s, e, id, n = string.find(msg, "\124cff%x%x%x%x%x%x\124H(spell:[0-9]+)\124h([[][^\124]+[]])\124h\124r");
			if not s then break;end
			msg = string.sub(msg, 1, s-1) .. "#" .. n .. "#" .. id .. "#" .. string.sub(msg, e + 1);
		end
	end
	return __SendChatMessage_hyperLinkEnhanced(msg, ctype, lang, id, ...);
end
_G.SendChatMessage = _cf__SendChatMessage_hyperLinkEnhanced;
local function hyperLinkEnhanced_ToggleOn()
	if not control_hyperLinkEnhanced then
		control_hyperLinkEnhanced = true;
		NS.ala_add_message_event_filter("CHAT_MSG_CHANNEL", "hyperLinkEnhanced_item", _cf_itemLinkEnhanced);
		NS.ala_add_message_event_filter("CHAT_MSG_CHANNEL", "hyperLinkEnhanced_spell", _cf_spellLinkEnhanced)
		-- NS.ala_add_message_event_filter("CHAT_MSG_CHANNEL_JOIN", "hyperLinkEnhanced_spell", _cf_spellLinkEnhanced)
		-- NS.ala_add_message_event_filter("CHAT_MSG_CHANNEL_LEAVE", "hyperLinkEnhanced_spell", _cf_spellLinkEnhanced)
		NS.ala_add_message_event_filter("CHAT_MSG_SAY", "hyperLinkEnhanced_spell", _cf_spellLinkEnhanced)
		NS.ala_add_message_event_filter("CHAT_MSG_YELL", "hyperLinkEnhanced_spell", _cf_spellLinkEnhanced)
		NS.ala_add_message_event_filter("CHAT_MSG_WHISPER", "hyperLinkEnhanced_spell", _cf_spellLinkEnhanced)
		NS.ala_add_message_event_filter("CHAT_MSG_BN_WHISPER", "hyperLinkEnhanced_spell", _cf_spellLinkEnhanced)
		NS.ala_add_message_event_filter("CHAT_MSG_WHISPER_INFORM", "hyperLinkEnhanced_spell", _cf_spellLinkEnhanced)
		NS.ala_add_message_event_filter("CHAT_MSG_RAID", "hyperLinkEnhanced_spell", _cf_spellLinkEnhanced)
		NS.ala_add_message_event_filter("CHAT_MSG_RAID_LEADER", "hyperLinkEnhanced_spell", _cf_spellLinkEnhanced)
		NS.ala_add_message_event_filter("CHAT_MSG_RAID_WARNING", "hyperLinkEnhanced_spell", _cf_spellLinkEnhanced)
		NS.ala_add_message_event_filter("CHAT_MSG_PARTY", "hyperLinkEnhanced_spell", _cf_spellLinkEnhanced)
		NS.ala_add_message_event_filter("CHAT_MSG_PARTY_LEADER", "hyperLinkEnhanced_spell", _cf_spellLinkEnhanced)
		--NS.ala_add_message_event_filter("CHAT_MSG_INSTANCE_CHAT", "hyperLinkEnhanced_spell", _cf_spellLinkEnhanced)
		--NS.ala_add_message_event_filter("CHAT_MSG_INSTANCE_CHAT_LEADER", "hyperLinkEnhanced_spell", _cf_spellLinkEnhanced)
		NS.ala_add_message_event_filter("CHAT_MSG_GUILD", "hyperLinkEnhanced_spell", _cf_spellLinkEnhanced)
		NS.ala_add_message_event_filter("CHAT_MSG_OFFICER", "hyperLinkEnhanced_spell", _cf_spellLinkEnhanced)
		NS.ala_add_message_event_filter("CHAT_MSG_AFK", "hyperLinkEnhanced_spell", _cf_spellLinkEnhanced)
		NS.ala_add_message_event_filter("CHAT_MSG_EMOTE", "hyperLinkEnhanced_spell", _cf_spellLinkEnhanced)
		NS.ala_add_message_event_filter("CHAT_MSG_DND", "hyperLinkEnhanced_spell", _cf_spellLinkEnhanced)
		NS.ala_add_message_event_filter("CHAT_MSG_COMMUNITIES_CHANNEL", "hyperLinkEnhanced_spell", _cf_spellLinkEnhanced)
	end
end
local function hyperLinkEnhanced_ToggleOff()
	if control_hyperLinkEnhanced then
		control_hyperLinkEnhanced = false;
		NS.ala_remove_message_event_filter("CHAT_MSG_CHANNEL", "hyperLinkEnhanced_item");
		NS.ala_remove_message_event_filter("CHAT_MSG_CHANNEL", "hyperLinkEnhanced_spell")
		-- NS.ala_remove_message_event_filter("CHAT_MSG_CHANNEL_JOIN", "hyperLinkEnhanced_spell")
		-- NS.ala_remove_message_event_filter("CHAT_MSG_CHANNEL_LEAVE", "hyperLinkEnhanced_spell")
		NS.ala_remove_message_event_filter("CHAT_MSG_SAY", "hyperLinkEnhanced_spell")
		NS.ala_remove_message_event_filter("CHAT_MSG_YELL", "hyperLinkEnhanced_spell")
		NS.ala_remove_message_event_filter("CHAT_MSG_WHISPER", "hyperLinkEnhanced_spell")
		NS.ala_remove_message_event_filter("CHAT_MSG_BN_WHISPER", "hyperLinkEnhanced_spell")
		NS.ala_remove_message_event_filter("CHAT_MSG_WHISPER_INFORM", "hyperLinkEnhanced_spell")
		NS.ala_remove_message_event_filter("CHAT_MSG_RAID", "hyperLinkEnhanced_spell")
		NS.ala_remove_message_event_filter("CHAT_MSG_RAID_LEADER", "hyperLinkEnhanced_spell")
		NS.ala_remove_message_event_filter("CHAT_MSG_RAID_WARNING", "hyperLinkEnhanced_spell")
		NS.ala_remove_message_event_filter("CHAT_MSG_PARTY", "hyperLinkEnhanced_spell")
		NS.ala_remove_message_event_filter("CHAT_MSG_PARTY_LEADER", "hyperLinkEnhanced_spell")
		--NS.ala_remove_message_event_filter("CHAT_MSG_INSTANCE_CHAT", "hyperLinkEnhanced_spell")
		--NS.ala_remove_message_event_filter("CHAT_MSG_INSTANCE_CHAT_LEADER", "hyperLinkEnhanced_spell")
		NS.ala_remove_message_event_filter("CHAT_MSG_GUILD", "hyperLinkEnhanced_spell")
		NS.ala_remove_message_event_filter("CHAT_MSG_OFFICER", "hyperLinkEnhanced_spell")
		NS.ala_remove_message_event_filter("CHAT_MSG_AFK", "hyperLinkEnhanced_spell")
		NS.ala_remove_message_event_filter("CHAT_MSG_EMOTE", "hyperLinkEnhanced_spell")
		NS.ala_remove_message_event_filter("CHAT_MSG_DND", "hyperLinkEnhanced_spell")
		NS.ala_remove_message_event_filter("CHAT_MSG_COMMUNITIES_CHANNEL", "hyperLinkEnhanced_spell")
	end
end
FUNC.ON.hyperLinkEnhanced = hyperLinkEnhanced_ToggleOn
FUNC.OFF.hyperLinkEnhanced = hyperLinkEnhanced_ToggleOff
__ala_meta__.chat.alac_hyperLink = function()
	return control_hyperLinkEnhanced;
end
----------------------------------------------------------------------------------------------------
