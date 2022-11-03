--[=[
	SETTING
--]=]
local __ala_meta__ = _G.__ala_meta__;
local uireimp = __ala_meta__.uireimp;

local __addon, __private = ...;
local L = __private.L;

local pcall, xpcall, geterrorhandler = pcall, xpcall, geterrorhandler;
local setmetatable = setmetatable;
local type = type;
local next, unpack = next, unpack;
local gsub = string.gsub;
local tinsert = table.insert;
local min, max = math.min, math.max, math;
local CreateFrame = CreateFrame;
local UIParent = UIParent;
local _G = _G;

local TEXTURE_PATH = __private.TEXTURE_PATH;
local SettingUIColWidth = 180;
local SettingUILineHeight = 24;
local SettingUIFont = SystemFont_Shadow_Med1:GetFont();
local SettingUIFontSize = min(select(2, SystemFont_Shadow_Med1:GetFont()) + 1, 15);
local SettingUIHeadTexture = TEXTURE_PATH .. [[ArrowRight]];
local SettingUICheckNormalTexture = TEXTURE_PATH .. [[CheckButtonBorder]];
local SettingUICheckCheckedTexture = TEXTURE_PATH .. [[CheckButtonCenter]];

local __default = {  };
local __db = {  };
local __modulelist = nil;
local __module = nil;

--[=[
	meta = {
		1	module,
		2	key,
		3	type['boolean', 'number', 'editor', 'color', 'list' / 'input-list', 'raido'],
		4	extra	--	range{ min, step, max, } : number; tipkey : editor; list{} : list, radio; ,
		5	func(val),
		6	mod[nil, number, func],
		7	exhibit
	}
]=]
--
local SettingUI = nil;
local SettingUIInterfaceOptionsFrameContainer = nil;
local SettingUIFreeContainer = nil;
local _CategoryList = {  };
local _SettingList = {  };
local _SettingNodes = {  };

if __private.__is_dev then
	__private:BuildEnv("_Setting");
end

--
	local function SetDB(module, key, val, loading, extra)
		local meta = _SettingList[module][key];
		if meta ~= nil then
			if meta[6] ~= nil then
				val = meta[6](val);
			end
			if meta[5] ~= nil then
				meta[5](val);
			else
				__db[module][key] = val;
				__module:callback(module, key, val, loading);
			end
			return val;
		end
	end
-->	AddSetting
	local round_func_table = setmetatable({  }, {
		__index = function(t, key)
			if type(key) == 'number' and key % 1 == 0 then
				local dec = 0.1 ^ key;
				local func = function(val)
					val = val + dec * 0.5;
					return val - val % dec;
				end;
				t[key] = func;
				return func;
			end
		end,
	});
	local boolean_func = function(val)
		if val == false or val == "false" or val == 0 or val == "0" or val == nil or val == "off" or val == "disabled" then
			return false;
		else
			return true;
		end
	end
	function __private:AddSetting(category, meta, tab, col, icon)
		category = category or "GENERAL";
		meta.category = category;
		local module = meta[1];
		local key = meta[2];
		local Type = meta[3];
		_SettingList[module] = _SettingList[module] or {  };
		_SettingList[module][key] = meta;
		if Type == 'number' then
			local modfunc = meta[6];
			meta[6] = type(modfunc) == 'function' and modfunc or (type(modfunc) == 'number' and round_func_table[modfunc]) or nil;
		elseif Type == 'boolean' then
			meta[6] = meta[6] or boolean_func;
		end
		local CategoryTable = _CategoryList[category] or __private:CreateCategory(SettingUI, category);
		CategoryTable.Setting[#CategoryTable.Setting + 1] = meta;
		__private:CreateSetting(CategoryTable.Panel, module, key, Type, meta[4], meta[7], tab, col, icon);
	end
-->	Tab	<--
	local function Tab_OnClick(Tab)
		local SettingUI = __private.__SettingUI;
		local SelectedTab = SettingUI.SelectedTab;
		if SelectedTab ~= Tab then
			if SelectedTab ~= nil then
				SelectedTab.Sel:Hide();
				SelectedTab.Panel:Hide();
			end
			Tab.Sel:Show();
			Tab.Panel:Show();
			SettingUI.SelectedTab = Tab;
			SettingUI.Editor:Hide();
		end
	end
	function __private:CreateCategory(Parent, category)
		local Tab = CreateFrame('BUTTON', nil, Parent);
		local Panel = CreateFrame('FRAME', nil, Parent);
		Panel:SetPoint("BOTTOMLEFT", 6, 6);
		Panel:SetPoint("TOPRIGHT", -6, -32);
		Panel:Hide();
		Tab.Panel = Panel;
		Tab:SetSize(72, 24);
		local Text = Tab:CreateFontString(nil, "OVERLAY", "GameFontNormal");
		Text:SetPoint("CENTER");
		Tab.Text = Text;
		local Sel = Tab:CreateTexture(nil, "OVERLAY");
		Sel:SetAllPoints();
		Sel:SetBlendMode("ADD");
		Sel:SetColorTexture(0.25, 0.5, 0.5, 0.5);
		Sel:Hide();
		Tab.Sel = Sel;
		local NTex = Tab:CreateTexture(nil, "ARTWORK");
		Tab:SetNormalTexture(NTex);
		NTex:SetAllPoints();
		NTex:SetColorTexture(0.25, 0.25, 0.25, 0.5);
		local PTex = Tab:CreateTexture(nil, "ARTWORK");
		Tab:SetPushedTexture(PTex);
		PTex:SetAllPoints();
		PTex:SetColorTexture(0.15, 0.25, 0.25, 0.5);
		local HTex = Tab:CreateTexture(nil, "ARTWORK");
		Tab:SetHighlightTexture(HTex);
		HTex:SetAllPoints();
		HTex:SetColorTexture(0.25, 0.25, 0.25, 1.0);
		Tab:SetPoint("TOPLEFT", Parent, "TOPLEFT", 4 + 76 * #_CategoryList, -4);
		--
		_CategoryList[#_CategoryList + 1] = category;
		local CategoryTable = { Tab = Tab, Panel = Panel, Setting = {  }, };
		_CategoryList[category] = CategoryTable;
		Parent:SetWidth(min(max(Parent:GetWidth(), 4 + 76 * #_CategoryList), 1024));
		--
		Tab:SetScript("OnClick", Tab_OnClick);
		Panel.pos = { 0, 0, 0, 0, 0, 0, 0, 0, };
		Tab.Text:SetText(L.SETTINGCATEGORY[category] or category);
		return CategoryTable;
	end
-->	Setting Node	<--
	-->	node method
		--	number
		local function Slider_OnValueChanged(self, val, userInput)
			if userInput then
				val = SetDB(self.module, self.key, val, false);
				self:SetStr(val);
			end
		end
		--	boolean
		local function Check_OnClick(self, button)
			SetDB(self.module, self.key, self:GetChecked(), false);
		end
		--	editor
		local function EditorCallOutButton_OnClick(self)
			SettingUI.Editor.To = self;
			SettingUI.Editor:Show();
			SettingUI.EditorEditBox:SetText(__db[self.module][self.key]);
			SettingUI.EditorInformation:SetText(self.extra);
		end
		--	color
		local function ColorCallOutButton_OnClick(self)
			if ColorPickerFrame:IsShown() then
				ColorPickerFrame:Hide();
			else
				local module = self.module;
				local key = self.key;
				local orig = __db[module][key];
				ColorPickerFrame.func = nil;
				ColorPickerFrame.cancelFunc = nil;
				ColorPickerFrame:SetColorRGB(unpack(__db[module][key]));
				ColorPickerFrame.func = function()
					SetDB(module, key, { ColorPickerFrame:GetColorRGB() }, false);
				end
				ColorPickerFrame.cancelFunc = function()
					SetDB(module, key, orig, false);
				end
				ColorPickerFrame.opacityFunc = nil;
				ColorPickerFrame:ClearAllPoints();
				ColorPickerFrame:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 12, 12);
				ColorPickerFrame:Show();
			end
		end
		local function ColorPicker_Pick(module, key, value)
			SetDB(module, key, value, false);
		end
		--	list
		local function ListButton_Handler(self, module, key, val, drop, editbox)
			SetDB(module, key, val, false);
			drop:SetVal(val);
		end
		local function ListDrop_OnClick(self)
			if self.__list == nil then
				ALADROP(self, "BOTTOMLEFT", self.meta, false);
			else
				local meta = self.meta;
				local __list, __buttononshow, __buttononhide = self.__list();
				local __para = self.__para;
				local elements = meta.elements;
				wipe(elements);
				for name, val in next, __list do
					elements[#elements + 1] = {
						text = name,
						para = { __para[1], __para[2], val, __para[4], };
					};
				end
				meta.__buttononshow = __buttononshow;
				meta.__buttononhide = __buttononhide;
				ALADROP(self, "BOTTOMLEFT", meta, false);
			end
		end
		local function InputListEditBox_OnEnterPressed(self)
			local value = self:GetText();
			local valid, err = pcall(date, value);
			if valid then
				SetDB(self.module, self.key, value, false);
				self.parent:SetVal(__db[self.module][self.key]);
				self:ClearFocus();
				self.okay:Hide();
				self.discard:Hide();
			else
				self.err:SetText(err);
				self.err:SetVertexColor(1.0, 0.0, 0.0, 1.0);
			end
		end
		local function InputListEditBox_OnEscapePressed(self)
			self:ClearFocus();
			self.okay:Hide();
			self.discard:Hide();
			self.parent:SetVal(__db[self.module][self.key]);
		end
		local function InputListEditBox_OnTextChanged(self, userInput)
			if userInput then
				self.okay:Show();
				self.discard:Show();
				self.err:SetText("");
			end
		end
		local function InputListEditBoxOkay_OnClick(self)
			InputListEditBox_OnEnterPressed(self.editbox);
		end
		local function InputListEditBoxDiscard_OnClick(self)
			InputListEditBox_OnEscapePressed(self.editbox);
		end
		--	radio
		local function ListCheck_OnClick(self, button)
			SetDB(self.module, self.key, self.val, false);
		end
	-->
		local function SetButtonColorTexture(button)
			local NT = button:CreateTexture(nil, "ARTWORK");
			local PT = button:CreateTexture(nil, "ARTWORK");
			local HT = button:CreateTexture(nil, "HIGHLIGHT");
			NT:SetAllPoints();
			PT:SetAllPoints();
			HT:SetAllPoints();
			button:SetNormalTexture(NT);
			button:SetPushedTexture(PT);
			button:SetHighlightTexture(HT);
			NT:SetColorTexture(0.25, 0.25, 0.25, 0.75);
			PT:SetColorTexture(0.25, 0.5, 0.75, 0.75);
			HT:SetColorTexture(0.0, 0.25, 0.5, 0.5);
			HT:SetBlendMode("ADD");
		end
		local function SetCheckButtonTexture(check)
			check:SetNormalTexture(SettingUICheckNormalTexture);
			check:SetPushedTexture(SettingUICheckCheckedTexture);
			check:SetHighlightTexture(SettingUICheckNormalTexture);
			check:SetCheckedTexture(SettingUICheckCheckedTexture);
			check:GetNormalTexture():SetVertexColor(1.0, 1.0, 1.0, 0.5);
			check:GetPushedTexture():SetVertexColor(1.0, 1.0, 1.0, 0.25);
			check:GetHighlightTexture():SetVertexColor(1.0, 1.0, 1.0, 0.5);
			check:GetCheckedTexture():SetVertexColor(0.0, 0.5, 1.0, 0.75);
		end
	-->
	function __private:CreateSetting(Panel, module, key, Type, extra, exhibit, tab, col, icon)
		tab = tab or 0;
		col = col or 1;
		local LSETTINGMODULE = L.SETTING[module];
		_SettingNodes[module] = _SettingNodes[module] or {  };
		local anchor = nil;
		if Type == 'number' then
			local head = Panel:CreateTexture(nil, "ARTWORK");
			head:SetSize(16, 10);
			head:SetTexture(SettingUIHeadTexture);
			head:SetVertexColor(0.5, 0.75, 1.0, 0.5);
			local label = Panel:CreateFontString(nil, "ARTWORK");
			label:SetFont(SettingUIFont, SettingUIFontSize, "");
			label:SetText(gsub(LSETTINGMODULE[key], "%%[a-z]", ""));
			label:SetPoint("LEFT", head, "CENTER", 16, 0);
			local slider = CreateFrame('SLIDER', nil, Panel);
			slider:SetWidth(160);
			slider:SetHeight(15);
			slider:SetOrientation("HORIZONTAL");
			slider:SetMinMaxValues(extra[1], extra[2]);
			slider:SetValueStep(extra[3]);
			slider:SetObeyStepOnDrag(true);
			slider:SetPoint("LEFT", head, "CENTER", 16, -SettingUILineHeight * 0.75);
			slider:SetThumbTexture([[Interface\Buttons\UI-ScrollBar-Knob]]);
			slider.Thumb = slider:GetThumbTexture();
			slider.Thumb:Show();
			slider.Thumb:SetSize(2, 7);
			slider.Thumb:SetColorTexture(1.0, 1.0, 1.0, 1.0);
			slider.Track = slider:CreateTexture(nil, "BACKGROUND");
			slider.Track:SetHeight(1);
			slider.Track:SetPoint("LEFT");
			slider.Track:SetPoint("RIGHT");
			slider.Track:SetColorTexture(1.0, 1.0, 1.0, 0.25);
			slider.Text = slider:CreateFontString(nil, "ARTWORK");
			slider.Text:SetFont(SettingUIFont, SettingUIFontSize - 1, "");
			slider.Text:ClearAllPoints();
			slider.Text:SetPoint("TOP", slider, "BOTTOM", 0, 6);
			slider.Text:SetAlpha(0.75);
			slider.Low = slider:CreateFontString(nil, "ARTWORK");
			slider.Low:SetFont(SettingUIFont, SettingUIFontSize - 1, "");
			slider.Low:ClearAllPoints();
			slider.Low:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 4, 6);
			slider.Low:SetVertexColor(0.5, 1.0, 0.5);
			slider.Low:SetAlpha(0.75);
			slider.Low:SetText(extra[1]);
			slider.High = slider:CreateFontString(nil, "ARTWORK");
			slider.High:SetFont(SettingUIFont, SettingUIFontSize - 1, "");
			slider.High:ClearAllPoints();
			slider.High:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", -4, 6);
			slider.High:SetVertexColor(1.0, 0.5, 0.5);
			slider.High:SetAlpha(0.75);
			slider.High:SetText(extra[2]);
			slider.module = module;
			slider.key = key;
			slider.head = head;
			slider.label = label;
			slider:SetScript("OnValueChanged", Slider_OnValueChanged);
			function slider:SetVal(val)
				self:SetValue(val);
				self:SetStr(val);
			end
			local def = __default[module][key];
			function slider:SetStr(val)
				self.Text:SetText(val);
				local diff = val - def;
				if diff > 0.0000001 then
					self.Text:SetVertexColor(1.0, 0.25, 0.25);
				elseif diff < -0.0000001 then
					self.Text:SetVertexColor(0.25, 1.0, 0.25);
				else
					self.Text:SetVertexColor(1.0, 1.0, 1.0);
				end
			end
			slider._SetPoint = slider.SetPoint;
			function slider:SetPoint(...)
				self.head:SetPoint(...);
			end
			_SettingNodes[module][key] = slider;
			head:SetPoint("CENTER", Panel, "TOPLEFT", 32 + tab * SettingUILineHeight + (col - 1) * SettingUIColWidth, -22 - Panel.pos[col] * SettingUILineHeight);
			Panel.pos[col] = Panel.pos[col] + 2;
			anchor = head;
		elseif Type == 'boolean' then
			local check = CreateFrame('CHECKBUTTON', nil, Panel);
			check:SetSize(16, 16);
			check:SetHitRectInsets(0, 0, 0, 0);
			check:Show();
			SetCheckButtonTexture(check);
			check.module = module;
			check.key = key;
			check:SetScript("OnClick", Check_OnClick);
			function check:SetVal(val)
				self:SetChecked(val);
			end
			local label = Panel:CreateFontString(nil, "ARTWORK");
			label:SetFont(SettingUIFont, SettingUIFontSize, "");
			label:SetText(gsub(LSETTINGMODULE[key], "%%[a-z]", ""));
			label:SetPoint("LEFT", check, "CENTER", 16, 0);
			_SettingNodes[module][key] = check;
			check:SetPoint("CENTER", Panel, "TOPLEFT", 32 + tab * SettingUILineHeight + (col - 1) * SettingUIColWidth, -22 - Panel.pos[col] * SettingUILineHeight);
			Panel.pos[col] = Panel.pos[col] + 1;
			anchor = check;
		elseif Type == 'editor' then
			local head = Panel:CreateTexture(nil, "ARTWORK");
			head:SetSize(16, 10);
			head:SetTexture(SettingUIHeadTexture);
			head:SetVertexColor(0.5, 0.75, 1.0, 0.5);
			local button = CreateFrame('BUTTON', nil, Panel);
			button:SetSize(128, 16);
			button:SetPoint("LEFT", head, "CENTER", 16, 0);
			SetButtonColorTexture(button);
			button.module = module;
			button.key = key;
			button.extra = LSETTINGMODULE[extra] or extra;
			button:SetScript("OnClick", EditorCallOutButton_OnClick);
			local str = button:CreateFontString(nil, "ARTWORK");
			str:SetFont(SettingUIFont, SettingUIFontSize, "");
			str:SetPoint("CENTER");
			str:SetText(gsub(LSETTINGMODULE[key], "%%[a-z]", ""));
			button._SetPoint = button.SetPoint;
			function button:SetPoint(...)
				self.head:SetPoint(...);
			end
			button.__indirect = true;
			_SettingNodes[module][key] = button;
			head:SetPoint("CENTER", Panel, "TOPLEFT", 32 + tab * SettingUILineHeight + (col - 1) * SettingUIColWidth, -22 - Panel.pos[col] * SettingUILineHeight);
			Panel.pos[col] = Panel.pos[col] + 1;
			anchor = head;
		elseif Type == 'color' then
			local head = Panel:CreateTexture(nil, "ARTWORK");
			head:SetSize(16, 10);
			head:SetTexture(SettingUIHeadTexture);
			head:SetVertexColor(0.5, 0.75, 1.0, 0.5);
			local button = CreateFrame('BUTTON', nil, Panel);
			button:SetSize(128, 16);
			button:SetPoint("LEFT", head, "CENTER", 16, 0);
			SetButtonColorTexture(button);
			button.module = module;
			button.key = key;
			button:SetScript("OnClick", ColorCallOutButton_OnClick);
			local str = button:CreateFontString(nil, "ARTWORK");
			str:SetFont(SettingUIFont, SettingUIFontSize, "");
			str:SetPoint("CENTER");
			str:SetText(gsub(LSETTINGMODULE[key], "%%[a-z]", ""));
			button._SetPoint = button.SetPoint;
			function button:SetPoint(...)
				self.head:SetPoint(...);
			end
			button.__indirect = true;
			_SettingNodes[module][key] = button;
			head:SetPoint("CENTER", Panel, "TOPLEFT", 32 + tab * SettingUILineHeight + (col - 1) * SettingUIColWidth, -22 - Panel.pos[col] * SettingUILineHeight);
			Panel.pos[col] = Panel.pos[col] + 1;
			anchor = head;
		elseif Type == 'list' or Type == 'input-list' then
			local head = Panel:CreateTexture(nil, "ARTWORK");
			head:SetSize(16, 10);
			head:SetTexture(SettingUIHeadTexture);
			head:SetVertexColor(0.5, 0.75, 1.0, 0.5);
			local label = Panel:CreateFontString(nil, "ARTWORK");
			label:SetFont(SettingUIFont, SettingUIFontSize, "");
			label:SetText(gsub(LSETTINGMODULE[key], "%%[a-z]", ""));
			label:SetPoint("LEFT", head, "CENTER", 16, 0);
			local drop = CreateFrame('BUTTON', nil, Panel);
			drop:SetSize(12, 12);
			drop:SetPoint("LEFT", head, "CENTER", 16, -SettingUILineHeight);
			drop:SetNormalTexture(TEXTURE_PATH .. "ArrowDown");
			drop:SetPushedTexture(TEXTURE_PATH .. "ArrowDown");
			drop:GetPushedTexture():SetVertexColor(0.5, 0.5, 0.5, 1.0);
			drop:SetHighlightTexture(TEXTURE_PATH .. "ArrowDown");
			drop:GetHighlightTexture():SetVertexColor(0.0, 0.5, 1.0, 0.25);
			local elements = {  };
			if type(extra) == 'table' then
				for index = 1, #extra do
					elements[index] = {
						text = LSETTINGMODULE[extra[index]] or extra[index];
						para = { module, key, extra[index], drop, };
					};
				end
			elseif type(extra) == 'function' then
				drop.__list = extra;
				drop.__para = { module, key, nil, drop, };
				extra();
			end
			drop.meta = {
				handler = ListButton_Handler,
				elements = elements,
			}
			drop:SetScript("OnClick", ListDrop_OnClick);
			local editbox = CreateFrame('EDITBOX', nil, Panel);
			editbox:SetSize(160, 20);
			editbox:SetFont(SettingUIFont, SettingUIFontSize, "");
			editbox:SetPoint("LEFT", drop, "RIGHT", 2, 0);
			editbox:SetAutoFocus(false);
			editbox:SetTextInsets(10, 0, 0, 0);
			editbox.parent = drop;
			if Type == 'input-list' then
				if exhibit ~= nil then
					function drop:SetVal(val)
						editbox:SetText(val);
						editbox.err:SetText(LSETTINGMODULE[val] or exhibit(val) or val);
						editbox.err:SetVertexColor(1.0, 1.0, 1.0, 1.0);
					end
				else
					function drop:SetVal(val)
						editbox:SetText(val);
						editbox.err:SetText(LSETTINGMODULE[val] or val);
						editbox.err:SetVertexColor(1.0, 1.0, 1.0, 1.0);
					end
				end
				uireimp._SetSimpleBackdrop(editbox, 0, 1, 0.25, 0.25, 0.25, 1.0, 1.0, 1.0, 1.0, 0.125);
				-- elements[#elements + 1] = {
				-- 	text = "",
				-- 	para = { module, key, nil, drop, editbox, },
				-- };
				local okay = CreateFrame('BUTTON', nil, editbox);
				okay:SetSize(16, 16);
				okay:SetPoint("LEFT", editbox, "RIGHT", 2, 0);
				okay:SetNormalTexture(TEXTURE_PATH .. [[opt-okay]]);
				okay:GetNormalTexture():SetVertexColor(0.75, 0.75, 0.75, 1.0);
				okay:SetPushedTexture(TEXTURE_PATH .. [[opt-okay]]);
				okay:GetPushedTexture():SetVertexColor(0.5, 0.5, 0.5, 0.5);
				okay:SetHighlightTexture(TEXTURE_PATH .. [[opt-okay]]);
				okay:GetHighlightTexture():SetVertexColor(0.5, 0.5, 0.5, 0.5);
				okay:Hide();
				okay:SetScript("OnClick", InputListEditBoxOkay_OnClick);
				editbox.okay = okay;
				okay.editbox = editbox;
				local discard = CreateFrame('BUTTON', nil, editbox);
				discard:SetSize(16, 16);
				discard:SetPoint("LEFT", okay, "RIGHT", 2, 0);
				discard:SetNormalTexture(TEXTURE_PATH .. [[opt-discard]]);
				discard:GetNormalTexture():SetVertexColor(0.75, 0.75, 0.75, 1.0);
				discard:SetPushedTexture(TEXTURE_PATH .. [[opt-discard]]);
				discard:GetPushedTexture():SetVertexColor(0.5, 0.5, 0.5, 0.5);
				discard:SetHighlightTexture(TEXTURE_PATH .. [[opt-discard]]);
				discard:GetHighlightTexture():SetVertexColor(0.5, 0.5, 0.5, 0.5);
				discard:Hide();
				discard:SetScript("OnClick", InputListEditBoxDiscard_OnClick);
				editbox.discard = discard;
				discard.editbox = editbox;
				local err = editbox:CreateFontString(nil, "ARTWORK");
				err:SetFont(SettingUIFont, SettingUIFontSize, "");
				err:SetPoint("LEFT", editbox, "BOTTOMLEFT", 0, -SettingUILineHeight * 0.5);
				err:Show();
				editbox.err = err;
				editbox.module = module;
				editbox.key = key;
				editbox:SetScript("OnEnterPressed", InputListEditBox_OnEnterPressed);
				editbox:SetScript("OnEscapePressed", InputListEditBox_OnEscapePressed);
				editbox:SetScript("OnTextChanged", InputListEditBox_OnTextChanged);
			else
				if exhibit ~= nil then
					function drop:SetVal(val)
						editbox:SetText(LSETTINGMODULE[val] or exhibit(val) or val);
					end
				else
					function drop:SetVal(val)
						editbox:SetText(LSETTINGMODULE[val] or val);
					end
				end
				uireimp._SetSimpleBackdrop(editbox, 0, 1, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.25);
				editbox:Disable();
			end
			drop._SetPoint = drop.SetPoint;
			function drop:SetPoint(...)
				self.head:SetPoint(...);
			end
			_SettingNodes[module][key] = drop;
			head:SetPoint("CENTER", Panel, "TOPLEFT", 32 + tab * SettingUILineHeight + (col - 1) * SettingUIColWidth, -22 - Panel.pos[col] * SettingUILineHeight);
			Panel.pos[col] = Panel.pos[col] + (Type == 'input-list' and 3 or 2);
			anchor = head;
		elseif Type == 'radio' then
			local head = Panel:CreateTexture(nil, "ARTWORK");
			head:SetSize(16, 10);
			head:SetTexture(SettingUIHeadTexture);
			head:SetVertexColor(0.5, 0.75, 1.0, 0.5);
			local label = Panel:CreateFontString(nil, "ARTWORK");
			label:SetFont(SettingUIFont, SettingUIFontSize, "");
			label:SetText(gsub(LSETTINGMODULE[key], "%%[a-z]", ""));
			label:SetPoint("LEFT", head, "CENTER", 16, 0);
			local list = {  };
			for index, val in next, extra do
				local check = CreateFrame('CHECKBUTTON', nil, Panel);
				check:SetSize(16, 16);
				check:SetPoint("TOPLEFT", head, "CENTER", 18 + (index - 1) * 80, -SettingUILineHeight * 1.5);
				check:SetHitRectInsets(0, 0, 0, 0);
				check:Show();
				SetCheckButtonTexture(check);
				check.module = module;
				check.key = key;
				check:SetScript("OnClick", ListCheck_OnClick);
				check.list = list;
				check.index = index;
				check.val = val;
				list[index] = check;
				local text = Panel:CreateFontString(nil, "ARTWORK");
				text:SetFont(SettingUIFont, SettingUIFontSize, "");
				text:SetText(val);
				text:SetPoint("LEFT", check, "RIGHT", 2, 0);
				check.text = text;
			end
			function list:SetVal(val)
				for index, v in next, extra do
					list[index]:SetChecked(v == val);
				end
			end
			list._SetPoint = list.SetPoint;
			function list:SetPoint(...)
				self.head:SetPoint(...);
			end
			list.__indirect = false;
			_SettingNodes[module][key] = list;
			head:SetPoint("CENTER", Panel, "TOPLEFT", 32 + tab * SettingUILineHeight + (col - 1) * SettingUIColWidth, -22 - Panel.pos[col] * SettingUILineHeight);
			Panel.pos[col] = Panel.pos[col] + 2;
			anchor = head;
		else
			return;
		end
		SettingUI:SetHeight(min(max(SettingUI:GetHeight(), 32 + 12 + Panel.pos[col] * SettingUILineHeight + 12 + 6), 1024));
		if icon ~= nil then
			local i = Panel:CreateTexture(nil, "ARTWORK");
			i:SetSize(20, 20);
			i:SetPoint("RIGHT", anchor, "CENTER", -12, 0);
			if type(icon) == 'table' then
				if icon[1] ~= nil then
					i:SetTexture(icon[1]);
					if icon[2] ~= nil then
						i:SetTexCoord(unpack(icon[2]));
					end
					if icon[3] ~= nil then
						i:SetVertexColor(unpack(icon[3]));
					end
				elseif icon[3] ~= nil then
					i:SetColorTexture(unpack(icon[3]));
				end
			else
				i:SetTexture(icon);
			end
		end
	end
	function __private:AlignSetting(category, ofs)
		local CategoryTable = _CategoryList[category];
		if CategoryTable ~= nil then
			local pos = CategoryTable.Panel.pos;
			local val = 0;
			for index = 1, 8 do
				local v = pos[index];
				if v > val then
					val = v;
				end
			end
			val = val + (ofs or 0);
			for index = 1, 8 do
				pos[index] = val;
			end
		end
	end
-->	SettingUI	<--
	local function SettingUIOnShow()
		for module, nodes in next, _SettingNodes do
			for key, node in next, nodes do
				if node.__indirect ~= true then
					node:SetVal(__db[module] ~= nil and __db[module][key]);
				end
			end
		end
	end
	local function CreateEditor(SettingUI)
		local _Editor = CreateFrame('FRAME', nil, SettingUI);
		_Editor:SetFrameLevel(SettingUI:GetFrameLevel() + 63);
		_Editor:SetPoint("BOTTOMLEFT", 0, 0);
		_Editor:SetPoint("TOPRIGHT", 0, -32);
		local EBG = _Editor:CreateTexture(nil, "BACKGROUND");
		EBG:SetAllPoints();
		EBG:SetColorTexture(0.0, 0.0, 0.0, 1.0);
		_Editor.BG = EBG;
		--
		local _EditorScrollFrame = CreateFrame('SCROLLFRAME', nil, _Editor);
		_EditorScrollFrame:SetPoint("BOTTOMLEFT", 0, 32);
		_EditorScrollFrame:SetPoint("TOPRIGHT", -20, -72);
		local ESBG = _EditorScrollFrame:CreateTexture(nil, "BACKGROUND");
		ESBG:SetAllPoints();
		ESBG:SetColorTexture(0.25, 0.25, 0.25, 0.5);
		_EditorScrollFrame.BG = ESBG;
		--
		local _EditorScrollBar = CreateFrame('SLIDER', nil, _Editor);
		_EditorScrollBar:SetWidth(12);
		_EditorScrollBar:SetPoint("BOTTOMRIGHT", -4, 46);
		_EditorScrollBar:SetPoint("TOPRIGHT", -4, -78);
		_EditorScrollBar:SetOrientation("VERTICAL");
		_EditorScrollBar:EnableMouse(true);
		_EditorScrollBar:SetThumbTexture([[Interface\Buttons\UI-ScrollBar-Knob]]);
			local _Thumb = _EditorScrollBar:GetThumbTexture();
			_Thumb:Show();
			_Thumb:SetColorTexture(0.0, 1.0, 0.0, 1.0);
			local _TrackSmallerValue = _EditorScrollBar:CreateTexture(nil, "ARTWORK");
			_TrackSmallerValue:Show();
			_TrackSmallerValue:SetColorTexture(0.0, 1.0, 0.0, 1.0);
			_EditorScrollBar._TrackSmallerValue = _TrackSmallerValue;
			local _TrackLargerValue = _EditorScrollBar:CreateTexture(nil, "ARTWORK");
			_TrackLargerValue:Show();
			_TrackLargerValue:SetColorTexture(1.0, 1.0, 1.0, 1.0);
			_EditorScrollBar._TrackLargerValue = _TrackLargerValue;
			_Thumb:SetSize(2, 1);
			_TrackSmallerValue:SetWidth(2);
			_TrackSmallerValue:ClearAllPoints();
			_TrackSmallerValue:SetPoint("TOP");
			_TrackSmallerValue:SetPoint("BOTTOM", _Thumb, "TOP");
			_TrackLargerValue:SetWidth(2);
			_TrackLargerValue:ClearAllPoints();
			_TrackLargerValue:SetPoint("BOTTOM");
			_TrackLargerValue:SetPoint("TOP", _Thumb, "BOTTOM");
		_EditorScrollBar:SetMinMaxValues(0, 0);
		--
		local _EditorEditBox = CreateFrame('EDITBOX', nil, _EditorScrollFrame);
		_EditorEditBox:SetPoint("LEFT", 0, 0);
		-- _EditorEditBox:SetPoint("RIGHT", 0, 0);
		_EditorEditBox:SetFont(SettingUIFont, SettingUIFontSize, "");
		_EditorEditBox:SetJustifyH("LEFT");
		_EditorEditBox:SetTextColor(1.0, 1.0, 1.0, 1.0);
		_EditorEditBox:SetMultiLine(true);
		_EditorEditBox:SetAutoFocus(false);
		_EditorEditBox:SetTextInsets(5, 5, 5, 5);
		_EditorScrollFrame:SetScrollChild(_EditorEditBox);
		--
		local _EditorSaveValue = CreateFrame('BUTTON', nil, _Editor);
		_EditorSaveValue:SetSize(48, 20);
		SetButtonColorTexture(_EditorSaveValue);
		_EditorSaveValue:SetPoint("CENTER", _Editor, "BOTTOM", -48, 16);
		local _EditorSaveValueStr = _EditorSaveValue:CreateFontString(nil, "ARTWORK");
		_EditorSaveValueStr:SetFont(SettingUIFont, SettingUIFontSize, "");
		_EditorSaveValueStr:SetPoint("CENTER");
		-- _EditorSaveValueStr:SetTextColor(0.5, 1.0, 0.5);
		_EditorSaveValueStr:SetText(OKAY or "OKAY");
		local _EditorCancel = CreateFrame('BUTTON', nil, _Editor);
		_EditorCancel:SetSize(48, 20);
		SetButtonColorTexture(_EditorCancel);
		_EditorCancel:SetPoint("CENTER", _Editor, "BOTTOM", 48, 16);
		local _EditorCancelStr = _EditorCancel:CreateFontString(nil, "ARTWORK");
		_EditorCancelStr:SetFont(SettingUIFont, SettingUIFontSize, "");
		_EditorCancelStr:SetPoint("CENTER");
		-- _EditorCancelStr:SetTextColor(1.0, 0.5, 0.5);
		_EditorCancelStr:SetText(CANCEL or "CANCEL");
		local _Information = _Editor:CreateFontString(nil, "ARTWORK");
		_Information:SetFont(SettingUIFont, SettingUIFontSize, "");
		_Information:SetPoint("LEFT", _Editor, "TOPLEFT", 4, -36);
		_Information:SetPoint("RIGHT", _Editor, "TOPRIGHT", -4, -36);
		--	Editor Script
			_EditorSaveValue:SetScript("OnClick", function()
				local To = _Editor.To;
				SetDB(To.module, To.key, _EditorEditBox:GetText(), false);
				_Editor:Hide();
			end);
			_EditorCancel:SetScript("OnClick", function() _Editor:Hide(); end);
		--	Scroll Script
			local __val = 0;
			local __stepSize = 20;
			_Editor:SetScript("OnShow", function() _EditorScrollBar:SetValue(0); end);
			_EditorScrollFrame:SetScript("OnSizeChanged", function() _EditorEditBox:SetWidth(_Editor:GetWidth() - 24); end);
			_EditorScrollFrame:SetScript("OnScrollRangeChanged", function(self, xrange, yrange)
				_EditorScrollBar:SetMinMaxValues(0, yrange);
				if yrange + 0.5 < __val then
					_EditorScrollBar:SetValue(yrange);
				end
			end);
			_EditorScrollFrame:SetScript("OnMouseDown", function(self) _EditorEditBox:SetFocus(); end);
			_EditorScrollFrame:SetScript("OnMouseWheel", function(self, delta)
				local _min, _max = _EditorScrollBar:GetMinMaxValues();
				local _val = __val - delta * __stepSize;
				if _val > _max then
					_val = _max;
				elseif _val < _min then
					_val = _min;
				end
				_EditorScrollBar:SetValue(_val);
			end);
			_EditorScrollBar:SetScript("OnValueChanged", function(self, value)
				_EditorScrollFrame:SetVerticalScroll(value);
				__val = value;
			end);
			_EditorScrollBar:SetScript("OnMouseWheel", function(self, delta)
				local _min, _max = self:GetMinMaxValues();
				local _val = __val - delta * __stepSize;
				if _val > _max then
					_val = _max;
				elseif _val < _min then
					_val = _min;
				end
				self:SetValue(_val);
			end);
			-- _EditorEditBox:SetScript("OnTextChanged", nil);
			_EditorEditBox:SetScript("OnEscapePressed", _EditorEditBox.ClearFocus);
			_EditorEditBox:SetScript("OnCursorChanged", function(self, x, y, w, h)
				local _min, _max = _EditorScrollBar:GetMinMaxValues();
				if _max > 0 then
					local _Height = _EditorScrollFrame:GetHeight();
					local _minPos = -y - _Height;
					if _Height > h then
						local _maxPos = _minPos + h;
						local _minRange = __val - _Height;
						local _maxRange = __val;
						--
						if _minPos < _minRange then
							_EditorScrollBar:SetValue(_minRange);
						elseif _maxPos > _maxRange then
							_EditorScrollBar:SetValue(_maxPos);
						end
					else
						_EditorScrollBar:SetValue(_minPos);
					end
				end
			end);
		--
		_Editor._Information = _Information;
		_Editor._SaveValue = _EditorSaveValue;
		_Editor._Cancel = _EditorCancel;
		_Editor._ScrollFrame = _EditorScrollFrame;
		_Editor._ScrollBar = _EditorScrollBar;
		_Editor._EditorEditBox = _EditorEditBox;
		SettingUI.Editor = _Editor;
		SettingUI.EditorInformation = _Information;
		SettingUI.EditorEditBox = _EditorEditBox;
		_Editor:Hide();
	end
	local function CreateSettingUI()
		SettingUI = CreateFrame('FRAME', nil, UIParent);
		SettingUI:SetFrameStrata("DIALOG");
		SettingUI:SetScript("OnShow", SettingUIOnShow);
		SettingUI:Hide();
		CreateEditor(SettingUI);
		__private.__SettingUI = SettingUI;
		__private:CreateCategory(SettingUI, "GENERAL").Tab:Click();
		--
		SettingUIFreeContainer = CreateFrame('FRAME', "ALACHAT_SETTING_UI_C", UIParent);
		SettingUIFreeContainer:Hide();
		SettingUIFreeContainer:SetFrameStrata("DIALOG");
		SettingUIFreeContainer:SetPoint("CENTER");
		SettingUIFreeContainer:EnableMouse(true);
		SettingUIFreeContainer:SetMovable(true);
		SettingUIFreeContainer:RegisterForDrag("LeftButton");
		SettingUIFreeContainer:SetScript("OnDragStart", function(self)
			self:StartMoving();
		end);
		SettingUIFreeContainer:SetScript("OnDragStop", function(self)
			self:StopMovingOrSizing();
		end);
		SettingUIFreeContainer:SetScript("OnShow", function(self)
			SettingUIInterfaceOptionsFrameContainer:Hide();
			self:SetSize(SettingUI:GetWidth(), SettingUI:GetHeight() + 24);
			SettingUI:Show();
			SettingUI:ClearAllPoints();
			SettingUI:SetPoint("BOTTOM", self, "BOTTOM");
			SettingUI.Container = self;
		end);
		SettingUIFreeContainer:SetScript("OnHide", function()
			if not SettingUIInterfaceOptionsFrameContainer:IsShown() then
				SettingUI:Hide();
				SettingUI:ClearAllPoints();
			end
		end);
		tinsert(UISpecialFrames, "ALACHAT_SETTING_UI_C");
		local Close = CreateFrame('BUTTON', nil, SettingUIFreeContainer);
		Close:SetSize(16, 16);
		Close:SetNormalTexture(TEXTURE_PATH .. [[Close]]);
		Close:SetPushedTexture(TEXTURE_PATH .. [[Close]]);
		Close:GetPushedTexture():SetVertexColor(0.5, 0.5, 0.5, 0.5);
		Close:SetHighlightTexture(TEXTURE_PATH .. [[Close]]);
		Close:GetHighlightTexture():SetVertexColor(0.5, 0.5, 0.5, 0.5);
		Close:SetPoint("TOPRIGHT", SettingUIFreeContainer, "TOPRIGHT", -4, -4);
		Close:SetScript("OnClick", function(self)
			SettingUIFreeContainer:Hide();
		end);
		SettingUIFreeContainer.Close = Close;
		local BG = SettingUIFreeContainer:CreateTexture(nil, "BACKGROUND");
		BG:SetAllPoints();
		BG:SetColorTexture(0.0, 0.0, 0.0, 0.9);
		SettingUIFreeContainer.BG = BG;
		--
		SettingUIInterfaceOptionsFrameContainer = CreateFrame('FRAME');
		SettingUIInterfaceOptionsFrameContainer:Hide();
		SettingUIInterfaceOptionsFrameContainer:SetSize(1, 1);
		SettingUIInterfaceOptionsFrameContainer.name = __addon;
		SettingUIInterfaceOptionsFrameContainer:SetScript("OnShow", function(self)
			SettingUIFreeContainer:Hide();
			SettingUI:Show();
			SettingUI:ClearAllPoints();
			SettingUI:SetPoint("TOPLEFT", self, "TOPLEFT", 4, 0);
			SettingUI.Container = self;
		end);
		SettingUIInterfaceOptionsFrameContainer:SetScript("OnHide", function()
			if not SettingUIFreeContainer:IsShown() then
				SettingUI:Hide();
				SettingUI:ClearAllPoints();
			end
		end);
		InterfaceOptions_AddCategory(SettingUIInterfaceOptionsFrameContainer);
		--
	end
-->
function __private:InitSettingUI(db, default, modulelist, module)
	__db = db;
	__default = default;
	__modulelist = modulelist;
	__module = module;
	--
	CreateSettingUI();
end
function __private:SetDB(module, key, val, loading, extra)
	SetDB(module, key, val, loading, extra);
	local node = _SettingNodes[module][key];
	if node ~= nil and node.__indirect ~= true then
		node:SetVal(val);
	end
end
function __private:SetDBAllModules(key, val, loading, extra)
	for index = 1, #__modulelist do
		__private:SetDB(__modulelist[index], key, val, loading, extra);
	end
end
function __private:SetDBAllModulesExceptOne(key, val, exclude, loading, extra)
	for index = 1, #__modulelist do
		if __modulelist[index] ~= exclude then
			__private:SetDB(__modulelist[index], key, val, loading, extra);
		end
	end
end
function __private:OpenSettingTo(module, key)
	local node = _SettingNodes[module][key];
	local meta = _SettingList[module][key];
	local CategoryTable = _CategoryList[meta.category];
	if not SettingUIInterfaceOptionsFrameContainer:IsShown() then
		SettingUIFreeContainer:Show();
	end
	CategoryTable.Tab:Click();
	if node.__indirect == true and node.Click then
		node:Click();
	end
end

_G.SLASH_ALACHAT1 = "/alac";
_G.SLASH_ALACHAT2 = "/alachat";
SlashCmdList["ALACHAT"] = function()
	if (SettingsPanel or InterfaceOptionsFrame):IsShown() then
		InterfaceOptionsFrame_OpenToCategory(__addon);
	else
		SettingUIFreeContainer:SetShown(not SettingUIFreeContainer:IsShown());
	end
end
