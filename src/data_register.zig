var data_registers: [16]u8 = undefined;

pub const DataRegister = enum(usize) {
    V0 = 0,
    V1 = 1,
    V2 = 2,
    V3 = 3,
    V4 = 4,
    V5 = 5,
    V6 = 6,
    V7 = 7,
    V8 = 8,
    V9 = 9,
    VA = 10,
    VB = 11,
    VC = 12,
    VD = 13,
    VE = 14,
    VF = 15,
};

pub fn get(register: DataRegister) u8 {
    return data_registers[@intFromEnum(register)];
}

pub fn set(register: DataRegister, value: u8) void {
    data_registers[@intFromEnum(register)] = value;
}
