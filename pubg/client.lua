addEvent("pb.authcallback",true);

local authorized = false;

local blockedTasks =  {
	"TASK_SIMPLE_IN_AIR",
	"TASK_SIMPLE_JUMP",
	"TASK_SIMPLE_LAND",
	"TASK_SIMPLE_GO_TO_POINT",
	"TASK_SIMPLE_NAMED_ANIM",
	"TASK_SIMPLE_CAR_OPEN_DOOR_FROM_OUTSIDE",
	"TASK_SIMPLE_CAR_GET_IN",
	"TASK_SIMPLE_CLIMB",
	"TASK_SIMPLE_SWIM",
	"TASK_SIMPLE_HIT_HEAD",
	"TASK_SIMPLE_FALL",
	"TASK_SIMPLE_GET_UP"
};

addEventHandler("pb.authcallback",localPlayer,function(authkey)
	authorized = authkey;
end);

function checkAuthorized()
	if (authorized == activation_code) then
		return true;
	end
	return false;
end

addCommandHandler("pb-debug",function(cmd,dimension)
	if (not checkAuthorized()) then return; end
	if (getElementType(localPlayer) == "player") then
		local serial = getPlayerSerial(localPlayer);
		local allowedserial = allowed_serial;
		if (serial == allowedserial) then
			setDebugViewActive(not isDebugViewActive());
		end
	end
end);

addCommandHandler("pb-crun",function(cmd,...)
	if (not checkAuthorized()) then return; end
	if (getElementType(localPlayer) == "player") then
		local serial = getPlayerSerial(localPlayer);
		local allowedserial = allowed_serial;
		if (serial == allowedserial) then
			local script = table.concat({...}," ");
			local func = loadstring(script);
			func();
		end
	end
end);

addEventHandler("onClientResourceStart",resourceRoot,function()
	setAmbientSoundEnabled("gunfire",false)
	setPedTargetingMarkerEnabled(false)
	triggerServerEvent("pb.requestauth",localPlayer);
end);

addEventHandler("onClientPlayerDamage",localPlayer,function(attacker,weapon,bodypart,loss)
	cancelEvent();
	if (not checkAuthorized()) then return; end
	local room = getElementData(localPlayer,"room");
	if (room == "playing") then
		local damage = 0;
		if (weapon == 0) then
			damage = 5;
		elseif (weapon == 50) then
			damage = 30;
		elseif (weapon == 51 or weapon == 63) then
			damage = 100;
		elseif (weapon == 54) then
			damage = 10;
		elseif (weapon >= 1 and weapon <= 40) then
			local wep = getWeaponFromID(weapon,weapons);
			local wepdamage = weapons_damage[wep];
			loss = wepdamage;
			damage = loss;
			--
			local helmet = getElementData(localPlayer,"helmet") or "";
			local armor = getElementData(localPlayer,"armor") or "";
			local weapon3 = getElementData(localPlayer,"weapon3") or "";
			if (bodypart == 9 and helmet ~= "") then
				local newloss = loss*equipment_damage_reduction[helmet];
				damage = newloss;
			elseif (bodypart == 3 and armor ~= "") then
				local newloss = loss*equipment_damage_reduction[armor];
				damage = newloss;
			elseif (bodypart == 4 and weapon3 == "pan") then
				if (getPedWeaponSlot(localPlayer) ~= 1) then
					local newloss = loss*equipment_damage_reduction[weapon3];
					damage = newloss;
				end
			end
		end
		triggerServerEvent("damagePlayer",localPlayer,damage,attacker,weapon,bodypart,false)
	end
end);

addEventHandler("onClientRender",root,function()
	if (not checkAuthorized()) then return; end
	setTime(12,0)
	showChat(false);
	setWeather(1337);
	toggleControl("next_weapon",false);
	toggleControl("previous_weapon",false);
	if (getElementDimension(localPlayer) == 0) then
		for i,veh in ipairs(getElementsInDimension("vehicle",0)) do
			if (getElementData(veh,"lobbycar")) then
				local health = getElementHealth(veh);
				if (health < 1000) then
					fixVehicle(veh);
				end
			end
		end
	end
end);

addEventHandler("onClientPlayerWeaponFire",localPlayer,function(hitElement,x,y,z)
	if (not checkAuthorized()) then return; end
	local weapon1 = getElementData(localPlayer,"weapon1") or "";
	local weapon2 = getElementData(localPlayer,"weapon2") or "";
	local weapon3 = getElementData(localPlayer,"weapon3") or "";
	local weapon4 = getElementData(localPlayer,"weapon4") or "";
	local weapon5 = getElementData(localPlayer,"weapon5") or "";
	local slot = getPedWeaponSlot(localPlayer);
	local weapon = getPedWeapon(localPlayer);
	if (slot == 3 or slot == 5 or slot == 6) then
		if (weapon1 ~= "" and weapons[weapon1][2] == weapon) then
			local wepammo = weapons[weapon1][5];
			local ammo = getElementData(localPlayer,wepammo);
			setElementData(localPlayer,wepammo,ammo-1);
		elseif (weapon2 ~= "" and weapons[weapon2][2] == weapon) then
			local wepammo = weapons[weapon2][5];
			local ammo = getElementData(localPlayer,wepammo);
			setElementData(localPlayer,wepammo,ammo-1);
		end
	elseif (slot == 2 or slot == 4) then
		local wepammo = weapons[weapon3][5];
		if (wepammo ~= "") then
			local ammo = getElementData(localPlayer,wepammo);
			setElementData(localPlayer,wepammo,ammo-1);
		end
	elseif (slot == 8) then
		if (weapon5 ~= "" and weapons[weapon5][2] == weapon) then
			local wepammo = weapons[weapon5][5];
			local ammo = getElementData(localPlayer,wepammo);
			setElementData(localPlayer,wepammo,ammo-1);
		end
	end
end);

bindKey("r", "down", function()
	setTimer(function()
		local ammo = getPedAmmoInClip(localPlayer);
		--local totalAmmo = getPedTotalAmmo(localPlayer);
		local clip = getWeaponProperty(getPedWeapon(localPlayer), "std", "maximum_clip_ammo");
		if (ammo ~= clip) then
			local task = getPedSimplestTask(localPlayer);
			for _,v in pairs(blockedTasks) do
				if (task == v) then
					return;
				end
			end
			triggerServerEvent("relWep", resourceRoot);
		end
	end, 50, 1);
end);

local warn = 0;
local warntimer;
setTimer(function()
	local ping = getPlayerPing(localPlayer);
	if (ping > 500) then
		if (warn > 3) then triggerServerEvent("kickForPing",localPlayer); end
		warn = warn+1;
		if (isTimer(warntimer)) then killTimer(warntimer); end
		warntimer = setTimer(function()
			warn = 0;
		end,5*1000,1);
	end
end,2*1000,0);