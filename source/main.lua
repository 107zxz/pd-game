import "CoreLibs/sprites"
import "CoreLibs/graphics"

local pd <const> = playdate
local gfx <const> = playdate.graphics

local SCROLL_PERIOD <const> = 360 * 4

gfx.setBackgroundColor(gfx.kColorBlack)
gfx.setColor(gfx.kColorWhite)

gfx.clear(gfx.kColorBlack)

local scroll = 0
local oldScroll = scroll
local change = 0

local iSlot = 2

local amyImg = gfx.image.new("amy.png")
assert(amyImg ~= nil, "Couldn't load amy.png")
local normalFont = gfx.font.new("Ubuntu-Regular.ttf")
gfx.setFont(normalFont)

-- local wasCrankDocked = true

local function draw_tunnel()
   -- gfx.setDrawOffset(math.random(32),0)

   -- Clear old sines
   gfx.setColor(gfx.kColorBlack)
   gfx.drawSineWave(40, 0, 40, 248, 16, 16, SCROLL_PERIOD, oldScroll % SCROLL_PERIOD)
   gfx.drawSineWave(400 - 48, 0, 400 - 48, 248, 16, 16, SCROLL_PERIOD, oldScroll % SCROLL_PERIOD + SCROLL_PERIOD / 2)
   -- Draw new sines
   gfx.setColor(gfx.kColorWhite)
   gfx.drawSineWave(40, 0, 40, 248, 16, 16, SCROLL_PERIOD, scroll % SCROLL_PERIOD)
   gfx.drawSineWave(400 - 48, 0, 400 - 48, 248, 16, 16, SCROLL_PERIOD, scroll % SCROLL_PERIOD + SCROLL_PERIOD / 2)

   -- Clear old stars
   local oldStarScroll <const> = (oldScroll / 1.5) % SCROLL_PERIOD / 4 - 32
   local starScroll <const> = (scroll / 1.5) % SCROLL_PERIOD / 4 - 32

   gfx.setColor(gfx.kColorBlack)
   gfx.drawSineWave(
      64,
      240 - oldStarScroll,
      400 - 64,
      240 - oldStarScroll,
      32,
      32,
      800,
      450
   )
   -- Draw new stars
   gfx.setColor(gfx.kColorWhite)
   -- gfx.setDitherPattern(0.7, gfx.image.kDitherTypeBayer8x8)
   gfx.setClipRect(68, 240 - starScroll - 32, 262, 32)
   gfx.drawSineWave(
      64,
      240 - starScroll,
      400 - 64,
      240 - starScroll,
      32,
      32,
      800,
      450
   )
   gfx.clearClipRect()
end

local function draw_progress()
   gfx.setDrawOffset(0, scroll / 180)
   gfx.setColor(gfx.kColorBlack)
   gfx.fillRect(400 - 16, 6, 8, 15)
   gfx.setColor(gfx.kColorWhite)
   gfx.fillPolygon(400 - 16, 8, 400 - 12, 12, 400 - 8, 8, 400 - 8, 16, 400 - 12, 20, 400 - 16, 16)
   gfx.setDrawOffset(0, 0)
end

draw_tunnel()

-- Progress Rect

-- draw_progress()

function pd.update()
   change = pd.getCrankChange() * 2

   if pd.buttonJustPressed(pd.kButtonUp) or pd.buttonJustPressed(pd.kButtonDown) then
      gfx.setColor(gfx.kColorBlack)
      gfx.fillRect(100, 80, 400 - 200, 240 - 160)

      gfx.setColor(gfx.kColorWhite)
      gfx.drawRect(400 - 20, 4, 16, 240 - 8)
   end

   if pd.buttonIsPressed(pd.kButtonDown) then
      change += 24

      draw_progress()
   end
   if pd.buttonIsPressed(pd.kButtonUp) then
      change -= 24

      draw_progress()
   end
   if pd.buttonJustPressed(pd.kButtonLeft) or pd.buttonJustPressed(pd.kButtonRight) then
      if pd.buttonJustPressed(pd.kButtonLeft) then
         iSlot -= 1
      end
      if pd.buttonJustPressed(pd.kButtonRight) then
         iSlot += 1
      end

      iSlot = (iSlot - 1) % 2 + 1

      gfx.setColor(gfx.kColorBlack)
      gfx.fillRect(400 - 20, 4, 16, 240 - 8)

      -- Draw main options
      gfx.fillRect(100, 80, 400 - 200, 240 - 160)
      gfx.setColor(gfx.kColorWhite)
      gfx.drawRect(100, 80, 400 - 200, 240 - 160)
      amyImg:draw(110, 85)
      gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
      gfx.drawText("Amy", 184, 85)

      for i = 0, 1 do
         gfx.drawRect(184 + 50 * i, 106, 44, 44)
         if i + 1 == iSlot then
            gfx.drawRect(184 + 50 * i + 2, 106 + 2, 40, 40)
         end
      end
   end

   oldScroll = scroll
   scroll += change

   if change ~= 0 then
      draw_tunnel()
      if not pd.isCrankDocked() then
         draw_progress()
      end
   end
end
