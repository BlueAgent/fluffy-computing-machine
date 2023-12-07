-- The uu crop library needs to be below the turtle.
-- Output needs to be in front.
local CROP_SEED_SLOT = 0 + 1
local uumCropAna = peripheral.find("ic2:uu_crop_library")

local running = true
local function loopMain()
  local lastItem = nil
  while running do
    os.sleep(2)

    local currentItem = uumCropAna.getItemDetail(CROP_SEED_SLOT)
    if currentItem ~= nil and lastItem == currentItem then
      if turtle.suckDown() then
        lastItem = nil
      else
        lastItem = uumCropAna.getItemDetail(CROP_SEED_SLOT)
      end
    else
      lastItem = currentItem
    end

    local selectedItem = turtle.getItemDetail(turtle.getSelectedSlot(), true)
    if selectedItem ~= nil and turtle.drop() then
      print(("Moved %ix %s"):format(selectedItem.count, selectedItem.displayName))
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
