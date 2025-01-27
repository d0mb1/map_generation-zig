const std = @import("std");

const coords = struct { row: u8, column: u8 };
const map_size: coords = .{ .row = 40, .column = 64 };
var map: [map_size.row][map_size.column]u8 = undefined;

const RED: []const u8 = "\x1b[31m";
const GREEN: []const u8 = "\x1b[0;30;42m";
const BRIGHT_GREEN: []const u8 = "\x1b[0;30;102m";
const WHITE: []const u8 = "\x1b[0;30;47m";
const BLUE: []const u8 = "\x1b[0;30;44m";
const RESET: []const u8 = "\x1b[0m";

const mountain: u8 = 0;
const forest: u8 = 1;
const plains: u8 = 2;
const water: u8 = 3;

pub fn main() void {
    setSeed();
    generateMap();
    generateRiver();
    printMap();
    std.debug.print("Compiled!\n", .{});
}

fn setSeed() void {
    var i: usize = 0;
    var j: usize = 0;
    while (i < map.len) : (i += 1) {
        while (j < map[0].len) : (j += 1) {
            map[i][j] = ' ';
        }
        j = 0;
    }
    while (j < map.len) : (j += 1) {
        map[j][0] = '#';
        map[j][map_size.column - 1] = '#';
    }
    j = 0;
    while (j < map[0].len) : (j += 1) {
        map[0][j] = '#';
        map[map_size.row - 1][j] = '#';
    }
    var rng = std.rand.DefaultPrng.init(@intCast(std.time.timestamp()));
    const rand = rng.random();

    var index: usize = 0;
    while (index < 12) {
        const forestOrigin: coords = .{ .row = rand.intRangeLessThan(u8, 1, map_size.row - 1), .column = rand.intRangeLessThan(u8, 1, map_size.column - 1) };
        map[forestOrigin.row][forestOrigin.column] = forest;
        index += 1;
    }
    index = 0;
    while (index < 1) {
        const mountainOrigin: coords = .{ .row = rand.intRangeLessThan(u8, 1, map_size.row - 1), .column = rand.intRangeLessThan(u8, 1, map_size.column - 1) };
        map[mountainOrigin.row][mountainOrigin.column] = mountain;
        index += 1;
    }
    index = 0;
    while (index < 12) {
        const plainsOrigin: coords = .{ .row = rand.intRangeLessThan(u8, 1, map_size.row - 1), .column = rand.intRangeLessThan(u8, 1, map_size.column - 1) };
        map[plainsOrigin.row][plainsOrigin.column] = plains;
        index += 1;
    }
    index = 0;
    while (index < 1) {
        const lakeOrigin: coords = .{ .row = rand.intRangeLessThan(u8, 1, map_size.row - 1), .column = rand.intRangeLessThan(u8, 1, map_size.column - 1) };
        map[lakeOrigin.row][lakeOrigin.column] = water;
        index += 1;
    }
}

fn generateMap() void {
    var rng = std.rand.DefaultPrng.init(@intCast(std.time.timestamp()));
    const rand = rng.random();

    var empty_spaces_left: usize = 1;
    printMap();

    var row: usize = 1;
    var column: usize = 1;
    while (empty_spaces_left != 0) {
        empty_spaces_left = 0;
        while (row < map.len - 1) : (row += 1) {
            while (column < map[0].len - 1) : (column += 1) {
                if (map[row][column] != '#' | ' ') {
                    const direction = rand.intRangeLessThan(u8, 0, 4);
                    // std.debug.print("{} ", .{direction});
                    switch (direction) {
                        0 => {
                            if (map[row - 1][column] == ' ') {
                                map[row - 1][column] = map[row][column];
                            }
                        },
                        1 => {
                            if (map[row + 1][column] == ' ') {
                                map[row + 1][column] = map[row][column];
                            }
                        },
                        2 => {
                            if (map[row][column - 1] == ' ') {
                                map[row][column - 1] = map[row][column];
                            }
                        },
                        3 => {
                            if (map[row][column + 1] == ' ') {
                                map[row][column + 1] = map[row][column];
                            }
                        },
                        else => {},
                    }
                }
                if (map[row][column] == ' ') empty_spaces_left += 1;
            }
            column = 1;
        }
        row = 1;
        // std.debug.print("\x1B[2J\x1B[H", .{});
        // printMap();
        // std.time.sleep(10000000);
    }
}

fn generateRiver() void {
    var rng = std.rand.DefaultPrng.init(@intCast(std.time.timestamp()));
    const rand = rng.random();
    const edge = rand.intRangeLessThan(u8, 0, 4);
    switch (edge) {
        0 => {
            var river_coords: coords = .{ .row = map_size.row - 2, .column = rand.intRangeLessThan(u8, 1, map_size.column - 1) };
            map[river_coords.row][river_coords.column] = water;
            while (map[river_coords.row][river_coords.column] != '#') {
                const direction = rand.intRangeLessThan(u8, 0, 5);
                switch (direction) {
                    0 => {
                        if (map[river_coords.row][river_coords.column + 1] == '#') break;
                        if (map[river_coords.row][river_coords.column + 1] != water) {
                            river_coords.column += 1;
                        }
                    },
                    1 => {
                        if (map[river_coords.row][river_coords.column - 1] == '#') break;
                        if (map[river_coords.row][river_coords.column - 1] != water) {
                            river_coords.column -= 1;
                        }
                    },
                    2...4 => {
                        if (map[river_coords.row - 1][river_coords.column] == '#') break;
                        river_coords.row -= 1;
                    },
                    else => {},
                }
                map[river_coords.row][river_coords.column] = water;
                // std.debug.print("\x1B[2J\x1B[H", .{});
                // printMap();
                // std.time.sleep(10000000);
            }
        },
        1 => {
            var river_coords: coords = .{ .row = 1, .column = rand.intRangeLessThan(u8, 1, map_size.column - 1) };
            map[river_coords.row][river_coords.column] = water;
            while (map[river_coords.row][river_coords.column] != '#') {
                const direction = rand.intRangeLessThan(u8, 0, 5);
                switch (direction) {
                    0 => {
                        if (map[river_coords.row][river_coords.column + 1] == '#') break;
                        if (map[river_coords.row][river_coords.column + 1] != water) {
                            river_coords.column += 1;
                        }
                    },
                    1 => {
                        if (map[river_coords.row][river_coords.column - 1] == '#') break;
                        if (map[river_coords.row][river_coords.column - 1] != water) {
                            river_coords.column -= 1;
                        }
                    },
                    2...4 => {
                        if (map[river_coords.row + 1][river_coords.column] == '#') break;
                        river_coords.row += 1;
                    },
                    else => {},
                }
                map[river_coords.row][river_coords.column] = water;
                // std.debug.print("\x1B[2J\x1B[H", .{});
                // printMap();
                // std.time.sleep(10000000);
            }
        },
        2 => {
            var river_coords: coords = .{ .row = rand.intRangeLessThan(u8, 1, map_size.row - 1), .column = map_size.column - 2 };
            map[river_coords.row][river_coords.column] = water;
            while (map[river_coords.row][river_coords.column] != '#') {
                const direction = rand.intRangeLessThan(u8, 0, 5);
                switch (direction) {
                    0 => {
                        if (map[river_coords.row + 1][river_coords.column] == '#') break;
                        if (map[river_coords.row + 1][river_coords.column] != water) {
                            river_coords.row += 1;
                        }
                    },
                    1 => {
                        if (map[river_coords.row - 1][river_coords.column] == '#') break;
                        if (map[river_coords.row - 1][river_coords.column] != water) {
                            river_coords.row -= 1;
                        }
                    },
                    2...4 => {
                        if (map[river_coords.row][river_coords.column - 1] == '#') break;
                        river_coords.column -= 1;
                    },
                    else => {},
                }
                map[river_coords.row][river_coords.column] = water;
                // std.debug.print("\x1B[2J\x1B[H", .{});
                // printMap();
                // std.time.sleep(10000000);
            }
        },
        3 => {
            var river_coords: coords = .{ .row = rand.intRangeLessThan(u8, 1, map_size.row - 1), .column = 1 };
            map[river_coords.row][river_coords.column] = water;
            while (map[river_coords.row][river_coords.column] != '#') {
                const direction = rand.intRangeLessThan(u8, 0, 5);
                switch (direction) {
                    0 => {
                        if (map[river_coords.row + 1][river_coords.column] == '#') break;
                        if (map[river_coords.row + 1][river_coords.column] != water) {
                            river_coords.row += 1;
                        }
                    },
                    1 => {
                        if (map[river_coords.row - 1][river_coords.column] == '#') break;
                        if (map[river_coords.row - 1][river_coords.column] != water) {
                            river_coords.row -= 1;
                        }
                    },
                    2...4 => {
                        if (map[river_coords.row][river_coords.column + 1] == '#') break;
                        river_coords.column += 1;
                    },
                    else => {},
                }
                map[river_coords.row][river_coords.column] = water;
                // std.debug.print("\x1B[2J\x1B[H", .{});
                // printMap();
                // std.time.sleep(10000000);
            }
        },
        else => {},
    }
}

fn printMap() void {
    var rng = std.rand.DefaultPrng.init(@intCast(std.time.timestamp()));
    const rand = rng.random();

    for (map) |row| {
        for (row) |square| {
            // std.debug.print("{} ", .{variation});
            switch (square) {
                0 => {
                    for (0..2) |_| {
                        const variation = rand.intRangeLessThan(u8, 0, 2);
                        switch (variation) {
                            0 => std.debug.print("{s}A{s}", .{ WHITE, RESET }),
                            1 => std.debug.print("{s}^{s}", .{ WHITE, RESET }),
                            else => {},
                        }
                    }
                },
                1 => {
                    for (0..2) |_| {
                        const variation = rand.intRangeLessThan(u8, 0, 4);
                        switch (variation) {
                            0 => std.debug.print("{s}@{s}", .{ GREEN, RESET }),
                            1 => std.debug.print("{s}${s}", .{ GREEN, RESET }),
                            2 => std.debug.print("{s}&{s}", .{ GREEN, RESET }),
                            3 => std.debug.print("{s}%{s}", .{ GREEN, RESET }),
                            else => {},
                        }
                    }
                },
                2 => {
                    for (0..2) |_| {
                        const variation = rand.intRangeLessThan(u8, 0, 4);
                        switch (variation) {
                            0 => std.debug.print("{s},{s}", .{ BRIGHT_GREEN, RESET }),
                            1 => std.debug.print("{s}.{s}", .{ BRIGHT_GREEN, RESET }),
                            2 => std.debug.print("{s}'{s}", .{ BRIGHT_GREEN, RESET }),
                            3 => std.debug.print("{s}.{s}", .{ BRIGHT_GREEN, RESET }),
                            else => {},
                        }
                    }
                },
                3 => {
                    for (0..2) |_| {
                        const variation = rand.intRangeLessThan(u8, 0, 2);
                        switch (variation) {
                            0 => std.debug.print("{s}~{s}", .{ BLUE, RESET }),
                            1 => std.debug.print("{s}-{s}", .{ BLUE, RESET }),
                            else => {},
                        }
                    }
                },
                else => if (square != '#') std.debug.print("{c} ", .{square}),
            }
        }
        std.debug.print("\n", .{});
    }
}
