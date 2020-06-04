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
-- screenResetLevel.lua
--
------------------------------------------------------------------------------------------------------------------------------------
-- Release Version 1.1
-- Code developed for CORONA SDK STABLE RELESE 2013.2076
-- 13th February 2014
------------------------------------------------------------------------------------------------------------------------------------

local storyboard		= require( "storyboard" )
local scene = storyboard.newScene()
iPhone5Offset		= 40

---------------------------------------------------------------------------------
-- BEGINNING OF IMPLEMENTATION
---------------------------------------------------------------------------------


-- level select button function
function restartLevel()

	audio.stop()

	storyboard.gotoScene( "mainGameInterface"  )
	return true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view
	
--[[
	if (keepScore == true) then
		gameScore 	= gameScore
	else
		gameScore 	= 0
	end

	keepScore = false
--]]

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	
	storyboard.purgeScene( "mainGameInterface" )
	storyboard.removeScene( "mainGameInterface" )
	
	local cleanMyLevel = "level"..level
	package.loaded[levelsPath..cleanMyLevel] = nil

	local cleanMyLevel = "level"..(level-1)
	package.loaded[levelsPath..cleanMyLevel] = nil

	local cleanMyLevel = "level"..(level+1)
	package.loaded[levelsPath..cleanMyLevel] = nil


	package.loaded[levelsPath..myLevel] = nil
	
	--Short delay before we go back to the scene
	timer.performWithDelay(60, restartLevel )

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	
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





