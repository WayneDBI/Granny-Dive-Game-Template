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
-- BASE.lua
--
------------------------------------------------------------------------------------------------------------------------------------
-- Release Version 1.1
-- Code developed for CORONA SDK STABLE RELESE 2013.2076
-- 13th February 2014
------------------------------------------------------------------------------------------------------------------------------------

local storyboard		= require( "storyboard" )
local ui 				= require("ui")
local widget 			= require "widget"

local scene = storyboard.newScene()

local doDebug = false
performance = nil
---------------------------------------------------------------------------------
-- BEGINNING OF IMPLEMENTATION
---------------------------------------------------------------------------------

local image

-- level select button function
function levelSelect()
	storyboard.gotoScene( "mainGameInterface", "fade", 400  )
	return true
end

function debugFPSInfo()

	if (doDebug == false) then
		doDebug = true
	else
		doDebug = false
		performance.group.y = 480
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
		  

	----------------------------------------------------------------------------------------------------
	-- Setup the Background Image
	----------------------------------------------------------------------------------------------------
	--image = display.newSprite( imageSheet2, animationSequenceData2 )
	--image:setSequence( "startScreenImage" )
	--image:play()
	image = display.newImageRect( "Default.png",320,568 )
	image.x = _w/2
	image.y = _h/2
	image.alpha = 1.0
	screenGroup:insert( image )
	--image:addEventListener( "touch", Touch )
	
	----------------------------------------------------------------------------------------------------
	-- Setup the START BUTTON
	----------------------------------------------------------------------------------------------------
	local startButton = widget.newButton{
		left = (_w/2)-80,
		top = 380,
		default = imagePath.."buttonStart_Off.png",
		over = imagePath.."buttonStart_On.png",
		onRelease = levelSelect,
		}			
	screenGroup:insert( startButton )


	local debugFPS = widget.newButton{
		left = (_w/2)-80,
		top = 420,
		default = imagePath.."buttonFPS_Off.png",
		over = imagePath.."buttonFPS_On.png",
		onRelease = debugFPSInfo,
		}			
	screenGroup:insert( debugFPS )




end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	storyboard.removeScene( "main" )
	storyboard.purgeScene( "mainGameInterface" )
	storyboard.removeScene( "mainGameInterface" )
	storyboard.removeAll()
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	
	print( "((destroying scene 1's view))" )
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

return scene





