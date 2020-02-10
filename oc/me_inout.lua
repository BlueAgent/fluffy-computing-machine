local thread = require("thread")
local component = require("component")
local me = component.me_interface

if not me then
  error("missing interface")
end

local running = true

local tPush = thread.create(function(a, b)
  while running do
    me.exportItem({id="minecraft:iron"}, "DOWN")
    os.sleep()
  end
end)

local tSuck = thresh.create(function(a, b)
  while running do
    me.pullItem("DOWN", 8)
    os.sleep()
    me.pullItem("DOWN", 9)
    os.sleep()
  end
end)

thread.waitForAny({t1, t2})
print("Buh Bye :3")
