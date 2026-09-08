zig build-exe main.zig ^
  -lc ^
  -IC:\raylib\raylib\zig-out\include ^
  -LC:\raylib\raylib\zig-out\lib ^
  -lraylib ^
  -lwinmm ^
  -lgdi32 ^
  -lopengl32 ^
  -lshell32 ^
  -luser32
