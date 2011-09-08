-- 
-- Abstract: Digital Catalog App
--  
-- Version: 1.0
-- 
display.setStatusBar( display.HiddenStatusBar ) 

local screenW, screenH = display.contentWidth, display.contentHeight
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

local MARGIN_BOTTOM = 10
local MARGIN_SIDE = 10

function showDebug()
	print("============================================")
	print("DEBUG INFO")
	print("Orientation: ", orientation)
	print("Screen: ", screenW, screenH)
	print("Viewable Screen: ", viewableScreenW, viewableScreenH)
	print("Screen Offset: ", screenOffsetW, screenOffsetH)
	print("Content Width/Height: ", display.contentWidth, display.contentHeight)
	print("Screen Origin: ", display.screenOriginX, display.screenOriginY)
	print("============================================")
end
showDebug()

local slideView = require("slideView")
local slideNav = require("slideNav")
-- local gMain = display.newGroup()

local catalog

function loadCatalog()
	local path = system.pathForFile( "catalog.txt", system.ResourceDirectory )
	local file = io.open( path, "r" )
	local line
	local t = { }
	if file then
		for line in file:lines() do
			table.insert(t, line)
		end
	end
	return t
end

catalog = loadCatalog()

function loadThumbnails(catalog)
	local g = display.newGroup()
	local thumbDir = "thumbs/"
	local spacingX = 20
	local posX = 0
	for i=1,#catalog do
		local thumbImagePath = thumbDir .. catalog[i] .. "_lg.jpg"
		local aThumbImg = display.newImage( thumbImagePath )
		posX = posX + aThumbImg.width + spacingX
		aThumbImg.x = posX
		aThumbImg.strokeWidth=4
		aThumbImg:setStrokeColor(128,128,128)
		--print(thumbImagePath, aThumbImg.width, aThumbImg.height, aThumbImg.x, aThumbImg.y)
		g:insert(aThumbImg)
	end
	return g
end

slideNav.new(thumbImages, 0, 0, 0, 0)
local thumbnails = loadThumbnails(loadCatalog())
thumbnails:setReferencePoint( display.TopLeftReferencePoint ) 
thumbnails.x = MARGIN_SIDE
thumbnails.y = screenH - thumbnails.height - MARGIN_BOTTOM

print(thumbnails.xOrigin, thumbnails.xScale, thumbnails.xReference)
--print(thumbnails.parent.xOrigin, thumbnails.parent.xScale, thumbnails.parent.xReference)