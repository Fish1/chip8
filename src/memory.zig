const START_OFFSET = 0x200;
const MAX_SIZE = 4096;

var memory: [MAX_SIZE]u16 = undefined;

pub fn get(address: usize) u16 {
    return memory[address];
}

pub fn get_offset(offset: usize) u16 {
    return memory[START_OFFSET + offset];
}

pub fn set(address: usize, value: u16) void {
    memory[address] = value;
}

pub fn set_offset(offset: usize, value: u16) void {
    memory[START_OFFSET + offset] = value;
}

pub fn max_offset() usize {
    return MAX_SIZE - START_OFFSET;
}

pub fn max() usize {
    return MAX_SIZE;
}
