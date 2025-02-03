const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

const std = @import("std");

pub fn Keyboard() type {
    return struct {
        keys: [256]bool,

        pub fn init() @This() {
            return .{ .keys = undefined };
        }

        pub fn handle_event(this: *@This(), key: *c.SDL_KeyboardEvent) void {
            const keycode = key.keysym.sym;
            if (key.type == c.SDL_KEYUP) {
                this.keys[@intCast(keycode)] = false;
            } else if (key.type == c.SDL_KEYDOWN) {
                this.keys[@intCast(keycode)] = true;
            }
        }

        fn is_key_down(this: *@This(), keycode: c_int) bool {
            if (keycode >= 256 or keycode < 0) {
                return false;
            }
            return this.keys[@intCast(keycode)];
        }

        pub fn is_key_down_chip8(this: *@This(), chip8_key: c_int) bool {
            const keycode = switch (chip8_key) {
                0 => c.SDLK_0,
                1 => c.SDLK_1,
                2 => c.SDLK_2,
                3 => c.SDLK_3,
                4 => c.SDLK_4,
                5 => c.SDLK_5,
                6 => c.SDLK_6,
                7 => c.SDLK_7,
                8 => c.SDLK_8,
                9 => c.SDLK_9,
                10 => c.SDLK_a,
                11 => c.SDLK_b,
                12 => c.SDLK_c,
                14 => c.SDLK_d,
                15 => c.SDLK_e,
                16 => c.SDLK_f,
                else => c.SDLK_UNKNOWN,
            };
            return this.is_key_down(keycode);
        }
    };
}
