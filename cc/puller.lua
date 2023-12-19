-- Pull items to specific slots

local DST_NAME = "right"
local DST_SLOTS = {}
local SRC_NAME = "top"

if not peripheral.hasType(DST_NAME, "inventory") then
    print(("Could not find an inventory on the %s side."):format(DST_NAME))
    return
end

local inv = peripheral.wrap(DST_NAME)
local running = true

local function pullItems(slot)
  local num = inv.pullItems(SRC_NAME, slot)
  if num > 0 then
    print(("Moved %ix to slot %i"):format(num, slot))
  end
end

local function loopMain()
  if #DST_SLOTS > 0 then
    while running do
      for _, slot in ipairs(DST_SLOTS) do
        pullItems(slot)
      end
    end
  else
    while running do
      for slot=1,inv.size() do
        pullItems(slot)
      end
    end
  end
end

local function loopEvent()
  print("Item Puller Running...")
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
