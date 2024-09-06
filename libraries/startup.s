    
.exportzp _VRAM_UPDATE := VRAM_UPDATE

    
    .export _exit,__STARTUP__:absolute=1
	.export _PAL_BUF := PAL_BUF, _PAL_UPDATE := PAL_UPDATE, _xargs := xargs
	.import push0,popa,popax,_main





; Linker generated symbols
	.import __C_STACK_START__, __C_STACK_SIZE__
	.import __PAL_BUF_START__, __OAM_BUF_START__, __VRAM_BUF_START__
	.import	__CODE_LOAD__   ,__CODE_RUN__   ,__CODE_SIZE__
	.import	__RODATA_LOAD__ ,__RODATA_RUN__ ,__RODATA_SIZE__

	.import MAPPER, SUBMAPPER, MIRRORING, PRG_BANK_COUNT, CHR_BANK_COUNT, SRAM, TRAINER, CONSOLE_TYPE, PRG_RAM_COUNT, PRG_NVRAM_COUNT, CHR_RAM_COUNT, CHR_NVRAM_COUNT, CPU_PPU_TIMING, HARDWARE_TYPE, MISC_ROMS, DEF_EXP_DEVICE



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

OAM_BUF		=$0200
;PAL_BUF		=$01c0
VRAM_BUF	=$0700

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
    PAD_STATEP: 		.res 2
    PAD_STATET: 		.res 2
    PPU_CTRL_VAR: 		.res 1
    PPU_CTRL_VAR1: 		.res 1
    PPU_MASK_VAR: 		.res 1
    RAND_SEED: 			.res 2
    ;FT_TEMP: 			.res 3

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

    ;nesdoug code requires
    VRAM_INDEX:			.res 1
    META_PTR:			.res 2
    DATA_PTR:			.res 2

    xargs:				.res 4

.segment "BSS"
    PAL_BUF: .res 32
    current_song_bank:	.res 1
    ;move this out of the hardware stack
    ;the mmc3 code is using more of the stack
    ;and might collide with $1c0-1df

;
; NES 2.0 header
;
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
	lda #%10000000					;	Stolen from initialize_mapper
	sta MMC3_REG_PRG_RAM_PROTECT	;__
    lda $00
    sta $7FFE
    lda $01
    sta $7FFF


    sei
	cld
	ldx #$40
	stx CTRL_PORT2
    ldx #$ff
    txs
    inx
    stx PPU_MASK
    stx DMC_FREQ
    stx PPU_CTRL		;no NMI

initPPU:
    bit PPU_STATUS
@1:
    bit PPU_STATUS
    bpl @1
@2:
    bit PPU_STATUS
    bpl @2

clearPalette:
	lda #$3f
	sta PPU_ADDR
	stx PPU_ADDR
	lda #$0f
	ldx #$20
@1:
	sta PPU_DATA
	dex
	bne @1

clearVRAM:
	txa
	ldy #$20
	sty PPU_ADDR
	sta PPU_ADDR
	ldy #$10
@1:
	sta PPU_DATA
	inx
	bne @1
	dey
	bne @1

clearRAM:
    txa
@1:
    sta $00,x   ;
    sta $0100,x ;
    sta $0200,x ;
    sta $0300,x ;   Clear regular NES RAM
    sta $0400,x ;
    sta $0500,x ;
    sta $0600,x ;
    sta $0700,x ;__
	sta $6000,x ;
	sta $6100,x ;   Clear the collision map space
    sta $6200,x ;
	sta $6300,x ;__
    inx
    bne @1


	lda #4
	jsr _pal_bright
	jsr _pal_clear
	jsr _oam_clear

	jsr initialize_mapper

    ; jsr	zerobss	; Unnecessary, we already zeroed out the entire memory
	;jsr	copydata	; Sets all the initial values of variables

    lda #<(__C_STACK_START__+__C_STACK_SIZE__) ;changed
    sta	sp
    lda	#>(__C_STACK_START__+__C_STACK_SIZE__)
    sta	sp+1            ; Set argument stack ptr

	; jsr	initlib	; removed. this called the CONDES function

	lda #%10100000
	sta <PPU_CTRL_VAR
	sta PPU_CTRL		;enable NMI
	lda #%00000110
	sta <PPU_MASK_VAR

waitSync3:
	lda <FRAME_CNT1
@1:
	cmp <FRAME_CNT1
	beq @1

detectNTSC:
	ldx #52				;blargg's code
	ldy #24
@1:
	dex
	bne @1
	dey
	bne @1

	lda PPU_STATUS
	and #$80
	sta <NTSC_MODE

	jsr _ppu_off

	lda #0
	ldx #0
	jsr _set_vram_update

	;LDA #<-1        ;   Do famistudio_init
    ;JSR _music_play ;__

    ;LDA #<.bank(sounds)
    ;JSR mmc3_tmp_prg_bank_1
    
	;ldx #<sounds
	;ldy #>sounds
	;jsr famistudio_sfx_init

	lda $60FC
	beq @fallback
	sta <RAND_SEED
	lda $60FD
	beq @fallback
	sta <RAND_SEED+1
	lda $60FE
	beq @fallback
	sta <RAND_SEED+2
	lda $60FF
	beq @fallback
	sta <RAND_SEED+3
        bne @done
@fallback:
	lda #$FD
	sta <RAND_SEED
	sta <RAND_SEED+1
	sta <RAND_SEED+2
	sta <RAND_SEED+3
@done:
	lda #0
	sta PPU_SCROLL
	sta PPU_SCROLL

    cli

	jmp _main			;no parameters


    .include "mmc3.s"
    .include "nmi.s"
    .include "irq.s"

.segment "SND_DRV"
    .include "famistudio_ca65.s"
    .include "wrappers.s"

.segment "NESLIB"
    .include "neslib.s"

.segment "sfx"
    .include "../musics/sfx.s"

.segment "chr_00"




.segment "VECTORS"

    .word nmi	;$fffa vblank nmi
    .word start	;$fffc reset
   	.word irq	;$fffe irq / brk