local winder = peripheral.find("Winder", function (name, p) return p.getName() == "Coil Winder" end)
local cvt = peripheral.find("AdvancedGear", function (name, p) return p.getName() == "CVT Unit" end)

if not winder then
  error("Coil Winder missing")
elseif not cvt then
  error("CVT missing")
end

local INPUT_TORQUE = 512*4*8
-- 16 for bedrock, 1 for HSLA assuming we always use 16 cause lazy :3
local COIL_STIFFNESS = 16
-- 4 AC Engines -> 8x Torque -> CVT -> Winder
-- Redstone output is ON if it needs engines to run
local REDSTONE_SIDE = "bottom"
local wasRunning = false
while true do
  local coil = winder.getStackInSlot(1)
  local targetCharge = 0
  if coil then
    targetCharge = coil.dmg + 1
  end
  local running
  if targetCharge <= 32000 and targetCharge > 0 then
    local torqueReq = targetCharge * COIL_STIFFNESS
    local cvtReq = -1
    if torqueReq > INPUT_TORQUE then
      cvtReq = -math.ceil(torqueReq / INPUT_TORQUE)
    end
    -- clamp values (should only need -16 but eh)
    cvtReq = math.max(-32, cvtReq)
    if cvtReq ~= cvt.getRatio() then
      cvt.setRatio(cvtReq)
      print("Updated CVT to " ..(-cvtReq) .."x Torque")
    end
    running = true
    redstone.setOutput(REDSTONE_SIDE, true)
  else
    running = false
    redstone.setOutput(REDSTONE_SIDE, false)
  end
  if running ~= wasRunning then
    wasRunning = running
    if running then
      print("Started Engines")
    else
      print("Stopped Engines")
    end
  end
  if running then
    os.sleep(0)
  else
    os.sleep(5)
  end
end
