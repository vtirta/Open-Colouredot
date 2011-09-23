module(..., package.seeall)

-- CONSTANTS
local MARGIN_BOTTOM = 25
local MARGIN_SIDE = 10
local DEFAULT_SPACING = 10
local DEFAULT_BORDER_WIDTH = 2
local BORDER_COLOR = { 128, 128, 128 }

--local background

function new(params)

	local itemSet = params.itemSet
	local imageSet = params.imageSet
	local xPos = params.xPos or 0
	local borderWidth = params.borderWidth or DEFAULT_BORDER_WIDTH
	local spacing = params.spacing or DEFAULT_SPACING
	local navBackground = params.navBackground
	local callback = params.callback
	local callbackParams = params.callbackParams

	local thumbNav = display.newGroup()

	function tapHandler(event)
		--print("Tapped", event.target.x, event.target.y)
		local g = event.target.parent
		-- reset all the border colors to default
		for i = 1, g.numChildren do
			local thumb = g[i]
			thumb:setStrokeColor(128, 128, 128)
		end
		event.target:setStrokeColor(255, 255, 255)

		-- execute callback function
		if (callback) then
			callback(event.target.itemId)
		else
			print("Callback function is not specified")
		end
	end

	--[[
	if navBackground then
		background = display.newImage(slideBackground, 0, 0, true)
	else
		background = display.newRect( 0, 0, screenW, screenH-(top+bottom) )
		background:setFillColor(0, 0, 0)
	end
	thumbNav:insert(background)
	]] --

	-- add thumbnail images to the thumbnail navigation group
	for i = 1, #imageSet do
		local aThumbImg = display.newImage(imageSet[i])
		xPos = xPos + aThumbImg.width + spacing
		aThumbImg.x = xPos
		aThumbImg.strokeWidth = borderWidth
		aThumbImg:setStrokeColor(BORDER_COLOR[1], BORDER_COLOR[2], BORDER_COLOR[3])
		aThumbImg:addEventListener("tap", tapHandler)
		aThumbImg.itemId=i
		aThumbImg.itemCode=itemSet[i]
		aThumbImg.imagePath=imageSet[i]
		--print(thumbImagePath, aThumbImg.width, aThumbImg.height, aThumbImg.x, aThumbImg.y)
		thumbNav:insert(aThumbImg)
	end

	-- Set position of the thumbnails
	thumbNav:setReferencePoint(display.TopLeftReferencePoint)
	thumbNav.x = MARGIN_SIDE
	thumbNav.y = display.contentHeight - thumbNav.height - MARGIN_BOTTOM

	function thumbNav:cleanUp()
		if thumbNav then
			for i = 1, thumbNav.numChildren do
				if thumbNav[i] then
					thumbNav[i]:removeSelf() 
					thumbNav[i] = nil
				end
			end
		end
	end
	
	return thumbNav
end