const std = @import("std");
const data_register = @import("../data_register.zig");

pub fn add(instruction: u16) void {
    const imm: u8 = @intCast(instruction & 0xff);
    const reg = (instruction >> 8) & 0xf;

    const current = data_register.get(@enumFromInt(reg));
    // std.log.info("cur = {}, imm = {}", .{ current, imm });
    data_register.set(@enumFromInt(reg), @addWithOverflow(current, imm)[0]);
}
