const std = @import("std");

const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

const data_register = @import("data_register.zig");
const DataRegister = data_register.DataRegister;

const memory = @import("memory.zig");
const address_register = @import("address_register.zig");
const OPCode = @import("instruction.zig").OPCode;

const instructions = @import("instructions/instructions.zig");

const Renderer = @import("Renderer.zig").Renderer();
const Keyboard = @import("Keyboard.zig").Keyboard();
const Timer = @import("Timer.zig").Timer();

fn get_obj_path() [*:0]u8 {
    return std.os.argv[0];
}

fn valid_arguments() bool {
    if (std.os.argv.len != 2) {
        return false;
    }
    return true;
}

fn load() !void {
    const path = std.mem.sliceTo(std.os.argv[1], 0);
    std.log.info("reading file = {s}", .{path});
    const file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();

    var file_buffer = std.io.bufferedReader(file.reader());
    var buffer: [1]u8 = undefined;

    var offset: u16 = 0;
    while (true) {
        const num_read_bytes = try file_buffer.read(&buffer);
        if (num_read_bytes == 0) {
            break;
        }
        memory.set_offset(offset, buffer[0]);
        offset += 1;
    }
}

fn run(counter: *usize, random: *std.Random.Xoshiro256, renderer: *Renderer, keyboard: *Keyboard, delay_timer: *Timer, frame_instruction_count: u64) !void {
    const instruction = memory.get_instruction(counter.*);
    const opcode: OPCode = @enumFromInt(instruction >> 12);
    var inc = true;

    // std.log.info("addr: {:0>4} data: {x:0>4} opcode: {}", .{ counter.*, instruction, opcode });
    switch (opcode) {
        OPCode.MACHINE => try instructions.machine(instruction, renderer, counter),
        OPCode.SUBROUTINE => try instructions.subroutine(instruction, counter, &inc),

        OPCode.DRAW => {
            if (frame_instruction_count == 0) {
                try instructions.draw(instruction, renderer);
            } else {
                counter.* -= 2;
            }
        },
        OPCode.LOAD => instructions.load(instruction),
        OPCode.LOAD_I => instructions.load_i(instruction),
        OPCode.RAND => instructions.rand(instruction, random),
        OPCode.MATH => instructions.math(instruction),
        OPCode.JUMP => instructions.jump(instruction, counter, &inc),
        OPCode.ADD => instructions.add(instruction),
        OPCode.JUMP_OFFSET => instructions.jump_offset(instruction, counter, &inc),

        OPCode.SKIP_EQ_IMM => instructions.skip_eq_imm(instruction, counter),
        OPCode.SKIP_NE_IMM => instructions.skip_ne_imm(instruction, counter),
        OPCode.SKIP_NE => instructions.skip_ne(instruction, counter),
        OPCode.SKIP_EQ => instructions.skip_eq(instruction, counter),
        OPCode.SKIP_KEY => instructions.skip_key(instruction, counter, keyboard),

        OPCode.OTHER => instructions.other(instruction, delay_timer),
    }

    if (inc == true) {
        counter.* += 2;
    }
}

fn poll(quit: *bool, keyboard: *Keyboard) void {
    var event: c.SDL_Event = undefined;
    while (c.SDL_PollEvent(&event) != 0) {
        switch (event.type) {
            c.SDL_QUIT => {
                quit.* = true;
            },
            c.SDL_KEYDOWN, c.SDL_KEYUP => {
                keyboard.handle_event(&event.key);
            },
            else => {},
        }
    }
}

pub fn main() !void {
    if (valid_arguments() == false) {
        std.log.err("usage\napp [bin]", .{});
        return;
    }

    var renderer = try Renderer.init();
    defer renderer.destroy();

    var keyboard = Keyboard.init();
    var delay_timer = Timer.init();
    var sound_timer = Timer.init();

    try load();

    var quit = false;
    var counter: usize = 0x200;
    var random = std.rand.DefaultPrng.init(1);

    var fps_timer = try std.time.Timer.start();

    while (quit == false) {
        delay_timer.tick();
        sound_timer.tick();

        poll(&quit, &keyboard);

        for (0..11) |frame_counter| {
            try run(&counter, &random, &renderer, &keyboard, &delay_timer, frame_counter);
        }

        const remaining = (std.time.ns_per_s / 60) - fps_timer.read();
        std.time.sleep(remaining);
        fps_timer.reset();
    }

    std.log.info("goodbye", .{});
}
