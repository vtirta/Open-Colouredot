-- 
-- Abstract: Digital Catalog App
--  
-- Version: 1.0
-- 
local screenW, screenH = display.contentWidth, display.contentHeight
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

display.setStatusBar( display.HiddenStatusBar ) 


local slideView = require("slideView")
local slideNav = require("slideNav")

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
	local t = { }
	if file then
		for line in file:lines() do
		--print( line )
			table.insert(t, line)
		end
	end
	return t
end

function loadThumbnails()
	local catalog = loadCatalog()
	local thumbDir = "thumbs/"
	for i=1,#catalog do
		local thumbImagePath = thumbDir .. line .. "_lg.jpg"
		print( thumbImagePath )
		local aThumbImg = display.newImage( thumbImagePath )
		aThumbImg.x = 100
		aThumbImg.y = 300
	end
end

slideNav.new(thumbImages, 0, 0, 0, 0)

loadThumbnails()


--slideView.new( myImages, nil, 500, 60 )

--slideView.new( myImages )

--[[

-- Examples of other parameters:

-- Show a background image behind the slides
slideView.new( myImages, "bg.jpg"," )

-- Insert space at the top and bottom
slideView.new( myImages, nil, 40, 60 )

--]]

