; startup code for cc65

.exportzp _VRAM_UPDATE := VRAM_UPDATE

.import push0,popa,popax,_main

.import __C_STACK_START__, __C_STACK_SIZE__
.import __PAL_BUF_START__, __OAM_BUF_START__, __VRAM_BUF_START__
.import	__CODE_LOAD__   ,__CODE_RUN__   ,__CODE_SIZE__
.import	__RODATA_LOAD__ ,__RODATA_RUN__ ,__RODATA_SIZE__

.import	__DATA_LOAD__,	__DATA_RUN__,	__DATA_SIZE__

; header symbols
.import MAPPER, SUBMAPPER, MIRRORING, PRG_BANK_COUNT, CHR_BANK_COUNT, SRAM, TRAINER, CONSOLE_TYPE, PRG_RAM_COUNT, PRG_NVRAM_COUNT, CHR_RAM_COUNT, CHR_NVRAM_COUNT, CPU_PPU_TIMING, HARDWARE_TYPE, MISC_ROMS, DEF_EXP_DEVICE
.import FIRST_MUSIC_BANK, FIRST_DMC_BANK, _SRAM_VALIDATE

VRAM_BUF=__VRAM_BUF_START__
OAM_BUF=__OAM_BUF_START__
PAL_BUF=__PAL_BUF_START__

.importzp _PAD_STATE, _PAD_STATET ;added
.include "zeropage.inc"

PPU_CTRL	=$2000
PPU_MASK	=$2001
PPU_STATUS	=$2002
PPU_OAM_ADDR=$2003
PPU_OAM_DATA=$2004
PPU_SCROLL	=$2005
PPU_ADDR	=$2006
PPU_DATA	=$2007
PPU_OAM_DMA	=$4014
PPU_FRAMECNT=$4017
DMC_FREQ	=$4010
CTRL_PORT1	=$4016
CTRL_PORT2	=$4017

.segment "ZEROPAGE"

NTSC_MODE: 			.res 1
FRAME_CNT1: 		.res 1
FRAME_CNT2: 		.res 1
VRAM_UPDATE: 		.res 1
NAME_UPD_ADR: 		.res 2
NAME_UPD_ENABLE: 	.res 1
PAL_UPDATE: 		.res 1
PAL_BG_PTR: 		.res 2
PAL_SPR_PTR: 		.res 2
SCROLL_X: 			.res 1
SCROLL_Y: 			.res 1
SCROLL_X1: 			.res 1
SCROLL_Y1: 			.res 1
PAD_STATE: 			.res 2		;one byte per controller
PAD_STATE2: 		.res 2		;one byte per controller
PAD_STATEP: 		.res 2
PAD_STATEP2: 		.res 2
PAD_STATET: 		.res 2
PAD_STATET2: 		.res 2
PPU_CTRL_VAR: 		.res 1
PPU_CTRL_VAR1: 		.res 1
PPU_MASK_VAR: 		.res 1
RAND_SEED: 			.res 4

TEMP: 				.res 11
SPRID:				.res 1

PAD_BUF		=TEMP+1

PTR			=TEMP	;word
LEN			=TEMP+2	;word
NEXTSPR		=TEMP+4
SCRX		=TEMP+5
SCRY		=TEMP+6
SRC			=TEMP+7	;word
DST			=TEMP+9	;word

RLE_LOW		=TEMP
RLE_HIGH	=TEMP+1
RLE_TAG		=TEMP+2
RLE_BYTE	=TEMP+3

VRAM_INDEX:			.res 1

xargs:				.res 4

.segment "HEADER"

    NES2_0_IDENTIFIER = %00001000

    .byte 'N', 'E', 'S', $1A ; ID
    .byte <PRG_BANK_COUNT
    .byte <CHR_BANK_COUNT
    .byte <(MIRRORING | (SRAM << 1) | (TRAINER << 2) | ((MAPPER & $00F) << 4))
    .byte <((MAPPER & $0F0) | CONSOLE_TYPE | NES2_0_IDENTIFIER)
    .byte <(((MAPPER & $F00) >> 8) | SUBMAPPER << 4)
    .byte <(((PRG_BANK_COUNT & $F00) >> 8) | ((CHR_BANK_COUNT & $F00) >> 4))
    .byte <(PRG_RAM_COUNT | (PRG_NVRAM_COUNT << 4))
    .byte <(CHR_RAM_COUNT | (CHR_NVRAM_COUNT << 4))
    .byte <CPU_PPU_TIMING, <HARDWARE_TYPE, <MISC_ROMS, <DEF_EXP_DEVICE

.segment "STARTUP"
start:
_exit:



    jmp _main

    .include "nmi.s"
    .include "irq.s"
    .include "neslib.s"

.segment "VECTORS"

    .word nmi	;$fffa vblank nmi
    .word start	;$fffc reset
   	.word irq	;$fffe irq / brk