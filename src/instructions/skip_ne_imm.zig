const data_register = @import("../data_register.zig");

pub fn skip_ne_imm(instruction: u16, counter: *usize) void {
    const imm = instruction & 0xff;
    const reg = (instruction >> 8) & 0xf;

    const current = data_register.get(@enumFromInt(reg));

    if (current != imm) {
        counter.* += 2;
    }
}
