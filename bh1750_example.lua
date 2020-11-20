bh1750 = require("bh1750")

I2C_ID = 0
I2C_SCL_PIN = 5
I2C_SDA_PIN = 6

if i2c.setup(I2C_ID, I2C_SDA_PIN, I2C_SCL_PIN, i2c.SLOW) == 0 then
  print("[DEBUG] Failed to initialize the I2C bus")
end

cfg = {}
cfg.i2c_id      = I2C_ID

m = bh1750.setup(cfg)
if not m then
  print("[DEBUG] Setup failed")
  m = nil
  bh1750 = nil
  package.loaded["bh1750"] = nil
  return
end

tmr.create():alarm(1000, tmr.ALARM_AUTO, function()
  local c = m:get_counts()
  local l = m:get_value()
  if c and l then
    print(l .. " lx / " .. c .. " counts")
  end
end)
