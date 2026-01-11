local pd <const> = playdate
local gfx <const> = playdate.graphics

function pd.gameWillPause()
    local pauseImage = gfx.image.new(200, 120, gfx.kColorBlack)
    gfx.pushContext(pauseImage)
    CharacterSheet:drawStats()
    gfx.popContext()
    pd.setMenuImage(pauseImage:scaledImage(2))
end

function CharacterSheet()
    local cs = {}

    cs.items = {
    }

    cs.stats = {
        { "STR", 0 },
        { "CON", 0 },
        { "PSY", 0 },
        { "FTE", 0 }
    }
    cs.columnSelected = 1
    cs.statSelected = 1

    function cs:addItem(itemName)
        for i, v in ipairs(self.items) do
            if v[1] == itemName then
                self.items[i][2] += 1
                self:open()
                CurrentScreen = CharacterSheet

                self.columnSelected = 2
                self.statSelected = i
                self:drawStats()
                return
            end
        end
        table.insert(self.items, { itemName, 1 })
        self:open()
        CurrentScreen = CharacterSheet
        self.columnSelected = 2
        self.statSelected = #self.items
        self:drawStats()
    end

    function cs:getStat(statName)
        for _, stat in pairs(self.stats) do
            if stat[1] == statName then
                return stat[2]
            end
        end

        error("Invalid stat ".. statName)
    end

    function cs:open()
        self.screenshot = gfx.getDisplayImage()

        local tw = GameFnt:getTextWidth("Character Sheet")

        gfx.clear()
        gfx.setColor(gfx.kColorWhite)
        gfx.drawRect(5, 5, 190, 110)

        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(100 - tw / 2, 0, tw, 10)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        GameFnt:drawText("Character Sheet", 100 - tw / 2, 0)


        -- Default Stats

        self:drawStats()
    end

    function cs:drawStats()
        gfx.fillRect(6, 7, 188, 107)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        local statsText = "Stats:"
        for i, value in ipairs(self.stats) do
            statsText = statsText .. "\n " .. value[1] .. ": " .. value[2]
            if i == self.statSelected and self.columnSelected == 1 then
                statsText = statsText .. " < >"
            end
        end
        GameFnt:drawText(statsText, 10, 10)

        local itemsText = "Items:"
        for i, value in ipairs(self.items) do
            itemsText = itemsText .. "\n " .. value[1] .. ": x" .. value[2]
            if i == self.statSelected and self.columnSelected == 2 then
                itemsText = itemsText .. " < >"
            end
        end
        GameFnt:drawText(itemsText, 90, 10)

        GameFnt:drawText("<- A ->", 100 - GameFnt:getTextWidth("<- A ->") / 2, 100)
    end

    function cs:update()
        if pd.buttonJustPressed(pd.kButtonB) then
            CurrentScreen = TextScreen
            TextScreen:loadPage(TextScreen.page)
            return
        end
        if pd.buttonJustPressed(pd.kButtonA) then
            if self.columnSelected == 1 and #self.items > 0 then
                self.statSelected = math.min(#self.items, self.statSelected)

                self.columnSelected = 2
            elseif self.columnSelected == 2 then
                if self.items[self.statSelected][2] == 0 then
                    table.remove(self.items, self.statSelected)
                end
                self.statSelected = math.min(#self.stats, self.statSelected)

                self.columnSelected = 1
            end
            self:drawStats()
        end

        if pd.buttonJustPressed(pd.kButtonLeft) then
            if self.columnSelected == 1 then
                self.stats[self.statSelected][2] -= 1
            end
            if self.columnSelected == 2 then
                self.items[self.statSelected][2] = math.max(self.items[self.statSelected][2] - 1, 0)
            end
            self:drawStats()
        end
        if pd.buttonJustPressed(pd.kButtonRight) then
            if self.columnSelected == 1 then
                self.stats[self.statSelected][2] += 1
            end
            if self.columnSelected == 2 then
                self.items[self.statSelected][2] += 1
            end
            self:drawStats()
        end

        if pd.buttonJustPressed(pd.kButtonUp) then
            if self.columnSelected == 2 and self.statSelected > 1 then
                -- Clear item if zero
                if self.items[self.statSelected][2] == 0 then
                    table.remove(self.items, self.statSelected)
                end
            end
            self.statSelected = math.max(1, self.statSelected - 1)
            self:drawStats()
        end
        if pd.buttonJustPressed(pd.kButtonDown) then
            if self.columnSelected == 1 then
                self.statSelected = math.min(#self.stats, self.statSelected + 1)
            elseif self.statSelected < #self.items then
                -- Clear item if zero
                if self.items[self.statSelected][2] == 0 then
                    table.remove(self.items, self.statSelected)
                end
                -- Select next stat
                self.statSelected = math.min(#self.items, self.statSelected + 1)
            end
            self:drawStats()
        end
    end

    return cs
end
