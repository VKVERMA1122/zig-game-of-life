const std = @import("std");

const HEIGHT = 25;
const WIDTH = 50;
const BACKGROUND = '-';
const CELL = '#';

const state = enum {
    DEAD,
    ALIVE,
};

const cell = struct {
    state: state,
};

var grid: [HEIGHT][WIDTH]cell = undefined;

fn clearTerminal() !void {
    const os = @import("builtin").os.tag;

    var stdout = std.io.getStdOut().writer();

    //defer stdout.deinit();

    if (os == .linux or os == .macos or os == .freebsd) {
        try stdout.print("\x1Bc", .{});
    } else if (os == .windows) {
        try stdout.print("\x1B[2J", .{});
    } else {
        std.debug.warn("Unsupported OS\n", .{});
    }
}

fn init_grid() !void {
    for (0..HEIGHT) |i| {
        for (0..WIDTH) |j| {
            grid[i][j].state = state.DEAD;
        }
    }
}

fn print_grid() i32 {
    var alive_count: i32 = 0;
    for (0..HEIGHT) |i| {
        for (0..WIDTH) |j| {
            //std.debug.print("{c}", .{grid[i][j]});
            switch (grid[i][j].state) {
                .DEAD => {
                    std.debug.print("{c}", .{BACKGROUND});
                    alive_count = alive_count + 1;
                },
                .ALIVE => std.debug.print("{c}", .{CELL}),
            }
        }
        std.debug.print("\n", .{});
    }
    return alive_count;
}

fn gen_next() !void {
    var i: i32 = 0;
    while (i < HEIGHT) {
        var j: i32 = 0;
        while (j < WIDTH) {
            var k: i32 = -1;
            var alive_count: i32 = 0;
            while (k < 1) {
                var l: i32 = -1;
                while (l < 1) {
                    if (k == 0 and l == 0) {
                        continue;
                    }
                    if (i + k < HEIGHT or i + k > 0 or j + l < WIDTH or j + l > 0) {
                        const h = @as(i32, i + k);
                        const g = @as(i32, j + l);
                        if (grid[h][g].state == state.ALIVE) {
                            alive_count = alive_count + 1;
                        }
                    }

                    l = l + 1;
                }
                k = k + 1;
            }
            switch (alive_count) {
                1 => {
                    grid[i][j].state = state.DEAD;
                    break;
                },
                3 => {
                    if (grid[i][j].state == state.DEAD and alive_count == 3) {
                        grid[i][j].state = state.ALIVE;
                        break;
                    }
                },
                else => {
                    grid[i][j].state = state.DEAD;
                },
            }

            j = j + 1;
        }
        i = i + 1;
    }
}

pub fn main() !void {
    try init_grid();
    grid[HEIGHT / 2][WIDTH / 2].state = state.ALIVE;

    while (print_grid() != 0) {
        std.time.sleep(500000000);
        try gen_next();
        try clearTerminal();
    }
}
