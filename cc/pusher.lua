-- Push items from specific slots

local SRC_NAME = "top"
local SRC_SLOTS = {}
local DST_NAME = "right"

if not peripheral.hasType(SRC_NAME, "inventory") then
    print(("Could not find an inventory on the %s side."):format(SRC_NAME))
    return
end

local inv = peripheral.wrap(SRC_NAME)
local running = true

local function pushItems(slot)
  local num = inv.pushItems(DST_NAME, slot)
  print(("Moved %ix from slot %i"):format(num, slot))
end

local function loopMain()
  if #SRC_SLOTS > 0 then
    while running do
      for _, slot in ipairs(SRC_SLOTS) do
        pushItems(slot)
      end
    end
  else
    while running do
      for slot=1,inv.size() do
        pushItems(slot)
      end
    end
  end
end

local function loopEvent()
  print("Item Pusher Running...")
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
