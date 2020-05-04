--[[--
	alex@0
--]]--
----------------------------------------------------------------------------------------------------
local ADDON, NS = ...;
----------------------------------------------------------------------------------------------------
local math,table,string,pairs,type,select,tonumber,unpack=math,table,string,pairs,type,select,tonumber,unpack;
local _G=_G;
local GameTooltip=GameTooltip;
----------------------------------------------------------------------------------------------------
local __alaBaseBtn_Version=1.07;
if __alaBaseBtn and __alaBaseBtn.Version>=__alaBaseBtn_Version then
	return;
end
----------------------------------------------------------------------------------------------------
local btnSize=24;
local btnInterval=1;
local backdrop = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = nil;--"Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 2,
	edgeSize = 2,
	insets = { left = 0, right = 0, top = 0, bottom = 0 }
};
local backdropColor = { 0.15, 0.15, 0.15, 0.33 };
local locale = GetLocale()

if __alaBaseBtn then
	for k,v in pairs(__alaBaseBtn) do
		if k~=0 then
			__alaBaseBtn[k]=nil;
		end
	end
end
local alaBaseBtn=__alaBaseBtn or CreateFrame("frame","__alaBaseBtn",UIParent);
alaBaseBtn:Show();
alaBaseBtn:SetWidth(btnSize);
alaBaseBtn:SetHeight(btnSize);
alaBaseBtn.BtnList=alaBaseBtn.BtnList or {n=0,};
alaBaseBtn.BPList=alaBaseBtn.BPList or {};
alaBaseBtn.SubBPList=alaBaseBtn.SubBPList or {};
alaBaseBtn:SetMovable(true);
alaBaseBtn.HandleEvent=alaBaseBtn.HandleEvent or {"OnClick","OnDragStart","OnDragStop","OnEnter","OnLeave",};
local function onDragStart(self)
	if self:IsMovable() and IsControlKeyDown() then
		self.AnchorParent:StartMoving();
	end
end
local function onDragStop(self)
	if self:IsMovable() then
		self.AnchorParent:StopMovingOrSizing();
		alaBaseBtn:RecordPos();
	end
end
local function onEnter(self)
	GameTooltip:SetOwner(self,"ANCHOR_BOTTOMLEFT");
	for _,v in pairs(self.gtLine) do
		if type(v)=="string" then
			GameTooltip:AddLine(v);
		elseif type(v)=="function" then
			GameTooltip:AddLine(v());
		end
	end
	-- if locale == "zhCN" or locale == "zhTW" then
	-- 	GameTooltip:AddLine("\124cffff40ff按住ctrl拖动移动位置\124r");
	-- 	GameTooltip:AddLine("\124cffff40ff按住ctrl右击重置位置\124r");
	-- else
	-- 	GameTooltip:AddLine("\124cffff40ffHolding ctrl and left-drag to move\124r");
	-- 	GameTooltip:AddLine("\124cffff40ffHolding ctrl and right-click to reset pos\124r");
	-- end
	GameTooltip:Show();
end
local function onLeave(self)
	if GameTooltip:GetOwner()==self then
    	GameTooltip:Hide();
	end
end
local function onClick(self,button,...)
	if button=="RightButton" and IsControlKeyDown() then
		self.AnchorParent:ResetPoint();
	elseif self.onClickHandler then
		self.onClickHandler(self,button,...);
	end
end

local function onClickP(self,button,...)
	if self.isBtnShown then
		for _,b in pairs(self.list) do
		    b:Hide();
		end
	    self.isBtnShown=false;
	else
	    for _,b in pairs(self.list) do
		    b:Show();
		end
	    self.isBtnShown=true;
		self.elasped=2.5;
	end
end
local function onUpdateP(self,elasped)
    if self.isBtnShown then
		self.elasped=self.elasped-elasped;
		if self.elasped<=0 then
		    --onClickP(self);
		end
	end
end

local function onDragStartPB(self)
	if self:IsMovable() and IsControlKeyDown() then
		self.panel.AnchorParent:StartMoving();
	end
end
local function onDragStopPB(self)
	if self:IsMovable() then
		self.panel.AnchorParent:StopMovingOrSizing();
		alaBaseBtn:RecordPos();
	end
end
local function onEnterPB(self)
	GameTooltip:SetOwner(self,"ANCHOR_BOTTOMLEFT");
	for _,v in pairs(self.gtLine) do
		if type(v)=="string" then
			GameTooltip:AddLine(v);
		elseif type(v)=="function" then
			GameTooltip:AddLine(v());
		end
	end
	GameTooltip:Show();
end
local function onLeavePB(self)
	if GameTooltip:GetOwner()==self then
    	GameTooltip:Hide();
	end
end
local function onClickPB(self,button,...)
	if button=="RightButton" and IsControlKeyDown() then
		self.panel.AnchorParent:ResetPoint();
	elseif self.onClickHandler then
		self.onClickHandler(self,button,...);
		onClickP(self.panel);
	end
end

function alaBaseBtn:ArrangeBtn(start_pos, end_pos)
	-- alaBaseData.xBtn.dir
	-- print(alaBaseData.xBtn.dir)
	local list = self.BtnList;
	local pos = 0;
	if start_pos then
		for i = 1, start_pos-1 do
			pos = pos + list[i].n;
		end
	else
		start_pos = 1;
	end
	end_pos = end_pos or list.n;
	for i = start_pos, end_pos do
		local l = list[i];
		for j = 1, l.n do
			pos = pos + 1;
			local b = l[j];
			if b then
				b:ClearAllPoints();
				if alaBaseData.xBtn.dir == "HORIZONTAL" then
					b:SetPoint("TOP", self, "TOP", (btnSize+btnInterval) * (pos - 1), 0);
				elseif alaBaseData.xBtn.dir == "VERTICAL" then
					b:SetPoint("TOP", self, "TOP", 0, - (btnSize+btnInterval) * (pos - 1));
				end
			end
		end
	end
end
--posIndexMajor,posIndexMinor,btn,customScript,resize,show
--posIndexMajor,btn,customScript,resize,show
--btn,customScript,resize,show
function alaBaseBtn:AddBtn(posIndexMajor,posIndexMinor,btn,customScript,resize,show)
	local list=self.BtnList;
	if posIndexMajor and type(posIndexMajor)=="table" then
		btn,customScript,resize,show=posIndexMajor,posIndexMinor,btn,customScript;
		posIndexMajor=1;
		posIndexMinor=-1;
	elseif posIndexMinor and type(posIndexMinor)=="table" then
		btn,customScript,resize,show=posIndexMinor,btn,customScript,resize;
		posIndexMajor=tonumber(posIndexMajor);
		if not posIndexMajor or posIndexMajor<=0 then
			posIndexMajor=1;
		end
		posIndexMinor=-1;
	elseif btn and type(btn)=="table" then
		posIndexMajor=tonumber(posIndexMajor);
		if not posIndexMajor or posIndexMajor<=0 then
			posIndexMajor=1;
		end
		posIndexMinor=tonumber(posIndexMinor);
		if not posIndexMinor or posIndexMinor<=0 then
			posIndexMinor=-1;
		end
	end
	for i=list.n+1,posIndexMajor do
		list[i]=list[i] or {n=0};
	end
	list.n=max(list.n,posIndexMajor);
	list[posIndexMajor].n=list[posIndexMajor].n+1;
	if posIndexMinor>list[posIndexMajor].n then
		list[posIndexMajor].n=posIndexMinor;
	elseif posIndexMinor<0 then
		posIndexMinor=list[posIndexMajor].n;
	end
	table.insert(list[posIndexMajor],posIndexMinor,btn);
	local pos=0;
	alaBaseBtn:ArrangeBtn(posIndexMajor);
	-- for i=1,posIndexMajor-1 do
	-- 	pos=pos+list[i].n;
	-- end
	-- for i=posIndexMajor,list.n do
	-- 	local l=list[i];
	-- 	for j=1,l.n do
	-- 		pos=pos+1;
	-- 		local b=l[j];
	-- 		if b then
	-- 			b:ClearAllPoints();
	-- 			b:SetPoint("TOP",self,"TOP",(btnSize+btnInterval)*(pos-1),0);
	-- 		end
	-- 	end
	-- end
	btn.AnchorParent=self;
	if not customScript then
		btn:SetScript("OnClick",onClick);
		btn:SetScript("OnEnter",onEnter);
		btn:SetScript("OnLeave",onLeave);
		btn:SetScript("OnDragStart",onDragStart);
		btn:SetScript("OnDragStop",onDragStop);
	end
	btn:SetParent(alaBaseBtn);
	if resize then
		btn:SetWidth(btnSize);
		btn:SetHeight(btnSize);
	end
	if show then
		btn:Show();
	end
end
--posIndexMajor,posIndexMinor,hide
--btn,hide
function alaBaseBtn:RemoveBtn(posIndexMajor,posIndexMinor,hide)
	if posIndexMajor then
		local list=self.BtnList;
		if type(posIndexMajor)=="table" then
			local btn=posIndexMajor;
			hide=posIndexMinor;
			for i=1,list.n do
				local l=list[i];
				for j=1,l.n do
					if l[j]==btn then
						table.remove(l,j);
						l.n=l.n-1;
					end
				end
			end
			btn:ClearAllPoints();
			if hide then
				btn:Hide();
			end
		else
			posIndexMajor=tonumber(posIndexMajor);
			if posIndexMajor>0 then
				if type(posIndexMinor)=="table" then
					local btn=posIndexMinor;
					local l=list[posIndexMajor];
					for j=1,l.n do
						if l[j]==btn then
							table.remove(l,j);
							l.n=l.n-1;
						end
					end
				else
					posIndexMinor=tonumber(posIndexMinor);
					if posIndexMinor>0 then
						local l=list[posIndexMajor];
						if l and l[posIndexMinor] then
							l[posIndexMinor]:ClearAllPoints();
							if hide then
								l[posIndexMinor]:Hide();
							end
							table.remove(l,posIndexMinor);
							l.n=l.n-1;
						end
					end
				end
			end
		end
		alaBaseBtn:ArrangeBtn();
		-- local pos=0;
		-- for i=1,list.n do
		-- 	local l=list[i];
		-- 	for j=1,l.n do
		-- 		pos=pos+1;
		-- 		local b=l[j];
		-- 		if b then
		-- 			b:ClearAllPoints();
		-- 			b:SetPoint("TOP",self,"TOP",(btnSize+btnInterval)*(pos-1),0);
		-- 		end
		-- 	end
		-- end
	end
end
function alaBaseBtn:AddPanelBtn(panel,Btn)	-- MAYBE BROKEN
    --Btn:SetMovable(false);
	if type(panel)=="number" or type(panel)=="string" then
	    panel=self.BPList[panel];
	end
	if not panel or not panel.list then
		return;
	end
	panel.num=panel.num+1;
	panel.list[panel.num]=Btn;
	if panel.num==1 then
	    Btn:ClearAllPoints();
		Btn:SetPoint("BOTTOM",panel,"TOP",0,2);
	else
	    Btn:ClearAllPoints();
		Btn:SetPoint("BOTTOM",panel.list[panel.num-1],"TOP",0,2);
	end
	if panel.isBtnShown then
	    Btn:Show();
	else
	    Btn:Hide();
	end
	Btn:SetScript("OnClick",onClickPB);
	Btn:SetScript("OnEnter",onEnterPB);
	Btn:SetScript("OnLeave",onLeavePB);
	Btn:SetScript("OnDragStart",onDragStartPB);
	Btn:SetScript("OnDragStop",onDragStopPB);
	Btn.panel=panel;
end
--posIndexMajor,posIndexMinor,name,nTex,pTex,hTex,onClickHandler,line,panel,alpha,color
--posIndexMajor,name,nTex,pTex,hTex,onClickHandler,line,panel,alpha,color
--name,nTex,pTex,hTex,onClickHandler,line,panel,alpha,color
local temp_name_id = 1;
function alaBaseBtn:CreateBtn(posIndexMajor,posIndexMinor,name,nTex,pTex,hTex,onClickHandler,line,panel,alpha,color)
	if posIndexMajor == nl or type(posIndexMajor)=="string" then
		name,nTex,pTex,hTex,onClickHandler,line,panel,alpha=posIndexMajor,posIndexMinor,name,nTex,pTex,hTex,onClickHandler,line;
		posIndexMajor=1;
		posIndexMinor=-1
	else
		if posIndexMinor == nil or type(posIndexMinor)=="string" then
			name,nTex,pTex,hTex,onClickHandler,line,panel,alpha=posIndexMinor,name,nTex,pTex,hTex,onClickHandler,line,panel;
			posIndexMajor=tonumber(posIndexMajor);
			if not posIndexMajor or posIndexMajor<=0 then
				posIndexMajor=1;
			end
			posIndexMinor=-1
		else
			posIndexMajor=tonumber(posIndexMajor);
			if not posIndexMajor or posIndexMajor<=0 then
				posIndexMajor=1;
			end
			posIndexMinor=tonumber(posIndexMinor);
			if not posIndexMinor or posIndexMinor<=0 then
				posIndexMinor=-1;
			end
		end
	end
	-- if not name then
	-- 	name = "alaBaseBtnChildren" .. temp_name_id;
	-- 	temp_name_id = temp_name_id + 1;
	-- end
	local btn=CreateFrame("Button", name,alaBaseBtn);
	btn:SetWidth(btnSize);
	btn:SetHeight(btnSize);
	alaBaseBtn:ChangeBtnTexture(btn, nTex, pTex, hTex,color);
	--
	btn:SetAlpha(alpha or 1);
	btn:SetFrameLevel(32);
	btn:SetMovable(true);
	btn:EnableMouse(true);
	btn:RegisterForClicks("LeftButtonUp","RightButtonUp");
	btn:ClearAllPoints();
	btn.gtLine=line or {};
	btn.onClickHandler=onClickHandler;
	btn:Show();
	if panel then
	    self:AddPanelBtn(panel,btn);
	else
		btn:RegisterForDrag("LeftButton","RightButton");
	    self:AddBtn(posIndexMajor,posIndexMinor,btn);
	end
	return btn;
end
function alaBaseBtn:ChangeBtnTexture(btn, nTex, pTex, hTex, color)
	if not btn then
		return;
	end
	if nTex then
	    if string.lower(nTex)=="class" and pTex then
		    btn:SetNormalTexture("Interface\\TARGETINGFRAME\\UI-CLASSES-CIRCLES");
			btn:SetPushedTexture("Interface\\TARGETINGFRAME\\UI-CLASSES-CIRCLES");
			if CLASS_ICON_TCOORDS[string.upper(pTex)] then
				btn:GetNormalTexture():SetTexCoord(unpack(CLASS_ICON_TCOORDS[pTex]));
				btn:GetPushedTexture():SetTexCoord(unpack(CLASS_ICON_TCOORDS[pTex]));
			else
				btn:GetNormalTexture():SetTexCoord(unpack(CLASS_ICON_TCOORDS[select(2,UnitClass("player")) or "WARRIOR"]));
				btn:GetPushedTexture():SetTexCoord(unpack(CLASS_ICON_TCOORDS[select(2,UnitClass("player")) or "WARRIOR"]));
			end
			if hTex then
				btn:SetHighlightTexture(hTex);
				btn.hTex = hTex;
			else
				btn:SetHighlightTexture("Interface\\Buttons\\ui-panel-minimizebutton-highlight");
			end
			btn:GetHighlightTexture():SetBlendMode("ADD");
			if btn.fontString then
				btn.fontString:Hide();
			end
			btn.type = 'class';
		elseif string.lower(nTex)=="char" then
			-- local btnTexture=btn:CreateTexture(name.."Texture","BACKGROUND");
			-- btnTexture:SetAllPoints(btn);
			-- btnTexture:SetTexture("Interface\\Buttons\\UI-Quickslot-Depress");
			local name = btn:GetName();
			local btnFontString = btn.fontString or btn:CreateFontString(name and (name.."FontString"),"ARTWORK");
			btnFontString:SetPoint("CENTER");
			if alaBaseData.xBtn.style == 'blz' then
				btn:SetBackdropColor({
					bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
					edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
					tile = true,
					tileSize = 2,
					edgeSize = 2,
					insets = { left = 2, right = 2, top = 2, bottom = 2 }
				});
				btn:SetNormalTexture(NS.ICON_PATH .. "text_nor_frame");
				btn:GetNormalTexture():SetVertexColor(1.0, 1.0, 1.0, 1.0);
				btn:SetPushedTexture(NS.ICON_PATH .. "text_push_frame");
				btn:GetPushedTexture():SetVertexColor(1.0, 1.0, 1.0, 1.0);
				btn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight");
				btn:GetHighlightTexture():SetBlendMode("ADD");
				btnFontString:SetFont(NumberFont_Shadow_Med:GetFont(),15,"NORMAL");
				btnFontString:SetTextColor(1.0, 0.75, 0.25, 1.0);
			elseif alaBaseData.xBtn.style == 'ala' then
				btn:SetBackdropColor({
					bgFile = nil,
					edgeFile = nil,
					tile = true,
					tileSize = 0,
					edgeSize = 0,
					insets = { left = 0, right = 0, top = 0, bottom = 0 }
				});
				btn:SetNormalTexture(nil);
				btn:SetPushedTexture(nil);
				if hTex then
					btn:SetHighlightTexture(hTex);
					btn.hTex = hTex;
				else
					btn:SetHighlightTexture("Interface\\Buttons\\ui-panel-minimizebutton-highlight");
				end
				btn:GetHighlightTexture():SetBlendMode("ADD");
				btnFontString:SetFont(SystemFont_Shadow_Med1:GetFont(),21,"NORMAL");
				if color then
					btnFontString:SetTextColor(color.r, color.g, color.b, 1.0);
				end
			end
			btnFontString:SetText(pTex);
			btnFontString:Show();
			btn.color = color;
			btn.fontString = btnFontString;
			btn.type = 'char';
		else
			btn:SetNormalTexture(nTex);
			if pTex then
				btn:SetPushedTexture(pTex);
			else
				btn:SetPushedTexture(nTex);
			end
			if color then
				if btn:GetNormalTexture() then
					btn:GetNormalTexture():SetVertexColor(color.r, color.g, color.b, color.a or 1.0);
				end
				if btn:GetPushedTexture() then
					btn:GetPushedTexture():SetVertexColor(color.r, color.g, color.b, color.a or 1.0);
				end
				btn.color = color;
			end
			if hTex then
				btn:SetHighlightTexture(hTex);
				btn.hTex = hTex;
			else
				btn:SetHighlightTexture("Interface\\Buttons\\ui-panel-minimizebutton-highlight");
			end
			btn:GetHighlightTexture():SetBlendMode("ADD");
			if btn.fontString then
				btn.fontString:Hide();
			end
			btn.type = 'norm';
		end
	end
end
function alaBaseBtn:CreateBtnPanel(name,nTex,pTex,line)
    -- if not name then
	--     name=1;
	-- 	while self.BPList[name] do
	-- 	    name=name+1;
	-- 	end
	-- end
	local btn=self:CreateBtn(name and (name.."BTN"),nTex,pTex,onClickBP,line);
	btn.onClickHandler=onClickP;
	btn.list={};
	btn.num=0;
	self.BPList[name]=btn;
	btn.isBtnShown=false;
	btn:SetScript("OnUpdate",onUpdateP);
	return name;
end
----------
__alaBaseBtn.Version=__alaBaseBtn_Version;
----------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
function alaBaseBtn:RecordPos()
	alaBaseData.xBtn.pos = { self:GetPoint() };
	if alaBaseData.xBtn.pos[1] and type(alaBaseData.xBtn.pos[1]) == "table" then
		alaBaseData.xBtn.pos[1] = alaBaseData.xBtn.pos[1]:GetName()
	end
	if alaBaseData.xBtn.pos[2] and type(alaBaseData.xBtn.pos[2]) == "table" then
		alaBaseData.xBtn.pos[2] = alaBaseData.xBtn.pos[2]:GetName()
	end
end
function alaBaseBtn:SetEditBox()
		for i = 1, NUM_CHAT_WINDOWS do
			local editbox = _G["ChatFrame" .. i .. "EditBox"];
			local chatframe = _G["ChatFrame" .. i];
			--print(editbox:GetTop(), chatframe:GetBottom(), chatframe:GetBottom() - editbox:GetTop())
			if ((editbox:GetTop() <= chatframe:GetBottom()) and (chatframe:GetBottom() - editbox:GetTop() < btnSize * alaBaseData.xBtn.scale)) or (editbox.bottom and (math.abs(editbox.bottom - editbox:GetBottom()) <= 0.5)) then
				editbox:ClearAllPoints();
				editbox:SetPoint("TOPLEFT", chatframe, "BOTTOMLEFT", - 5, - 5 - btnSize * alaBaseData.xBtn.scale);
				editbox:SetPoint("TOPRIGHT", chatframe, "BOTTOMRIGHT", - 5, - 5 - btnSize * alaBaseData.xBtn.scale);
				editbox.bottom = editbox:GetBottom();
			end
		end
end
function alaBaseBtn:ResetEditBox()
		for i = 1, NUM_CHAT_WINDOWS do
			local editbox = _G["ChatFrame" .. i .. "EditBox"];
			local chatframe = _G["ChatFrame" .. i];
			if editbox.bottom and math.abs(editbox.bottom - editbox:GetBottom()) <= 0.5 then
				editbox:ClearAllPoints();
				editbox:SetPoint("TOPLEFT", chatframe, "BOTTOMLEFT", -5, -2);
				editbox:SetPoint("TOPRIGHT", chatframe, "BOTTOMRIGHT", -5, -2);
				editbox.bottom = nil;
			end
		end
end
function alaBaseBtn:ResetPoint()
	--print(alaBaseData.xBtn.posEx)
	self:ClearAllPoints();
	if alaBaseData.xBtn.posEx == "ABOVE_EDITOBX" then
		self:SetPoint("BOTTOMLEFT", ChatFrame1EditBox, "TOPLEFT", 0, -1);
		self:SetEditBox();
	elseif alaBaseData.xBtn.posEx == "BELOW_EDITBOX" then
		self:SetPoint("TOPLEFT", ChatFrame1EditBox, "BOTTOMLEFT", 0, -1);
		self:ResetEditBox();
	elseif alaBaseData.xBtn.posEx == "ABOVE_CHATFRAME" then
		self:SetPoint("BOTTOMLEFT", ChatFrame1Tab, "TOPLEFT", 0, 1);
		self:ResetEditBox();
	end
	--self:ResetEditBox();
	alaBaseData.xBtn.pos = nil;
end

function alaBaseBtn:Scale(s)
	alaBaseData.xBtn.scale = s;
	self:SetScale(s);
	if(alaBaseData.xBtn.posEx == "ABOVE_EDITOBX") then
		self:SetEditBox();
	end
end
function alaBaseBtn:Alpha(a)
	alaBaseData.xBtn.alpha = a;
	self:SetAlpha(a);
end
function alaBaseBtn:Pos(p)
	--print(p)
	if p ~= alaBaseData.xBtn.posEx and (p == "ABOVE_EDITOBX" or p == "BELOW_EDITBOX" or p == "ABOVE_CHATFRAME") then
		alaBaseData.xBtn.posEx = p;--ABOVE_EDITOBX,BELOW_EDITBOX,ABOVE_CHATFRAME
		self:ResetPoint();
	end
end
function alaBaseBtn:Dir(d)
	if d ~= alaBaseData.xBtn.dir and (d == "HORIZONTAL" or d == "VERTICAL") then
		alaBaseData.xBtn.dir = d;
		self:ArrangeBtn();
	end
end
function alaBaseBtn:Style(s)
	--'ala', 'blz'
	if alaBaseData.xBtn.style ~= s and (s == 'blz' or s == 'ala') then
		alaBaseData.xBtn.style = s;
		if s == 'blz' then
			for i = 1, #self.BtnList do
				local l = self.BtnList[i];
				for j = 1, #l do
					local btn = self.BtnList[i][j];
					if btn.type == 'char' then
						btn:SetBackdropColor({
							bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
							edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
							tile = true,
							tileSize = 2,
							edgeSize = 2,
							insets = { left = 2, right = 2, top = 2, bottom = 2 }
						});
						btn:SetNormalTexture(NS.ICON_PATH .. "text_nor_frame");
						btn:GetNormalTexture():SetVertexColor(1.0, 1.0, 1.0, 1.0);
						btn:SetPushedTexture(NS.ICON_PATH .. "text_push_frame");
						btn:GetPushedTexture():SetVertexColor(1.0, 1.0, 1.0, 1.0);
						btn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight");
						btn:GetHighlightTexture():SetBlendMode("ADD");
						btn.fontString:SetFont(NumberFont_Shadow_Med:GetFont(),15,"NORMAL");
						btn.fontString:SetTextColor(1.0, 0.75, 0.25, 1.0);
						btn.fontString:SetText(btn.fontString:GetText());
					end
				end
			end
		elseif s == 'ala' then
			for i = 1, #self.BtnList do
				local l = self.BtnList[i];
				for j = 1, #l do
					local btn = self.BtnList[i][j];
					if btn.type == 'char' then
						btn:SetBackdropColor({
							bgFile = nil,
							edgeFile = nil,
							tile = true,
							tileSize = 0,
							edgeSize = 0,
							insets = { left = 0, right = 0, top = 0, bottom = 0 }
						});
						btn:SetNormalTexture(nil);
						btn:SetPushedTexture(nil);
						if hTex then
							btn:SetHighlightTexture(hTex);
							btn.hTex = hTex;
						else
							btn:SetHighlightTexture("Interface\\Buttons\\ui-panel-minimizebutton-highlight");
						end
						btn:GetHighlightTexture():SetBlendMode("ADD");
						btn.fontString:SetFont(SystemFont_Shadow_Med1:GetFont(),21,"NORMAL");
						if btn.color then
							btn.fontString:SetTextColor(btn.color.r, btn.color.g, btn.color.b, 1.0);
						end
						btn.fontString:SetText(btn.fontString:GetText());
					end
				end
			end
		end
	end
end

alaBaseBtn:RegisterEvent("PLAYER_ENTERING_WORLD");
alaBaseBtn:SetScript("OnEvent", function()
										alaBaseData = alaBaseData or {};
										alaBaseData.xBtn = alaBaseData.xBtn or {};
										alaBaseData.xBtn.posEx = alaBaseData.xBtn.posEx or "BELOW_EDITBOX";
										alaBaseData.xBtn.dir = alaBaseData.xBtn.dir or "HORIZONTAL";
										alaBaseData.xBtn.scale = alaBaseData.xBtn.scale or 1.0;
										alaBaseData.xBtn.alpha = alaBaseData.xBtn.alpha or 1.0;
										alaBaseData.xBtn.style = alaBaseData.xBtn.style or 'blz';
										--if alaBaseData.xBtn then
											if not alaBaseData.xBtn._version or alaBaseData.xBtn._version < __alaBaseBtn_Version then
												alaBaseData.xBtn._version = __alaBaseBtn_Version;
												--alaBaseData = alaBaseData or {};
												--alaBaseData.xBtn = alaBaseData.xBtn or {};
												--alaBaseData.xBtn.posEx = alaBaseData.xBtn.posEx or "BELOW_EDITBOX";
												--alaBaseData.xBtn.scale = alaBaseData.xBtn.scale or 1.0;
											end
											if alaBaseData.xBtn.pos then
												alaBaseBtn:ClearAllPoints();
												alaBaseBtn:SetPoint(unpack(alaBaseData.xBtn.pos));
												if alaBaseData.xBtn.posEx == "ABOVE_EDITOBX" then
													alaBaseBtn:SetEditBox();
												end
											else
												alaBaseBtn:ResetPoint();
											end
											--if alaBaseData.xBtn.scale then
												alaBaseBtn:SetScale(alaBaseData.xBtn.scale);
											--end
											--if alaBaseData.xBtn.alpha then
												alaBaseBtn:SetAlpha(alaBaseData.xBtn.alpha);
											--end
										--else
										--	alaBaseBtn:ResetPoint();
										--end
									end
);

