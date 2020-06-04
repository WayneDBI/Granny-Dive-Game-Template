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
-- mainGameInterface.lua
--
------------------------------------------------------------------------------------------------------------------------------------
-- Release Version 1.0.1
-- Code developed for CORONA SDK STABLE RELESE 2013.1137
-- 11th September 2013
------------------------------------------------------------------------------------------------------------------------------------

-- Collect relevant external libraries
local storyboard 		= require( "storyboard" )
local ui 				= require("ui")
local widget 			= require "widget"

-- Require our external Load/Save module
local loadsave 				= require("loadsave")

local scene 		= storyboard.newScene()
--system.activate( "multitouch" )

gameOverBool			= false
triggerGameOver			= false
levelCompleted			= false
levelFailed				= false

scrollStart				= false
gameStart				= false

debugON           		= false

tiltSpeed				= 5	-- How fast the LEFT and RIGHT Moves..
resetSpeed				= 700 -- How fast we move the hero back to the centre (Larger #=Slower)

moveLeft				= false
moveRight				= false
parachuteOut			= false
parachauteAnim			= false
controlsAlpha			= 0.01	-- The LEFT and RIGHT controllers on the screen
controlPlayerStart		= false
--gameScore				= gameScore
--myhighScore				= highScore
distanceTravelled		= 0

scrollSpeed 			= 0		-- This value is controlled from the LEVEL data.
collectItemScrollSpeed 	= 2  	-- NOTE: This value is ADDED to the default ScrollSpeed for added depth.
scrollSpeedDie			= 13	-- The user Did not hit the deploy Zone - SPEED up the user death! Mwahhhh...
scrollParachuteSpeed	= 2
floatDownSpeed			= 70	-- This is the final FORCE that is applied if the Parachute is out

slowMotionSpeed			= 1		-- If activated, how ast to scroll the scene.
slowMotionTime			= 4		-- How many seconds of Slowmotion?
slowMotionActivated		= false
slowMotionValue			= 100	-- How many EXTRA points for collecting the slowmotion icon?
slowMotionZoomScale		= 1.0	-- How much the Backdrops should zoom if a slow mo is collected.

scrollHeight 			= 0 	-- Overridden in the LEVEL LOADER !
platformSize 			= 1 	-- Overridden in the LEVEL LOADER !

scrollCount 			= 0
startOffsetY 			= 250
heroLastY				= 0
cloudXScrollSpeed		= 0.5

coinsCollected			= 0
bonusCollected			= 0

deployZoneOnScreen		= false
inDeployZone			= false
missedDeployZone		= false
stopObjectSpawns		= false

local temp 				= 1
resetHeroPosition		= nil
local zoneTableWidth 	= 9
collectItemLevel		= 1	

scrollZones				= {}
zones 					= {}

offScreenWallYPosition	= -240	-- NOTE: We will draw the boundary wall outside of the screen - so as to destroy objects OFF SCREEN!
local currentLevel		= 1
finalScene				= false

--local myLevel					= "needs loading"

local gameIsPaused		= false
landMinX				= 0		-- Minimum X value if the target is moving along the X axis
landMaxX				= 0		-- Maximum X value if the target is moving along the X axis
landMoving				= false	-- Is the target landing platform moving (values defined in the LEVEL lua files)
landMovingSpeed			= 0		-- Speed of the moving Target.
landStaticX				= 0		-- If the Target base is static, store the X position here.
parachuteZoneHeight		= 0		-- This is the HEIGHT of the Chute zone, again setup in the LEVEL lua file

_W 		= display.contentWidth/2
_H 		= display.contentHeight/2
_MH  	= display.contentHeight
_MW  	= display.contentWidth

realDeviceWidthPixels = (display.contentWidth - (display.screenOriginX * 2)) / display.contentScaleX
realDeviceHeightPixels = (display.contentHeight - (display.screenOriginY * 2)) / display.contentScaleY

-----------------------------------------------------------------
-- Setup our World/Scene Groups
-----------------------------------------------------------------
sky_Group 			= display.newGroup()
cliff_Group 		= display.newGroup()
info_Group 			= display.newGroup()
hero_Group 			= display.newGroup()
hud_Group			= display.newGroup()
cloud_Group			= display.newGroup()
gameOver_Group		= display.newGroup()
levelComplete_Group	= display.newGroup()
baseGroup			= display.newGroup()

-----------------------------------------------------------------
-- Setup the Physics World
-----------------------------------------------------------------
physics.start()
physics.setScale( 120 )
physics.setGravity( 0, 0 )
physics.setPositionIterations(12)

-- un-comment to see the Physics world over the top of the Sprites
--physics.setDrawMode( "hybrid" )

----------------------------------------------------------------------------------------------------
-- Extra cleanup routines
----------------------------------------------------------------------------------------------------
local coronaMetaTable = getmetatable(display.getCurrentStage())
	isDisplayObject = function(aDisplayObject)
	return (type(aDisplayObject) == "table" and getmetatable(aDisplayObject) == coronaMetaTable)
end

local function cleanGroups ( objectOrGroup )
    if(not isDisplayObject(objectOrGroup)) then return end
		if objectOrGroup.numChildren then
			-- we have a group, so first clean that out
			while objectOrGroup.numChildren > 0 do
				-- clean out the last member of the group (work from the top down!)
				cleanGroups ( objectOrGroup[objectOrGroup.numChildren])
			end
		end
			objectOrGroup:removeSelf()
    return
end


-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view
		
		--audio.setVolume( musicVolume )
		
		myLevel = "level"..level
		collectScene = require(levelsPath..myLevel) --We dynamically load the correct level.
		
		print("Starting Score: "..gameScore)
		
		--resetScore = gameScore
		gameScore = resetScore
		
		-----------------------------------------------------------------
		--Collect some other LEVEL specific data from the level.lua file
		-----------------------------------------------------------------
		scrollHeight 		= 	collectScene.numberOfZones
		scrollSpeed 		=	collectScene.collectScrollSpeedData
		landMinX 			= 	collectScene.collectMinXData
		landMaxX 			= 	collectScene.collectMaxXData
		landStaticX 		= 	collectScene.collectStaticXData
		landMoving			= 	collectScene.collectTargetMovingData
		landMovingSpeed		= 	collectScene.collectMovingSpeedData
		parachuteZoneHeight	= 	collectScene.collectParachuteZoneHeightData
		platformSize		= 	collectScene.collectplatformSizeData
		-----------------------------------------------------------------
		--scrollZones		= 	collectScene.scrollZones
		--zones				= 	collectScene.zones

		
		-----------------------------------------------------------------
		-- Setup Collision Filters
		-----------------------------------------------------------------
		heroFilterData = { categoryBits = 1, maskBits = 478 }
		collectItemsFilterData = { categoryBits = 2, maskBits = 33 }
		hazard1FilterData = { categoryBits = 4, maskBits = 33 }
		hazard2FilterData = { categoryBits = 8, maskBits = 33 }
		floorFilterData = { categoryBits = 16, maskBits = 1 }
		wallsFilterData = { categoryBits = 32, maskBits = 14 }
		parachuteZoneFilterData = { categoryBits = 64, maskBits = 1 }
		landZoneFilterData = { categoryBits = 128, maskBits = 1 }
		dieZoneFilterData = { categoryBits = 256, maskBits = 1 }
		-----------------------------------------------------------------
		-- Setup the Walls
		-----------------------------------------------------------------
		worldWall = display.newRect( 0, 0, _MW, 30 )
		worldWall.x = _W
		worldWall.y = offScreenWallYPosition -- NOTE: We draw the boundary wall outside of the screen - so as to destroy objects OFF SCREEN!
		worldWall.myName = "wall"
		worldWall.alpha = 0.0
		physics.addBody( worldWall, "dynamic", wallsFilterData )
		worldWall.isSensor = true
		hero_Group:insert( worldWall )


		-----------------------------------------------------------------
		-- Setup our Hero
		-----------------------------------------------------------------
		ourHero = display.newSprite( imageSheet, animationSequenceData )
		--ourHero:setSequence( "openParachuteAnimation" )
		ourHero:setSequence( "standingAnimation" )
		ourHero:play()
		ourHero.x = _W
		
		--if (iPhone5) then
		--	ourHero.y = 170
		--else
			ourHero.y = 130--160
		--end
		
		--We'll make a HIT AREA just big enough for our heros head
		local heroArea = { -15,-5, 15,-5, 15,35, -15,35 }
		local heroMaterial = { density=10.0, friction=0.0, bounce=0.0, filter=heroFilterData, shape=heroArea }
		physics.addBody( ourHero, heroMaterial )
		ourHero.isSensor = true
		ourHero.myName = "hero"
		--hero_Group:insert( ourHero )

		-----------------------------------------------------------------
		-- Setup our Hero's Parachute: We'll hide it until it's needed!
		-----------------------------------------------------------------
		--heroParachute = display.newSprite( imageSheet, animationSequenceData )
		--heroParachute:setSequence( "parachuteAnimation" )
		--heroParachute.x = _W
		--heroParachute.y = ourHero.y-90   --We'll constrain the Y position to our Hero, and deploy when needed!
		--heroParachute.alpha = 0.0 -- set it to invisible, until needed!
		
		--hero_Group:insert( heroParachute )
		hero_Group:insert( ourHero )

		-----------------------------------------------------------------
		-- Setup the SKY
		-----------------------------------------------------------------
		local sky = display.newSprite( imageSheet2, animationSequenceData2 )
		sky:setSequence( "skyBG" )
		sky:play()
		sky.x = _W
		sky.y = _H
		sky.yScale = 1.0
		sky.rotation = 90
		sky_Group:insert( sky )
		
		sky:addEventListener( "touch", skyTouchStart)

		-----------------------------------------------------------------
		-- Setup the CLIFF FACE

		cliffTop = display.newSprite( imageSheet2, animationSequenceData2 )
		--cliffTop:setReferencePoint(display.BottomCenterReferencePoint)
		cliffTop.anchorX = 0.5	-- Graphics 2.0 Anchoring method
		cliffTop.anchorY = 1.0	-- Graphics 2.0 Anchoring method
		cliffTop:setSequence( "cliffTop" )
		--cliffTop:play()

		cliffMid1 = display.newSprite( imageSheet2, animationSequenceData2 )
		--cliffMid1:setReferencePoint(display.BottomCenterReferencePoint)
		cliffMid1.anchorX = 0.5	-- Graphics 2.0 Anchoring method
		cliffMid1.anchorY = 1.0	-- Graphics 2.0 Anchoring method
		cliffMid1:setSequence( "cliffMid1" )
		--cliffMid1:setFillColor( 255,0,0,0.4 ) --debug data
		--cliffMid1:play()

		cliffMid2 = display.newSprite( imageSheet2, animationSequenceData2 )
		--cliffMid2:setReferencePoint(display.BottomCenterReferencePoint)
		cliffMid2.anchorX = 0.5	-- Graphics 2.0 Anchoring method
		cliffMid2.anchorY = 1.0	-- Graphics 2.0 Anchoring method
		cliffMid2:setSequence( "cliffMid2" )
		--cliffMid2:setFillColor( 0,255,0,0.4 ) --debug data
		--cliffMid2:play()

		cliffMid3 = display.newSprite( imageSheet2, animationSequenceData2 )
		--cliffMid3:setReferencePoint(display.BottomCenterReferencePoint)
		cliffMid3.anchorX = 0.5	-- Graphics 2.0 Anchoring method
		cliffMid3.anchorY = 1.0	-- Graphics 2.0 Anchoring method
		cliffMid3:setSequence( "cliffMid1" )
		--cliffMid3:setFillColor( 0,0,255,0.4 ) --debug data
		--cliffMid3:play()
			
		if (iPhone5) then
			--cliffMid3 = display.newSprite( imageSheet2, animationSequenceData2 )
			--cliffMid3:setReferencePoint(display.BottomCenterReferencePoint)
			--cliffMid3:setSequence( "cliffMid1" )
			--cliffMid3:setFillColor( 0,55,100,0.4 ) --debug data
			--cliffMid3:play()

			cliffTop.x = _W
			cliffTop.y = (_H+startOffsetY)  - 44

			cliffMid1.x = _W
			cliffMid1.y = (720+startOffsetY) + 0

			cliffMid2.x = _W
			cliffMid2.y = (1200+startOffsetY)  + 0
			
			cliffMid3.x = _W
			cliffMid3.y = (1680+startOffsetY)  + 0
		else
			cliffTop.x = _W
			cliffTop.y = _H+startOffsetY
			
			cliffMid1.x = _W
			cliffMid1.y = 720+startOffsetY

			cliffMid2.x = _W
			cliffMid2.y = 1200+startOffsetY
			
			cliffMid3.x = _W
			cliffMid3.y = 1680+startOffsetY
		end

			cliff_Group:insert( cliffMid1 )
			cliff_Group:insert( cliffMid2 )
			cliff_Group:insert( cliffMid3 )
			cliff_Group:insert( cliffTop )

		--if (iPhone5) then
		--	cliff_Group:insert( cliffMid3 )
		--end
		
		--cliff_Group:insert( cliffMid1 )
		--cliff_Group:insert( cliffMid2 )
		--cliff_Group:insert( cliffTop )

		-----------------------------------------------------------------
		-- Setup the BASE ITEMS (at the bottom of the cliff)
		-----------------------------------------------------------------
		cliffBase = display.newSprite( imageSheet2, animationSequenceData2 )
		cliffBase:setSequence( "cliffFiller" )
		cliffBase.x = _W
		cliffBase.y = _MH - (cliffBase.height/2)
		cliffBase.xScale = 1.3
		cliffBase.myName = "dieZone"
		
		local cliffBaseMaterial = { density=10000.0, friction=0.0, bounce=0.0, filter=dieZoneFilterData }
		physics.addBody( cliffBase, cliffBaseMaterial )
		--local myJoint = physics.newJoint( "weld", cliffBase, cliffBase, cliffBase.x,cliffBase.y )
		cliffBase.isFixedRotation = true
		baseGroup:insert( cliffBase )
		
		landTarget = display.newSprite( imageSheet, animationSequenceData )
		landTarget:setSequence( "platformLand"..platformSize )
		
		--Set the position of the Landing Target area
		--If it's a moving Base use the Starting X Position - otherwise use the Static X Position
		if ( landMoving == true ) then
			landTarget.x = landMinX
		else
			landTarget.x = landStaticX
		end
		
		landTarget.y = cliffBase.y - (cliffBase.height/2) - (landTarget.height/2)
		landTarget.myName = "landTarget"
		
		local landTargetMaterial = { density=10000.0, friction=0.0, bounce=0.0, filter=landZoneFilterData }
		--local myJoint = physics.newJoint( "weld", landTarget, cliffBase, cliffBase.x,cliffBase.y )
		physics.addBody( landTarget, landTargetMaterial )
		landTarget.isFixedRotation = true
		baseGroup:insert( landTarget )
	
		--Rocks
		local baseRocks = display.newSprite( imageSheet, animationSequenceData )
		baseRocks:setSequence( "outcrop1" )
		baseRocks.x = (baseRocks.width/2)+6
		baseRocks.y = (cliffBase.y - (cliffBase.height/2) - (baseRocks.height/2)) +4
		baseRocks.rotation = 180
		baseRocks.myName = "outCrop"
		baseGroup:insert( baseRocks )

		--Direction Arrow
		guideArrow = display.newSprite( imageSheet, animationSequenceData )
		guideArrow:setSequence( "landArrow" )
		guideArrow.x = landTarget.x
		guideArrow.y = cliffBase.y - (cliffBase.height/2) - 50
		guideArrow.alpha = 0.0
		guideArrow.myName = "guideArrow"
		baseGroup:insert( guideArrow )
		
		-----------------------------------------------------------------------
		-- Setup the Home, Next Level, game Over, completed etc screen objects
		-----------------------------------------------------------------------
		--Move the Base Group One screen down
		--if (iPhone5) then
			baseGroup.y = 1450
		--else
		--	baseGroup.y = 960
		--end
		

		-----------------------------------------------------------------
		-- Setup the Clouds on a separate Group/Layer
		-----------------------------------------------------------------		
		cloud1 = display.newSprite( imageSheet, animationSequenceData )
		cloud1:setSequence( "cloudSmall" )
		cloud1.x = math.random(-20,_MW)
		cloud1.y = math.random(-20,_MH)
		cloud1.alpha = 1.0
		cloud_Group:insert( cloud1 )

		cloud2 = display.newSprite( imageSheet, animationSequenceData )
		cloud2:setSequence( "cloudSmall" )
		cloud2.x = math.random(-20,_MW)
		cloud2.y = math.random(-20,_MH)
		cloud2.alpha = 1.0
		cloud_Group:insert( cloud2 )

		cloud3 = display.newSprite( imageSheet, animationSequenceData )
		cloud3:setSequence( "cloudSmall" )
		cloud3.x = math.random(-20,_MW)
		cloud3.y = math.random(-20,_MH)
		cloud3.alpha = 1.0
		cloud_Group:insert( cloud3 )




		-----------------------------------------------------------------
		-- Score and HighScore
		-----------------------------------------------------------------		
		local scoreHudBar = display.newSprite( imageSheet, animationSequenceData )
		scoreHudBar:setSequence( "hudTop" )
		scoreHudBar.x = 143
		scoreHudBar.y = 21
		scoreHudBar.alpha = 0.5
		hud_Group:insert( scoreHudBar )

		myScoreText = display.newText("Score: "..gameScore,0,0, "HelveticaNeue-CondensedBlack", 18)
		--myScoreText:setReferencePoint(display.CenterLeftReferencePoint)
		myScoreText.anchorX = 0.0		-- Graphics 2.0 Anchoring method
		myScoreText.anchorY = 0.5		-- Graphics 2.0 Anchoring method
		--myScoreText:setTextColor(255,255,255)
		myScoreText:setFillColor(1,1,1)		-- Graphics 2.0 Text Coloring method
		myScoreText.x = 20
		myScoreText.y = 20
		myScoreText.alpha = 1
		hud_Group:insert(myScoreText)
		
		myHighScoreText = display.newText("Highscore: "..highScore,0,0, "HelveticaNeue-CondensedBlack", 18)
		--myHighScoreText:setReferencePoint(display.CenterLeftReferencePoint)
		myHighScoreText.anchorX = 0.0		-- Graphics 2.0 Anchoring method
		myHighScoreText.anchorY = 0.5		-- Graphics 2.0 Anchoring method
		--myHighScoreText:setTextColor(255,255,255)
		myHighScoreText:setFillColor(1,1,1)		-- Graphics 2.0 Text Coloring method
		myHighScoreText.x = 130
		myHighScoreText.y = 20
		myHighScoreText.alpha = 1
		hud_Group:insert(myHighScoreText)


		----------------------------------------------------------------------------------------------------
		-- Setup the Game Over panel
		----------------------------------------------------------------------------------------------------
		local gameOverGraphic = display.newSprite( imageSheet, animationSequenceData )
		gameOverGraphic:setSequence( "gameOverPanel" )
		--local gameOverGraphic = display.newImageRect( imagePath.."gameOverPanel.png",320,480 )
		gameOverGraphic.x = _W
		gameOverGraphic.y = _H
		gameOverGraphic.yScale = 1.0
		gameOver_Group:insert( gameOverGraphic )

		----------------------------------------------------------------------------------------------------
		-- Setup the BUTTONS : NOTE we are using new APIS introduced in Corona 2012.824
		----------------------------------------------------------------------------------------------------
		local hudPauseButton = widget.newButton{
			sheet = imageSheet, defaultFrame = 69, overFrame = 69,
			overColor = {128,128,128,100}, width = 42, height = 42,
			onRelease = pauseWindowShow,
			}
			
		--hudPauseButton:setReferencePoint(display.CenterReferencePoint)
		hudPauseButton.x = 291
		hudPauseButton.y = 24
			
		hud_Group:insert( hudPauseButton )
		
		-- Move the HUD off screen, until our hero is in flight!
		hud_Group.y = -80
		
		gameOver_Group.y = _MH*2

		----------------------------------------------------------------------------------------------------
		-- Setup the LEVEL COMPLETE Panel
		----------------------------------------------------------------------------------------------------
		local levelCompleteGraphic = display.newSprite( imageSheet, animationSequenceData )
		levelCompleteGraphic:setSequence( "levelCompletePanel" )
		--local gameOverGraphic = display.newImageRect( imagePath.."gameOverPanel.png",320,480 )
		levelCompleteGraphic.x = _W
		levelCompleteGraphic.y = _H
		levelCompleteGraphic.yScale = 1.0
		levelComplete_Group:insert( levelCompleteGraphic )
		levelComplete_Group.y = -(_MH*1.3)
		
		
		-----------------------------------------------------------------
		-- Set up the TUTORIAL sprites etc
		-----------------------------------------------------------------
		--Slow Motion overlay SHOWN when the user has slowed down
		slowMotionOverlay = display.newRect(0, 0, _w, _h)
		slowMotionOverlay:setFillColor(0,0,0)
		slowMotionOverlay.anchorX = 0.5	-- Graphics 2.0 Anchoring method
		slowMotionOverlay.anchorY = 0.5	-- Graphics 2.0 Anchoring method
		slowMotionOverlay.x=_w/2; slowMotionOverlay.y=_h/2; 
		slowMotionOverlay.alpha = 0.0
		info_Group:insert( slowMotionOverlay )
		
		infoTapScreenStart = display.newSprite( imageSheet2, animationSequenceData2 )
		infoTapScreenStart:setSequence( "infoStart" )
		infoTapScreenStart:play()
		infoTapScreenStart.alpha = 1.0
		infoTapScreenStart.x = _w/2; infoTapScreenStart.y = _h/2
		info_Group:insert( infoTapScreenStart )

		--If this is LEVEL ONE, then we BUILD the tutorial graphics.
		if (level==1 and showTutorial==true) then
			
			infoCollectItems = display.newSprite( imageSheet2, animationSequenceData2 )
			infoCollectItems:setSequence( "infoCoins" )
			infoCollectItems:play()
			infoCollectItems.alpha = 0.0
			infoCollectItems.anchorX = 0.5	-- Graphics 2.0 Anchoring method
			infoCollectItems.anchorY = 0.5	-- Graphics 2.0 Anchoring method
			infoCollectItems.x = _w/2; infoCollectItems.y = _h/2
			info_Group:insert( infoCollectItems )

			infoAvoidHazards = display.newSprite( imageSheet2, animationSequenceData2 )
			infoAvoidHazards:setSequence( "infoHazard" )
			infoAvoidHazards:play()
			infoAvoidHazards.alpha = 0.0
			infoAvoidHazards.anchorX = 0.5	-- Graphics 2.0 Anchoring method
			infoAvoidHazards.anchorY = 0.5	-- Graphics 2.0 Anchoring method
			infoAvoidHazards.x = _w/2; infoAvoidHazards.y = _h/2
			info_Group:insert( infoAvoidHazards )

			infoParachuteZone = display.newSprite( imageSheet2, animationSequenceData2 )
			infoParachuteZone:setSequence( "infoParachute" )
			infoParachuteZone:play()
			infoParachuteZone.alpha = 0.0
			infoParachuteZone.anchorX = 0.5	-- Graphics 2.0 Anchoring method
			infoParachuteZone.anchorY = 0.5	-- Graphics 2.0 Anchoring method
			infoParachuteZone.x = _w/2; infoParachuteZone.y = _h/2
			info_Group:insert( infoParachuteZone )
			
			infoLanding = display.newSprite( imageSheet2, animationSequenceData2 )
			infoLanding:setSequence( "infoLand" )
			infoLanding:play()
			infoLanding.alpha = 0.0
			infoLanding.anchorX = 0.5	-- Graphics 2.0 Anchoring method
			infoLanding.anchorY = 0.5	-- Graphics 2.0 Anchoring method
			infoLanding.x = _w/2; infoLanding.y = _h/2
			info_Group:insert( infoLanding )
		
			infoLeftPanel = display.newRect(0, 0, _w/2, _h)
			infoLeftPanel:setFillColor(255,0,0)
			infoLeftPanel.anchorX = 0.5	-- Graphics 2.0 Anchoring method
			infoLeftPanel.anchorY = 0.5	-- Graphics 2.0 Anchoring method
			infoLeftPanel.x=0+(infoLeftPanel.width/2); infoLeftPanel.y=_h/2; 
			infoLeftPanel.alpha = 0.0
			info_Group:insert( infoLeftPanel )

			infoRightPanel = display.newRect(0, 0, _w/2, _h)
			infoRightPanel:setFillColor(255,0,0)
			infoRightPanel.anchorX = 0.5	-- Graphics 2.0 Anchoring method
			infoRightPanel.anchorY = 0.5	-- Graphics 2.0 Anchoring method
			infoRightPanel.x=_w-(infoRightPanel.width/2); infoRightPanel.y=_h/2; 
			infoRightPanel.alpha = 0.0
			info_Group:insert( infoRightPanel )
			
			infoLeftPanelText = display.newSprite( imageSheet2, animationSequenceData2 )
			infoLeftPanelText:setSequence( "infoLeft" )
			infoLeftPanelText:play()
			infoLeftPanelText.anchorX = 0.5	-- Graphics 2.0 Anchoring method
			infoLeftPanelText.anchorY = 0.5	-- Graphics 2.0 Anchoring method
			infoLeftPanelText.alpha = 0.0
			infoLeftPanelText.x=infoLeftPanel.x; infoLeftPanelText.y=_h/2; 
			info_Group:insert( infoLeftPanelText )

			infoRightPanelText = display.newSprite( imageSheet2, animationSequenceData2 )
			infoRightPanelText:setSequence( "infoRight" )
			infoRightPanelText:play()
			infoRightPanelText.alpha = 0.0
			infoRightPanelText.anchorX = 0.5	-- Graphics 2.0 Anchoring method
			infoRightPanelText.anchorY = 0.5	-- Graphics 2.0 Anchoring method
			infoRightPanelText.x=infoRightPanel.x; infoRightPanelText.y=_h/2; 
			info_Group:insert( infoRightPanelText )

		end
		-----------------------------------------------------------------
		-- Setup the animated floor effect
		-----------------------------------------------------------------

		-----------------------------------------------------------------
		-- Put all the remaining NON ROTATING objects into the core game group
		-----------------------------------------------------------------
		screenGroup:insert( sky_Group )
		screenGroup:insert( cliff_Group )
		screenGroup:insert( cloud_Group )
		screenGroup:insert( info_Group )
		screenGroup:insert( hero_Group )
		screenGroup:insert( gameOver_Group )
		screenGroup:insert( levelComplete_Group )
		screenGroup:insert( hud_Group )
		screenGroup:insert( baseGroup )

		-----------------------------------------------------------------
		-- Start the BG Music - Looping
		-----------------------------------------------------------------
		--Reserve Channels 1, 2, 3 for Specific audio
		audio.reserveChannels( 3 )
		
		--audio.play(musicStart, {channel=2,loops = -1})
		audio.play(musicGame, {channel=2,loops = -1})
		
end


-----------------------------------------------------------------
-- position the collectable items based on the data in the array
-----------------------------------------------------------------
function buildZone(zone)

	if (stopObjectSpawns==false) then

		local len = table.maxn(zone)

		for i = 1, len do
			for j = 1, zoneTableWidth do
			
			
				--Setup the COLLECTABLE items data, physics etc...
				if(zone[i][j] == 1 and missedDeployZone==false ) then
					local collectableItem = display.newSprite( imageSheet, animationSequenceData )
					collectableItem:setSequence( "coinStatic" )
					collectableItem:play()
					collectableItem.destroy = false
					collectableItem.x = j*(_MW/(zoneTableWidth+1))
					collectableItem.y = (i*51.5) + _MH + (-hero_Group.y)
					collectableItem.myName = "collectItem"
					collectableItem.isSensor = true
					local collectItemMaterial = { density=3.0, friction=0.0, bounce=0.0, filter=collectItemsFilterData, radius=8 }
					physics.addBody( collectableItem, collectItemMaterial )
					hero_Group:insert(collectableItem)
					collectableItem:toBack()
				
				--Setup the COLLECTABLE items data, physics etc...
				elseif(zone[i][j] == 9 and missedDeployZone==false) then
					local collectableItem = display.newSprite( imageSheet, animationSequenceData )
					collectableItem:setSequence( "coinAnimated" )
					collectableItem:play()
					collectableItem.destroy = false
					collectableItem.x = j*(_MW/(zoneTableWidth+1))
					collectableItem.y = (i*51.5) + _MH + (-hero_Group.y)
					collectableItem.myName = "collectItemBonus"
					collectableItem.isSensor = true
					local collectItemMaterial = { density=3.0, friction=0.0, bounce=0.0, filter=collectItemsFilterData, radius=8 }
					physics.addBody( collectableItem, collectItemMaterial )
					hero_Group:insert(collectableItem)
					collectableItem:toBack()

				--Setup the LEFT SIDE HAZARD BRANCH style 1
				elseif(zone[i][j] == 2 and missedDeployZone==false) then
					local hazardObsticle = display.newSprite( imageSheet, animationSequenceData )
					hazardObsticle:setSequence( "branchLeft1" )
					hazardObsticle:play()
					--hazardObsticle.xScale = -1.0
					--hazardObsticle:setReferencePoint(display.CenterRightReferencePoint) -- Deprecated Graphics 1.0 API
					hazardObsticle.anchorX = 1.0	-- Graphics 2.0 Anchoring method
					hazardObsticle.anchorY = 0.5	-- Graphics 2.0 Anchoring method
					hazardObsticle.destroy = false
					hazardObsticle.x = (j)*(_MW/(zoneTableWidth+1))--(j*32)
					hazardObsticle.y = (i*51.5) + _MH + (-hero_Group.y)
					hazardObsticle.myName = "hazard"
					hazardObsticle.isSensor = true
					physics.addBody( hazardObsticle, physicsData:get("Object-BranchL1@2x") ) --Note the Collision Material is defined in the external Data file
					hero_Group:insert(hazardObsticle)
					hazardObsticle:toBack()

				--Setup the RIGHT SIDE HAZARD BRANCH style 1
				elseif(zone[i][j] == 3 and missedDeployZone==false) then
					local hazardObsticle = display.newSprite( imageSheet, animationSequenceData )
					hazardObsticle:setSequence( "branchRight1" )
					hazardObsticle:play()
					--hazardObsticle:setReferencePoint(display.CenterLeftReferencePoint)
					hazardObsticle.anchorX = 0.0	-- Graphics 2.0 Anchoring method
					hazardObsticle.anchorY = 0.5	-- Graphics 2.0 Anchoring method
					hazardObsticle.destroy = false
					hazardObsticle.x = (j+2)*(_MW/(zoneTableWidth+1))--(j*32)
					hazardObsticle.y = (i*51.5) + _MH + (-hero_Group.y)
					hazardObsticle.myName = "hazard"
					hazardObsticle.isSensor = true
					physics.addBody( hazardObsticle, physicsData:get("Object-BranchR1@2x") ) --Note the Collision Material is defined in the external Data file
					hero_Group:insert(hazardObsticle)
					hazardObsticle:toBack()

				--Setup the LEFT SIDE HAZARD BRANCH style 2
				elseif(zone[i][j] == 10 and missedDeployZone==false) then
					local hazardObsticle = display.newSprite( imageSheet, animationSequenceData )
					hazardObsticle:setSequence( "branchLeft2" )
					hazardObsticle:play()
					--hazardObsticle.xScale = -1.0
					--hazardObsticle:setReferencePoint(display.CenterRightReferencePoint)
					hazardObsticle.anchorX = 1.0	-- Graphics 2.0 Anchoring method
					hazardObsticle.anchorY = 0.5	-- Graphics 2.0 Anchoring method
					hazardObsticle.destroy = false
					hazardObsticle.x = (j)*(_MW/(zoneTableWidth+1))--(j*32)
					hazardObsticle.y = (i*51.5) + _MH + (-hero_Group.y)
					hazardObsticle.myName = "hazard"
					hazardObsticle.isSensor = true
					physics.addBody( hazardObsticle, physicsData:get("Object-BranchL2@2x") ) --Note the Collision Material is defined in the external Data file
					hero_Group:insert(hazardObsticle)
					hazardObsticle:toBack()
					print("LEFT SIDE HAZARD BRANCH style 2")

				--Setup the RIGHT SIDE HAZARD BRANCH style 2
				elseif(zone[i][j] == 11 and missedDeployZone==false) then
					local hazardObsticle = display.newSprite( imageSheet, animationSequenceData )
					hazardObsticle:setSequence( "branchRight2" )
					hazardObsticle:play()
					--hazardObsticle:setReferencePoint(display.CenterLeftReferencePoint)
					hazardObsticle.anchorX = 0.0	-- Graphics 2.0 Anchoring method
					hazardObsticle.anchorY = 0.5	-- Graphics 2.0 Anchoring method
					hazardObsticle.destroy = false
					hazardObsticle.x = (j)*(_MW/(zoneTableWidth+1))--(j*32)
					hazardObsticle.y = (i*51.5) + _MH + (-hero_Group.y)
					hazardObsticle.myName = "hazard"
					hazardObsticle.isSensor = true
					physics.addBody( hazardObsticle, physicsData:get("Object-BranchR2@2x") ) --Note the Collision Material is defined in the external Data file
					hero_Group:insert(hazardObsticle)
					hazardObsticle:toBack()

				--Setup the LEFT SIDE HAZARD CLIFF
				elseif(zone[i][j] == 4 and missedDeployZone==false) then
					local hazardObsticle = display.newSprite( imageSheet, animationSequenceData )
					hazardObsticle:setSequence( "ledgeLeft2" )
					hazardObsticle:play()
					--hazardObsticle.xScale = -1.0
					--hazardObsticle:setReferencePoint(display.CenterRightReferencePoint)
					hazardObsticle.anchorX = 1.0	-- Graphics 2.0 Anchoring method
					hazardObsticle.anchorY = 0.5	-- Graphics 2.0 Anchoring method
					hazardObsticle.destroy = false
					hazardObsticle.x = 0--(j-2)*(_MW/(zoneTableWidth+1))--(j*32)
					hazardObsticle.y = (i*51.5) + _MH + (-hero_Group.y)
					hazardObsticle.myName = "hazard"
					hazardObsticle.isSensor = true
					physics.addBody( hazardObsticle, physicsData:get("Object-LedgeL2@2x") ) --Note the Collision Material is defined in the external Data file
					hero_Group:insert(hazardObsticle)
					hazardObsticle:toBack()

				--Setup the RIGHT SIDE HAZARD CLIFF
				elseif(zone[i][j] == 5 and missedDeployZone==false) then
					local hazardObsticle = display.newSprite( imageSheet, animationSequenceData )
					hazardObsticle:setSequence( "ledgeRight2" )
					hazardObsticle:play()
					--hazardObsticle:setReferencePoint(display.CenterLeftReferencePoint)
					hazardObsticle.anchorX = 0.0	-- Graphics 2.0 Anchoring method
					hazardObsticle.anchorY = 0.5	-- Graphics 2.0 Anchoring method
					hazardObsticle.destroy = false
					hazardObsticle.x = (j)*(_MW/(zoneTableWidth+1))--(j*32)
					hazardObsticle.y = (i*51.5) + _MH + (-hero_Group.y)
					hazardObsticle.myName = "hazard"
					hazardObsticle.isSensor = true
					physics.addBody( hazardObsticle, physicsData:get("Object-LedgeR2@2x") ) --Note the Collision Material is defined in the external Data file
					hero_Group:insert(hazardObsticle)
					hazardObsticle:toBack()

				--Setup the INNER HAZARDS BOULDER
				elseif(zone[i][j] == 6 and missedDeployZone==false) then
					local hazardObsticle = display.newSprite( imageSheet, animationSequenceData )
					hazardObsticle:setSequence( "outcrop2" )
					hazardObsticle:play()
					--hazardObsticle.xScale = -1.0
					hazardObsticle.destroy = false
					hazardObsticle.x = j*(_MW/(zoneTableWidth+1))--(j*32)
					hazardObsticle.y = (i*51.5) + _MH + (-hero_Group.y)
					hazardObsticle.myName = "hazard"
					hazardObsticle.isSensor = true
					physics.addBody( hazardObsticle, physicsData:get("Object-Outcrop2@2x") ) --Note the Collision Material is defined in the external Data file
					hero_Group:insert(hazardObsticle)
					hazardObsticle:toBack()

				--Setup the INNER HAZARDS BOULDER
				elseif(zone[i][j] == 7 and missedDeployZone==false) then
					local hazardObsticle = display.newSprite( imageSheet, animationSequenceData )
					hazardObsticle:setSequence( "outcrop4" )
					hazardObsticle:play()
					--hazardObsticle.xScale = -1.0
					hazardObsticle.destroy = false
					hazardObsticle.x = j*(_MW/(zoneTableWidth+1))--(j*32)
					hazardObsticle.y = (i*51.5) + _MH + (-hero_Group.y)
					hazardObsticle.myName = "hazard"
					hazardObsticle.isSensor = true
					physics.addBody( hazardObsticle, physicsData:get("Object-Outcrop6@2x") ) --Note the Collision Material is defined in the external Data file
					hero_Group:insert(hazardObsticle)
					hazardObsticle:toBack()
				
				--Setup the SLOW MOTION BONUS
				elseif(zone[i][j] == 8 and missedDeployZone==false) then
					local slowMotionItem = display.newSprite( imageSheet, animationSequenceData )
					slowMotionItem:setSequence( "slowMotionBonus" )
					slowMotionItem:play()
					--slowMotionItem.xScale = -1.0
					slowMotionItem.destroy = false
					slowMotionItem.x = j*(_MW/(zoneTableWidth+1))--(j*32)
					slowMotionItem.y = (i*51.5) + _MH + (-hero_Group.y)
					slowMotionItem.myName = "slowMotion"
					slowMotionItem.isSensor = true
					local collectItemMaterial = { density=3.0, friction=0.0, bounce=0.0, filter=collectItemsFilterData, radius=12 }
					physics.addBody( slowMotionItem, collectItemMaterial )
					hero_Group:insert(slowMotionItem)
					slowMotionItem:toBack()


				--Deploy Parachute ZONE !
				elseif(zone[i][j] == 100) then
				
					deployZoneOnScreen = true
					parachuteZone = display.newRect(0, 0, _MW, parachuteZoneHeight)
					parachuteZone:setFillColor(255,0,0)
					
					parachuteZone.anchorX = 0.0	-- Graphics 2.0 Anchoring method
					parachuteZone.anchorY = 0.5	-- Graphics 2.0 Anchoring method
					
					parachuteZone.y = (i*51.5) + _MH + (-hero_Group.y)
					parachuteZone.alpha = 0.2

					parachuteZone.myName = "parachuteZone"
					parachuteZone.isSensor = true
					local parachuteMaterial = { density=3.0, friction=0.0, bounce=0.0, filter=parachuteZoneFilterData }
					physics.addBody( parachuteZone, parachuteMaterial )

					hero_Group:insert(parachuteZone)
					parachuteZone:toBack()
				
					-- We'll attach a TOUCH listener to the deployment zone.
					-- We'll further check to see if our [ inDeployZone ] variable is true
					-- If it is, and the user taps - we'll unleash the parachute to save our heros NECK !
					parachuteZone:addEventListener( "touch", deployParachuteTest)
				
					--Add a Border to the Zone area
					local parachuteZoneBorder = display.newRect(-10, 0, _MW+10, 4)
					parachuteZoneBorder:setFillColor(4,124,217)
					
					parachuteZoneBorder.anchorX = 0.0	-- Graphics 2.0 Anchoring method
					parachuteZoneBorder.anchorY = 0.5	-- Graphics 2.0 Anchoring method
					
					parachuteZoneBorder.y = (parachuteZone.y-parachuteZone.height/2)-2
					parachuteZoneBorder.alpha = 0.8
					hero_Group:insert(parachuteZoneBorder)
					parachuteZoneBorder:toBack()
				
					local parachuteZoneBorder = display.newRect(-10, 0, _MW+10, 4)
					parachuteZoneBorder:setFillColor(4,124,217)
					parachuteZoneBorder.anchorX = 0.0	-- Graphics 2.0 Anchoring method
					parachuteZoneBorder.anchorY = 0.5	-- Graphics 2.0 Anchoring method
					parachuteZoneBorder.y = (parachuteZone.y+parachuteZone.height/2)+2
					parachuteZoneBorder.alpha = 0.8
					hero_Group:insert(parachuteZoneBorder)
					parachuteZoneBorder:toBack()
				
				--THE TUTORIAL OBJECTS
				--HELP - Collect the Coins
				elseif(zone[i][j] == 55 ) then
			
					local function hideInfo()
						transition.to(infoCollectItems, { time=400, alpha=0.0 } )
					end
				
					infoCollectItems.alpha = 1.0
					timer.performWithDelay( 1200, hideInfo )
				
				--HELP - Avoid Hazards
				elseif(zone[i][j] == 77 ) then
			
					local function hideInfo()
						transition.to(infoAvoidHazards, { time=400, alpha=0.0 } )
					end
				
					infoAvoidHazards.alpha = 1.0
					timer.performWithDelay( 1200, hideInfo )
				
				--HELP - Release Parachute
				elseif(zone[i][j] == 88 ) then
			
					local function hideInfo()
						transition.to(infoParachuteZone, { time=400, alpha=0.0 } )
					end
				
					infoParachuteZone.alpha = 1.0
					timer.performWithDelay( 1200, hideInfo )

				
				end	





			end
		end
	end

end


function pauseWindowShow()
	if (gameOverBool==false) then

		if (gameIsPaused==false) then
			gameIsPaused = true
			
			--Cancel transitions (if necessary)
			if resetHeroPosition then
				transition.cancel( resetHeroPosition )
				resetHeroPosition = nil
			end
			
			--transition.cancel(resetHeroPosition)
	
			if (parachuteOut==true and scrollStart==false) then
				ourHero:applyForce( 0, -floatDownSpeed, ourHero.x, ourHero.y )
			end
			
			local options = { effect = "slideDown", time = 200,
			params ={ collectCoins=coinsCollected, collectBonus=bonusCollected,
			collectScore=gameScore, collectHighscore=highScore,} }

			storyboard.showOverlay("overlayPause", options )	--This is our Pause Screen

		else

			gameIsPaused = false
			storyboard.hideOverlay("overlayPause")

			if (parachuteOut==true and scrollStart==false) then
				ourHero:applyForce( 0, floatDownSpeed, ourHero.x, ourHero.y )
			end
	
			if ( ourHero.x ~= _W and gameOverBool == false) then
				resetHeroPosition = transition.to(ourHero, { time=resetSpeed, x = _W } )
			end

		end
		
	end	
end

function startHeroSequence()
	
	if (gameStart==false and gameOverBool==false) then
		
		gameStart = true

	
		ourHero:setSequence( "flipAnimation" )
		ourHero:play()

		audio.play(sfxLeap, {channel=1})

		--Force our Hero to the centre X position
		resetHeroPosition = transition.to(ourHero, { time=resetSpeed, x = _W } )
	
		local function startAction()
	
			ourHero:setSequence( "diveAnimation" )
			ourHero:play()
		
			print(ourHero.y)
			scrollStart = true
			controlPlayerStart = true
			
			--Hide/Show the Tutorial Details - 
			if (level==1 and showTutorial==true) then
				
				local function hideInfoRightTap()
					transition.to(infoRightPanel, { time=400, alpha=0.0 } )
					transition.to(infoRightPanelText, { time=400, alpha=0.0 } )
				end

				local function showInfoRightTap()
					transition.to(infoRightPanel, { time=400, alpha=0.6, onComplete=function() timer.performWithDelay( 1200, hideInfoRightTap ) end })
					transition.to(infoRightPanelText, { time=400, alpha=1.0 } )
				end
			
			
				local function hideInfoLeftTap()
					transition.to(infoLeftPanel, { time=400, alpha=0.0, onComplete=function() timer.performWithDelay( 500, showInfoRightTap ) end })
					transition.to(infoLeftPanelText, { time=400, alpha=0.0 } )
				end
				
				
				--Show Tap Left Info - and start the tutorial sequence.....
				transition.to(infoLeftPanel, { time=400, alpha=0.6, onComplete=function() timer.performWithDelay( 1200, hideInfoLeftTap ) end })
				transition.to(infoLeftPanelText, { time=400, alpha=1.0 } )
				
			end
			
			--Hide the TAP TO START text....
			transition.to(infoTapScreenStart, { time=400, alpha = 0.0 } )

			
			--Move the HUD onto the screen (Scores, Pause etc)
			transition.to(hud_Group, { time=500, y = 0 } )

		end
	
		local function dropDown()
			transition.to(ourHero, { time=400, y = ourHero.y + 50, onComplete=startAction } )
			transition.to(ourHero, { time=200, xScale = 1.0, yScale = 1.0 } )
			transition.to(cliff_Group, { time=300, x = 0, y = cliff_Group.y - 110 } )
			transition.to(cliff_Group, { time=300, xScale = 1.0, yScale = 1.0 } )
		end
		--Jump Up
		transition.to(ourHero, { time=600, y = ourHero.y - 110, onComplete=dropDown } )
		transition.to(ourHero, { time=200, xScale = 1.3, yScale = 1.3 } )
		transition.to(cliff_Group, { time=200, x = 30, y = cliff_Group.y + 120 } )
		transition.to(cliff_Group, { time=200, xScale = 0.8, yScale = 0.8 } )
		
	
	end
	
end

function cancelPlayerReset()
	if ( ourHero.x ~= _W and gameOverBool==false) then
		--transition.cancel(resetHeroPosition)
		
			--Cancel transitions (if necessary)
			if resetHeroPosition then
				transition.cancel( resetHeroPosition )
				resetHeroPosition = nil
			end


	end
end

function cancelGameTimersandEvents()

		print("All Cancel")
		gameOverBool = true
		
		if transitionDarkenBG then
			transition.cancel( transitionDarkenBG )
			transitionDarkenBG = nil
		end
		
		if ( parachuteOut==true ) then
		
			--Cancel transitions (if necessary)
			if transitionArrowBack then
				transition.cancel( transitionArrowBack )
				transitionArrowBack = nil
			end

			if transitionArrowUp then
				transition.cancel( transitionArrowUp )
				transitionArrowUp = nil
			end
		
			--transition.cancel(transitionArrowBack)
			--transition.cancel(transitionArrowUp)
		end
		
		if ( parachuteOut==true and landMoving==true) then
		
			--Cancel transitions (if necessary)
			if transitionBaseBack then
				transition.cancel( transitionBaseBack )
				transitionBaseBack = nil
			end

			if transitionBaseForward then
				transition.cancel( transitionBaseForward )
				transitionBaseForward = nil
			end


			if transitionSlowmoZoom then
				transition.cancel( transitionSlowmoZoom )
				transitionSlowmoZoom = nil
			end

		
			--transition.cancel(transitionBaseBack)
			--transition.cancel(transitionBaseForward)
		end
		
		if ( levelFailed==true) then
			storyboard.hideOverlay("overlayFailed")
			
			--transition.cancel(angelAnimationTransition)
		end
				
		physics.stop()

	
end


-----------------------------------------------------------------
-- Background touch for movement & start
-----------------------------------------------------------------
function skyTouchStart(event)
	if (gameOverBool==false and gameIsPaused == false) then

		if (event.phase == 'began') then
	

			if (gameStart == true and controlPlayerStart==true) then
				if (gameOverBool == false) then
					if (event.x < _W ) then
						print("LEFT: "..event.x)
				
						moveLeft = true
				
						if (parachuteOut==false) then
							ourHero:setSequence( "leftAnimation" )
							ourHero:play()
						elseif ( parachuteOut==true and parachauteAnim==true) then
							ourHero:setSequence( "chuteLeftAnimation" )
							ourHero:play()
						end
						cancelPlayerReset()

					else
						print("RIGHT: "..event.x)
				
						moveRight = true
						if (parachuteOut==false) then
							ourHero:setSequence( "rightAnimation" )
							ourHero:play()
						elseif ( parachuteOut==true and parachauteAnim==true) then
							ourHero:setSequence( "chuteRightAnimation" )
							ourHero:play()
						end
						cancelPlayerReset()
					end
				end
			end
		
		elseif (event.phase == 'ended') then
		
			--if (gameStart == true and controlPlayerStart==true) then

				moveLeft = false
				moveRight = false
		
				-- If our Hero is not in the centre, then move the player back to the middle
				-- Note we assign the transition to a variable, so we can cancel it at any time
				if ( ourHero.x ~= _W and gameOverBool == false) then
					resetHeroPosition = transition.to(ourHero, { time=resetSpeed, x = _W } )
				end

				if (gameStart == true and controlPlayerStart==true and gameOverBool == false) then
					if ( parachuteOut==false and parachauteAnim==false) then
						ourHero:setSequence( "diveAnimation" )
						ourHero:play()
						print("DIVE")
					elseif ( parachuteOut==true and parachauteAnim==true) then
						--ourHero:setSequence( "chuteNormalAnimation" )
						--ourHero:play()
					end
				end
				--see if this is the first touch to start the game?
				if (gameStart == false and gameOverBool==false) then
					print("Start Sequence")
					startHeroSequence()
				end
			--end
		
		end
		
	end	
	
end



-----------------------------------------------------------------
-- Update the score function
-----------------------------------------------------------------
local function updateTheScore(pointsValue)
		--Add to our Score!
		gameScore = gameScore + pointsValue
		if (gameScore > highScore) then
			highScore = gameScore		-- Set the Global High Score variable to the new value
		end
		
		-----------------------------------------------------------------
		-- Update Score on the screen
		-----------------------------------------------------------------
		myScoreText.text = "Score: "..gameScore
		--myScoreText:setReferencePoint(display.CenterLeftReferencePoint);
		myScoreText.anchorX = 0.0		-- Graphics 2.0 Anchoring method
		myScoreText.anchorY = 0.5		-- Graphics 2.0 Anchoring method

		myScoreText.x = 20

		-----------------------------------------------------------------
		-- Update the HighScore text on the screen
		-----------------------------------------------------------------
		myHighScoreText.text = "Highscore: "..highScore
		--myHighScoreText:setReferencePoint(display.CenterLeftReferencePoint);
		myHighScoreText.anchorX = 0.0		-- Graphics 2.0 Anchoring method
		myHighScoreText.anchorY = 0.5		-- Graphics 2.0 Anchoring method

		myHighScoreText.x = 130
end


-----------------------------------------------------------------
-- Test to see if the user is in and touched the deployment zone!
-----------------------------------------------------------------
function deployParachuteTest(event)

	if (event.phase == 'began' and inDeployZone == true and parachuteOut==false) then
	
		print("---------- DEPLOY THE PARACHUTE MAN!----------------")
		parachuteOut = true
		missedDeployZone = false
		
		ourHero:setSequence( "chuteOpenAnimation" )
		ourHero:play()
		
		local function setParachuteOutBoolean()
			parachauteAnim = true
			print("---------- YAY !!!!----------------")
			
			audio.play(sfxCollect4)

		end

		timer.performWithDelay(400, setParachuteOutBoolean ) --Very important! we need the chute opening animation to complete 1st!

		-- Slow the scroll speed down when the Parachute is deployed.
		scrollSpeed = scrollParachuteSpeed
		
		cliffMid1.y = cliffMid1.y - scrollSpeed
		cliffMid2.y = cliffMid2.y - scrollSpeed
		cliffMid3.y = cliffMid3.y - scrollSpeed

		--transition.to(ourHero, { time=1200, y=ourHero.y+130 } )
		--transition.to(heroParachute, { time=1200, y=heroParachute.y+130 } )		
		
	elseif (event.phase == 'ended') then
	
	end
	
end


function cancelParachuteZone()
	if (parachuteOut == false) then
		inDeployZone = false
		missedDeployZone = true
		scrollSpeed = scrollSpeedDie
	end
end

function ParachuteZonePassedReset()
	inDeployZone = false
end


function saveLevelData()

	--SAVE the highScore to the users device!
	saveDataTable.highScore = highScore
	loadsave.saveTable(saveDataTable, "grannydivedata.json")

	if (levelCompleted == true) then
		-- Here we increment the 'next' level counter to the CURRENT LEVEL + 1.
		-- if it's not greater than the MAX LEVELS, we load the value to the next level variable.
		
		-----------------------------------------------------------------------------
		--NEW Version 1.2 : Fix for updating next levels/unlocked function...
		-----------------------------------------------------------------------------
		local getCurrentLevelPositionFromFile = saveDataTable.levelReached
		
		-- Check if the currently played level is greater than the one saved to file.
		if (  (level + 1) > getCurrentLevelPositionFromFile  ) then
			
			--Increment The level counter if the user has passed a higher level than is currently saved in the JSON file.
			nextLevel = level + 1

			-- Save the data to the users device
			saveDataTable.levelReached = nextLevel
			saveDataTable.gameCompleted = false
			loadsave.saveTable(saveDataTable, "grannydivedata.json")
		end
		-----------------------------------------------------------------------------
		
		-----------------------------------------------------------------------------
		-- Has the user completed every single level?
		-----------------------------------------------------------------------------
		if (nextLevel > maxLevels) then
			allLevelsWon = true
			level 		= maxLevels
			nextLevel 	= maxLevels
		
			--SAVE the level data to the users device!
			saveDataTable.levelReached = nextLevel
			saveDataTable.gameCompleted = true
			loadsave.saveTable(saveDataTable, "grannydivedata.json")
		end
		-----------------------------------------------------------------------------
		
	end	
	
end




-----------------------------------------------------------------
-- Hit test for Rectangular Shapes
-----------------------------------------------------------------
function endScrolling()
	
	print("END")
	scrollStart = false
	--gameOverBool = true
	
	--baseGroup.y = 0
	transition.to(baseGroup, { time=200, y=0 } )
	
	-- Update our Hero's Physic attributes
	-- Remove old content and add new area of collision
	ourHero.isSensor = false
	local result = physics.removeBody( ourHero )
	local heroArea = { -20,-30, 20,-30, 20,55, -20,55 }
	local heroMaterial = { density=10.0, friction=0.0, bounce=0.0, filter=heroFilterData, shape=heroArea }
	physics.addBody( ourHero, heroMaterial )
	ourHero.isFixedRotation = true

	fixScrollingBackground()
	
	--hero_Group.y = 0
		
	ourHero.y = heroLastY
	baseGroup:insert( ourHero )

	--print(ourHero.y)
	
	finalScene = true
	--cliffBase.x = _W
	--cliffBase.y = _H-10
	
	--Hide the Clouds
	transition.to(cloud1, { time=600, alpha=0.0 } )
	transition.to(cloud2, { time=600, alpha=0.0 } )
	transition.to(cloud3, { time=600, alpha=0.0 } )

	transition.to(cloud1, { time=600, y = -(_MH+100)} )
	transition.to(cloud2, { time=800, y = -(_MH+100)} )
	transition.to(cloud3, { time=1200, y = -(_MH+100)} )
		
	local function endAnimationHappy()
		--ourHero:setSequence( "parachuteCloseAnimation" )
		--ourHero:play()
		--transition.to(heroParachute, { time=800, alpha=0.0 } )		
		--ourHero:setSequence( "flipAnimation2" )
		--ourHero:play()
		--transition.to( levelComplete_Group, { delay=400, time=700, y=0 } )
	end
	
	local function endAnimationBad()
		--ourHero:setSequence( "flipAnimation2" )
		--ourHero:play()
	end
	
	if (parachuteOut == true) then
		print("Slow Descend")
		
		--Show the Landing Arrow animation.
		transition.to(guideArrow, { time=300, alpha = 1.0 } )
		
		if (level==1 and showTutorial==true) then
			local function hideInfo()
				transition.to(infoLanding, { time=400, alpha=0.0 } )
			end
			
			infoLanding.alpha = 1.0
			timer.performWithDelay( 1200, hideInfo )
		end


		--Start the Guide Arrow animating/moving
		animateTheGuideArrow()
		
		-- If this level has a moving target base, set it in motion now
		if (landMoving == true) then
			animateTheTargetBase()
		end
		
		--Push our hero DOWN
		ourHero:applyForce( 0, floatDownSpeed, ourHero.x, ourHero.y )
		--transition.to(ourHero, { time=1200, y=ourHero.y+310 } )
		--transition.to(heroParachute, { time=1200, y=heroParachute.y+210, onComplete=endAnimationHappy } )
		
	else
		print("OMG!")
		
		--Remove any coins etc from the screen
		removeScenery()
		
		landTarget:removeSelf()
		guideArrow:removeSelf()
		
		local result = physics.removeBody( ourHero )
		local heroArea = { -20,-20, 20,-20, 20,25, -20,25 }
		local heroMaterial = { density=10.0, friction=0.0, bounce=0.0, filter=heroFilterData, shape=heroArea }
		physics.addBody( ourHero, heroMaterial )

		ourHero:applyForce( 0, floatDownSpeed*6, ourHero.x, ourHero.y )
		--LevelFailedFunctionStart()
		--transition.to(ourHero, { time=1200, y=ourHero.y+210, onComplete=endAnimationBad } )
	end
			
	--transition.to(cliffBase, { time=200, y = _H-scrollSpeed, x = _W } )
end



function removeScenery()

	print("Cleaning up scenery")
	
	-- Here we go through all the sprites in the group and REMOVE
	-- Collectables from the screen - if were on our way to dying!
	for i = hero_Group.numChildren,1, -1 do
	
	  local child = hero_Group[i]
	  local description = (child.myName)
	  if (description=="collectItem" or description=="hazard" or description=="collectItemBonus" or description=="slowMotion") then
	 	--print("child["..i.."]")
	  	child:removeSelf()
	  	child = nil
	  end

	end

end




function animateTheGuideArrow()
 
	if (gameOverBool==false) then
		function moveback()
		  transitionArrowBack =  transition.to(guideArrow, {time=600, y = (cliffBase.y - (cliffBase.height/2) - 50), onComplete = moveUp})
		end
 
		function moveUp() 
		   transitionArrowUp = transition.to(guideArrow, {time=600,y = 320, onComplete = moveback})
		end
	
		moveUp()
 	end
end

function animateTheTargetBase()
 
	if (gameOverBool==false ) then
		function moveBaseBack()
		  transitionBaseBack =  transition.to(landTarget, {time=landMovingSpeed, x=landMinX, onComplete = moveTargetBase})
		end
 
		function moveTargetBase()
		   transitionBaseForward = transition.to(landTarget, {time=landMovingSpeed, x=landMaxX, onComplete = moveBaseBack})
		end
	
		moveTargetBase()
 	end
end




function goSlowMotion()
	
	audio.pause(musicGame)
	audio.play(musicSlowMotion, {channel=3,loops=0})
	slowMotionZoomScale = 2.5
	
	slowMotionActivated = true
	local originalScrollSpeed = scrollSpeed
	scrollSpeed = slowMotionSpeed
	
	--Update the Background Y Positions
	--fixScrollingBackground()

	--transitionSlowmoZoom = transition.to( cliff_Group, { time=400, x=-(_w/2), xScale = 2.5, yScale = 2.5})
	transitionSlowmoZoom = transition.to( cliff_Group, { time=400, x=-_w/2, xScale = slowMotionZoomScale, yScale = slowMotionZoomScale})
	transitionDarkenBG = transition.to( slowMotionOverlay, { time=300, alpha=0.6})
	
	local function resetSpeed()
	

		local function updateZoomScale()
			slowMotionZoomScale = 1

			--Update the Background Y Positions
			--fixScrollingBackground()
		end
				
		slowMotionActivated = false
		scrollSpeed = originalScrollSpeed
		
		audio.resume(musicGame)
		--audio.stop(musicSlowMotion)
		audio.rewind(musicSlowMotion)
		
		transitionSlowmoZoom = transition.to( cliff_Group, { time=400, x=0, xScale = 1.0, yScale = 1.0, onComplete=updateZoomScale})
		transitionDarkenBG = transition.to( slowMotionOverlay, { time=300, alpha=0.0})

	end
	
	slowMotionTimer = timer.performWithDelay((slowMotionTime*1000), resetSpeed )
	
end


local function removeAfterDelay(object)
	object:removeSelf()
	object = nil
end

-- Because we keep slowing down and speeding up the scrolling background
-- The Y positions can sometimes go slightly out leaving a GAP in-between the cliffs
-- When we SLOW down or SPEED up we'll call this function to fit everything back together again.
function fixScrollingBackground()

	-- fixed the core code not to need this...

end


-----------------------------------------------------------------
-- Test to see if the OBJECTS have hit our Here - and pefrom
-- various triggers based on results (BEAR, ROCKS, FISH) etc.
-----------------------------------------------------------------
function gameGlobalCollision(event)
	
	--print (event.phase)
	--Only test this condition if the GameOver flag has not been set to TRUE
	if ( event.phase == "began" and gameOverBool==false) then
	
		--print( "Global report: " .. event.object1.myName .. " & " .. event.object2.myName .. " collision began" )
		
		if (event.object1.myName == "wall" and event.object2.myName == "collectItem") then
			timer.performWithDelay(100, removeAfterDelay(event.object2) )
		end

		if (event.object1.myName == "wall" and event.object2.myName == "hazard") then
			timer.performWithDelay(100, removeAfterDelay(event.object2) )
		end
		
		-- Update the Score and delete the object
		-- We also mark the item as collected (destroyed) so as not to accidentally collect multiple points!
		if (event.object1.myName == "hero" and event.object2.myName == "collectItem" and event.object2.destroy==false) then
			event.object2.destroy = true
			--print("Collected")
			--event.object2:setSequence( "itemCollected" )
			--event.object2.alpha=0.8
			--event.object2:play()
			--event.object2:toFront()
			updateTheScore(coinValue) -- We send the value of the points to the function to handle the addition
			coinsCollected = coinsCollected + 1
			audio.play(sfxCollect3)
			timer.performWithDelay(400, removeAfterDelay(event.object2) )
		end

		if (event.object1.myName == "hero" and event.object2.myName == "collectItemBonus" and event.object2.destroy==false) then
			event.object2.destroy = true
			updateTheScore(bonusValue) -- We send the value of the points to the function to handle the addition
			bonusCollected = bonusCollected + 1
			audio.play(sfxCollect2)
			timer.performWithDelay(400, removeAfterDelay(event.object2) )
		end

		if (event.object1.myName == "hero" and event.object2.myName == "slowMotion" and event.object2.destroy==false and slowMotionActivated==false) then
			event.object2.destroy = true
			--updateTheScore(bonusValue) -- We send the value of the points to the function to handle the addition
			--bonusCollected = bonusCollected + 1
			if (slowMotionActivated==false)  then -- only do this if the user is NOT ALREADY in Slow-motion!
				slowMotionActivated = true
				goSlowMotion()
				updateTheScore(slowMotionValue) -- We send the value of the points to the function to handle the addition
				audio.play(sfxCollect1)
				timer.performWithDelay(400, removeAfterDelay(event.object2) )
			end
		end



		-- See if the Hero is in the Parachute Deploy Zone
		if (event.object1.myName == "hero" and event.object2.myName == "parachuteZone") then
			print("IN THE DEPLOY ZONE")
			inDeployZone = true
		end
		
		-- See if the user failed to Deploy the Parachute at the correct time!
		if (event.object1.myName == "wall" and event.object2.myName == "parachuteZone" and parachuteOut == false) then
			print("TIME TO DIE FAST!!!!")
			--missedDeployZone = true
			--scrollSpeed = scrollSpeedDie
			timer.performWithDelay(200, cancelParachuteZone )
			--print(scrollSpeed)
			
			fixScrollingBackground()
		end
		
		-- OOPS ! You hit an Obstacle - Time to die my friend.... :-(
		if (event.object1.myName == "hero" and event.object2.myName == "hazard" and triggerGameOver==false) then
			print("HIT AN OBSTACLE - TIME TO DIE !!!!")
			audio.play(sfxHitObject)
			triggerGameOver = true
			--timer.performWithDelay(100, LevelFailedFunctionStart )
		end
		
		-- OOPS ! You hit the FLOOR !!
		if (event.object1.myName == "dieZone" and event.object2.myName == "hero" and triggerGameOver==false) then
			print("HIT THE FLOOR - TIME TO DIE !!!!")
			--gameOverBool = true
			audio.play(sfxHitFloor)
			--triggerGameOver = true
			timer.performWithDelay(10, LevelFailedFunctionStart )
		end

		-- WE WIN! You landed on the safe zone platform!
		if (event.object1.myName == "landTarget" and event.object2.myName == "hero" ) then
			print("We WIN")
			audio.play(sfxLand)
			timer.performWithDelay(100, levelCompletedFunctionStart )
		end



	end
	
	if ( event.phase == "ended" and gameOverBool==false) then
		
		if (triggerGameOver==true) then
			--LevelFailedFunctionStart()
			timer.performWithDelay(10, LevelFailedFunctionStart )

		end
		-- See if the Hero was in the DEPLOY ZONE... Now they've Past this point
		-- We'll reset the variable
		
		
		--if (inDeployZone == true) then
		--	print("Deploy Zone PAST")
		--	timer.performWithDelay(200, ParachuteZonePassedReset )
		
		
			--inDeployZone = false
		--end
	
	end

		
end



-----------------------------------------------------------------
-- The GAME MANAGER monitors the various conditions and checks for movement etc:
-----------------------------------------------------------------
function updateTick()

	if (gameIsPaused==false) then
	
		-- Track the landing Arrow to the X position of the target base IF this level has a MOVING target base.
		if (gameOverBool==false and parachuteOut==true and landMoving==true ) then
			guideArrow.x = landTarget.x
		end
		
		-- Manage the Scrolling Clouds (Each clouds moves LEFT or RIGHT) and vertically
		-- Also, when the clouds go OFF SCREEN, we reset their X position to start over...
		-- HORIZONTAL (X) Scrolling system
		if (gameOverBool==false) then
	
			--heroParachute.x = ourHero.x

			cloud1.x = cloud1.x - (cloudXScrollSpeed*1)
		
			if (cloud1.x < 0-(cloud1.width)) then
				cloud1.x = _MW+(cloud1.width/2)
				cloud1.y = math.random(-20,_MH)
			end

			cloud2.x = cloud2.x + (cloudXScrollSpeed*1.5)
			if (cloud2.x > _MW+(cloud2.width/2)) then
				cloud2.x = 0-(cloud2.width/2)
				cloud2.y = math.random(-20,_MH)
			end
	
			cloud3.x = cloud3.x - (cloudXScrollSpeed*0.5)
			if (cloud3.x < 0-(cloud3.width)) then
				cloud3.x = _MW+(cloud3.width/2)
				cloud3.y = math.random(-20,_MH)
			end

			if (moveLeft==true) then
				if (ourHero.x > (ourHero.width/2) ) then
					ourHero.x = ourHero.x - tiltSpeed
				end
			end
		
			if (moveRight==true) then
				if (ourHero.x < (_MW-(ourHero.width/2)) ) then
					ourHero.x = ourHero.x + tiltSpeed
				end
			end

		end

		if (scrollStart==true and gameOverBool==false) then

			hero_Group.y = hero_Group.y - (scrollSpeed+collectItemScrollSpeed)
		
			--Force our hero and kill Wall on the correct Y positions
			if (parachuteOut == true) then
				ourHero.y = -hero_Group.y + 130
				--heroParachute.y = ourHero.y-90
			else
				ourHero.y= -hero_Group.y + 100
			end
		
			worldWall.y = -hero_Group.y - 60 -- NOTE: We draw the boundary wall outside of the screen - so as to destroy objects OFF SCREEN!
			
				if (cliffMid1.y - cliffMid1.contentHeight) < -680*slowMotionZoomScale then
					scrollCount = scrollCount + 1
					cliffMid1:translate( 0,480*3 )
				end
				if (cliffMid2.y - cliffMid2.contentHeight) < -680*slowMotionZoomScale then
					cliffMid2:translate( 0,480*3 )
				end
				if (cliffMid3.y - cliffMid3.contentHeight) < -680*slowMotionZoomScale then
					cliffMid3:translate( 0,480*3 )
				end

				--If we are at the end, stop the scrolling procedures
				--Grab the Heros Y position !
				if (scrollCount == scrollHeight) then
					if (parachuteOut == true) then
						heroLastY = 130
					else
						heroLastY = 100
					end
					--timer.performWithDelay(600, endScrolling )
					endScrolling()
				end

				if (scrollZones[scrollCount+1]==false and stopObjectSpawns ==false) then
				--if (scrollZones[scrollCount+1]==false) then
					--print("--------------------Creating Zone: "..scrollCount+1)
					scrollZones[scrollCount+1] = true
					buildZone(zones[scrollCount+1])
				end
		
			-----------------------------------------------------------------
			-- Scroll the background
			-----------------------------------------------------------------
			if (scrollCount < scrollHeight) then
				cliffTop.y = cliffTop.y - scrollSpeed
				cliffMid1.y = cliffMid1.y - scrollSpeed
				cliffMid2.y = cliffMid2.y - scrollSpeed
				cliffMid3.y = cliffMid3.y - scrollSpeed

				-- Check if the user MISSED the deploy zone. If they did we need to compensate the scrolling Y position
				-- quickly, to ensue we reduce any 'gaps' between the scenery joins.
				if (missedDeployZone == true) then
					print("Oh dear!")
					
					audio.play(sfxScream, {channel=1})

					stopObjectSpawns = true
					baseGroup.y = baseGroup.y + scrollSpeedDie
					cliffMid1.y = cliffMid1.y + scrollSpeedDie
					cliffMid2.y = cliffMid2.y + scrollSpeedDie
					cliffMid3.y = cliffMid3.y + scrollSpeedDie
					
					missedDeployZone = false
				end

				--If were in the LAST ZONE, start moving the end BASE graphics on the screen
				if (scrollCount == (scrollHeight-1)) then
					baseGroup.y = baseGroup.y - scrollSpeed
				end
			
			end
		
			-- VERTICAL (Y) Scrolling system
			-- Note we'll simply scroll the GROUP LAYER as a whole and control accordingly
			if (scrollCount ~= scrollHeight) then
				cloud_Group.y = cloud_Group.y - (scrollSpeed+1.7)
				if (cloud_Group.y < -_MH ) then
					cloud_Group.y = _MH
				end
			end
		
		
		
		end

	end
end


--Level completed/Win code/functions
function levelCompletedFunctionEnd()

end 

function showWellDoneWindow()

end

function showFailedWindow()

end

--Level completed/Win code/functions
function levelCompletedFunctionStart()
	
	-- We check the GameOver flag here again, so as not to
	-- perform the GameOver functions more then once.
	if (gameOverBool == false) then
		cancelPlayerReset()
	
		gameOverBool = true
		levelCompleted = true
	
		moveLeft = false
		moveRight = false
	
		--Stop the base moving if it's been configured to move
		if (landMoving==true) then
		
			-- Move the Arrow and TARGET to the centre X point of the Hero (for neatness!)
			transition.to(landTarget, { time=50, x=ourHero.x} )
			transition.to(guideArrow, { time=50, x=ourHero.x} )

			--Cancel transitions (if necessary)
			if transitionBaseBack then
				transition.cancel( transitionBaseBack )
				transitionBaseBack = nil
			end

			if transitionBaseForward then
				transition.cancel( transitionBaseForward )
				transitionBaseForward = nil
			end
		
			--transition.cancel(transitionBaseBack)
			--transition.cancel(transitionBaseForward)
		end
	
		print ("CONGRATULATIONS! - LEVEL COMPLETED...")
	
		--Save the users data - and update the LEVEL COUNTER
		saveLevelData()
	
		ourHero:setSequence( "chutecloseAnimation" )
		ourHero:play()
	
		local result = physics.removeBody( ourHero )
	
		local function backToStandingAnimation()
			ourHero:setSequence( "standingAnimation" )
			ourHero:play()
			
			audio.stop()
			audio.play(musicWin, {channel=2,loops = -1})

			--Now show the Signs and Options
			--showBackHomeSignTimer 	= timer.performWithDelay(10, showBackHomeSign )
			--showNextLevelSignTimer 	= timer.performWithDelay(100, showNextLevelSign )
			showWellDoneWindowTimer	= timer.performWithDelay(200, showWellDoneWindow )
			
			--Which level completed screen to show?
			if (level == maxLevels) then
			
				-- Show the you have completed the WHOLE GAME screen..
				local function levelCompletedScreenShow()

					local options = { effect = "slideDown", time = 200,
						params ={ collectCoins=coinsCollected, collectBonus=bonusCollected,
						collectScore=gameScore, collectHighscore=highScore,} }
						storyboard.showOverlay("overlayCompleted", options )	--This is our Game Completed Screen
				end
				timer.performWithDelay(300, levelCompletedScreenShow )
				
			else
			
				-- or.... show the level completed screen
				local function levelWinScreenShow()
			
					local options = { effect = "slideDown", time = 200,
						params ={ collectCoins=coinsCollected, collectBonus=bonusCollected,
						collectScore=gameScore, collectHighscore=highScore,} }
						storyboard.showOverlay("overlayWin", options )	--This is our Level Won
				end
				timer.performWithDelay(300, levelWinScreenShow )
			
			end
			

		end

		local function celebrateFlipAnimation()
			ourHero:setSequence( "flipAnimation3" )
			ourHero:play()
			heroStandingTimer = timer.performWithDelay(450, backToStandingAnimation )
		
			--transition.to( ourHero, { time=100, y=(ourHero.y+5) } )
		
			local finalYPosition = ((landTarget.y-(landTarget.height/2))-(ourHero.height/2)) - 5
			transition.to( ourHero, { time=100, y=finalYPosition})

		end

	
		timer.performWithDelay(100, celebrateFlipAnimation )

	end
end 



function doGameCompleted()

end 


local function endMusic()
	--transition.to( youLoose_Group, { y = 0, time=400} )
end

function spawnAngelAnimation()
	print("Show Angel")
	local angleImage = display.newSprite( imageSheet, animationSequenceData )
	angleImage:setSequence( "angelAnimation" )
	angleImage:play()
	angleImage.y = ourHero.y
	angleImage.x = ourHero.x
	angleImage.alpha = 1.0
	angleImage.myName = "angleImage"
	hud_Group:insert( angleImage )
	angleImage:toFront()
	angelAnimationTransition = transition.to(angleImage, { time=3200, alpha = 0.5, y = -50 } )
end

-----------------------------------------------------------------
-- Game Over functions
-----------------------------------------------------------------
function LevelFailedFunctionStart()

	if (gameOverBool==false) then
		cancelPlayerReset()
	
		gameOverBool = true
		levelFailed = true
		moveLeft = false
		moveRight = false

		--Stop the MAIN MUSIC CHANNEL
		audio.stop(2)
	
		--Stop the SlowMotion Music if playing
		audio.stop(3)
	
		--Play the Crash music
		audio.play(musicCrash, {channel=2,loops = -1})

		print ("FAILED! - GAME OVER")
	
		--Hide the Landing Arrow animation.
		transition.to(guideArrow, { time=600, alpha = 0.0 } )
	
		--Save the users data - and update the LEVEL COUNTER
		saveLevelData()
		
		--Show the game over window and options etc
		--showBackHomeSign()
	
		ourHero:setSequence( "crashAnimation" )
		ourHero:play()
	
		--Spawn a little angle to float up the screen!
		if (scrollStart == false) then
			spawnAngelAnimation()
		end
	
		if (slowMotionActivated == true) then
			slowMotionActivated = false
			transitionSlowmoZoom = transition.to( cliff_Group, { time=400, x=0, xScale = 1.0, yScale = 1.0})
		end
	
		--if (ourHero.physics) then
			local result = physics.removeBody( ourHero )
		--end
	
		if (parachuteOut == true) then
			transition.to(ourHero, { time=100, y=ourHero.y+35 } ) --Missed the landing target - fix hero's final Y Crash Position
		else
			transition.to(ourHero, { time=100, y=ourHero.y+10 } ) --Did not deploy Parachute - fix hero's final Y Crash Position
		end
	
		if ( slowMotionActivated==true ) then
		print ("Cancelling Slow mo timer")
			timer.cancel(slowMotionTimer)
		end

		--Stop the base moving if it is!
		if (parachuteOut == true and landMoving==true) then
	
				--Cancel transitions (if necessary)
				if transitionBaseForward then
					transition.cancel( transitionBaseForward )
					transitionBaseForward = nil
				end

				if transitionBaseBack then
					transition.cancel( transitionBaseBack )
					transitionBaseBack = nil
				end
	
			--transition.cancel(transitionBaseBack)
			--transition.cancel(transitionBaseForward)
		end
	
		local function levelFailedScreenShow()
			local options = {
			effect = "slideDown", time = 200,
				params ={
				collectCoins=coinsCollected,
				collectBonus=bonusCollected,
				collectScore=gameScore,
				collectHighscore=highScore,}
			}
		
			storyboard.showOverlay("overlayFailed", options )	--This is our Pause Screen
		end
	
		timer.performWithDelay(300, levelFailedScreenShow )
	
	end

end



function tempRestart()
	storyboard.gotoScene("startScreen")	--This is our main menu
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	
	--storyboard.purgeScene( "main" )
	storyboard.purgeScene( "startScreen" )
	storyboard.removeScene( "startScreen" )

	storyboard.purgeScene( "screenLevelSelect" )
	storyboard.removeScene( "screenLevelSelect" )

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

	--moveSceneLeft:addEventListener( "touch", leftTouch)
	--moveSceneRight:addEventListener( "touch", rightTouch)
	--gameOverScreen:addEventListener( "touch", tapRestart)

end
		
-- Called when scene is about to move offscreen:
function scene:exitScene( event )

	cancelPlayerReset()
	cancelGameTimersandEvents()	
	
	Runtime:removeEventListener( "enterFrame", updateTick )
	Runtime:removeEventListener( "collision", gameGlobalCollision )
		
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )

end

function scene:overlayEnded( event )

	if(gameIsPaused==true) then
		print("PAUSE WINDOW *********")
		pauseWindowShow()
    end
    
    print( "The following overlay scene was removed: " .. event.sceneName )
end



---------------------------------------------------------------------------------
-- END OF SCENE IMPLEMENTATION
---------------------------------------------------------------------------------
scene:addEventListener( "overlayEnded" )

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
Runtime:addEventListener( "collision", gameGlobalCollision)


return scene