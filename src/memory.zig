const START_OFFSET = 0x200;
const MAX_SIZE = 4096;

var memory: [MAX_SIZE]u8 = undefined;

pub fn get(address: usize) u8 {
    return memory[address];
}

pub fn get_instruction(address: usize) u16 {
    return (@as(u16, memory[address]) << 8) | memory[address + 1];
}

pub fn get_offset(offset: u8) u8 {
    return memory[START_OFFSET + offset];
}

pub fn set(address: usize, value: u8) void {
    memory[address] = value;
}

pub fn set_offset(offset: usize, value: u8) void {
    memory[START_OFFSET + offset] = value;
}

pub fn max_offset() usize {
    return MAX_SIZE - START_OFFSET;
}

pub fn max() usize {
    return MAX_SIZE;
}
