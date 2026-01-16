import "CoreLibs/keyboard"

local pd <const> = playdate
local gfx <const> = playdate.graphics

function PageJump()
    local pj = {}

    pd.getSystemMenu():addMenuItem("jump", function() CurrentScreen = PageJump; PageJump:init(tonumber(TextScreen.page)) end)

    ---Open page jump screen at number
    ---@param currentPage integer
    function pj:init(currentPage)

        self.selection = 1
        self.number = currentPage

        self.timer = 0

        -- Get page max
        self.pagemax = 0
        for _, pg in ipairs(pd.file.listFiles("pages")) do
            local pn = tonumber(pg:match "(%w+).pdz")
            assert(pn ~= nil, "Couldn't parse page number from " .. pg)
            self.pagemax = math.max(pn, self.pagemax)
        end

        gfx.setBackgroundColor(gfx.kColorBlack)
        gfx.clear()
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        GameFnt:drawText("Select page:", 200/2 - GameFnt:getTextWidth"Select page:"/2, 120/2 - 12)

        self:updateNumber()
    end

    function pj:updateNumber()
        local cursorPt = 114 - 7 * self.selection
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(100 - GameFnt:getTextWidth"444" / 2, 67, GameFnt:getTextWidth"444", 16)
        GameFnt:drawText(string.format("%03d", self.number), 200/2 - GameFnt:getTextWidth"444"/2, 120/2 + 12)

        gfx.setColor(gfx.kColorWhite)
        gfx.fillTriangle(cursorPt - 2, 71, cursorPt + 2, 71, cursorPt, 71 - 4)
        gfx.fillTriangle(cursorPt - 2, 80, cursorPt + 2, 80, cursorPt, 80 + 4)

    end

    function pj:update()
        if pd.buttonJustPressed(pd.kButtonLeft) then
            self.selection = math.min(self.selection + 1, 3)
            self:updateNumber()
        end
        if pd.buttonJustPressed(pd.kButtonRight) then
            self.selection = math.max(self.selection - 1, 1)
            self:updateNumber()
        end

        if pd.buttonJustPressed(pd.kButtonUp) then
            self.number = math.min(self.number + 10 ^ (self.selection-1), self.pagemax)
            self:updateNumber()
        end
        if pd.buttonJustPressed(pd.kButtonDown) then
            self.number = math.max(self.number - 10 ^ (self.selection-1), 1)
            self:updateNumber()
        end

        -- Submit
        if self.timer > 10 then
            if pd.buttonJustPressed(pd.kButtonA) then
                CurrentScreen = TextScreen
                TextScreen:loadPage(string.format("%03d", self.number))
            end
            if pd.buttonJustPressed(pd.kButtonB) then
                CurrentScreen = TextScreen
                TextScreen:loadPage(TextScreen.page)
            end
        end

        self.timer += 1
    end

    return pj
end