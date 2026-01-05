local pd <const> = playdate
local gfx <const> = playdate.graphics

function Button(label, x, y)
    local btn = {}
    btn.label = label
    btn.x, btn.y, btn.w, btn.h = x, y, GameFnt:getTextWidth(label), GameFnt:getHeight()

    function btn:update(hovered)
        if hovered then
            gfx.setColor(gfx.kColorWhite)
        else
            gfx.setColor(gfx.kColorBlack)
        end
        gfx.fillRoundRect(self.x - 5, self.y - 4, self.w + 9, self.h + 7, 4)
        if hovered then
            gfx.setColor(gfx.kColorClear)
        else
            gfx.setColor(gfx.kColorWhite)
        end
        gfx.drawRoundRect(self.x - 5, self.y - 4, self.w + 9, self.h + 7, 4)
        if hovered then
            gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
        else
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        end
        GameFnt:drawText(self.label, self.x, self.y)
    end

    return btn
end
