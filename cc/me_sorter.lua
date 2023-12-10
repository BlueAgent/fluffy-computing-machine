-- Requires Advanced Peripherals' ME Bridge

-- Bulk is the subnetwork where you put items that have a high count.
local BULK_SIDE = "left"
-- Type is the subnetwork where you put items that have a low count.
local SMOL_SIDE = "right"
-- Items greater than or equal to this get moved to Bulk Network.
local BULK_MIN = 512
-- Items less than or equal to this get moved to Smol Network.
local SMOL_MAX = 64
-- Direction to push items out of the Bulk Network (and into the Smol Network).
local BULK_PUSH_SIDE = "top"
-- Direction to push items out of the Smol Network (and into the Bulk Network).
local SMOL_PUSH_SIDE = "top"

if peripheral.getType(BULK_SIDE) ~= "meBridge" then
    print(("Could not find Bulk ME Bridge on the %s side."):format(BULK_SIDE))
    return
end

if peripheral.getType(SMOL_SIDE) ~= "meBridge" then
    print(("Could not find Smol ME Bridge on the %s side."):format(SMOL_SIDE))
    return
end

local meBulk = peripheral.wrap(BULK_SIDE)
local meSmol = peripheral.wrap(SMOL_SIDE)
local running = true

local function loopMain()
  while running do
    local totalAmounts = {}
    local bulkAmounts = {}
    local smolAmounts = {}
    for item in meBulk.listItems() do
      if item.fingerprint ~= nil then
        bulkAmounts[item.fingerprint] = item.amount
        totalAmounts[item.fingerprint] = item.amount
      end
    end
    for item in meSmol.listItems() do
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
    for fingerprint, amount in totalAmounts do
      if not running then
        break
      end
      if amount <= SMOL_MAX and bulkAmounts[fingerprint] ~= nil then
        local filter = {fingerprint = fingerprint}
        local lastItem = nil
        local numExported = 0
        while running do
          local item = meBulk.getItem(filter);
          if item == nil or item.amount <= 0 then
            break
          end

          lastItem = item
          numExported = numExported + meBulk.exportItem({fingerprint = fingerprint}, BULK_PUSH_SIDE)
        end
        if lastItem ~= nil and numExported > 0 then
          print(("Moved %ix %s from Bulk to Smol"):format(numExported, lastItem.displayName))
        end
      end
      if amount >= BULK_MIN and smolAmounts[fingerprint] ~= nil then
        local filter = {fingerprint = fingerprint}
        local lastItem = nil
        local numExported = 0
        while running do
          local item = meSmol.getItem(filter);
          if item == nil or item.amount <= 0 then
            break
          end

          lastItem = item
          numExported = numExported + meSmol.exportItem({fingerprint = fingerprint}, SMOL_PUSH_SIDE)
        end
        if lastItem ~= nil and numExported > 0 then
          print(("Moved %ix %s from Smol to Bulk"):format(numExported, lastItem.displayName))
        end
      end
    end
  end
end

local function loopEvent()
  print("Bulk-Smol Sorter Running...")
  while running do
    local event, p1 = os.pullEventRaw()
    if event == 'terminate' then
      running = false
      print("Bye bye~")
      break
    end
  end
end

parallel.waitForAll(loopEvent, loopMain)