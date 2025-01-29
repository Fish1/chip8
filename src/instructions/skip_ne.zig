const data_register = @import("../data_register.zig");

pub fn skip_ne(instruction: u16, counter: *usize) void {
    const rx = ((instruction >> 8) & 0xf);
    const ry = ((instruction >> 4) & 0xf);
    if (rx != ry) {
        counter.* += 2;
    }
}
