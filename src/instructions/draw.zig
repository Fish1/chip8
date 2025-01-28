const std = @import("std");

const data_register = @import("../data_register.zig");
const address_register = @import("../address_register.zig");
const memory = @import("../memory.zig");

pub fn draw(instruction: u16, pixels: [*]u32, pixels_length: usize) !void {
    const rx: data_register.DataRegister = @enumFromInt((instruction >> 8) & 0xf);
    const ry: data_register.DataRegister = @enumFromInt((instruction >> 4) & 0xf);
    const n = instruction & 0xf;

    const dx = data_register.get(rx);
    const dy = data_register.get(ry);

    const i = (dy * 32) + dx;

    std.log.info("x = {}, y = {}, i = {}, n = {}", .{ dx, dy, i, n });

    if (i >= pixels_length) {
        return error.OutOfBoundsRender;
    }

    //  for (0..n) |n| {
    // const a = address_register.get() + ni;
    // const data = memory.get(a);
    // pixels[i] = 0xffffffff;
    //  }
    pixels[i] = 0xffffffff;

    data_register.set(data_register.DataRegister.VF, 1);
}
