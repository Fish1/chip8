const call_stack = @import("../call_stack.zig");
const address_register = @import("../address_register.zig");

pub fn execute_machine(instruction: u16) !void {
    switch (instruction) {
        0xe0 => {
            // todo: clear screen
        },
        0x0ee => {
            const address = try call_stack.pop();
            address_register.set(address);
        },
        else => {
            // unused
        },
    }
}
