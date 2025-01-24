const address_register = @import("../address_register.zig");

pub fn jump(instruction: u16) void {
    const address = instruction & 0xfff;
    address_register.set(address);
}
