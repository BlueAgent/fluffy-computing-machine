local component = require("component")
local me = component.me_interface

if not me then
  error("Missing ME Interface")
end

function doPull()
  return me.pullItem("DOWN", 8) + me.pullItem("DOWN", 9)
end

function doPush()
  local exported = me.exportItem({id="minecraft:iron_ore"}, "DOWN")
  return exported.size
end

local tasks = {
  {name="pull", op=doPull},
  {name="push", op=doPush},
}

local avgTypes = {
  {name = "1s" , size = 1},
  {name = "10s", size = 10},
  {name = "1m" , size = 60},
  {name = "10m", size = 60*10},
  {name = "1h" , size = 60*60},
  {name = "6h" , size = 60*60*6}
}
local avgMaxSize = 1
for k, v in pairs(avgTypes) do
  avgMaxSize = math.max(avgMaxSize, v.size)
end

local avgDataStore = {}
for _, task in pairs(tasks) do
  local avgData = {}
  avgDataStore[task.name] = avgData
  avgData["i"] = 1
  local hist = {}
  avgData["hist"] = hist
  for i=1, averagesMaxSize do
    hist[i] = 0
  end
  local avgs = {}
  avgData["avgs"] = avgs
  for _, avgType in pairs(avgTypes) do
    local avg = {}
    avgs[avgType.name] = avg
    avg["sum"] = 0
    avg["count"] = 0
    avg["avg"] = 0
  end
end

local histLastUpdate = os.time()
while true do
  event, p1, p2, p3, p4 = event.pull(0.05)
  if event == "interrupted" then
    break
  end
  for _, task in pairs(tasks) do
    local avgData = avgDataStore[task.name]
    local hist = avgData.hist
    local i = avgData.i
    hist[i] = hist[i] + task.op()
  end
  -- update history
  local time = os.time()
  if time > histLastUpdate + 1 then
    histLastUpdate = histLastUpdate + 1
  do
end
