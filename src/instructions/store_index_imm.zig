const address_register = @import("../address_register.zig");
const memory = @import("../memory.zig");

pub fn store_index_imm(instruction: u16) void {
    const address = instruction & 0xfff;
    const data = memory.get(address);
    address_register.set(data);
}
