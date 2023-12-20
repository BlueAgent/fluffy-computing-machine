-- Mekanism Fusion Reactor Controller

-- Reactor Logic Port
local REACTOR_NAME = "back"

if not peripheral.hasType(REACTOR_NAME, "fissionReactorLogicAdapter") then
  print(("Could not find reactor logic adapter named '%s'. Make sure a logic port is connected to the network under that name."):format(REACTOR_NAME))
  return
end

local reactor = peripheral.wrap(REACTOR_NAME)
local running = true
local lastStatus = nil
local scramming = false

local function isSafeToRun()
  if reactor.getDamagePercent() > 0 then
    return false, "Damage Greater than Zero"
  end
  local maxBurnRate = reactor.getMaxBurnRate()
  local coolant = reactor.getCoolant()
  local coolantHeatingRate
  if coolant.name == "mekanism:water" then
    coolantHeatingRate = maxBurnRate * 20000
  else
    coolantHeatingRate = maxBurnRate * 200000
  end
  if coolant.amount < coolantHeatingRate * 2 then
    return false, "Not Enough Coolant"
  end
  local heatedCoolant = reactor.getHeatedCoolant()
  if heatedCoolant.amount >= coolantHeatingRate * 2 then
    return false, "No Space for Heated Coolant"
  end
  if reactor.getWasteNeeded() <= maxBurnRate * 2 then
    return false, "No Space for Waste"
  end
  return true, "OK"
end

local function loopScram()
  while running do
    local safe, status = isSafeToRun()
    if not safe then
      reactor.scram()
      if not scramming then
        scramming = true
        print("Scramming!")
      end
    else
      reactor.activate()
      if scramming then
        scramming = false
        print("Activating...")
      end
    end
    if lastStatus ~= status then
      lastStatus = status
      print("Status: " .. status)
    end
  end
  reactor.scram()
  scramming = true
end

local function loopEvent()
  print("Mek Fission Computer Running...")
  while running do
    local event, p1 = os.pullEventRaw()
    if event == 'terminate' then
      running = false
      print("Bye bye~")
      reactor.scram()
      break
    end
  end
end

local status, result = pcall(parallel.waitForAll, loopEvent, loopScram)
reactor.scram()

if not status then
  io.stderr:write("Exited with error: ", result)
end
