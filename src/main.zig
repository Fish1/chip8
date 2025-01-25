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
    var buffer: [2]u8 = undefined;

    var offset: usize = 0;
    while (true) {
        const num_read_bytes = try file_buffer.read(&buffer);
        if (num_read_bytes == 0) {
            break;
        }
        const a = @as(u16, buffer[0]) << 8;
        const b = @as(u16, buffer[1]);
        memory.set_offset(offset, a + b);
        offset += 1;
    }
}

fn run() !void {
    var counter: u16 = 0x200;
    var random = std.rand.DefaultPrng.init(1);

    while (counter < memory.max()) {
        const instruction = memory.get(counter);
        const opcode: OPCode = @enumFromInt(instruction >> 12);
        var inc = true;

        std.log.info("addr: {:0>4} data: {x:0>4} opcode: {}", .{ counter, instruction, opcode });
        switch (opcode) {
            OPCode.MACHINE => {
                try instructions.machine(instruction);
            },
            OPCode.JUMP => {
                instructions.jump(instruction, &counter);
                inc = false;
            },
            OPCode.EXECUTE => {
                try instructions.subroutine(instruction);
            },
            OPCode.DRAW => {},
            OPCode.LOAD => {
                instructions.load(instruction);
            },
            OPCode.LOAD_I => {
                instructions.load_i(instruction);
            },
            OPCode.RAND => {
                instructions.rand(instruction, &random);
            },
            OPCode.MATH => {
                instructions.math(instruction);
            },
            OPCode.SKIP_NE => {
                instructions.skip_ne(instruction, &counter);
            },
            else => {
                std.log.err("unknown instruction {x}", .{instruction});
                break;
            },
        }

        if (inc == true) {
            counter += 1;
        }

        std.time.sleep(100000000);
    }
}

pub fn main() !void {
    if (valid_arguments() == false) {
        std.log.err("usage\napp [bin]", .{});
        return;
    }

    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return;
    }
    defer c.SDL_Quit();

    const screen = c.SDL_CreateWindow("My Window", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, 400, 140, c.SDL_WINDOW_OPENGL) orelse {
        c.SDL_Log("unable to create window: %s", c.SDL_GetError());
        return;
    };
    defer c.SDL_DestroyWindow(screen);

    load() catch {
        std.log.err("could not load program...", .{});
    };

    run() catch {};

    std.log.info("goodbye", .{});
}
