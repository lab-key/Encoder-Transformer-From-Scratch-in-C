const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const lib = b.addLibrary(.{
        .name = "lib_transformer_c",
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true, // Changed from link_libcpp to link_libc
        }),
    });

    lib.root_module.addCSourceFiles(.{
        .files = &.{ 
            "Final Version/main.c",
            "Final Version/activation_functions.c",
            "Final Version/backpropagation.c",
            "Final Version/Data_Loading_Cleaning.c",
            "Final Version/Data_Preprocessing.c",
            "Final Version/feed_forward_layer.c",
            "Final Version/self_attention_layer.c",
            "Final Version/test.c",
            "Final Version/Tokenizer.c",
            "Final Version/transformer_block.c",
        },
        .flags = &.{ 
            "-std=c11",
            "-Wall",
            "-Wextra",
            "-pedantic",
            "-fopenmp",
            "-D_GNU_SOURCE",
        },
    });

    // This block is kept for structural consistency, but its files are replaced with C files
    lib.root_module.addCSourceFiles(.{
        .files = &.{ 
            "Final Version/main.c", // Placeholder, replace with relevant C files if any
        },
        .flags = &.{ 
            "-std=c11", 
            "-Wall",
            "-Wextra",
            "-pedantic",
            "-fopenmp",
            "-D_GNU_SOURCE",
        },
    });

    lib.addIncludePath(b.path("Final Version/")); 

    lib.linkLibC();
    lib.linkSystemLibrary("omp");

    b.installArtifact(lib);

    // --- Create and export the transformer_zig Zig module ---
    const transformer_zig_module = b.createModule(.{
        .root_source_file = b.path("zig/c.zig"),
        .target = target,
        .optimize = optimize,
        // Removed imports field
    });

    transformer_zig_module.addIncludePath(b.path("Final Version/")); // Changed include path
    transformer_zig_module.linkLibrary(lib); // Changed module name

    b.modules.put("transformer_zig", transformer_zig_module) catch @panic("failed to register transformer_zig module"); // Changed module name

    // --- Build an example executable that uses the C library via Zig --- 
    const example_exe = b.addExecutable(.{
        .name = "transformer_example",
        .root_module = b.createModule(.{
            .root_source_file = b.path("zig/example.zig"), 
            .target = target,
            .optimize = optimize,
            .imports = &.{ 
                .{ .name = "transformer_zig", .module = transformer_zig_module },
            },
        }),
    });

    b.installArtifact(example_exe);

    const run_example_step = b.addRunArtifact(example_exe);
    const run_step = b.step("run", "Run the transformer example");
    run_step.dependOn(&run_example_step.step);
}
