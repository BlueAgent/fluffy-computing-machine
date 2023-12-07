local ex = peripheral.find('Extractor')
local cvt = peripheral.find('AdvancedGear', function (name, p) return p.getName() == "CVT Unit" end)
local coil = peripheral.find('AdvancedGear', function (name, p) return p.getName() == "Industrial Coil" end)

if not ex then
  error("Extractor missing")
elseif not cvt then
  error("CVT missing")
elseif not coil then
  error("Coil missing")
end

local running = true
local function loopMain()
  while running do
    local event, p1 = os.pullEventRaw()
    if event == 'terminate' then
      running = false
      coil.setTorque(0)
      coil.setSpeed(0)
      cvt.setRatio(0)
      print('Buh bye~ :3')
    end
  end
end

-- TODO: Have this handle first stage stuff as well
local function checkIntermediateStacks(input, output)
  if input['id'] ~= output['id'] then
    return false  
  end
  if input.id == "RotaryCraft:rotarycraft_item_extracts" then
    -- 0 to 7  dusts
    -- 8 to 15 slurrys
    -- 16 to 23 solutions
    -- 24 to 31 flakes
    -- 32 silver flakes
    -- 33 tungsten flakes
    return input.dmg + 8 == output.dmg
  elseif input.id == "RotaryCraft:rotarycraft_item_modextracts" then
    return input.dmg + 1 == output.dmg
  elseif input.id == "RotaryCraft:rotarycraft_item_customextracts" then
    return input.dmg + 1 == output.dmg
  else
    error("New Intermediate Type? O.o")
  end
end

local OFFSET_OUTPUT = 4
local lastStageMostWork = 0
local function loopSetCVTCoil()
  while running do
    os.sleep(0)

    local stacks = ex.getAllStacks()

    for slot=1,9 do
      if stacks[slot] then
        stacks[slot] = stacks[slot].basic()
      else
        stacks[slot] = nil
      end
    end

    local work = {0, 0, 0, 0}
    for stage=1,4 do
      local input = stacks[stage]
      if input then
        local output = stacks[stage + OFFSET_OUTPUT]
        -- Empty output slot
        if not output then
          work[stage] = math.min(input.qty, math.floor(input.max_size / 2))
        -- TODO: Mapping from ore to first stage output?
        -- Mergable input -> process -> output slot
        elseif stage ~= 1 and checkIntermediateStacks(input, output) then
          work[stage] = math.min(input.qty, math.floor((output.max_size - output.qty) / 2))
        end
      end
    end

    local stageMostWork = 1
    for stage=2,4 do
      if work[stage] > work[stageMostWork] then
        stageMostWork = stage
      end
    end
    if work[stageMostWork] == 0 then
      stageMostWork = 0
    end

    if lastStageMostWork ~= stageMostWork then
      lastStageMostWork = stageMostWork
      if stageMostWork == 0 then
        coil.setTorque(0)
        coil.setSpeed(0)
        cvt.setRatio(0)
      else
        if stageMostWork == 1 or stageMostWork == 4 then
          -- 16 MW
          coil.setTorque(4096)
          coil.setSpeed(4096)
          -- Gear: 16x Speed: 256 Nm @ 65 536 Rad/s
          if stageMostWork == 1 or work[1] > 4 then
            -- CVT: 2x Torque: 512 Nm @ 32 768 Rad/s
            cvt.setRatio(-2)
          else
            -- CVT: 1x Hehe: 256 Nm @ 65 536 Rad/s
            cvt.setRatio(0)
          end
        else
          -- 2 MW
          -- Gear: 16x Speed: 32 Nm @ 65 536 Rad/s
          -- CVT: 32x Speed: 1 Nm @ 2 097 152 Rad/s
          cvt.setRatio(32)
          coil.setTorque(512)
          coil.setSpeed(4096)
        end
      end
    end
  end
end

local function loopOutput()
  while running do
    ex.pushItem('UP', 8)
    ex.pushItem('UP', 9)
    os.sleep(0.5)
  end
end

parallel.waitForAll(loopMain, loopSetCVTCoil, loopOutput)
