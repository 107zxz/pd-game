import "CoreLibs/graphics"

local pd = playdate
local gfx = pd.graphics
local geo = pd.geometry

local sampleDie2 = {
    geo.polygon.new(
        16, -16,
        -16, -16,
        -16, 16,
        16, 16,
        16, -16
    ),
    geo.point.new(
        0, 0
    ),
    geo.point.new(
        -10, -10
    ),
    geo.point.new(
        -10, 0
    ),
    geo.point.new(
        -10, 10
    ),
    geo.point.new(
        10, 10
    ),
    geo.point.new(
        10, 0
    ),
    geo.point.new(
        10, -10
    ),
}

local function newDie(pips)
    return {
        tx = geo.point.new(100 + math.random(-32, 32), 60),
        rx = 45,
        px = geo.vector2D.new(25 * math.random(-2, 2), 25 * math.random(-2, 2)),
        rpx = math.random(-64, 64),
        pips = pips
    }
end

function DiceScreen()
    local ds = {}

    ---@type table
    ds.dice = {}

    function ds:roll(nDice)
        ds.dice = {}

        for _ = 1, nDice do
            table.insert(ds.dice, newDie(math.random(1, 6)))
        end

        self.frameCount = 0

        -- Screenshot old
        ds.screenPic = gfx.getDisplayImage()
    end

    function ds:drawDice()
        for di, d in ipairs(ds.dice) do
            -- Clear old die
            --if d.otr ~= nil then
            --gfx.setColor(gfx.kColorBlack)
            --for dx = -1, 1 do
            --for dy = -1, 1 do
            --local biggerTransform = d.otr:translatedBy(dx, dy)
            --gfx.fillPolygon(sampleDie[1] * biggerTransform)
            --end
            --end
            --end

            local diceTransform = geo.affineTransform.new()
            diceTransform:rotate(d.rx)
            diceTransform:translate(d.tx.x, d.tx.y)

            ds.dice[di].otr = diceTransform

            for i, p in ipairs(sampleDie2) do
                if i == 1 then
                    gfx.setColor(gfx.kColorWhite)
                    gfx.fillPolygon(p * diceTransform)
                    gfx.setColor(gfx.kColorBlack)
                    gfx.drawPolygon(p * diceTransform)
                else
                    -- Pip conditions, yes I'm a psychopath
                    local drawPip = true
                    -- Center
                    if i == 2 and (d.pips == 2 or d.pips == 4 or d.pips == 6) then
                        drawPip = false
                    end
                    -- Top Left
                    if i == 3 and (d.pips == 1 or d.pips == 2 or d.pips == 3) then
                        drawPip = false
                    end
                    -- Middle Left
                    if i == 4 and (d.pips ~= 6) then
                        drawPip = false
                    end
                    -- Bottom Left
                    if i == 5 and (d.pips == 1) then
                        drawPip = false
                    end
                    -- Bottom Right
                    if i == 6 and (d.pips == 1 or d.pips == 2 or d.pips == 3) then
                        drawPip = false
                    end
                    -- Middle Right
                    if i == 7 and (d.pips ~= 6) then
                        drawPip = false
                    end
                    -- Top Right
                    if i == 8 and (d.pips == 1) then
                        drawPip = false
                    end

                    if drawPip then
                        gfx.fillCircleAtPoint(p * diceTransform, 4)
                    end
                end
            end
        end
    end

    function ds:updateTheDice()
        self:drawDice()

        -- Momentum
        for di, d in ipairs(ds.dice) do
            self.dice[di].rx += self.dice[di].rpx
            self.dice[di].tx += self.dice[di].px

            -- Slow down!
            self.dice[di].rpx *= 0.9
            self.dice[di].px *= 0.9

            -- Bounce
            local bounce = false
            if self.dice[di].tx.x > 200 - 16 then
                self.dice[di].tx.x = 200 - 16
                self.dice[di].px.x *= -1
                bounce = true
            end
            if self.dice[di].tx.y > 120 - 16 then
                self.dice[di].tx.y = 120 - 16
                self.dice[di].px.y *= -1
                bounce = true
            end
            if self.dice[di].tx.x < 16 then
                self.dice[di].tx.x = 16
                self.dice[di].px.x *= -1
                bounce = true
            end
            if self.dice[di].tx.y < 16 then
                self.dice[di].tx.y = 16
                self.dice[di].px.y *= -1
                bounce = true
            end

            -- Bounce momentum
            if bounce then
                self.dice[di].px.x *= math.random(3, 4) / 4
                self.dice[di].px.y *= math.random(3, 4) / 4
            end
        end
    end

    function ds:resolveTheDice()
        -- Lerp dice to final position
        local dicetotal = 0

        for di, dd in ipairs(self.dice) do
            self.dice[di].tx.x = (dd.tx.x + (di - 1) * 40 + 100 + 20 - #self.dice * 20) / 2
            self.dice[di].tx.y = (dd.tx.y + 60) / 2

            self.dice[di].rx = dd.rx / 2

            dicetotal += dd.pips
        end
        gfx.clear(gfx.kColorWhite)
        ds:drawDice()

        gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
        local totalText = string.format("Total: %d", dicetotal)
        GameFnt:drawTextAligned(totalText, 100 - GameFnt:getTextWidth(totalText) / 2, 30, gfx.kAlignCenter)

        local resultText = "Strength check " .. (dicetotal > 6 and "PASS" or "FAIL")
        GameFnt:drawTextAligned(resultText, 100 - GameFnt:getTextWidth(resultText) / 2, 85, gfx.kAlignCenter)
    end

    function ds:update()
        gfx.setBackgroundColor(gfx.kColorBlack)

        gfx.setColor(gfx.kColorWhite)

        if self.frameCount < 40 then
            self:updateTheDice()
        elseif self.frameCount < 50 then
            self:resolveTheDice()
        elseif pd.buttonJustPressed(pd.kButtonA) or pd.buttonJustPressed(pd.kButtonB) then
            CurrentScreen = TextScreen
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
            self.screenPic:draw(0, 0)
        end

        self.frameCount += 1
    end

    return ds
end
