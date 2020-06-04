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
-- overlayCompleted.lua
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

iPhone5Offset		= 40
iPadOffset			= 20

buttonsGroup 		= display.newGroup()

local myHighscore
local myScore
local myBonus
local myCoins

---------------------------------------------------------------------------------
-- BEGINNING OF IMPLEMENTATION
---------------------------------------------------------------------------------

function goMenuScreen()
	audio.stop()
	storyboard.gotoScene( "startScreen", "slideDown", 600  )
	return true
end

function replayLevel()
	storyboard.gotoScene( "screenResetLevel" )
	return true
end

function nextLevelGo()

	-- Increment the next level.
	level = level + 1
		
	storyboard.gotoScene( "screenResetLevel" )
	return true
end

function Touch(event)
	if(event.phase == "began") then
		return true
	elseif(event.phase == "ended") then
		return true
	end
end




-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view		  
		  
	if (iPhone5) then
		iPhone5Offset = 40
	else
		iPhone5Offset = 0
	end
	
	if (iPad) then
		iPadOffset = 10
	else
		iPadOffset = 0
	end
	
	print(level)
		
	----------------------------------------------------------------------------------------------------
	-- Setup the Background Image
	----------------------------------------------------------------------------------------------------
	local bg = display.newRect(0, 0, _w, _h)
	bg:setFillColor(0,0,0)
	bg.alpha = 0.7
	--bg:setReferencePoint(display.CenterReferencePoint)
	bg.x = _w/2; bg.y = _h/2
	screenGroup:insert( bg )
	bg:addEventListener( "touch", Touch)

	local bgPanel = display.newSprite( imageSheet, animationSequenceData )
	bgPanel:setSequence( "infoPanel" )
	--bgPanel:setReferencePoint(display.CenterReferencePoint)
	bgPanel.x = _w/2; bgPanel.y = _h/2
	screenGroup:insert( bgPanel )

	local animatedGranny = display.newSprite( imageSheet, animationSequenceData )
	animatedGranny:setSequence( "chuteOpenAnimation" )
	animatedGranny:play()
	--animatedGranny:setReferencePoint(display.CenterReferencePoint)
	animatedGranny.x = (_w/2)-105; animatedGranny.y = 195+iPhone5Offset
	animatedGranny.rotation = -6
	screenGroup:insert( animatedGranny )


	local buttonMenu = widget.newButton{
		sheet = imageSheet, defaultFrame = 66, overFrame = 66,
		overColor = {128,128,128,100}, width = 53, height = 69,
		onRelease = goMenuScreen, }
	--buttonMenu:setReferencePoint(display.CenterReferencePoint)
	buttonMenu.x = (_w/2); buttonMenu.y = 320+iPhone5Offset
	screenGroup:insert( buttonMenu )


	local panelHeader = display.newSprite( imageSheet, animationSequenceData )
	panelHeader:setSequence( "allLevelsCompleted" )
	--panelHeader:setReferencePoint(display.CenterReferencePoint)
	panelHeader.x = (_w/2); panelHeader.y = 161+iPhone5Offset
	screenGroup:insert( panelHeader )
	
	local panelHeader = display.newSprite( imageSheet, animationSequenceData )
	panelHeader:setSequence( "infoPanelText" )
	--panelHeader:setReferencePoint(display.CenterReferencePoint)
	panelHeader.x = (_w/2)-40; panelHeader.y = 240+iPhone5Offset
	screenGroup:insert( panelHeader )

	myCoinsText = display.newText("",0,0, "HelveticaNeue-CondensedBlack", 18)
	--myCoinsText:setReferencePoint(display.CenterLeftReferencePoint)
	myCoinsText.anchorX = 0.0		-- Graphics 2.0 Anchoring method
	myCoinsText.anchorY = 0.5		-- Graphics 2.0 Anchoring method
	--myCoinsText:setTextColor(34,92,189)
	myCoinsText:setFillColor(0.13,0.36,0.74)		-- Graphics 2.0 Text Coloring method
	myCoinsText.x = (_w/2)+0
	myCoinsText.y = 205+iPhone5Offset
	myCoinsText.alpha = 1
	screenGroup:insert(myCoinsText)

	myBonusText = display.newText("",0,0, "HelveticaNeue-CondensedBlack", 18)
	--myBonusText:setReferencePoint(display.CenterLeftReferencePoint)
	myBonusText.anchorX = 0.0		-- Graphics 2.0 Anchoring method
	myBonusText.anchorY = 0.5		-- Graphics 2.0 Anchoring method
	--myBonusText:setTextColor(34,92,189)
	myCoinsText:setFillColor(0.13,0.36,0.74)		-- Graphics 2.0 Text Coloring method
	myBonusText.x = (_w/2)+0
	myBonusText.y = 227+iPhone5Offset
	myBonusText.alpha = 1
	screenGroup:insert(myBonusText)

	myScoreText = display.newText("",0,0, "HelveticaNeue-CondensedBlack", 18)
	--myScoreText:setReferencePoint(display.CenterLeftReferencePoint)
	myScoreText.anchorX = 0.0		-- Graphics 2.0 Anchoring method
	myScoreText.anchorY = 0.5		-- Graphics 2.0 Anchoring method
	myScoreText:setTextColor(34,92,189)
	myScoreText:setFillColor(0.13,0.36,0.74)		-- Graphics 2.0 Text Coloring method
	myScoreText.x = (_w/2)+0
	myScoreText.y = 248+iPhone5Offset
	myScoreText.alpha = 1
	screenGroup:insert(myScoreText)
	
	myHighScoreText = display.newText("",0,0, "HelveticaNeue-CondensedBlack", 18)
	--myHighScoreText:setReferencePoint(display.CenterLeftReferencePoint)
	myHighScoreText.anchorX = 0.0		-- Graphics 2.0 Anchoring method
	myHighScoreText.anchorY = 0.5		-- Graphics 2.0 Anchoring method
	--myHighScoreText:setTextColor(34,92,189)
	myHighScoreText:setFillColor(0.13,0.36,0.74)		-- Graphics 2.0 Text Coloring method
	myHighScoreText.x = (_w/2)+0
	myHighScoreText.y = 271+iPhone5Offset
	myHighScoreText.alpha = 1
	screenGroup:insert(myHighScoreText)
	
	

end


function updateScoreBoard()

	-----------------------------------------------------------------
	-- Update the Coins text on the screen
	-----------------------------------------------------------------
	myCoinsText.text = myCoins
	--myCoinsText:setReferencePoint(display.CenterLeftReferencePoint);
	myCoinsText.anchorX = 0.0		-- Graphics 2.0 Anchoring method
	myCoinsText.anchorY = 0.5		-- Graphics 2.0 Anchoring method
	myCoinsText.x = (_w/2)

	-----------------------------------------------------------------
	-- Update the Bonus text on the screen
	-----------------------------------------------------------------
	myBonusText.text = myBonus
	--myBonusText:setReferencePoint(display.CenterLeftReferencePoint);
	myBonusText.anchorX = 0.0		-- Graphics 2.0 Anchoring method
	myBonusText.anchorY = 0.5		-- Graphics 2.0 Anchoring method
	myBonusText.x = (_w/2)

	-----------------------------------------------------------------
	-- Update Score on the screen
	-----------------------------------------------------------------
	myScoreText.text = myScore
	--myScoreText:setReferencePoint(display.CenterLeftReferencePoint);
	myScoreText.anchorX = 0.0		-- Graphics 2.0 Anchoring method
	myScoreText.anchorY = 0.5		-- Graphics 2.0 Anchoring method
	myScoreText.x = (_w/2)

	-----------------------------------------------------------------
	-- Update the HighScore text on the screen
	-----------------------------------------------------------------
	myHighScoreText.text = myHighscore
	--myHighScoreText:setReferencePoint(display.CenterLeftReferencePoint);
	myHighScoreText.anchorX = 0.0		-- Graphics 2.0 Anchoring method
	myHighScoreText.anchorY = 0.5		-- Graphics 2.0 Anchoring method
	myHighScoreText.x = (_w/2)

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )

    local params = event.params

	myCoins 	= params.collectCoins
	myBonus 	= params.collectBonus
	myScore 	= params.collectScore
	myHighscore = params.collectHighscore
	
	-- Store the current score into the Global storage variable
	-- so we can pass it onto the NEXT LEVEL
	gameScore	= myScore
	
	print("Level Completed Score: "..gameScore)
	
	timer.performWithDelay(10, updateScoreBoard )

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	print( "((destroying overlayCompleted view))" )
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