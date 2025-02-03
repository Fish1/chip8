const std = @import("std");

const data_register = @import("../data_register.zig");
const Keyboard = @import("../Keyboard.zig").Keyboard();

pub fn skip_key(instruction: u16, counter: *usize, keyboard: *Keyboard) void {
    const tag = instruction & 0xff;

    const rx = (instruction >> 8) & 0xf;
    const dx = data_register.get(@enumFromInt(rx));

    const is_pressed = keyboard.is_key_down_chip8(dx);

    // std.log.info("look for key {}, is pressed = {}", .{ dx, is_pressed });

    if (tag == 0x9e and is_pressed == true) {
        counter.* += 2;
    } else if (tag == 0xa1 and is_pressed == false) {
        counter.* += 2;
    }
}
