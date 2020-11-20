# BH1750 Module
<!---
| Since  | Origin / Contributor  | Maintainer  | Source  |
| :----- | :-------------------- | :---------- | :------ |
| 2020-11-19 | [aqye](https://github.com/aqye) | [aqye](https://github.com/aqye) | [bh1750.lua](bh1750.lua)|
-->

This Lua module provides access to the BH1750 ambient light sensor for the NodeMCU firmware.

<!---
!!! important
-->
The module is created for the `float` version of the NodeMCU and requires `i2c` and `bit` C modules built into the firmware.

## Example
```
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
```

## bh1750.setup()
Configure the BT1750 module.

#### Syntax
`bh1750.setup(cfg)`

#### Parameters
- `cfg` table containing configuration data:
    - `i2c_id` i2c bus number
    - `address` device address (default: 0x23):
        - `0x23` ADDR pin voltage <= 0.3*VCC
        - `0x5C` ADDR pin voltage >= 0.7*VCC
    - `mode` measurement mode (default: 0x10)
    - `mtreg` MTreg value (default: 69)

#### Returns
BH1750 object `obj` on success, `nil` on error.

#### See also
- [obj:set_mode()](#objset_mode)
- [obj:set_mtreg()](#objset_mtreg)

## obj:get_counts()
Read raw brightness value.

#### Syntax
`obj:get_counts()`

#### Returns
Raw brightness `value` in counts or `nil` on error.

## obj:get_value()
Read brightness value.

#### Syntax
`obj:get_value()`

#### Returns
Brightness `value` in lux or `nil` on error.

## obj:reset()
Reset the data register stop measurements. 
Device should be in the `power_on` state.

#### See also
- [obj:set_mode()](#objset_mode)
- [obj:set_state()](#objset_state)

#### Syntax
`obj:reset()`

#### Returns
`true` on success, `nil` on error.

## obj:set_mode()
Set measurement mode.

#### Syntax
`obj:set_mode(mode)`

#### Parameters
- `mode` measurement mode (default: 0x10):
    - `0x10` continuous H-res (1 lx resolution, 120 ms measurement time)
    - `0x11` continuous H-res 2 (0.5 lx resolution, 120 ms measurement time)
    - `0x13` continuous L-res (4 lx resolution, 16 ms measurement time)
    - `0x20` one-time H-res (1 lx resolution, 120 ms measurement time)
    - `0x21` one-time H-res  2 (0.5 lx resolution, 120 ms measurement time)
    - `0x23` one-time L-res (4 lx resolution, 16 ms measurement time)

#### Returns
`true` on success, `nil` on error.

## obj:set_mtreg()
Set value of the measurement time register (MTreg).

#### Syntax
`obj:set_mtreg(mt)`

#### Parameters
`mt` MTreg value (31~254, default: 69)

#### Returns
`true` on success, `nil` on error.

## obj:set_state()
Set the state of the device.

#### Syntax
`obj:set_state(command)`

#### Parameters
- `command` change state:
    - `0` power down, measurements are stopped
    - `1` power up, enter the `power_on` state

#### Returns
`true` on success, `nil` on error.
