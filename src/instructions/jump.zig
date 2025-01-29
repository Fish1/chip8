const address_register = @import("../address_register.zig");

pub fn jump(instruction: u16, counter: *usize, inc: *bool) void {
    const address = instruction & 0xfff;
    counter.* = @intCast(address);
    inc.* = false;
}
