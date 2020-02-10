local ex = peripheral.find('Extractor')
local cvt = peripheral.find('AdvancedGear', function (name, p) return p.getName() == "CVT Unit" end)
local coil = peripheral.find('AdvancedGear', function (name, p) return p.getName() == "Industrial Coil" end)

if not ex then
  error("Extractor missing")
elseif not cvt then
  error("CVT missing")
elseif not coil then
  error("Coil missing")
end

local running = true
function loopMain()
  while running do
    local event, p1 = os.pullEventRaw()
    if event == 'terminate' then
      running = false
      coil.setTorque(0)
      coil.setSpeed(0)
      cvt.setRatio(0)
      print('Buh bye~ :3')
    end
  end
end

function hasAndCanWork()
  local stacks = ex.getAllStacks()
  if stacks[8] and stacks[8].all().qty >=63 then
    return false
  end
  for slot=1,4 do
    if stacks[slot] then
      return true
    end
  end
  return false
end

function loopSetCVTCoil()
  local mult = 8/20
  local stateMap = {
    torque = {time = 1.0  * mult, speed = 4096, torque = 4096, ratio = -2, next = "speed"},
    speed  = {time = 1.5  * mult, speed = 4096, torque = 512 , ratio = 32, next = "last"},
    last   = {time = 1.75 * mult, speed = 4096, torque = 4096, ratio =  0, next = "torque"},
    off    = {time = 80 / 20    , speed =    0, torque =    0, ratio =  0, next = "torque"}
  }
  local state = stateMap['off']
  while running do
    -- coil.setSpeed(state.speed)
    -- coil.setTorque(state.torque)
    -- cvt.setRatio(state.ratio)
    -- os.sleep(state.time)
    -- if hasAndCanWork() then
    --   state = stateMap[state.next]
    -- else
    --   state = stateMap["off"]
    -- end
  end
end

function loopSetCVTCoilDumb()
  coil.setSpeed(4096)
  while running do
    cvt.setRatio(-2)
    coil.setTorque(4096)
    os.sleep(0.4)
    cvt.setRatio(32)
    coil.setTorque(512)
    os.sleep(0.6)
    cvt.setRatio(1)
    coil.setTorque(4096)
    os.sleep(0.7)
  end
end

parallel.waitForAll(loopSetCVTCoilDumb)
