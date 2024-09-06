#include "include.h"

void main(){
    mmc3_set_8kb_chr(0);

    music_play(0);
    while (1) {
        ppu_wait_nmi();
        pad_poll(0);
        if (pad_new & PAD_A) sfx_play(0,0);
    }
}