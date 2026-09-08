const rl = @cImport({
    @cInclude("raylib.h");
});

const std = @import("std");
const math = std.math; 

pub fn main() void 
{
    const screen_width = 800;
    const screen_height = 450;
    const screen_center: rl.Vector2 = .{.x = screen_width / 2, .y = screen_height / 2};
    const beam_length = @min(screen_width, screen_height);
    
    rl.InitWindow(screen_width, screen_height, "Raylib Radar Example");
    defer rl.CloseWindow();

    rl.SetTargetFPS(60);

    const seconds_per_rotation: f32 = 3.0;
    const rotation_delta = getRotationDeltaRad(60.0, seconds_per_rotation);
    var radar_azimuth: f32 = 0.0; // radians

    // TODO(bcall): implement camera and moving around
    while (!rl.WindowShouldClose()) 
    {
        radar_azimuth += rotation_delta;
        radar_azimuth = @mod(radar_azimuth, 2.0 * math.pi);
        const beam_end: rl.Vector2 = .{
            .x = screen_center.x + beam_length*math.sin(radar_azimuth), 
            .y = screen_center.y - beam_length*math.cos(radar_azimuth) // NOTE(bcall): minus because 0,0 is top left
        };

        rl.BeginDrawing();
        rl.ClearBackground(rl.RAYWHITE);

        rl.DrawLineEx(screen_center, beam_end, 5, rl.GREEN);
        rl.DrawCircle(screen_center.x, screen_center.y, 10, rl.GREEN);
        rl.DrawText(rl.TextFormat("Azimuth: %.2f", radar_azimuth * 180.0 / math.pi), 10, 10, 20, rl.BLACK);
        
        rl.EndDrawing();
    }
}

fn getRotationDeltaRad(fps: f32, seconds_per_rotation: f32) f32
{
    return 2 * math.pi / seconds_per_rotation / fps;
}
