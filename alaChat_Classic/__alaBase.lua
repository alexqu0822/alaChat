--[[--
	alex@0
	--
	integer index=delayCall(function func,number delay,integer or bool period,list paraList);
	editdCall(integer index,function func,number delay,integer or bool period,list paraList);
	handler:func(paraList);
	--
	integer index=eventCall(eventHandler event,function func,integer or bool period,any para);
	editeCall(eventHandler event,integer index,function func,integer or bool period,any para);
	handler:func(para,event,...);
	--
	hookfCall,delhfCall(string hookedFunc,function or string hookingFunc);
	hookfCall,delhfCall(table or string hookedWidget,string hookedFunc,function or string hookingFunc);
	--
	hookwCall,delhwCall(table hookedWidget,string hookedHandler,function or string hookingFunc);
	--
	C_Timer.After(duration,callback)
	timer=C_Timer.NewTimer(duration,callback)
	timer:Cancel()
	ticker=C_Timer.NewTicker(duration,callback,iterations)
	ticker:Cancel()
--]]--
----------------------------------------------------------------------------------------------------
local math,table,string,pairs,type,select,tonumber,unpack=math,table,string,pairs,type,select,tonumber,unpack;
local _G=_G;
local random=random;
table.empty=table.empty or function(t)
	return next(t)==nil;
end
table.unempty=table.unempty or function(t)
	return next(t)~=nil;
end
----------------------------------------------------------------------------------------------------
local GetTime=GetTime;
local tempty=table.empty;
local __alaBase_Version=1.02;
----------------------------------------------------------------------------------------------------
if __alaBase and __alaBase.Version>=__alaBase_Version then
	return;
end
------------------------
local f=__alaBase or CreateFrame("frame","__alaBase");
------------------------
f.delayaction=f.delayaction or {};
f:SetScript("OnUpdate",function(self,e)
	local now=GetTime();
	for k,v in pairs(self.delayaction) do
		if v.expire<=now then
			v.func(unpack(v.para));
			if v.period then
				v.expire=now+v.delay;
				if type(v.period)=="number" and v.period>0 then
					v.period=v.period-1;
					if v.period==0 then
						self.delayaction[k]=nil;
					end
				end
			else
				self.delayaction[k]=nil;
			end
		end
	end
end)
function delayCall(func,delay,period,...)
	if not func or type(func)~="function" then return;end
	delay=type(delay)=="number" and delay or tonumber(delay) or 0;
	--if not delay then delay=0 end
	--if delay<=0 and not period then func(...);return;end
	if delay<=0 then func(...);return;end
	if period and type(period)~="number" then period=tonumber(period) or true;end
	local i=1;
	while f.delayaction[i] do i=i+1;end
	f.delayaction[i]={func=func,expire=GetTime()+delay,delay=delay,period=(period==0 and 1 or period),para={...},};
	return i;
end
function editdCall(i,func,delay,period,...)
	if not i or not f.delayaction[i] then return;end
	if func and type(func)~="function" then return;end
	if not func then
    	f.delayaction[i]=nil;
		return i;
	end
	delay=type(delay)=="number" and delay or tonumber(delay) or 0;
	if delay<=0 then func(...);return;end
	if period and type(period)~="number" then period=tonumber(period) or true;end
	--if not delay then delay=0 end
	f.delayaction[i]={func=func,expire=GetTime()+delay,delay=delay,period=period,para={...},};
	return i;
end
function procCall(func,delay,...)
	return delayCall(func,delay,true,...);
end
------------------------
f.eventaction=f.eventaction or {};
f:SetScript("OnEvent",function(self,event,...)
	if not self.eventaction[event] then
	    self:UnregisterEvent(event);
		return;
	end
	if tempty(self.eventaction[event]) then
    	self:UnregisterEvent(event);
		self.eventaction[event]=nil;
		return;
	end
	for i,v in pairs(self.eventaction[event]) do
		v.func(v.para,event,...);
		if v.period then
			if type(v.period)=="number" and v.period>0 then
				v.period=v.period-1;
				if v.period<=0 then
    				self.eventaction[event][i]=nil;
				end
			end
		else
			self.eventaction[event][i]=nil;
		end
	end
end)
function eventCall(event,func,period,para)
	if not event and type(event)~="string" then return;end
	if not func or type(func)~="function" then return;end
	event=string.upper(event);
	if not f.eventaction[event] then
	   f.eventaction[event]={};
	   f:RegisterEvent(event);
	end
	local i=1;
	while f.eventaction[event][i] do i=i+1;end
	if period and type(period)~="number" then period=tonumber(period) or true;end
	--if period==0 then period=1;end
	f.eventaction[event][i]={func=func,period=period,para=para,};
	return i;
end
function editeCall(event,i,func,period,para)
	if not event and type(event)~="string" then return;end
	event=string.upper(event);
	if not i or not f.eventaction[event] or not f.eventaction[event][i] then return;end
	if not func then
    	f.eventaction[event][i]=nil;
		return i;
	end
	if func and type(func)~="function" then return;end
	if period and type(period)~="number" then period=tonumber(period) or true;end
	--if period==0 then period=1;end
	f.eventaction[event][i]={func=func,period=period,para=para,};
	return i;
end
------------------------
f.hookfTable=f.hookfTable or {};
function hookfCall(a1,a2,a3)
	local hookfTable=f.hookfTable;
	if type(a1)=="string" and type(_G[a1])=="function" and a2 then
		local hookedFunc=a1;
		local hookingFunc=nil;
		if type(a2)=="string" then
			hookingFunc=_G[a2];
		else
			hookingFunc=a2;
		end
		if type(hookingFunc)~="function" then
			return;
		end
		if not hookfTable[hookedFunc] then
			hookfTable[hookedFunc]={};
			hookfTable[hookedFunc].func=function(...)
				for _,func in pairs(hookfTable[hookedFunc].hook) do
					func(...);
				end
			end
			hookfTable[hookedFunc].hook={};
			hooksecurefunc(hookedFunc,hookfTable[hookedFunc].func);
		else
			for _,v in pairs(hookfTable[hookedFunc].hook) do
				if v==hookingFunc then
					return;
				end
			end
		end
		table.insert(hookfTable[hookedFunc].hook,hookingFunc);
	elseif type(a1)=="table" and type(a2)=="string" and type(a1[a2])=="function" and a3 then
		local hookedWidget=a1;
		local hookedFunc=a2;
		local hookingFunc=nil;
		if type(a3)=="string" then
			hookingFunc=_G[a3];
		else
			hookingFunc=a3;
		end
		if type(hookingFunc)~="function" then
			return;
		end
		hookfTable[hookedWidget]=hookfTable[hookedWidget] or {};
		if not hookfTable[hookedWidget][hookedFunc] then
			hookfTable[hookedWidget][hookedFunc]={};
			hookfTable[hookedWidget][hookedFunc].func=function(...)
				for _,func in pairs(hookfTable[hookedWidget][hookedFunc].hook) do
					func(...);
				end
			end
			hookfTable[hookedWidget][hookedFunc].hook={};
			hooksecurefunc(hookedWidget,hookedFunc,hookfTable[hookedWidget][hookedFunc].func);
		else
			for _,v in pairs(hookfTable[hookedWidget][hookedFunc].hook) do
				if v=="hookingFunc" then
					return;
				end
			end
		end
		table.insert(hookfTable[hookedWidget][hookedFunc].hook,hookingFunc);
	end
end
function delhfCall(a1,a2,a3)
	local hookfTable=f.hookfTable;
	if type(a1)=="string" and type(_G[a1])=="function" and a2 then
		local hookedFunc=a1;
		local hookingFunc=nil;
		if type(a2)=="string" then
			hookingFunc=_G[a2];
		else
			hookingFunc=a2;
		end
		if type(hookingFunc)~="function" then
			return;
		end
		if hookfTable[hookedFunc] then
			for i=#hookfTable[hookedFunc].hook,1,-1 do
				if hookfTable[hookedFunc].hook[i]==hookingFunc then
					table.remove(hookfTable[hookedFunc].hook,i);
				end
			end
		end
	elseif type(a1)=="table" and type(a2)=="string" and type(a1[a2])=="function" and a3 then
		local hookedWidget=a1;
		local hookedFunc=a2;
		local hookingFunc=nil;
		if type(a3)=="string" then
			hookingFunc=_G[a3];
		else
			hookingFunc=a3;
		end
		if type(hookingFunc)~="function" then
			return;
		end
		if hookfTable[hookedWidget][hookedFunc] then
			for i=#hookfTable[hookedWidget][hookedFunc].hook,1,-1 do
				if hookfTable[hookedWidget][hookedFunc].hook[i]==hookingFunc then
					table.remove(hookfTable[hookedWidget][hookedFunc].hook,i);
				end
			end
		end
	end
end
------------------------
f.hookwTable=f.hookwTable or {};
function hookwCall(hookedWidget,hookedHandler,hookingFunc)
	local hookwTable=f.hookwTable;
	if type(hookedWidget)=="string" then
		hookedWidget=_G[hookedWidget];
	end
	if type(hookingFunc)=="string" then
		hookingFunc=_g[hookingFunc];
	end
	if type(hookedWidget)~="table" or type(hookedHandler)~="string" or type(hookingFunc)~="function" then
		return;
	end
	hookwTable[hookedWidget]=hookwTable[hookedWidget] or {};
	if not hookwTable[hookedWidget][hookedHandler] then
		hookwTable[hookedWidget][hookedHandler]={};
		hookwTable[hookedWidget][hookedHandler].func=function(...)
			for _,func in pairs(hookwTable[hookedWidget][hookedHandler].hook) do
				func(...);
			end
		end
		hookwTable[hookedWidget][hookedHandler].hook={};
		hookedWidget:HookScript(hookedHandler,hookwTable[hookedWidget][hookedHandler].func);
	end
	table.insert(hookwTable[hookedWidget][hookedHandler].hook,hookingFunc);
end
function delhwCall(hookedWidget,hookedHandler,hookingFunc)
	local hookwTable=f.hookwTable;
	if type(hookedWidget)=="string" then
		hookedWidget=_G[hookedWidget];
	end
	if type(hookingFunc)=="string" then
		hookingFunc=_g[hookingFunc];
	end
	if type(hookedWidget)~="table" or type(hookedHandler)~="string" or type(hookingFunc)~="function" then
		return;
	end
	if hookwTable[hookedWidget][hookedHandler] then
		for i=#hookwTable[hookedWidget][hookedHandler].hook,1,-1 do
			if hookwTable[hookedWidget][hookedHandler].hook[i]==hookingFunc then
				table.remove(hookwTable[hookedWidget][hookedHandler].hook,i);
			end
		end
	end
end
------------------------
f.delayCall=delayCall;
f.editeCall=editeCall;
f.eventCall=eventCall;
f.editeCall=editeCall;
f.hookfCall=hookfCall;
f.delhfCall=delhfCall;
f.hookwCall=hookwCall;
f.delhwCall=delhwCall;
----------
__alaBase.Version=__alaBase_Version;
------------------------

