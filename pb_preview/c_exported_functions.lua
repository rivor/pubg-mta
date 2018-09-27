-- 
-- c_exports.lua
--

function createObjectPreview(objElement,rotX,rotY,rotZ,projPosX,projPosY,projSizeX,projSizeY,...)
	if not isElement(objElement) then
		outputDebugString('objPrev : createObjectPreview fail (not an element) !')	
		return false
	end	
	local elementType = getElementType(objElement)
	if (not elementType =="vehicle" and not elementType =="object"  and not elementType =="ped") then 
		outputDebugString('objPrev : createObjectPreview fail (not proper element) !')
		return false 
	end
	local reqParam = {rotX,rotY,rotZ,projPosX,projPosY,projSizeX,projSizeY}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param ~= nil and (type(param) == "number")
	end
	local optParam = {...}
	if not isThisValid or (#optParam > 3 or #reqParam ~= 7 ) or (countParam ~= 7) then
		outputDebugString('objPrev : createObjectPreview fail (not enough parameters) !')
		return false 
	end
	local isRelative, postGui, isSecRT = false, false, true
	if #optParam > 0 then 
		if (type(optParam[1]) == "boolean") then
			isRelative = optParam[1]
		end
	end
	if #optParam > 1 then 
		if (type(optParam[2]) == "boolean") then
			postGui = optParam[2]
		end
	end
	if #optParam > 2 then 
		if (type(optParam[3]) == "boolean") then
			isSecRT = optParam[3]
		end
	end
	local thisObj = objectPreview:create(objElement,rotX,rotY,rotZ,projPosX,projPosY,projSizeX,projSizeY,isRelative,postGui,isSecRT)
	if thisObj and true then 
		return createElement("SOVelement", tostring(thisObj:getID()))
	else
		outputDebugString('objPrev : createObjectPreview fail (internal error) !')
		return false
	end
end

function destroyObjectPreview(w)
	if not isElement(w) then 
		outputDebugString('objPrev: No element ID')
		return false
	end
	local SOVelementID = tonumber(getElementID(w))
	local isThisValid = (type(SOVelementID) == "number") and true
	if isThisValid then
		isThisValid = false
		if refOPTable[SOVelementID] then
			if refOPTable[SOVelementID].enabled then
				local instance = refOPTable[SOVelementID].instance
				if instance then
					return instance:destroy()
				end
			end
		end			
		outputDebugString('objPrev : createObjectPreview fail (internal error) !')
		return false
	else	
		outputDebugString('objPrev : destroyObjectPreview fail (improper element) !')
		return false
	end
end

function saveRTToFile(w,filePath)
	if not isElement(w) then
		outputDebugString('objPrev: No element ID')
		return false
	end
	if not (dxGetStatus().AllowScreenUpload) then
		outputDebugString('objPrev : saveRTToFile fail (AllowScreenUpload) !')
		return false 
	end
	if type(filePath)~="string" then
		outputDebugString('objPrev : saveRTToFile fail (no file path) !')
		return false
	end
	local SOVelementID = tonumber(getElementID(w))
	local lastBit = string.len(filePath)
	local texExt = string.sub(filePath, lastBit - 3, lastBit ) 
	if texExt ~= '.png' then
		outputDebugString('objPrev : saveRTToFile fail (file extention is not png) !')
		return false 
	end
	local texName = string.sub(filePath, string.len( 1, lastBit - 4 ))
	if string.len(texName) < 1 then
		outputDebugString('objPrev : saveRTToFile fail (wrong tex name length) !')
		return false 
	end
	local outPath = ':'..getResourceName(sourceResource)..'/'..filePath	
	if refOPTable[SOVelementID] then
		if refOPTable[SOVelementID].enabled then
			local instance = refOPTable[SOVelementID].instance
			if instance then
				return instance:saveToFile(outPath)
			end
		end
		outputDebugString('objPrev: saveToFile fail (internal error) !')		
		return false
	else
		outputDebugString('objPrev : saveRTToFile fail (improper element) !')
		return false
	end
end

function setRotation(w,rotX,rotY,rotZ)
	if not isElement(w) then
		outputDebugString('objPrev: No element ID')
		return false
	end
	local SOVelementID = tonumber(getElementID(w))
	local reqParam = {SOVelementID,rotX,rotY,rotZ}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param and (type(param) == "number")
	end
	if isThisValid  and (countParam == 4) then
		if refOPTable[SOVelementID] then
			if refOPTable[SOVelementID].enabled then
				local instance = refOPTable[SOVelementID].instance
				if instance then
					return instance:setRotation(rotX,rotY,rotZ)
				end
			end
			outputDebugString('objPrev: setRotation fail (internal error) !')		
			return false
		end
		outputDebugString('objPrev : setRotation fail (improper element) !')
		return false
	else
		outputDebugString('objPrev : setRotation fail (improper parameters) !')
		return false
	end	
end

function setProjection(w,projPosX,projPosY,projSizeX,projSizeY,...)
	if not isElement(w) then
		outputDebugString('objPrev: No element ID')
		return false
	end
	local SOVelementID = tonumber(getElementID(w))
	local reqParam = {SOVelementID,projPosX,projPosY,projSizeX,projSizeY}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param and (type(param) == "number")
	end
	local optParam = {...}
	if not isThisValid or (#optParam > 2 or #reqParam ~= 5 ) or (countParam ~= 5) then
		outputDebugString('objPrev : setProjection fail (improper parameters) !')
		return false 
	end
	local isRelative, postGui = false, false
	if #optParam > 0 then 
		if (type(optParam[1]) == "boolean") then
			isRelative = optParam[1]
		end
	end
	if #optParam > 1 then 	
		if (type(optParam[2]) == "boolean") then
			postGui = optParam[2]
		end	
	end	
	if refOPTable[SOVelementID] then
		if refOPTable[SOVelementID].enabled then
			local instance = refOPTable[SOVelementID].instance
			if instance then
				return instance:setProjection(projPosX,projPosY,projSizeX,projSizeY,postGui,isRelative)
			end
		end
		outputDebugString('objPrev : setProjection fail (internal error) !')
		return false
	else
		outputDebugString('objPrev : setProjection fail (improper element) !')
		return false
	end
end

function setDistanceSpread(w,zSpread)
	if not isElement(w) then
		outputDebugString('objPrev: No element ID')
		return false
	end
	local SOVelementID = tonumber(getElementID(w))
	local reqParam = {SOVelementID,zSpread}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param and (type(param) == "number")
	end
	if isThisValid  and (countParam == 2) then
		if refOPTable[SOVelementID] then
			if refOPTable[SOVelementID].enabled then
				local instance = refOPTable[SOVelementID].instance
				if instance then
					return instance:setDistanceSpread(zSpread)
				end
			end
			outputDebugString('objPrev : setDistanceSpread fail (internal error) !')
			return false
		else
			outputDebugString('objPrev : setDistanceSpread fail (improper element) !')		
			return false
		end
	else
		outputDebugString('objPrev : setDistanceSpread fail (improper parameters) !')
		return false
	end	
end

function setPositionOffsets(w,offsX,offsY,offsZ)
	if not isElement(w) then
		outputDebugString('objPrev: No element ID')
		return false
	end
	local SOVelementID = tonumber(getElementID(w))
	local reqParam = {SOVelementID,offsX,offsY,offsZ}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param and (type(param) == "number")
	end
	if isThisValid  and (countParam == 4) then
		if refOPTable[SOVelementID] then
			if refOPTable[SOVelementID].enabled then
				local instance = refOPTable[SOVelementID].instance
				if instance then
					return instance:setPositionOffsets(offsX,offsY,offsZ)
				end
			end
			outputDebugString('objPrev : setPositionOffsets fail (internal error) !')
			return false
		else
			outputDebugString('objPrev : setPositionOffsets fail (improper element) !')	
			return false
		end
	else
		outputDebugString('objPrev : setPositionOffsets fail (improper parameters) !')	
		return false
	end	
end

function setRotationOffsets(w,offsX,offsY,offsZ)
	if not isElement(w) then
		outputDebugString('objPrev: No element ID')
		return false
	end
	local SOVelementID = tonumber(getElementID(w))
	local reqParam = {SOVelementID,offsX,offsY,offsZ}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param and (type(param) == "number")
	end
	if isThisValid  and (countParam == 4) then
		if refOPTable[SOVelementID] then
			if refOPTable[SOVelementID].enabled then
				local instance = refOPTable[SOVelementID].instance
				if instance then
					return instance:setRotationOffsets(offsX,offsY,offsZ)
				end
			end
			outputDebugString('objPrev : setRotationOffsets fail (internal error) !')
			return false
		else
			outputDebugString('objPrev : setRotationOffsets fail (improper element) !')
			return false
		end
	else
		outputDebugString('objPrev : setRotationOffsets fail (improper parameters) !')	
		return false
	end	
end

function setAlpha(w,alphaValue)
	if not isElement(w) then
		outputDebugString('objPrev: No element ID')
		return false
	end
	local SOVelementID = tonumber(getElementID(w))
	local isThisValid = (type(SOVelementID)=="number") and (type(alphaValue)=="number") and true
	if isThisValid then
		if refOPTable[SOVelementID] then
			if refOPTable[SOVelementID].enabled then
				local instance = refOPTable[SOVelementID].instance
				if instance then
					return instance:setAlpha(alphaValue)
				end
			end
			outputDebugString('objPrev : setAlpha fail (internal error) !')
			return false
		else
			outputDebugString('objPrev : setAlpha fail (improper element) !')		
			return false
		end
	else
		outputDebugString('objPrev : setAlpha fail (improper parameters) !')	
		return false
	end	
end

function getRenderTarget()
	local outputRT = getRTarget()
	if outputRT then
		return outputRT
	else
		outputDebugString('objPrev : getRenderTarget fail (No active render target) !')
		return false
	end
end
