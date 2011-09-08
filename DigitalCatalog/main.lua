-- 
-- Abstract: Digital Catalog App
--  
-- Version: 1.0
-- 
local screenW, screenH = display.contentWidth, display.contentHeight
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

function showDebug()
	print("============================================")
	print("DEBUG INFO")
	print("Screen: ", screenW, screenH)
	print("Viewable Screen: ", viewableScreenW, viewableScreenH)
	print("Screen Offset: ", screenOffsetW, screenOffsetH)
	print("Content Width/Height: ", display.contentWidth, display.contentHeight)
	print("Screen Origin: ", display.screenOriginX, display.screenOriginY)
	print("============================================")
end



showDebug()

display.setStatusBar( display.HiddenStatusBar ) 

local slideView = require("slideView")
local slideNav = require("slideNav")
local gMain = display.newGroup()
gMain.x = 0
gMain.y = 0

local thumbImages = {
	"thumbs/mfgear-902_amcapa_lg.jpg",
	"mfgear-910_fia_lg.jpg",
	"mfgear-931_wbfa_lg.jpg",
	"mfgear-903_amfa_lg.jpg",
	"mfgear-911_ambala_lg.jpg",
	"mfgear-933_wgia_lg.jpg",
	"mfgear-905_gfaa_lg.jpg",
	"mfgear-912_ciba_lg.jpg",
	"mfgear-939_stexa_lg.jpg",
	"mfgear-906_ifaa_lg.jpg",
	"mfgear-916_eupaca_lg.jpg",
	"mfgear-940_ahima_lg.jpg",
	"mfgear-908_bfaa_lg.jpg",
	"mfgear-921_ahita_lg.jpg",
	"mfgear-959_mmfa_lg.jpg"
}

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

function loadThumbnails(catalog)
	local g = display.newGroup()
	local thumbDir = "thumbs/"
	local spacingX = 20
	local posX = spacingX/2
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
thumbnails.x = 0
thumbnails.y = screenH - thumbnails.height

gMain:insert(thumbnails)

local label = display.newText( "portrait", 0, 0, nil, 30 )
label:setTextColor( 255,255,255 )
label.x = display.contentWidth/2; label.y = display.contentHeight/2
 
local function onOrientationChange( event )
        label.text = event.type   -- change text to reflect current orientation
        -- rotate text so it remains upright
        local newAngle = label.rotation - event.delta
        print("Angle: ", newAngle)
        transition.to( label, { time=150, rotation=newAngle } )
        --thumbnails.x = 0
        --thumbnails.y = screenW - thumbnails.height
        transition.to( gMain, { time=0, rotation=newAngle } )
        thumbnails.x=0
        thumbnails.y=-158
        --thumbnails.x = 0
        --thumbnails.y = display.contentHeight - thumbnails.height
        --print(gMain.x, gMain.y, gMain.rotation)
        print(thumbnails.x, thumbnails.y, thumbnails.rotation)
        showDebug()
end
 
Runtime:addEventListener( "orientation", onOrientationChange )

