const call_stack = @import("../call_stack.zig");
const address_register = @import("../address_register.zig");

pub fn machine(instruction: u16, counter: *usize) !void {
    switch (instruction) {
        0xe0 => {
            // todo: clear screen
        },
        0x0ee => {
            counter.* = try call_stack.pop();
        },
        else => {
            // unused
        },
    }
}
