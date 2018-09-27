local playzone_dummy = createElement("Object","playzone");
local playzone_timers = {};
local playzone_timers2 = {};

local startingzones = {
	{568,2021},
	{1954,1768},
	{1264,-423},
	{1296,-1159},
	{2086,-1507},
	{-752,-1089},
	{-1170,-1685},
	{-1956,-371},
	{-2193,632},
};

local warmuptime = 60*1000;

local circles = {
	--[1] = {radius,traveltime/staytime,percentdamage(0-1)};
	[1] = {2135,180*1000,0.04};
	[2] = {1240,120*1000,0.06};
	[3] = {740,60*1000,0.08};
	[4] = {360,30*1000,0.10};
	[5] = {175,20*1000,0.30};
	[6] = {90,10*1000,0.50};
	[7] = {50,5*1000,0.70};
	[8] = {0,60*1000,0.90};
};

setTimer(function()
	for dimension,game in ipairs(activegames) do
		local playzone = game.playzone;
		if (playzone) then
			local gasLoc = playzone.gas_location;
			local safeLoc = playzone.safe_location;
			local travelTime = playzone.travel_time;
			local travelTimeStart = playzone.travel_time_start;
			local circle = playzone.circle;
			local gasRad = playzone.gas_radius;
			local safeRad = playzone.safe_radius;
			if (isTimer(playzone_timers[dimension])) then
				local timeleft = getTimerDetails(playzone_timers[dimension]);
				setElementData(playzone_dummy,dimension.."_countdown",timeleft);
			else
				setElementData(playzone_dummy,dimension.."_countdown",false);
			end
			if (circle) then
				setElementData(playzone_dummy,dimension.."_circle",circle);
				setElementData(playzone_dummy,dimension.."_playzone_location",safeLoc);
				setElementData(playzone_dummy,dimension.."_playzone_radius",safeRad);
				if (travelTimeStart) then
					local timeNow = getTickCount();
					local totalTimePassed = travelTimeStart-timeNow;
					if (totalTimePassed < 0) then totalTimePassed = totalTimePassed*-1; end
					if (totalTimePassed < travelTime) then
						local progress = totalTimePassed/travelTime;
						local x,y = interpolateBetween(gasLoc[1],gasLoc[2],0,safeLoc[1],safeLoc[2],0,progress,"Linear");
						local nwradius = interpolateBetween(gasRad,0,0,safeRad,0,0,progress,"Linear");
						setElementData(playzone_dummy,dimension.."_gas_location",{x,y});
						setElementData(playzone_dummy,dimension.."_gas_radius",nwradius);
					end
				end
			end
		end
	end
end,1*1000,0);

setTimer(function()
	for dimension,game in ipairs(activegames) do
		local circle = getElementData(playzone_dummy,dimension.."_circle");
		if (circle) then
			local gasLoc = getElementData(playzone_dummy,dimension.."_gas_location");
			if (gasLoc) then
				local gasx,gasy = unpack(getElementData(playzone_dummy,dimension.."_gas_location"));
				local gasrad = getElementData(playzone_dummy,dimension.."_gas_radius");
				for i,player in ipairs(getAlivePlayersInDimension(dimension)) do
					if (not isPlayerInCircle(gasx,gasy,gasrad,player)) then
						local damage = 100*circles[circle][3];
						setElementHealth(player,getElementHealth(player)-damage);
					end
				end
			end
		end
	end
end,2.5*1000,0);

function killPlayzoneTimer(dimension)
	if (dimension and isTimer(playzone_timers2[dimension])) then
		killTimer(playzone_timers2[dimension]);
		playzone_timers[dimension] = nil;
	elseif (dimension and isTimer(playzone_timers[dimension])) then
		killTimer(playzone_timers[dimension]);
		playzone_timers[dimension] = nil;
	end
end

function getPlayzoneInfo(dimension)
	if (type(dimension) == "number") then
		local playzone = activegames[dimension].playzone;
		if (playzone) then
			local circle = playzone.circle;
			local safeloc = playzone.safe_location;
			local saferad = playzone.safe_radius;
			local gasloc = playzone.gas_location;
			local gasrad = playzone.gas_radius;
			local traveltime = playzone.travel_time;
			local traveltimestart = playzone.travel_time_start;
			return circle,safeloc,saferad,gasloc,gasrad,traveltime,traveltimestart;
		end
	end
	return false;
end

function redirectGas(x,y,radius,traveltime,dimension)
	activegames[dimension].playzone.gas_location = {x,y};
	activegames[dimension].playzone.gas_radius = radius;
	activegames[dimension].playzone.travel_time = traveltime;
	activegames[dimension].playzone.travel_time_start = getTickCount();
end

function setPlayzone(circle,x,y,radius,dimension)
	activegames[dimension].playzone.circle = circle;
	activegames[dimension].playzone.safe_location = {x,y};
	activegames[dimension].playzone.safe_radius = radius;
end

function gascycler(dimension,x,y)
	if (type(dimension) == "number") then
		local playzone = activegames[dimension].playzone;
		if (playzone) then
			if (playzone.circle) then
				local circle = playzone.circle;
				local radius,traveltime = unpack(circles[circle]);
				if (circle == 1) then radius = 6000; else radius = circles[circle-1][1]; end
				redirectGas(x,y,radius,traveltime,dimension);
				playzone_timers2[dimension] = setTimer(function()
					local newcircle = circle+1;
					if (newcircle ~= #circles+1) then
						x,y = unpack(getElementData(playzone_dummy,dimension.."_gas_location"));
						radius = getElementData(playzone_dummy,dimension.."_gas_radius");
						local newx,newy = math.random(x-(playzone.gas_radius/7),x+(playzone.gas_radius/7)),math.random(y-(playzone.gas_radius/7),y+(playzone.gas_radius/7));
						setPlayzone(newcircle,newx,newy,circles[newcircle][1],dimension);
						setElementData(playzone_dummy,dimension.."_startgas_location",{x,y});
						setElementData(playzone_dummy,dimension.."_startgas_radius",radius);
						playzone_timers[dimension] = setTimer(function()
							gascycler(dimension,x,y);
						end,traveltime,1);
					end
				end,traveltime,1);
			else
				local radius,traveltime = unpack(circles[1]);
				setPlayzone(1,x,y,radius,dimension);
				setElementData(playzone_dummy,dimension.."_startgas_location",{0,0});
				setElementData(playzone_dummy,dimension.."_startgas_radius",6000);
				playzone_timers[dimension] = setTimer(function()
					gascycler(dimension,0,0);
				end,traveltime,1);
			end
		end
	end
end

function createPlayzone(dimension)
	activegames[dimension].playzone = {
		circle = false,
		safe_location = false,
		safe_radius = false,
		gas_location = {0,0},
		gas_radius = 6000,
		travel_time = false,
		travel_time_start = false,
	};
	playzone_timers2[dimension] = setTimer(function()
		local x,y = unpack(startingzones[math.random(#startingzones)]);
		gascycler(dimension,x,y);
	end,warmuptime,1);
end