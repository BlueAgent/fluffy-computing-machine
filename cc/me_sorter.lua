-- Requires Advanced Peripherals' ME Bridge

-- The following peripherals should be on the same computer network as this computer (and each other).
-- Bulk is the ME Bridge for the subnetwork where you put items that have a high count.
local BULK_BRIDGE_NAME = "meBridge_0"
-- Smol is the ME Bridge for the the subnetwork where you put items that have a low count.
local SMOL_BRIDGE_NAME = "meBridge_1"
-- Peripheral to push items into the Bulk Network (out of the Smol Network).
local BULK_INPUT_NAME = "ae2:interface_0"
-- Peripheral to push items into the Smol Network (out of the Bulk Network).
local SMOL_INPUT_NAME = "ae2:interface_1"
-- Items greater than or equal to this get moved to Bulk Network.
local BULK_MIN = 4096
-- Items less than or equal to this get moved to Smol Network.
local SMOL_MAX = 2048

local bulkMeBridge
local smolMeBridge
local bulkInput
local smolInput
local running = true

local function loopMain()
  while running do
    local totalAmounts = {}
    local bulkAmounts = {}
    local smolAmounts = {}
    for _, item in pairs(bulkMeBridge.listItems()) do
      if item.fingerprint ~= nil then
        bulkAmounts[item.fingerprint] = item.amount
        totalAmounts[item.fingerprint] = item.amount
      end
    end
    for _, item in pairs(smolMeBridge.listItems()) do
      if item.fingerprint ~= nil then
        smolAmounts[item.fingerprint] = item.amount
        local newTotal = totalAmounts[item.fingerprint]
        if newTotal == nil then
          newTotal = item.amount
        else
          newTotal = newTotal + item.amount
        end
        totalAmounts[item.fingerprint] = newTotal
      end
    end
    for fingerprint, amount in pairs(totalAmounts) do
      if not running then
        break
      end
      if amount <= SMOL_MAX and bulkAmounts[fingerprint] ~= nil then
        local filter = {fingerprint = fingerprint}
        local lastItem = nil
        local totalExported = 0
        while running do
          local item = bulkMeBridge.getItem(filter);
          if item == nil or item.amount == nil or item.amount <= 0 then
            break
          end

          lastItem = item
          totalExported = totalExported + bulkMeBridge.exportItemToPeripheral({fingerprint = fingerprint}, peripheral.getName(smolInput))
          os.sleep(0)
        end
        if lastItem ~= nil and totalExported > 0 then
          print(("Moved %ix %s from Bulk to Smol"):format(totalExported, lastItem.displayName))
        end
      end
      if amount >= BULK_MIN and smolAmounts[fingerprint] ~= nil then
        local filter = {fingerprint = fingerprint}
        local lastItem = nil
        local totalExported = 0
        while running do
          local item = smolMeBridge.getItem(filter);
          if item == nil or item.amount == nil or item.amount <= 0 then
            break
          end

          lastItem = item
          totalExported = totalExported + smolMeBridge.exportItemToPeripheral({fingerprint = fingerprint}, peripheral.getName(bulkInput))
          os.sleep(0)
        end
        if lastItem ~= nil and totalExported > 0 then
          print(("Moved %ix %s from Smol to Bulk"):format(totalExported, lastItem.displayName))
        end
      end
      os.sleep(0)
    end
    os.sleep(10)
  end
end

local function loopEvent()
  print("Bulk-Smol Sorter Running...")
  while running do
    local event, p1 = os.pullEventRaw()
    if event == 'terminate' then
      running = false
      break
    end
  end
end

local function main()
  bulkMeBridge = peripheral.wrap(BULK_BRIDGE_NAME)
  smolMeBridge = peripheral.wrap(SMOL_BRIDGE_NAME)
  bulkInput = peripheral.wrap(BULK_INPUT_NAME)
  smolInput = peripheral.wrap(SMOL_INPUT_NAME)

  if not bulkMeBridge or not peripheral.hasType(bulkMeBridge, "meBridge") then
    print(("Could not find Bulk ME Bridge on the network with the name '%s'."):format(BULK_BRIDGE_NAME))
    return
  end

  if not smolMeBridge or not peripheral.hasType(smolMeBridge, "meBridge") then
      print(("Could not find Smol ME Bridge on the network with the name '%s'."):format(SMOL_BRIDGE_NAME))
      return
  end

  if not bulkInput or not peripheral.hasType(bulkInput, "inventory") then
    print(("Could not find Bulk Input Inventory on the network with the name '%s'."):format(BULK_INPUT_NAME))
    return
  end

  if not smolInput or not peripheral.hasType(smolInput, "inventory") then
      print(("Could not find Smol Input Inventory on the network with the name '%s'."):format(SMOL_INPUT_NAME))
      return
  end

  local status, result = pcall(parallel.waitForAll, loopEvent, loopMain)
  if not status then
    if result == "Terminated" then
      running = false
      return
    end

    io.stderr:write("Error: ", result, "\n")
  end
end

while running do
  local status, result = pcall(main)
  if not status then
    io.stderr:write("Error in main(): ", result, "\n")
  end

  if running then
    status, result = os.sleep(5)
    if result == "Terminated" then
      running = false
    end
  end
end

print("Bye bye~")
