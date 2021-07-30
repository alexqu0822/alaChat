
local __addon, __private = ...;
local L = __private.L;

local TEXTURE_PATH = __private.TEXTURE_PATH;
local PIN_ORDER_OFFSET = 120;

local __utils = {  };
local _db = {  };

local __pins = {  };

-->		Method
	--	StatReprot
	local function GetTalentDesc()
		local n1, _, p1 = GetTalentTabInfo(1);
		local n2, _, p2 = GetTalentTabInfo(2);
		local n3, _, p3 = GetTalentTabInfo(3);
		if p1 == p2 or p2 == p3 or p1 == p3 then
			return TALENT .. " (" .. p1 .. "/" .. p2 .. "/" .. p3 .. ")";
		elseif p1 > p2 and p1 > p3 then
			return TALENT .. " " .. n1 .. "(" .. p1 .. "/" .. p2 .. "/" .. p3 .. ")";
		elseif p2 > p1 and p2 > p3 then
			return TALENT .. " " .. n2 .. "(" .. p1 .. "/" .. p2 .. "/" .. p3 .. ")";
		else
			return TALENT .. " " .. n3 .. "(" .. p1 .. "/" .. p2 .. "/" .. p3 .. ")";
		end
	end
	local method = {
		tank = function(prefix, suffix)
			local class, file = UnitClass('player');
			local health = UnitHealthMax('player');
			local mana = UnitPowerMax('player', 0);
			local _, armor = UnitArmor('player');
			local base, modifier = UnitDefense('player');
			local pChance = GetParryChance();
			local dChance = GetDodgeChance();
			local bChance = GetBlockChance();
			local block = GetShieldBlock();
			local expmh, expoh, expranged = GetExpertise();
			local expmhChance, expohChance = GetExpertisePercent();
			local hit = GetCombatRating(CR_HIT_MELEE);
			local hitChance = GetCombatRatingBonus(CR_HIT_MELEE);
			local resilience = GetCombatRating(CR_RESILIENCE_CRIT_TAKEN);
			local rChance = GetCombatRatingBonus(CR_RESILIENCE_CRIT_TAKEN);
			return (prefix == nil and "" or (prefix .. " "))
					.. class
					.. ", " .. LEVEL .. UnitLevel('player')
					.. ", " .. GetTalentDesc()
					.. ", " .. HEALTH.. " " .. health
						.. (mana == 0 and "" or (" " .. MANA.. ", " .. mana))
						.. ", " .. ARMOR.. " " .. armor
					.. ", " .. DEFENSE.. " " .. (base + modifier)
						.. ", " .. STAT_PARRY.. " " .. (pChance - pChance % 0.01) .. "%"
						.. ", " .. STAT_DODGE.. " " .. (dChance - dChance % 0.01) .. "%"
						.. ", " .. STAT_BLOCK.. " " .. (bChance - bChance % 0.01) .. "% (" .. block .. ")"
					.. ", " .. STAT_EXPERTISE.. " " .. expmh .. " (" .. (expmhChance - expmhChance % 0.01) .. "%)"
						.. ", " .. ITEM_MOD_HIT_RATING_SHORT.. " " .. hit .. " (" .. (hitChance - hitChance % 0.01) .. "%)"
					.. ", " .. STAT_RESILIENCE.. " " .. resilience .." (" .. min((rChance - rChance % 0.01) * 2, 25.00) .. "%)"
					.. (suffix == nil and "" or (", " .. suffix));
		end,
		melee = function(prefix, suffix)
			local class, file = UnitClass('player');
			local health = UnitHealthMax('player');
			local mana = UnitPowerMax('player', 0);
			local apBase, apPos, apNeg = UnitAttackPower('player');
			local crit = GetCombatRating(CR_CRIT_MELEE);
			local critChance = GetCritChance();
			local haste = GetCombatRating(CR_HASTE_MELEE);
			local hasteChance = GetCombatRatingBonus(CR_HASTE_MELEE);
			local hit = GetCombatRating(CR_HIT_MELEE);
			local hitChance = GetCombatRatingBonus(CR_HIT_MELEE);
			local expmh, expoh, expranged = GetExpertise();
			local expmhChance, expohChance = GetExpertisePercent();
			local pene = GetArmorPenetration()
			local resilience = GetCombatRating(CR_RESILIENCE_CRIT_TAKEN);
			local rChance = GetCombatRatingBonus(CR_RESILIENCE_CRIT_TAKEN);
			return (prefix == nil and "" or (prefix .. " "))
					.. class
					.. ", " .. LEVEL .. UnitLevel('player')
					.. ", " .. GetTalentDesc()
					.. ", " .. HEALTH.. " " .. health
						.. (mana == 0 and "" or (", " .. MANA.. " " .. mana))
					.. ", " .. ATTACK_POWER_TOOLTIP.. " " .. (apBase + apPos + apNeg)
						.. ", " .. STAT_CRITICAL_STRIKE.. " " .. crit .. " (" .. (critChance - critChance % 0.01) .. "%)"
						.. ", " .. STAT_HASTE.. " " .. haste .. " (" .. (hasteChance - hasteChance % 0.01) .. "%)"
						.. ", " .. ITEM_MOD_HIT_RATING_SHORT.. " " .. hit .. " (" .. (hitChance - hitChance % 0.01) .. "%)"
						.. ", " .. STAT_EXPERTISE.. " " .. expmh .. " (" .. (expmhChance - expmhChance % 0.01) .. "%)"
						.. ", " .. ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT.. " " .. pene
					.. ", " .. STAT_RESILIENCE.. " " .. resilience .." (" .. min((rChance - rChance % 0.01) * 2, 25.00) .. "%)"
					.. (suffix == nil and "" or (", " .. suffix));
		end,
		spell = function(prefix, suffix)
			local class, file = UnitClass('player');
			local health = UnitHealthMax('player');
			local mana = UnitPowerMax('player', 0);
			local sp = GetSpellBonusDamage(2);
			local msp, msch = sp, 2;
			for school = 3, MAX_SPELL_SCHOOLS do
				local s = GetSpellBonusDamage(school);
				sp = sp > s and s or sp;
				if msp < s then
					msp = s;
					msch = school;
				end
			end
			local crit = GetCombatRating(CR_CRIT_MELEE);
			local critChance = GetSpellCritChance(2);
			local mcc, mcsch = critChance, 2;
			for school = 3, MAX_SPELL_SCHOOLS do
				local ch = GetSpellCritChance(school);
				critChance = critChance > ch and ch or critChance;
				if mcc < ch then
					mcc = ch;
					mcsch = school;
				end
			end
			local haste = GetCombatRating(CR_HASTE_SPELL);
			local hasteChance = GetCombatRatingBonus(CR_HASTE_SPELL);
			local hit = GetCombatRating(CR_HIT_SPELL);
			local hitChance = GetCombatRatingBonus(CR_HIT_SPELL);
			local pene = GetSpellPenetration()
			local resilience = GetCombatRating(CR_RESILIENCE_CRIT_TAKEN);
			local rChance = GetCombatRatingBonus(CR_RESILIENCE_CRIT_TAKEN);
			return (prefix == nil and "" or (prefix .. " "))
					.. class
					.. ", " .. LEVEL .. UnitLevel('player')
					.. ", " .. GetTalentDesc()
					.. ", " .. HEALTH.. " " .. health
						.. (mana == 0 and "" or (", " .. MANA.. " " .. mana))
					.. ", " .. STAT_SPELLPOWER.. " " .. sp .. (sp == msp and "" or (" (" .. _G["DAMAGE_SCHOOL" .. msch] .. " " .. msp .. ")"))
						.. ", " .. STAT_CRITICAL_STRIKE.. " " .. crit .. " (" .. (critChance - critChance % 0.01) .. (critChance == mcc and "%" or ("% (" .. _G["DAMAGE_SCHOOL" .. mcsch] .. " " .. (mcc - mcc % 0.01) .. "%)")) .. ")"
						.. ", " .. STAT_HASTE.. " " .. haste .. " (" .. (hasteChance - hasteChance % 0.01) .. "%)"
						.. ", " .. ITEM_MOD_HIT_RATING_SHORT.. " " .. hit .. " (" .. (hitChance - hitChance % 0.01) .. "%)"
						.. ", " .. ITEM_MOD_SPELL_PENETRATION_SHORT.. " " .. pene
					.. ", " .. STAT_RESILIENCE.. " " .. resilience .." (" .. min((rChance - rChance % 0.01) * 2, 25.00) .. "%)"
					.. (suffix == nil and "" or (", " .. suffix));
		end,
		ranged = function(prefix, suffix)
			local class, file = UnitClass('player');
			local health = UnitHealthMax('player');
			local mana = UnitPowerMax('player', 0);
			local rapBase, rapPos, rapNeg = UnitRangedAttackPower('player');
			local crit = GetCombatRating(CR_CRIT_RANGED);
			local critChance = GetRangedCritChance();
			local haste = GetCombatRating(CR_HASTE_RANGED);
			local hasteChance = GetCombatRatingBonus(CR_HASTE_RANGED);
			local hit = GetCombatRating(CR_HIT_RANGED);
			local hitChance = GetCombatRatingBonus(CR_HIT_RANGED);
			local pene = GetArmorPenetration()
			local resilience = GetCombatRating(CR_RESILIENCE_CRIT_TAKEN);
			local rChance = GetCombatRatingBonus(CR_RESILIENCE_CRIT_TAKEN);
			return (prefix == nil and "" or (prefix .. " "))
					.. class
					.. ", " .. LEVEL .. UnitLevel('player')
					.. ", " .. GetTalentDesc()
					.. ", " .. HEALTH.. " " .. health
						.. (mana == 0 and "" or (", " .. MANA.. " " .. mana))
					.. ", " .. RANGED_ATTACK_POWER.. " " .. (rapBase + rapPos + rapNeg)
						.. ", " .. STAT_CRITICAL_STRIKE.. " " .. crit .. " (" .. (critChance - critChance % 0.01) .. "%)"
						.. ", " .. STAT_HASTE.. " " .. haste .. " (" .. (hasteChance - hasteChance % 0.01) .. "%)"
						.. ", " .. ITEM_MOD_HIT_RATING_SHORT.. " " .. hit .. " (" .. (hitChance - hitChance % 0.01) .. "%)"
						.. ", " .. ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT.. " " .. pene
					.. ", " .. STAT_RESILIENCE.. " " .. resilience .." (" .. min((rChance - rChance % 0.01) * 2, 25.00) .. "%)"
					.. (suffix == nil and "" or (", " .. suffix));
		end,
		heal = function(prefix, suffix)
			local class, file = UnitClass('player');
			local health = UnitHealthMax('player');
			local mana = UnitPowerMax('player', 0);
			local heal = GetSpellBonusHealing();
			local crit = GetCombatRating(CR_CRIT_MELEE);
			local critChance = GetCritChance();
			local haste = GetCombatRating(CR_HASTE_SPELL);
			local hasteChance = GetCombatRatingBonus(CR_HASTE_SPELL);
			local regen = GetManaRegen() * 5;
			local resilience = GetCombatRating(CR_RESILIENCE_CRIT_TAKEN);
			local rChance = GetCombatRatingBonus(CR_RESILIENCE_CRIT_TAKEN);
			return (prefix == nil and "" or (prefix .. " "))
					.. class
					.. ", " .. LEVEL .. UnitLevel('player')
					.. ", " .. GetTalentDesc()
					.. ", " .. HEALTH.. " " .. health
						.. (mana == 0 and "" or (", " .. MANA.. " " .. mana))
					.. ", " .. STAT_SPELLHEALING.. " " .. heal
						.. ", " .. STAT_CRITICAL_STRIKE.. " " .. crit .. " (" .. (critChance - critChance % 0.01) .. "%)"
						.. ", " .. STAT_HASTE.. " " .. haste .. " (" .. (hasteChance - hasteChance % 0.01) .. "%)"
						.. ", " .. MANA_REGEN.. " " .. (regen - regen % 1.0)
					.. ", " .. STAT_RESILIENCE.. " " .. resilience .." (" .. min((rChance - rChance % 0.01) * 2, 25.00) .. "%)"
					.. (suffix == nil and "" or (", " .. suffix));
		end,
		basic = function(prefix, suffix)
		end,
	};
	local DruidShapeFormID = {
		[1] = 768,		--	CAT
		[2] = 33891,	--	TREE
		--	3			--	TRAVEL
		--	4			--	AQUATIC
		[5] = 5487,		--	BEAR
		--	27			--	SWIFT
		--	29			--	FLIGHT
		[31] = 24858,	--	MOONKIN
	};
	local function GetReport(which)
		local class = UnitClassBase('player');
		if method[which] ~= nil then
			if class == "DRUID" then
			local id = GetShapeshiftFormID();
			local shape = id and DruidShapeFormID[id] and GetSpellInfo(DruidShapeFormID[id]);
				return method[which](shape and ("[" .. shape .. "]"));
			else
				return method[which]();
			end
		end
		if class == "WARRIOR" then
			local _, _, p1 = GetTalentTabInfo(1);
			local _, _, p2 = GetTalentTabInfo(2);
			local _, _, p3 = GetTalentTabInfo(3);
			if p3 >= p1 and p3 >= p2 then
				return method.tank();
			else
				return method.melee();
			end
		elseif class == "HUNTER" then
			return method.ranged();
		elseif class == "SHAMAN" then
			local _, _, p1 = GetTalentTabInfo(1);
			local _, _, p2 = GetTalentTabInfo(2);
			local _, _, p3 = GetTalentTabInfo(3);
			if p1 > p2 and p1 >= p3 then
				return method.spell();
			elseif p2 >= p1 and p2 >= p3 then
				return method.melee();
			else
				return method.heal();
			end
		elseif class == "ROGUE" then
			return method.melee();
		elseif class == "MAGE" then
			return method.spell();
		elseif class == "DRUID" then
			local id = GetShapeshiftFormID();
			local shape = id and DruidShapeFormID[id] and GetSpellInfo(DruidShapeFormID[id]);
			local _, _, p1 = GetTalentTabInfo(1);
			local _, _, p2 = GetTalentTabInfo(2);
			local _, _, p3 = GetTalentTabInfo(3);
			if p1 > p2 and p1 >= p3 then
				return method.spell(shape and ("[" .. shape .. "]"));
			elseif p2 >= p1 and p2 >= p3 then
				if id == 1 then
					return method.melee(shape and ("[" .. shape .. "]"));
				elseif id == 5 then
					return method.tank(shape and ("[" .. shape .. "]"));
				else
					print(L.STATREPORT.SHAPESHIFTFORMFIRST);
					return method.basic(shape and ("[" .. shape .. "]"));
				end
			else
				return method.heal(shape and ("[" .. shape .. "]"));
			end
		elseif class == "PALADIN" then
			local _, _, p1 = GetTalentTabInfo(1);
			local _, _, p2 = GetTalentTabInfo(2);
			local _, _, p3 = GetTalentTabInfo(3);
			if p1 >= p2 and p1 >= p3 then
				return method.heal();
			elseif p2 >= p1 and p2 >= p3 then
				return method.tank();
			else
				return method.melee();
			end
		elseif class == "PRIEST" then
			local _, _, p1 = GetTalentTabInfo(1);
			local _, _, p2 = GetTalentTabInfo(2);
			local _, _, p3 = GetTalentTabInfo(3);
			if p3 >= p1 and p3 >= p2 then
				return method.spell();
			else
				return method.heal();
			end
		elseif class == "WARLOCK" then
			return method.spell();
		end
	end
	--
-->

-->		GUI
	local SR_MENU = {
		handler = function(self, which)
			local editBox = ChatEdit_ChooseBoxForSend();
			if not editBox:HasFocus() then
				ChatEdit_ActivateChat(editBox);
			end
			editBox:Insert(GetReport(which));
		end,
		elements = {
			{
				text = L.STATREPORT["melee"],
				para = { "melee", },
			},
			{
				text = L.STATREPORT["spell"],
				para = { "spell", },
			},
			{
				text = L.STATREPORT["ranged"],
				para = { "ranged", },
			},
			{
				text = L.STATREPORT["tank"],
				para = { "tank", },
			},
			{
				text = L.STATREPORT["heal"],
				para = { "heal", },
			},
		},
	};
	local function SR_OnClick(Pin, button)
		if button == "RightButton" then
			ALADROP(Pin, "TOPRIGHT", SR_MENU, false);
		else
			local report = GetReport();
			if report ~= nil then
				local editBox = ChatEdit_ChooseBoxForSend();
				if not editBox:HasFocus() then
					ChatEdit_ActivateChat(editBox);
				end
				editBox:Insert(report);
			end
		end
	end
	local function DP_OnClick(Pin, button)
		if button == "LeftButton" then
			if SlashCmdList["DEADLYBOSSMODS"] then
				SlashCmdList["DEADLYBOSSMODS"]("pull" .. tostring(_db.DBMPullLen or 6));
			elseif SlashCmdList["DEADLYBOSSMODSPULL"] then
				SlashCmdList["DEADLYBOSSMODSPULL"](tostring(_db.DBMPullLen or 6));
			elseif SlashCmdList["BIGWIGSPULL"] then
				SlashCmdList["BIGWIGSPULL"](tostring(_db.DBMPullLen or 6));
			else
				DEFAULT_CHAT_FRAME:AddMessage("|cffFFFF88 DBM or BigWigs is off. |r", 1, 1, 0);
			end
		else
			if SlashCmdList["DEADLYBOSSMODS"] then
				SlashCmdList["DEADLYBOSSMODS"]("pull 0");
			elseif SlashCmdList["DEADLYBOSSMODSPULL"] then
				SlashCmdList["DEADLYBOSSMODSPULL"]("0");
			elseif SlashCmdList["BIGWIGSPULL"] then
				SlashCmdList["BIGWIGSPULL"]("0");
			end
		end
	end
	local function R_OnClick(Pin, button)
		RandomRoll(1, 100);
		GameTooltip:Hide();
	end
	local function RC_OnClick(Pin, button)
		DoReadyCheck();
	end
	local function CreatePins()
		local SR = __private.__docker:CreatePin(PIN_ORDER_OFFSET + 1);
		SR:SetNormalTexture([[Interface\TARGETINGFRAME\UI-CLASSES-CIRCLES]]);
		SR:SetPushedTexture([[Interface\TARGETINGFRAME\UI-CLASSES-CIRCLES]]);
		local coord = CLASS_ICON_TCOORDS[UnitClassBase('player')];
		SR:GetNormalTexture():SetTexCoord(coord[1], coord[2], coord[3], coord[4]);
		SR:GetPushedTexture():SetTexCoord(coord[1], coord[2], coord[3], coord[4]);
		SR:GetPushedTexture():SetVertexColor(0.5, 0.5, 0.5, 1.0);
		SR:SetScript("OnClick", SR_OnClick);
		SR:SetTip(L.TIP.StatReport, L.DETAILEDTIP.StatReport);
		if _db.StatReport then
			__private.__docker:ShowPin(SR);
		else
			__private.__docker:HidePin(SR);
		end
		__pins.StatReport = SR;
		local DP = __private.__docker:CreatePin(PIN_ORDER_OFFSET + 2);
		DP:SetNormalTexture(TEXTURE_PATH .. [[DBMPull_normal]]);
		DP:SetPushedTexture(TEXTURE_PATH .. [[DBMPull_pushed]]);
		DP:SetScript("OnClick", DP_OnClick);
		DP:SetTip(L.TIP.DBMPull, L.DETAILEDTIP.DBMPull);
		if _db.DBMPull then
			__private.__docker:ShowPin(DP);
		else
			__private.__docker:HidePin(DP);
		end
		__pins.DBMPull = DP;
		local R = __private.__docker:CreatePin(PIN_ORDER_OFFSET + 3);
		R:SetNormalTexture(TEXTURE_PATH .. [[roll_normal]]);
		R:SetPushedTexture(TEXTURE_PATH .. [[roll_pushed]]);
		R:SetScript("OnClick", R_OnClick);
		R:SetTip(L.TIP.roll, L.DETAILEDTIP.roll);
		if _db.roll then
			__private.__docker:ShowPin(R);
		else
			__private.__docker:HidePin(R);
		end
		__pins.roll = R;
		local RC = __private.__docker:CreatePin(PIN_ORDER_OFFSET + 4);
		RC.Text:SetText("C");
		RC:SetFontString(RC.Text);
		RC:SetPushedTextOffset(0, -1);
		RC:SetScript("OnClick", RC_OnClick);
		RC:SetTip(L.TIP.ReadyCheck, L.DETAILEDTIP.ReadyCheck);
		if _db.ReadyCheck then
			__private.__docker:ShowPin(RC);
		else
			__private.__docker:HidePin(RC);
		end
		__pins.ReadyCheck = RC;
	end
-->

-->		Init
	local B_Initialized = false;
	local function Init()
		B_Initialized = true;
		CreatePins();
	end
-->

-->		Module
	function __utils.StatReport(value, loading)
		if not loading then
			if value then
				__private.__docker:ShowPin(__pins["StatReport"]);
			else
				__private.__docker:HidePin(__pins["StatReport"]);
			end
		end
	end
	function __utils.DBMPull(value, loading)
		if not loading then
			if value then
				__private.__docker:ShowPin(__pins["DBMPull"]);
			else
				__private.__docker:HidePin(__pins["DBMPull"]);
			end
		end
	end
	function __utils.roll(value, loading)
		if not loading then
			if value then
				__private.__docker:ShowPin(__pins["roll"]);
			else
				__private.__docker:HidePin(__pins["roll"]);
			end
		end
	end
	function __utils.ReadyCheck(value, loading)
		if not loading then
			if value then
				__private.__docker:ShowPin(__pins["ReadyCheck"]);
			else
				__private.__docker:HidePin(__pins["ReadyCheck"]);
			end
		end
	end
	function __utils.__init(db, loading)
		_db = db;
		if not B_Initialized then
			Init();
		end
	end

	function __utils.__callback(which, value, loading)
		if __utils[which] ~= nil then
			return __utils[which](value, loading);
		end
	end
	function __utils.__setting()
		__private:AddSetting("UTILS", { "utils", "StatReport", 'boolean', });
		__private:AddSetting("UTILS", { "utils", "DBMPull", 'boolean', });
		__private:AddSetting("UTILS", { "utils", "DBMPullLen", 'number', { 3, 60, 1, }, nil, 0, }, 1);
		__private:AddSetting("UTILS", { "utils", "roll", 'boolean', });
		__private:AddSetting("UTILS", { "utils", "ReadyCheck", 'boolean', });
	end

	__private.__module["utils"] = __utils;
-->
--	state report

--	wel to guild

--	level

--	hyperlink (era)
--	shaman color (era)

--	scale, alpha, style
