

const rl = @cImport({
    @cInclude("raylib.h");
});

const std = @import("std");
const math = std.math;

pub fn main() void 
{
    var screen_width: c_int = 800;
    var screen_height: c_int = 450;

    const beam_length: f32 = 200.0;

    rl.SetConfigFlags(rl.FLAG_WINDOW_RESIZABLE);
    rl.InitWindow(screen_width, screen_height, "Raylib Radar Example");
    defer rl.CloseWindow();

    rl.SetTargetFPS(60);

    const seconds_per_rotation: f32 = 3.0;
    const rotation_delta = getRotationDeltaRad(60.0, seconds_per_rotation);

    var radar_azimuth: f32 = 0.0;

    var camera: rl.Camera2D = std.mem.zeroes(rl.Camera2D);

    // Camera looks at world position (0, 0)
    camera.target = .{
        .x = 0.0,
        .y = 0.0,
    };

    camera.rotation = 0.0;
    camera.zoom = 1.0;

    while (!rl.WindowShouldClose()) 
    {
        screen_width = rl.GetScreenWidth();
        screen_height = rl.GetScreenHeight();
        
        // -------------------------
        // Camera
        // -------------------------

        // NOTE(bcall): Keep camera offset at the center of the window.
        // This is the screen position where camera.target appears.
        camera.offset = .{
            .x = @as(f32, @floatFromInt(screen_width)) / 2.0,
            .y = @as(f32, @floatFromInt(screen_height)) / 2.0,
        };

        const camera_speed: f32 = 5.0;

        if (rl.IsKeyDown(rl.KEY_UP))    { camera.target.y -= camera_speed; }
        if (rl.IsKeyDown(rl.KEY_W))     { camera.target.y -= camera_speed; }

        if (rl.IsKeyDown(rl.KEY_DOWN))  { camera.target.y += camera_speed; }
        if (rl.IsKeyDown(rl.KEY_S))     { camera.target.y += camera_speed; }

        if (rl.IsKeyDown(rl.KEY_LEFT))  { camera.target.x -= camera_speed; }
        if (rl.IsKeyDown(rl.KEY_A))     { camera.target.x -= camera_speed; }
        
        if (rl.IsKeyDown(rl.KEY_RIGHT)) { camera.target.x += camera_speed; }
        if (rl.IsKeyDown(rl.KEY_D))     { camera.target.x += camera_speed; }

        const wheel = rl.GetMouseWheelMove();
        camera.zoom *= @exp(wheel * 0.1);
        camera.zoom = @max(0.1, @min(camera.zoom, 10.0));
        
        // -------------------------
        // Radar
        // -------------------------

        radar_azimuth += rotation_delta;
        radar_azimuth = @mod(radar_azimuth, 2.0 * math.pi);
        
        const radar_center: rl.Vector2 = .{ .x = 0.0, .y = 0.0, };

        const beam_end: rl.Vector2 = .{
            .x = radar_center.x + beam_length * math.sin(radar_azimuth),
            .y = radar_center.y - beam_length * math.cos(radar_azimuth),
        };

        // -------------------------
        // Drawing
        // -------------------------

        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.ClearBackground(rl.RAYWHITE);

        // NOTE(bcall): everything inside camera is relative to WORLD coordinates
        rl.BeginMode2D(camera);

        rl.DrawLineEx(radar_center, beam_end, 5.0, rl.GREEN);
        rl.DrawCircleV(radar_center, 10.0, rl.GREEN);

        // Draw radar circles
        rl.DrawCircleLines(0, 0, 50.0, rl.GREEN);
        rl.DrawCircleLines(0, 0, 100.0, rl.GREEN);
        rl.DrawCircleLines(0, 0, 150.0, rl.GREEN);
        rl.DrawCircleLines(0, 0, 200.0, rl.GREEN);

        rl.EndMode2D();

        // NOTE(bcall): everything outside camera is relative to screen
        rl.DrawText(
            rl.TextFormat("Azimuth: %.2f", radar_azimuth * 180.0 / math.pi),
            10, 10, 20, rl.BLACK,
        );
    }
}

fn getRotationDeltaRad(fps: f32, seconds_per_rotation: f32) f32 
{
    return 2.0 * math.pi / seconds_per_rotation / fps;
}
