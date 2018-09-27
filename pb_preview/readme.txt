Resource: Object Preview v0.6.7 
contact: knoblauch700@o2.pl

This resource lets you create an object that will be drawn on the screen 
provided size and position - just like when drawing an image. This way it is easy to
create object preview on GUI (supports drawing in a separate render target).
Works with peds, world objects and vehicles.

Wiki: https://wiki.multitheftauto.com/wiki/Resource:Object_preview
Example resources: (for MRT and non MRT effect)
https://www.dropbox.com/s/p32z7mjr5o6wajj/object_preview_test.zip?dl=0
https://www.dropbox.com/s/t7d4bfjxrb8epdl/object_preview_test_nonMRT.zip?dl=0

Note:
Some older graphics cards do not support MRT in shaders. 
If You are planning on using this resource on a public server then 
consider creating a non MRT effect - then an object will be drawn in the same 
render target as the world is. Ofcourse no renderTarget related functions will be supported. 

The resource itself adds exported clientside functions:

createObjectPreview(element object, float rotX rotY, rotZ, projPosX, projPosY, projSizeX, projSizeY [, bool isRelative = false, postGUI = false, isSecRT = true])
	Creates the preview for provided world,ped or vehicle element.
destroyObjectPreview(element objectPreviewElement)
	Destroys previously created preview - without destroying the object it was applied to.
saveRTToFile(element objectPreviewElement, string path)
	Save render target to png file. (Only when drawing to second render target is enabled)
setRotation(element objectPreviewElement,float rotX, rotX, rotZ)
	This function sets object rotation in camera space.
setProjection(element objectPreviewElement, float projPosY, projSizeX, projSizeY [, bool isRelative = false])
	This function sets object on screen position and size.
setAlpha(element objectPreviewElement,int alpha)
	This function sets object alpha transparency.
getRenderTarget()
	This function returns a renderTarget (Only when drawing to second render target is enabled)
setDistanceSpread(element objectPreviewElement,float zSpread)
	This function sets the difference between object to camera distance set by MTA and that set by shader.
setPositionOffsets(element objectPreviewElement,float posX, posX, posX)
	This function sets object position to camera offsets (standard is 0,0,0)
setRotationOffsets(element objectPreviewElement,float posX, posX, posX)
	This function sets object rotation centre offsets (standard is 0,0,0)