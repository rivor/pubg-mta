local sW,sH = guiGetScreenSize();
local roboto_bold = dxCreateFont("fonts/Roboto-Bold.ttf",12,false);
local roboto_regular = dxCreateFont("fonts/Roboto-Regular.ttf",12,false);

local drag = {active = false,source = false,object = false,item = false}
local splt = {active = false,source = false,object = false,action = false,amount = false,item = false};

local ground = {rt = dxCreateRenderTarget(sW*0.155,sH*0.6,true),scroll = 0}
local inventory = {rt = dxCreateRenderTarget(sW*0.155,sH*0.6,true),scroll = 0}

healing = {item=false,timer=false,amount=false};

local ped = createPed(getElementModel(localPlayer),0,0,0,0,false);
local preview = exports.pb_preview:createObjectPreview(ped,0,0,180,0,0,sW,sH,false,true);
exports.pb_preview:setPositionOffsets(preview,0,0,-(100*sH*0.001))

local inv_blur = exports.pb_blur:createBlurBox(0,0,sW,sH,255,255,255,255,false);
exports.pb_blur:setScreenResolutionMultiplier(0.5,0.5)
exports.pb_blur:setBlurIntensity(5)
exports.pb_blur:setBlurBoxEnabled(inv_blur,false);

addEventHandler("onClientResourceStop",resourceRoot,function()
	exports.pb_preview:destroyObjectPreview(preview);
	exports.pb_blur:destroyBlurBox(inv_blur);
end);

function openInventory()
	if (not checkAuthorized()) then return; end
	if (exports.pb_map:isPlayerMapVisible()) then
		exports.pb_map:setPlayerMapVisible(false);
	end
	setElementData(localPlayer,"inventory_visible",true);
	toggleControl("fire",false);
	toggleControl("aim_weapon",false);
	setElementModel(ped,getElementModel(localPlayer))
	exports.pb_preview:setPositionOffsets(preview,0,1.5,0.1)
	exports.pb_blur:setBlurBoxEnabled(inv_blur,true);
end

function closeInventory()
	if (not checkAuthorized()) then return; end
	setElementData(localPlayer,"inventory_visible",false);
	toggleControl("fire",true);
	toggleControl("aim_weapon",true);
	disableDrag()
	disableSplit()
	exports.pb_preview:setPositionOffsets(preview,0,0,-100)
	exports.pb_blur:setBlurBoxEnabled(inv_blur,false);
end

bindKey("TAB","down",function()
	local room = getElementData(localPlayer,"room");
	if (room == "playing") then
		if (not getElementData(localPlayer,"inventory_visible")) then
			showCursor(true,false);
			openInventory()
		else
			showCursor(false);
			closeInventory()
		end
	end
end)

function getPlayerItems()
	local pitems = {};
	for i,v in ipairs(items) do
		local pitem = getElementData(localPlayer,v[1]);
		if (pitem and pitem >= 1) then
			table.insert(pitems,{v[1],pitem})
		end
	end
	return pitems;
end

function getGroundItems()
	local gitems = {};
	local nearitems = getElementsWithinColShape(getElementData(localPlayer,"col"),"object");
	for i,v in ipairs(items) do
		for ii,vv in ipairs(nearitems) do
			local pdimension = getElementDimension(localPlayer);
			local idimension = getElementDimension(vv);
			if (pdimension == idimension) then
				local nitem = getElementData(vv,v[1]);
				if (nitem and nitem >= 1) then
					table.insert(gitems,{vv,v[1],nitem})
				end
			end
		end
	end
	return gitems;
end

function countWeight()
	local playerWeight = 50;
	local backpackWeight = slots[getElementData(localPlayer,"backpack")] or 0;
	local armorWeight = slots[getElementData(localPlayer,"armor")] or 0;
	local maxWeight = playerWeight+backpackWeight+armorWeight;
	local currWeight = 0;
	for i,v in ipairs(getPlayerItems()) do
		local item = v;
		for i,v in ipairs(items) do
			if item[1] == v[1] then
				currWeight = currWeight+(v[4]*item[2]);
			end
		end
	end
	return currWeight,maxWeight;
end

function drawGroundItems()
	dxSetRenderTarget(ground.rt,true);
	if (not drag.active and drag.source == "ground") then drag.source = false; drag.object = false; drag.item = false; end
	for i,v in ipairs(getGroundItems()) do
		i=i-1;
		if (isCursorOnArea(sW*0.015,sH*0.2,sW*0.155,sH*0.6) and isCursorOnArea(sW*0.015,sH*0.2+(i*sH*0.0542)-ground.scroll,sW*0.155,sH*0.052) and not drag.active) then
			drag.source = "ground";
			drag.item = v[2];
			drag.object = v[1];
			dxDrawRectangle(0,(i*sH*0.054)-ground.scroll,sH*0.052,sH*0.052,tocolor(255,255,255,150));
			dxDrawImage(0,(i*sH*0.054)-ground.scroll,sH*0.052,sH*0.052,"images/inventory/icons/"..v[2]..".png",0,0,0,tocolor(255,255,255));
			dxDrawRectangle(sH*0.052,(i*sH*0.054)-ground.scroll,sW*0.155-sH*0.05,sH*0.052,tocolor(255,255,255,130));
			dxDrawLine(0,((i*sH*0.054)-ground.scroll)+sH*0.052-1,sW*0.155,((i*sH*0.054)-ground.scroll)+sH*0.052-1,tocolor(255,255,255,150),2);
			dxDrawText(translateLocalization(v[2]),sH*0.057,(i*sH*0.054)-ground.scroll,sW*0.155,(i*sH*0.054)-ground.scroll+sH*0.052,tocolor(255,255,255),1,"default","left","center",true,false,false,false,false,0,0,0);
			if (v[3] > 1) then
				dxDrawText(v[3],sH*0.06,(i*sH*0.054)-ground.scroll,sW*0.15,(i*sH*0.054)-ground.scroll+sH*0.052,tocolor(255,255,255),1,"default","right","center",true,false,false,false,false,0,0,0);
			end
		elseif (drag.source == "ground" and drag.object ~= v[1] or drag.source ~= "ground") then
			dxDrawRectangle(0,(i*sH*0.054)-ground.scroll,sH*0.052,sH*0.052,tocolor(255,255,255,120));
			dxDrawImage(0,(i*sH*0.054)-ground.scroll,sH*0.052,sH*0.052,"images/inventory/icons/"..v[2]..".png",0,0,0,tocolor(255,255,255));
			dxDrawRectangle(sH*0.052,(i*sH*0.054)-ground.scroll,sW*0.155-sH*0.05,sH*0.052,tocolor(255,255,255,100));
			dxDrawText(translateLocalization(v[2]),sH*0.057,(i*sH*0.054)-ground.scroll,sW*0.155,(i*sH*0.054)-ground.scroll+sH*0.052,tocolor(255,255,255),1,"default","left","center",true,false,false,false,false,0,0,0);
			if (v[3] > 1) then
				dxDrawText(v[3],sH*0.06,(i*sH*0.054)-ground.scroll,sW*0.15,(i*sH*0.054)-ground.scroll+sH*0.052,tocolor(255,255,255),1,"default","right","center",true,false,false,false,false,0,0,0);
			end
		end
	end
	dxSetRenderTarget();
end

function drawInventoryItems()
	dxSetRenderTarget(inventory.rt,true);
	if (not drag.active and drag.source == "inventory") then drag.source = false; drag.item = false; end
	for i,v in ipairs(getPlayerItems()) do
		i=i-1;
		if (isCursorOnArea(sW*0.176,sH*0.2,sW*0.155,sH*0.6) and isCursorOnArea(sW*0.176,sH*0.2+(i*sH*0.054)-inventory.scroll,sW*0.155,sH*0.052) and not drag.active) then
			drag.source = "inventory";
			drag.item = v[1];
			if (healing.item == v[1]) then
				local timeleft,_,totaltime = getTimerDetails(healing.timer);
				dxDrawRectangle(0,(i*sH*0.054)-inventory.scroll,(timeleft/totaltime)*(sH*0.052+sW*0.155-sH*0.05),sH*0.052,tocolor(100,100,100,100));
			end
			dxDrawRectangle(0,(i*sH*0.054)-inventory.scroll,sH*0.052,sH*0.052,tocolor(255,255,255,150));
			dxDrawImage(0,(i*sH*0.054)-inventory.scroll,sH*0.052,sH*0.052,"images/inventory/icons/"..v[1]..".png",0,0,0,tocolor(255,255,255));
			dxDrawRectangle(sH*0.052,(i*sH*0.054)-inventory.scroll,sW*0.155-sH*0.05,sH*0.052,tocolor(255,255,255,130));
			dxDrawLine(0,((i*sH*0.054)-inventory.scroll)+sH*0.052-1,sW*0.155,((i*sH*0.054)-inventory.scroll)+sH*0.052-1,tocolor(255,255,255,150),2);
			dxDrawText(translateLocalization(v[1]),sH*0.057,(i*sH*0.054)-inventory.scroll,sW*0.155,(i*sH*0.054)-inventory.scroll+sH*0.052,tocolor(255,255,255),1,"default","left","center",true,false,false,false,false,0,0,0);
			if (v[2] > 1) then
				dxDrawText(v[2],sH*0.06,(i*sH*0.054)-inventory.scroll,sW*0.15,(i*sH*0.054)-inventory.scroll+sH*0.052,tocolor(255,255,255),1,"default","right","center",true,false,false,false,false,0,0,0);
			end
		elseif (drag.source == "inventory" and drag.item ~= v[1] or drag.source ~= "inventory") then
			if (healing.item == v[1]) then
				local timeleft,_,totaltime = getTimerDetails(healing.timer);
				dxDrawRectangle(0,(i*sH*0.054)-inventory.scroll,(timeleft/totaltime)*(sH*0.052+sW*0.155-sH*0.05),sH*0.052,tocolor(100,100,100,100));
			end
			dxDrawRectangle(0,(i*sH*0.054)-inventory.scroll,sH*0.052,sH*0.052,tocolor(255,255,255,120));
			dxDrawImage(0,(i*sH*0.054)-inventory.scroll,sH*0.052,sH*0.052,"images/inventory/icons/"..v[1]..".png",0,0,0,tocolor(255,255,255));
			dxDrawRectangle(sH*0.052,(i*sH*0.054)-inventory.scroll,sW*0.155-sH*0.05,sH*0.052,tocolor(255,255,255,100));
			dxDrawText(translateLocalization(v[1]),sH*0.057,(i*sH*0.054)-inventory.scroll,sW*0.155,(i*sH*0.054)-inventory.scroll+sH*0.052,tocolor(255,255,255),1,"default","left","center",true,false,false,false,false,0,0,0);
			if (v[2] > 1) then
				dxDrawText(v[2],sH*0.06,(i*sH*0.054)-inventory.scroll,sW*0.15,(i*sH*0.054)-inventory.scroll+sH*0.052,tocolor(255,255,255),1,"default","right","center",true,false,false,false,false,0,0,0);
			end
		end
	end
	dxSetRenderTarget();
end

addEventHandler("onClientPreRender",root,function()
	if (not checkAuthorized()) then return; end
	if (getElementData(localPlayer,"inventory_visible")) then
		dxDrawRectangle(0,0,sW,sH,tocolor(0,0,0,200),true);
	end
end);

addEventHandler("onClientRender",root,function()
	if (not checkAuthorized()) then return; end
	if (getPedWeapon(localPlayer,11) == 46) then setPedWeaponSlot(localPlayer,11); end
	if (getElementData(localPlayer,"inventory_visible")) then
		-- player name
		dxDrawText(getPlayerName(localPlayer):gsub("#%x%x%x%x%x%x", ""),0,0,sW,sH*0.19,tocolor(255,255,255),1,roboto_regular,"center","bottom",false,false,true,false,false,0,0,0);
		-- ground items
		dxDrawText(translateLocalization("ground"),sW*0.015,sH*0.2-10,sW*0.015,sH*0.2-10,tocolor(255,255,255),1,"Arial","left","center",false,false,true,false,false,0,0,0);
		dxDrawImage(sW*0.015,sH*0.2,sW*0.155,sH*0.6,ground.rt,0,0,0,tocolor(255,255,255),true);
		dxDrawLine(sW*0.015+sW*0.155+sH*0.003,sH*0.2,sW*0.015+sW*0.155+sH*0.003,sH*0.8,tocolor(255,255,255,100),1,true)
		if (#getGroundItems()*sH*0.0542 <= sH*0.6-2) then ground.scroll=0;
		elseif (ground.scroll > #getGroundItems()*sH*0.0542-sH*0.6-2) then ground.scroll=#getGroundItems()*sH*0.0542-sH*0.6-2;
		end
		if (#getGroundItems()*sH*0.0542 > sH*0.6-2) then
			dxDrawRectangle(sW*0.013+sW*0.155+sH*0.003,(sH*0.2)*(ground.scroll/((#getGroundItems()*sH*0.0542-sH*0.6-2)*0.372)+1),5,sH*0.063,tocolor(255,255,255),true)
		end
		-- inventory items
		dxDrawText(translateLocalization("inventory"),sW*0.176,sH*0.2-10,sW*0.176,sH*0.2-10,tocolor(255,255,255),1,"Arial","left","center",false,false,true,false,false,0,0,0);
		dxDrawImage(sW*0.176,sH*0.2,sW*0.155,sH*0.6,inventory.rt,0,0,0,tocolor(255,255,255),true);
		if (#getPlayerItems()*sH*0.0542 <= sH*0.6-2) then inventory.scroll=0;
		elseif (inventory.scroll > #getPlayerItems()*sH*0.0542-sH*0.6-2) then inventory.scroll=#getPlayerItems()*sH*0.0542-sH*0.6-2;
		end
		if (#getPlayerItems()*sH*0.0542 > sH*0.6-2) then
			--dxDrawLine(sW*0.176+sW*0.155+sH*0.003,sH*0.2,sW*0.176+sW*0.155+sH*0.003,sH*0.8,tocolor(255,255,255,100),1,true)
			dxDrawRectangle(sW*0.174+sW*0.155+sH*0.003,(sH*0.2)*(inventory.scroll/((#getPlayerItems()*sH*0.0542-sH*0.6-2)*0.372)+1),5,sH*0.063,tocolor(255,255,255),true)
		end
		-- helmet placeholder
		drawBox(sW*0.37,sH*0.23,sH*0.052,sH*0.052,tocolor(0,0,0,150),tocolor(255,255,255,100),1,true)
		local helmet = getElementData(localPlayer,"helmet");
		if (not drag.active and drag.source == "helmet") then drag.source = false;drag.item = false; end
		if (drag.active and drag.source and string.find(drag.item,"helmet")) then
			drawBox(sW*0.37,sH*0.23,sH*0.052,sH*0.052,tocolor(200,200,200,50),tocolor(200,200,200,25),2,true)
		end
		if (helmet and helmet ~= "" and drag.source ~= "helmet") then
			if (not drag.active and isCursorOnArea(sW*0.37,sH*0.23,sH*0.052,sH*0.052)) then
				drawBox(sW*0.37,sH*0.23,sH*0.052,sH*0.052,tocolor(200,200,200,50),tocolor(200,200,200,25),2,true)
			end
			dxDrawImage(sW*0.37,sH*0.23,sH*0.052,sH*0.052,"images/inventory/icons/"..helmet..".png",0,0,0,tocolor(255,255,255),true);
		end
		-- backpack placeholder
		drawBox(sW*0.37,sH*0.43,sH*0.052,sH*0.052,tocolor(0,0,0,150),tocolor(255,255,255,100),1,true)
		local backpack = getElementData(localPlayer,"backpack");
		if (not drag.active and drag.source == "backpack") then drag.source = false;drag.item = false; end
		if (drag.active and drag.source and string.find(drag.item,"backpack")) then
			drawBox(sW*0.37,sH*0.43,sH*0.052,sH*0.052,tocolor(200,200,200,50),tocolor(200,200,200,25),2,true)
		end
		if (backpack and backpack ~= "" and drag.source ~= "backpack") then
			if (not drag.active and isCursorOnArea(sW*0.37,sH*0.43,sH*0.052,sH*0.052)) then
				drawBox(sW*0.37,sH*0.43,sH*0.052,sH*0.052,tocolor(200,200,200,50),tocolor(200,200,200,25),2,true)
			end
			dxDrawImage(sW*0.37,sH*0.43,sH*0.052,sH*0.052,"images/inventory/icons/"..backpack..".png",0,0,0,tocolor(255,255,255),true);
		end
		-- armor placeholder
		drawBox(sW*0.37,sH*0.5,sH*0.052,sH*0.052,tocolor(0,0,0,150),tocolor(255,255,255,100),1,true)
		local armor = getElementData(localPlayer,"armor");
		if (not drag.active and drag.source == "armor") then drag.source = false;drag.item = false; end
		if (drag.active and drag.source and string.find(drag.item,"armor")) then
				drawBox(sW*0.37,sH*0.5,sH*0.052,sH*0.052,tocolor(200,200,200,50),tocolor(200,200,200,25),2,true)
		end
		if (armor and armor ~= "" and drag.source ~= "armor") then
			if (not drag.active and isCursorOnArea(sW*0.37,sH*0.5,sH*0.052,sH*0.052)) then
				drawBox(sW*0.37,sH*0.5,sH*0.052,sH*0.052,tocolor(200,200,200,50),tocolor(200,200,200,25),2,true)
			end
			dxDrawImage(sW*0.37,sH*0.5,sH*0.052,sH*0.052,"images/inventory/icons/"..armor..".png",0,0,0,tocolor(255,255,255),true);
		end
		-- weight indicator sW*0.48,sH*0.5,sH*0.052,sH*0.052
		drawBox(sW*0.37-sW*0.014,sH*0.43,sW*0.007,sH*0.052*2+sH*0.018,tocolor(0,0,0,150),tocolor(255,255,255,100),1,true)
		local currWeight,maxWeight = countWeight();
		local percentweight = math.floor((currWeight/maxWeight)*(sH*0.052*2+sH*0.02-2));
		if -percentweight < -(sH*0.052*2+sH*0.02-2) then percentweight = sH*0.052*2+sH*0.02-2; end
 		dxDrawImage(sW*0.37-sW*0.014,sH*0.43+sH*0.052*2+sH*0.02-2,sW*0.007,-percentweight,"images/inventory/bar.png",180,0,0,tocolor(255,255,255,100),true);
		if not drag.active and isCursorOnArea(sW*0.37-sW*0.014,sH*0.43,sW*0.007,sH*0.052*2+sH*0.02-2) then
			local mX,mY = getCursorPosition();
			mX,mY =  sW * mX, sH * mY;
			local tex = translateLocalization("weight")..": "..math.floor(currWeight/maxWeight*100).."/100";
			local tW = dxGetTextWidth(tex,1,"default");
			local tH = dxGetFontHeight(1,"default");
			drawBox(mX-tW/2-1,mY-tH-1,tW+2,tH+2,tocolor(0,0,0,150),tocolor(255,255,255,100),1,true)
			dxDrawText(tex,mX-tW/2,mY-tH,mX,mY,tocolor(255,255,255),1,"default","left","top",false,false,true,false,false,0,0,0);
		end
		-- weapon 1
		local wep = getElementData(localPlayer,"weapon1") or "";
		local x,y = sW*0.65,sH*0.2;
		local w,h = x+sW*0.33,y+sH*0.14;
		dxDrawLine(x,y+sH*0.14,w,y+sH*0.14,tocolor(255,255,255,100),1,true)
		if (not drag.active and drag.source == "weapon1") then drag.source = false;drag.item = false; end
		if (wep ~= "") then
			local inmag = 0;
			local requiredammo = weapons[wep][5];
			local maxammo = (getElementData(localPlayer,requiredammo)) or 0;
			if (getPedWeapon(localPlayer) == weapons[wep][2]) then
				inmag = getPedAmmoInClip(localPlayer);
				maxammo = maxammo-getPedAmmoInClip(localPlayer);
			end
			local tWidth = dxGetTextWidth(maxammo,1.2*sH*0.001,"default-bold")
			local tWidth2 = dxGetTextWidth(inmag,1.5*sH*0.001,"default-bold")
			local middle_offset = sH*0.02;
			local side_offset = sH*0.07
			if (drag.source ~= "weapon1") then
				dxDrawImage(x+side_offset,y+middle_offset+sH*0.015,w-x-side_offset*2,h-y-middle_offset*2,"images/hud/weapons/"..wep..".png",0,0,0,tocolor(200,200,200,200),true);
			end
			drawBox(x,y,sH*0.025,sH*0.025,tocolor(0,0,0,200),tocolor(255,255,255,100),1,true)
			dxDrawText("1",x,y,x+sH*0.025,y+sH*0.025,tocolor(255,255,255,230),1.4*sH*0.001,"default-bold","center","center",false,false,true)
			dxDrawText(translateLocalization(wep),x+sH*0.03,y,x+sH*0.03,y+sH*0.025,tocolor(255,255,255,170),1.5*sH*0.001,"default-bold","left","bottom",false,false,true)
			dxDrawImage(w-sH*0.015-tWidth,y+sH*0.007,sH*0.015,sH*0.015,"images/hud/bullet.png",0,0,0,tocolor(255,255,255,220),true);
			dxDrawText(maxammo,x+sW*.15,y,w,y+sH*0.025,tocolor(255,255,255,170),1.2*sH*0.001,"default-bold","right","bottom",false,false,true)
			dxDrawText(inmag,x+sW*.15,y,w-sH*0.015-tWidth,y+sH*0.025,tocolor(255,255,255,170),1.5*sH*0.001,"default-bold","right","bottom",false,false,true)
			dxDrawText(translateLocalization(requiredammo),x+sW*.15,y,w-sH*0.025-tWidth-tWidth2,y+sH*0.025,tocolor(255,255,255,150),1*sH*0.001,"default","right","bottom",false,false,true)
			if (not drag.active and isCursorOnArea(x,y,sW*0.33,sH*0.14)) then
				drawBox(x,y,sW*0.33,sH*0.14,tocolor(150,150,150,10),tocolor(150,150,150,10),sH*0.003,true);
			end
		end
		if (drag.active and drag.source and weapons[drag.item] and weapons[drag.item][1] == "primary") then
			drawBox(x,y,sW*0.33,sH*0.14,tocolor(255,255,255,15),tocolor(200,200,200,15),5,true);
		end
		-- weapon 2
		local wep = getElementData(localPlayer,"weapon2") or "";
		local x,y = sW*0.65,sH*0.35;
		local w,h = x+sW*0.33,y+sH*0.14;
		dxDrawLine(x,y+sH*0.14,w,y+sH*0.14,tocolor(255,255,255,100),1,true)
		if (not drag.active and drag.source == "weapon2") then drag.source = false;drag.item = false; end
		if (wep ~= "") then
			local inmag = 0;
			local requiredammo = weapons[wep][5];
			local maxammo = (getElementData(localPlayer,requiredammo)) or 0;
			if (getPedWeapon(localPlayer) == weapons[wep][2]) then
				inmag = getPedAmmoInClip(localPlayer);
				maxammo = maxammo-getPedAmmoInClip(localPlayer);
			end
			local tWidth = dxGetTextWidth(maxammo,1.2*sH*0.001,"default-bold")
			local tWidth2 = dxGetTextWidth(inmag,1.5*sH*0.001,"default-bold")
			local middle_offset = sH*0.02;
			local side_offset = sH*0.07
			if (drag.source ~= "weapon2") then
				dxDrawImage(x+side_offset,y+middle_offset+sH*0.015,w-x-side_offset*2,h-y-middle_offset*2,"images/hud/weapons/"..wep..".png",0,0,0,tocolor(200,200,200,200),true);
			end
			drawBox(x,y,sH*0.025,sH*0.025,tocolor(0,0,0,200),tocolor(255,255,255,100),1,true)
			dxDrawText("2",x,y,x+sH*0.025,y+sH*0.025,tocolor(255,255,255,230),1.4*sH*0.001,"default-bold","center","center",false,false,true)
			dxDrawText(translateLocalization(wep),x+sH*0.03,y,x+sH*0.03,y+sH*0.025,tocolor(255,255,255,170),1.5*sH*0.001,"default-bold","left","bottom",false,false,true)
			dxDrawImage(w-sH*0.015-tWidth,y+sH*0.007,sH*0.015,sH*0.015,"images/hud/bullet.png",0,0,0,tocolor(255,255,255,220),true);
			dxDrawText(maxammo,x+sW*.15,y,w,y+sH*0.025,tocolor(255,255,255,170),1.2*sH*0.001,"default-bold","right","bottom",false,false,true)
			dxDrawText(inmag,x+sW*.15,y,w-sH*0.015-tWidth,y+sH*0.025,tocolor(255,255,255,170),1.5*sH*0.001,"default-bold","right","bottom",false,false,true)
			dxDrawText(translateLocalization(requiredammo),x+sW*.15,y,w-sH*0.025-tWidth-tWidth2,y+sH*0.025,tocolor(255,255,255,150),1*sH*0.001,"default","right","bottom",false,false,true)
			if (not drag.active and isCursorOnArea(x,y,sW*0.33,sH*0.14)) then
				drawBox(x,y,sW*0.33,sH*0.14,tocolor(150,150,150,10),tocolor(150,150,150,10),sH*0.003,true);
			end
		end
		if (drag.active and drag.source and weapons[drag.item] and weapons[drag.item][1] == "primary") then
			drawBox(x,y,sW*0.33,sH*0.14,tocolor(255,255,255,15),tocolor(200,200,200,25),sH*0.005,true);
		end
		-- weapon 3
		if (not drag.active and drag.source == "weapon3") then drag.source = false;drag.item = false; end
		local wep = getElementData(localPlayer,"weapon3") or "";
		local x,y = sW*0.65,sH*0.5;
		local w,h = x+sW*0.33,y+sH*0.14;
		dxDrawLine(x,y+sH*0.14,w,y+sH*0.14,tocolor(255,255,255,100),1,true)
		if (wep ~= "") then
			local inmag = 0;
			local requiredammo = weapons[wep][5];
			local maxammo = (getElementData(localPlayer,requiredammo)) or 0;
			if (getPedWeapon(localPlayer) == weapons[wep][2]) then
				inmag = getPedAmmoInClip(localPlayer);
				maxammo = maxammo-getPedAmmoInClip(localPlayer);
			end
			local tWidth = dxGetTextWidth(maxammo,1.2*sH*0.001,"default-bold")
			local tWidth2 = dxGetTextWidth(inmag,1.5*sH*0.001,"default-bold")
			local middle_offset = sH*0.025;
			local side_offset = sH*0.15
			if (wep == "mp5" or wep == "machete" or wep == "crowbar") then
				side_offset = sH*0.12;
			end
			if (drag.source ~= "weapon3") then
				dxDrawImage(x+side_offset,y+middle_offset+sH*0.015,w-x-side_offset*2,h-y-middle_offset*2,"images/hud/weapons/"..wep..".png",0,0,0,tocolor(200,200,200,200),true);
			end
			drawBox(x,y,sH*0.025,sH*0.025,tocolor(0,0,0,200),tocolor(255,255,255,100),1,true)
			dxDrawText("3",x,y,x+sH*0.025,y+sH*0.025,tocolor(255,255,255,230),1.4*sH*0.001,"default-bold","center","center",false,false,true)
			dxDrawText(translateLocalization(wep),x+sH*0.03,y,x+sH*0.03,y+sH*0.025,tocolor(255,255,255,170),1.5*sH*0.001,"default-bold","left","bottom",false,false,true)
			if (requiredammo ~= "") then
				dxDrawImage(w-sH*0.015-tWidth,y+sH*0.007,sH*0.015,sH*0.015,"images/hud/bullet.png",0,0,0,tocolor(255,255,255,220),true);
				dxDrawText(maxammo,x+sW*.15,y,w,y+sH*0.025,tocolor(255,255,255,170),1.2*sH*0.001,"default-bold","right","bottom",false,false,true)
				dxDrawText(inmag,x+sW*.15,y,w-sH*0.015-tWidth,y+sH*0.025,tocolor(255,255,255,170),1.5*sH*0.001,"default-bold","right","bottom",false,false,true)
				dxDrawText(translateLocalization(requiredammo),x+sW*.15,y,w-sH*0.025-tWidth-tWidth2,y+sH*0.025,tocolor(255,255,255,150),1*sH*0.001,"default","right","bottom",false,false,true)
			end
			if (not drag.active and isCursorOnArea(x,y,sW*0.33,sH*0.14)) then
				drawBox(x,y,sW*0.33,sH*0.14,tocolor(150,150,150,10),tocolor(150,150,150,10),sH*0.003,true);
			end
		end
		if (drag.active and drag.source and weapons[drag.item] and weapons[drag.item][1] == "secondary") then
			drawBox(x,y,sW*0.33,sH*0.14,tocolor(255,255,255,15),tocolor(200,200,200,25),sH*0.005,true);
		end
		-- weapon 4
		local wep = getElementData(localPlayer,"weapon4") or "";
		local x,y = sW*0.65,sH*0.65;
		local w,h = x+sW*0.16,y+sH*0.14;
		dxDrawLine(x,y+sH*0.14,w,y+sH*0.14,tocolor(255,255,255,100),1,true)
		if (not drag.active and drag.source == "weapon4") then drag.source = false;drag.item = false; end
		if (wep ~= "") then
			local middle_offset = sH*0.03;
			local side_offset = sH*0.02
			if (drag.source ~= "weapon4") then
				dxDrawImage(x+side_offset,y+middle_offset+sH*0.015,w-x-side_offset*2,h-y-middle_offset*2,"images/hud/weapons/"..wep..".png",0,0,0,tocolor(200,200,200,200),true);
			end
			drawBox(x,y,sH*0.025,sH*0.025,tocolor(0,0,0,200),tocolor(255,255,255,100),1,true)
			dxDrawText("4",x,y,x+sH*0.025,y+sH*0.025,tocolor(255,255,255,230),1.4*sH*0.001,"default-bold","center","center",false,false,true)
			dxDrawText(translateLocalization(wep),x+sH*0.03,y,x+sH*0.03,y+sH*0.025,tocolor(255,255,255,170),1.5*sH*0.001,"default-bold","left","bottom",false,false,true)
			if (not drag.active and isCursorOnArea(x,y,sW*0.16,sH*0.14)) then
				drawBox(x,y,sW*0.16,sH*0.14,tocolor(150,150,150,10),tocolor(150,150,150,10),sH*0.003,true);
			end
		end
		if (drag.active and drag.source and weapons[drag.item] and weapons[drag.item][1] == "meele") then
			drawBox(x,y,sW*0.16,sH*0.14,tocolor(255,255,255,15),tocolor(200,200,200,25),sH*0.005,true);
		end
		-- weapon 5
		local wep = getElementData(localPlayer,"weapon5") or "";
		local x,y = sW*0.82,sH*0.65;
		local w,h = x+sW*0.16,y+sH*0.14;
		dxDrawLine(x,y+sH*0.14,w,y+sH*0.14,tocolor(255,255,255,100),1,true)
		if (not drag.active and drag.source == "weapon5") then drag.source = false;drag.item = false; end
		if (wep ~= "") then
			local middle_offset = sH*0.03;
			local side_offset = sH*0.08
			if (drag.source ~= "weapon5") then
				dxDrawImage(x+side_offset,y+middle_offset+sH*0.015,w-x-side_offset*2,h-y-middle_offset*2,"images/hud/weapons/"..wep..".png",0,0,0,tocolor(200,200,200,200),true);
			end
			drawBox(x,y,sH*0.025,sH*0.025,tocolor(0,0,0,200),tocolor(255,255,255,100),1,true)
			dxDrawText("5",x,y,x+sH*0.025,y+sH*0.025,tocolor(255,255,255,230),1.4*sH*0.001,"default-bold","center","center",false,false,true)
			dxDrawText(translateLocalization(wep),x+sH*0.03,y,x+sH*0.03,y+sH*0.025,tocolor(255,255,255,170),1.5*sH*0.001,"default-bold","left","bottom",false,false,true)
			if (not drag.active and isCursorOnArea(x,y,sW*0.16,sH*0.14)) then
				drawBox(x,y,sW*0.16,sH*0.14,tocolor(150,150,150,10),tocolor(150,150,150,10),sH*0.003,true);
			end
		end
		if (drag.active and drag.source and drag.source ~= "ground" and weapons[drag.item] and weapons[drag.item][1] == "grenade") then
			drawBox(x,y,sW*0.16,sH*0.14,tocolor(255,255,255,15),tocolor(200,200,200,25),sH*0.005,true);
		end
		-- other
		if (splt.active) then
			splt.action = false;

			local color1 = tocolor(120,120,120,230)
			local color2 = tocolor(120,120,120,230)
			local color3 = tocolor(120,120,120,230)
			local color4 = tocolor(0,0,0,255)
			local color5 = tocolor(230,230,230,230)
			local color6 = tocolor(120,120,120,230)

			local splitting = 1;
			if (string.find(splt.item,"ammo")) then
				splitting = 10;
			end

			local w,h = sW*0.23,sH*0.155;
			local x,y = sW/2-w/2,sH/2-h/2;
			if isCursorOnArea(x+w-sH*0.026,y,sH*0.024,sH*0.024) then
				color1 = tocolor(80,80,80,230)
				splt.action = "x";
			end
			dxDrawRectangle(x,y,w,h,tocolor(0,0,0,150),true);
			dxDrawRectangle(x+w-sH*0.026,y,sH*0.026,sH*0.026,color1,true);
			dxDrawText("x",x+w,y,x+w-sH*0.024,y+sH*0.024,tocolor(0,0,0,230),1.5*sH*0.0011,"default-bold","center","center",false,false,true)

			dxDrawText(translateLocalization("split1",nil,translateLocalization(splt.item)),x*1.025,y,x*1.025,y+h*0.4,tocolor(60,60,60,230),1*sH*0.0012,"default","left","center",false,false,true,true)

			local w1,h1 = sH*0.04,sH*0.035;
			local x1,y1 = x*1.02,y+h/2-h1/2;
			if isCursorOnArea(x1,y1,w1,h1) then
				color2 = tocolor(80,80,80,230)
				splt.action = "-";
			end
			dxDrawRectangle(x1,y1,w1,h1,color2,true);
			dxDrawText("-"..splitting,x1,y1,x1+w1,y1+h1,tocolor(255,255,255,230),1.5*sH*0.001,"default","center","center",false,false,true)

			local w2,h2 = sH*0.04,sH*0.035;
			local x2,y2 = x*0.98+w-w2,y+h/2-h2/2;
			if isCursorOnArea(x2,y2,w2,h2) then
				color3 = tocolor(80,80,80,230)
				splt.action = "+";
			end
			dxDrawRectangle(x2,y2,w2,h2,color3,true);
			dxDrawText("+"..splitting,x2,y2,x2+w2,y2+h2,tocolor(255,255,255,230),1.5*sH*0.001,"default","center","center",false,false,true)
			
			if isCursorOnArea(x1+w1,y1,x2-x1-w2,h1) then
				color4 = tocolor(5,5,5,230)
				splt.action = "amount";
			end
			dxDrawRectangle(x1+w1,y1,x2-x1-w2,h1,color4,true);
			dxDrawText(splt.amount,x1+w1,y1,x1+w1+x2-x1-w2,y1+h1,tocolor(255,255,255,230),1.5*sH*0.001,"default","center","center",false,false,true)
		
			local w3,h3 = sH*0.13,sH*0.035;
			local x3,y3 = x*1.02,y+h*0.68;
			if isCursorOnArea(x3,y3,w3,h3) then
				color5 = tocolor(190,190,190,230)
				splt.action = "accept";
			end
			dxDrawRectangle(x3,y3,w3,h3,color5,true);
			dxDrawText(translateLocalization("split2"),x3,y3,x3+w3,y3+h3,tocolor(0,0,0,230),1.5*sH*0.001,"default-bold","center","center",false,false,true)

			local w4,h4 = sH*0.13,sH*0.035;
			local x4,y4 = x*0.98+w-w4,y+h*0.68;
			if isCursorOnArea(x4,y4,w4,h4) then
				color6 = tocolor(80,80,80,230)
				splt.action = "cancel";
			end
			dxDrawRectangle(x4,y4,w4,h4,color6,true);
			dxDrawText(translateLocalization("split3"),x4,y4,x4+w4,y4+h4,tocolor(50,50,50,230),1.5*sH*0.001,"default-bold","center","center",false,false,true)
		elseif (drag.active) then
			local mX,mY = getCursorPosition();
			mX,mY =  sW * mX, sH * mY;
			if (drag.active and drag.item) then
				drawBox(mX-(sH*0.052/2),mY-(sH*0.052/2),sH*0.052,sH*0.052,tocolor(255,255,255,50),tocolor(255,255,255,100),1,true)
				dxDrawImage(mX-(sH*0.052/2),mY-(sH*0.052/2),sH*0.052,sH*0.052,"images/inventory/icons/"..drag.item..".png",0,0,0,tocolor(255,255,255),true);
			end
		end
		drawGroundItems();
		drawInventoryItems()
	end
	if (healing.item) then
		local timeleft,_,totaltime = getTimerDetails(healing.timer);
		dxDrawText(math.round(timeleft/1000,1),sW/2,sH/2,sW/2,sH/2,tocolor(255,255,255,255),1*sH*0.001,"default-bold","center","center",false,false,true)
		dxDrawCircle2(sW/2-2,sH/2,sH*0.021,sH*0.005,nil,nil,360,tocolor(0,0,0),true);
		dxDrawCircle2(sW/2-2,sH/2,sH*0.021,sH*0.004,nil,0,-360*(timeleft/totaltime),tocolor(255,255,255,100),true);
		drawActionWindow(translateLocalization("tocancel"))
	end
end);

local lctrl = false;
bindKey("lctrl","both",function(_,state)
	if (state == "down") then
		lctrl = true;
	else
		lctrl = false;
	end
end)

function enableSplit(source,object,item)
	if (not splt.active) then
		splt.active = true;
		splt.source = source;
		splt.object = object;
		splt.amount = 1;
		splt.item = item;
	end
end

function disableSplit()
	if (splt.active) then
		splt.active = false;
		splt.source = false;
		splt.object = false;
		splt.action = false;
		splt.amount = false;
		splt.item = false;
	end
end

function disableDrag()
	drag.active = false;
	drag.source = false;
	drag.object = false;
	drag.item = false;
end

bindKey("mouse1","both",function(_,state)
	if (not checkAuthorized()) then return; end
	if (getElementData(localPlayer,"inventory_visible")) then
		if (healing.item and healing.timer) then return; end
		if (state == "down") then
			if (splt.active) then return; end
			if (isCursorOnArea(sW*0.015,sH*0.2,sW*0.155,sH*0.6) or isCursorOnArea(sW*0.176,sH*0.2,sW*0.155,sH*0.6)) then
				drag.active = true;
			elseif isCursorOnArea(sW*0.37,sH*0.23,sH*0.052,sH*0.052) then
				local helmet = getElementData(localPlayer,"helmet");
				if (helmet and helmet ~= "") then
					drag.active = true;
					drag.source = "helmet";
					drag.item = helmet;
				end
			elseif isCursorOnArea(sW*0.37,sH*0.43,sH*0.052,sH*0.052) then
				local backpack = getElementData(localPlayer,"backpack");
				if (backpack and backpack ~= "") then
					drag.active = true;
					drag.source = "backpack";
					drag.item = backpack;
				end
			elseif isCursorOnArea(sW*0.37,sH*0.5,sH*0.052,sH*0.052) then
				local armor = getElementData(localPlayer,"armor");
				if (armor and armor ~= "") then
					drag.active = true;
					drag.source = "armor";
					drag.item = armor;
				end
			elseif isCursorOnArea(sW*0.65,sH*0.2,sW*0.33,sH*0.14) then
				local weapon1 = getElementData(localPlayer,"weapon1");
				if (weapon1 and weapon1 ~= "") then
					drag.active = true;
					drag.source = "weapon1";
					drag.item = weapon1;
				end
			elseif isCursorOnArea(sW*0.65,sH*0.35,sW*0.33,sH*0.14) then
				local weapon2 = getElementData(localPlayer,"weapon2");
				if (weapon2 and weapon2 ~= "") then
					drag.active = true;
					drag.source = "weapon2";
					drag.item = weapon2;
				end
			elseif isCursorOnArea(sW*0.65,sH*0.5,sW*0.33,sH*0.14) then
				local weapon3 = getElementData(localPlayer,"weapon3");
				if (weapon3 and weapon3 ~= "") then
					drag.active = true;
					drag.source = "weapon3";
					drag.item = weapon3;
				end
			elseif isCursorOnArea(sW*0.65,sH*0.65,sW*0.16,sH*0.14) then
				local weapon4 = getElementData(localPlayer,"weapon4");
				if (weapon4 and weapon4 ~= "") then
					drag.active = true;
					drag.source = "weapon4";
					drag.item = weapon4;
				end
			elseif isCursorOnArea(sW*0.82,sH*0.65,sW*0.16,sH*0.14) then
				local weapon5 = getElementData(localPlayer,"weapon5");
				if (weapon5 and weapon5 ~= "") then
					drag.active = true;
					drag.source = "weapon5";
					drag.item = weapon5;
				end
			end
		else
			if (drag.active) then
					drag.active = false;
					if (isCursorOnArea(sW*0.015,sH*0.2,sW*0.155,sH*0.6)) then
						if (drag.source == "inventory") then
							if (not lctrl) then
								triggerServerEvent("dropItemToGround",localPlayer,drag.item,getElementData(localPlayer,drag.item))
							else
								enableSplit(drag.source,drag.object,drag.item);
							end
						elseif (drag.source == "helmet" or drag.source == "backpack" or drag.source == "armor"
						or drag.source == "weapon1" or drag.source == "weapon2" or drag.source == "weapon3"
						or drag.source == "weapon4" or drag.source == "weapon5") then
							triggerServerEvent("removeItemFromPlayer",localPlayer,"ground",drag.item,drag.source)
						end
					elseif isCursorOnArea(sW*0.176,sH*0.2,sW*0.155,sH*0.6) then
						if (drag.source == "ground") then
							if (not lctrl) then
								triggerServerEvent("takeItemFromGround",localPlayer,drag.object,drag.item,getElementData(drag.object,drag.item))
							else
								enableSplit(drag.source,drag.object,drag.item);
							end
						elseif (drag.source == "helmet" or drag.source == "backpack" or drag.source == "armor"
						or drag.source == "weapon1" or drag.source == "weapon2" or drag.source == "weapon3"
						or drag.source == "weapon4" or drag.source == "weapon5") then
							triggerServerEvent("removeItemFromPlayer",localPlayer,"inventory",drag.item,drag.source)
						end
					elseif isCursorOnArea(sW*0.37,sH*0.23,sH*0.052,sH*0.052) then
						triggerServerEvent("useItemFromInventory",localPlayer,drag.item,drag.object,"helmet")
					elseif isCursorOnArea(sW*0.37,sH*0.43,sH*0.052,sH*0.052) then
						triggerServerEvent("useItemFromInventory",localPlayer,drag.item,drag.object,"backpack")
					elseif isCursorOnArea(sW*0.37,sH*0.5,sH*0.052,sH*0.052) then
						triggerServerEvent("useItemFromInventory",localPlayer,drag.item,drag.object,"armor")
					elseif isCursorOnArea(sW*0.65,sH*0.2,sW*0.33,sH*0.14) and weapons[drag.item] and weapons[drag.item][1] == "primary" then
						triggerServerEvent("equipPlayerWeapon",localPlayer,drag.item,drag.object,drag.source,weapons[drag.item][1],1)
					elseif isCursorOnArea(sW*0.65,sH*0.35,sW*0.33,sH*0.14) and weapons[drag.item] and weapons[drag.item][1] == "primary" then
						triggerServerEvent("equipPlayerWeapon",localPlayer,drag.item,drag.object,drag.source,weapons[drag.item][1],2)
					elseif isCursorOnArea(sW*0.65,sH*0.5,sW*0.33,sH*0.14) and weapons[drag.item] and weapons[drag.item][1] == "secondary" then
						triggerServerEvent("equipPlayerWeapon",localPlayer,drag.item,drag.object,drag.source,weapons[drag.item][1],3)
					elseif isCursorOnArea(sW*0.65,sH*0.65,sW*0.16,sH*0.14) and weapons[drag.item] and weapons[drag.item][1] == "meele" then
						triggerServerEvent("equipPlayerWeapon",localPlayer,drag.item,drag.object,drag.source,weapons[drag.item][1],4)
					elseif isCursorOnArea(sW*0.82,sH*0.65,sW*0.16,sH*0.14) and weapons[drag.item] and weapons[drag.item][1] == "grenade" then
						triggerServerEvent("equipPlayerWeapon",localPlayer,drag.item,drag.object,drag.source,weapons[drag.item][1],5)
					end
			elseif (splt.active) then
				local splitting = 1;
				if (string.find(splt.item,"ammo")) then
					splitting = 10;
				end
				if (splt.action == "x" or splt.action == "cancel") then
					disableSplit()
				elseif (splt.action == "-") then
					splt.amount = splt.amount-splitting;
					if (splt.amount <= 0) then splt.amount = 1; end
				elseif (splt.action == "+") then
					splt.amount = splt.amount+splitting;
					if (splt.object) then
						if (splt.amount > getElementData(splt.object,splt.item)) then
							splt.amount = getElementData(splt.object,splt.item);
						end
					elseif (splt.amount > getElementData(localPlayer,splt.item)) then
						splt.amount = getElementData(localPlayer,splt.item);
					end
				elseif (splt.action == "accept") then
					if (splt.source == "inventory") then
						triggerServerEvent("dropItemToGround",localPlayer,splt.item,splt.amount)
						disableSplit()
					elseif (splt.source == "ground") then
						triggerServerEvent("takeItemFromGround",localPlayer,splt.object,splt.item,splt.amount)
						disableSplit()
					end
				end
			end
		end
	end
end)

bindKey("mouse2","down",function()
	if (not checkAuthorized()) then return; end
	if (getElementData(localPlayer,"inventory_visible")) then
		if (splt.active) then return; end
		if (healing.item and healing.timer) then return; end
		if (isCursorOnArea(sW*0.015,sH*0.2,sW*0.155,sH*0.6)) then
			if (drag.source == "ground") then
				triggerServerEvent("takeItemFromGround",localPlayer,drag.object,drag.item,getElementData(drag.object,drag.item))
			end
		elseif isCursorOnArea(sW*0.176,sH*0.2,sW*0.155,sH*0.6) then
			if (drag.source == "inventory") then
				if (drag.item == "medkit") then
					if (getElementHealth(localPlayer) == 100) then return; end
					local time = 7*1000;
					healing.item = drag.item;
					healing.amount = 100;
					setPedAnimation(localPlayer, "FOOD", "EAT_Burger",time, true, false, false, false);
					healing.timer = setTimer(function()
						triggerServerEvent("useItemFromInventory",localPlayer,healing.item,false,false,healing.amount)
						healing.item = false;
						healing.timer = false;
						healing.amount = false;
						setPedAnimation(localPlayer,nil,nil);
					end,time,1);
				elseif (drag.item == "first_aid") then
					if (getElementHealth(localPlayer) == 100) then return; end
					local time = 5*1000;
					healing.item = drag.item;
					healing.amount = 25;
					setPedAnimation(localPlayer, "FOOD", "EAT_Burger",time, true, false, false, false);
					healing.timer = setTimer(function()
						triggerServerEvent("useItemFromInventory",localPlayer,healing.item,false,false,healing.amount)
						healing.item = false;
						healing.timer = false;
						healing.amount = false;
						setPedAnimation(localPlayer,nil,nil);
					end,time,1);
				elseif (drag.item == "bandage") then
					if (getElementHealth(localPlayer) == 100) then return; end
					local time = 3*1000;
					healing.item = drag.item;
					healing.amount = 15;
					setPedAnimation(localPlayer, "FOOD", "EAT_Burger",time, true, false, false, false);
					healing.timer = setTimer(function()
						triggerServerEvent("useItemFromInventory",localPlayer,healing.item,false,false,healing.amount)
						healing.item = false;
						healing.timer = false;
						healing.amount = false;
						setPedAnimation(localPlayer,nil,nil);
					end,time,1);
				elseif (drag.item == "energy_drink") then
					if (getElementHealth(localPlayer) == 100) then return; end
					local time = 2*1000;
					healing.item = drag.item;
					healing.amount = 7;
					setPedAnimation(localPlayer, "FOOD", "EAT_Burger",time, true, false, false, false);
					healing.timer = setTimer(function()
						triggerServerEvent("useItemFromInventory",localPlayer,healing.item,false,false,healing.amount)
						healing.item = false;
						healing.timer = false;
						healing.amount = false;
						setPedAnimation(localPlayer,nil,nil);
					end,time,1);
				elseif (drag.item == "painkiller") then
					if (getElementHealth(localPlayer) == 100) then return; end
					local time = 2*1000;
					healing.item = drag.item;
					healing.amount = 5;
					setPedAnimation(localPlayer, "FOOD", "EAT_Burger",time, true, false, false, false);
					healing.timer = setTimer(function()
						triggerServerEvent("useItemFromInventory",localPlayer,healing.item,false,false,healing.amount)
						healing.item = false;
						healing.timer = false;
						healing.amount = false;
						setPedAnimation(localPlayer,nil,nil);
					end,time,1);
				else
					triggerServerEvent("useItemFromInventory",localPlayer,drag.item)
				end
				if (weapons[drag.item]) then
					local weapon = weapons[drag.item];
					local slot = false;
					if (weapon[1] == "primary") then
						for i=1,2 do
							local wep = getElementData(localPlayer,"weapon"..i) or "";
							if (wep == "") then slot = i; break; end
						end
					elseif (weapon[1] == "secondary") then
						local wep = getElementData(localPlayer,"weapon3") or "";
						if (wep == "") then slot = 3; end
					elseif (weapon[1] == "meele") then
						local wep = getElementData(localPlayer,"weapon4") or "";
						if (wep == "") then slot = 4; end
					elseif (weapon[1] == "grenade") then
						local wep = getElementData(localPlayer,"weapon5") or "";
						if (wep == "") then slot = 5; end
					end
					if (slot) then triggerServerEvent("equipPlayerWeapon",localPlayer,drag.item,drag.object,drag.source,weapons[drag.item][1],slot); end
				end
			end
		end
	end
end);

bindKey("f","down",function()
	if (not checkAuthorized()) then return; end
	if (healing.item and isTimer(healing.timer)) then
		setPedAnimation(localPlayer,nil,nil);
		killTimer(healing.timer);
		healing.item = false;
		healing.timer = false;
		healing.amount = false;
	end
end);

function selectWeapon(key)
	if (not checkAuthorized()) then return; end
	if (isPedInVehicle(localPlayer) or exports.pb_map:isPlayerMapVisible()) then return; end
	if (getPedWeapon(localPlayer,11) == 46) then return setPedWeaponSlot(localPlayer,11); end
	if (getPedControlState("aim_weapon")) then return; end
	if (key ~= "x") then
		triggerServerEvent("armPlayerWeapon",localPlayer,key);
	else
		triggerServerEvent("armPlayerWeapon",localPlayer,0);
	end
end
bindKey("1","down",selectWeapon);
bindKey("2","down",selectWeapon);
bindKey("3","down",selectWeapon);
bindKey("4","down",selectWeapon);
bindKey("5","down",selectWeapon);
bindKey("x","down",selectWeapon);

bindKey("mouse_wheel_up","down",function()
	if (getElementData(localPlayer,"inventory_visible")) then
		if (isCursorOnArea(sW*0.015,sH*0.2,sW*0.155,sH*0.6)) then
			if (#getGroundItems()*sH*0.0542 < sH*0.6-2) then return; end
			ground.scroll=ground.scroll-25;
			if (ground.scroll < 0) then ground.scroll = 0; end
		elseif (isCursorOnArea(sW*0.176,sH*0.2,sW*0.155,sH*0.6)) then
			if (#getPlayerItems()*sH*0.0542 < sH*0.6-2) then return; end
			inventory.scroll=inventory.scroll-25;
			if (inventory.scroll < 0) then inventory.scroll = 0; end
		end
	else
		local slot = getElementData(localPlayer,"wepslot") or 0;
		slot = slot-1;
		if (slot < 0) then slot = 5; end
		for i=5,0,-1 do
			if (i ~= 0) then
				local weapon = getElementData(localPlayer,"weapon"..i) or "";
				if (weapon == "" and slot == i) then slot = slot-1; end
				if (weapon ~= "" and slot == i) then
					local wepammo = weapons[weapon][5];
					if (wepammo ~= "" and getElementData(localPlayer,wepammo) <= 0) then slot = slot-1; end
				end
			end
		end
		selectWeapon(slot);
	end
end)

bindKey("mouse_wheel_down","down",function()
	if (getElementData(localPlayer,"inventory_visible")) then
		if (isCursorOnArea(sW*0.015,sH*0.2,sW*0.155,sH*0.6)) then
			if (#getGroundItems()*sH*0.0542 < sH*0.6-2) then return; end
			ground.scroll=ground.scroll+25;
			if (ground.scroll > #getGroundItems()*sH*0.0542-sH*0.6-2) then ground.scroll = #getGroundItems()*sH*0.0542-sH*0.6-2; end
		elseif (isCursorOnArea(sW*0.176,sH*0.2,sW*0.155,sH*0.6)) then
			if (#getPlayerItems()*sH*0.0542 < sH*0.6-2) then return; end
			inventory.scroll=inventory.scroll+25;
			if (inventory.scroll > #getPlayerItems()*sH*0.0542-sH*0.6-2) then inventory.scroll = #getPlayerItems()*sH*0.0542-sH*0.6-2; end
		end
	else
		local slot = getElementData(localPlayer,"wepslot") or 0;
		slot = slot+1;
		for i=0,5 do
			if (i ~= 0) then
				local weapon = getElementData(localPlayer,"weapon"..i) or "";
				if (weapon == "" and slot == i) then slot = slot+1; end
				if (weapon ~= "" and slot == i) then
					local wepammo = weapons[weapon][5];
					if (wepammo ~= "" and getElementData(localPlayer,wepammo) <= 0) then slot = slot+1; end
				end
			end
		end
		if (slot > 5) then slot = 0; end
		selectWeapon(slot);
	end
end)
