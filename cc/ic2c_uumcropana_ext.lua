local CROP_SEED_SLOT = 0 + 1
local outputInvName = "left"
local outputInv = peripheral.wrap(outputInvName)
local uumCropAnaName = "bottom"
local uumCropAna = peripheral.wrap(uumCropAnaName)

local running = true
local function loopMain()
  local lastItem = nil
  while running do
    os.sleep(2)
    local currentItem = uumCropAna.getItemDetail(CROP_SEED_SLOT)
    if lastItem == currentItem then
      if currentItem ~= nil then
        local numMoved = outputInv.pullItems(uumCropAnaName, CROP_SEED_SLOT)
        if numMoved > 0 then
          print(("Moved %ix %s"):format(numMoved, currentItem.displayName))
        end
      end
    else
      lastItem = currentItem
    end
  end
end

local function loopEvent()
  while running do
    local event, p1 = os.pullEventRaw()
    if event == 'terminate' then
      running = false
      break
    end
  end
end

parallel.waitForAll(loopEvent, loopMain)
