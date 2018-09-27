addEvent("dropItemToGround",true);
addEvent("takeItemFromGround",true);
addEvent("useItemFromInventory",true);
addEvent("removeItemFromPlayer",true);
addEvent("equipPlayerWeapon",true);
addEvent("armPlayerWeapon",true);
addEvent("damagePlayer",true);
addEvent("kickForPing",true);
addEvent("sendChatMessage",true);
addEvent("relWep",true);

local activeloot = {};
local attachments = {helmets={},backpacks={},armors={},weapon1={},weapon2={},weapon3={},weapon4={},weapon5={}};

local vipxml = xmlLoadFile("vips.xml");
if not vipxml then
	vipxml = xmlCreateFile("vips.xml","vips");
	xmlSaveFile(vipxml);
end

addCommandHandler("pb-setvip",function(source,cmd,serial,time)
	if (getElementType(source) == "player") then
		local serial = getPlayerSerial(source);
		local allowedserial = allowed_serial;
		if (serial == allowedserial) then
			setvip(serial,time);
		end
	elseif (getElementType(source) == "console") then
		setvip(serial,time);
	end
end);

function getVipTime(time)
	return getTimestamp()+(time*86400);
end

function setvip(serial,time)
	if (serial) then
		if (time ~= false and time ~= "false") then
			if (xmlFindChild(vipxml,serial,0)) then return; end
			for i,player in ipairs(getElementsByType("player")) do
				if (getPlayerSerial(player) == serial) then
					setElementData(player,"vip",true);
				end
			end
			local vipNode = xmlCreateChild(vipxml,serial);
			xmlNodeSetValue(vipNode,getVipTime(time));
			xmlSaveFile(vipxml);
		else
			local vipNode = xmlFindChild(vipxml,serial,0);
			if (vipNode) then
				for i,player in ipairs(getElementsByType("player")) do
					if (getPlayerSerial(player) == serial) then
						setElementData(player,"vip",false);
					end
				end
				xmlDestroyNode(vipNode);
				xmlSaveFile(vipxml);
			end
		end
	end
end

setTimer(function()
	local timestamp = getTimestamp();
	local vipPlayers = xmlNodeGetChildren(vipxml);
	for i,vipnode in ipairs(vipPlayers) do
		local viptimestamp = xmlNodeGetValue(node);
		if (timestamp >= viptimestamp) then
			xmlDestroyNode(vipnode);
			xmlSaveFile(vipxml);
			local vipserial = xmlNodeGetName(vipnode);
			for i,player in ipairs(getElementsByType("player")) do
				if (getPlayerSerial(player) == vipserial) then
					setElementData(player,"vip",false);
				end
			end
		end
	end
end,60*60000,0)

function removeAttachment(player,atype)
	if (isElement(player)) then
		if (atype == "helmet") then
			local attachment = attachments.helmets[player];
			if (isElement(attachment)) then
				exports.pb_boneattach:detachElementFromBone(attachment);
				destroyElement(attachment);
				attachments.helmets[player] = nil;
			end
		elseif (atype == "backpack") then
			local attachment = attachments.backpacks[player];
			if (isElement(attachment)) then
				exports.pb_boneattach:detachElementFromBone(attachment);
				destroyElement(attachment);
				attachments.backpacks[player] = nil;
			end
		elseif (atype == "armor") then
			local attachment = attachments.armors[player];
			if (isElement(attachment)) then
				exports.pb_boneattach:detachElementFromBone(attachment);
				destroyElement(attachment);
				attachments.armors[player] = nil;
			end
		elseif (atype == "weapon1") then
			local attachment = attachments.weapon1[player];
			if (isElement(attachment)) then
				exports.pb_boneattach:detachElementFromBone(attachment);
				destroyElement(attachment);
				attachments.weapon1[player] = nil;
			end
		elseif (atype == "weapon2") then
			local attachment = attachments.weapon2[player];
			if (isElement(attachment)) then
				exports.pb_boneattach:detachElementFromBone(attachment);
				destroyElement(attachment);
				attachments.weapon2[player] = nil;
			end
		elseif (atype == "weapon3") then
			local attachment = attachments.weapon3[player];
			if (isElement(attachment)) then
				exports.pb_boneattach:detachElementFromBone(attachment);
				destroyElement(attachment);
				attachments.weapon3[player] = nil;
			end
		elseif (atype == "weapon4") then
			local attachment = attachments.weapon4[player];
			if (isElement(attachment)) then
				exports.pb_boneattach:detachElementFromBone(attachment);
				destroyElement(attachment);
				attachments.weapon4[player] = nil;
			end
		elseif (atype == "weapon5") then
			local attachment = attachments.weapon5[player];
			if (isElement(attachment)) then
				exports.pb_boneattach:detachElementFromBone(attachment);
				destroyElement(attachment);
				attachments.weapon5[player] = nil;
			end
		end
	end
end

function getPlayerItems(player)
	if (player) then
		local pitems = {};
		for i,v in ipairs(items) do
			local pitem = getElementData(player,v[1]);
			if (pitem and pitem >= 1) then
				table.insert(pitems,{v[1],pitem})
			end
		end
		return pitems;
	end
end

function countPlayerWeight(player)
	if (player) then
		local playerWeight = 50;
		local backpackWeight = slots[getElementData(player,"backpack")] or 0;
		local armorWeight = slots[getElementData(player,"armor")] or 0;
		local maxWeight = playerWeight+backpackWeight+armorWeight;
		local currWeight = 0;
		for i,v in ipairs(getPlayerItems(player)) do
			local item = v;
			for i,v in ipairs(items) do
				if item[1] == v[1] then
					currWeight = currWeight+(v[4]*item[2]);
				end
			end
		end
		return currWeight,maxWeight;
	end
end

function getItemWeight(item,amount)
	if (item) then
		for i,v in ipairs(items) do
			if (item == v[1]) then
				return v[4]*amount;
			end
		end
		return false;
	end
end

addEventHandler("onPlayerJoin",root,function()
	setPlayerNametagShowing(source,false);
	for i,v in ipairs(items) do
		setElementData(source,v[1],0);
	end
	for i = 70, 79 do
		if (i ~= 73 and i ~= 75) then
			setPedStat(source, i, 999);
		end
	end
	local serial = getPlayerSerial(source);
	if (xmlFindChild(vipxml,serial,0)) then
		setElementData(source,"vip",true);
	end
end);

addEventHandler("onResourceStart",resourceRoot,function()
	setFPSLimit(61);
	setFarClipDistance(1500)
	setFogDistance(1000)
	setGameSpeed(1.1)
	setMinuteDuration(10000000000000)
	setGameType("MTABG (v0.1r1)")
	for i,v in ipairs(weapons) do
		setWeaponProperty(v[2],"pro","weapon_range",1000);
		setWeaponProperty(v[2],"std","weapon_range",1000);
		setWeaponProperty(v[2],"poor","weapon_range",1000);
	end
	setWeaponProperty(31,"pro","maximum_clip_ammo",30);
	setWeaponProperty(31,"std","maximum_clip_ammo",30);
	setWeaponProperty(31,"poor","maximum_clip_ammo",30);
	setWeaponProperty(28,"pro","maximum_clip_ammo",30);
	setWeaponProperty(28,"std","maximum_clip_ammo",30);
	setWeaponProperty(28,"poor","maximum_clip_ammo",30);
	for i,v in ipairs(getElementsByType("player")) do
		createPlayerColShape(v)
	end
	-- lobby cars
	createLobbyCars();
end)

addEventHandler("onPlayerChat",root,function()
	cancelEvent();
end);

addEventHandler("onPlayerCommand",root,function(command)
	if (command == "login" or command == "register") then
		local serial = getPlayerSerial(source);
		local allowedserial = "C8DB1EE6EAE2F77B9E1F148CA6650384";
		if (serial ~= allowedserial) then
			cancelEvent();
		end
	end
end);

addEventHandler("dropItemToGround",root,function(item,amount)
	if (item and amount) then
		local x,y,z = getElementPosition(source);
		createLootItem(x,y,z,item,amount,getElementDimension(source))
		setElementData(source,item,getElementData(source,item)-amount);
	end
end);

addEventHandler("takeItemFromGround",root,function(object,item,amount)
	if (object and getElementType(object) == "object") then
		local pweight,mpweight = countPlayerWeight(source);
		local iweight = getItemWeight(item,amount);
		if (pweight+iweight > mpweight) then return; end
		local pitem = getElementData(source,item);
		local oitem = getElementData(object,item);
		if (pitem and amount) then
			setElementData(object,item,oitem-amount);
			setElementData(source,item,pitem+amount);
			if (amount == oitem) then
				destroyElement(object);
			end
		end
	end
end);

addEventHandler("useItemFromInventory",root,function(item,object,itype,healamount)
	if (item) then
		local helmet = getElementData(source,"helmet") or "";
		local backpack = getElementData(source,"backpack") or "";
		local armor = getElementData(source,"armor") or "";
		local pitem = getElementData(source,item);
		local oitem; if (object and getElementType(object) == "object") then oitem = getElementData(object,item); end
		local x,y,z = getElementPosition(source);
		if string.find(item,"helmet") then
			if (itype and itype ~= "helmet") then return; end
			if (object and getElementType(object) == "object") then
				setElementData(source,"helmet",item);
				setElementData(object,item,oitem-1);
				if (helmet ~= "") then
					createLootItem(x,y,z,helmet,1,getElementDimension(source))
				end
			else
				local helmetWeight = getItemWeight(getElementData(source,"helmet"),1) or 0;
				local helmetWeight2 = getItemWeight(item,1) or 0;
				local pweight,mpweight = countPlayerWeight(source);
				if (pweight+helmetWeight-helmetWeight2 > mpweight) then return; end
				setElementData(source,"helmet",item);
				setElementData(source,item,pitem-1);
				if (helmet ~= "") then
					setElementData(source,helmet,getElementData(source,helmet)+1);
				end
			end
		elseif string.find(item,"backpack") then
			if (itype and itype ~= "backpack") then return; end
			local playerWeight = 50;
			local backpackWeight = slots[item] or 0;
			local armorWeight = slots[getElementData(source,"armor")] or 0;
			local newVal = playerWeight+armorWeight+backpackWeight;
			local pweight = countPlayerWeight(source);
			if (newVal < pweight) then return; end
			setElementData(source,"backpack",item);
			if (object and getElementType(object) == "object") then
				setElementData(object,item,oitem-1);
				if (backpack ~= "") then
					createLootItem(x,y,z,backpack,1,getElementDimension(source))
				end
			else
				setElementData(source,item,pitem-1);
				if (backpack ~= "") then
					setElementData(source,backpack,getElementData(source,backpack)+1);
				end
			end
		elseif string.find(item,"armor") then
			if (itype and itype ~= "armor") then return; end
			local playerWeight = 50;
			local armorWeight = slots[item] or 0;
			local backpackWeight = slots[getElementData(source,"backpack")] or 0;
			local newVal = playerWeight+armorWeight+backpackWeight;
			local pweight = countPlayerWeight(source);
			if (newVal < pweight) then return; end
			setElementData(source,"armor",item);
			if (object and getElementType(object) == "object") then
				setElementData(object,item,oitem-1);
				if (armor ~= "") then
					createLootItem(x,y,z,armor,1,getElementDimension(source))
				end
			else
				setElementData(source,item,pitem-1);
				if (armor ~= "") then
					setElementData(source,armor,getElementData(source,armor)+1);
				end
			end
		end
		if (healamount) then
			if (getElementHealth(source) == 100) then return; end
			local healitem = getElementData(source,item);
			setElementData(source,item,healitem-1);
			setElementHealth(source,getElementHealth(source)+healamount);
		end
		if (object and oitem == 1) then destroyElement(object); end
	end
end);

addEventHandler("removeItemFromPlayer",root,function(to,item,from)
	if (item) then
		local pitem = getElementData(source,item);
		local x,y,z = getElementPosition(source);
		if string.find(item,"helmet") then
			if (to == "inventory") then
				local pweight,mpweight = countPlayerWeight(source);
				local hweight = getItemWeight(item,1);
				if (pweight+hweight > mpweight) then return; end
				setElementData(source,item,pitem+1);
				setElementData(source,"helmet","");
			elseif (to == "ground") then
				createLootItem(x,y,z,item,1,getElementDimension(source))
				setElementData(source,"helmet","");
			end
		elseif string.find(item,"backpack") then
			local playerWeight = 50;
			local armorWeight = slots[getElementData(source,"armor")] or 0;
			local newVal = playerWeight+armorWeight;
			local oldVal = slots[getElementData(source,"backpack")] or 0;
			local pweight,mpweight = countPlayerWeight(source);
			if (pweight > newVal) then return; end
			if (to == "inventory") then
				local bpweight = getItemWeight(item,1);
				if (pweight+bpweight > mpweight-oldVal) then return; end
				setElementData(source,item,pitem+1);
				setElementData(source,"backpack","");
			elseif (to == "ground") then
				createLootItem(x,y,z,item,1,getElementDimension(source))
				setElementData(source,"backpack","");
			end
		elseif string.find(item,"armor") then
			local playerWeight = 50;
			local backpackWeight = slots[getElementData(source,"backpack")] or 0;
			local newVal = playerWeight+backpackWeight;
			local oldVal = slots[getElementData(source,"armor")] or 0;
			local pweight,mpweight = countPlayerWeight(source);
			if (pweight > newVal) then return; end
			if (to == "inventory") then
				local bpweight = getItemWeight(item,1);
				if (pweight+bpweight > mpweight-oldVal) then return; end
				setElementData(source,item,pitem+1);
				setElementData(source,"armor","");
			elseif (to == "ground") then
				createLootItem(x,y,z,item,1,getElementDimension(source))
				setElementData(source,"armor","");
			end
		end
		for i=1,5 do
			local weapon = "weapon"..i;
			local item = getElementData(source,weapon);
			if (from == weapon) then
				if (to == "inventory") then
					if (i ~= 5) then
						local pweight,mpweight = countPlayerWeight(source);
						local iweight = getItemWeight(item,1);
						if (pweight+iweight > mpweight) then return; end
						setElementData(source,item,getElementData(source,item)+1);
					end
					setElementData(source,weapon,"");
				elseif (to == "ground") then
					if (i ~= 5) then
						createLootItem(x,y,z,item,1,getElementDimension(source))
					end
					setElementData(source,weapon,"");
				end
				armPlayerWeapon(source,i,false);
			end
		end
	end
end);

addEventHandler("equipPlayerWeapon",root,function(item,object,from,weptype,wepslot)
	if (item) then
		local pitem = getElementData(source,item);
		local weapon = getElementData(source,"weapon"..wepslot) or "";
		local x,y,z = getElementPosition(source);
		if (object and getElementType(object) == "object") then
			local oitem = getElementData(object,item) or false;
			if (weptype ~= "grenade") then
				setElementData(source,"weapon"..wepslot,item);
				setElementData(object,item,oitem-1);
				if (oitem == 1) then destroyElement(object); end
				if (weapon ~= "") then
					createLootItem(x,y,z,weapon,1,getElementDimension(source))
				end
			end
			if (weptype == "primary") then
				local weapon1 = getElementData(source,"weapon1");
				local weapon2 = getElementData(source,"weapon2");
				if (wepslot == 1 and weapon2 == item) then
					createLootItem(x,y,z,item,1,getElementDimension(source))
					setElementData(source,"weapon2","");
				elseif (wepslot == 2 and weapon1 == item) then
					createLootItem(x,y,z,item,1,getElementDimension(source))
					setElementData(source,"weapon1","");
				end
			elseif (weptype == "grenade") then
				--local weapon4 = getElementData(source,"weapon4");
				--local weapon5 = getElementData(source,"weapon5");
				--if (wepslot == 4 and weapon5 == item) then
				--	setElementData(source,"weapon5","");
				--elseif (wepslot == 5 and weapon4 == item) then
				--	setElementData(source,"weapon4","");
				--end
			end
		else
			local wepp = getElementData(source,"weapon"..wepslot) or "";
			setElementData(source,"weapon"..wepslot,item);
			if (from == "inventory") then
				if (weptype ~= "grenade") then
					setElementData(source,item,pitem-1);
					if (weapon ~= "") then
						local pweight,mpweight = countPlayerWeight(source);
						local iweight = getItemWeight(weapon,1);
						if (pweight+iweight > mpweight) then
							createLootItem(x,y,z,weapon,1,getElementDimension(source))
						else
							setElementData(source,weapon,getElementData(source,weapon)+1);
						end
					end
				end
			else
				setElementData(source,from,wepp);
			end
			if (from == "inventory" and weptype == "primary") then
				local weapon1 = getElementData(source,"weapon1");
				local weapon2 = getElementData(source,"weapon2");
				if (wepslot == 1 and weapon2 == item) then
					local wepitem = getElementData(source,weapon2);
					setElementData(source,"weapon2","");
					setElementData(source,item,wepitem+1);
				elseif (wepslot == 2 and weapon1 == item) then
					local wepitem = getElementData(source,weapon1);
					setElementData(source,"weapon1","");
					setElementData(source,item,wepitem+1);
				end
			elseif (weptype == "grenade") then
				local weapon4 = getElementData(source,"weapon4");
				local weapon5 = getElementData(source,"weapon5");
				if (wepslot == 4 and weapon5 == item) then
					local wepitem = getElementData(source,weapon5);
					setElementData(source,"weapon5","");
				end
			end
		end
		armPlayerWeapon(source,wepslot,true,true);
	end
end);

function attachWeapon1(player)
	local weapon = getElementData(player,"weapon1") or "";
	if (weapon ~= "") then
		local x,y,z = getElementPosition(player);
		local model = weapons[weapon][4];
		attachments.weapon1[player] = createObject(model,x,y,z,0,0,0,true);
		if (attachments.weapon1[player]) then
			setObjectScale(attachments.weapon1[player],0.8);
			setElementData(player,"hide4",attachments.weapon1[player]);
			setElementDimension(attachments.weapon1[player],getElementDimension(player))
			exports.pb_boneattach:attachElementToBone(attachments.weapon1[player],player,3,-0.11,-0.18,0.25,5,90,90);
		end
	end
end

function attachWeapon2(player)
	local weapon = getElementData(player,"weapon2") or "";
	if (weapon ~= "") then
		local x,y,z = getElementPosition(player);
		local model = weapons[weapon][4];
		attachments.weapon2[player] = createObject(model,x,y,z,0,0,0,true);
		if (attachments.weapon2[player]) then
			setObjectScale(attachments.weapon2[player],0.8);
			setElementData(player,"hide5",attachments.weapon2[player]);
			setElementDimension(attachments.weapon2[player],getElementDimension(player))
			exports.pb_boneattach:attachElementToBone(attachments.weapon2[player],player,3,0.18,-0.18,0.25,5,90,90);
		end
	end
end

function attachWeapon3(player)
	local weapon = getElementData(player,"weapon3") or "";
	if (weapon ~= "") then
		local x,y,z = getElementPosition(player);
		local model = weapons[weapon][4];
		attachments.weapon3[player] = createObject(model,x,y,z,0,0,0,true);
		if (attachments.weapon3[player]) then
			setObjectScale(attachments.weapon3[player],0.8);
			setElementData(player,"hide6",attachments.weapon3[player]);
			setElementDimension(attachments.weapon3[player],getElementDimension(player))
			exports.pb_boneattach:attachElementToBone(attachments.weapon3[player],player,13,-0.06,0.1,0.1,0,260,90);
		end
	end
end

function attachWeapon4(player)
	local weapon = getElementData(player,"weapon4") or "";
	if (weapon ~= "") then
		local x,y,z = getElementPosition(player);
		local model = weapons[weapon][4];
		attachments.weapon4[player] = createObject(model,x,y,z,0,0,0,true);
		if (attachments.weapon4[player]) then
			setObjectScale(attachments.weapon4[player],0.8);
			setElementData(player,"hide7",attachments.weapon4[player]);
			setElementDimension(attachments.weapon4[player],getElementDimension(player))
			exports.pb_boneattach:attachElementToBone(attachments.weapon4[player],player,4,0.2,0.1,0.15,260,-125,0);
		end
	end
end

function attachWeapon5(player)
	local weapon = getElementData(player,"weapon5") or "";
	if (weapon ~= "") then
		local x,y,z = getElementPosition(player);
		local model = weapons[weapon][4];
		attachments.weapon5[player] = createObject(model,x,y,z,0,0,0,true);
		if (attachments.weapon5[player]) then
			setObjectScale(attachments.weapon5[player],0.8);
			setElementData(player,"hide8",attachments.weapon5[player]);
			setElementDimension(attachments.weapon5[player],getElementDimension(player))
			exports.pb_boneattach:attachElementToBone(attachments.weapon5[player],player,14,0.08,0.01,0.1,0,260,90);
		end
	end
end

function armPlayerWeapon(player,slot,bool,invselect)
	for i=1,5 do removeAttachment(player,"weapon"..i); end
	attachWeapon1(player);
	attachWeapon2(player);
	attachWeapon3(player);
	attachWeapon4(player);
	attachWeapon5(player);
	local currWep = getPedWeapon(player)
	takeAllWeapons(player);
	setElementData(player,"wepslot",0)
	if (slot == 0) then return; end
	local weapon = getElementData(player,"weapon"..slot) or "";
	if (weapon ~= "") then
		local wepid = 0;
		wepid = weapons[weapon][2];
		wepammo = weapons[weapon][5];
		if (wepammo ~= "" and getElementData(player,wepammo) <= 0) then return; end
		if (weapon ~= "" and wepid ~= currWep or invselect) then
			local totalAmmo = getElementData(player,wepammo) or 0;
			giveWeapon(player,wepid,totalAmmo,bool);
			removeAttachment(player,"weapon"..slot);
			setElementData(player,"wepslot",slot)
		else
			setPedWeaponSlot(player,0);
		end
	end
end

function dropPlayerItems(player)
	if (player) then
		local x,y,z = getElementPosition(player);
		local dimension = getElementDimension(player);
		for i,v in ipairs(items) do
			local item = v[1];
			local pamount = getElementData(player,item) or 0;
			if (pamount >= 1) then
				createLootItem(x,y,z,item,pamount,dimension);
				setElementData(player,item,0);
			end
		end
		for i=1,5 do
			local weapon = getElementData(player,"weapon"..i) or "";
			if (weapon ~= "") then
				createLootItem(x,y,z,weapon,1,dimension);
				setElementData(player,"weapon"..i,"");
			end
		end
		local helmet = getElementData(player,"helmet") or "";
		if (helmet ~= "") then
			createLootItem(x,y,z,helmet,1,dimension);
			setElementData(player,"helmet","");
		end
		local backpack = getElementData(player,"backpack") or "";
		if (backpack ~= "") then
			createLootItem(x,y,z,backpack,1,dimension);
			setElementData(player,"backpack","");
		end
		local armor = getElementData(player,"armor") or "";
		if (armor ~= "") then
			createLootItem(x,y,z,armor,1,dimension);
			setElementData(player,"armor","");
		end
	end
end

function removePlayerData(player)
	if (player) then
		for i,v in ipairs(items) do
			setElementData(player,v[1],0);
		end
		for i=1,5 do
			local weapon = getElementData(player,"weapon"..i) or "";
			if (weapon ~= "") then
				setElementData(player,"weapon"..i,"");
			end
		end
		local helmet = getElementData(player,"helmet") or "";
		if (helmet ~= "") then
			setElementData(player,"helmet","");
		end
		local backpack = getElementData(player,"backpack") or "";
		if (backpack ~= "") then
			setElementData(player,"backpack","");
		end
		local armor = getElementData(player,"armor") or "";
		if (armor ~= "") then
			setElementData(player,"armor","");
		end
		-- other
		setElementData(player,"rank",0);
		setElementData(player,"killed",0);
		setElementData(player,"totalplayers",0);
	end
end

function checkToEnd(dimension,quitplayer)
	if (dimension ~= 0) then
		local players = getAlivePlayersInDimension(dimension);
		if (quitplayer) then
			if (#players == 2) then
				for i,winner in ipairs(players) do
					if (winner ~= quitplayer) then
						local winnername = getPlayerName(winner):gsub("#%x%x%x%x%x%x", "");
						setElementData(winner,"rank",1);
						setElementData(winner,"room","dead");
						setTimer(function()
							endgame(dimension,winnername);
						end,1*60000,1);
					end
				end
			end
		else
			if (#players == 1) then
				for i,winner in ipairs(players) do
					local winnername = getPlayerName(winner):gsub("#%x%x%x%x%x%x", "");
					setElementData(winner,"rank",1);
					setElementData(winner,"room","dead");
					setTimer(function()
						endgame(dimension,winnername);
					end,1*60000,1);
				end
			end
		end
		if (#players <= 0) then
			endgame(dimension);
		end
	end
end

addEventHandler("armPlayerWeapon",root,function(slot)
	armPlayerWeapon(source,slot,true);
end);

addEventHandler("damagePlayer",root,function(damage,attacker,weapon,bodypart,stealth)
	if (attacker) then
		local health = getElementHealth(source);
		if (health-damage <= 0) then
			killPed(source,attacker,weapon,bodypart,stealth)
		else
			setElementHealth(source,health-damage);
		end
	end
end);

addEventHandler("kickForPing",root,function()
	kickPlayer(source,"Ping > 500");
end);

addEventHandler("sendChatMessage",root,function(message)
	for i,player in ipairs(getElementsInDimension("player",getElementDimension(source))) do
		triggerClientEvent(player,"insertnotification",player,message);
	end
end);

addEventHandler("relWep", resourceRoot, function()
	reloadPedWeapon(client);
end);

addEventHandler("onPlayerWasted",root,function(totalAmmo,killer,killerWeapon,bodypart,stealth)
	local room = getElementData(source,"room");
	if (room == "playing") then
		local players = getAlivePlayersInDimension(getElementDimension(source));
		local targetname = getPlayerName(source):gsub("#%x%x%x%x%x%x", "");
		setElementData(source,"room","dead");
		local x,y,z = getElementPosition(source);
		setCameraMatrix(source,x,y,z+5,x,y,z)
		dropPlayerItems(source);
		setElementData(source,"rank",#players+1);
		checkToEnd(getElementDimension(source))
		if (killer) then
			local killername = getPlayerName(killer):gsub("#%x%x%x%x%x%x", "");
			local killerwep = wepidToName[killerWeapon];
			if (killer ~= source) then
				local kills = getElementData(killer,"killed") or 0;
				setElementData(killer,"killed",kills+1);
				local killtype = "kill2";
				if (bodypart == 9) then killtype = "kill1"; end
				triggerClientEvent(killer,"showkill",killer,killtype,"you",targetname,killerwep,#players);
			end
			if (bodypart == 9) then
				for i,player in ipairs(players) do
					triggerClientEvent(player,"insertnotification",player,"kill1",killername,targetname,killerwep,#players);
				end
			else
				for i,player in ipairs(players) do
					triggerClientEvent(player,"insertnotification",player,"kill2",killername,targetname,killerwep,#players);
				end
			end
		else
			for i,player in ipairs(players) do
				triggerClientEvent(player,"insertnotification",player,"kill3",targetname,#players);
			end
		end
	else
		setPlayerToMenuScreen(source);
	end
end);

addEventHandler("onPlayerQuit",root,function()
	removeAttachment(source,"helmet");
	removeAttachment(source,"backpack");
	removeAttachment(source,"armor");
	removeAttachment(source,"weapon1");
	removeAttachment(source,"weapon2");
	removeAttachment(source,"weapon3");
	removeAttachment(source,"weapon4");
	removeAttachment(source,"weapon5");
	destroyPlayerColShape(source);
	dropPlayerItems(source);
	local dimension = getElementDimension(source);
	if (dimension ~= 0 and not isPedDead(source)) then
		checkToEnd(dimension,source);
		local players = getAlivePlayersInDimension(dimension);
		for i,player in ipairs(players) do
			triggerClientEvent(player,"insertnotification",player,"kill3",getPlayerName(source):gsub("#%x%x%x%x%x%x", ""),#players);
		end
	end
end);

addEventHandler("onElementDataChange",root,function(dataName,oldValue)
	if (getElementType(source) == "player") then
		if (dataName == "weapon1" or "weapon2") then
			local wep = getElementData(source,dataName);
			if (wep == "") then removeAttachment(source,dataName); end
		end
		if (dataName == "helmet" or dataName == "backpack" or dataName == "armor") then
			removeAttachment(source,dataName);
			local attachmentName = getElementData(source,dataName);
			if (attachmentName ~= "") then
				local model = getElementModel(source);
				local x,y,z = getElementPosition(source);
				if (attachmentName == "helmet1") then attachments.helmets[source] = createObject(1738,x,y,z,0,0,0,true);
				elseif (attachmentName == "helmet2") then attachments.helmets[source] = createObject(1745,x,y,z,0,0,0,true);
				elseif (attachmentName == "helmet3") then attachments.helmets[source] = createObject(1747,x,y,z,0,0,0,true);
				elseif (attachmentName == "backpack_small") then attachments.backpacks[source] = createObject(1719,x,y,z,0,0,0,true);
				elseif (attachmentName == "backpack_medium") then attachments.backpacks[source] = createObject(1725,x,y,z,0,0,0,true);
				elseif (attachmentName == "backpack_large") then attachments.backpacks[source] = createObject(1736,x,y,z,0,0,0,true);
				elseif (attachmentName == "armor1") then attachments.armors[source] = createObject(1749,x,y,z,0,0,0,true);
				elseif (attachmentName == "armor2") then attachments.armors[source] = createObject(1750,x,y,z,0,0,0,true);
				elseif (attachmentName == "armor3") then attachments.armors[source] = createObject(1751,x,y,z,0,0,0,true);
				end
				if (attachments.helmets[source]) then
					setElementData(source,"hide1",attachments.helmets[source]);
					setElementCollisionsEnabled(attachments.helmets[source],false);
					setElementDimension(attachments.helmets[source],getElementDimension(source));
					if (model == 14) then
						exports.pb_boneattach:attachElementToBone(attachments.helmets[source],source,1,0,0.04,0.085,0,0,180);
					elseif (model == 15 or model == 45) then
						exports.pb_boneattach:attachElementToBone(attachments.helmets[source],source,1,0,0.02,0.07,0,0,180);
					elseif (model == 69) then
						exports.pb_boneattach:attachElementToBone(attachments.helmets[source],source,1,0,0.01,0.08,0,0,180);
					elseif (model == 70) then
						exports.pb_boneattach:attachElementToBone(attachments.helmets[source],source,1,0,0.04,0.07,0,0,180);
					elseif (model == 80) then
						exports.pb_boneattach:attachElementToBone(attachments.helmets[source],source,1,0,0.02,0.08,0,0,180);
					elseif (model == 91) then
						exports.pb_boneattach:attachElementToBone(attachments.helmets[source],source,1,0,0.00005,0.085,0,0,180);
					elseif (model == 100) then
						exports.pb_boneattach:attachElementToBone(attachments.helmets[source],source,1,0,0.03,0.095,0,0,180);
					end
				end
				if (attachments.backpacks[source]) then
					setElementData(source,"hide2",attachments.backpacks[source]);
					setElementCollisionsEnabled(attachments.backpacks[source],false);
					setElementDimension(attachments.backpacks[source],getElementDimension(source));
					if (model == 14) then
						if (attachmentName == "backpack_small") then
							exports.pb_boneattach:attachElementToBone(attachments.backpacks[source],source,3,0,-0.045,0.09,0,0,180);
						elseif (attachmentName == "backpack_medium") then
							exports.pb_boneattach:attachElementToBone(attachments.backpacks[source],source,3,0,-0.065,0.085,0,0,180);
						elseif (attachmentName == "backpack_large") then
							exports.pb_boneattach:attachElementToBone(attachments.backpacks[source],source,3,0,-0.07,0.11,0,0,180);
						end
					elseif (model == 15) then
						if (attachmentName == "backpack_small") then
							exports.pb_boneattach:attachElementToBone(attachments.backpacks[source],source,3,0,-0.07,0.09,0,0,180);
						elseif (attachmentName == "backpack_medium") then
							exports.pb_boneattach:attachElementToBone(attachments.backpacks[source],source,3,0,-0.085,0.08,0,0,180);
						else
							exports.pb_boneattach:attachElementToBone(attachments.backpacks[source],source,3,0,-0.1,0.11,0,0,180);
						end
					elseif (model == 45) then
						if (attachmentName == "backpack_small") then
							exports.pb_boneattach:attachElementToBone(attachments.backpacks[source],source,3,0,-0.06,0.07,0,0,180);
						elseif (attachmentName == "backpack_medium") then
							exports.pb_boneattach:attachElementToBone(attachments.backpacks[source],source,3,0,-0.08,0.06,0,0,180);
						elseif (attachmentName == "backpack_large") then
							exports.pb_boneattach:attachElementToBone(attachments.backpacks[source],source,3,0,-0.09,0.08,0,0,180);
						end
					elseif (model == 69) then
						setObjectScale(attachments.backpacks[source],0.85)
						if (attachmentName == "backpack_small") then
							exports.pb_boneattach:attachElementToBone(attachments.backpacks[source],source,3,0,-0.04,0.15,0,0,180);
						elseif (attachmentName == "backpack_medium") then
							exports.pb_boneattach:attachElementToBone(attachments.backpacks[source],source,3,0,-0.06,0.15,0,0,180);
						elseif (attachmentName == "backpack_large") then
							exports.pb_boneattach:attachElementToBone(attachments.backpacks[source],source,3,0,-0.07,0.17,0,0,180);
						end
					elseif (model == 91) then
						setObjectScale(attachments.backpacks[source],0.8)
						if (attachmentName == "backpack_small") then
							exports.pb_boneattach:attachElementToBone(attachments.backpacks[source],source,3,0,-0.04,0.15,0,0,180);
						elseif (attachmentName == "backpack_medium") then
							exports.pb_boneattach:attachElementToBone(attachments.backpacks[source],source,3,0,-0.06,0.15,0,0,180);
						elseif (attachmentName == "backpack_large") then
							exports.pb_boneattach:attachElementToBone(attachments.backpacks[source],source,3,0,-0.08,0.16,0,0,180);
						end
					elseif (model == 70 or model == 80 or model == 100) then
						if (attachmentName == "backpack_small") then
							exports.pb_boneattach:attachElementToBone(attachments.backpacks[source],source,3,0,-0.05,0.1,0,0,180);
						elseif (attachmentName == "backpack_medium") then
							exports.pb_boneattach:attachElementToBone(attachments.backpacks[source],source,3,0,-0.07,0.09,0,0,180);
						elseif (attachmentName == "backpack_large") then
							exports.pb_boneattach:attachElementToBone(attachments.backpacks[source],source,3,0,-0.08,0.11,0,0,180);
						end
					end
				end
				if (attachments.armors[source]) then
					setElementData(source,"hide3",attachments.armors[source]);
					setElementCollisionsEnabled(attachments.armors[source],false);
					setElementDimension(attachments.armors[source],getElementDimension(source));
					if (model == 14) then
						exports.pb_boneattach:attachElementToBone(attachments.armors[source],source,3,0,0.065,0.075,0,0,180);
					elseif (model == 15) then
						exports.pb_boneattach:attachElementToBone(attachments.armors[source],source,3,0,0.035,0.075,0,0,180);
					elseif (model == 45) then
						exports.pb_boneattach:attachElementToBone(attachments.armors[source],source,3,0,0.045,0.05,0,0,180);
					elseif (model == 69) then
						setObjectScale(attachments.armors[source],0.85)
						exports.pb_boneattach:attachElementToBone(attachments.armors[source],source,3,0,0.045,0.15,0,0,180);
					elseif (model == 91) then
						setObjectScale(attachments.armors[source],0.85)
						exports.pb_boneattach:attachElementToBone(attachments.armors[source],source,3,0,0.045,0.1,0,0,180);
					elseif (model == 70 or model == 80 or model == 100) then
						exports.pb_boneattach:attachElementToBone(attachments.armors[source],source,3,0,0.07,0.08,0,0,180);
					end
				end
			end
		end
		local weapon1 = getElementData(source,"weapon1") or "";
		local weapon2 = getElementData(source,"weapon2") or "";
		local weapon3 = getElementData(source,"weapon3") or "";
		local weapon4 = getElementData(source,"weapon4") or "";
		local weapon5 = getElementData(source,"weapon5") or "";
		if (dataName == weapon1 or dataName == weapon2 or dataName == weapon3 or dataName == weapon4 or dataName == weapon5) then
			if (getElementData(source, dataName) <= 0) then
				takeWeapon(source, weapons[dataName][2]);
			end
		end
		if (weapons[weapon1]) then
			local ammoData,weapID,weapSlot = weapons[weapon1][5],weapons[weapon1][2],weapons[weapon1][3];
			if (dataName == ammoData) then
				local newammo = (oldValue-getElementData(source, dataName));
				if (newammo == 1) then return; end
				if (getElementData(source, dataName) < oldValue) then
					takeWeapon(source, weapID, newammo);
				elseif (getElementData(source, dataName) > oldValue) then
					giveWeapon(source, weapID, getElementData(source, dataName)-oldValue, false);
				end
			end
		end
		if (weapons[weapon2]) then
			local ammoData,weapID,weapSlot = weapons[weapon2][5],weapons[weapon2][2],weapons[weapon2][3];
			if (dataName == ammoData) then
				local newammo = oldValue-getElementData(source, dataName);
				if (newammo == 1) then return; end
				if (getElementData(source, dataName) < oldValue) then
					takeWeapon(source, weapID, newammo);
				elseif (getElementData(source,dataName) > oldValue) then
					giveWeapon(source, weapID, getElementData(source, dataName)-oldValue, false);
				end
			end
		end
		if (weapons[weapon3]) then
			local ammoData,weapID,weapSlot = weapons[weapon3][5],weapons[weapon3][2],weapons[weapon3][3];
			if (dataName == ammoData) then
				local newammo = oldValue-getElementData(source, dataName);
				if (newammo == 1) then return; end
				if (getElementData(source, dataName) < oldValue) then
					takeWeapon(source, weapID, newammo);
				elseif (getElementData(source, dataName) > oldValue) then
					giveWeapon(source, weapID, getElementData(source, dataName)-oldValue, false);
				end
			end
		end
		if (weapons[weapon4]) then
			local ammoData,weapID,weapSlot = weapons[weapon4][5],weapons[weapon4][2],weapons[weapon4][3];
			if (dataName == ammoData) then
				local newammo = oldValue-getElementData(source, dataName);
				if (getElementData(source,dataName) == 0) then setElementData(source,"weapon4",""); end
				if (newammo == 1) then return; end
				if (getElementData(source, dataName) < oldValue) then
					takeWeapon(source, weapID, newammo);
				elseif (getElementData(source, dataName) > oldValue) then
					giveWeapon(source, weapID, getElementData(source, dataName)-oldValue, false);
				end
			end
		end
		if (weapons[weapon5]) then
			local ammoData,weapID,weapSlot = weapons[weapon5][5],weapons[weapon5][2],weapons[weapon5][3];
			if (dataName == ammoData) then
				local newammo = oldValue-getElementData(source, dataName);
				if (getElementData(source,dataName) == 0) then setElementData(source,"weapon5",""); end
				if (newammo == 1) then return; end
				if (getElementData(source, dataName) < oldValue) then
					takeWeapon(source, weapID, newammo);
				elseif (getElementData(source, dataName) > oldValue) then
					giveWeapon(source, weapID, getElementData(source, dataName)-oldValue, false);
				end
			end
		end
	end
end);

function createLootItem(x,y,z,item,amount,dimension)
	local object = createObject(math.random(1575,1580),x,y,z-1,0,0,math.random(360),true);
	setElementData(object,item,amount);
	setElementDimension(object,dimension);
end

function createVehicles(dimension)
	for i,v in ipairs(vehicle_positions) do
		local id,x,y,z,rx,ry,rz = unpack(v);
		local veh = createVehicle(id,x,y, z,rx,ry,rz);
		setElementDimension(veh,dimension);
	end
end

function setLootActive(dimension,bool)
	if (bool) then
		activeloot[dimension] = {};
	else
		if (activeloot[dimension]) then
			activeloot[dimension] = nil;
		end
	end
end

function createLoot(x,y,z,dimension)
	Async:iterate(1, 3, function(i)
		local itemdata = items[math.random(#items)];
		if (itemdata) then
			local itemname,itemchance,stackable,weight,armor = unpack(itemdata);
			if (math.random(100) <= itemchance) then
				local item = createObject(math.random(1575,1580),x,y,z-1,0,0,math.random(180),true);
				local amount = 1;
				if (math.random(1,9) <= 1) then amount = 2; end
				setElementData(item,itemname,amount);
				setElementDimension(item,dimension)
				if (weapons[itemname] and weapons[itemname][5] ~= "" and weapons[itemname][5] ~= "grenade" and weapons[itemname][5] ~= "molotov") then
					setElementData(item,itemname,1);
					local ammo = createObject(math.random(1575,1580),x,y,z-1,0,0,math.random(180),true);
					setElementData(ammo,weapons[itemname][5],math.random(12,48));
					setElementDimension(ammo,dimension)
				end
				if (string.find(itemname,"ammo_")) then
					setElementData(item,itemname,math.random(12,48));
				end
			end
		end
	end);
end

function createLOOT(dimension)
	Async:foreach(spawn_positions, function(position)
		local sx,sy,sz = unpack(position);
		if (sx) then
			createLoot(sx,sy,sz,dimension)
		end
	end);
end

--setTimer(function()
-
--	for i,pos in ipairs(spawn_positions) do
--		local sx,sy,sz = unpack(pos);
--		for i,player in ipairs(getElementsByType("player")) do
--			local dimension = getElementDimension(player);
--			if (type(activeloot[dimension]) == "table") then
--				local px,py,pz = getElementPosition(player);
--				if (dimension ~= 0 and not isPedDead(player)) then
--					if (not tableHasXYZ(activeloot[dimension],sx,sy,sz)) then
--						local dist = getDistanceBetweenPoints3D(sx,sy,sz,px,py,pz);
--						if (dist <= 150) then
--							table.insert(activeloot[dimension],{sx,sy,sz})
--							createLoot(sx,sy,sz,dimension)
--						end
--					end
--				end
--			end
--		end
--	end
--end,5*1000,0);