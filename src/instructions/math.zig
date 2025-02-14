const std = @import("std");

const data_register = @import("../data_register.zig");

pub fn math(instruction: u16) void {
    const tag = instruction & 0xf;

    const rx: data_register.DataRegister = @enumFromInt((instruction >> 8) & 0xf);
    const dx = data_register.get(rx);

    const ry: data_register.DataRegister = @enumFromInt((instruction >> 4) & 0xf);
    const dy = data_register.get(ry);

    switch (tag) {
        0 => {
            data_register.set(rx, dy);
        },
        1 => {
            data_register.set(rx, dx | dy);
            data_register.set(data_register.DataRegister.VF, 0);
        },
        2 => {
            data_register.set(rx, dx & dy);
            data_register.set(data_register.DataRegister.VF, 0);
        },
        3 => {
            data_register.set(rx, dx ^ dy);
            data_register.set(data_register.DataRegister.VF, 0);
        },
        4 => {
            const add = @addWithOverflow(dx, dy);
            data_register.set(rx, add[0]);
            data_register.set(data_register.DataRegister.VF, add[1]);
        },
        5 => {
            const sub = @subWithOverflow(dx, dy);
            data_register.set(rx, sub[0]);
            data_register.set(data_register.DataRegister.VF, ~sub[1]);
        },
        6 => {
            const least = dy & 0x1;
            const shift = dy >> 1;
            data_register.set(rx, shift);
            data_register.set(data_register.DataRegister.VF, least);
        },
        7 => {
            const sub = @subWithOverflow(dy, dx);
            data_register.set(rx, sub[0]);
            data_register.set(data_register.DataRegister.VF, ~sub[1]);
        },
        14 => {
            const most = (dy & 0x80) >> 7;
            const shift = dy << 1;
            data_register.set(rx, shift);
            data_register.set(data_register.DataRegister.VF, most);
        },
        else => {
            std.log.err("unable to parse math opcode", .{});
        },
    }
}
