const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

const std = @import("std");

const WIDTH = 64;
const HEIGHT = 32;

pub fn Renderer() type {
    return struct {
        window: *c.SDL_Window,
        renderer: *c.SDL_Renderer,
        texture: *c.SDL_Texture,

        pixels: [*]u32,

        pub fn init() !@This() {
            if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
                return error.FailedSDLInit;
            }

            const window = c.SDL_CreateWindow("My Window", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, WIDTH, HEIGHT, c.SDL_WINDOW_RESIZABLE) orelse {
                return error.FailedCreatingWindow;
            };

            const renderer = c.SDL_CreateRenderer(window, -1, 0) orelse {
                return error.FailedCreatingRenderer;
            };

            const texture = c.SDL_CreateTexture(renderer, c.SDL_PIXELFORMAT_RGBA32, c.SDL_TEXTUREACCESS_STREAMING, WIDTH, HEIGHT) orelse {
                return error.FailedCreatingTexture;
            };

            c.SDL_SetWindowSize(window, 800, 400);

            return .{ .window = window, .renderer = renderer, .texture = texture, .pixels = undefined };
        }

        pub fn destroy(this: @This()) void {
            c.SDL_Quit();
            c.SDL_DestroyWindow(this.window);
            c.SDL_DestroyRenderer(this.renderer);
            c.SDL_DestroyTexture(this.texture);
        }

        pub fn start_draw(this: *@This()) !void {
            var pitch: c_int = WIDTH * 4;
            if (c.SDL_LockTexture(this.texture, null, @ptrCast(&this.pixels), &pitch) != 0) {
                return error.FailedToStartDraw;
            }
        }

        pub fn flip_pixel(this: @This(), x: usize, y: usize) void {
            const index = (y * 64) + x;
            std.log.info("index = {}", .{index});
            this.pixels[index] ^= 0xffffffff;
        }

        pub fn stop_draw(this: @This()) void {
            c.SDL_UnlockTexture(this.texture);
        }

        pub fn display(this: @This()) !void {
            if (c.SDL_RenderCopy(this.renderer, this.texture, null, null) != 0) {
                return error.FailedToRender;
            }
        }
    };
}
