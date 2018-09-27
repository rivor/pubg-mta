if (localPlayer) then
	function drawBox(x,y,w,h,color1,color2,thickness,postgui)
		dxDrawRectangle(x,y,w,h,color1,postgui)
		dxDrawLine(x,y+thickness/2,x+w-thickness,y+thickness/2,color2,thickness,postgui) -- top
		dxDrawLine(x+thickness,y+h-thickness/2,x+w,y+h-thickness/2,color2,thickness,postgui) -- bottom
		dxDrawLine(x+thickness/2,y+thickness,x+thickness/2,y+h,color2,thickness,postgui) -- left
		dxDrawLine(x+w-thickness/2,y,x+w-thickness/2,y+h-thickness,color2,thickness,postgui) -- right
	end

	function drawActionWindow(text1,text2)
		local sW,sH = guiGetScreenSize();
		local x,y = sW*0.6,sH*0.6
		local font,fsize = "default-bold",1*sH*0.001;
		local key = "F";
		dxGetFontHeight(fsize,font)
		drawBox(x-sH*0.025/2,y-sH*0.025/2,sH*0.025,sH*0.025,tocolor(0,0,0,200),tocolor(255,255,255,100),1,true)
		dxDrawText(key,x-sH*0.025/2,y-sH*0.025/2,x-sH*0.025/2+sH*0.025,y-sH*0.025/2+sH*0.025,tocolor(255,255,255,230),1.4*sH*0.001,"default-bold","center","center",false,false,true)
		dxDrawRectangle(x+sH*0.025/1.5,y-sH*0.025/2,dxGetTextWidth(text1,fsize,font)*1.11,sH*0.025,tocolor(0,0,0,100),true)
		dxDrawText(text1,x+sH*0.025/1.5,y-sH*0.025/2,x+sH*0.025+dxGetTextWidth(text1,fsize,font),y+sH*0.025/2,tocolor(255,255,255,255),fsize,font,"center","center",false,false,true)
	end

	function dxDrawCircle(x,y,radius,color,width,postgui)
		local numPoints = math.floor( math.pow( radius, 0.4 ) * 5 )
		local step = math.pi * 2 / numPoints
		local sx,sy
		for p=0,numPoints do
			local ex = math.cos ( p * step ) * radius
			local ey = math.sin ( p * step ) * radius
			if sx then
				dxDrawLine( x+sx, y+sy, x+ex, y+ey, color, width, postgui)
			end
			sx,sy = ex,ey
		end
	end

	function dxDrawCircle2( posX, posY, radius, width, angleAmount, startAngle, stopAngle, color, postGUI )
		if ( type( posX ) ~= "number" ) or ( type( posY ) ~= "number" ) then
			return false
		end
		
		radius = type( radius ) == "number" and radius or 50
		width = type( width ) == "number" and width or 5
		startAngle =  type( startAngle ) == "number" and startAngle or 0, 0, 360 
		stopAngle =  type( stopAngle ) == "number" and stopAngle or 360, 0, 360 
		color = color or tocolor( 255, 255, 255, 100 )
		postGUI = type( postGUI ) == "boolean" and postGUI or false
		
		startAngle = startAngle-90;
		stopAngle = stopAngle-90;

		if ( stopAngle < startAngle ) then
			local tempAngle = stopAngle
			stopAngle = startAngle
			startAngle = tempAngle
		end
		
		local multiby = 50;

		if (radius >= 1000) then multiby = 3000; end

		for i = startAngle, stopAngle, multiby/radius do
			local startX = math.cos( math.rad( i ) ) * ( radius - width )
			local startY = math.sin( math.rad( i ) ) * ( radius - width )
			local endX = math.cos( math.rad( i ) ) * ( radius + width )
			local endY = math.sin( math.rad( i ) ) * ( radius + width )
		
			dxDrawLine( startX + posX, startY + posY, endX + posX, endY + posY, color, width, postGUI )
		end
		
		return true
	end

	local gastex = dxCreateTexture("images/wall.png");
	local mover = 0;
	function dxDrawGas(x,y,radius)
		local originx,originy = x,y;
		local numPoints = math.floor( math.pow( radius, 0.4 ) * 5 )
		local step = math.pi * 2 / numPoints
		local sx,sy
		for p=0,numPoints do
			local ex = math.cos ( p * step ) * radius
			local ey = math.sin ( p * step ) * radius
			if sx then
				mover = mover+0.002;
				local stretch = radius*0.5;
				if (stretch < 300) then stretch = radius*3; end
				dxDrawMaterialSectionLine3D(x+sx,y+sy,0,x+ex,y+ey,0,0,mover,150000,stretch,gastex,10000,tocolor(255,255,255,255),originx,originy,0)
			end
			sx,sy = ex,ey
		end
	end

	function isCursorOnArea(posX,posY,width,height)
		if isCursorShowing() then
			local mouseX, mouseY = getCursorPosition();
			local clientW, clientH = guiGetScreenSize();
			local mouseX, mouseY = mouseX * clientW, mouseY * clientH;
			if (mouseX > posX and mouseX < (posX+width) and mouseY > posY and mouseY < (posY+height)) then
				return true;
			end
		end
		return false
	end

	function getMousePosition()
		local x, y = getCursorPosition()
		if not x then
			return 0, 0
		end
		local width, height = guiGetScreenSize()
		return x * width, y * height
	end
end


function isPlayerInCircle(x, y, radius, player)
	local Player = localPlayer;
	if (player) then Player = player; end
	local px, py = getElementPosition(Player);
	if ((x-px)^2+(y-py)^2 <= radius^2) then return true; end
	return false;
end

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

function getRGColorFromPercentage(percentage)
	if not percentage or
		percentage and type(percentage) ~= "number" or
		percentage > 100 or percentage < 0 then
		return false
	end

	if percentage > 50 then
		local temp = 100 - percentage
		return temp*5.1, 255
	elseif percentage == 50 then
		return 255, 255
	end
	
	return 255, percentage*5.1
end

function getElementsInDimension(theType,dimension)
	local elementsInDimension = { }
	for key, value in ipairs(getElementsByType(theType)) do
		if getElementDimension(value)==dimension then
			table.insert(elementsInDimension,value)
		end
	end
	return elementsInDimension
end

function getAlivePlayersInDimension(dimension)
	local players = {};
	for i,player in ipairs(getElementsInDimension("player",dimension)) do
		if (dimension ~= 0) then
			if (not isPedDead(player)) then
				table.insert(players,player);
			end
		else
			if (getElementData(player,"room") == "lobby") then
				table.insert(players,player);
			end
		end
	end
	return players;
end

function secondsToMinutes(seconds)
	local seconds = tonumber(seconds)
	if seconds <= 0 then
		return "00:00";
	else
		local mins = string.format("%02.f", math.floor(seconds/60));
		local secs = string.format("%02.f", math.floor(seconds-mins*60));
		if (tonumber(mins) >= 1) then
			return mins..":"..secs;
		else
			return secs;
		end
	end
end

function findRotation(x1,y1,x2,y2) 
	local t = -math.deg(math.atan2(x2-x1,y2-y1));
	return t<0 and t+360 or t;
end

function tableHasXYZ(table,x,y,z)
	for i,v in ipairs(table) do
		if (type(v) == "table") then
			local tx,ty,tz = unpack(v);
			if (tx == x and ty == y and tz == z) then
				return true;
			end
		end
	end
	return false;
end

function getWeaponFromID(id,weptable)
	for i,v in pairs(weptable) do
		if (id == v[2]) then return tostring(i); end
	end
	return false;
end

function isLeapYear(year)
    if year then year = math.floor(year)
    else year = getRealTime().year + 1900 end
    return ((year % 4 == 0 and year % 100 ~= 0) or year % 400 == 0)
end

function getTimestamp(year, month, day, hour, minute, second)
    -- initiate variables
    local monthseconds = { 2678400, 2419200, 2678400, 2592000, 2678400, 2592000, 2678400, 2678400, 2592000, 2678400, 2592000, 2678400 }
    local timestamp = 0
    local datetime = getRealTime()
    year, month, day = year or datetime.year + 1900, month or datetime.month + 1, day or datetime.monthday
    hour, minute, second = hour or datetime.hour, minute or datetime.minute, second or datetime.second
    
    -- calculate timestamp
    for i=1970, year-1 do timestamp = timestamp + (isLeapYear(i) and 31622400 or 31536000) end
    for i=1, month-1 do timestamp = timestamp + ((isLeapYear(year) and i == 2) and 2505600 or monthseconds[i]) end
    timestamp = timestamp + 86400 * (day - 1) + 3600 * hour + 60 * minute + second
    
    timestamp = timestamp - 3600 --GMT+1 compensation
    if datetime.isdst then timestamp = timestamp - 3600 end
    
    return timestamp
end