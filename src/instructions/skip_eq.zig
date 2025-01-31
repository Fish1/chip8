const data_register = @import("../data_register.zig");

pub fn skip_gte(instruction: u16, counter: *usize) void {
    const rx = ((instruction >> 8) & 0xf);
    const ry = ((instruction >> 4) & 0xf);

    const dx = data_register.get(@enumFromInt(rx));
    const dy = data_register.get(@enumFromInt(ry));

    if (dx == dy) {
        counter.* += 2;
    }
}
