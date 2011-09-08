print( "Application Start")

local physics = require "physics"
physics.start()

physics.setScale( 60 )
physics.setGravity( 0, 9.8 )
display.setStatusBar( display.HiddenStatusBar ) -- Hide status bar on top

--physics.setDrawMode("hybrid")

-- Set app background image
background = display.newImage( "bg.png", true )
background.x = display.contentWidth / 2
background.y = display.contentHeight / 2

-- Set ceiling object
ceiling = display.newRect(0, 0, display.contentWidth, 0)
ceiling.myName = "ceiling"
physics.addBody( ceiling, "static", { density = 1.0, friction = 1.0, bounce = 0 } )

-- Set ground object
ground = display.newRect(0, display.contentHeight-90, display.contentWidth, 0)
ground.myName = "ground"
physics.addBody( ground, "static", { density = 1.0, friction = 1.0, bounce = 0.3 } )

leftWall = display.newRect(0, 0, 0, display.contentHeight)
leftWall.myName = "leftWall"
physics.addBody( leftWall, "static", { density = 1.0, friction = 1.0, bounce = 0.3 } )

rightWall = display.newRect(display.contentWidth, 0, 0, display.contentHeight)
rightWall.myName = "rightWall"
physics.addBody( rightWall, "static", { density = 1.0, friction = 1.0, bounce = 0.3 } )

-- BALL SECTION
local function hitBall( event )
	local t = event.target
	local phase = event.phase

	if "began" == phase then
		-- print( "Hit Ball - Ball Position: " .. math.ceil(t.x) .. "," .. math.ceil(t.y) .. " Event: " .. event.x .. "," .. event.y )
		local xForce = (t.x - event.x) + 10
		xForce = 0
		
		local yForce = -20;
		-- print( "X Force: " .. xForce .. " Y Force: " .. yForce )
		t:applyLinearImpulse( xForce, yForce, t.x, t.y )
	end
	return true
end

local ballXLoc = {
	(display.contentWidth / 2),
	(display.contentWidth / 4),
	(display.contentWidth / 2 + display.contentWidth / 4),
	(display.contentWidth / 8),
	(display.contentWidth / 4 + display.contentWidth / 8),
	(display.contentWidth / 2 + display.contentWidth / 8),
	(display.contentWidth / 2 + display.contentWidth / 4 + display.contentWidth / 8)
}

function getBallXLoc(i)
	
end

local ball = {}
local ballBody = { density = 1.0, friction = 1.0, bounce = 0.5, radius = 50 }
local n = 0
local numOfBalls = 7
for i = 1, numOfBalls do
	n = n + 1
	ball[n] = display.newImage("soccerball_1.png")
	local aBall = ball[n]
	aBall.x = ballXLoc[n]
	aBall.y = math.random(200, 600)
	--ball[n].linearDamping = 0
	--ball[n].angularDamping = 0.8
	aBall.id = "ball"
	aBall.myName = "ball_" .. n
	physics.addBody( aBall, ballBody )
	aBall:addEventListener( "touch", hitBall )
end

-- Collision events
local function onCollision( event )
	if ( event.phase == "began" ) then
    	--print( "Event: collision Began: " .. event.object1.myName .. " & " .. event.object2.myName )
    elseif ( event.phase == "ended" ) then
		print( "Event: collision Ended: " .. event.object1.myName .. " & " .. event.object2.myName )
    end
end

Runtime:addEventListener( "collision", onCollision )


-- Splash Screen
--local startButton = display.newText( "Start bouncing", display.contentWidth/2, 200, native.systemFont, 24 )
--startButton:setTextColor( 255,255,255 )
--startButton.x = display.contentWidth/2