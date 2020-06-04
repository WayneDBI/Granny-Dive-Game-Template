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
-- overlayFailed.lua
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

function resumePlay()
	storyboard.hideOverlay("overlayPause")
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
	
	--Collect the Score parameters sent over from previous scene
		local params = event.params
	
		if (params.collectCoins) then
			myCoins = params.collectCoins
		else
			myCoins = 0
		end

		if (params.collectCoins) then
			myBonus = params.collectBonus
		else
			myBonus = 0
		end
	
		 if (params.collectCoins) then
			myScore = params.collectScore
		else
			myScore = 0
		end
	
		if (params.collectCoins) then
			myHighscore = params.collectHighscore
		else
			myHighscore = 0
		end
	
		--[[
		myCoins 	= params.collectCoins
		myBonus 	= params.collectBonus
		myScore 	= params.collectScore
		myHighscore = params.collectHighscore
		--]]
	
		timer.performWithDelay(10, updateScoreBoard )

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

	local animatedAngel = display.newSprite( imageSheet, animationSequenceData )
	animatedAngel:setSequence( "angelAnimation" )
	animatedAngel:play()
	--animatedAngel:setReferencePoint(display.CenterReferencePoint)
	animatedAngel.x = (_w/2)-85; animatedAngel.y = 195+iPhone5Offset
	screenGroup:insert( animatedAngel )

	local crashImage = display.newSprite( imageSheet, animationSequenceData )
	crashImage:setSequence( "crashAnimation" )
	--crashImage:setReferencePoint(display.CenterReferencePoint)
	crashImage.x = (_w/2)+90; crashImage.y = 169+iPhone5Offset
	crashImage.rotation = 30
	screenGroup:insert( crashImage )

	local buttonMenu = widget.newButton{
	sheet = imageSheet, defaultFrame = 66, overFrame = 66,
	overColor = {128,128,128,100}, width = 53, height = 69,
	onRelease = goMenuScreen, }
	--buttonMenu:setReferencePoint(display.CenterReferencePoint)
	buttonMenu.x = (_w/2)-40; buttonMenu.y = 320+iPhone5Offset
	screenGroup:insert( buttonMenu )

	local buttonReplay = widget.newButton{
	sheet = imageSheet, defaultFrame = 71, overFrame = 71,
	overColor = {128,128,128,100}, width = 53, height = 69,
	onRelease = replayLevel, }
	--buttonReplay:setReferencePoint(display.CenterReferencePoint)
	buttonReplay.x = (_w/2)+40; buttonReplay.y = 320+iPhone5Offset
	screenGroup:insert( buttonReplay )

--[[
	local buttonResume = widget.newButton{
	sheet = imageSheet, defaultFrame = 70, overFrame = 70,
	overColor = {128,128,128,100}, width = 53, height = 69,
	onRelease = resumePlay, }
	buttonResume:setReferencePoint(display.CenterReferencePoint)
	buttonResume.x = (_w/2)+80; buttonResume.y = 300+iPhone5Offset
	buttonsGroup:insert( buttonResume )
--]]

	local panelHeader = display.newSprite( imageSheet, animationSequenceData )
	panelHeader:setSequence( "infoFailed" )
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
	myBonusText:setFillColor(0.13,0.36,0.74)		-- Graphics 2.0 Text Coloring method
	myBonusText.x = (_w/2)+0
	myBonusText.y = 227+iPhone5Offset
	myBonusText.alpha = 1
	screenGroup:insert(myBonusText)

	myScoreText = display.newText("",0,0, "HelveticaNeue-CondensedBlack", 18)
	--myScoreText:setReferencePoint(display.CenterLeftReferencePoint)
	myScoreText.anchorX = 0.0		-- Graphics 2.0 Anchoring method
	myScoreText.anchorY = 0.5		-- Graphics 2.0 Anchoring method
	--myScoreText:setTextColor(34,92,189)
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

--[[
function collectScores()

    local params = event.params
    
    if (params.collectCoins) then
    	myCoins = params.collectCoins
    else
    	myCoins = 0
    end

    if (params.collectCoins) then
    	myBonus = params.collectBonus
    else
    	myBonus = 0
    end
    
     if (params.collectCoins) then
    	myScore = params.collectScore
    else
    	myScore = 0
    end
    
    if (params.collectCoins) then
    	myHighscore = params.collectHighscore
    else
    	myHighscore = 0
    end
    
	--myCoins 	= params.collectCoins
	--myBonus 	= params.collectBonus
	--myScore 	= params.collectScore
	--myHighscore = params.collectHighscore
	
	timer.performWithDelay(10, updateScoreBoard )
end
--]]

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )


end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	print( "((destroying overlayFailed view))" )
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