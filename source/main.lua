import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "CoreLibs/ui"
import "textscreen"
import "dicescreen"
import "charsheet"
import "pagejump"

local pd <const> = playdate
local gfx <const> = playdate.graphics

local saveDat = pd.datastore.read()
if saveDat == nil then
    saveDat = {}
    saveDat.page = "001"
end

pd.display.setScale(2)

GameFnt = gfx.font.new("fonts/topaz_serif_8")
gfx.setFont(GameFnt)

TextScreen = TextScreen()
DiceScreen = DiceScreen()
CharacterSheet = CharacterSheet()
PageJump = PageJump()

CurrentScreen = TextScreen
TextScreen:loadPage(saveDat.page)

function pd.update()
    CurrentScreen:update()
end

function pd.gameWillTerminate()
    pd.datastore.write{page = TextScreen.page}
end

function pd.deviceWillSleep()
    pd.datastore.write{page = TextScreen.page}
end
