const std = @import("std");

const data_register = @import("../data_register.zig");

pub fn math(instruction: u16) void {
    const tag = instruction & 0xf;

    const left_reg: data_register.DataRegister = @enumFromInt((instruction >> 8) & 0xf);
    const data_left_reg = data_register.get(left_reg);

    const right_reg: data_register.DataRegister = @enumFromInt((instruction >> 4) & 0xf);
    const data_right_reg = data_register.get(right_reg);

    switch (tag) {
        3 => {
            // xor
            data_register.set(left_reg, data_left_reg ^ data_right_reg);
        },
        else => {
            std.log.err("unable to parse math opcode", .{});
        },
    }
}
