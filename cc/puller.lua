-- Pull items from specific slots

local SRC_NAME = "right"
local SRC_SLOTS = {}
local DST_NAME = "left"

if not peripheral.hasType(SRC_NAME, "inventory") then
  print(("Could not find an inventory on the %s side."):format(DST_NAME))
  return
end

if not peripheral.hasType(DST_NAME, "inventory") then
    print(("Could not find an inventory on the %s side."):format(DST_NAME))
    return
end

local src = peripheral.wrap(SRC_NAME)
local dst = peripheral.wrap(DST_NAME)
local running = true

local function pullItems(slot)
  local num = dst.pullItems(SRC_NAME, slot)
  if num > 0 then
    print(("Moved %ix from slot %i"):format(num, slot))
  end
  return num
end

local function loopMain()
  if #SRC_SLOTS > 0 then
    while running do
      for _, slot in ipairs(SRC_SLOTS) do
        while pullItems(slot) > 0 do
        end
      end
    end
  else
    while running do
      for slot=1,src.size() do
        while pullItems(slot) > 0 do
        end
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
