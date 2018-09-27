-- 
-- c_helper_functions.lua
--

function isMTAUpToDate(vBuild)
	local mtaVer = getVersion().sortable
	local mtaBuild = mtaVer:sub(9)
	outputDebugString("MTA Build: "..tostring(mtaBuild))
	if mtaBuild < vBuild then
		return false
	else
		return true
	end
end

function vCardNumRenderTargets()
	local numRTar = tostring(dxGetStatus().VideoCardNumRenderTargets)
	outputDebugString("VideoCardNumRenderTargets: "..numRTar)
	return tonumber(numRTar)
end

function toint(n)
    local s = tostring(n)
    local i = s:find('%.')
    if i then
        return tonumber(s:sub(1, i-1))
    else
        return n
    end
end

function returnMaxValue(inTable)
	local itemCount=#inTable
	local outTable = {}	
	for i,v in pairs(inTable) do
		outTable[i] = math.abs(v)
	end
	local hasChanged
	repeat
		hasChanged = false
		itemCount = itemCount - 1
		for i = 1, itemCount do
			if outTable[i] > outTable[i + 1] then
				outTable[i], outTable[i + 1] = outTable[i + 1], outTable[i]
				hasChanged = true
			end
		end
	until hasChanged == false
	return outTable[#outTable]
end

function createElementMatrix(pos, rot)
	local rx, ry, rz = math.rad(rot[1]), math.rad(rot[2]), math.rad(rot[3])
	return {{ math.cos(rz) * math.cos(ry) - math.sin(rz) * math.sin(rx) * math.sin(ry), 
			math.cos(ry) * math.sin(rz) + math.cos(rz) * math.sin(rx) * math.sin(ry), -math.cos(rx) * math.sin(ry), 0},
			{ -math.cos(rx) * math.sin(rz), math.cos(rz) * math.cos(rx), math.sin(rx), 0},
			{math.cos(rz) * math.sin(ry) + math.cos(ry) * math.sin(rz) * math.sin(rx), math.sin(rz) * math.sin(ry) - 
				math.cos(rz) * math.cos(ry) * math.sin(rx), math.cos(rx) * math.cos(ry), 0},
			{pos[1], pos[2], pos[3], 1 }}
end

function getEulerAnglesFromMatrix(mat)
	local nz1, nz2, nz3
	nz3 = math.sqrt(mat[2][1] * mat[2][1] + mat[2][2] * mat[2][2])
	nz1 = -mat[2][1] * mat[2][3] / nz3
	nz2 = -mat[2][2] * mat[2][3] / nz3
	local vx = nz1 * mat[1][1] + nz2 * mat[1][2] + nz3 * mat[1][3]
	local vz = nz1 * mat[3][1] + nz2 * mat[3][2] + nz3 * mat[3][3]
	return math.deg(math.asin(mat[2][3]) ), -math.deg(math.atan2(vx, vz) ), -math.deg(math.atan2(mat[2][1], mat[2][2]))
end

function getPositionFromMatrixOffset(mat, pos)
	return (pos[1] * mat[1][1] + pos[2] * mat[2][1] + pos[3] * mat[3][1] + mat[4][1]), 
		(pos[1] * mat[1][2] + pos[2] * mat[2][2] + pos[3] * mat[3][2] + mat[4][2]),
		(pos[1] * mat[1][3] + pos[2] * mat[2][3] + pos[3] * mat[3][3] + mat[4][3])
end

function matrixMultiply(mat1, mat2)
	local matOut = {}
	for i = 1,#mat1 do
		matOut[i] = {}
		for j = 1,#mat2[1] do
			local num = mat1[i][1] * mat2[1][j]
			for n = 2,#mat1[1] do
				num = num + mat1[i][n] * mat2[n][j]
			end
			matOut[i][j] = num
		end
	end
	return matOut
end

function findEmptyEntry(inTable)
	for index,value in ipairs(inTable) do
		if not value.enabled then
			return index
		end
	end
	return #inTable + 1
end
