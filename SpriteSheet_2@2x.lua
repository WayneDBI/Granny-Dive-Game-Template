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
            x=4,
            y=4,
            width=1138,
            height=768,

        },
        {
            -- Cliff-Filler
            x=1292,
            y=1546,
            width=672,
            height=114,

        },
        {
            -- Cliff-Repeat-960-Top
            x=648,
            y=988,
            width=640,
            height=980,

        },
        {
            -- Cliff-Repeat-960
            x=4,
            y=776,
            width=640,
            height=980,

        },
        {
            -- Cliff-Repeat2-960
            x=1146,
            y=4,
            width=640,
            height=980,

        },
        {
            -- infoCoins
            x=1292,
            y=1190,
            width=396,
            height=198,

        },
        {
            -- infoHazard
            x=1292,
            y=988,
            width=440,
            height=198,

        },
        {
            -- infoLand
            x=4,
            y=1760,
            width=478,
            height=200,

        },
        {
            -- infoLeft
            x=1692,
            y=1190,
            width=236,
            height=148,

        },
        {
            -- infoParachute
            x=648,
            y=776,
            width=484,
            height=208,

        },
        {
            -- infoRight
            x=1292,
            y=1392,
            width=262,
            height=150,

        },
        {
            -- infoStart
            x=1292,
            y=1664,
            width=510,
            height=104,

        },
    },
    
    sheetContentWidth = 2048,
    sheetContentHeight = 2048
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
