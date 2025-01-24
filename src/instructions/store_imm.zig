const data_register = @import("../data_register.zig");

pub fn store_imm(instruction: u16) void {
    const imm: u8 = @intCast(instruction & 0xff);
    const reg: data_register.DataRegister = @enumFromInt((instruction >> 8) & 0xf);
    data_register.set(reg, imm);
}
