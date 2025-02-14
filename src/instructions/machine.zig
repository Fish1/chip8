const Renderer = @import("../Renderer.zig").Renderer();

const call_stack = @import("../call_stack.zig");
const address_register = @import("../address_register.zig");

pub fn machine(instruction: u16, renderer: *Renderer, counter: *usize) !void {
    switch (instruction) {
        0xe0 => {
            try renderer.start_draw();
            renderer.clear();
            renderer.stop_draw();
        },
        0x0ee => {
            counter.* = try call_stack.pop();
        },
        else => {
            // unused
        },
    }
}
