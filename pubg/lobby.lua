addEvent("lobby",true);
addEvent("exitplane",true);
addEvent("returnToLobby",true);

activegames = {};

local min_players = 5;

local lobby_cars = {};
local lobby_car_locations = {
	{446,-116.90000152588,-4211.2998046875,-0,0,0,0},
	{478,-113.80000305176,-4336.1000976563,1.5,0,0,102},
	{422,-131.69999694824,-4352,1.5,0,0,0},
	{462,-157.89999389648,-4356.2998046875,1.1000000238419,0,0,0},
	{462,-156.80000305176,-4356.2998046875,1.1000000238419,0,0,0},
	{462,-159.60000610352,-4356.7001953125,1.1000000238419,0,0,0},
	{552,-160,-4247.2998046875,1.2000000476837,0,0,290},
	{552,-159.10000610352,-4243.2998046875,1.2000000476837,0,0,290},
	{552,-159,-4239.6000976563,1.2000000476837,0,0,290},
};

local lobby_dummy = createElement("Object","lobby");
setElementData(lobby_dummy,"players",0);
setElementData(lobby_dummy,"neededplayers",min_players);
setElementData(lobby_dummy,"startsin",false);

addEventHandler("lobby",root,function(skin)
	spawnPlayerTo(source,-135.5,-4302.1000976563,1.3999999761581,0,skin,0,false);
	setElementData(source,"room","lobby");
	-- col
	createPlayerColShape(source);
	-- lobby
	setElementData(lobby_dummy,"players",#getAlivePlayersInDimension(0));
	if (getElementData(lobby_dummy,"startsin")) then return; end
	--setElementData(lobby_dummy,"neededplayers",#getElementsInDimension("player",0));
end);

addEventHandler("onPlayerJoin",root,function()
	if (getElementDimension(source) == 0) then
		setElementData(lobby_dummy,"players",#getAlivePlayersInDimension(0));
		if (getElementData(lobby_dummy,"startsin")) then return; end
		--setElementData(lobby_dummy,"neededplayers",#getElementsInDimension("player",0));
	end
end);

addEventHandler("onPlayerQuit",root,function()
	local room = getElementData(source,"room");
	if (room == "lobby") then
		setElementData(lobby_dummy,"players",#getAlivePlayersInDimension(0)-1);
		if (getElementData(lobby_dummy,"startsin")) then return; end
		--setElementData(lobby_dummy,"neededplayers",#getElementsInDimension("player",0));
	end
end);

addEventHandler("exitplane",root,function()
	if (getElementData(source,"inplane") and getElementData(source,"canparachute")) then
		setElementData(source,"inplane",false);
		setElementData(source,"canparachute",false);
		giveWeapon(source,46,1,true);
		detachElements(source,getElementData(source,"plane"));
		fadeCamera(source,true);
		setCameraTarget(source,source);
	end
end);

addEventHandler("returnToLobby",root,function()
	if (getElementData(source,"room") == "dead") then
		removePlayerData(source)
		setPlayerToMenuScreen(source);
	end
end);

function spawnPlayerTo(player,x,y,z,rot,skin,dimension,frozen)
	spawnPlayer(player,x,y,z,rot,skin,0,dimension);
	setElementFrozen(player,frozen);
	fadeCamera(player,true);
	setCameraTarget(player,source);
end

function createLobbyCars()
	for i,v in ipairs(lobby_car_locations) do
		local model,x,y,z,rx,ry,rz = unpack(v);
		lobby_cars[i] = createVehicle(model,x,y,z,rx,ry,rz);
		setElementData(lobby_cars[i],"lobbycar",true);
	end
end

function destroyLobbyCars()
	for i,v in ipairs(lobby_cars) do
		if (isElement(v)) then
			destroyElement(v);
			lobby_cars[i] = nil;
		end
	end
end

function getAvailableDimension()
	local available = false;
	for i=1,100 do
		if (activegames[i] == nil) then
			available = i;
			break;
		end
	end
	return available;
end

function getRandomPlanePosition()
	local side = math.random(2);
	if (side == 1) then
		local x1,y1 = math.random(-3000,3000),-3500;
		local x2,y2 = math.random(-3000,3000),3500;
		local random = math.random(2);
		if (random == 1) then
			return x1,y1,x2,y2;
		else
			return x2,y2,x1,y1;
		end
	else
		local x1,y1 = -3500,math.random(-3000,3000);
		local x2,y2 = 3500,math.random(-3000,3000);
		local random = math.random(2);
		if (random == 1) then
			return x1,y1,x2,y2;
		else
			return x2,y2,x1,y1;
		end
	end
end

function createPlayerColShape(player)
	if (getElementData(player,"room") == "lobby" or getElementData(player,"room") == "playing") then
		local col = createColSphere(0,0,0,1);
		setElementDimension(col,getElementDimension(player));
		attachElements(col,player,0,0,-0.5,0,0,0);
		setElementData(player,"col",col);
		setElementData(col,"parent",player);
	end
end

function destroyPlayerColShape(player)
	if (getElementData(player,"room") == "lobby" or getElementData(player,"room") == "playing") then
		local col = getElementData(player,"col");
		if (isElement(col)) then
			destroyElement(col);
		end
	end
end

function setPlayerToMenuScreen(player)
	if (isPedDead(player)) then
		spawnPlayerTo(player,0,0,0,0,0,0,true);
	end
	showCursor(player,true)
	setElementDimension(player,0);
	setElementData(player,"room","menu");
	setCameraMatrix(player,5079.15625,-135.69271850586,373.3,5084.1000976563,-132.30000305176,373.29998779297,0,70)
	setElementData(lobby_dummy,"players",#getAlivePlayersInDimension(0));
	--setElementData(lobby_dummy,"neededplayers",#getElementsInDimension("player",0));
end

function giveVipItems(player)
	if (getElementData(player,"vip")) then
		for i,item in ipairs(vipitems) do
			setElementData(player,item[1],item[2]);
		end
	end
end

function startgame()
	if (isTimer(getElementData(lobby_dummy,"starttimer"))) then
		killTimer(getElementData(lobby_dummy,"starttimer"));
		setElementData(lobby_dummy,"starttimer",false);
	end
	setElementData(lobby_dummy,"startsin",false);
	destroyLobbyCars();
	local players = getElementsInDimension("player",0);
	local gamedimension = getAvailableDimension();
	local startx,starty,endx,endy = getRandomPlanePosition();
	local zrot = findRotation(startx,starty,endx,endy);
	local planeobject = createObject(1372,startx,starty,700,0,0,zrot,true);
	local plane = createVehicle(592,startx,starty,700,0,0,0);
	setElementDimension(planeobject,gamedimension);
	setElementDimension(plane,gamedimension);
	setElementCollisionsEnabled(planeobject,false);
	setElementCollisionsEnabled(plane,false);
	setObjectScale(planeobject,0);
	attachElements(plane,planeobject);
	Async:foreach(players, function(player)
		local room = getElementData(player,"room");
		if (room == "lobby") then
			removePedFromVehicle(player);
			setElementDimension(player,gamedimension);
			setElementDimension(getElementData(player,"col"),gamedimension);
			setElementPosition(player,startx,starty,700);
			attachElements(player,planeobject,0,0,0);
			setElementData(player,"inplane",true);
			setTimer(setElementData,10*1000,1,player,"canparachute",true);
			setElementData(player,"plane",planeobject);
			setElementData(player,"room","playing");
			-- info
			setElementData(player,"totalplayers",#players);
			giveVipItems(player);
		end
	end);
	moveObject(planeobject,60*1000,endx,endy,700);
	setTimer(destroyElement,60*1000,1,planeobject);
	setTimer(function(gamedimension)
		for i,player in ipairs(getElementsInDimension("player",gamedimension)) do
			if (getElementData(player,"inplane")) then
				triggerEvent("exitplane",player);
			end
		end
	end,110*1000,1,gamedimension);
	activegames[gamedimension] = {
		dimension = gamedimension,
		players = #players,
		winner = "",
		playzone = {},
	};
	outputServerLog("PUBG - Starting new game with "..#players.." players, in dimension "..gamedimension.."!")
	--setLootActive(gamedimension,true)
	createLOOT(gamedimension);
	createVehicles(gamedimension);
	createPlayzone(gamedimension);
	createLobbyCars()
	setElementData(lobby_dummy,"players",#getAlivePlayersInDimension(0));
	--setElementData(lobby_dummy,"neededplayers",#getElementsInDimension("player",0));
end

function endgame(dimension,winnerplayer)
	setLootActive(dimension,false);
	killPlayzoneTimer(dimension);
	local winner = "{no winner}";
	Async:foreach(getElementsByType("object"), function(object)
		if (getElementDimension(object) == dimension) then
			if (isElement(object)) then
				destroyElement(object);
			end
		end
	end);
	Async:foreach(getElementsByType("vehicle"), function(vehicle)
		if (getElementDimension(vehicle) == dimension) then
			if (isElement(vehicle)) then
				destroyElement(vehicle);
			end
		end
	end);
	Async:foreach(getElementsByType("player"), function(player)
		if (getElementDimension(player) == dimension) then
			removePedFromVehicle(player);
			removeAttachment(source,"helmet");
			removeAttachment(source,"backpack");
			removeAttachment(source,"armor");
			removeAttachment(source,"weapon1");
			removeAttachment(source,"weapon2");
			removeAttachment(source,"weapon3");
			removeAttachment(source,"weapon4");
			removeAttachment(source,"weapon5");
			takeAllWeapons(player);
			removePlayerData(player)
			destroyPlayerColShape(player);
			setPlayerToMenuScreen(player);
		end
	end);
	activegames[dimension] = nil;
	local playzone = getElementByID("playzone");
	if (playzone) then
		setElementData(playzone,dimension.."_countdown",nil);
		setElementData(playzone,dimension.."_circle",nil);
		setElementData(playzone,dimension.."_startgas_location",nil);
		setElementData(playzone,dimension.."_gas_location",nil);
		setElementData(playzone,dimension.."_gas_radius",nil);
		setElementData(playzone,dimension.."_playzone_location",nil);
		setElementData(playzone,dimension.."_playzone_radius",nil);
	end
	if (winnerplayer) then winner = winnerplayer; end
	outputServerLog("PUBG - Ending game in dimension "..dimension..", winner "..winner.."!")
end

addEventHandler("onElementDataChange",lobby_dummy,function(dataName,oldValue)
	if (dataName == "players") then
		local players = getElementData(source,"players");
		local neededplayers = getElementData(source,"neededplayers");
		if (players >= neededplayers) then
			if (getElementData(source,"startsin") == false) then
				setElementData(source,"startsin",60);
				local starttimer = setTimer(function(source)
					local timeleft = getElementData(source,"startsin");
					if (timeleft) then
						setElementData(source,"startsin",timeleft-1)
					end
				end,1*1000,60,source)
				setElementData(source,"starttimer",starttimer);
			end
		end
	elseif (dataName == "neededplayers") then
		local neededplayers = getElementData(source,dataName);
		if (neededplayers < min_players) then
			setElementData(source,dataName,min_players);
		end
	elseif (dataName == "startsin") then
		local timeleft = getElementData(source,"startsin");
		if (timeleft and timeleft <= 0) then
			startgame();
		end
	end
end);

addCommandHandler("pb-start",function(source)
	if (getElementType(source) == "player") then
		local serial = getPlayerSerial(source);
		if (serial == allowedserial) then
			startgame();
		end
	elseif (getElementType(source) == "console") then
		startgame();
	end
end);

addCommandHandler("pb-starttimer",function(source)
	if (getElementType(source) == "player") then
		local serial = getPlayerSerial(source);
		if (serial == allowedserial) then
			if (getElementData(lobby_dummy,"startsin") == false) then
				setElementData(lobby_dummy,"startsin",60);
				local starttimer = setTimer(function(lobby_dummy)
					local timeleft = getElementData(lobby_dummy,"startsin");
					if (timeleft) then
						setElementData(lobby_dummy,"startsin",timeleft-1)
					end
				end,1*1000,60,lobby_dummy)
				setElementData(lobby_dummy,"starttimer",starttimer);
			end
		end
	elseif (getElementType(source) == "console") then
		if (getElementData(lobby_dummy,"startsin") == false) then
			setElementData(lobby_dummy,"startsin",60);
			local starttimer = setTimer(function(lobby_dummy)
				local timeleft = getElementData(lobby_dummy,"startsin");
				if (timeleft) then
					setElementData(lobby_dummy,"startsin",timeleft-1)
				end
			end,1*1000,60,lobby_dummy)
			setElementData(lobby_dummy,"starttimer",starttimer);
		end
	end
end);

addCommandHandler("pb-end",function(source,cmd,dimension)
	if (dimension) then dimension = tonumber(dimension); end
	if (getElementType(source) == "player") then
		local serial = getPlayerSerial(source);
		if (serial == allowedserial) then
			endgame(dimension);
		end
	elseif (getElementType(source) == "console") then
		endgame(dimension);
	end
end);

addCommandHandler("pb-minplayers",function(source,cmd,minplayers)
	if (dimension) then dimension = tonumber(dimension); end
	if (getElementType(source) == "player") then
		local serial = getPlayerSerial(source);
		if (serial == allowedserial) then
			setElementData(lobby_dummy,"neededplayers",tonumber(minplayers));
			min_players = tonumber(minplayers);
		end
	elseif (getElementType(source) == "console") then
		setElementData(lobby_dummy,"neededplayers",tonumber(minplayers));
		min_players = tonumber(minplayers);
	end
end);