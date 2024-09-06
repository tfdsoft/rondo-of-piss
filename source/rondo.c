#include "include.h"

void main(){
    mmc3_set_8kb_chr(0);

    while (1) {
        ppu_wait_nmi();
        pad_poll(0);
    }
}