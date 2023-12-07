-- The uu crop library needs to be below the turtle.
-- Output needs to be in front.

local running = true
local function loopMain()
  while running do
    os.sleep(1)

    if turtle.suckDown() then
      turtle.dropDown()
      os.sleep(2)
      turtle.suckDown()
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
