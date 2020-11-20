--- bh1750.lua
-- This Lua module provides access to the BH1750 ambient light sensor for the
-- NodeMCU firmware
--
-- @author aqye
-- @github https://github.com/aqye/nodemcu-bh1750
-- @copyright 2020
-- @license MIT

local M = {}
M.__index = M

local i2c_start, i2c_stop, i2c_address, i2c_read, i2c_write, i2c_TRANSMITTER, 
      i2c_RECEIVER = i2c.start, i2c.stop, i2c.address, i2c.read, i2c.write, 
      i2c.TRANSMITTER, i2c.RECEIVER
local bit_band, bit_bor, bit_rshift, bit_lshift = bit.band, bit.bor, 
      bit.rshift, bit.lshift
local string_byte = string.byte

i2c, bit, string = nil, nil, nil

local function reg_write(i2c_id, address, register)
  if not i2c_id or not address or not register then return end
  i2c_start(i2c_id)
  if not i2c_address(i2c_id, address, i2c_TRANSMITTER) then
    i2c_stop(i2c_id)
    return
  end
  i2c_write(i2c_id, register)
  i2c_stop(i2c_id)
  return true
end

local function upd_conv_rate(self)
  self.conv_rate = 1.2 * self.mtreg / 69
  if (self.mode == 0x11) or (self.mode == 0x21) then
    self.conv_rate = self.conv_rate * 2
  end
end

function M:reset()
  return reg_write(self.i2c_id, self.address, 0x07)
end

function M:set_state(command)
  if command ~= 0 and command ~= 1 then return end
  return reg_write(self.i2c_id, self.address, command)
end


function M:set_mode(mode)
  if (mode < 0x10 or mode > 0x13) and (mode < 0x20 or mode > 0x23) then
    return
  end
  self.mode = mode
  if not reg_write(self.i2c_id, self.address, self.mode) then return end
  upd_conv_rate(self)
  return true
end

function M:set_mtreg(mt)
  local mt = mt or 0x45
  if mt < 0x1F or mt > 0xFE then return end

  if not reg_write(self.i2c_id, self.address, 
                   bit_bor(0x40, bit_rshift(mt, 5))) then return end
  if not reg_write(self.i2c_id, self.address, 
                   bit_bor(0x60, bit_band(mt, 0x1F))) then return end

  self.mtreg = mt
  upd_conv_rate(self)
  return true
end

function M:get_counts()
  i2c_start(self.i2c_id)
  if not i2c_address(self.i2c_id, self.address, i2c_RECEIVER) then
    i2c_stop(self.i2c_id)
    return
  end
  local a, b = string_byte(i2c_read(self.i2c_id, 2), 1, 2)
  i2c_stop(self.i2c_id)
  return bit_bor(bit_lshift(a, 8), b)
end

function M:get_value()
  local counts = self:get_counts()
  if not counts then return end

  return counts / self.conv_rate
end

function M.setup(cfg)
  local self = {}
  self.i2c_id    = cfg.i2c_id    or 0
  self.address   = cfg.address   or 0x23
  self.mode      = cfg.mode      or 0x10
  self.mtreg     = cfg.mtreg     or 0x45
  self.conv_rate = 1
  setmetatable(self, M)

  self:set_mtreg(self.mtreg)
  self:set_mode(self.mode)
  return self
end

return M
