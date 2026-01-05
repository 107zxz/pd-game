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

    function ds:roll()
        ds.dice = {
            newDie(1),
            newDie(2),
            newDie(3),
            newDie(4),
            newDie(5),
            newDie(6)
        }
    end

    function ds:update()
        gfx.setBackgroundColor(gfx.kColorBlack)

        gfx.setColor(gfx.kColorWhite)
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

            -- Momentum
            ds.dice[di].rx += ds.dice[di].rpx
            ds.dice[di].tx += ds.dice[di].px

            -- Slow down!
            ds.dice[di].rpx *= 0.9
            ds.dice[di].px *= 0.9

            -- Bounce
            local bounce = false
            if ds.dice[di].tx.x > 200 - 16 then
                ds.dice[di].tx.x = 200 - 16
                ds.dice[di].px.x *= -1
                bounce = true
            end
            if ds.dice[di].tx.y > 120 - 16 then
                ds.dice[di].tx.y = 120 - 16
                ds.dice[di].px.y *= -1
                bounce = true
            end
            if ds.dice[di].tx.x < 16 then
                ds.dice[di].tx.x = 16
                ds.dice[di].px.x *= -1
                bounce = true
            end
            if ds.dice[di].tx.y < 16 then
                ds.dice[di].tx.y = 16
                ds.dice[di].px.y *= -1
                bounce = true
            end

            -- Bounce momentum
            if bounce then
                ds.dice[di].px.x *= math.random(3, 4) / 4
                ds.dice[di].px.y *= math.random(3, 4) / 4
            end
        end
    end

    return ds
end
