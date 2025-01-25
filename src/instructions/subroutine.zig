const address_register = @import("../address_register.zig");
const call_stack = @import("../call_stack.zig");

pub fn subroutine(instruction: u16) !void {
    const current = address_register.get();
    try call_stack.push(current);
    const new = instruction & 0xfff;
    address_register.set(new);
}
