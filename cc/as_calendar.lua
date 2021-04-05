-- Moon constants
local MOON_PHASE_DESCS = {
  [0] = "Full Moon",
  "Waning Gibbous",
  "Third Quarter",
  "Waning Crescent",
  "New Moon",
  "Waxing Crescent",
  "First Quarter",
  "Waxing Gibbous"
}
local MoonPhase = {
  FULL = 0,
  WANING_3_4 = 1,
  WANING_1_2 = 2,
  WANING_1_4 = 3,
  NEW = 4,
  WAXING_1_4 = 5,
  WAXING_1_2 = 6,
  WAXING_3_4 = 7
}
MOON_PHASE_SIZE = 8

-- Manual Config
local SOLAR_ECLIPSE_DAY = 1734 -- From debug menu on the day of the eclipse
local CONSTELLATION_PHASE_RANGES = {
  discidia  = {from = MoonPhase.WAXING_3_4, to = MoonPhase.WANING_1_4},
  armara    = {from = MoonPhase.WANING_1_4, to = MoonPhase.WANING_3_4},
  vicio     = {from = MoonPhase.WAXING_1_2, to = MoonPhase.WANING_1_2},
  aevitas   = {from = MoonPhase.WAXING_1_4, to = MoonPhase.WANING_3_4},
  evorsio   = {from = MoonPhase.WANING_3_4, to = MoonPhase.WAXING_1_4},
  lucerna   = {from = MoonPhase.FULL, to = MoonPhase.NEW},
  mineralis = {from = MoonPhase.WAXING_1_4, to = MoonPhase.WANING_3_4},
  octans    = {from = MoonPhase.WANING_3_4, to = MoonPhase.WAXING_1_4},
  bootes    = {from = MoonPhase.FULL, to = MoonPhase.NEW},
  fornax    = {from = MoonPhase.WANING_3_4, to = MoonPhase.WAXING_1_4},
}

-- Constants
local TICKS_PER_DAY = 24000
local TICKS_PER_HOUR = 1000
local SUNRIZE_OFFSET = -6000
local SOLAR_ECLIPSE_CYCLE_LENGTH = 36

-- Constellation Colours
local CONSTELLATION_DISCIDIA   = 0xE01903
local CONSTELLATION_ARMARA     = 0xB7BBB8
local CONSTELLATION_VICIO      = 0x00BDAD
local CONSTELLATION_AEVITAS    = 0x2EE400
local CONSTELLATION_EVORSIO    = 0xA00100
local CONSTELLATION_LUCERNA    = 0xFFE709
local CONSTELLATION_MINERALIS  = 0xCB7D0A
local CONSTELLATION_HOROLOGIUM = 0x7D16B4
local CONSTELLATION_OCTANS     = 0x706EFF
local CONSTELLATION_BOOTES     = 0xD41CD6
local CONSTELLATION_FORNAX     = 0xFF4E1B
local CONSTELLATION_PELOTRIO   = 0xEC006B
local CONSTELLATION_GELU       = 0x758BA8
local CONSTELLATION_ULTERIA    = 0x347463
local CONSTELLATION_ALCARA     = 0x802952
local CONSTELLATION_VORUX      = 0xA8881E

-- Constellation Definitions
local Constellation = {
  name = "Unknown",
  color = 0xFFFFFF,
  doesShowUp = function(dayTime) return false end
}
function Constellation:new(o)
  local o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local Major = Constellation:new()
function Major:new(name, color)
  local o = {
    name = name,
    color = color,
    doesShowUp = function(dayTime) return isMoonPhaseInRange(getMoonPhase(dayTime), CONSTELLATION_PHASE_RANGES[name]) end
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

local Weak = Constellation:new()
function Weak:new(name, color)
  local o = {
    name = name,
    color = color,
    doesShowUp = function(dayTime) return isMoonPhaseInRange(getMoonPhase(dayTime), CONSTELLATION_PHASE_RANGES[name]) end
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

local WeakSpecial = Constellation:new()
function WeakSpecial:new(name, color, doesShowUp)
  local o = {
    name = name,
    color = color,
    doesShowUp = doesShowUp
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

local Minor = Constellation:new()
function Minor:new(name, color, moonPhases)
  local o = {
    name = name,
    color = color,
    doesShowUp = function(dayTime)
      targetMoonPhase = getMoonPhase(dayTime)
      for moonPhase in moonPhases do
        if moonPhase == targetMoonPhase then
          return true
        end
      end
      return false
    end
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

local CONSTELLATIONS_ORDERED = {}
function register(constellation)
  table.insert(CONSTELLATIONS_ORDERED, constellation)
end
local Constellations = {
  discidia   = register(Major:new("discidia", CONSTELLATION_DISCIDIA)),
  armara     = register(Major:new("armara", CONSTELLATION_ARMARA)),
  vicio      = register(Major:new("vicio", CONSTELLATION_VICIO)),
  aevitas    = register(Major:new("aevitas", CONSTELLATION_AEVITAS)),
  evorsio    = register(Major:new("evorsio", CONSTELLATION_EVORSIO)),
  lucerna    = register(Weak:new("lucerna", CONSTELLATION_LUCERNA)),
  mineralis  = register(Weak:new("mineralis", CONSTELLATION_MINERALIS)),
  horologium = register(WeakSpecial:new("horologium", CONSTELLATION_HOROLOGIUM, function(dayTime)
    return (getDay(dayTime) - SOLAR_ECLIPSE_DAY) % SOLAR_ECLIPSE_CYCLE_LENGTH == 0
  end)),
  octans     = register(Weak:new("octans", CONSTELLATION_OCTANS)),
  bootes     = register(Weak:new("bootes", CONSTELLATION_BOOTES)),
  fornax     = register(Weak:new("fornax", CONSTELLATION_FORNAX)),
  pelotrio   = register(WeakSpecial:new("pelotrio", CONSTELLATION_PELOTRIO, function(dayTime)
    local moonPhase = getMoonPhase(dayTime)
    return moonPhase == MoonPhase.NEW or moonPhase == MoonPhase.FULL
  end)),
}

-- Day 0: Time 0 ticks
--     CC Day 1, Time 06.000 (Sunrise)
-- Day 0: Time 6000 ticks
--     CC Day 1, Time 12.000 (Midday)
-- Day 0: Time 17999 ticks
--     CC Day 1, Time 23.999 (Almost midnight)
-- Day 0: Time 18000 ticks
--     CC Day 2, Time 00.000 (Midnight)
-- Day 0: Time 23999 ticks
--     CC Day 2, Time 05.999
-- Day 1: Time 0 ticks (24000 ticks total)
--     CC Day 2, Time 06.000 (Sunrise)

-- Gets Minecraft's total day time value in ticks.
function getDayTime()
  return (os.day() - 1) * TICKS_PER_DAY + os.time() * TICKS_PER_HOUR + SUNRIZE_OFFSET
end

-- Gets Minecraft's day starting at 0.
-- The day starts and increments at sunrize.
function getDay(dayTime)
  dayTime = dayTime or getDayTime()
  return math.floor(dayTime / TICKS_PER_DAY)
end

-- Gets Minecraft's time of day in ticks.
-- Normally 0 is Sunrise, 6000 Midday, 12000 Sunset and 18000 Midnight.
function getTimeOfDay(dayTime)
  dayTime = dayTime or getDayTime()
  return dayTime % TICKS_PER_DAY
end

-- Gets the moon phase
function getMoonPhase(dayTime)
  dayTime = dayTime or getDayTime()
  return (math.floor(dayTime / TICKS_PER_DAY) % MOON_PHASE_SIZE + MOON_PHASE_SIZE) % MOON_PHASE_SIZE;
end

-- Checks if the the moon phase is in the range
function isMoonPhaseInRange(moonPhase, range)
  if range.from <= range.to then
    return range.from <= moonPhase and moonPhase <= range.to
  else
    return moonPhase <= range.to or range.from <= moonPhase
  end
end

print("DayTime: " .. getDayTime() .. " Day: " .. getDay() .. " Time: " .. getTimeOfDay())
print("MoonPhase: " .. getMoonPhase() .. " " .. MOON_PHASE_DESCS[getMoonPhase()])
for i, c in pairs(CONSTELLATIONS_ORDERED) do
  print(tostring(c.doesShowUp()) .. " " .. c.name)
end
