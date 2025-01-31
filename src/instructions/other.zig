const std = @import("std");

const data_register = @import("../data_register.zig");
const address_register = @import("../address_register.zig");
const memory = @import("../memory.zig");

pub fn other(instruction: u16) void {
    const tag = instruction & 0xff;
    const rx = (instruction >> 8) & 0xf;

    switch (tag) {
        0x1e => {
            const current = address_register.get();
            const dx = data_register.get(@enumFromInt(rx));
            address_register.set(current + dx);
        },
        0x33 => {
            const address = address_register.get();
            const dx = data_register.get(@enumFromInt(rx));
            const hundreds = (dx - (dx % 100)) / 100;
            const tens = ((dx % 100) - (dx % 10)) / 10;
            const ones = dx % 10;
            memory.set(address, hundreds);
            memory.set(address + 1, tens);
            memory.set(address + 2, ones);
        },
        0x55 => {
            for (0..rx + 1) |register| {
                const address = address_register.get() + register;
                const data = data_register.get(@enumFromInt(register));
                memory.set(address, data);
            }
            address_register.set(address_register.get() + rx + 1);
        },
        0x65 => {
            for (0..rx + 1) |register| {
                const address = address_register.get() + register;
                const data = memory.get(address);
                data_register.set(@enumFromInt(register), data);
            }
            address_register.set(address_register.get() + rx + 1);
        },
        else => {},
    }
}
