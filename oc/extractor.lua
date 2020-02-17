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

local previousStacks = {}
local stuckSlots = {8,9}
local STUCK_STACK_LIMIT = 8
function isStuck(stacks)
  local pStacks = previousStacks
  previousStacks = stacks
  if stacks then
    same = 0
    for _, slot in pairs(stuckSlots) do
      local prev = pStacks[slot]
      local curr = stacks[slot]
      if prev and curr and prev.id == curr.id and (prev.amt == curr.amt or curr.amt > STUCK_STACK_LIMIT) then
        same = same + 1
      end
    end
    if same == table.getn(stuckSlots) then
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

local shouldRunLast = false
local stuckCounter = 0
local STUCK_LIMIT = 2
function hasAndCanWork()
  local stacks = ex.getAllStacks()
  if not stacks then stacks = {} end
  if hasWork(stacks) then
    if isStuck(stacks) then
      if stuckCounter == STUCK_LIMIT then
        print("Stuck")
      end
      stuckCounter = stuckCounter + 1
    else
      if stuckCounter ~= 0 then
        print("Unstuck after " .. stuckCounter .. " cycles")
        stuckCounter = 0
      end
    end
    local shouldRun = stuckCounter < STUCK_LIMIT
    if shouldRun ~= shouldRunLast then
      shouldRunLast = shouldRun
      if shouldRun then
        print("Starting Extractor")
      else
        print("Stopping Extractor")
      end
    end
    return shouldRun
  end
  return false
end

while true do
  if hasAndCanWork() then
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
    os.sleep(1)
  end
end
