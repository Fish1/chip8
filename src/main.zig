const std = @import("std");

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
    while (address_register.get() < memory.max()) {
        // while (address_register.get() < 400) {
        const instruction = memory.get(address_register.get());
        const opcode: OPCode = @enumFromInt(instruction >> 12);

        std.log.info("addr: {} data: {x} opcode: {}", .{ address_register.get(), instruction, opcode });
        switch (opcode) {
            OPCode.EXECUTE_MACHINE => {
                // try instructions.execute_machine(instruction);
            },
            OPCode.JUMP => {
                instructions.jump(instruction);
                break;
            },
            OPCode.EXECUTE => {
                try instructions.execute_subroutine(instruction);
            },
            OPCode.DRAW => {},
            OPCode.STORE_IMM => {
                instructions.store_imm(instruction);
            },
            OPCode.STORE_INDEX_IMM => {
                instructions.store_index_imm(instruction);
            },
            else => {
                std.log.err("unknown instruction {x}", .{instruction});
                break;
            },
        }
        address_register.increment();
    }
}

pub fn main() !void {
    if (valid_arguments() == false) {
        std.log.err("usage\napp [bin]", .{});
        return;
    }

    load() catch {
        std.log.err("could not load program...", .{});
    };

    run() catch {};

    std.log.info("goodbye", .{});
}
