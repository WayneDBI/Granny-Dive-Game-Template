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
-- screenCredits.lua
--
------------------------------------------------------------------------------------------------------------------------------------
-- Release Version 1.1
-- Code developed for CORONA SDK STABLE RELESE 2013.2076
-- 13th February 2014
------------------------------------------------------------------------------------------------------------------------------------

local storyboard		= require( "storyboard" )
local ui 				= require("ui")
local widget 			= require "widget"

local spine 			= require "_Assets.spine.spine"

local scene = storyboard.newScene()

iPhone5Offset		= 40

local lastTime = 0
local animationTime = 0

animationJson.scale = 0.3
skeletonData = animationJson:readSkeletonDataFile("_Assets/SpineAnimationData/skeleton-skeleton.json")
danceAnimation = animationJson:readAnimationFile(skeletonData, "_Assets/SpineAnimationData/skeleton-Dance.json")
--Here we initiate our Dancing animation
skeleton = spine.Skeleton.new(skeletonData)

---------------------------------------------------------------------------------
-- BEGINNING OF IMPLEMENTATION
---------------------------------------------------------------------------------


function goMenuScreen()
	storyboard.gotoScene( "startScreen", "slideLeft", 600  )
	return true
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
		  
		  
	if (iPhone5) then
		iPhone5Offset = 40
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

	local bgPanel = display.newSprite( imageSheet, animationSequenceData )
	bgPanel:setSequence( "infoPanel" )
	--bgPanel:setReferencePoint(display.CenterReferencePoint)
	bgPanel.x = _w/2; bgPanel.y = 285+iPhone5Offset
	screenGroup:insert( bgPanel )


	local buttonMenu = widget.newButton{
		sheet = imageSheet, defaultFrame = 66, overFrame = 66,
		overColor = {128,128,128,100}, width = 53, height = 69,
		onRelease = goMenuScreen, }
		
	--buttonMenu:setReferencePoint(display.CenterReferencePoint)
	buttonMenu.x = (_w/2); buttonMenu.y = 390+iPhone5Offset
	screenGroup:insert( buttonMenu )

	--[[
	local granny = display.newSprite( imageSheet, animationSequenceData )
	granny:setSequence( "splashGranny" )
	granny:setReferencePoint(display.CenterReferencePoint)
	granny.x = 67; granny.y = 64+(iPhone5Offset/2)
	granny.xScale = 0.61; granny.yScale = 0.61
	screenGroup:insert( granny )
	--]]
	
	local dbi = display.newSprite( imageSheet, animationSequenceData )
	dbi:setSequence( "dbi" )
	--dbi:setReferencePoint(display.CenterReferencePoint)
	dbi.x = _w-50; dbi.y = 443+iPhone5Offset
	screenGroup:insert( dbi )

	local grannyDiveLogo = display.newSprite( imageSheet, animationSequenceData )
	grannyDiveLogo:setSequence( "splashLogo" )
	--grannyDiveLogo:setReferencePoint(display.CenterReferencePoint)
	grannyDiveLogo.x = _w-110; grannyDiveLogo.y = 80+(iPhone5Offset/2)
	grannyDiveLogo.xScale = 0.75; grannyDiveLogo.yScale = 0.75
	screenGroup:insert( grannyDiveLogo )

	local templateLogo = display.newSprite( imageSheet, animationSequenceData )
	templateLogo:setSequence( "splashTemplate" )
	--templateLogo:setReferencePoint(display.CenterReferencePoint)
	templateLogo.x = 102; templateLogo.y = 450+(iPhone5Offset/1)
	templateLogo.rotation = -6
	templateLogo.xScale = 0.6; templateLogo.yScale = 0.6
	screenGroup:insert( templateLogo )
	
	local panelHeader = display.newSprite( imageSheet, animationSequenceData )
	panelHeader:setSequence( "creditsHeader" )
	--panelHeader:setReferencePoint(display.CenterReferencePoint)
	panelHeader.x = (_w/2); panelHeader.y = 199+(iPhone5Offset)
	screenGroup:insert( panelHeader )

	local panelText = display.newSprite( imageSheet, animationSequenceData )
	panelText:setSequence( "creditsText" )
	--panelText:setReferencePoint(display.CenterReferencePoint)
	panelText.x = (_w/2); panelText.y = 297+(iPhone5Offset)
	screenGroup:insert( panelText )

	-- Dancing Granny !
	skeleton.x = _w-250; skeleton.y = 200+(iPhone5Offset*0.4)
	skeleton.flipX = false
	skeleton.flipY = false
	skeleton.debug = false -- Omit or set to false to not draw debug lines on top of the images.
	skeleton:setToBindPose()

	--dancingGroup:insert(skeleton)
	screenGroup:insert( skeleton )

end



--Update our Dancing Granny Animation every tick
function updateTick(event)
	-- Compute time in seconds since last frame.
	local currentTime = event.time / 1000
	local delta = currentTime - lastTime
	lastTime = currentTime
	animationTime = animationTime + delta
	-- Accumulate time and pose skeleton using animation.
	danceAnimation:apply(skeleton, animationTime, true)
	skeleton:updateWorldTransform()
end



-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	storyboard.removeScene( "main" )
	
	storyboard.purgeScene( "mainGameInterface" )
	storyboard.removeScene( "mainGameInterface" )
	
	storyboard.purgeScene( "screenOptions" )
	storyboard.removeScene( "screenOptions" )

	storyboard.purgeScene( "startScreen" )
	storyboard.removeScene( "startScreen" )

	storyboard.purgeScene( "screenLevelSelect" )
	storyboard.removeScene( "screenLevelSelect" )
	
	--storyboard.removeAll()
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	Runtime:removeEventListener("enterFrame", updateTick)
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	
	print( "((destroying sceneCredits view))" )
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





