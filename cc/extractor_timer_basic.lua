local cvt = peripheral.find('AdvancedGear', function (name, p) return p.getName() == "CVT Unit" end)
local coil = peripheral.find('AdvancedGear', function (name, p) return p.getName() == "Industrial Coil" end)

coil.setSpeed(4096)
while true do
  cvt.setRatio(-2)
  coil.setTorque(4096)
  os.sleep(0.4)
  cvt.setRatio(32)
  coil.setTorque(512)
  os.sleep(0.6)
  cvt.setRatio(1)
  coil.setTorque(4096)
  os.sleep(0.7)
end
