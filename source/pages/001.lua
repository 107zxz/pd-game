local pg = {}
pg.image = "gfx/amy.png"
pg.buttons = {
    {label="One",action=function() CurrentScreen = DiceScreen; DiceScreen:roll() end},
    {label="Two",action=function() print("Button two pressed!"); TextScreen:loadPage"002" end}
}
pg.text = [[
Hello, World.

I am Yugi Muto.

Oh dear

Fuck my trap car

adojsajdoa


Hell No
]]
return pg
