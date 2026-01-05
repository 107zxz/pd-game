local pg = {}
pg.buttons = {
    {label="DC 7 STR",action=function() CurrentScreen = DiceScreen; DiceScreen:roll(2) end},
    {label="p.002",action=function() TextScreen:loadPage"002" end},
    {label="p.003",action=function() TextScreen:loadPage"003" end},
}
pg.text = [[
To jump to the other ledge, roll a DC 7 STR check. If you pass, turn to p.002. Otherwise, turn to p.003.
]]
return pg
