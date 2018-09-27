-- 
-- c_main.lua
--

objectPreview = {}
objectPreview_mt = { __index = objectPreview }

local isMRTShaderSupported = nil
local glRenderTarget = nil
refOPTable = {}

local scx, scy = guiGetScreenSize ()
local fov = ({getCameraMatrix()})[8]

function objectPreview:create(element,rotX,rotY,rotZ,projPosX,projPosY,projSizeX,projSizeY,isRelative,postGui,isSRT)
	local posX,posY,posZ = getCameraMatrix()
	if isRelative == false then
		projPosX, projPosY, projSizeX, projSizeY = projPosX / scx, projPosY / scy, projSizeX / scx, projSizeY / scy
	end
	local elementType = getElementType(element)
	--outputDebugString('objPrev: Identified element as: '..tostring(elementType))
	if elementType =="ped" or elementType =="player" then 
		elementType = "ped"
	end

    local new = {
		element = element,
		elementType = elementType,
		alpha = 255,
		elementRadius = 0,
		elementPosition = {posX, posY, posZ},
		elementRotation = {rotX, rotY, rotZ},
		elementRotationOffsets = {0, 0, 0},
		elementPositionOffsets = {0, 0, 0},
		zDistanceSpread = 0,
		projection = {projPosX, projPosY, projSizeX, projSizeY, postGui, isRelative},
		shader = nil,
		isSecondRT = isSRT,
		isUpdate = false,
		renID = findEmptyEntry(refOPTable) 
	}

	setElementAlpha(new.element, 254)
	setElementStreamable(new.element, false)
	setElementFrozen(new.element, true)
	setElementCollisionsEnabled (new.element, false)
	
	if elementType =="vehicle" then
		new.zDistanceSpread = -3.9
		for i=0,5 do
			setVehicleDoorState ( new.element, i, 0 )
		end
	elseif elementType =="ped" then
		new.zDistanceSpread = -1.0
	else
		new.zDistanceSpread = 3.0		
	end

	new.elementRadius = math.max(returnMaxValue({getElementBoundingBox(new.element)}), 1)	

	local tempRadius = getElementRadius(new.element)
	if tempRadius > new.elementRadius then new.elementRadius = tempRadius end

	if new.isSecondRT then
		if not isMRTShaderSupported then
			--outputDebugString('objPrev: Can not create a preview. MRT in shaders not supported')
			return false
		end
		--outputDebugString('objPrev: Creating fx_pre_'..elementType..'.fx')
		new.shader = dxCreateShader("fx/fx_pre_"..elementType..".fx", 0, 0, false, "all")
		if not glRenderTarget then
			glRenderTarget = dxCreateRenderTarget( scx, scy, true )
			--outputDebugString('objPrev : MRT objects visible - created RT')
		end
	else
		--outputDebugString('objPrev: Creating fx_pre_'..elementType..'_noMRT.fx')
		new.shader = dxCreateShader("fx/fx_pre_"..elementType.."_noMRT.fx", 0, 0, false, "all")	
	end
	if not new.shader then 
		return false 
	end

	if isMRTShaderSupported and glRenderTarget and new.isSecondRT then
		dxSetShaderValue (new.shader, "secondRT", glRenderTarget)
	end
	
	dxSetShaderValue(new.shader, "sFov", math.rad(fov))
	dxSetShaderValue(new.shader, "sAspect", (scy / scx))
	engineApplyShaderToWorldTexture (new.shader, "*", new.element)
	
	refOPTable[new.renID] = {}
	refOPTable[new.renID].enabled = true
	refOPTable[new.renID].isSecondRT = isSRT
	refOPTable[new.renID].instance = new

	new.onPreRender = function()
		new:update()
	end
	addEventHandler( "onClientPreRender", root, new.onPreRender, true, "low-5" )
    setmetatable(new, objectPreview_mt)
	--outputDebugString('objPrev: Created ID: '..new.renID..' for: '..tostring(elementType)) 
	return new
end

function objectPreview:getID()
	return self.renID
end

function objectPreview:setAlpha(alphaValue)
	self.alpha = alphaValue
	self.isUpdate = false
	return setElementAlpha(self.element, self.alpha) 
end

function objectPreview:destroy()
	if self.onPreRender then
		removeEventHandler( "onClientPreRender", root, self.onPreRender)
		self.onPreRender = nil
	end
	self.onPreRender = nil
	local renID = self.renID
	refOPTable[renID].enabled = false
	refOPTable[renID].isSecondRT = false
	refOPTable[renID].instance = nil
	if self.shader then
		engineRemoveShaderFromWorldTexture(self.shader, "*", self.element)
		destroyElement(self.shader)
		self.shader = nil
	end
	--outputDebugString('objPrev: Destroyed ID: '..renID) 
	self.element = nil
end

function objectPreview:update()
	-- Check if element exists
    if not isElement(self.element) then 
		return false
	end
	-- Calculate position and size of the projector	
	local projPosX, projPosY, projSizeX, projSizeY, postGui, isRelative = unpack(self.projection)
	projSizeX, projSizeY = projSizeX / 2, projSizeY / 2
	projPosX, projPosY = projPosX + projSizeX - 0.5, -(projPosY + projSizeY - 0.5)
	projPosX, projPosY = 2 * projPosX, 2 * projPosY
	
	-- Calculate position and rotation of the element		
	local cameraMatrix = getElementMatrix(getCamera())
	local rotationMatrix = createElementMatrix({0,0,0}, self.elementRotation)
	local positionMatrix = createElementMatrix(self.elementRotationOffsets, {0,0,0})
	local transformMatrix = matrixMultiply(positionMatrix, rotationMatrix)
		
	local multipliedMatrix = matrixMultiply(transformMatrix, cameraMatrix)
	local distTemp = self.zDistanceSpread

	local posTemp = self.elementPositionOffsets
	local posX, posY, posZ = getPositionFromMatrixOffset(cameraMatrix, {posTemp[1], 1.6 * self.elementRadius + distTemp + posTemp[2], posTemp[3]})
	local rotX, rotY, rotZ = getEulerAnglesFromMatrix(multipliedMatrix)

	local velX, velY, velZ = getCamVelocity()
	local vecLen = math.sqrt(math.pow(velX, 2) + math.pow(velY, 2) + math.pow(velZ, 2))
	local camCom = {cameraMatrix[2][1] * vecLen, cameraMatrix[2][2] * vecLen, cameraMatrix[2][3] * vecLen}
	velX, velY, velZ =	(velX + camCom[1]), (velY + camCom[2]), (velZ + camCom[3])
	setElementPosition(self.element, posX + velX, posY + velY, posZ + velZ)				
	setElementRotation(self.element, rotX, rotY, rotZ, "ZXY")
	
	-- Set shader values
	if self.shader then
		dxSetShaderValue(self.shader, "sCameraPosition", cameraMatrix[4])
		dxSetShaderValue(self.shader, "sCameraForward", cameraMatrix[2])
		dxSetShaderValue(self.shader, "sCameraUp", cameraMatrix[3])
		dxSetShaderValue(self.shader, "sElementOffset", 0, -distTemp, 0)
		dxSetShaderValue(self.shader, "sWorldOffset", -velX, -velY, -velZ)
		dxSetShaderValue(self.shader, "sMoveObject2D", projPosX, projPosY)
		dxSetShaderValue(self.shader, "sScaleObject2D", 2 * math.min(projSizeX, projSizeY), 2 * math.min(projSizeX, projSizeY))
		dxSetShaderValue(self.shader, "sProjZMult", 2)
		self.isUpdate = true
	end
end

local getLastTick = getTickCount() local lastCamVelocity  = {0, 0, 0}
local currentCamPos = {0, 0, 0} local lastCamPos = {0, 0, 0}

function getCamVelocity()
	if getTickCount() - getLastTick  < 100 then 
		return lastCamVelocity[1], lastCamVelocity[2], lastCamVelocity[3] 
	end
	local currentCamPos = {getElementPosition(getCamera())}
	lastCamVelocity = {currentCamPos[1] - lastCamPos[1], currentCamPos[2] - lastCamPos[2], currentCamPos[3] - lastCamPos[3]}
	lastCamPos = {currentCamPos[1], currentCamPos[2], currentCamPos[3]}
	return lastCamVelocity[1], lastCamVelocity[2], lastCamVelocity[3]
end


function objectPreview:saveToFile(filePath)
	if not isMRTShaderSupported or not self.isSecondRT or not isElement(self.element) then
			--outputDebugString('objPrev : saveRTToFile fail (non MRT object or MRT not supported) !')
		return false 
	end
	if glRenderTarget then
		local projPosX, projPosY, projSizeX, projSizeY, postGui, isRelaftive = unpack(self.projection)
		projPosX, projPosY, projSizeX, projSizeY = toint(projPosX * scx), toint(projPosY * scy), toint(projSizeX * scx), toint(projSizeY * scy)
		local rtPixels = dxGetTexturePixels ( glRenderTarget, projPosX, projPosY, projSizeX + projPosX, projSizeY + projPosY)
		if not rtPixels then
			--outputDebugString('objPrev : saveRTToFile fail (could not get texture pixels) !')
			return false 
		end
		rtPixels = dxConvertPixels(rtPixels, 'png')
		isValid = rtPixels and true
		local file = fileCreate(filePath)
		isValid = fileWrite(file, rtPixels) and isValid
		isValid = fileClose(file) and isValid
		if not isValid then
			--outputDebugString('objPrev : saveRTToFile fail (could not save pixels to file) !')
			return false
		end
		--outputDebugString('objPrev : saveRTToFile to: '..filePath)
		return isValid
	else
		--outputDebugString('objPrev : saveRTToFile fail (render target error) !')
		return false	
	end
	return false
end

function objectPreview:drawRenderTarget()
	if not isMRTShaderSupported or not self.isSecondRT then return false end
	if glRenderTarget then
		local projPosX, projPosY, projSizeX, projSizeY, postGui, isRelative = unpack(self.projection)
		projPosX, projPosY, projSizeX, projSizeY = projPosX * scx, projPosY * scy, projSizeX * scx, projSizeY * scy
		return dxDrawImageSection(projPosX, projPosY, projSizeX, projSizeY, projPosX, projPosY, projSizeX, projSizeY, glRenderTarget, 
			0, 0, 0, tocolor(255, 255, 255, 255), postGui )
	end
	return false
end

function objectPreview:setProjection(projPosX, projPosY, projSizeX, projSizeY, postGui, isRelative)
	if self.projection then
		if isRelative == false then
			projPosX, projPosY, projSizeX, projSizeY = projPosX / scx, projPosY / scy, projSizeX / scx, projSizeY / scy
		end
		self.isUpdate = false
		self.projection = {projPosX, projPosY, projSizeX, projSizeY, postGui, isRelative}
	end
end

function objectPreview:setPostGui(postGui)
	if not self.isSecondRT then return false end
	if self.projection then
		self.isUpdate = false
		self.projection[5] = postGui
	end
end

function objectPreview:setRotation(rotX, rotY, rotZ)
	if self.elementRotation then
		self.isUpdate = false
		self.elementRotation = {rotX, rotY, rotZ}
	end
end

function objectPreview:setRotationOffsets(offsX, offsY, offsZ)
	if self.elementRotationOffsets then
		self.isUpdate = false
		self.elementRotationOffsets = {offsX, offsY, offsZ}
	end
end

function objectPreview:setDistanceSpread(zSpread)
	if self.zDistanceSpread then
		self.isUpdate = false
		self.zDistanceSpread = zSpread
	end
end

function objectPreview:setPositionOffsets(offsX, offsY, offsZ)
	if self.elementPositionOffsets then
		self.isUpdate = false
		self.elementPositionOffsets = {offsX, offsY, offsZ}
	end
end

function getRTarget()
	if not isMRTShaderSupported then return false end
	if glRenderTarget then
		return glRenderTarget
	else
		--outputDebugString('objPrev : getRenderTarget fail (no render target) !')
		return false
	end
end	

-- onClientPreRender
addEventHandler( "onClientPreRender", root, function()
	if not isMRTShaderSupported or (#refOPTable == 0) then 
		return 
	end
	if glRenderTarget then
		dxSetRenderTarget( glRenderTarget, true )
		dxSetRenderTarget()
	end
end, true, "low-5" )

-- onClientHUDRender
addEventHandler( "onClientHUDRender", root, function()
	isMRTUsed = false
	if not isMRTShaderSupported or (#refOPTable == 0) then 
		return 
	end
	for index, this in ipairs( refOPTable ) do
		-- Draw secondary render target
		if refOPTable[index] then
			if refOPTable[index].isSecondRT then
					isMRTUsed = true
				end
			if refOPTable[index].enabled then
				local instance = this.instance
				if instance then
					instance:drawRenderTarget()
				end
			end
		end
    end
	if (isMRTUsed == false) and glRenderTarget then
		destroyElement( glRenderTarget )
		glRenderTarget = nil
		--outputDebugString('objPrev : no MRT objects visible - destroyed RT')
	end
end, true, "low-10" )

-- OnClientResourceStart
addEventHandler("onClientResourceStart", getResourceRootElement( getThisResource()), function()
	if not isMTAUpToDate("07331") then 
		outputChatBox('Object preview: Update your MTA 1.5 client. Download at nightly.mtasa.com',255,0,0) 
		return 
	end
	isMRTShaderSupported = vCardNumRenderTargets() > 1
	if not isMRTShaderSupported then 
		outputChatBox('Object preview: Multiple RT in shader not supported',255,0,0) 
		return 
	end
end)
