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
-- screenLevelSelect.lua
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

iPhone5Offset			= 40

local iPadXOffset = 0; if (_G.iPad==true)  then iPadXOffset = 22; end

local levelSelection	= 0

local this_btn = nil
local baseX = 20
local baseY = 4
local offsetX = 105
local offsetY = 110
--offsetYStep		= 160

local slideCounter = 0
local mainSpriteGroup 		= nil
local imageSprite			= nil
local stageRefernce			= 0
local board = {}
local setIncrementor 		= 1
local sliderPanel			= nil
local sliderPanelSprite		= nil
local this_btn 				= nil

local numberOfLevels		=	maxLevels
local levelsPerScreen		= 12 	-- How many level select panels shown on each slide
local maxLevelRows			= 3		-- How many ROWS per level select screen
local maxLevelColums		= 4		-- How many COLUMNS per level select

local myButtonsGroup1 = display.newGroup()

local lastTime = 0
local animationTime = 0

animationJson.scale = 0.2
skeletonData = animationJson:readSkeletonDataFile("_Assets/SpineAnimationData/skeleton-skeleton.json")
danceAnimation = animationJson:readAnimationFile(skeletonData, "_Assets/SpineAnimationData/skeleton-Dance.json")

--Here we initiate our Dancing animation
skeleton = spine.Skeleton.new(skeletonData)

--sliderGroup = display.newGroup()
mainSpriteGroup = display.newGroup()

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
		  
	-- We set up a simple Y offset value here depending on the device in use...	  
	if (iPhone5) then
		iPhone5Offset = 40
	else
		iPhone5Offset = 0
	end
		
	------------------------------------------------------------------------------------------------------------------------------------
	-- Create A Group (Layer) to hold our Sliding Sprites
	------------------------------------------------------------------------------------------------------------------------------------
	SliderPanelGroup = display.newGroup()
	SliderPanelGroup.x = _w/2
	
		
	----------------------------------------------------------------------------------------------------
	-- Setup the Background Image
	----------------------------------------------------------------------------------------------------
	local bg = display.newSprite( imageSheet2, animationSequenceData2 )
	bg:setSequence( "splashBackground" )
	bg.rotation = 90
	--bg:setReferencePoint(display.CenterReferencePoint)
	bg.x = _w/2; bg.y = _h/2
	bg:setFillColor( 80,80,80 )
	screenGroup:insert( bg )

	local bgPanel = display.newSprite( imageSheet, animationSequenceData )
	bgPanel:setSequence( "levelSelectText" )
	--bgPanel:setReferencePoint(display.CenterReferencePoint)
	bgPanel.x = _w-60; bgPanel.y = 460+(iPhone5Offset*1.4)
	bgPanel.xScale = 0.6
	bgPanel.yScale = 0.6
	screenGroup:insert( bgPanel )

	-- Back to menu button
	local buttonMenu = widget.newButton{
		sheet = imageSheet, defaultFrame = 66, overFrame = 66,
		overColor = {128,128,128,100}, width = 53, height = 69,
		onRelease = goMenuScreen, }
	--buttonMenu:setReferencePoint(display.CenterReferencePoint)
	buttonMenu.x = 50
	
	if (iPhone5==false) then
		buttonMenu.xScale = 0.6
		buttonMenu.yScale = 0.6
		buttonMenu.y = (_h-30) - iPhone5Offset
	else
		buttonMenu.xScale = 1
		buttonMenu.yScale = 1
		buttonMenu.y = (_h-10) - iPhone5Offset
	end
	
	screenGroup:insert( buttonMenu )

	local grannyDiveLogo = display.newSprite( imageSheet, animationSequenceData )
	grannyDiveLogo:setSequence( "splashLogo" )
	--grannyDiveLogo:setReferencePoint(display.CenterReferencePoint)
	grannyDiveLogo.x = (_w/2)-70; grannyDiveLogo.y = 320+(iPhone5Offset)
	grannyDiveLogo.xScale = 0.5; grannyDiveLogo.yScale = 0.5
	screenGroup:insert( grannyDiveLogo )

	local templateLogo = display.newSprite( imageSheet, animationSequenceData )
	templateLogo:setSequence( "splashTemplate" )
	--templateLogo:setReferencePoint(display.CenterReferencePoint)
	templateLogo.x = (_w/2)-70; templateLogo.y = 377+(iPhone5Offset*1.4)
	templateLogo.rotation = -6
	templateLogo.xScale = 0.7; templateLogo.yScale = 0.7
	screenGroup:insert( templateLogo )
	
	-- Dancing Granny !
	skeleton.x = _w-250; skeleton.y = 265+(iPhone5Offset*1.1)
	skeleton.flipX = false
	skeleton.flipY = false
	skeleton.debug = false -- Omit or set to false to not draw debug lines on top of the images.
	skeleton:setToBindPose()

	--dancingGroup:insert(skeleton)
	screenGroup:insert( skeleton )
	
	
	local function init()
			
		sliderPanel		= require( "slider" ) 	-- Enable this option to have the level select slide LEFT/RIGHT
		--sliderPanel	= require( "sliderY" ) 	-- Enable this option to have the level select slide UP/DOWN
		sliderPanel:init()
		sliderPanelSprite = sliderPanel:getSprite()
		SliderPanelGroup:insert( sliderPanelSprite )

		local sliderSpriteLevel = nil
		local sliderPanelIndicatorButtons = nil
		local this_btn = nil

		------------------------------------------------------------------------------------------------------------------------------------
		-- Loop through, creating the Slide Panels. We create enough Slide Panels to hold all of our levelPanel images
		------------------------------------------------------------------------------------------------------------------------------------
		for i = 1, (numberOfLevels/levelsPerScreen) do --Here we are looping through how many Slide Panels to Create.
			sliderSpriteLevel = createSlidePanels( i )
			sliderPanelIndicatorButtons = renderSlideBtn( i, (_w/2) )
			sliderPanel.addSlide( sliderSpriteLevel, sliderPanelIndicatorButtons )
		end
		screenGroup:insert(SliderPanelGroup)
	
	end
	
	
	------------------------------------------------------------------------------------------------------------------------------------
	-- This function is called on each iteration of the Slide Creation Loop (above)
	-- Here we are placing each of the thumbnails within the correct slider panel
	-- and setting up the levelPanel to act like a Button, with a EventListener.
	-- Looks scarier than it is really.
	------------------------------------------------------------------------------------------------------------------------------------
	function createSlidePanels( slideIndex )
		local sliderSpriteLevel = display.newGroup()
		local rowCount		= 0
		local columnCount	= 0
		
		for i = 1, levelsPerScreen do  				-- Here we are looping through how many Thumbnails to show on each Slide Panel
			setIncrementor	= setIncrementor	+ 1 -- Which Image/levelPanel to create.
			rowCount		= rowCount			+ 1	-- Increment the row count id
			
			----------------------------------------------------------------------------
			if rowCount > maxLevelRows then			-- We only want 3 ROWS
				rowCount	= 1						-- Reset the counter if exceeded
				columnCount	= columnCount + 1		-- Increment the column count id
			end
			----------------------------------------------------------------------------

			-- We assign a LIVE id to FALSE or TRUE to each menu item. Depending on the levels reached,
			-- this id is set accordingly, and used later when we try to open the selected level.
			if ((setIncrementor-1) <= nextLevel) then
				levelPanel = display.newSprite( imageSheet, animationSequenceData )
				levelPanel:setSequence( "levelUnLocked" )
				levelPanel.live = true -- Level is UNLOCKED - user can select :-)
			else
				levelPanel = display.newSprite( imageSheet, animationSequenceData )
				levelPanel:setSequence( "levelLocked" )
				levelPanel.live = false -- Level is LOCKED - user CAN NOT select :-(
				levelPanel:setFillColor( 200,200,200 )
			end

			--levelPanel:setReferencePoint(display.CenterReferencePoint)
			levelPanel.xScale = 0.62 ; levelPanel.yScale = 0.62
			levelPanel.x = (rowCount*offsetX) - ((_w/2)+(offsetX/2)) + iPadXOffset-- Set the Panels X pixels apart
			levelPanel.y = (columnCount*offsetY) + (offsetY/2) + iPhone5Offset
			
			-- We assign a TAG reference to each BUTTON/MENU - so when a user taps it,
			-- it send the listener the TAG ref, and launch the correct LEVEL
			levelPanel.tag = setIncrementor-1
			levelPanel:addEventListener( "tap", levelSelection)
			
			-- Now insert the new BUTTON/MENU item into the holding group.
			sliderSpriteLevel:insert( levelPanel )
			
			-- Quickly add the LEVEL number to the level panel
			local levelLabel = display.newText(setIncrementor-1,0,0, "HelveticaNeue-CondensedBlack", 15)
			--levelLabel:setReferencePoint(display.CenterReferencePoint)
			
			-- Adjust the colour of the Level TEXT label, if it's locked.
			if ((setIncrementor-1) <= nextLevel) then
				--levelLabel:setTextColor(25,115,206)
				levelLabel:setFillColor(0.09,0.45,0.8)
				
			else
				--levelLabel:setTextColor(16,80,180) -- Darker text for LOCKED levels...
				levelLabel:setFillColor(0.06,0.31,0.42) -- Darker text for LOCKED levels...
			end
			
			-- Position the menu text correctly.
			levelLabel.x = -2 + (rowCount*offsetX) - ((_w/2)+(offsetX/2)) -- Set the Panels X pixels apart
			levelLabel.y = -6 + (columnCount*offsetY) + (offsetY/2) + iPhone5Offset
			levelLabel.alpha = 1
			levelLabel.rotation = 4
		
			-- Add the Label to the working group.
			sliderSpriteLevel:insert(levelLabel)
			
		end
		
		local bck_sprt = display.newRect(0,0,_w,_h)
		bck_sprt.alpha = 0.01
		bck_sprt.x = 0
		sliderSpriteLevel:insert( bck_sprt )
		
		--Insert the new Slide Panel into our Screen Group
		screenGroup:insert( sliderSpriteLevel )

		return sliderSpriteLevel
	end
	----------------------------------------------------------------------------------------------------
	

	----------------------------------------------------------------------------------------------------
	-- Create the Dots at bottom of the Screen
	----------------------------------------------------------------------------------------------------
	function renderSlideBtn( btnIndex, slideWidth )
		-- We setup how many 'dots' there are by dividing how many thumbnails and Panels.
		-- Note you must ensure the number of Thumbnails EVENLY divides into the panels.
		-- If you do not, there will be an error...
		local numBtns = (numberOfLevels/levelsPerScreen)  
		
		-- Setup the Dots, to show how many slides there are.
		local sliderPanelIndicatorButtons = display.newGroup()
			sliderPanelIndicatorButtons.x =  (0.5 * slideWidth + (btnIndex - 0.5 * numBtns - 1) * 20) - (_w/4)
			sliderPanelIndicatorButtons.y = _h-15
			sliderPanelIndicatorButtons.id = btnIndex
		
		-- Set up an ON dot for the specific panel
		local slidePanelIndicatorButton_ON = display.newImageRect( imagePath.."PageIndicatorSelected.png",8,8 )
			sliderPanelIndicatorButtons:insert(slidePanelIndicatorButton_ON)
		
		-- Set up an OFF dot for the specific panel
		local slidePanelIndicatorButton_OFF = display.newImageRect( imagePath.."PageIndicatorNormal.png",8,8 )
			sliderPanelIndicatorButtons:insert(slidePanelIndicatorButton_OFF)
			slidePanelIndicatorButton_OFF.isVisible = false
		
		return sliderPanelIndicatorButtons
	end
	
	
	
	----------------------------------------------------------------------------------------------------
	-- Play a Sound when our button is pressed
	-- NOTE: we'll load the sound based on the CAPTURED data from the button in the sliderPanel.
	----------------------------------------------------------------------------------------------------
	function levelSelection( evt )
		-- Collect the id's associated with the tapped menu..
		local btnId 	= evt.target.id
		local btnLevel	= evt.target.tag
		local btnActive	= evt.target.live
		------------------------------------
		local saveX = evt.target.x
		local saveY = evt.target.y
		local levelStatusInfo = "Locked."
		------------------------------------
		local function loadUsersLevel()
				
			print( "loadUsersLevel function loaded" )
			level 				= btnLevel
			
			local cleanMyLevel = "level"..level
			package.loaded[levelsPath..cleanMyLevel] = nil

			
			-- Tell the engine that this is the FIRST level to be played this session.
			multiLevelsPlayed 	= 0
			
			-- Set the Game Score to ZERO before we begin ANY level
			gameScore	= 0
			resetScore	= 0

			print( "Going to:mainGameInterface" )
			
			storyboard.gotoScene( "mainGameInterface", "fade", 400  )
		end
		
		-- If the level selected is UN-LOCKED, then load the level and proceed!.
		if (btnActive) then
			levelStatusInfo = "Un-Locked."
			timer.performWithDelay(200, loadUsersLevel ) -- Perform after a short delay
		end
		
		-- Show which button/Menu was tapped, with some status details.
		print( "Level Selected: = " .. btnLevel )
		print( "Level Status:   = " .. levelStatusInfo )
	
		--Clean up and then play the new sound
		--audio.dispose()
		--audio.stop()
		--audio.rewind()
		--currentSound = audio.loadSound( audioPath..subImagePath..btnSound..soundType )
		--audio.play(currentSound)
	

	end
	
	
	init()
	
	

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

	storyboard.purgeScene( "screenCredits" )
	storyboard.removeScene( "screenCredits" )

	storyboard.purgeScene( "startScreen" )
	storyboard.removeScene( "startScreen" )

	--storyboard.purgeScene( "screenLevelSelect" )
	--storyboard.removeScene( "screenLevelSelect" )
	
	--storyboard.removeAll()
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
		Runtime:removeEventListener("enterFrame", updateTick)
		audio.stop()
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	print( "((destroying screenLevelSelect view))" )
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