#include "include.h"

void main(){
    ppu_off();
    mmc3_set_8kb_chr(0);

    funny = 0;
    music_play(0);
    pal_bright(4);
    
    ppu_on_all();
    while (1) {
        ppu_wait_nmi();
        pad_poll(0);
        pal_col(0x00, funny);
        ++funny;
        if (funny > 0x3f) funny = 0;


        if (pad_new & PAD_A) sfx_play(0,0);
    }
}