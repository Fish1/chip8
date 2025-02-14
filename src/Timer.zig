const std = @import("std");

pub fn Timer() type {
    return struct {
        time: u8,

        pub fn init() @This() {
            return .{ .time = 0 };
        }

        pub fn setTime(this: *@This(), value: u8) void {
            this.time = value;
        }

        pub fn getTime(this: *@This()) u8 {
            return this.time;
        }

        pub fn tick(this: *@This()) void {
            if (this.time > 0) {
                this.time -= 1;
            }
        }
    };
}
