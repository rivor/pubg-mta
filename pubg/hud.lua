addEvent("insertnotification",true);
addEvent("showkill",true);

local roboto_bold = dxCreateFont("fonts/Roboto-Bold.ttf",42,true);
local roboto_regular = dxCreateFont("fonts/Roboto-Regular.ttf",42,false);
local roboto_regular1 = dxCreateFont("fonts/Roboto-Regular.ttf",12,false);
local roboto_regular3 = dxCreateFont("fonts/Roboto-Regular.ttf",62,false);
local bebasneue = dxCreateFont("fonts/BebasNeue.otf",42,false);

local sW,sH = guiGetScreenSize();

local playimage1 = dxCreateTexture("images/hud/play1.png","argb",true,"clamp");
local playimage2 = dxCreateTexture("images/hud/play2.png","argb",true,"clamp");

local ped;
local skins = {14,15,45,69,70,80,91,100}; -- available play skins

local mapWidth,mapHeight = 600,600; -- for gps
local gps_w = sH*0.21;
local gps_h = gps_w;
local gps_rt = dxCreateRenderTarget(gps_w,gps_h);

local fade = 255;
local fade_fadein = true;
local fade_fadeaway = false;

local anglex = 0;
local anglez = 30;

local showkill = "";
local notifications = {};

local chatting = false;
local chatedit = guiCreateEdit(0,0,0,0,"",false);
guiEditSetMaxLength(chatedit,40);
guiSetVisible(chatedit,false);

local invlistParent = guiCreateGridList(sW/2-125,sH/2-200,250,280,false);
guiSetVisible(invlistParent,false);
guiSetAlpha(invlistParent,0.8);
local invlistSearch = guiCreateEdit(0.02,0.025,1-0.04,0.1,"",true,invlistParent)
local invlistPlayers = guiCreateGridList(0.02,0.035+0.1,1-0.04,0.9-0.06-0.1,true,invlistParent);
guiGridListAddColumn(invlistPlayers,"Player",0.85);
local invlistInviteBtn = guiCreateButton(0.02,0.89,0.8,0.088,"Invite",true,invlistParent)
local invlistCloseBtn = guiCreateButton(0.8+0.03,0.89,0.14,0.088,"X",true,invlistParent)

function updateInvlist()
	guiGridListClear(invlistPlayers);
	for i,player in ipairs(getElementsByType("player")) do
		if (getElementDimension(player) == 0 and getElementData(player,"room") == "menu") then
			local row = guiGridListAddRow(invlistPlayers);
			guiGridListSetItemText(invlistPlayers,row,1,getPlayerName(player):gsub("#%x%x%x%x%x%x", ""),false,false);
		end
	end
end

function setMenuScreen()
	setElementData(localPlayer,"room","menu");
	setCameraMatrix(5079.15625,-135.69271850586,373.3,5084.1000976563,-132.30000305176,373.29998779297,0,70)
	showCursor(true)
end

function getGPSFromWorldPosition(x,y)
	local mW,mH = dxGetMaterialSize(gps_rt);
	local px,py = getElementPosition(localPlayer);
	return (mW/2-((px-x)/(6000/mapWidth))),(mW/2+((py-y)/(6000/mapWidth)));
end

function getGPSFromWorldRadius(radius)
	return radius/(6000/mapWidth);
end

addEventHandler("onClientResourceStart",resourceRoot,function()
	ped = createPed(skins[math.random(#skins)],5082.2001953125,-133.59999389648,372.79998779297,120)
	setPedAnimation(ped,"dealer","dealer_idle",nil,true,false);
	fadeCamera(true)
	showChat(false)
	setPlayerHudComponentVisible("all",false);
	setPlayerHudComponentVisible("crosshair",true)
	toggleControl("action",false);
	if (not getElementData(localPlayer,"room") or getElementData(localPlayer,"room") == "menu") then
		setMenuScreen()
	end
end);

addEventHandler("showkill",localPlayer,function(texttype,you,...)
	if (not checkAuthorized()) then return; end
	showkill = translateLocalization(texttype,nil,translateLocalization(you),...);
	if isTimer(notifications["timer3"]) then killTimer(notifications["timer3"]); end
	notifications["timer3"] = setTimer(function(translated)
		showkill = "";
	end,5*1000,6,translated);
end);

addEventHandler("insertnotification",localPlayer,function(texttype,...)
	if (not checkAuthorized()) then return; end
	local translated = translateLocalization(texttype,nil,...);
	if (not translated) then translated = texttype; end
	if (#notifications > 6) then table.remove(notifications,#notifications); end
	table.insert(notifications,1,{translated,120});
	if isTimer(notifications["timer1"]) then killTimer(notifications["timer1"]); end
	if isTimer(notifications["timer2"]) then killTimer(notifications["timer2"]); end
	notifications["timer1"] = setTimer(function(translated)
		for i=#notifications,1,-1 do
			local tableInt = i;
			notifications["timer2"] = setTimer(function(tableInt)
				if (notifications[tableInt]) then
					notifications[tableInt][2] = notifications[tableInt][2]-10;
					if (notifications[tableInt][2] <= 0) then
						table.remove(notifications,tableInt);
					end
				end
			end,50,12,tableInt)
			break;
		end
	end,5*1000,6,translated);
end);

addEventHandler("onClientPreRender",root,function()
	if (not checkAuthorized()) then return; end
	local task = getPedTask(localPlayer, "secondary", 0);
	local control = getPedControlState("aim_weapon");
	if ((task == "TASK_SIMPLE_USE_GUN") and control) then
		if (getPedWeapon(localPlayer) == 34) then
			for i=1,8 do
				local object = getElementData(localPlayer,"hide"..i);
				if (isElement(object)) then
					setElementPosition(object,0,0,0);
				end
			end
		end
	end
	local playzone = getElementByID("playzone");
	local dimension = getElementDimension(localPlayer);
	if (playzone) then
		local circle = getElementData(playzone,dimension.."_circle");
		if (circle) then
			local currLoc =getElementData(playzone,dimension.."_gas_location");
			if (currLoc) then
				local px,py = getElementPosition(localPlayer);
				local gasx,gasy = unpack(currLoc);
				local gasrad = getElementData(playzone,dimension.."_gas_radius");
				local playzonex,playzoney = unpack(getElementData(playzone,dimension.."_playzone_location"));
				local playzonerad = getElementData(playzone,dimension.."_playzone_radius");
				dxDrawGas(gasx,gasy,gasrad);
				if (not isPlayerInCircle(gasx,gasy,gasrad)) then
					dxDrawRectangle(0,0,sW,sH,tocolor(0,0,255,80),true);
				end
			end
		end
	end
end);

addEventHandler("onClientCursorMove",root,function(rx, ry, x, y)
	if (not checkAuthorized()) then return; end
	if (not isCursorShowing()) then
		local sx, sy = guiGetScreenSize();
		anglex = (anglex + (x - sx / 2) / 10) % 360;
		anglez = (anglez + (y - sy / 2) / 10) % 360;
		if (anglez > 180) then
			if (anglez < 300) then anglez = 300 end;
		else
			if (anglez > 60) then anglez = 60 end;
		end
	end
end)

local heightDetector = sH*0.03;

addEventHandler("onClientRender",root,function()
	if (not checkAuthorized()) then return; end
	local room = getElementData(localPlayer,"room");
	if (room ~= "playing") then
		if (getElementData(localPlayer,"inventory_visible")) then
			closeInventory()
		elseif (exports.pb_map:isPlayerMapVisible()) then
			exports.pb_map:setPlayerMapVisible(false);
		end
	end
	if (room == "menu") then
		local image = playimage1;
		local color = tocolor(255,255,255,150);
		if isCursorOnArea(0,0,sH*0.200,sH*0.100) then image = playimage2;color = tocolor(200,200,200,150); end
		dxDrawImage(0,0,sH*0.200,sH*0.100,image,0,0,0,tocolor(255,255,255));
		dxDrawImage(sW*0.99-sH*0.200,sH*0.99-sH*0.115,sH*0.200,sH*0.100,"images/hud/logo.png",0,0,0,tocolor(255,255,255));
		dxDrawText("OPEN ALPHA",sW*0.99-sH*0.200,sH*0.99-sH*0.115,sW*0.99-sH*0.200+sH*0.200,sH*0.99-sH*0.115+sH*0.100,tocolor(250,200,25),1*sH*0.001,"default-bold","center","bottom",false,false,false,false,false,0,0,0);
		local tW = dxGetTextWidth(translateLocalization("play"),1*sH*0.001,bebasneue);
		local color1 = tocolor(255,255,255);
		local color2 = tocolor(255,255,255);
		if isCursorOnArea(sW*0.4,sH*0.6,dxGetTextWidth("<",5*sH*0.001,"default-bold"),dxGetFontHeight(5*sH*0.001,"default-bold")) then color1 = tocolor(0,0,0); end
		if isCursorOnArea(sW*0.58,sH*0.6,dxGetTextWidth(">",5*sH*0.001,"default-bold"),dxGetFontHeight(5*sH*0.001,"default-bold")) then color2 = tocolor(0,0,0); end
		local playTextScale = 1*sH*0.001;
		local currLang = getElementData(localPlayer,"lang") or "en";
		if (currLang == "ru") then playTextScale = 0.5*sH*0.001; end
		dxDrawText(translateLocalization("play"),sH*0.010,sH*0.005,sH*0.200,sH*0.100,color,playTextScale,bebasneue,"left","center",false,false,false,false,false,0,0,0);
		dxDrawText("<",sW*0.4,sH*0.6,0,0,color1,5*sH*0.001,"default-bold","left","top",false,false,false,false,false,0,0,0);
		dxDrawText(">",sW*0.58,sH*0.6,0,0,color2,5*sH*0.001,"default-bold","left","top",false,false,false,false,false,0,0,0);
		-- lang selection
		dxDrawImage(sH*0.005,sH*0.105,sH*0.03,sH*0.03,"images/language.png",0,0,0,tocolor(255,255,255,255));
		local langcolor = tocolor(255,255,255);
		if (currLang == "en") then currLang = "English";
		elseif (currLang == "lv") then currLang = "Latviešu";
		elseif (currLang == "ru") then currLang = "Русский";
		end
		if isCursorOnArea(sH*0.005,sH*0.105,sH*0.05+dxGetTextWidth(currLang,1.5*sH*0.001,"default-bold"),heightDetector) then
			heightDetector = sH*0.04+sH*0.083;
			dxDrawImage(sH*0.005,sH*0.105,sH*0.03,sH*0.031,"images/language.png",0,0,0,tocolor(255,255,255,150));
			langcolor = tocolor(230,230,230,200);
			dxDrawRectangle(sH*0.005,sH*0.105+sH*0.04,sH*0.120,sH*0.083,tocolor(0,0,0,150));
			if (isCursorOnArea(sH*0.005,sH*0.105+sH*0.024+dxGetFontHeight(1.5*sH*0.001,"default"),sH*0.120,dxGetFontHeight(1.5*sH*0.001,"default")*1.05)) then
				dxDrawRectangle(sH*0.005,sH*0.105+sH*0.024+dxGetFontHeight(1.5*sH*0.001,"default"),sH*0.120,dxGetFontHeight(1.5*sH*0.001,"default")*1.05,tocolor(255,255,255,25));
			elseif (isCursorOnArea(sH*0.005,sH*0.105+sH*0.024+dxGetFontHeight(1.5*sH*0.001,"default")*2,sH*0.120,dxGetFontHeight(1.5*sH*0.001,"default")*1.05)) then
				dxDrawRectangle(sH*0.005,sH*0.105+sH*0.024+dxGetFontHeight(1.5*sH*0.001,"default")*2,sH*0.120,dxGetFontHeight(1.5*sH*0.001,"default")*1.05,tocolor(255,255,255,25));
			elseif (isCursorOnArea(sH*0.005,sH*0.105+sH*0.025+dxGetFontHeight(1.5*sH*0.001,"default")*3,sH*0.120,dxGetFontHeight(1.5*sH*0.001,"default")*1.05)) then
				dxDrawRectangle(sH*0.005,sH*0.105+sH*0.025+dxGetFontHeight(1.5*sH*0.001,"default")*3,sH*0.120,dxGetFontHeight(1.5*sH*0.001,"default")*1.05,tocolor(255,255,255,25));
			end
			dxDrawText("English",sH*0.005,sH*0.105+sH*0.035+dxGetFontHeight(1.5*sH*0.001,"default"),sH*0.005+sH*0.120,sH*0.105+sH*0.035+dxGetFontHeight(1.5*sH*0.001,"default"),tocolor(255,255,255),1.5*sH*0.001,"default","center","center",false,false,false);
			dxDrawText("Latviešu",sH*0.005,sH*0.105+sH*0.035+dxGetFontHeight(1.5*sH*0.001,"default")*2,sH*0.005+sH*0.120,sH*0.105+sH*0.035+dxGetFontHeight(1.5*sH*0.001,"default")*2,tocolor(255,255,255),1.5*sH*0.001,"default","center","center",false,false,false);
			dxDrawText("Русский",sH*0.005,sH*0.105+sH*0.035+dxGetFontHeight(1.5*sH*0.001,"default")*3,sH*0.005+sH*0.120,sH*0.105+sH*0.035+dxGetFontHeight(1.5*sH*0.001,"default")*3,tocolor(255,255,255),1.5*sH*0.001,"default","center","center",false,false,false);
		else
			heightDetector = sH*0.03;
		end
		dxDrawText(currLang,sH*0.005+sH*0.04,sH*0.105,sH*0.005+sH*0.03,sH*0.105+sH*0.03,langcolor,1.5*sH*0.001,"default-bold","left","center",false,false,false,false,false,0,0,0);
		-- invite section
		--local ilText = "Players in lobby 100";
		--local ilText2 = "Invite";
		--local ilFont = "default-bold";
		--local ilFontSize = 1*sH*0.001;
		--local ilRGB = tocolor(255,255,255,200);
		--if (isCursorOnArea(sW*0.01+dxGetTextWidth(ilText,ilFontSize,ilFont)*1.15,sH-sH*0.03,sH*0.225-dxGetTextWidth(ilText,ilFontSize,ilFont),sH*0.025)) then
		--	ilRGB = tocolor(155,155,155,200);
		--end
		--dxDrawRectangle(sW*0.01,sH-sH*0.035,dxGetTextWidth(ilText,ilFontSize,ilFont)*1.2+sH*0.225-dxGetTextWidth(ilText,ilFontSize,ilFont),sH*0.035,tocolor(0,0,0,155));
		--dxDrawText(ilText,sW*0.015,sH-sH*0.035,sW*0.01+sH*0.255,sH-sH*0.035+sH*0.035,tocolor(255,255,255),ilFontSize,ilFont,"left","center");
		--dxDrawRectangle(sW*0.01+dxGetTextWidth(ilText,ilFontSize,ilFont)*1.15,sH-sH*0.03,sH*0.225-dxGetTextWidth(ilText,ilFontSize,ilFont),sH*0.025,ilRGB);
		--dxDrawText(ilText2,sW*0.01+dxGetTextWidth(ilText,ilFontSize,ilFont)*1.15,sH-sH*0.03,sW*0.01+dxGetTextWidth(ilText,ilFontSize,ilFont)*1.15+sH*0.225-dxGetTextWidth(ilText,ilFontSize,ilFont),sH-sH*0.03+sH*0.025,tocolor(0,0,0),ilFontSize,ilFont,"center","center");
	elseif (room == "lobby") then
		local lobby = getElementByID("lobby");
		if (lobby) then
			local players = getElementData(lobby,"players");
			local neededplayers = getElementData(lobby,"neededplayers");
			local startsin = getElementData(lobby,"startsin");
			local text = translateLocalization("lobby1",nil,players,neededplayers);
			if (startsin) then
				text = text.."\n"..translateLocalization("lobby2",nil,startsin);
			end
			dxDrawText(text,0,sH*0.505,sW,sH,tocolor(0,0,0),0.5*sH*0.001,bebasneue,"center","center",false,false,true,false,false,0,0,0);
			dxDrawText(text,0,sH*0.5,sW,sH,tocolor(255,255,255),0.5*sH*0.001,bebasneue,"center","center",false,false,true,false,false,0,0,0);
		end
	elseif (room == "dead") then
		showCursor(true)

		local name = getPlayerName(localPlayer):gsub("#%x%x%x%x%x%x", "");
		local rank = getElementData(localPlayer,"rank") or 0;
		local totalplayers = getElementData(localPlayer,"totalplayers") or 0;
		local kills = getElementData(localPlayer,"killed") or 0;

		local text = translateLocalization("dead1");
		if (rank == 1) then text = translateLocalization("dead2"); end

		dxDrawRectangle(0,0,sW,sH,tocolor(0,0,0,200),true);
		dxDrawText(name,sW*0.08,sH*0.08,sW*0.92,0,tocolor(255,255,255),5*sH*0.001,"default-bold","left","top",false,false,true);
		dxDrawText(text,sW*0.08,sH*0.15,0,0,tocolor(250,200,25),3*sH*0.001,"default-bold","left","top",false,false,true);
		-- rank
		local tw = dxGetTextWidth("/"..totalplayers,1*sH*0.001,roboto_regular);
		local th = dxGetFontHeight(1*sH*0.001,roboto_regular3);
		dxDrawText("#"..rank,sW*0.08,sH*0.05,sW*0.92-tw,0,tocolor(250,200,25),1*sH*0.001,roboto_regular3,"right","top",false,false,true);
		dxDrawText("/"..totalplayers,sW*0.08,sH*0.05,sW*0.92,sH*0.035+th,tocolor(99,99,99),1*sH*0.001,roboto_regular,"right","bottom",false,false,true);
		-- stats
		dxDrawText(translateLocalization("rank").." ",sW*0.08,sH*0.35,sW*0.92,0,tocolor(255,255,255,180),3*sH*0.001,"arial","left","top",false,false,true);
		dxDrawText(" #"..rank,sW*0.08+dxGetTextWidth(translateLocalization("rank"),3*sH*0.001,"arial"),sH*0.35,sW*0.92,0,tocolor(255,255,255),3*sH*0.001,"default-bold","left","top",false,false,true);
		dxDrawText(translateLocalization("kill").." ",sW*0.25,sH*0.35,sW*0.92,0,tocolor(255,255,255,180),3*sH*0.001,"arial","left","top",false,false,true);
		dxDrawText(" "..kills,sW*0.25+dxGetTextWidth(translateLocalization("kill"),3*sH*0.001,"arial"),sH*0.35,sW*0.92,0,tocolor(255,255,255),3*sH*0.001,"default-bold","left","top",false,false,true);
		dxDrawText(" "..translateLocalization("players"),sW*0.25+dxGetTextWidth(translateLocalization("kill").." ",3*sH*0.001,"arial")+dxGetTextWidth(kills,3*sH*0.001,"default-bold"),sH*0.35,sW*0.92,sH*0.343+dxGetFontHeight(3*sH*0.001,"default-bold"),tocolor(255,255,255,120),1.5*sH*0.001,"arial","left","bottom",false,false,true);
		-- button
		local exitdeadtext = translateLocalization("exitdead");
		local exitdeadTW = dxGetTextWidth(exitdeadtext,1.5*sH*0.001,"default-bold");
		local color = tocolor(80,80,80);
		if (isCursorOnArea(sW*0.9-exitdeadTW*1.5,sH*0.85,exitdeadTW*1.5,sH*0.04)) then
			color = tocolor(100,100,100);
		end
		dxDrawRectangle(sW*0.9-exitdeadTW*1.5,sH*0.85,exitdeadTW*1.5,sH*0.04,color,true);
		dxDrawText(exitdeadtext,sW*0.9-exitdeadTW*1.5,sH*0.85,sW*0.9-exitdeadTW*1.5+exitdeadTW*1.5,sH*0.85+sH*0.04,tocolor(255,255,255,180),1.5*sH*0.001,"default-bold","center","center",false,false,true);
	elseif (room == "playing") then
		if (getElementData(localPlayer,"inplane")) then
			local x,y,z = getElementPosition(getElementData(localPlayer,"plane"));
			local ox, oy, oz
			ox = x-math.sin(math.rad(anglex))*50
			oy = y-math.cos(math.rad(anglex))*50
			oz = z+math.tan(math.rad(anglez))*50
			setCameraMatrix(ox,oy,oz,x,y,z)
			if (getElementData(localPlayer,"canparachute")) then
				drawActionWindow(translateLocalization("exitplane"))
			end
		elseif (getPedWeapon(localPlayer) == 46) then
			drawActionWindow(translateLocalization("parachute"))
		end
		-- show killed enemy
		if (showkill ~= "") then
			local killed = getElementData(localPlayer,"killed") or 0;
			dxDrawText(showkill:gsub("#%x%x%x%x%x%x",""),0+sH*0.003,sH*0.3+sH*0.003,sW,sH,tocolor(0,0,0),0.3*sH*0.001,roboto_regular3,"center","center",false,false,false)
			dxDrawText(showkill:gsub("#%x%x%x%x%x%x",""),0,sH*0.3,sW,sH,tocolor(255,255,255),0.3*sH*0.001,roboto_regular3,"center","center",false,false,false)
			dxDrawText(translateLocalization("kills",nil,killed),0+sH*0.003,sH*0.37+sH*0.003,sW,sH,tocolor(0,0,0),0.5*sH*0.001,roboto_bold,"center","center",false,false,false)
			dxDrawText(translateLocalization("kills",nil,killed),0,sH*0.37,sW,sH,tocolor(200,35,50),0.5*sH*0.001,roboto_bold,"center","center",false,false,false)
		end
		-- health bar
		local healthW,healthH = sH*0.38,sH*0.026;
		dxDrawRectangle(sW*0.5-healthW*0.5,sH-healthH*1.5,healthW,healthH,tocolor(180,180,180,80),true)
		local health = getElementHealth(localPlayer);
		local by = health/100
		if (health <= 35) then
			if fade_fadein then
				fade = fade+3;
				if fade >= 200 then
					fade = 200;
					fade_fadein = false;
					fade_fadeaway = true;
				end
			end
			if fade_fadeaway then
				fade = fade-5;
				if fade <= 35 then
					fade = 35;
					fade_fadeaway = false;
					fade_fadein = true;
				end
			end
		else
			fade = 180;
		end
		--if (g <= 185 or b <= 185) then g=g+70;b=b+70; end
		if (healing.amount) then
			local healamount = healing.amount/100;
			healamount = healamount+by;
			if (healamount > 1) then healamount = 1; end
			dxDrawRectangle(sW*0.5-healthW*0.5,sH-healthH*1.5,healthW*healamount,healthH,tocolor(200,200,200,100),true)
		end
		dxDrawRectangle(sW*0.5-healthW*0.5,sH-healthH*1.5,healthW*by,healthH,tocolor(200,200,200,fade),true)
		-- weapon hud
		for i=1,5 do
			local wepname = getElementData(localPlayer,"weapon"..i) or "";
			local currWep = getPedWeapon(localPlayer);
			local currS = getPedWeaponSlot(localPlayer);
			if (wepname ~= "" and weapons[wepname] and weapons[wepname][2] == currWep and weapons[wepname][3] == currS) then
				local height = sH*0.062;
				local side_offset = sH*0.1
				if (wepname == "mp5" or wepname == "machete" or wepname == "crowbar" or wepname == "colt45" or wepname == "uzi" or wepname == "pan") then
					side_offset = sH*0.13;
				end
				if (wepname == "grenade" or wepname == "molotov") then
					side_offset = sH*0.17;
				end
				dxDrawImage(sW*0.5-healthW*0.5+side_offset,sH-height*1.8,healthW-side_offset*2,height,"images/hud/weapons/"..wepname..".png",0,0,0,tocolor(255,255,255),true);
				local font_size = 2.5*sH*0.001;
				if (i ~= 4) then
					local clip = getPedAmmoInClip(localPlayer);
					local ammo = getElementData(localPlayer,weapons[wepname][5])-clip;
					if (i == 5) then
						clip = getElementData(localPlayer,weapons[wepname][5]);
						ammo = 0;
					end
					local tW = dxGetTextWidth(clip,font_size,"default-bold")
					local tH = dxGetFontHeight(font_size,"default-bold")
					dxDrawText(clip,sW*0.5-healthW*0.5,sH-height*1.8-tH,sW*0.5-healthW*0.5+healthW,sH-height*1.8+height,tocolor(255,255,255),font_size,"default-bold","center","top",false,false,true);
					if (ammo ~= 0) then
						dxDrawImage(sW*0.5+tW/2,sH-height*1.64-tH,sH*0.015,sH*0.02,"images/hud/bullet.png",0,0,0,tocolor(255,255,255),true);
						local font_size2 = 1.5*sH*0.001;
						local tW2 = dxGetTextWidth(ammo,font_size2,"default-bold")
						local tH2 = dxGetFontHeight(font_size2,"default-bold")
						dxDrawText(ammo,sW*0.5+(sH*0.0175+tW/2),sH-height*1.87-tH2,sW*0.5-healthW*0.5+healthW,sH-height*1.8+height,tocolor(255,255,255),font_size2,"default-bold","left","top",false,false,true);
					end
				end
			end
		end
		-- compass
		if (not getElementData(localPlayer,"inventory_visible")) then
			local _,_,rot = getElementRotation(getCamera()) 
			local pos = rot/360;
			local x,y,w,h = sW/2-sH*0.65/2,sH*0.02,sH*0.65,sH*0.04
			dxDrawImageSection(x,y,w,h,660+(-pos*2400),0,1100,72,"images/hud/compass.png");
			dxDrawImage((x+w/2)-sW*0.015/2,y-sH*0.016/2.5,sH*0.016,sH*0.016,"images/hud/arrow.png",0,0,0,tocolor(255,255,255));
			--dxDrawImage((x+w/2)-19/2,y-16/2.5,19,16,"images/hud/arrow.png",0,0,0,tocolor(255,255,255));
		end
		-- alive players
		local alive = #getAlivePlayersInDimension(getElementDimension(localPlayer));
		local text = translateLocalization("alive");
		local font_size = 2.2*sH*0.001;
		local tW = dxGetTextWidth(text,font_size,"default-bold")
		local tH = dxGetFontHeight(font_size,"default-bold")
		local tW2 = dxGetTextWidth(alive,font_size,"default-bold")*1.3
		dxDrawRectangle(sW*0.99-tW,sH*0.02,tW,tH,tocolor(180,180,180,230),true);
		dxDrawText(text,sW*0.99-tW,sH*0.02,sW*0.99,sH*0.022+tH,tocolor(100,100,100,150),font_size*0.95,"default-bold","center","center",false,false,true,false,false,0,0,0);
		dxDrawRectangle(sW*0.99-tW-tW2,sH*0.02,tW2,tH,tocolor(0,0,0,200),true);
		dxDrawText(alive,sW*0.99-tW-tW2,sH*0.02,sW*0.99-tW,sH*0.022+tH,tocolor(255,255,255),font_size*0.95,"default-bold","center","center",false,false,true,false,false,0,0,0);
		-- killed players
		if (getElementData(localPlayer,"inventory_visible")) then
			local killed = getElementData(localPlayer,"killed") or 0;
			local killedtext = translateLocalization("killed");
			local killed_tW = dxGetTextWidth(killedtext,font_size,"default-bold")
			local killed_tW2 = dxGetTextWidth(killed,font_size,"default-bold")*1.3
			dxDrawRectangle(sW*0.99-killed_tW-(tW+tW2)*1.1,sH*0.02,killed_tW,tH,tocolor(180,180,180,230),true);
			dxDrawText(killedtext,sW*0.99-killed_tW-(tW+tW2)*1.1,sH*0.02,sW*0.99-(tW+tW2)*1.1,sH*0.022+tH,tocolor(100,100,100,150),font_size*0.95,"default-bold","center","center",false,false,true,false,false,0,0,0);
			dxDrawRectangle(sW*0.99-killed_tW-killed_tW2-(tW+tW2)*1.1,sH*0.02,killed_tW2,tH,tocolor(0,0,0,200),true);
			dxDrawText(killed,sW*0.99-killed_tW-killed_tW2-(tW+tW2)*1.1,sH*0.02,sW*0.99-killed_tW-(tW+tW2)*1.1,sH*0.022+tH,tocolor(255,255,255),font_size*0.95,"default-bold","center","center",false,false,true,false,false,0,0,0);
		else
			if (not exports.pb_map:isPlayerMapVisible()) then
				-- playzone indicator
				local playzone = getElementByID("playzone");
				local dimension = getElementDimension(localPlayer);
				local px,py = getElementPosition(localPlayer);
				local mW,mH = dxGetMaterialSize(gps_rt);
				local x,y = sW*0.99-mW,sH*0.94-mH;
				if (playzone) then
					local circle = getElementData(playzone,dimension.."_circle");
					local countdown = getElementData(playzone,dimension.."_countdown");

					if (not countdown) then y = sH*0.96-mH; end

					if (circle or countdown) then
						dxDrawRectangle(x,y,mW,sH*0.010,tocolor(0,0,0,50),true);
						dxDrawRectangle(x,y,sH*0.010,sH*0.010,tocolor(0,0,255,150),true);
						dxDrawRectangle(x+mW-sH*0.010,y,sH*0.010,sH*0.010,tocolor(255,255,255,150),true);
					end

					if (circle) then
						local currLoc = getElementData(playzone,dimension.."_gas_location");
						if (currLoc) then
							local startgasx,startgasy = unpack(getElementData(playzone,dimension.."_startgas_location"));
							local gasx,gasy = unpack(currLoc);
							local gasrad = getElementData(playzone,dimension.."_gas_radius");
							local playzonex,playzoney = unpack(getElementData(playzone,dimension.."_playzone_location"));
							local playzonerad = getElementData(playzone,dimension.."_playzone_radius");
							local orgDist = getDistanceBetweenPoints2D(startgasx,startgasy,playzonex,playzoney);
							local pDist = getDistanceBetweenPoints2D(startgasx,startgasy,px,py);
							local currDist = getDistanceBetweenPoints2D(gasx,gasy,playzonex,playzoney);
							local dist = (orgDist-currDist)/orgDist;
							dxDrawRectangle(x+sH*0.010,y,(mW-sH*0.020)*dist,sH*0.010,tocolor(0,0,255,80),true);
							local relDist = (((orgDist+currDist)+playzonerad)-pDist)/(orgDist+currDist)
							if (relDist < 0) then relDist = 0; end
							if (relDist > 1) then relDist = 1; end
							dxDrawImage(((x+sH*0.010)-(sH*0.050/2))+(mW-sH*0.020)*relDist,y-sH*0.050/1.5,sH*0.050,sH*0.050,"images/hud/runner.png",0,0,0,tocolor(255,255,255,200),true);
						end
					end

					if (countdown) then
						dxDrawText(secondsToMinutes(math.round(countdown/1000,0)),x,y+sH*0.010,x,y+sH*0.010,tocolor(255,255,255),1.5*sH*0.001,"default-bold","left","top",false,false,true);
					end
				end
				-- gps
				local mW,mH = dxGetMaterialSize(gps_rt);
				local x,y = sW*0.99-mW,sH*0.987-mH;
				local xx,yy = mW/2-(px/(6000/mapWidth)), mH/2+(py/(6000/mapHeight));
				local _,_,cZ = getElementRotation(getCamera());

				dxDrawRectangle(x-2,y-2,mW+4,mH+4,tocolor(170,170,170,150),true);
				dxSetRenderTarget(gps_rt,true);
				dxDrawRectangle(0, 0, mW, mH, 0xFF3D5054);
				dxDrawImage(xx-mapWidth/2,yy-mapHeight/2,mapWidth,mapHeight,"images/map.jpg",0,0,0,tocolor(255,255,255));

				-- horizontal lines
				for i=1,7 do
					local x1,y1 = getGPSFromWorldPosition(-3000,-3000+750*i);
					local x2,y2 = getGPSFromWorldPosition(3000,-3000+750*i);
					dxDrawLine(x1,y1,x2,y2,tocolor(255,255,255),1);
				end
				-- vertical lines
				for i=1,7 do
					local x1,y1 = getGPSFromWorldPosition(-3000+750*i,-3000);
					local x2,y2 = getGPSFromWorldPosition(-3000+750*i,3000);
					dxDrawLine(x1,y1,x2,y2,tocolor(255,255,255),1);
				end

				if (playzone) then
					local circle = getElementData(playzone,dimension.."_circle");
					if (circle) then
						local currLoc = getElementData(playzone,dimension.."_gas_location");
						local gasx,gasy;
						local gasrad = getElementData(playzone,dimension.."_gas_radius");
						local playzonex,playzoney = unpack(getElementData(playzone,dimension.."_playzone_location"));
						local playzonerad = getElementData(playzone,dimension.."_playzone_radius");

						if (currLoc) then
							gasx,gasy = getGPSFromWorldPosition(unpack(currLoc));
							gasrad = getGPSFromWorldRadius(gasrad);
						end
						playzonex,playzoney = getGPSFromWorldPosition(playzonex,playzoney);

						if (playzonerad > 0) then
							local x,y = unpack(getElementData(playzone,dimension.."_playzone_location"));
							if (not isPlayerInCircle(x,y,playzonerad) and playzonerad > 0) then
								dxDrawLine(mW/2,mH/2,playzonex,playzoney,tocolor(255,255,255),1);
							end

							playzonerad = getGPSFromWorldRadius(playzonerad);

							dxDrawCircle(playzonex,playzoney,playzonerad,tocolor(255,255,255),2);
						end
						if (gasx and gasrad > 0) then
							dxDrawCircle(gasx,gasy,gasrad,tocolor(0,0,255),2);
						end
					end
				end
				dxDrawImage(mW/2-16,mH/2-16,32,32,"images/hud/p_circle.png",0,0,0,tocolor(255,255,255));
				dxDrawImage(mW/2-16,mH/2-16,32,32,"images/hud/p_location.png",-cZ,0,0,tocolor(255,255,255));
				dxSetRenderTarget();
				dxDrawImage(x,y,mW,mH,gps_rt,0,0,0,tocolor(255,255,255),true);
			end
		end
	end
	if (room == "lobby" or room == "playing") then
		if (not getElementData(localPlayer,"inventory_visible")) then
			-- notification/chat block
			local font,fsize = roboto_regular,0.28*sH*0.001;
			local fH = dxGetFontHeight(fsize,font);
			for i,v in ipairs(notifications) do
				local tW = dxGetTextWidth(v[1]:gsub("#%x%x%x%x%x%x",""),fsize,font);
				dxDrawRectangle(sW*0.01,sH*0.8-fH*i*1.1,tW+sH*0.003,fH,tocolor(0,0,0,v[2]),false);
				dxDrawText(v[1],sW*0.01,sH*0.8-fH*i*1.1,sW*0.01+tW+sH*0.003,sH*0.8+fH-fH*i*1.1,tocolor(180,180,180,v[2]+50),fsize,font,"center","center",false,false,false,true)
			end
			if (chatedit and guiGetVisible(chatedit)) then
				local text = guiGetText(chatedit);
				local text = "Lobby: "..text:gsub("#%x%x%x%x%x%x","");
				local tW = dxGetTextWidth(text,fsize,font);
				dxDrawRectangle(sW*0.01,sH*0.825-fH,tW+sH*0.003,fH,tocolor(0,0,0,120),false);
				dxDrawText(text,sW*0.01,sH*0.825-fH,sW*0.01+tW+sH*0.003,sH*0.825+fH-fH,tocolor(200,200,200,100),fsize,font,"center","center",false,false,false)
			end
		end
	end
	local ping = getPlayerPing(localPlayer);
	if (ping > 500) then
		dxDrawRectangle(0,0,sW,sH,tocolor(0,0,0,200),true);
		dxDrawText("NETWORK TROUBLE!",0,0,sW,sH,tocolor(255,255,255),1.5*sH*0.001,"default-bold","center","center",false,false,true);
		setElementFrozen(localPlayer,true);
	else
		setElementFrozen(localPlayer,false);
	end
end);

bindKey("mouse1","down",function()
	if (not checkAuthorized()) then return; end
	local room = getElementData(localPlayer,"room");
	if (room == "menu") then
		if (isCursorOnArea(0,0,sH*0.200,sH*0.100)) then
			local skin = getElementModel(ped);
			triggerServerEvent("lobby",localPlayer,skin);
			showCursor(false);
		elseif (isCursorOnArea(sW*0.4,sH*0.6,dxGetTextWidth("<",5,"default-bold"),dxGetFontHeight(5,"default-bold"))) then
			local currSkin = getElementModel(ped);
			local newSkin;
			for i=1,#skins do
				local skin = skins[i];
				if (currSkin == 14) then newSkin = 100; end
				if skin == currSkin then break; end
				newSkin = skin;
			end
			setElementModel(ped,newSkin);
		elseif (isCursorOnArea(sW*0.58,sH*0.6,dxGetTextWidth(">",5,"default-bold"),dxGetFontHeight(5,"default-bold"))) then
			local currSkin = getElementModel(ped);
			local newSkin;
			for i=#skins,1,-1 do
				local skin = skins[i];
				if (currSkin == 100) then newSkin = 14; end
				if skin == currSkin then break; end
				newSkin = skin;
			end
			setElementModel(ped,newSkin);
		elseif (isCursorOnArea(sH*0.005,sH*0.105+sH*0.024+dxGetFontHeight(1.5*sH*0.001,"default"),sH*0.120,dxGetFontHeight(1.5*sH*0.001,"default")*1.05)) then
			if (heightDetector <= sH*0.03) then return; end
			setElementData(localPlayer,"lang","en")
		elseif (isCursorOnArea(sH*0.005,sH*0.105+sH*0.024+dxGetFontHeight(1.5*sH*0.001,"default")*2,sH*0.120,dxGetFontHeight(1.5*sH*0.001,"default")*1.05)) then
			if (heightDetector <= sH*0.03) then return; end
			setElementData(localPlayer,"lang","lv")
		elseif (isCursorOnArea(sH*0.005,sH*0.105+sH*0.025+dxGetFontHeight(1.5*sH*0.001,"default")*3,sH*0.120,dxGetFontHeight(1.5*sH*0.001,"default")*1.05)) then
			if (heightDetector <= sH*0.03) then return; end
			setElementData(localPlayer,"lang","ru")
		elseif (isCursorOnArea(sW*0.01+dxGetTextWidth("Players in lobby 100",1*sH*0.001,"default-bold")*1.15,sH-sH*0.03,sH*0.225-dxGetTextWidth("Players in lobby 100",1*sH*0.001,"default-bold"),sH*0.025)) then
			guiSetVisible(invlistParent,not guiGetVisible(invlistParent))
			updateInvlist()
		end
	elseif (room == "dead") then
		local exitdeadtext = translateLocalization("exitdead");
		local exitdeadTW = dxGetTextWidth(exitdeadtext,1.5*sH*0.001,"default-bold");
		if (isCursorOnArea(sW*0.9-exitdeadTW*1.5,sH*0.85,exitdeadTW*1.5,sH*0.04)) then
			triggerServerEvent("returnToLobby",localPlayer);
		end
	end
end);

bindKey("f","down",function()
	if (not checkAuthorized()) then return; end
	if (getElementData(localPlayer,"inplane") and getElementData(localPlayer,"canparachute")) then
		triggerServerEvent("exitplane",localPlayer);
	end
end);

addEventHandler("onClientKey",root,function(button,press)
	local room = getElementData(localPlayer,"room");
	if (button == "escape" and press) then
		if (chatting) then
			cancelEvent();
			chatting = false;
			guiSetVisible(chatedit,false);
			guiSetInputMode(false);
		end
	elseif (button == "t" and press) then
		if (not chatting) then
			if (room == "lobby" or getElementData(localPlayer,"vip")) then
				chatting = true;
				setTimer(function()
					guiSetVisible(chatedit,true);
					guiBringToFront(chatedit);
					guiSetInputMode(true)
				end,50,1);
			end
		end
	elseif (button == "enter" and press) then
		if (chatting and guiGetText(chatedit) ~= "" and room == "lobby" or chatting and guiGetText(chatedit) ~= "" and getElementData(localPlayer,"vip")) then
			triggerServerEvent("sendChatMessage",localPlayer,getPlayerName(localPlayer):gsub("#%x%x%x%x%x%x","")..": "..guiGetText(chatedit):gsub("#%x%x%x%x%x%x",""));
			guiSetVisible(chatedit,false);
			guiSetText(chatedit,"");
			guiSetInputMode(false);
			chatting = false;
		else
			guiSetVisible(chatedit,false);
			guiSetText(chatedit,"");
			guiSetInputMode(false);
			chatting = false;
		end
	elseif (button == "mouse1" and press) then
		if (chatting) then
			guiSetVisible(chatedit,false);
			guiSetText(chatedit,"");
			guiSetInputMode(false);
			chatting = false;
		end
	end
end);