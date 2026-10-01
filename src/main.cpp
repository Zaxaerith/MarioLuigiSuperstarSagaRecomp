// Mario & Luigi: Superstar Saga (GBA) — host integration entry point.
//
// The framework runtime owns the window, audio device, input mapping, save
// handling, launcher UI, debug TCP server and the ARM CPU/bus/PPU lifecycle.
// See gbarecomp-main/src/runtime/runtime.h.
//
// The two builtin values below must equal docs/ROM_IDENTITY.json.

#include "runtime.h"

int main(int argc, char** argv) {
    gbarecomp::RunOptions options;
    options.builtin_game_name = "Mario & Luigi: Superstar Saga";
    options.builtin_rom_sha1 = "7c303cdde5061ee329296948060b875cb50ba410";
    return gbarecomp::run_game(argc, argv, options);
}
