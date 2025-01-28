const std = @import("std");

const data_register = @import("../data_register.zig");
const address_register = @import("../address_register.zig");
const memory = @import("../memory.zig");

pub fn draw(instruction: u16, pixels: [*]u32, pixels_length: usize) !void {
    const rx: data_register.DataRegister = @enumFromInt((instruction >> 8) & 0xf);
    const ry: data_register.DataRegister = @enumFromInt((instruction >> 4) & 0xf);
    const n = (instruction & 0xf) + 1;

    const dx = data_register.get(rx);
    const dy = data_register.get(ry);

    const ii = (dy * 32) + dx;

    // std.log.info("rx = {}, x = {}, ry = {}, y = {}, i = {}, n = {}", .{ rx, dx, ry, dy, i2, n });

    if (ii >= pixels_length) {
        return error.OutOfBoundsRender;
    }

    for (0..n / 2) |xx| {
        const a = address_register.get() + xx;
        const data = memory.get(@intCast(a));
        const dx2 = dx;
        const dy2 = dy + xx;
        const i = (dy2 * 32) + dx2;
        // const ix = ((dy + (xx / 2 / 2)) * 32) + (dx + (((xx / 2) % 2) * 4));
        pixels[i + 0] ^= if (data & 0b10000000 != 0) 0xffffffff else 0;
        pixels[i + 1] ^= if (data & 0b01000000 != 0) 0xffffffff else 0;
        pixels[i + 2] ^= if (data & 0b00100000 != 0) 0xffffffff else 0;
        pixels[i + 3] ^= if (data & 0b00010000 != 0) 0xffffffff else 0;
        pixels[i + 4] ^= if (data & 0b00001000 != 0) 0xffffffff else 0;
        pixels[i + 5] ^= if (data & 0b00000100 != 0) 0xffffffff else 0;
        pixels[i + 6] ^= if (data & 0b00000010 != 0) 0xffffffff else 0;
        pixels[i + 7] ^= if (data & 0b00000001 != 0) 0xffffffff else 0;
        // std.log.info("ix = {}", .{dy / 2});
    }
    // pixels[i] = 0xffffffff;

    data_register.set(data_register.DataRegister.VF, 1);
}
