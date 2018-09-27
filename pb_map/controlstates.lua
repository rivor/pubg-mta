local states={
	["radar_zoom_in"]=false,
	["radar_zoom_out"]=false,
	["radar_move_north"]=false,
	["radar_move_south"]=false,
	["radar_move_east"]=false,
	["radar_move_west"]=false,
}
local mta_getControlState=getPedControlState

function getPedControlState(control)
	local state=states[control]
	if state==nil then
		return mta_getControlState(control)
	else
		return state
	end
end

local function handleStateChange(key,state,control)
	states[control]=(state=="down")
end

for control,state in pairs(states) do
	for key,states in pairs(getBoundKeys(control)) do
		bindKey(key,"both",handleStateChange,control)
	end
end

function isPlayerInCircle(x, y, radius)
	local px, py = getElementPosition(localPlayer);
	if ((x-px)^2+(y-py)^2 <= radius^2) then return true; end
	return false;
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