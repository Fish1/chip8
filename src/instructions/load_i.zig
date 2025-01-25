const std = @import("std");

const address_register = @import("../address_register.zig");
const memory = @import("../memory.zig");

pub fn load_i(instruction: u16) void {
    const address = instruction & 0xfff;
    address_register.set(address);
}
