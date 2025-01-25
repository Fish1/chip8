const std = @import("std");

const data_register = @import("../data_register.zig");

pub fn rand(instruction: u16, random: *std.Random.Xoshiro256) void {
    const mask: u8 = @intCast(instruction & 0xff);
    const r: u8 = @intCast(random.next() & 0xff);
    data_register.set(data_register.DataRegister.V9, r & mask);
}
