const data_register = @import("../data_register.zig");

pub fn jump_offset(instruction: u16, counter: *usize, inc: *bool) void {
    const imm = instruction & 0xfff;
    const offset = data_register.get(data_register.DataRegister.V0);
    counter.* = @intCast(imm + offset);
    inc.* = false;
}
