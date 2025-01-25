var address_register: u16 = 0;

pub fn get() u16 {
    return address_register & 0xfff;
}

pub fn set(value: u16) void {
    address_register = value & 0xfff;
}
