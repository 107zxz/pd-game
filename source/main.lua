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

function pd.update()
    CurrentScreen:update()
end
