local component = require("component")
local sides = require("sides")
local robot = component.robot
local tc = component.tank_controller

-- indent is for pasting into lua window
  while true do
    if tc.getFluidInInternalTank() then
      local success, amount = robot.fill(sides.down, 1000)
      if success then
        print("Pushed " .. amount)
      else
        print("Pushed nothing")
      end
    end
    local success, amount = robot.drain(sides.front, 1000)
    if success then
      print("Sucked " .. amount)
    else
      print("Sucked nothing")
    end
    os.sleep(1)
  end
