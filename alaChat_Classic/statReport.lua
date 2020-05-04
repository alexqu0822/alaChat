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
local CB_DATA = L.CHATBAR;
if not CB_DATA then return;end
local REPORT_DATA = L.REPORT;
if not REPORT_DATA then return;end
----------------------------------------------------------------------------------------------------
local alaBaseBtn = __alaBaseBtn;
if not alaBaseBtn then
	return;
end
--------------------------------------------------stat report
local control_statReport = false;
local btnStatReport = nil;
local locale_class, class = UnitClass('player');

local function genReport(set)
	-- if true then return "Function Under Construction. 功能施工中";end
	local uLevel = UnitLevel('player');
	--local uSpecId = GetSpecialization();
	--local _, uSpec, _, _, uRole = GetSpecializationInfo(uSpecId);
	--uRole = _G[uRole] or uRole;
	--local maxIl, curIl = GetAverageItemLevel();
	--
	local str = UnitStat('player', 1);
	local agi = UnitStat('player', 2);
	local sta = UnitStat('player', 3);
	local int = UnitStat('player', 4);
	--
	--local mChance = GetMasteryEffect();
	--local mRating = GetCombatRating(CR_MASTERY);
	--local cChance = GetCritChance();
	--local cRating = GetCombatRating(CR_CRIT_SPELL);
	--local hChance = GetHaste();
	--local hRating = GetCombatRating(CR_HASTE_SPELL);
	--local vChance = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE);
	--local vRating = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE);
	--
	local pChance = GetParryChance();
	local dChance = GetDodgeChance();
	local bChance = GetBlockChance();
	local shieldBlock = GetShieldBlock();
	--
	--local lefeSteal = GetLifesteal();
	--local avoidance = GetAvoidance();
	--local speed = GetSpeed();
	--
	--table azeriteLoc = C_AzeriteItem.FindActiveAzeriteItem()
	--boolean has = C_AzeriteItem.HasActiveAzeriteItem(azeriteLoc)
	--1 physical 2 holy 3 fire 4 nature 5 frost 6 shadow 7 arcane
	--int xp, int xpMax = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteLoc)
	--int level = C_AzeriteItem:GetPowerLevel(azeriteLoc)
	--
	local ap, apmod = UnitAttackPower('player');
	ap = ap + apmod;
	local sp = GetSpellBonusDamage(1);
	for i = 2, 7 do
		local spi = GetSpellBonusDamage(i);
		if spi > sp then
			sp = spi;
		end
	end
	local rp, rpmod = UnitRangedAttackPower('player');
	rp = rp + rpmod;
	--1 physical 2 holy 3 fire 4 nature 5 frost 6 shadow 7 arcane
	local heal = GetSpellBonusHealing();
	local health = UnitHealthMax('player');
	local mana = UnitPowerMax('player', 0);
	local _, armor = UnitArmor('player');
	local pCrit = GetCritChance();
	local rCrit = GetRangedCritChance();
	local sCrit = GetSpellCritChance();
	local hit = GetHitModifier();
	local shit = GetSpellHitModifier();
	--
	--C_AzeriteItem:GetPowerLevel(C_AzeriteItem.FindActiveAzeriteItem());
	--for k, v in pairs(C_AzeriteItem:FindActiveAzeriteItem()) do print(k, v) end
	-- local hasAz = C_AzeriteItem.HasActiveAzeriteItem();
	-- local azLevel = nil;
	-- local neckLevel = nil;
	-- if hasAz then
	-- 	local azeriteLoc = C_AzeriteItem.FindActiveAzeriteItem();
	-- 	azLevel = C_AzeriteItem.GetPowerLevel(azeriteLoc);
	-- 	if azeriteLoc.equipmentSlotIndex then
	-- 		local neckLink = GetInventoryItemLink('player', 2);
	-- 		neckLevel = neckLink and select(4, GetItemInfo(neckLink)) or -1;
	-- 	elseif azeriteLoc.bagID and azeriteLoc.slotIndex then
	-- 		local neckLink = GetContainerItemLink(azeriteLoc.bagID, azeriteLoc.slotIndex);
	-- 		neckLevel = neckLink and select(4, GetItemInfo(neckLink)) or -1;
	-- 	end
	-- else
	-- 	local neckLink = GetInventoryItemLink('player', 2);
	-- 	neckLevel = neckLink and select(4, GetItemInfo(neckLink)) or 0;
	-- end
	--
	-- local text = string.format("%s:%s,%s:%s(%s),%s:%.1f(%.1f)%s,%s:%d(%.1f%%),%s:%d(%.1f%%),%s:%d(%.1f%%),%s:%d(%.1f%%)",
	-- 	CB_DATA.T_STAT,
	-- 	locale_class,
	-- 	TALENT, uSpec, uRole,
	-- 	STAT_AVERAGE_ITEM_LEVEL, curIl, maxIl,
	-- 	hasAz and string.format(",%s:%d(%s%d)",REPORT_DATA.neckLevel, neckLevel, REPORT_DATA.azLevel, azLevel) or "", --neck
	-- 	STAT_MASTERY, mRating, mChance,
	-- 	STAT_CRITICAL_STRIKE, cRating, cChance,
	-- 	STAT_HASTE, hRating, hChance,
	-- 	STAT_VERSATILITY, vRating, vChance
	-- 	);
	-- return text;
	--[[
		/run for k,v in pairs(_G) do if v == '法术治疗' then print(k) end end
		str agi sta int spi
		SPELL_STAT#_NAME

		ARMOR
		STAT_ATTACK_POWER
		RANGED_ATTACK_POWER
		STAT_SPELLPOWER
		STAT_SPELLHEALING

		_ def dog par blo hit _ _ crit
		COMBAT_RATING_NAME#
	]]
	if class == 'WARRIOR' then
		if set then
			return string.format(
				"%s: %s%d%s, %s%d, %s%d, %s%d%%, %s%.2f%%",
				CB_DATA.T_STAT,
				LEVEL, uLevel, locale_class,
				HEALTH, health,
				STAT_ATTACK_POWER, ap,
				COMBAT_RATING_NAME6, hit,
				COMBAT_RATING_NAME9, pCrit
			);
		else
			local def = 0;
			for i = 1, GetNumSkillLines() do
				local name, header, _, rank, rankTemp, rankMod, rankMax = GetSkillLineInfo(i);
				if name == COMBAT_RATING_NAME2 then
					def = rank + rankTemp + rankMod;
					break;
				end
			end
			return string.format(
				"%s: %s%d%s, %s%d, %s%d, %s%d, %s%.2f%%, %s%.2f%%, %s%.2f%%%s%d, %s%d, %s%d%%, %s%.2f%%",
				CB_DATA.T_STAT,
				LEVEL, uLevel, locale_class,
				HEALTH, health,
				COMBAT_RATING_NAME2, def,
				ARMOR, armor,
				COMBAT_RATING_NAME3, dChance,
				COMBAT_RATING_NAME4, pChance,
				COMBAT_RATING_NAME5, bChance, ITEM_MOD_BLOCK_VALUE_SHORT, shieldBlock,
				STAT_ATTACK_POWER, ap,
				COMBAT_RATING_NAME6, hit,
				COMBAT_RATING_NAME9, pCrit
			);
		end
	elseif class == 'HUNTER' then
		return string.format(
			"%s: %s%d%s, %s%d, %s%d, %s%d, %s%d%%, %s%.2f%%",
			CB_DATA.T_STAT,
			LEVEL, uLevel, locale_class,
			HEALTH, health,
			MANA, mana,
			RANGED_ATTACK_POWER, rp,
			COMBAT_RATING_NAME6, hit,
			COMBAT_RATING_NAME9, rCrit
		);
	elseif class == 'SHAMAN' then
		if set then
			return string.format(
				"%s: %s%d%s, %s%d, %s%d, %s%.2f%%, %s%d, %s%d%%, %s%.2f%%, %s%d, %s%d%%, %s%.2f%%",
				CB_DATA.T_STAT,
				LEVEL, uLevel,locale_class,
				HEALTH, health,
				MANA, mana,
				COMBAT_RATING_NAME9, sCrit,
				STAT_SPELLPOWER, sp,
				COMBAT_RATING_NAME6, shit,
				COMBAT_RATING_NAME9, sCrit,
				STAT_ATTACK_POWER, ap,
				COMBAT_RATING_NAME6, hit,
				COMBAT_RATING_NAME9, pCrit
			);
		else
			return string.format(
				"%s: %s%d%s, %s%d, %s%d, %s%d, %s%d, %s%d%%, %s%.2f%%, %s%d, %s%d%%, %s%.2f%%",
				CB_DATA.T_STAT,
				LEVEL, uLevel,locale_class,
				HEALTH, health,
				MANA, mana,
				STAT_SPELLHEALING, heal,
				STAT_SPELLPOWER, sp,
				COMBAT_RATING_NAME6, shit,
				COMBAT_RATING_NAME9, sCrit,
				STAT_ATTACK_POWER, ap,
				COMBAT_RATING_NAME6, hit,
				COMBAT_RATING_NAME9, pCrit
			);
		end
	elseif class == 'PALADIN' then
		if set then
			return string.format(
				"%s: %s%d%s, %s%d, %s%d, %s%d, %s%d%%, %s%.2f%%",
				CB_DATA.T_STAT,
				LEVEL, uLevel,locale_class,
				HEALTH, health,
				MANA, mana,
				STAT_ATTACK_POWER, ap,
				COMBAT_RATING_NAME6, hit,
				COMBAT_RATING_NAME9, pCrit
			);
		else
			local def = 0;
			for i = 1, GetNumSkillLines() do
				local name, header, _, rank, rankTemp, rankMod, rankMax = GetSkillLineInfo(i);
				if name == COMBAT_RATING_NAME2 then
					def = rank + rankTemp + rankMod;
					break;
				end
			end
			return string.format(
				"%s: %s%d%s, %s%d, %s%d, %s%d, %s%.2f%%, %s%d, %s%d, %s%.2f%%, %s%.2f%%, %s%.2f%%%s%d, %s%d, %s%d%%, %s%.2f%%",
				CB_DATA.T_STAT,
				LEVEL, uLevel,locale_class,
				HEALTH, health,
				MANA, mana,
				STAT_SPELLHEALING, heal,
				COMBAT_RATING_NAME9, sCrit,
				COMBAT_RATING_NAME2, def,
				ARMOR, armor,
				COMBAT_RATING_NAME3, dChance,
				COMBAT_RATING_NAME4, pChance,
				COMBAT_RATING_NAME5, bChance, ITEM_MOD_BLOCK_VALUE_SHORT, shieldBlock,
				STAT_ATTACK_POWER, ap,
				COMBAT_RATING_NAME6, hit,
				COMBAT_RATING_NAME9, pCrit
			);
		end
	elseif class == 'PRIEST' then
		if set then
			return string.format(
				"%s: %s%d%s, %s%d, %s%d, %s%d%%, %s%.2f%%",
				CB_DATA.T_STAT,
				LEVEL, uLevel,locale_class,
				HEALTH, health,
				MANA, mana,
				STAT_SPELLPOWER, sp,
				COMBAT_RATING_NAME6, shit,
				COMBAT_RATING_NAME9, sCrit
			);
		else
			return string.format(
				"%s: %s%d%s, %s%d, %s%d, %s%d, %s%d, %s%d%%, %s%.2f%%",
				CB_DATA.T_STAT,
				LEVEL, uLevel,locale_class,
				HEALTH, health,
				MANA, mana,
				STAT_SPELLHEALING, heal,
				STAT_SPELLPOWER, sp,
				COMBAT_RATING_NAME6, shit,
				COMBAT_RATING_NAME9, sCrit
			);
		end
	elseif class == 'WARLOCK' then
		return string.format(
			"%s: %s%d%s, %s%d, %s%d, %s%d, %s%d%%, %s%.2f%%",
			CB_DATA.T_STAT,
			LEVEL, uLevel, locale_class,
			HEALTH, health,
			MANA, mana,
			STAT_SPELLPOWER, sp,
			COMBAT_RATING_NAME6, shit,
			COMBAT_RATING_NAME9, sCrit
		);
	elseif class == 'MAGE' then
		return string.format(
			"%s: %s%d%s, %s%d, %s%d, %s%d, %s%d%%, %s%.2f%%",
			CB_DATA.T_STAT,
			LEVEL, uLevel, locale_class,
			HEALTH, health,
			MANA, mana,
			STAT_SPELLPOWER, sp,
			COMBAT_RATING_NAME6, shit,
			COMBAT_RATING_NAME9, sCrit
		);
	elseif class == 'ROGUE' then
		return string.format(
			"%s: %s%d%s, %s%d, %s%d, %s%d%%, %s%.2f%%",
			CB_DATA.T_STAT,
			LEVEL, uLevel, locale_class,
			HEALTH, health,
			STAT_ATTACK_POWER, ap,
			COMBAT_RATING_NAME6, hit,
			COMBAT_RATING_NAME9, pCrit
		);
	elseif class == 'DRUID' then
		if set then
			return string.format(
				"%s: %s%d%s, %s%d, %s%d, %s%d, %s%d%%, %s%.2f%%, %s%d, %s%d%%, %s%.2f%%",
				CB_DATA.T_STAT,
				LEVEL, uLevel,locale_class,
				HEALTH, health,
				MANA, mana,
				STAT_SPELLPOWER, sp,
				COMBAT_RATING_NAME6, shit,
				COMBAT_RATING_NAME9, sCrit,
				STAT_ATTACK_POWER, ap,
				COMBAT_RATING_NAME6, hit,
				COMBAT_RATING_NAME9, pCrit
			);
		else
			local def = 0;
			for i = 1, GetNumSkillLines() do
				local name, header, _, rank, rankTemp, rankMod, rankMax = GetSkillLineInfo(i);
				if name == COMBAT_RATING_NAME2 then
					def = rank + rankTemp + rankMod;
					break;
				end
			end
			return string.format(
				"%s: %s%d%s, %s%d, %s%d, %s%d, %s%.2f%%, %s%d, %s%d, %s%.2f%%, %s%d, %s%d%%, %s%.2f%%, %s%d, %s%d%%, %s%.2f%%",
				CB_DATA.T_STAT,
				LEVEL, uLevel,locale_class,
				HEALTH, health,
				MANA, mana,
				STAT_SPELLHEALING, heal,
				COMBAT_RATING_NAME9, sCrit,
				COMBAT_RATING_NAME2, def,
				ARMOR, armor,
				COMBAT_RATING_NAME3, dChance,
				STAT_SPELLPOWER, sp,
				COMBAT_RATING_NAME6, shit,
				COMBAT_RATING_NAME9, sCrit,
				STAT_ATTACK_POWER, ap,
				COMBAT_RATING_NAME6, hit,
				COMBAT_RATING_NAME9, pCrit
			);
		end
	end
end
local function statReport_On()
	if control_statReport then
		return;
	end
	control_statReport = true;
	if btnStatReport then
		alaBaseBtn:AddBtn(3, -1, btnStatReport, true, false, true);
	else
		btnStatReport = alaBaseBtn:CreateBtn(
				3,
				-1,
				nil,
				"class",
				select(2, UnitClass('player')),
				nil,
				function(self, button)
					local editBox = ChatEdit_ChooseBoxForSend();
					editBox:Show();
					editBox:SetFocus();
					editBox:Insert(genReport(button == "RightButton"));
				end,
				{
					CB_DATA.LINE_STAT1,
					CB_DATA.LINE_STAT2,
					CB_DATA.LINE_STAT3,
				},
				nil,
				nil,
				nil
		);
	end
	return control_statReport;
end
local function statReport_Off()
	if not control_statReport then
		return;
	end
	control_statReport = false;
	alaBaseBtn:RemoveBtn(btnStatReport, true);
	return control_statReport;
end
FUNC.ON.statReport = statReport_On;
FUNC.OFF.statReport = statReport_Off;
----------------------------------------------------------------------------------------------------
