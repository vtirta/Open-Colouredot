-- sideScrollView.lua 
-- 
-- Version 1.0 
--
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of 
-- this software and associated documentation files (the "Software"), to deal in the 
-- Software without restriction, including without limitation the rights to use, copy, 
-- modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
-- and to permit persons to whom the Software is furnished to do so, subject to the 
-- following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all copies 
-- or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
-- DEALINGS IN THE SOFTWARE.
 
module(..., package.seeall)

-- set some global values for width and height of the screen
local screenW, screenH = display.contentWidth, display.contentHeight
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

local prevTime = 0

function new(params)
	--prevTime = 0
	-- setup a group to be the scrolling screen
	local sideScrollView = display.newGroup()
		
	sideScrollView.left = params.left or 0
	sideScrollView.right = params.right or 0

	function sideScrollView:touch(event) 
	        local phase = event.phase      
	        --print(phase)
	        			        
	        if( phase == "began" ) then

	                self.startPos = event.x
	                self.prevPos = event.x                                       
	                self.delta, self.velocity = 0, 0
		            if self.tween then transition.cancel(self.tween) end

	                Runtime:removeEventListener("enterFrame", sideScrollView ) 

					self.prevTime = 0
					self.prevX = 0

					transition.to(self.scrollBar,  { time=200, alpha=1 } )									

					-- Start tracking velocity
					Runtime:addEventListener("enterFrame", trackVelocity)
	                
	                -- Subsequent touch events will target button even if they are outside the contentBounds of button
	                display.getCurrentStage():setFocus( self )
	                self.isFocus = true
	 
	        elseif( self.isFocus ) then
	 
	                if( phase == "moved" ) then     
					        local rightLimit = screenW - self.width - self.right

	                        self.delta = event.x - self.prevPos
	                        self.prevPos = event.x
	                        if ( self.x > self.left or self.x < rightLimit ) then
                                self.x  = self.x + self.delta/2
	                        else
                                self.x = self.x + self.delta
	                        end
	                        
	                        sideScrollView:moveScrollBar()

	                elseif( phase == "ended" or phase == "cancelled" ) then 
	                        local dragDistance = event.x - self.startPos
							self.lastTime = event.time
	                        
	                        Runtime:addEventListener("enterFrame", sideScrollView )  	 			
	                        Runtime:removeEventListener("enterFrame", trackVelocity)
	        	                	        
	                        -- Allow touch events to be sent normally to the objects they "hit"
	                        display.getCurrentStage():setFocus( nil )
	                        self.isFocus = false
	                end
	        end
	        
	        return true
	end
	 
	function sideScrollView:enterFrame(event)   
		local friction = 0.9
		local timePassed = event.time - self.lastTime
		self.lastTime = self.lastTime + timePassed       

        --turn off scrolling if velocity is near zero
        if math.abs(self.velocity) < .01 then
                self.velocity = 0
	            Runtime:removeEventListener("enterFrame", sideScrollView )          
				transition.to(self.scrollBar,  { time=400, alpha=0 } )									
        end       

        self.velocity = self.velocity*friction
        
        self.x = math.floor(self.x + self.velocity*timePassed)
        
        local leftLimit = self.left
	    local rightLimit = screenW - self.width - self.right

        if ( self.x > leftLimit ) then
                self.velocity = 0
                Runtime:removeEventListener("enterFrame", sideScrollView )          
                self.tween = transition.to(self, { time=400, x=leftLimit, transition=easing.outQuad})
				transition.to(self.scrollBar,  { time=400, alpha=0 } )									
        elseif ( self.x < rightLimit and rightLimit < 0 ) then
                self.velocity = 0
                Runtime:removeEventListener("enterFrame", sideScrollView )          
                self.tween = transition.to(self, { time=400, x=rightLimit, transition=easing.outQuad})
				transition.to(self.scrollBar,  { time=400, alpha=0 } )									
        elseif ( self.x < rightLimit ) then
                self.velocity = 0
                Runtime:removeEventListener("enterFrame", sideScrollView )          
                self.tween = transition.to(self, { time=400, x=leftLimit, transition=easing.outQuad})
				transition.to(self.scrollBar,  { time=400, alpha=0 } )									
        end 

        sideScrollView:moveScrollBar()
        	        
	    return true
	end
	
	function sideScrollView:moveScrollBar()
		if self.scrollBar then						
			local scrollBar = self.scrollBar
			
			scrollBar.x = -self.x*self.xRatio + scrollBar.width*0.5 + self.left
			
			if scrollBar.x <  5 + self.left + scrollBar.width*0.5 then
				scrollBar.x = 5 + self.left + scrollBar.width*0.5 + 10
			end
			if scrollBar.x > screenW - self.right  - 5 - scrollBar.width*0.5 then
				scrollBar.x = screenW - self.right - 5 - scrollBar.width*0.5 + 10
			end
			
		end
	end

	function trackVelocity(event) 	
		local timePassed = event.time - sideScrollView.prevTime
		sideScrollView.prevTime = sideScrollView.prevTime + timePassed
	
		if sideScrollView.prevX then 
			sideScrollView.velocity = (sideScrollView.x - sideScrollView.prevX)/timePassed
		end
		sideScrollView.prevX = sideScrollView.x
	end			
	    
	sideScrollView.x = sideScrollView.left
	
	-- setup the touch listener 
	sideScrollView:addEventListener( "touch", sideScrollView )

	function sideScrollView:addScrollBar(r,g,b,a)
		if self.scrollBar then self.scrollBar:removeSelf() end

		local scrollColorR = r or 0
		local scrollColorG = g or 0
		local scrollColorB = b or 0
		local scrollColorA = a or 120
						
		local viewPortW = screenW - self.left - self.right
		local scrollW = viewPortW*self.width/(self.width*2 - viewPortW)
		local scrollBar = display.newRoundedRect(0,viewableScreenH-15,scrollW,5,2)

		scrollBar:setFillColor(scrollColorR, scrollColorG, scrollColorB, scrollColorA)

		local xRatio = scrollW/self.width
		self.xRatio = xRatio

		scrollBar.x = scrollBar.width*0.5 + self.left + 10

		self.scrollBar = scrollBar

		transition.to(scrollBar,  { time=400, alpha=0 } )			
	end

	function sideScrollView:removeScrollBar()
		if self.scrollBar then 
			self.scrollBar:removeSelf() 
			self.scrollBar = nil
		end
	end
	
	function sideScrollView:cleanUp()
        Runtime:removeEventListener("enterFrame", trackVelocity)
		Runtime:removeEventListener( "touch", sideScrollView )
		Runtime:removeEventListener("enterFrame", sideScrollView ) 
		sideScrollView:removeScrollBar()
	end
	
	return sideScrollView
end
