-- 
-- Abstract: Digital Catalog App
--  
-- Version: 1.0
--

-- Load required libraries / components
local thumbNav = require("thumbNav")
local sideScrollView = require("sideScrollView")
local pageHelper = require("pageHelper")

-- Hide status bar
display.setStatusBar( display.HiddenStatusBar ) 

local screenW, screenH = display.contentWidth, display.contentHeight
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

local MARGIN_TOP = 10
local MARGIN_BOTTOM = 10
local MARGIN_SIDE = 10
local CONTENT_DIR = "_content/"

local fullPageHeight = display.contentHeight - MARGIN_TOP - MARGIN_BOTTOM
local fullPageWidth = pageHelper.toPageWidth(fullPageHeight)

local initialPageScale = 0.75

local catalogHeight = fullPageHeight
local catalogWidth = fullPageWidth

local function loadCatalogList()
	local path = system.pathForFile( CONTENT_DIR .. "catalog.txt", system.ResourceDirectory )
	local file = io.open( path, "r" )
	local line
	local t = { }
	local catArr = {}
	local thumbArr = {}
	local thumbDir = CONTENT_DIR .. "thumbs/"
	if file then
		for line in file:lines() do
			table.insert(catArr, line)
			table.insert(thumbArr, thumbDir .. line .. "_lg.jpg")
		end
		t = { catalog = catArr, thumbnails = thumbArr }
	end
	return t
end

local navItems
local catalogNav
local currentCatalogId
local currentPage = 1
local catalogList = loadCatalogList()
local catalogCache = {}

--local catalog = display.newGroup()
--catalog:setReferencePoint(display.TopCenterReferencePoint)
--catalog.x = display.contentWidth/2
--catalog.y = 0

function pageTapHandler(event)
	local t = event.target
	local taps = event.numTaps
	if ( taps == 2 ) then
		local largeScale = 1
		local scale = initialPageScale
		print("Event:", event.x, event.y)
		print("Target:", t.x, t.y, t.width, t.height)
		
		local moveByX = display.contentWidth/2 - event.x
		print(moveByX)
		local moveTo = t.x + moveByX
		print(moveTo)
		
		if t.xScale == scale then
			scale = largeScale
			transition.to(catalogNav, {time=500, alpha=0})
		else
			transition.to(catalogNav, {time=500, alpha=1})
		end
		
		--transition.to(t, {time=0, x=moveTo})
		transition.to(t, {time=1000, xScale=scale, yScale=scale, transition=easing.outExpo})
	end
end

local startPos
local endPos

function pageSwipeHandler(event)
	local t = event.target
	local phase = event.phase

	if ( phase == "began") then
		--print("begin")
		startPos = event.x
	elseif ( phase == "moved" ) then
		--print("moved", startPos, event.x)
		if (event.x > startPos) then
			local nextPages = loadNextPages(currentCatalogId)
			local xTransFrom = display.contentWidth/4*3
			transition.from(nextPages, { time=400, alpha=0, x=xTransFrom })
		else
			print("swiped LEFT")
		end
	elseif ( phase == "ended" ) then
		--print("end", startPos, event.x)
	end
	--[[

	]]--
end

local function loadCatalogImage(itemId, pageNum)
	local itemCode = catalogList.catalog[itemId]
	local filePath = CONTENT_DIR .. itemCode .. "/" .. itemCode .. "_Page_" .. pageNum .. ".png"
	local img = display.newImageRect(filePath, catalogWidth, catalogHeight)
	--img.xScale = initialPageScale
	--img.yScale = initialPageScale
	--img:addEventListener("tap", pageTapHandler)
	--img:addEventListener("touch", pageSwipeHandler)
	return img
end

local function loadCoverPage(itemId)
	local page = loadCatalogPage(itemId, 1)
	page:setReferencePoint(display.TopCenterReferencePoint)
	page.x=display.contentWidth/2
	page.y=MARGIN_TOP
	currentPage = 1
	return page
end

local function loadPages(itemId, pageNum)
	local g = display.newGroup()
	local x = display.contentWidth/2
	local pageSetNum = pageNum * 2

	local page = loadCatalogPage(itemId, pageSetNum)
	page:setReferencePoint(display.TopRightReferencePoint)
	page.x = x
	page.y = MARGIN_TOP

	g:insert(page)

	page = loadCatalogPage(itemId, pageSetNum+1)
	page:setReferencePoint(display.TopLeftReferencePoint)
	page.x = x
	page.y = MARGIN_TOP

	g:insert(page)

	return g
end

local function loadCatalog(itemId, numPages)
	local g = display.newGroup()
	local xPos = 10
	for i=1,numPages do
		local page = loadCatalogImage(itemId, i)
		xPos = xPos + page.width
		page.x = xPos
		g:insert(page)
	end
	return g
end

local catalog

local loadedCatalogs = {}

local loadingText = display.newText( "Loading literature ...", display.contentWidth/2, display.contentHeight/2, native.systemFontBold, 24 )
loadingText:setReferencePoint(display.TopCenterReferencePoint)
loadingText.x=display.contentWidth/2
loadingText.y=display.contentHeight/2-100
loadingText:setTextColor(255, 255, 255)
loadingText.alpha=0 

local function showCatalog(itemId)

	local numPages = 16
	
	if (currentCatalogId == itemId) then
		return
	end
	
	-- Hide the existing catalog
	if (catalog) then
		transition.to(catalog, {time=200,alpha=0})
	end
	
	-- If catalog has been loaded previously, load it from the cache
	if (loadedCatalogs[itemId]) then
		catalog = loadedCatalogs[itemId]
		transition.to(catalog, {time=500,alpha=1})
	-- If catalog is not loaded, then load it from the file system
	else
	
		local function loadNewCatalog(itemId, numPages)
		
			catalog = loadCatalog(itemId, numPages)
			catalog.alpha=0
			catalog:setReferencePoint(display.TopLeftReferencePoint)
			catalog.x = MARGIN_TOP
			catalog.y = MARGIN_SIDE
			catalog.xScale = initialPageScale
			catalog.yScale = initialPageScale
			catalog:addEventListener("tap", pageTapHandler)
		
			local foo = sideScrollView.new{ left=display.screenOriginX, right=display.screenOriginX + (MARGIN_SIDE*2) }
			foo:insert(catalog)
			foo:addScrollBar(128,128,128)
			
			if loadedCatalogs[itemId] == nil then
				table.insert(loadedCatalogs, itemId, catalog)
			end

			transition.to(catalog, { time=1000, alpha=1 })
			loadingText.alpha=0

		end
		
    	local myclosure = function() loadNewCatalog(itemId, numPages) end
    	timer.performWithDelay(300, myclosure, 1)
    	loadingText.alpha=1
		
	end

	currentCatalogId = itemId

end

navItems = thumbNav.new{ itemSet=catalogList.catalog, imageSet=catalogList.thumbnails, xPos=0, spacing=10, borderWidth=3,
	callback=showCatalog}

-- Add the thumbnails to the side scroll navigation object at the bottom of the screen
catalogNav = sideScrollView.new{ left=display.screenOriginX, right=display.screenOriginX + (MARGIN_SIDE*2) }

catalogNav:insert(navItems)
catalogNav:addScrollBar(128,128,128)

