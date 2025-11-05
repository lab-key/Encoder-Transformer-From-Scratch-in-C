const std = @import("std");
const transformer_zig = @import("transformer_zig");

pub fn main() !void {
    std.debug.print("Hello from Zig example using C library!\n", .{});
    
    // Call a C function from the transformer_zig module
    const random_value = transformer_zig.c.generate_random();
    std.debug.print("Random value from C: {d}\n", .{random_value});
}