const std = @import("std");

const data_register = @import("data_register.zig");
const DataRegister = data_register.DataRegister;

const memory = @import("memory.zig");

const address_register = @import("address_register.zig");

fn get_obj_path() [*:0]u8 {
    return std.os.argv[0];
}

fn valid_arguments() bool {
    if (std.os.argv.len != 2) {
        return false;
    }
    return true;
}

fn display_info() !void {
    std.log.info("start memory = {}", .{memory.start_memory});
    std.log.info("register v4 = {}", .{data_register.get(DataRegister.V4)});
    data_register.set(DataRegister.V4, 8);
    std.log.info("register v4 = {}", .{data_register.get(DataRegister.V4)});
}

fn read_program() !void {
    const path = std.mem.sliceTo(std.os.argv[1], 0);
    std.log.info("reading file = {s}", .{path});
    const file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();

    var file_buffer = std.io.bufferedReader(file.reader());
    var buffer: [1]u8 = undefined;

    while (true) {
        const num_read_bytes = try file_buffer.read(&buffer);
        if (num_read_bytes == 0) {
            break;
        }
    }
}

fn dump_program() !void {}

pub fn main() !void {
    if (valid_arguments() == false) {
        std.log.err("usage\napp [bin]", .{});
        return;
    }

    try display_info();

    read_program() catch {
        std.log.err("could not read file", .{});
    };

    std.log.info("goodbye", .{});

    // const out_file = std.io.getStdOut().writer();
    // var buffered_writer = std.io.bufferedWriter(out_file);
    // const writer = buffered_writer.writer();

    // while (true) : (address_register.increment()) {
    //    const instruction = memory.get(address_register.get());
    //    try writer.print("address: {}\n", .{address_register.get()});
    //    try writer.print("instruction: {}\n", .{instruction});
    //}
}
