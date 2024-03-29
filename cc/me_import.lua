local me = peripheral.find('tileinterface')
local suckDelay = 0
-- return an array of import attempts (I think up to 9)
local function getImportCommands()
  local direction = 'DOWN'
  return {
    {dir=direction, slot=8},
    {dir=direction, slot=9}
  }
end

local histories = {
  {name='1s', size=1},
  {name='10s', size=10},
  {name='1m', size=60},
  {name='10m', size=60*10},
  {name='1h', size=60*60},
  {name='6h', size=60*60*6}
}

for _, v in pairs(histories) do
  local hist = {}
  for i=1, v['size'] do
    hist[i] = 0
  end
  v['hist'] = hist
  v['avg'] = 0
  v['sum'] = 0
  v['i'] = 1
  v['avgs'] = 0
end

local function updateHistory()
  for _, v in pairs(histories) do
    local hist = v['hist']
    local size = v['size']

    local curr = v['i']
    local sum = v['sum']

    if size > 1 then
      sum = sum + hist[curr]
      curr = curr % size + 1
      sum = sum - hist[curr]
    else
      sum = hist[curr]
    end
    hist[curr] = 0

    v['i'] = curr
    v['sum'] = sum
    v['avgs'] = math.min(v['avgs'] + 1, size)
    v['avg'] = math.floor(sum / v['avgs'])
  end
end

local running = true
local function loopMain()
  local timerHistory = os.startTimer(1)
  while running do
    local event, p1 = os.pullEventRaw()
    if event == 'terminate' then
      running = false
      term.setCursorPos(1, table.getn(histories) + 2)
      print('Buh bye~ :3')
    elseif event == 'timer' then
      if p1 == timerHistory then
        timerHistory = os.startTimer(1)
        updateHistory()
      end
    end
  end
end

local function loopSuck()
  while running do
    local num = 0
    for _, v in pairs(getImportCommands()) do
      num = num + me.pullItem(v.dir, v.slot)
    end
    for _, v in pairs(histories) do
      local hist = v['hist']
      local curr = v['i']
      hist[curr] = hist[curr] + num
    end
    os.sleep(suckDelay)
  end
end

local displayKeys = {'name', 'avg', 'sum'}
local function loopDisplay()
  while running do
    term.clear()
    local column = 1
    for _, dKey in pairs(displayKeys) do
      local columnWidth = string.len(dKey)
      term.setCursorPos(column, 1)
      term.write(dKey)
      for k, v in pairs(histories) do
        term.setCursorPos(column, k + 1)
        local dVal = v[dKey]
        term.write(dVal)
        columnWidth = math.max(columnWidth, string.len(dVal))
      end
      column = column + columnWidth + 1
    end
    os.sleep(0.5)
  end
end

parallel.waitForAll(loopMain, loopSuck, loopDisplay)
