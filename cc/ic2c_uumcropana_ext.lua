local CROP_SEED_SLOT = 0 + 1
local outputSide = "front"
local uumCropAnaPushSide = "top"
local uumCropAna = peripheral.wrap("ic2:uu_crop_library")

local running = true
local function loopMain()
  local lastItem = nil
  while running do
    os.sleep(2)
    local currentItem = uumCropAna.getItemDetail(CROP_SEED_SLOT)
    if currentItem ~= nil and lastItem ~= currentItem then
      local numMoved = uumCropAna.pushItems(uumCropAnaPushSide, CROP_SEED_SLOT, turtle.getSelectedSlot())
      if numMoved > 0 then
        print(("Moved %ix %s to Turtle"):format(numMoved, currentItem.displayName))
      end
    end
    local numMoved = turtle.pushItems(outputSide, turtle.getSelectedSlot())
    if numMoved > 0 then
      print(("Moved %ix %s from Turtle"):format(numMoved, currentItem.displayName))
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
