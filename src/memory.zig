var memory: [4096]u16 = undefined;

pub const start_memory = 0x200;

pub fn get(address: usize) u16 {
    return memory[address];
}

pub fn set(address: usize, value: u16) void {
    memory[address] = value;
}
