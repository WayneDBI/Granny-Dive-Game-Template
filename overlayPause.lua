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
-- overlayPause.lua
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

function soundOnOff()

	buttonSound:removeSelf()
	buttonSound = nil

	if (soundON) then
		soundON = false
		volumeSFX 	= 0.0
		volumeMusic = 0.0
		
		--audio.stop({ channel=1 })
		--audio.stop({ channel=2 })
	
		buttonSound = widget.newButton{
		sheet = imageSheet, defaultFrame = 72, overFrame = 72,
		overColor = {128,128,128,100}, width = 53, height = 69,
		onRelease = soundOnOff, }
		--buttonSound:setReferencePoint(display.CenterReferencePoint)
		buttonSound.x = (_w/2); buttonSound.y = 174+iPhone5Offset
		buttonsGroup:insert( buttonSound )
	
	else
		soundON = true
		volumeSFX 	= resetVolumeSFX
		volumeMusic	= resetVolumeMusic
			
		buttonSound = widget.newButton{
		sheet = imageSheet, defaultFrame = 73, overFrame = 73,
		overColor = {128,128,128,100}, width = 53, height = 69,
		onRelease = soundOnOff, }
		--buttonSound:setReferencePoint(display.CenterReferencePoint)
		buttonSound.x = (_w/2); buttonSound.y = 174+iPhone5Offset
		buttonsGroup:insert( buttonSound )

		
	end
	
	audio.setVolume( volumeMusic, { channel=2 } )
	audio.setVolume( volumeMusic, { channel=3 } )
	
	audio.setVolume( volumeSFX, { channel=1 } )
	for i = 4, 32 do
		audio.setVolume( volumeSFX, { channel=i } )
	end 

	--print(volumeSFX)
	--print(volumeMusic)
	
	return true
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


	local buttonMenu = widget.newButton{
		sheet = imageSheet, defaultFrame = 66, overFrame = 66,
		overColor = {128,128,128,100}, width = 53, height = 69,
		onRelease = goMenuScreen, }
	--buttonMenu:setReferencePoint(display.CenterReferencePoint)
	buttonMenu.x = (_w/2)-80; buttonMenu.y = 300+iPhone5Offset
	buttonsGroup:insert( buttonMenu )

	local buttonReplay = widget.newButton{
		sheet = imageSheet, defaultFrame = 71, overFrame = 71,
		overColor = {128,128,128,100}, width = 53, height = 69,
		onRelease = replayLevel, }
	--buttonReplay:setReferencePoint(display.CenterReferencePoint)
	buttonReplay.x = (_w/2); buttonReplay.y = 300+iPhone5Offset
	buttonsGroup:insert( buttonReplay )

	local buttonResume = widget.newButton{
		sheet = imageSheet, defaultFrame = 70, overFrame = 70,
		overColor = {128,128,128,100}, width = 53, height = 69,
		onRelease = resumePlay, }
	--buttonResume:setReferencePoint(display.CenterReferencePoint)
	buttonResume.x = (_w/2)+80; buttonResume.y = 300+iPhone5Offset
	buttonsGroup:insert( buttonResume )

	if (volumeMusic==0.0 and volumeSFX==0.0) then
		buttonSound = widget.newButton{
			sheet = imageSheet, defaultFrame = 72, overFrame = 72,
			overColor = {128,128,128,100}, width = 53, height = 69,
			onRelease = soundOnOff, }
	else
		buttonSound = widget.newButton{
			sheet = imageSheet, defaultFrame = 73, overFrame = 73,
			overColor = {128,128,128,100}, width = 53, height = 69,
			onRelease = soundOnOff, }
	end

	--buttonSound:setReferencePoint(display.CenterReferencePoint)
	buttonSound.x = (_w/2); buttonSound.y = 174+iPhone5Offset
	buttonsGroup:insert( buttonSound )

	screenGroup:insert(buttonsGroup)
	
	local panelHeader = display.newSprite( imageSheet, animationSequenceData )
	panelHeader:setSequence( "infoPaused" )
	--panelHeader:setReferencePoint(display.CenterReferencePoint)
	panelHeader.x = (_w/2); panelHeader.y = _h/2
	screenGroup:insert( panelHeader )

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
	--gameScore	= myScore
	
	-- We set a global boolean to tell the engine to KEEP the
	-- previous level scores as we continue
	--keepScore	= true

	--timer.performWithDelay(10, updateScoreBoard )

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	print( "((destroying PAUSE view))" )
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





