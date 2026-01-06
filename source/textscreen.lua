import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/ui"
import "ui"

local pd <const> = playdate
local gfx <const> = playdate.graphics

function TextScreen()
    local ts = {}

    ts.cornerImage = gfx.image.new("gfx/cornerdeco.png")
    assert(ts.cornerImage ~= nil, "Couldn't load corner image!")

    -- Menu item
    -- ts.previous = "001"
    -- pd.getSystemMenu():addMenuItem("Jump Back", function() ts:loadPage(ts.previous) end)

    function ts:updateBottomUI()
        local totalLen = 0
        for _, btn in ipairs(self.buttons) do
            totalLen += GameFnt:getTextWidth(btn.label) + 14
        end

        local spacing = (200 - totalLen) / 2

        local spaceAcc = 0
        for i, btn in ipairs(self.buttons) do
            local buttonWidth = GameFnt:getTextWidth(btn.label)

            Button(btn.label, spacing + spaceAcc, 92):update(i ==
                self.selection)

            spaceAcc += buttonWidth + 14
        end
    end

    ---@param page string
    function ts:loadPage(page)
        self.page = page
        --- @type table
        self.buttons = {}

        -- Load page from disk
        local pagePath = string.format("pages/%s.pdz", page)

        local pageFile = pd.file.open(pagePath)
        if pageFile == nil then
            error(string.format("Couldn't open pages/%s", pagePath))
        end

        --- @type table
        local pageObj = pd.file.load(pagePath)()
        if pageObj == nil then
            error("Could not load page object: " .. pagePath)
        end
        local pageText = pageObj.text:match "^%s*(.-)%s*$"
        self.buttons = pageObj.buttons
        self.imagePath = pageObj.image

        gfx.setColor(gfx.kColorWhite)
        gfx.setBackgroundColor(gfx.kColorBlack)
        gfx.setImageDrawMode(gfx.kDrawModeBlackTransparent)

        gfx.clear()
        self.cornerImage:draw(0, 0)

        self.cornerImage:draw(200 - self.cornerImage.width, 0, gfx.kImageFlippedX)
        self.cornerImage:draw(0, 120 - self.cornerImage.height, gfx.kImageFlippedY)
        self.cornerImage:draw(200 - self.cornerImage.width, 120 - self.cornerImage.height, gfx.kImageFlippedXY)
        gfx.setColor(gfx.kColorBlack)

        local function makePageImage(text)
            local _, textHeight = gfx.getTextSizeForMaxWidth(text, 200 - GameFnt:getGlyph " ".width * 2)

            local figure = nil
            if self.imagePath ~= nil then
                figure = gfx.image.new(self.imagePath)
                if figure == nil then
                    error("Couldn't load image: " .. self.imagePath)
                end
            end

            local bonusUIHeight = 32

            local portImgSize = {
                200 - GameFnt:getGlyph(" ").width * 2,
                textHeight + bonusUIHeight
            }

            local offsetHeight = 0
            if figure ~= nil then
                portImgSize[2] += figure.height
                offsetHeight = figure.height
            end

            local portImg = gfx.image.new(table.unpack(portImgSize))

            -- Predraw text
            gfx.pushContext(portImg)
            gfx.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
            if figure ~= nil then
                figure:draw(100 - figure.width / 2, 0)
            end
            gfx.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
            gfx.drawText(
                text,
                2,
                offsetHeight + 2,
                portImgSize[1],
                portImgSize[2],
                nil,
                gfx.kWrapWord,
                gfx.kAlignCenter
            )
            gfx.popContext()

            return portImg
        end

        local function getPageMax()
            local max = 0
            for _, pg in ipairs(pd.file.listFiles("pages")) do
                local pn = tonumber(pg:match "(%w+).pdz")
                assert(pn ~= nil, "Couldn't parse page number from " .. pg)
                max = math.max(pn, max)
            end
            return string.format("%03d", max)
        end

        self.pageMax = getPageMax()

        function ts:drawPageArrows()
            if self.page ~= "001" or gfx.getColor() ~= gfx.kColorWhite then
                gfx.drawPolygon(1, 60, 6, 60 - 5, 6, 60 + 5)
            end
            if self.page ~= self.pageMax or gfx.getColor() ~= gfx.kColorWhite then
                gfx.drawPolygon(198, 60, 193, 60 - 5, 193, 60 + 5)
            end
        end

        self.currentPage = makePageImage(pageText)

        local scrollMin = -self.currentPage.height + 120 - GameFnt:getHeight() * 2
        local scrollMax = 0
        self.scrollProgress = 0
        self.scrollProgress = math.min(self.scrollProgress, scrollMax)
        self.scrollProgress = math.max(self.scrollProgress, scrollMin)

        -- Remember special case for small pages
        self.selection = 1

        self.pageRect = pd.geometry.rect.new(
            GameFnt:getGlyph ' '.width,
            GameFnt:getHeight(),
            200 - GameFnt:getGlyph ' '.width * 2,
            120 - GameFnt:getHeight() * 2
        )

        gfx.setClipRect(self.pageRect)
        gfx.fillRect(self.pageRect)
        self.currentPage:draw(GameFnt:getGlyph ' '.width, GameFnt:getHeight() + self.scrollProgress)
        gfx.clearClipRect()

        gfx.setColor(gfx.kColorWhite)
        self:drawPageArrows()
        if scrollMin > scrollMax then
            self.selection = 0

            -- Show buttons!
            ts:updateBottomUI()
        else
            gfx.drawPolygon(95, 120 - 8, 105, 120 - 8, 100, 117)
        end

        -- Page Number
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        GameFnt:drawText(page, 100 - GameFnt:getTextWidth(page) / 2, 0)
    end

    function ts:update()
        local scrollMin = -self.currentPage.height + 120 - GameFnt:getHeight() * 2
        local scrollMax = 0

        if scrollMin < scrollMax then
            local _, ch = pd.getCrankChange()
            if ch == nil then
                ch = 0
            end

            if math.abs(ch) < 3 and self.scrollProgress == scrollMin then
                ch = 0
            end

            if pd.buttonIsPressed(pd.kButtonDown) then
                ch = 3
            end
            if pd.buttonIsPressed(pd.kButtonUp) then
                ch = -3
            end

            -- Speed up
            if pd.buttonIsPressed(pd.kButtonB) then
                ch *= 3
            end

            if ch ~= 0 then
                self.scrollProgress -= ch
                self.scrollProgress = math.min(self.scrollProgress, scrollMax)
                self.scrollProgress = math.max(self.scrollProgress, scrollMin)

                gfx.setClipRect(self.pageRect)
                gfx.setColor(gfx.kColorBlack)
                gfx.fillRect(self.pageRect)
                gfx.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
                self.currentPage:draw(GameFnt:getGlyph ' '.width, GameFnt:getHeight() + self.scrollProgress)
                gfx.clearClipRect()

                -- Scroll Arrows
                if self.scrollProgress < scrollMax and ch > 0 then
                    gfx.setColor(gfx.kColorBlack)
                    gfx.fillRect(64, 0, 36 * 2, GameFnt:getHeight())

                    gfx.setColor(gfx.kColorWhite)
                    gfx.drawPolygon(95, 7, 105, 7, 100, 2)
                end
                if self.scrollProgress == scrollMax and ch < 0 then
                    gfx.setColor(gfx.kColorBlack)
                    gfx.drawPolygon(95, 7, 105, 7, 100, 2)

                    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
                    GameFnt:drawText(self.page, 100 - GameFnt:getTextWidth(self.page) / 2, 0)
                end
                if self.scrollProgress > scrollMin and ch < 0 then
                    -- Clear page number
                    gfx.setColor(gfx.kColorBlack)
                    gfx.fillRect(64, 120 - GameFnt:getHeight(), 36 * 2, 120)

                    gfx.setColor(gfx.kColorWhite)
                    gfx.drawPolygon(95, 120 - 8, 105, 120 - 8, 100, 117)

                    -- Page left/right arrows
                    self:drawPageArrows()
                end
                if self.scrollProgress == scrollMin and ch > 0 then
                    gfx.setColor(gfx.kColorBlack)
                    gfx.drawPolygon(95, 120 - 8, 105, 120 - 8, 100, 117)

                    -- Page left/right arrows
                    self:drawPageArrows()

                    ts:updateBottomUI()

                    -- Page number
                    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
                    GameFnt:drawText(self.page, 100 - GameFnt:getTextWidth(self.page) / 2, 120 - GameFnt:getHeight())
                end
            end
        end

        -- Button Selection
        local function pageRelative(offset)
            local pNum = tonumber(self.page)
            return string.format("%03d", pNum + offset)
        end
        if self.scrollProgress == scrollMin then
            if pd.buttonIsPressed(pd.kButtonDown) or pd.buttonIsPressed(pd.kButtonUp) then
                ts:updateBottomUI()
            end
            if (pd.buttonJustPressed(pd.kButtonUp) or pd.buttonJustPressed(pd.kButtonDown) and scrollMin > scrollMax) and #self.buttons > 0 then
                if self.selection == 0 then
                    self.selection = 1
                    gfx.setColor(gfx.kColorBlack)
                else
                    self.selection = 0
                    gfx.setColor(gfx.kColorWhite)
                end
                -- Page left/right arrows
                self:drawPageArrows()
            end

            if self.selection ~= 0 then
                if pd.buttonJustPressed(pd.kButtonLeft) then
                    -- Show buttons!
                    self.selection = math.max(self.selection - 1, 1)
                    ts:updateBottomUI()
                end
                if pd.buttonJustPressed(pd.kButtonRight) then
                    -- Show buttons!
                    self.selection = math.min(self.selection + 1, #self.buttons)
                    ts:updateBottomUI()
                end

                if pd.buttonJustPressed(pd.kButtonA) then
                    self.buttons[self.selection].action()
                end
            else
                if pd.buttonJustPressed(pd.kButtonRight) and self.page ~= self.pageMax then
                    self:loadPage(pageRelative(1))
                end
                if pd.buttonJustPressed(pd.kButtonLeft) and self.page ~= "001" then
                    self:loadPage(pageRelative(-1))
                end
            end
        else
            -- Page switch
            if pd.buttonJustPressed(pd.kButtonRight) and self.page ~= self.pageMax then
                self:loadPage(pageRelative(1))
            end
            if pd.buttonJustPressed(pd.kButtonLeft) and self.page ~= "001" then
                self:loadPage(pageRelative(-1))
            end
        end
    end

    return ts
end
