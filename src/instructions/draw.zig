const std = @import("std");

const data_register = @import("../data_register.zig");
const address_register = @import("../address_register.zig");
const memory = @import("../memory.zig");

const Renderer = @import("../Renderer.zig").Renderer();

pub fn draw(instruction: u16, renderer: *Renderer) !void {
    const rx: data_register.DataRegister = @enumFromInt((instruction >> 8) & 0xf);
    const ry: data_register.DataRegister = @enumFromInt((instruction >> 4) & 0xf);
    const read_bytes = (instruction & 0xf);

    const dx = @as(u16, data_register.get(rx));
    const dy = @as(u16, data_register.get(ry));

    try renderer.start_draw();

    for (0..read_bytes) |current_byte| {
        const address = address_register.get() + current_byte;
        const data = memory.get(address);

        const x = dx;
        const y = dy + current_byte;

        inline for (0..8) |bit| {
            const flip = (data & (0b10000000 >> bit) != 0);
            if (flip) {
                renderer.flip_pixel(x + bit, y);
            }
        }
    }

    renderer.stop_draw();

    data_register.set(data_register.DataRegister.VF, 1);
}
