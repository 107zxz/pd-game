import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "CoreLibs/ui"
import "textscreen"
import "dicescreen"

local pd <const> = playdate
local gfx <const> = playdate.graphics

pd.display.setScale(2)
--pd.display.setRefreshRate(50)

GameFnt = gfx.font.new("fonts/topaz_serif_8")
gfx.setFont(GameFnt)

TextScreen = TextScreen()
TextScreen:loadPage("001")

DiceScreen = DiceScreen()
-- DiceScreen:roll()

CurrentScreen = TextScreen
--local currentScreen = DiceScreen

-- Add menu items
-- local menu = pd.getSystemMenu()
-- menu:addOptionsMenuItem("Roll Dice", {"1","2","3","4","5"}, "2", function(number) CurrentScreen = DiceScreen; DiceScreen:roll(tonumber(number)) end)

function pd.update()
    CurrentScreen:update()
end
