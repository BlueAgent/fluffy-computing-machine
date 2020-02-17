local component = require("component")

local ex = component.Extractor
local cvt
local coil

for address, componentType in component.list('AdvancedGear') do
  local p = component.proxy(address)
  if p.getName() == "CVT Unit" then
    cvt = p
  elseif p.getName() == "Industrial Coil" then
    coil = p
  end
end

if not ex then
  error("Extractor missing")
elseif not cvt then
  error("CVT missing")
elseif not coil then
  error("Coil missing")
end

local previousStacks
function isStuck(stacks)
  local pStacks = previousStacks
  previousStacks = stacks
  if stacks then
    same = 0
    for slot=2,9 do
      local prev = pStacks[slot]
      local curr = stacks[slot]
      if (not prev and not curr) or (prev and curr and prev.id == curr.id and prev.amt == curr.amt) then
        same = same + 1
      end
    end
    if same == 8 then
      return true
    end
  end
  return false
end

function hasWork(stacks)
  for slot=1,4 do
    if stacks[slot] then
      return true
    end
  end
  return false
end

local stuckCounter = 0
function hasAndCanWork()
  local stacks = ex.getAllStacks()
  if hasWork(stacks) then
    if isStuck(stacks) then
      if stuckCounter == 0 then
        print("Stuck")
      end
      stuckCounter = stuckCounter + 1
    else
      if stuckCounter != 0 then
        print("Unstuck after " .. stuckCounter .. " cycles")
        stuckCounter = 0
      end
    end
    return stuckCounter == 0
  end
  return false
end

local wasRunning = false
while true do
  os.sleep(1)
  if hasAndCanWork() then
    if not wasRunning then
      print("Starting Extractor")
    end
    wasRunning = true
    coil.setSpeed(4096)
    cvt.setRatio(-2)
    coil.setTorque(4096)
    os.sleep(0.4)
    cvt.setRatio(32)
    coil.setTorque(512)
    os.sleep(0.6)
    cvt.setRatio(1)
    coil.setTorque(4096)
    os.sleep(0.7)
  else
    coil.setSpeed(0)
    coil.setTorque(0)
    cvt.setRatio(0)
    if wasRunning then
      print("Stopped Extractor")
    end
    wasRunning = false
  end
end
