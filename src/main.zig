const std = @import("std");

//window height and width
const HEIGHT: i32 = 25;
const WIDTH: i32 = 50;

//dead cell
const BACKGROUND = '-';

//alive cell
const CELL = '#';

//cell state
const state = enum {
    DEAD,
    ALIVE,
};

//cells
const cell = struct {
    state: state,
};

//grid array of cells
var grid: [HEIGHT][WIDTH]cell = undefined;

//function to clear terminal after every itre
fn clear_terminal() !void {
    const os = @import("builtin").os.tag;

    var stdout = std.io.getStdOut().writer();

    if (os == .linux or os == .macos or os == .freebsd) {
        try stdout.print("\x1Bc", .{});
    } else if (os == .windows) {
        try stdout.print("\x1B[2J", .{});
    } else {
        std.debug.warn("Unsupported OS\n", .{});
    }
}

//grid init
fn init_grid() !void {
    for (0..HEIGHT) |i| {
        for (0..WIDTH) |j| {
            //init grid with all dead cells
            grid[i][j].state = state.DEAD;
        }
    }
}

fn print_grid() i32 {
    var alive_count: i32 = 0;
    for (0..HEIGHT) |i| {
        for (0..WIDTH) |j| {
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
    for (0..HEIGHT) |i| {
        for (0..WIDTH) |j| {
            var alive_count: i32 = 0;
            if (i < HEIGHT or i > 0 or j < WIDTH or j > 0 or i - 1 < HEIGHT or i - 1 > 0 or j - 1 < WIDTH or j - 1 > 0) {
                if (grid[i][j].state == state.ALIVE and grid[i][j].state == state.ALIVE or
                    grid[i - 1][j].state == state.ALIVE and grid[i][j - 1].state == state.ALIVE or
                    grid[i][j - 1].state == state.ALIVE and grid[i - 1][j].state == state.ALIVE or
                    grid[i - 1][j - 1].state == state.ALIVE and grid[i - 1][j - 1].state == state.ALIVE or
                    grid[i - 1][j].state == state.ALIVE and grid[i - 1][j].state == state.ALIVE or
                    grid[i][j - 1].state == state.ALIVE and grid[i][j - 1].state == state.ALIVE)
                {
                    alive_count = alive_count + 1;
                }
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
        }
    }
}

pub fn main() !void {
    try init_grid();
    grid[HEIGHT / 2][WIDTH / 2].state = state.ALIVE;

    //try gen_next();
    while (print_grid() != 0) {
        std.time.sleep(500000000);
        try gen_next();
        try clear_terminal();
    }
}
