module( ..., package.seeall )

-- vars
local slider_sprt		= nil
local slides_sprt		= nil
local btns_sprt			= nil

local isDragging		= false
local currSlideIndex	= 1
local startPosY			= 0
local offsetPosY		= 0
local lastPosY			= 0
local lastTimeMsec		= 0
local dY				= 0
local slide_twn			= nil

-- forward declerations
local touchCb
local slideEndCb
local toggleBtns
local startDrag
local endDrag
local drag
local slideTo



--##################################################################################################
-- PUBLIC METHODS
--##################################################################################################

----------------------------------------------------------------------------------------------------
-- init
----------------------------------------------------------------------------------------------------
function init()

	-- vars
	slider_sprt		= nil
	slides_sprt		= nil
	btns_sprt		= nil

	isDragging		= false
	currSlideIndex	= 1
	startPosY		= 0
	offsetPosY		= 0
	lastPosY		= 0
	lastTimeMsec	= 0
	dY				= 0
	slide_twn		= nil
	
	-- slider_sprt
	slider_sprt = display.newGroup()
	
	-- slides_sprt
	slides_sprt = display.newGroup()
	slider_sprt:insert( slides_sprt )
	
	-- btns_sprt
	btns_sprt = display.newGroup()
	slider_sprt:insert( btns_sprt )
	
	-- events
	slides_sprt:addEventListener( "touch", touchCb )
	--Runtime:addEventListener( "touch", touchCb )
	
end

----------------------------------------------------------------------------------------------------
-- dispose
----------------------------------------------------------------------------------------------------
function dispose()
	
	-- events
	slides_sprt:removeEventListener( "touch", touchCb )
	--Runtime:removeEventListener( "touch", touchCb )
	
	-- cancel tween
	if ( slide_twn ~= nil ) then
		transition.cancel( slide_twn )
		slide_twn = nil
	end
	
	-- btns_sprt
	local thisBtn = nil
	while ( btns_sprt.numChildren > 0 ) do
		thisBtn = btns_sprt[ 1 ]
		for j=1, thisBtn.numChildren do
			thisBtn:remove( 1 )
		end
		thisBtn:removeEventListener( "tap",  tapCb)
		btns_sprt:remove( thisBtn )
	end
	slider_sprt:remove( btns_sprt )
	btns_sprt = nil
	
	-- slides_sprt
	slides_sprt = display.newGroup()
	
	local thisSlide_sprt = nil
	while ( slides_sprt.numChildren > 0 ) do
		--thisSlide_sprt.dispose()
		thisSlide_sprt = slides_sprt[ 1 ]
		slides_sprt:remove( thisSlide_sprt )
	end
	slider_sprt:remove( slides_sprt )
	slides_sprt = nil
	
	-- slider_sprt
	
	-- vars

end

----------------------------------------------------------------------------------------------------
-- getSprite
----------------------------------------------------------------------------------------------------
function getSprite()

	return slider_sprt
	
end

----------------------------------------------------------------------------------------------------
-- getSlide
----------------------------------------------------------------------------------------------------
function getSlide( slideIndex )

	return slides_sprt[ slideIndex ]
	
end

----------------------------------------------------------------------------------------------------
-- setState
----------------------------------------------------------------------------------------------------
function addSlide( slide_sprt, btn_sprt )
	
	-- slide
	slides_sprt:insert( slide_sprt )
	slide_sprt.y = (slides_sprt.numChildren - 1) * display.contentHeight
	
	-- btn
	if ( btn_sprt ~= nil ) then
		btns_sprt:insert( btn_sprt )
		btn_sprt:addEventListener( "tap",  tapCb)
		toggleBtns( 1 )
	end
	
end



--##################################################################################################
-- PRIVATE METHODS
--##################################################################################################

----------------------------------------------------------------------------------------------------
-- touchCb
----------------------------------------------------------------------------------------------------
function touchCb( evt )
	
	if (evt.phase == "began") then
		startDrag( evt )
	elseif (evt.phase == "ended") then
		endDrag( evt )
	else
		drag( evt )
	end
	
end

----------------------------------------------------------------------------------------------------
-- slideEndCb
----------------------------------------------------------------------------------------------------
function slideEndCb( evt )
	
	-- currSlideIndex
	currSlideIndex = 1 + math.floor( (-slides_sprt.y + 0.5 * display.contentHeight) / display.contentHeight )
	-- offsetPosY
	offsetPosY = slides_sprt.y
	-- btns
	toggleBtns( currSlideIndex )
	
end

----------------------------------------------------------------------------------------------------
-- tapCb
----------------------------------------------------------------------------------------------------
function tapCb( evt )
	
	local btnId = evt.target.id
	--toggleBtns( btnId )
	slideTo( btnId, 2500 )
	
end

----------------------------------------------------------------------------------------------------
-- toggleBtns
----------------------------------------------------------------------------------------------------
function toggleBtns( activeBtnId )	
	
	local this_btn = nil
	local isActive = false
	for i=1, btns_sprt.numChildren do
		this_btn = btns_sprt[ i ]
		if ( this_btn ~= nil ) then
			isActive = ( i == activeBtnId )
			this_btn[ 1 ].isVisible = isActive
			this_btn[ 2 ].isVisible = not isActive
		end
	end
	
end

----------------------------------------------------------------------------------------------------
-- startDrag
----------------------------------------------------------------------------------------------------
function startDrag( evt )
	
	isDragging = true
	
	-- startPosY
	--startPosY = evt.yStart
	startPosY = evt.y
	
	-- offsetPosY
	offsetPosY = slides_sprt.y
	
	-- lastPosY and lastTimeMsec
	lastPosY = evt.y
	lastTimeMsec = system.getTimer()
	
	-- cancel tween
	if ( slide_twn ~= nil ) then
		transition.cancel( slide_twn )
		slide_twn = nil
	end
	
end

----------------------------------------------------------------------------------------------------
-- endDrag
----------------------------------------------------------------------------------------------------
function endDrag( evt )
	
	isDragging = false
	
	-- calc speed
	local dT = system.getTimer() - lastTimeMsec
	if (dT < 10) then dT = 10 end
	local speed = dY / ( 0.001 * dT )
	
	-- targetSlideIndex
	local targetSlideIndex = currSlideIndex
	
	if (math.abs(speed) > 500) then
		-- speed
		targetSlideIndex = targetSlideIndex - (speed / math.abs(speed))
	else
		targetSlideIndex = 1 + math.floor( (-slides_sprt.y + 0.5 * display.contentHeight) / display.contentHeight )
		speed = 1000
	end
	
	-- min / max slide index
	if ( targetSlideIndex <= 0 or targetSlideIndex >  slides_sprt.numChildren) then
		targetSlideIndex = currSlideIndex
		speed = 1000
	end
	
	-- slide tween
	slideTo( targetSlideIndex, speed )
	
end

----------------------------------------------------------------------------------------------------
-- drag
----------------------------------------------------------------------------------------------------
function drag( evt )
	
	if ( false == isDragging ) then
		startDrag( evt )
		startPosY = evt.y
	end
	
	-- lastPosY and lastTimeMsec
	dY = evt.y - lastPosY
	lastPosY = evt.y
	lastTimeMsec = system.getTimer()
	
	-- pos
	--slides_sprt.y = offsetPosY + evt.y - evt.yStart
	slides_sprt.y = offsetPosY + evt.y - startPosY
	
end

----------------------------------------------------------------------------------------------------
-- slideTo
----------------------------------------------------------------------------------------------------
function slideTo( targetSlideIndex, speed )
	
	-- cancel tween
	if ( slide_twn ~= nil ) then
		transition.cancel( slide_twn )
		slide_twn = nil
	end
	
	-- tween
	local targetPosY = (targetSlideIndex - 1) * display.contentHeight
	local timeMsec = 1000 * math.abs( (slides_sprt.y + targetPosY) / speed )
	--slide_twn = transition.to( slides_sprt, { y = -targetPosY, time = timeMsec, transition = easing.inOutQuad, onComplete = slideEndCb } )
	slide_twn = transition.to( slides_sprt, { y = -targetPosY, time = timeMsec, onComplete = slideEndCb } )
	
end