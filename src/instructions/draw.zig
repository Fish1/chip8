const std = @import("std");

const data_register = @import("../data_register.zig");
const address_register = @import("../address_register.zig");
const memory = @import("../memory.zig");

const Renderer = @import("../Renderer.zig").Renderer();
const WIDTH = @import("../Renderer.zig").WIDTH;
const HEIGHT = @import("../Renderer.zig").HEIGHT;

pub fn draw(instruction: u16, renderer: *Renderer) !void {
    const rx: data_register.DataRegister = @enumFromInt((instruction >> 8) & 0xf);
    const ry: data_register.DataRegister = @enumFromInt((instruction >> 4) & 0xf);
    const read_bytes = (instruction & 0xf);

    const dx = @as(u16, data_register.get(rx)) % WIDTH;
    const dy = @as(u16, data_register.get(ry)) % HEIGHT;

    try renderer.start_draw();

    var unset: u1 = 0;
    for (0..read_bytes) |current_byte| {
        const address = address_register.get() + current_byte;
        const data = memory.get(address);

        const x = dx;
        const y = dy + current_byte;

        if (y >= HEIGHT) {
            continue;
        }

        inline for (0..8) |bit| {
            if (x + bit >= WIDTH) {
                break;
            }

            const flip = (data & (0b10000000 >> bit) != 0);
            if (flip) {
                if (renderer.flip_pixel(x + bit, y)) {
                    unset = 1;
                }
            }
        }
    }

    renderer.stop_draw();

    try renderer.display();

    data_register.set(data_register.DataRegister.VF, unset);
}
