--[[--
	alex@0
--]]--
do return end
----------------------------------------------------------------------------------------------------
local ADDON,NS=...;
local FUNC=NS.FUNC;
if not FUNC then return;end
local L=NS.L;
if not L then return;end
----------------------------------------------------------------------------------------------------
local math,table,string,pairs,type,select,tonumber,unpack=math,table,string,pairs,type,select,tonumber,unpack;
local _G=_G;
----------------------------------------------------------------------------------------------------
local alaBaseBtn=__alaBaseBtn;
if not alaBaseBtn then
	return;
end
--------------------------------------------------chat frame arrange
local control_chatFrameScroll=false;
local chatframe={};
for i=1,NUM_CHAT_WINDOWS do
	chatframe[i]=_G["ChatFrame"..i];
end
local function disableSetPoint(f)
	if not f._ClearAllPoints then
		f._ClearAllPoints=f.ClearAllPoints;
		f.ClearAllPoints=function()end;
	end
	if not f._SetPoint then
		f._SetPoint=f.SetPoint;
		f.SetPoint=function()end;
	end
end
local function enableSetPoint(f)
	if f._ClearAllPoints then
		f.ClearAllPoints=f._ClearAllPoints;
		f._ClearAllPoints=nil;
	end
	if f._SetPoint then
		f.SetPoint=f._SetPoint;
		f._SetPoint=nil;
	end
end
--[[
default layout

.ScrollToBottomButton
	BR .ResizeButton TR 0 -2
	size=24
.ScrollBar
	TL $ TR 0 0
	B .ScrollToBottomButton T 0 0
	width=22
.Background
	TL $ TL -2 3
	BR $ BR 24 -6

ChatFrameMenuButton
	B .buttonFrame(ChatFrame1ButtonFrame) B 0 0
ChatFrameToggleVoiceMuteButton
	T ↓ B 0 -2
ChatFrameToggleVoiceDeafenButton
	T ↓ B 0 -2
ChatFrameChannelButton
	T .buttonFrame(ChatFrame1ButtonFrame) T 0 0

--]]
local function reset()
	for i=1,NUM_CHAT_WINDOWS do
		local f=chatframe[i];
		local btn=f.ScrollToBottomButton;
		local bar=f.ScrollBar;

		btn:SetSize(24,24);
		bar:SetWidth(22);

		enableSetPoint(btn);
		btn:ClearAllPoints();
		btn:SetPoint("BOTTOMRIGHT",f.ResizeButton,"TOPRIGHT",0,-2);
		btn:SetAlpha(0);
		btn.SetAlpha=btn._SetAlpha;
		btn._SetAlpha=nil;

		enableSetPoint(bar);
		bar:ClearAllPoints();
		bar:SetPoint("TOPLEFT",f,"TOPRIGHT",0,0);
		bar:SetPoint("BOTTOM",btn,"TOP",-2,0);
		bar:SetAlpha(0);
		bar.SetAlpha=bar._SetAlpha;
		bar._SetAlpha=nil;

		if i~=2 then
			local bg=f.Background;

			enableSetPoint(bg);
			bg:ClearAllPoints();
			bg:SetPoint("TOPLEFT",f,"TOPLEFT",-2,3);
			bg:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",24,-6);
		end
	end
	ChatFrameChannelButton:ClearAllPoints();
	ChatFrameChannelButton:SetPoint("TOP",ChatFrame1ButtonFrame,"TOP",0,0);
	ChatFrameChannelButton:SetSize(27,26);
	ChatFrameToggleVoiceDeafenButton:ClearAllPoints();
	ChatFrameToggleVoiceDeafenButton:SetPoint("TOP",ChatFrameChannelButton,"BOTTOM",0,-2);
	ChatFrameToggleVoiceDeafenButton:SetSize(27,26);
	ChatFrameToggleVoiceMuteButton:ClearAllPoints();
	ChatFrameToggleVoiceMuteButton:SetPoint("TOP",ChatFrameToggleVoiceDeafenButton,"BOTTOM",0,-2);
	ChatFrameToggleVoiceMuteButton:SetSize(27,26);
	ChatFrameMenuButton:ClearAllPoints();
	ChatFrameMenuButton:SetPoint("BOTTOM",ChatFrame1ButtonFrame,"BOTTOM",0,0);
	ChatFrameMenuButton:SetSize(32,32);
end
local LSBB={};
local function style0()--add scroll to bottom button

	ChatFrameMenuButton:ClearAllPoints();
	ChatFrameMenuButton:SetPoint("TOP",ChatFrameToggleVoiceMuteButton,"BOTTOM",0,0);

	for i=1,NUM_CHAT_WINDOWS do

	    --add button
		local f=chatframe[i];
		local btn=f.ScrollToBottomButton;
		if LSBB[i] then
			LSBB[i]:Show();
		else
			local LScrollToBottomButton=CreateFrame("Button","ChatFrame"..i.."LScrollToBottomButton",f);
			LScrollToBottomButton:SetWidth(32);
			LScrollToBottomButton:SetHeight(32);
			LScrollToBottomButton:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollEnd-Disabled");
			--LScrollToBottomButton:SetHighlightTexture(btn:GetHighlightTexture());
			LScrollToBottomButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollEnd-Up");
			LScrollToBottomButton:GetHighlightTexture():SetTexture(btn:GetHighlightTexture():GetTexture());
			LScrollToBottomButton:GetHighlightTexture():SetBlendMode("ADD");
			LScrollToBottomButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollEnd-Up");
			LScrollToBottomButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollEnd-Down");
			LScrollToBottomButton:SetScript("OnClick",btn:GetScript("OnClick"));
			LScrollToBottomButton:SetScript("OnEnter",btn:GetScript("OnEnter"));
			LScrollToBottomButton:SetScript("OnLeave",btn:GetScript("OnLeave"));
			LScrollToBottomButton:SetScript("OnDragStart",btn:GetScript("OnDragStart"));
			LScrollToBottomButton:SetScript("OnDragStop",btn:GetScript("OnDragStop"));
			LScrollToBottomButton:EnableMouse(true);
			LScrollToBottomButton:RegisterForClicks("LeftButtonUp","RightButtonUp");
			LScrollToBottomButton:ClearAllPoints();
			LScrollToBottomButton:SetPoint("BOTTOM",ChatFrame1ButtonFrame,"BOTTOM",0,0);
			LScrollToBottomButton:Show();
			LSBB[i]=LScrollToBottomButton;
		end
	end
end
local function reset0()
	ChatFrameMenuButton:ClearAllPoints();
	ChatFrameMenuButton:SetPoint("BOTTOM",ChatFrame1ButtonFrame,"BOTTOM",0,0);
	for i=1,NUM_CHAT_WINDOWS do
		if LSBB[i] then
			LSBB[i]:Hide();
		end
	end
end
local function moveScrollToLeft()
	for i=1,NUM_CHAT_WINDOWS do
	    --moveScrollToLeft
		local f=chatframe[i];
		local btn=f.ScrollToBottomButton;
		local bar=f.ScrollBar;

		btn:SetSize(32,32);
		bar:SetWidth(30);

		btn:ClearAllPoints();
		btn:SetPoint("BOTTOMRIGHT",f,"BOTTOMLEFT",0,0);
		disableSetPoint(btn);
		btn:SetAlpha(1);
		btn._SetAlpha=btn.SetAlpha;
		btn.SetAlpha=function()end;

		bar:ClearAllPoints();
		bar:SetPoint("BOTTOMLEFT",btn,"TOPLEFT",0,0);
		bar:SetPoint("TOPRIGHT",f,"TOPLEFT",-2,0);
		disableSetPoint(bar);
		bar:SetAlpha(1);
		bar._SetAlpha=bar.SetAlpha;
		bar.SetAlpha=function()end;

		--deleteScrollRegionBackground
		if i~=2 then
			local bg=f.Background;

			--bg:ClearAllPoints();
			bg:SetPoint("TOPRIGHT",f,"TOPRIGHT",2,3);
			--bg:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",-2,-6);
			disableSetPoint(bg);
		end
	end
end
local function style1()--left scroll & left button
	for i=1,NUM_CHAT_WINDOWS do
	    --moveScrollToLeft
		local f=chatframe[i];
		local btn=f.ScrollToBottomButton;
		local bar=f.ScrollBar;

		btn:ClearAllPoints();
		btn:SetPoint("BOTTOMRIGHT",f,"BOTTOMLEFT",0,0);
		disableSetPoint(btn);

		bar:ClearAllPoints();
		bar:SetPoint("BOTTOM",btn,"TOP",0,0);
		bar:SetPoint("TOPRIGHT",f,"TOPLEFT",0,0);
		disableSetPoint(bar);
	end
	for i=1,NUM_CHAT_WINDOWS do
		local f=chatframe[i];
		local bg=f.Background;

		if false and i==2 then
			local clb=CombatLogQuickButtonFrame_Custom
			clb.ClearAllPoints();
			clb:SetPoint("BOTTOMLEFT",ChatFrame2,"TOPLEFT");
			clb:SetPoint("BOTTOMRIGHT",ChatFrame2,"TOPRIGHT");
			disableSetPoint(clb);

			f:ClearAllPoints();
			f:SetPoint("TOPRIGHT",ChatFrame1,"TOPRIGHT",0,0);
			f:SetPoint("BOTTOMLEFT",ChatFrame1,"BOTTOMLEFT",0,0);
			disableSetPoint(f);
		else
			--print(i,select(1,bg:GetSize()));
			--bg:SetSize(bg:GetSize());
		end
		bg:ClearAllPoints();
		bg:SetPoint("TOPRIGHT",f,"TOPRIGHT",2,3);
		bg:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",-26,-6);
		disableSetPoint(bg);

	end
end
local function style2()--left scroll & top button

	--moveIconToTop
	ChatFrameChannelButton:ClearAllPoints();
	ChatFrameChannelButton:SetPoint("LEFT",QuickJoinToastButton,"RIGHT",2,0);
	disableSetPoint(ChatFrameChannelButton);
	ChatFrameToggleVoiceDeafenButton:ClearAllPoints();
	ChatFrameToggleVoiceDeafenButton:SetPoint("LEFT",ChatFrameChannelButton,"RIGHT",2,0);
	disableSetPoint(ChatFrameToggleVoiceDeafenButton);
	ChatFrameToggleVoiceMuteButton:ClearAllPoints();
	ChatFrameToggleVoiceMuteButton:SetPoint("LEFT",ChatFrameToggleVoiceDeafenButton,"RIGHT",2,0);
	disableSetPoint(ChatFrameToggleVoiceMuteButton);
	ChatFrameMenuButton:ClearAllPoints();
	ChatFrameMenuButton:SetPoint("LEFT",ChatFrameToggleVoiceMuteButton,"RIGHT",2,0);
	disableSetPoint(ChatFrameMenuButton);

	moveScrollToLeft();
end
local function style3()--left scroll & bottom button

	--moveIconToBottom
	ChatFrameChannelButton:ClearAllPoints();
	ChatFrameChannelButton:SetPoint("TOPLEFT",ChatFrame1EditBox,"BOTTOMLEFT",0,-2);
	disableSetPoint(ChatFrameChannelButton);
	ChatFrameToggleVoiceDeafenButton:ClearAllPoints();
	ChatFrameToggleVoiceDeafenButton:SetPoint("LEFT",ChatFrameChannelButton,"RIGHT",2,0);
	disableSetPoint(ChatFrameToggleVoiceDeafenButton);
	ChatFrameToggleVoiceMuteButton:ClearAllPoints();
	ChatFrameToggleVoiceMuteButton:SetPoint("LEFT",ChatFrameToggleVoiceDeafenButton,"RIGHT",2,0);
	disableSetPoint(ChatFrameToggleVoiceMuteButton);
	ChatFrameMenuButton:ClearAllPoints();
	ChatFrameMenuButton:SetPoint("LEFT",ChatFrameToggleVoiceMuteButton,"RIGHT",2,0);
	disableSetPoint(ChatFrameMenuButton);

	moveScrollToLeft();
end
local function style4()--left scroll & bar button
	--moveIconToBar
	alaBaseBtn:AddBtn(4,ChatFrameMenuButton,true,true);
	alaBaseBtn:AddBtn(4,ChatFrameChannelButton,true,true);
	alaBaseBtn:AddBtn(4,ChatFrameToggleVoiceDeafenButton,true,true);
	alaBaseBtn:AddBtn(4,ChatFrameToggleVoiceMuteButton,true,true);

	moveScrollToLeft();
end
local function reset4()
	control_chatFrameScroll=false;
	alaBaseBtn:RemoveBtn(4,ChatFrameMenuButton);
	alaBaseBtn:RemoveBtn(4,ChatFrameChannelButton);
	alaBaseBtn:RemoveBtn(4,ChatFrameToggleVoiceDeafenButton);
	alaBaseBtn:RemoveBtn(4,ChatFrameToggleVoiceMuteButton);
	reset();
end
local S={style0,style1,style2,style3,style4};
local R={reset0,reset1,reset2,reset3,reset4};
local chosen=0;
local function chatFrameScroll_ToggleOn()
	if control_chatFrameScroll then
		return;
	end
	control_chatFrameScroll=true;
	S[chosen+1]();
	return control_chatFrameScroll;
end
local function chatFrameScroll_ToggleOff()
	if not control_chatFrameScroll then
		return;
	end
	control_chatFrameScroll=false;
	R[chosen+1]();
	return control_chatFrameScroll;
end
FUNC.ON.chatFrameScroll=chatFrameScroll_ToggleOn;
FUNC.OFF.chatFrameScroll=chatFrameScroll_ToggleOff;
----------------------------------------------------------------------------------------------------
