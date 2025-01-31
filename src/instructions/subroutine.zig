const address_register = @import("../address_register.zig");
const call_stack = @import("../call_stack.zig");

pub fn subroutine(instruction: u16, counter: *usize, inc: *bool) !void {
    try call_stack.push(counter.*);
    counter.* = instruction & 0xfff;
    inc.* = false;
}
