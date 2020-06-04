--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:4fa1e58b6e4261a5893b352200ac9a6c$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- Background-comp-extended
            x=2,
            y=2,
            width=569,
            height=384,

        },
        {
            -- Cliff-Filler
            x=646,
            y=773,
            width=336,
            height=57,

        },
        {
            -- Cliff-Repeat-960-Top
            x=324,
            y=494,
            width=320,
            height=490,

        },
        {
            -- Cliff-Repeat-960
            x=2,
            y=388,
            width=320,
            height=490,

        },
        {
            -- Cliff-Repeat2-960
            x=573,
            y=2,
            width=320,
            height=490,

        },
        {
            -- infoCoins
            x=646,
            y=595,
            width=198,
            height=99,

        },
        {
            -- infoHazard
            x=646,
            y=494,
            width=220,
            height=99,

        },
        {
            -- infoLand
            x=2,
            y=880,
            width=239,
            height=100,

        },
        {
            -- infoLeft
            x=846,
            y=595,
            width=118,
            height=74,

        },
        {
            -- infoParachute
            x=324,
            y=388,
            width=242,
            height=104,

        },
        {
            -- infoRight
            x=646,
            y=696,
            width=131,
            height=75,

        },
        {
            -- infoStart
            x=646,
            y=832,
            width=255,
            height=52,

        },
    },
    
    sheetContentWidth = 1024,
    sheetContentHeight = 1024
}

SheetInfo.frameIndex =
{

    ["Background-comp-extended"] = 1,
    ["Cliff-Filler"] = 2,
    ["Cliff-Repeat-960-Top"] = 3,
    ["Cliff-Repeat-960"] = 4,
    ["Cliff-Repeat2-960"] = 5,
    ["infoCoins"] = 6,
    ["infoHazard"] = 7,
    ["infoLand"] = 8,
    ["infoLeft"] = 9,
    ["infoParachute"] = 10,
    ["infoRight"] = 11,
    ["infoStart"] = 12,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
