local t = {}

-----------------------------------------------------------------
-- Return some basic information on how the
-- TARGET LANDING platform should behave and the Parachute Zone
-----------------------------------------------------------------
t.collectMinXData 					= 90		-- Assign the Min X Position of the Landing Target Base (if moving).
t.collectMaxXData 					= 300		-- Assign the Max X Position of the Landing Target Base (if moving).
t.collectTargetMovingData 			= false		-- Assign Landing Target Base as moving or not [True] or [False].
t.collectMovingSpeedData 			= 1800		-- Assign Landing Target Base moving speed (Higher number = slower).
t.collectStaticXData 				= (_W-60)	-- If the Landing Target base is STATIC (ie not moving), then assign the X position here.
t.collectParachuteZoneHeightData	= 250		-- This is the height of the Parachute Release zone. Anything less than 250 is hard (ish)
t.collectScrollSpeedData			= 5			-- This is the speed the hero will fall down the screen. (1 = Slow, 14 = Crazy Fast)
t.collectplatformSizeData			= 3			-- We can choose between 1 (BIG), 2, 3, 4, 5(SMALL) for the platform size...

-- As each LEVEL can have a different number of ZONES, we return the value here - back to the
-- main game engine. This value is used to determine the END SEQUENCE, GRAPHICS and behaviours etc.
t.numberOfZones 					= 9

showTutorial						= true		-- Set to TRUE to show game tutorial details on this level

-----------------------------------------------------------------
-- SET UP THE COLLECTABLES ON THE LEVEL
-----------------------------------------------------------------
-- Each ZONE can have a series of collectables (and hazards). If the ZONE has
-- any collectables or hazards set the value below to TRUE - otherwise keep as FALSE
-- Using this technique we can minimise when the game engine needs to consider DRAWING
-- the game objects. WE ONLY START DRAWING THE ZONE IF IT'S TRUE!
-- thus improving FPS, conserving MEMORY and achieving the better results.

-- The FALSE and TRUE booleans for each zone means: "HAS THIS ZONE BEEN CREATED YET?"
-- Pre setting the ZONE with [true] - will cause that zone to never be rendered.
scrollZones[1] = false
scrollZones[2] = false
scrollZones[3] = false
scrollZones[4] = false
scrollZones[5] = false
scrollZones[6] = false
scrollZones[7] = false
scrollZones[8] = false
scrollZones[9] = false
scrollZones[10] = true
scrollZones[11] = true
scrollZones[12] = true
scrollZones[13] = true
scrollZones[14] = true
scrollZones[15] = true

-- For each ZONE setup the collectables position. Here we have split the screen into
-- 9 across, by 12 down - each POSITIVE number will cause the engine to position the collectable
-- item on the screen. SEE BELOW - for a more detailed explanation.
-- Note each ZONE can be longer - this will add content to the areas BETWEEN zones...

-- Numerical meanings:
-- 0	= NOTHING
-- 1	= COLLECTABLE
-- 2	= LEFT Branch STYLE 1
-- 3	= RIGHT Branch STYLE 2
-- 4	= LEFT HAZARD 1
-- 5	= RIGHT HAZARD 2
-- 6	= Hazard1
-- 7	= Hazard2
-- 8	= SlowMotion (3 seconds)
-- 9	= Bonus
-- 10	= LEFT Branch STYLE 2
-- 11	= RIGHT Branch STYLE 2

-- 100	= DEPLOY PARACHUTE ZONE !

-- TUTORIAL CONTROLS
-- 55	= collect Coins
-- 66	= land zone
-- 77	= avoid hazards
-- 88	= deploy parachute info

zones[1] = {
			 {0,0,0,0,0,0,0,0,0},
			 {0,1,0,0,0,0,0,0,0},
			 {0,0,0,0,0,0,0,0,0},
			 {0,1,0,0,0,0,0,0,0},
			 {0,0,0,0,0,0,0,0,0},
			 {0,1,0,0,0,0,0,0,0},
			 {0,0,0,0,0,0,0,0,0},
			 {0,1,0,0,0,0,0,0,0},
			 {0,0,0,0,0,0,0,0,0},
			 {0,1,0,0,0,0,0,0,0},
			 {0,0,0,0,0,0,0,0,0},
			 {0,1,0,0,0,0,0,0,0},}
			 
			 
zones[2] = {
			 {0,0,0,0,0,0,0,0,0},
			 {0,0,0,0,0,0,0,1,0},
			 {0,0,0,0,0,0,0,0,0},
			 {0,0,0,0,0,0,0,1,0},
			 {0,0,0,0,0,0,0,0,0},
			 {0,0,0,0,0,0,0,1,0},
			 {0,0,0,0,0,0,0,0,0},
			 {0,0,0,0,0,0,0,1,0},
			 {0,0,0,0,0,0,0,0,0},
			 {0,0,0,0,0,0,0,1,0},
			 {0,0,0,0,0,0,0,0,0},
			 {0,0,0,0,0,0,0,1,0},}

zones[3] = {
			 {0,0,0,0,1,0,0,0,0},
			 {0,0,0,0,1,0,0,0,0},
			 {0,0,0,0,1,0,0,0,0},
			 {0,0,0,0,1,0,0,0,0},
			 {0,0,0,0,1,0,0,0,0},
			 {0,0,0,1,0,0,0,0,0},
			 {0,0,1,0,0,0,0,0,0},
			 {0,0,1,0,0,0,0,0,0},
			 {0,0,1,0,0,0,0,0,0},
			 {0,0,0,1,0,0,0,0,0},
			 {0,0,0,0,1,0,0,0,0},
			 {0,0,0,0,0,1,0,0,0},

			 {0,0,0,0,0,0,1,0,0},
			 {0,0,0,0,0,0,0,1,0},
			 {0,0,0,0,0,0,0,0,1},
			 {0,0,0,0,0,0,0,1,0},
			 {0,0,0,0,0,0,1,0,0},
			 {0,0,0,0,0,1,0,0,0},
			 {0,0,0,0,1,0,0,0,0},
			 {0,0,0,0,1,0,0,0,0},
			 {0,0,1,1,1,1,1,0,0},
			 {0,0,0,1,1,1,0,0,0},
			 {0,0,0,0,1,0,0,0,0},}
			 
zones[4] = {
			 {0,0,0,0,77,0,0,0,0},
			 {0,0,0,0,0,0,0,0,0},
			 {0,0,2,0,0,0,0,0,0},
			 {0,0,0,0,0,0,0,0,0},
			 {0,0,0,0,0,0,0,0,0},
			 {0,4,0,0,4,0,0,0,0},
			 {0,0,0,0,0,0,0,0,0},
			 {0,0,0,0,0,0,0,0,0},
			 {0,0,0,0,0,0,0,3,0},
			 {0,0,0,0,0,0,0,0,0},
			 {0,0,0,0,0,0,0,0,0},
			 {0,0,0,0,5,0,5,0,0},}

zones[5] = {
			 {0,0,8,0,0,0,0,0,0},
			 {0,1,1,0,7,0,0,0,0},
			 {0,1,1,0,0,7,0,0,0},
			 {0,1,1,0,0,0,7,0,0},
			 {6,0,1,1,0,0,0,7,0},
			 {0,0,0,1,1,0,0,0,7},
			 {0,6,0,0,1,1,0,0,0},
			 {0,0,0,0,1,1,0,0,0},
			 {0,2,0,1,1,0,5,0,0},
			 {0,0,1,1,0,0,0,0,0},
			 {0,1,1,0,3,0,3,0,0},
			 {0,1,1,0,0,0,0,0,0},}

zones[6] = {
			 {0,0,0,0,1,0,0,0,0},
			 {2,0,0,0,1,0,0,0,0},
			 {0,0,0,1,1,1,0,0,0},
			 {0,0,0,1,1,1,0,0,3},
			 {0,0,1,1,1,1,1,0,0},
			 {0,1,1,0,0,0,1,1,0},
			 {0,1,1,0,7,0,1,1,0},
			 {1,1,0,6,0,6,0,1,1},
			 {1,1,0,0,7,0,0,1,1},
			 {1,1,1,0,0,0,1,1,1},
			 {0,0,1,1,1,1,1,0,0},
			 {0,0,0,1,1,1,0,0,0},}

zones[7] = {
			 {0,0,0,0,1,0,0,0,0},
			 {0,0,0,1,1,1,0,0,0},
			 {0,0,0,1,0,1,0,0,0},
			 {0,0,1,0,0,0,1,0,0},
			 {0,0,0,1,8,1,0,0,0},
			 {0,0,0,0,1,0,0,0,0},
			 {0,0,0,1,1,1,0,0,0},
			 {0,0,1,1,1,1,1,0,0},
			 {0,1,1,1,1,1,1,1,0},
			 {0,0,1,1,1,1,1,0,0},
			 {0,0,0,1,1,1,0,0,0},
			 {0,0,0,0,1,0,0,0,0},}
			 
zones[8] = {
			 {0,0,0,1,1,1,0,0,0},
			 {0,0,0,0,1,0,0,0,0},
			 {0,0,0,0,1,0,0,0,0},
			 {0,0,0,0,88,0,0,0,0},
			 {0,0,0,0,1,0,0,0,0},
			 {0,0,0,1,1,1,0,0,0},
			 {0,1,1,1,1,1,1,1,0},
			 {0,0,1,1,1,1,1,0,0},
			 {0,0,0,1,1,1,0,0,0},
			 {0,0,0,1,1,1,0,0,0},
			 {0,0,0,0,1,0,0,0,0},
			 {0,0,0,0,100,0,0,0,0},}

zones[9] = {
			 {0,0,0,0,1,0,0,0,0},
			 {0,0,0,1,1,1,0,0,0},
			 {0,0,1,1,1,1,1,0,0},
			 {0,0,1,1,1,1,1,0,0},
			 {0,0,0,1,1,1,0,0,0},
			 {0,0,0,0,1,0,0,0,0},
			 {0,2,0,0,1,0,0,3,0},
			 {0,0,0,1,1,1,0,0,0},
			 {0,1,1,1,1,1,1,1,0},
			 {0,0,1,1,1,1,1,0,0},
			 {0,0,0,1,1,1,0,0,0},

			 {0,0,0,0,1,0,0,0,0},
			 {0,1,1,1,1,1,1,1,0},
			 {0,1,1,1,1,1,1,1,0},
			 {0,1,1,1,1,1,1,1,0},
			 {0,1,1,1,1,1,1,1,0},
			 {0,1,1,1,1,1,1,1,0},
			 {0,1,1,1,1,1,1,1,0},
			 {0,1,1,1,9,1,1,1,0},
			 {0,1,1,1,1,1,1,1,0},
			 {0,1,9,1,1,1,9,1,0},
			 {0,1,1,1,1,1,1,1,0},
			 {0,0,0,1,9,1,0,0,0},}

zones[10] = {
			 {0,0,0,0,1,0,0,0,0},
			 {0,0,0,0,0,0,0,0,0},
			 {0,0,0,0,1,0,0,0,0},
			 {0,0,0,0,0,0,0,0,0},
			 {0,0,0,1,0,1,0,0,0},
			 {0,0,1,0,0,0,1,0,0},
			 {0,0,1,0,0,0,1,0,0},
			 {0,0,0,1,0,1,0,0,0},
			 {0,0,0,0,1,0,0,0,0},
			 {0,0,0,0,1,0,0,0,0},
			 {0,0,0,0,1,0,0,0,0},
			 {0,0,0,0,1,0,0,0,0},}


return t
--[[
_____________________________
| 0  0  0  0  0  0  0  0  0 |
| 0  0  0  0  1  0  0  0  0 |
| 0  0  0  0  1  0  0  0  0 |
| 0  0  0  0  1  0  0  0  0 |
| 0  1  1  1  1  1  1  1  0 |
| 0  0  0  0  1  0  0  0  0 |
| 0  0  0  0  1  0  0  0  0 |
| 0  0  0  0  1  0  0  0  0 |
| 0  0  0  0  1  0  0  0  0 |
| 0  0  0  0  0  0  0  0  0 |
_____________________________

The above example would place the collectables in a giant PLUS [ + ]
shape on the screen. Using this method you can build some fun levels,
and have the collectables in the same position on each re-try.

--EMPTY ZONE

zones[1] = {
				 {0,0,0,0,0,0,0,0,0},
				 {0,0,0,0,0,0,0,0,0},
				 {0,0,0,0,0,0,0,0,0},
				 {0,0,0,0,0,0,0,0,0},
				 {0,0,0,0,0,0,0,0,0},
				 {0,0,0,0,0,0,0,0,0},
				 {0,0,0,0,0,0,0,0,0},
				 {0,0,0,0,0,0,0,0,0},
				 {0,0,0,0,0,0,0,0,0},
				 {0,0,0,0,0,0,0,0,0},}

--]]