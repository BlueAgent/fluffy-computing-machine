-- The uu crop library needs to be below the turtle.
-- Output needs to be in front.
local CROP_SEED_SLOT = 0 + 1
local uumCropAna = peripheral.find("ic2:uu_crop_library")

local running = true
local function loopSuck()
  local hadSeed = false
  while running do
    os.sleep(2)
    local hasSeed = uumCropAna.getItemDetail(CROP_SEED_SLOT) ~= nil
    if hadSeed ~= hasSeed then
      hadSeed = hasSeed
    elseif hadSeed and hasSeed then
      turtle.suckDown()
    end
  end
end

local function loopDrop()
  while running do
    os.sleep(2)
    for i = 1, 16 do
      if turtle.getItemCount(i) > 0 then
        turtle.select(i)
        local selectedItem = turtle.getItemDetail(turtle.getSelectedSlot(), true)
        if selectedItem ~= nil and turtle.drop() then
          print(("Moved %ix %s"):format(selectedItem.count, selectedItem.displayName))
        end
      end
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

parallel.waitForAll(loopEvent, loopSuck, loopDrop)
