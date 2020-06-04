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
-- main.lua
--
------------------------------------------------------------------------------------------------------------------------------------
-- Release Version 1.1
-- Code developed for CORONA SDK STABLE RELESE 2013.2076
-- 13th February 2014
------------------------------------------------------------------------------------------------------------------------------------

display.setStatusBar( display.HiddenStatusBar )

-- require controller module
local storyboard 		= require "storyboard"
local physics 			= require( "physics" )

_G.sprite = require "sprite"							-- Add SPRITE API for Graphics 1.0

--- Require our external Load/Save module
local loadsave 				= require("loadsave")

local spine = require "_Assets.spine.spine" -- Used for the Granny animation

scaleFactor = 0.5
physicsData 			= (require "physicsShapes").physicsData(scaleFactor)

_G._w 					= display.contentWidth  		-- Get the devices Width
_G._h 					= display.contentHeight 		-- Get the devices Height
_G.gameScore			= 0								-- The Users score
_G.imagePath			= "_Assets/Images/"
_G.audioPath			= "_Assets/Audio/"
_G.levelsPath			= "_Assets.Levels."
_G.level				= 1								-- Global Level Select, Clean, Load, etc...
_G.myLevel				= 0
_G.maxLevels			= 36							-- How many levels does out game have

_G.coinValue			= 2								-- How much are each coin worth in game?
_G.bonusValue			= 10							-- How much are each BONUS items worth in game?
_G.showTutorial			= false							-- Does the level need to show a TUTORIAL?
_G.iPhone5				= false							-- Which device	

_G.volumeSFX			= 0.7							-- Define the SFX Volume
_G.volumeMusic			= 0.7							-- Define the Music Volume
_G.resetVolumeSFX		= volumeSFX						-- Define the SFX Volume Reset Value
_G.resetVolumeMusic		= volumeMusic					-- Define the Music Volume Reset Value
_G.soundON				= true							-- Is the sound ON or Off?

_G.factorX				= 0.4166	--2.400				-- Scale factors
_G.factorY				= 0.46875	--2.133

_G.saveDataTable		= {}							-- Define the Save/Load base Table to hold our data


-- Load in the saved data to our game table
-- check the files exists before !
if loadsave.fileExists("grannydivedata.json", system.DocumentsDirectory) then
	saveDataTable = loadsave.loadTable("grannydivedata.json")
else
	saveDataTable.levelReached 		= 1
	saveDataTable.gameCompleted 	= false
	saveDataTable.highScore 		= 0
	loadsave.saveTable(saveDataTable, "grannydivedata.json")
end

--Now load in the Data
saveDataTable = loadsave.loadTable("grannydivedata.json")

--Now assign the LOADED level to the Game Variable to control the levels the user can select.
_G.nextLevel			= saveDataTable.levelReached	-- Global The next available Level Select, Clean, Load, etc...
_G.allLevelsWon 		= saveDataTable.gameCompleted	-- Has the user completed EVERY level?
_G.highScore			= saveDataTable.highScore		-- Saved HighScore value
_G.gameScore			= 0								-- Set the Starting value of the score to ZERO ( 0 )
_G.resetScore			= 0								-- Used when a user RESETS a level, so we keep the correct score.

if system.getInfo("model") == "iPad" or system.getInfo("model") == "iPad Simulator" then
	_G.iPhone5	= false
	_G.iPad		= true
elseif display.pixelHeight > 960 then
	_G.iPhone5	= true
	_G.iPad		= false
end

-- Enable debug by setting to [true] to see FPS and Memory usage.
local doDebug 			= false

-- Debug Data
if (doDebug) then
	local fps = require("fps")
	local performance = fps.PerformanceOutput.new();
	performance.group.x, performance.group.y = (display.contentWidth/2)-40,  270;
	performance.alpha = 0.3; -- So it doesn't get in the way of the rest of the scene
end


--Set the Music Volume
audio.setVolume( volumeMusic, 	{ channel=2 } ) -- set the volume on channel 2
audio.setVolume( volumeMusic, 	{ channel=3 } ) -- set the volume on channel 2
audio.setVolume( volumeSFX, 	{ channel=1 } ) -- set the volume on channel 1

for i = 4, 32 do
	audio.setVolume( volumeSFX, { channel=i } )
end 



function startGame()
	storyboard.gotoScene( "startScreen")	--This is our main menu
end


--Dancing Animation start data / Spine
attachmentResolver = spine.AttachmentResolver.new()
function attachmentResolver:createImage (attachment)

	--STATIC SPRITE
	return display.newImage("_Assets/SpineAnimationData/" .. attachment.name .. ".png")
	
	--FROM SPRITESHEET
	--return display.newSprite( imageSheet , {frames={sheetInfo:getFrameIndex(attachment.name)}} )
end
animationJson = spine.SkeletonJson.new(attachmentResolver)


--Define some globally loaded assets
musicStart 			= audio.loadSound( audioPath.."musicStart.mp3" )
musicGame			= audio.loadSound( audioPath.."musicGameTheme.mp3" )
musicWin			= audio.loadSound( audioPath.."musicWin.mp3" )
musicSlowMotion		= audio.loadSound( audioPath.."musicSlowMotion.mp3" )
musicCrash			= audio.loadSound( audioPath.."musicCrash.mp3" )
sfxCollect1			= audio.loadSound( audioPath.."sfxCollect1.mp3" )
sfxCollect2			= audio.loadSound( audioPath.."sfxCollect2.mp3" )
sfxCollect3			= audio.loadSound( audioPath.."sfxCollect3.mp3" )
sfxCollect4			= audio.loadSound( audioPath.."sfxCollect4.mp3" )
sfxHitFloor			= audio.loadSound( audioPath.."sfxHitFloor.mp3" )
sfxHitObject		= audio.loadSound( audioPath.."sfxHitObject.mp3" )
sfxLand				= audio.loadSound( audioPath.."sfxLand.mp3" )
sfxLeap				= audio.loadSound( audioPath.."sfxLeap.mp3" )
sfxScream			= audio.loadSound( audioPath.."sfxScream.mp3" )


------------------------------------------------------------------------------------------------------------------------------------
-- Preload SpriteSheets
------------------------------------------------------------------------------------------------------------------------------------
sheetInfo = require("SpriteSheet_1")
imageSheet = graphics.newImageSheet( imagePath.."SpriteSheet_1.png", sheetInfo:getSheet() )

sheetInfo2 = require("SpriteSheet_2")
imageSheet2 = graphics.newImageSheet( imagePath.."SpriteSheet_2.png", sheetInfo2:getSheet() )


-----------------------------------------------------------------
-- Setup the various animation sequences used on the games scenes
-----------------------------------------------------------------
animationSequenceData = {

  { name = "angelAnimation", frames={ 1,2,3,4,5,4,3,2 }, time=250 },
  { name = "chuteOpenAnimation", frames={ 6,7,8,9 }, time=400, loopCount=1 },
  { name = "chuteLeftAnimation", frames={ 10 }, time=250, loopCount=1 },
  { name = "chuteRightAnimation", frames={ 11 }, time=250, loopCount=1 },
  { name = "crashAnimation", frames={ 12,13,14 }, time=350, loopCount=1 },
  { name = "diveAnimation", frames={ 15,16,17,18,19 }, time=250 },
  { name = "flipAnimation", frames={ 20,20,21,21,21,21,22,23,24,25,26,27 }, time=950, loopCount=1 },
  { name = "flipAnimation2", frames={ 20,20,21,21,21,21,21,22,23,24,25,26,27 }, time=950, loopDirection=bounce },
  { name = "flipAnimation3", frames={ 20,21,22,23,24,25,26,27 }, time=450, loopCount=1 },
  { name = "leftAnimation", frames={ 28,29,30,29 }, time=200 },
  { name = "rightAnimation", frames={ 31,32,33,32 }, time=200 },
  { name = "standingAnimation", frames={ 34,34,34,34,34,34,34,34,34,34,35,36,37,38,39 }, time=1250 },
  
  { name = "branchLeft1",  frames={ 40 }, time=250, loopCount=1 },
  { name = "branchLeft2",  frames={ 41 }, time=250, loopCount=1 },
  { name = "branchLeft3",  frames={ 42 }, time=250, loopCount=1 },
  { name = "branchRight1",  frames={ 43 }, time=250, loopCount=1 },
  { name = "branchRight2",  frames={ 44 }, time=250, loopCount=1 },
  { name = "branchRight3",  frames={ 45 }, time=250, loopCount=1 },
  { name = "cloudSmall",  frames={ 46 }, time=250, loopCount=1 },
  { name = "coinStatic",  frames={ 47 }, time=250, loopCount=1 },
  { name = "landArrow",  frames={ 48 }, time=250, loopCount=1 },
  { name = "ledgeLeft1",  frames={ 49 }, time=250, loopCount=1 },
  { name = "ledgeLeft2",  frames={ 50 }, time=250, loopCount=1 },
  { name = "ledgeRight1",  frames={ 51 }, time=250, loopCount=1 },
  { name = "ledgeRight2",  frames={ 52 }, time=250, loopCount=1 },
  { name = "outcrop1",  frames={ 53 }, time=250, loopCount=1 },
  { name = "outcrop2",  frames={ 54 }, time=250, loopCount=1 },
  { name = "outcrop3",  frames={ 55 }, time=250, loopCount=1 },
  { name = "outcrop4",  frames={ 56 }, time=250, loopCount=1 },
  { name = "outcrop5",  frames={ 57 }, time=250, loopCount=1 },

  { name = "signCliff",  frames={ 58 }, time=250, loopCount=1 },
  { name = "signHome",  frames={ 59 }, time=250, loopCount=1 },
  { name = "signNextCliff",  frames={ 60 }, time=250, loopCount=1 },
  { name = "signPost",  frames={ 61 }, time=250, loopCount=1 },
  
  { name = "allLevelsCompleted",  frames={ 62 }, time=250, loopCount=1 },
  { name = "audioSetup",  frames={ 63 }, time=250, loopCount=1 },

  { name = "buttonBack",  frames={ 64 }, time=250, loopCount=1 },
  { name = "buttonCredits",  frames={ 65 }, time=250, loopCount=1 },
  { name = "buttonMenu",  frames={ 66 }, time=250, loopCount=1 },
  { name = "buttonNextLevel",  frames={ 67 }, time=250, loopCount=1 },
  { name = "buttonOptions",  frames={ 68 }, time=250, loopCount=1 },
  { name = "buttonPause",  frames={ 69 }, time=250, loopCount=1 },
  { name = "buttonPlay",  frames={ 70 }, time=250, loopCount=1 },
  { name = "buttonReplay",  frames={ 71 }, time=250, loopCount=1 },
  { name = "buttonSoundOff",  frames={ 72 }, time=250, loopCount=1 },
  { name = "buttonSoundOn",  frames={ 73 }, time=250, loopCount=1 },
  { name = "buttonStart",  frames={ 74 }, time=250, loopCount=1 },
  { name = "buttonWeb",  frames={ 75 }, time=250, loopCount=1 },
  
  { name = "cloudLargeBlur",  frames={ 76 }, time=250, loopCount=1 },
  { name = "cloudLargeNorm",  frames={ 77 }, time=250, loopCount=1 },

  { name = "creditsHeader",  frames={ 78 }, time=250, loopCount=1 },
  { name = "creditsText",  frames={ 79 }, time=250, loopCount=1 },
  { name = "dbi",  frames={ 80 }, time=250, loopCount=1 },
  { name = "hudTop",  frames={ 81 }, time=250, loopCount=1 },
  { name = "infoCompleted",  frames={ 82 }, time=250, loopCount=1 },
  { name = "infoFailed",  frames={ 83 }, time=250, loopCount=1 },
  { name = "infoPanel",  frames={ 84 }, time=250, loopCount=1 },
  { name = "infoPanelText",  frames={ 85 }, time=250, loopCount=1 },
  { name = "infoPaused",  frames={ 86 }, time=250, loopCount=1 },
  { name = "levelLocked",  frames={ 87 }, time=250, loopCount=1 },
  { name = "levelSelectArrow",  frames={ 88 }, time=250, loopCount=1 },
  { name = "levelSelectText",  frames={ 89 }, time=250, loopCount=1 },
  { name = "levelUnLocked",  frames={ 90 }, time=250, loopCount=1 },
  { name = "menuSelectArrow",  frames={ 91 }, time=250, loopCount=1 },
  { name = "musicHeader",  frames={ 92 }, time=250, loopCount=1 },
  { name = "platformLand1",  frames={ 93 }, time=250, loopCount=1 },
  { name = "platformLand2",  frames={ 94 }, time=250, loopCount=1 },
  { name = "platformLand3",  frames={ 95 }, time=250, loopCount=1 },
  { name = "platformLand4",  frames={ 96 }, time=250, loopCount=1 },
  { name = "platformLand5",  frames={ 97 }, time=250, loopCount=1 },
  { name = "sfxHeader",  frames={ 98 }, time=250, loopCount=1 },
  
  { name = "slideBar",  frames={ 99 }, time=250, loopCount=1 },
  { name = "slideButton",  frames={ 100 }, time=250, loopCount=1 },
  
  { name = "coinAnimated",  frames={ 101,102,103,104,105,106 }, time=450 },
  { name = "splashGranny",  frames={ 107 }, time=250, loopCount=1 },
  { name = "splashLogo",  frames={ 108 }, time=250, loopCount=1 },
  { name = "splashTemplate",  frames={ 109 }, time=250, loopCount=1 },

  { name = "slowMotionBonus",  frames={ 110,111,112,113,114,115,116,117,118,119,120,121 }, time=450 },
  
}


animationSequenceData2 = {

  { name = "skyBG",  frames={ 1 }, time=250, loopCount=1 },
  { name = "cliffFiller",  frames={ 2 }, time=250, loopCount=1 },
  { name = "cliffTop",  frames={ 3 }, time=250, loopCount=1 },
  { name = "cliffMid1",  frames={ 4 }, time=250, loopCount=1 },
  { name = "cliffMid2",  frames={ 5 }, time=250, loopCount=1 },
  { name = "infoCoins",  frames={ 6 }, time=250, loopCount=1 },
  { name = "infoHazard",  frames={ 7 }, time=250, loopCount=1 },
  { name = "infoLand",  frames={ 8 }, time=250, loopCount=1 },
  { name = "infoLeft",  frames={ 9 }, time=250, loopCount=1 },
  { name = "infoParachute",  frames={ 10 }, time=250, loopCount=1 },
  { name = "infoRight",  frames={ 11 }, time=250, loopCount=1 },
  { name = "infoStart",  frames={ 12 }, time=250, loopCount=1 },
  --{ name = "splashBackground",  frames={ 12 }, time=250, loopCount=1 },

}
  --{ name = "startScreenImage",  frames={ 32 }, time=250, loopCount=1 },
  --{ name = "itemCollected",  frames={ 11,12,13,14,15 }, time=500, loopCount=1 },

--Start Game after a short delay.
timer.performWithDelay(5, startGame )
