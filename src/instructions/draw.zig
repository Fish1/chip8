const std = @import("std");

const data_register = @import("../data_register.zig");
const address_register = @import("../address_register.zig");
const memory = @import("../memory.zig");

pub fn draw(instruction: u16, pixels: [*]u32, pixels_length: usize) !void {
    const rx: data_register.DataRegister = @enumFromInt((instruction >> 8) & 0xf);
    const ry: data_register.DataRegister = @enumFromInt((instruction >> 4) & 0xf);
    const read_bytes = (instruction & 0xf);

    const dx = @as(u16, data_register.get(rx));
    const dy = @as(u16, data_register.get(ry));

    const ii = (dy * 32) + dx;

    // std.log.info("rx = {}, x = {}, ry = {}, y = {}, i = {}, n = {}", .{ rx, dx, ry, dy, i2, n });

    if (ii >= pixels_length) {
        return error.OutOfBoundsRender;
    }

    for (0..read_bytes) |current_byte| {
        const a = address_register.get() + current_byte;
        const data = memory.get(a);
        const index = ((dy + current_byte) * 64) + dx;
        // const ix = ((dy + (xx / 2 / 2)) * 32) + (dx + (((xx / 2) % 2) * 4));
        inline for (0..8) |z| {
            const flip = ((data & (0b10000000 >> z)) != 0);
            if (flip) {
                if (pixels[index + z] == 0) {
                    pixels[index + z] = 0xffffffff;
                } else {
                    pixels[index + z] = 0;
                }
            }
        }
    }

    data_register.set(data_register.DataRegister.VF, 1);
}
