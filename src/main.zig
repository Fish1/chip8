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

const width = 64;
const height = 32;
var pitch: c_int = width * 4;

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

fn run(counter: *usize, random: *std.Random.Xoshiro256, pixels: [*]u32) !void {
    const instruction = memory.get_instruction(counter.*);
    const opcode: OPCode = @enumFromInt(instruction >> 12);
    var inc = true;

    std.log.info("addr: {:0>4} data: {x:0>4} opcode: {}", .{ counter.*, instruction, opcode });
    switch (opcode) {
        OPCode.MACHINE => try instructions.machine(instruction),
        OPCode.EXECUTE => try instructions.subroutine(instruction),
        OPCode.DRAW => try instructions.draw(instruction, pixels, width * height),
        OPCode.LOAD => instructions.load(instruction),
        OPCode.LOAD_I => instructions.load_i(instruction),
        OPCode.RAND => instructions.rand(instruction, random),
        OPCode.MATH => instructions.math(instruction),
        OPCode.SKIP_NE => instructions.skip_ne(instruction, counter),
        OPCode.JUMP => instructions.jump(instruction, counter, &inc),
        else => {
            std.log.err("unknown instruction {x}", .{instruction});
            return error.UnknownInstruction;
        },
    }

    if (inc == true) {
        counter.* += 2;
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

    const window = c.SDL_CreateWindow("My Window", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, width, height, c.SDL_WINDOW_RESIZABLE) orelse {
        c.SDL_Log("unable to create window: %s", c.SDL_GetError());
        return;
    };
    defer c.SDL_DestroyWindow(window);

    c.SDL_SetWindowSize(window, 800, 400);

    const renderer = c.SDL_CreateRenderer(window, -1, 0) orelse {
        c.SDL_Log("Unable to create renderer: %s", c.SDL_GetError());
        return;
    };
    defer c.SDL_DestroyRenderer(renderer);

    load() catch {
        unreachable;
    };

    var quit = false;
    var counter: usize = 0x200;
    var random = std.rand.DefaultPrng.init(1);

    const texture = c.SDL_CreateTexture(renderer, c.SDL_PIXELFORMAT_RGBA32, c.SDL_TEXTUREACCESS_STREAMING, width, height) orelse {
        c.SDL_Log("Failed to create texture: %s", c.SDL_GetError());
        return;
    };

    while (quit == false) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => {
                    quit = true;
                },
                else => {},
            }
        }

        var pixels: [*]u32 = undefined;
        if (c.SDL_LockTexture(texture, null, @ptrCast(&pixels), &pitch) != 0) {
            c.SDL_Log("Failed to lock texture: %s", c.SDL_GetError());
            return;
        }

        run(&counter, &random, pixels) catch {
            unreachable;
        };

        c.SDL_UnlockTexture(texture);

        if (c.SDL_RenderCopy(renderer, texture, null, null) != 0) {
            c.SDL_Log("Failed to render: %s", c.SDL_GetError());
            return;
        }

        c.SDL_RenderPresent(renderer);

        c.SDL_Delay(200);
    }

    std.log.info("goodbye", .{});
}
