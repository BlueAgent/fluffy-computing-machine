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
    if currentItem ~= nil and lastItem ~= currentItem then
      if turtle.suckDown() then
        print(("Moved %s to Turtle"):format(currentItem.displayName))
      end
    end
    if turtle.detect() then
      currentItem = turtle.getItemDetail(turtle.getSelectedSlot())
      if turtle.drop() then
        print(("Moved %ix %s from Turtle"):format(currentItem.count, currentItem.displayName))
      end
    end
    lastItem = currentItem
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
