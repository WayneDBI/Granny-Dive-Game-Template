------------------------------------------------------------------------------------------------------------------------------------
-- GRANNY DIVE Corona SDK Template
------------------------------------------------------------------------------------------------------------------------------------
-- Developed by Deep Blue Apps.com [www.deepbueapps.com]
------------------------------------------------------------------------------------------------------------------------------------
-- Abstract: Collect the coins and avoid the obstacles, as our hero falls down the screen.
-- Tap the left or right side of the screen to move our hero. Collect Slow motion objects
-- to help our hero collect as much as possible. Tap in the PARACHUTE ZONE to deploy your parachute
-- Then land on the base at the bottom safely to move onto the next level.
------------------------------------------------------------------------------------------------------------------------------------
-- NOTE: After you have created your levels set the [_G.maxLevels] variable in the main.lua file
-- to how many levels you have! This is VERY IMPORTANT!! As it tells the engine when the user has
-- completed ALL OF THE LEVELS.
------------------------------------------------------------------------------------------------------------------------------------
--
-- startScreen.lua
--
------------------------------------------------------------------------------------------------------------------------------------
-- Release Version 1.1
-- Code developed for CORONA SDK STABLE RELESE 2013.2076
-- 13th February 2014
------------------------------------------------------------------------------------------------------------------------------------

local storyboard		= require( "storyboard" )
local ui 				= require("ui")
local widget 			= require "widget"

local spine = require "_Assets.spine.spine"


local scene = storyboard.newScene()

local oldVolumeMusic
local oldVolumeSFX

iPhone5Offset		= 40

local doDebug = false
performance = nil

transitionCloud1A = nil
transitionCloud1B = nil
transitionCloud2A = nil
transitionCloud2B = nil
transitionCloud3A = nil
transitionCloud3B = nil
transitionCloud4A = nil
transitionCloud4B = nil

local cloud1 = nil
local cloud2 = nil
local cloud3 = nil
local cloud4 = nil

local lastTime = 0
local animationTime = 0

--Dancing Animation start data / Spine
--Optional second parameter can be the group for the Skeleton to use. Eg, could be an image group.

animationJson.scale = 0.3
skeletonData = animationJson:readSkeletonDataFile("_Assets/SpineAnimationData/skeleton-skeleton.json")
danceAnimation = animationJson:readAnimationFile(skeletonData, "_Assets/SpineAnimationData/skeleton-Dance.json")
--Here we initiate our Dancing animation
skeleton = spine.Skeleton.new(skeletonData)


---------------------------------------------------------------------------------
-- BEGINNING OF IMPLEMENTATION
---------------------------------------------------------------------------------

local image

-- level select button function
function levelSelect()
	level = 1
	--storyboard.gotoScene( "mainGameInterface", "fade", 400  )
	storyboard.gotoScene( "screenLevelSelect", "slideUp", 600  )
	return true
end

function creditsFunction()
	storyboard.gotoScene( "screenCredits", "slideUp", 600  )
	return true
end

function optionsFunction()

	storyboard.gotoScene( "screenOptions", "slideRight", 600  )
	
	--cancelTransitions()
	--timer.performWithDelay(1000,doAction,0)

	return true
end


function debugFPSInfo()

	if (doDebug == false) then
		doDebug = true
	else
		doDebug = false
		performance.group.y = 720
	end
	
	-- Debug Data
	if (doDebug) then
		local fps = require("fps")
		performance = fps.PerformanceOutput.new();
		performance.group.x, performance.group.y = (display.contentWidth/2)-40,  320;
		performance.alpha = 0.3; -- So it doesn't get in the way of the rest of the scene
	end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view
	
	function Touch(event)
		if(event.phase == "began" and gameOverBool == false) then
	
		elseif(event.phase == "ended") then
			levelSelect()
		end
	end
		  

	oldVolumeMusic 	= volumeMusic
	oldVolumeSFX 	= volumeSFX


	if (iPhone5) then
		iPhone5Offset = 80
	else
		iPhone5Offset = 0
	end
		
	----------------------------------------------------------------------------------------------------
	-- Setup the Background Image
	----------------------------------------------------------------------------------------------------
	local bg = display.newSprite( imageSheet2, animationSequenceData2 )
	bg:setSequence( "splashBackground" )
	bg.rotation = 90
	--bg:setReferencePoint(display.CenterReferencePoint)
	bg.x = _w/2; bg.y = _h/2
	screenGroup:insert( bg )
	
	-- Animated Clouds
	cloud1 = display.newSprite( imageSheet, animationSequenceData )
	cloud1:setSequence( "cloudLargeNorm" )
	--cloud1:setReferencePoint(display.CenterReferencePoint)
	cloud1.x = 0; cloud1.y = 87+iPhone5Offset
	cloud1.xScale = 1.0; cloud1.yScale = 1.0
	screenGroup:insert( cloud1 )
	
	cloud3 = display.newSprite( imageSheet, animationSequenceData )
	cloud3:setSequence( "cloudLargeNorm" )
	--cloud3:setReferencePoint(display.CenterReferencePoint)
	cloud3.x = _w+100; cloud3.y = 310--+(iPhone5Offset*2)
	cloud3.xScale = 1.0; cloud3.yScale = 1.0
	screenGroup:insert( cloud3 )


	--[[
	local granny = display.newSprite( imageSheet, animationSequenceData )
	granny:setSequence( "splashGranny" )
	granny:setReferencePoint(display.CenterReferencePoint)
	granny.x = _w/2; granny.y = 107
	screenGroup:insert( granny )
	--]]
	
	
	local grannyDiveLogo = display.newSprite( imageSheet, animationSequenceData )
	grannyDiveLogo:setSequence( "splashLogo" )
	--grannyDiveLogo:setReferencePoint(display.CenterReferencePoint)
	grannyDiveLogo.x = _w/2; grannyDiveLogo.y = 260+(iPhone5Offset/2)
	screenGroup:insert( grannyDiveLogo )

	local templateLogo = display.newSprite( imageSheet, animationSequenceData )
	templateLogo:setSequence( "splashTemplate" )
	--templateLogo:setReferencePoint(display.CenterReferencePoint)
	templateLogo.x = _w/2; templateLogo.y = 358+(iPhone5Offset/1.2)
	templateLogo.rotation = -6
	screenGroup:insert( templateLogo )
	
	local dbi = display.newSprite( imageSheet, animationSequenceData )
	dbi:setSequence( "dbi" )
	--dbi:setReferencePoint(display.CenterReferencePoint)
	dbi.x = _w-50; dbi.y = 36
	screenGroup:insert( dbi )

	cloud2 = display.newSprite( imageSheet, animationSequenceData )
	cloud2:setSequence( "cloudLargeBlur" )
	--cloud2:setReferencePoint(display.CenterReferencePoint)
	cloud2.x = _w+100; cloud2.y = 61--+(iPhone5Offset*2)
	cloud2.xScale = 0.8; cloud2.yScale = 0.8
	screenGroup:insert( cloud2 )
	
	cloud4 = display.newSprite( imageSheet, animationSequenceData )
	cloud4:setSequence( "cloudLargeBlur" )
	--cloud4:setReferencePoint(display.CenterReferencePoint)
	cloud4.x = -30; cloud4.y = 400--+(iPhone5Offset*2)
	cloud4.xScale = 0.8; cloud4.yScale = 0.8
	screenGroup:insert( cloud4 )
	
	local buttonOptions = widget.newButton{
		sheet = imageSheet, defaultFrame = 68, overFrame = 68,
		overColor = {128,128,128,100}, width = 59, height = 69,
		onRelease = optionsFunction, }
		
	--buttonOptions:setReferencePoint(display.CenterReferencePoint)
	buttonOptions.x = (60); buttonOptions.y = 424+iPhone5Offset
	screenGroup:insert( buttonOptions )

	local buttonCredits = widget.newButton{
		sheet = imageSheet, defaultFrame = 65, overFrame = 65,
		overColor = {128,128,128,100}, width = 53, height = 69,
		onRelease = creditsFunction, }
		
	--buttonCredits:setReferencePoint(display.CenterReferencePoint)
	buttonCredits.x = (_w/2); buttonCredits.y = 424+iPhone5Offset
	screenGroup:insert( buttonCredits )

	local buttonStart = widget.newButton{
		sheet = imageSheet, defaultFrame = 74, overFrame = 74,
		overColor = {128,128,128,100}, width = 53, height = 69,
		onRelease = levelSelect, }
		
	--buttonStart:setReferencePoint(display.CenterReferencePoint)
	buttonStart.x = (_w-60); buttonStart.y = 424+iPhone5Offset
	screenGroup:insert( buttonStart )

	-- Dancing Granny !
	skeleton.x = _w/2; skeleton.y = 200+(iPhone5Offset*0.4)
	skeleton.flipX = false
	skeleton.flipY = false
	skeleton.debug = false -- Omit or set to false to not draw debug lines on top of the images.
	skeleton:setToBindPose()

	--dancingGroup:insert(skeleton)
	screenGroup:insert( skeleton )

	
	--Start te Clouds Moving
	animateClouds()
	
	-----------------------------------------------------------------
	-- Start the BG Music - Looping
	-----------------------------------------------------------------
	audio.play(musicStart, {channel=2,loops = -1})


	-----------------------------------------------------------------
	-- Start the BG Music - Looping
	-----------------------------------------------------------------
	--audio.setVolume( volumeSFX, { channel=1 } ) -- set the volume on channel 1
	--audio.setVolume( volumeMusic, { channel=2 } ) -- set the volume on channel 2
	--audio.play(bgMusic, {channel=3, loops = -1})


--[[
	local debugFPS = widget.newButton{
		left = (_w/2)-80,
		top = 420,
		default = imagePath.."buttonFPS_Off.png",
		over = imagePath.."buttonFPS_On.png",
		onRelease = debugFPSInfo,
		}			
	screenGroup:insert( debugFPS )
--]]



end

function cancelTransitions()

	--Cancel transitions (if necessary)
	if transitionCloud1A then
		transition.cancel( transitionCloud1A )
		transitionCloud1A = nil
	end

	if transitionCloud1B then
		transition.cancel( transitionCloud1B )
		transitionCloud1B = nil
	end

	if transitionCloud2A then
		transition.cancel( transitionCloud2A )
		transitionCloud2A = nil
	end

	if transitionCloud2B then
		transition.cancel( transitionCloud2B )
		transitionCloud2B = nil
	end

	if transitionCloud3A then
		transition.cancel( transitionCloud3A )
		transitionCloud3A = nil
	end

	if transitionCloud3B then
		transition.cancel( transitionCloud3B )
		transitionCloud3B = nil
	end

	if transitionCloud4A then
		transition.cancel( transitionCloud4A )
		transitionCloud4A = nil
	end

	if transitionCloud4B then
		transition.cancel( transitionCloud4B )
		transitionCloud4B = nil
	end



	
end


function animateClouds()


		function moveback4()
		   transitionCloud4A =  transition.to(cloud4, {time=16000, x = -100, onComplete = moveCloud4})
		end
 
		function moveCloud4() 
		    transitionCloud4B = transition.to(cloud4, {time=16000,x = (_w+100), onComplete = moveback4})
		end

		function moveback3()
		   transitionCloud3A =  transition.to(cloud3, {time=24000, x = (_w+100), onComplete = moveCloud3})
		end
 
		function moveCloud3() 
		    transitionCloud3B = transition.to(cloud3, {time=24000,x = -100, onComplete = moveback3})
		end

		function moveback2()
		   transitionCloud2A =  transition.to(cloud2, {time=15000, x = (_w+100), onComplete = moveCloud2})
		end
 
		function moveCloud2() 
		    transitionCloud2B = transition.to(cloud2, {time=15000,x = -100, onComplete = moveback2})
		end
	
		function moveback1()
		   transitionCloud1A =  transition.to(cloud1, {time=22000, x = -100, onComplete = moveCloud1})
		end
 
		function moveCloud1() 
		    transitionCloud1B = transition.to(cloud1, {time=22000,x = (_w+100), onComplete = moveback1})
		end
	
	
		moveCloud1()
		moveCloud2()
		moveCloud3()
		moveCloud4()
 	
 	
end

------------------------------------------------------------------------------------------------------------------------------------
-- Reset the Audio back to original values
------------------------------------------------------------------------------------------------------------------------------------
function actionResetAudio()
	volumeSFX 	= resetVolumeSFX
	volumeMusic = resetVolumeMusic
	
	audio.setVolume( volumeSFX, { channel=1 } ) -- set the volume on channel 1
	audio.setVolume( volumeMusic, { channel=2 } ) -- set the volume on channel 3
end


--Update our Dancing Granny Animation every tick
function updateTick(event)

	-- Compute time in seconds since last frame.
	local currentTime = event.time / 1000
	local delta = currentTime - lastTime
	lastTime = currentTime
	animationTime = animationTime + delta
	
	
		skeleton.flipX = false

	
	-- Accumulate time and pose skeleton using animation.
	danceAnimation:apply(skeleton, animationTime, true)
	skeleton:updateWorldTransform()
end




-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	--storyboard.removeScene( "main" )
	
	--storyboard.purgeScene( "startScreen" )
	--storyboard.removeScene( "startScreen" )

	storyboard.purgeScene( "screenLevelSelect" )
	storyboard.removeScene( "screenLevelSelect" )

	storyboard.purgeScene( "screenOptions" )
	storyboard.removeScene( "screenOptions" )

	storyboard.purgeScene( "screenCredits" )
	storyboard.removeScene( "screenCredits" )

	storyboard.purgeScene( "overlayPause" )
	storyboard.removeScene( "overlayPause" )

	storyboard.purgeScene( "overlayFailed" )
	storyboard.removeScene( "overlayFailed" )

	storyboard.purgeScene( "overlayWin" )
	storyboard.removeScene( "overlayWin" )

	storyboard.purgeScene( "overlayCompleted" )
	storyboard.removeScene( "overlayCompleted" )

	storyboard.purgeScene( "screenResetLevel" )
	storyboard.removeScene( "screenResetLevel" )
	
	
	--storyboard.removeAll()
end



-- Called when scene is about to move offscreen:
function scene:exitScene( event )
		Runtime:removeEventListener("enterFrame", updateTick)
		animationTime = 0
		cancelTransitions()
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )

	print( "((destroying scene startScreen view))" )
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

---------------------------------------------------------------------------------
Runtime:addEventListener( "enterFrame", updateTick )

return scene





