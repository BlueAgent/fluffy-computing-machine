-- Mekanism Fusion Reactor Controller

-- Reactor Logic Port. Make sure exactly one exists on the network.
local REACTOR_LOGIC_PORT_TYPE = "fissionReactorLogicAdapter"

local reactor
local lastStatus
local running = true

local function scram()
  local getStatusSuccess, getStatusResult = pcall(reactor.getStatus)
  if getStatusSuccess and getStatusResult then
    print("Scramming")
  end
  -- We call it and ignore if it fails just in-case.
  pcall(reactor.scram)
end

local function activate()
  if not reactor.getStatus() then
    print("Activating")
    reactor.activate()
  end
end

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
  if coolant.amount < coolantHeatingRate then
    return false, "Not Enough Coolant"
  end
  if reactor.getHeatedCoolantNeeded() < coolantHeatingRate then
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
      scram()
    else
      activate()
    end
    if lastStatus ~= status then
      lastStatus = status
      print("Status: " .. status)
    end
  end
  scram()
end

local function loopEvent()
  print("Mek Fission Computer Running...")
  while running do
    local event, p1 = os.pullEventRaw()
    if event == 'terminate' then
      running = false
      print("Terminating...")
      scram()
      break
    end
  end
end

local function main()
  reactor = peripheral.find(REACTOR_LOGIC_PORT_TYPE)
  lastStatus = nil
  if not reactor then
    print(("Could not find fission reactor logic adapter (type '%s'). Make sure a fission reactor logic port is connected to the network."):format(REACTOR_LOGIC_PORT_TYPE))
    return
  end

  local status, result = pcall(parallel.waitForAll, loopEvent, loopScram)
  scram()
  if not status then
    io.stderr:write("Error: ", result, "\n")
  end
end

while running do
  local status, result = pcall(main)
  if not status then
    io.stderr:write("Error in main(): ", result, "\n")
  end
  os.sleep(0.05)
end

scram()
print("Bye bye~")
