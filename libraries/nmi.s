;NMI handler

nmi:
	pha
	txa
	pha
	tya
	pha

	lda #0
    sta mmc3IRQTableIndex
    sta mmc3IRQJoever

	lda <PPU_MASK_VAR	;if rendering is disabled, do not access the VRAM at all
	and #%00011000
	bne @renderingOn
	jmp	@skipAll
	
@renderingOn:	
	lda <VRAM_UPDATE ;is the frame complete?
	bne @doUpdate
	jmp @skipAll ;skipUpd

@doUpdate:
	lda #0
	sta <VRAM_UPDATE

	lda <PPU_MASK_VAR
	and #%11100111		;	Disable BG and sprites
	ora #%11100000		;	Enable dark emphasis
	sta PPU_MASK

	lda #>OAM_BUF		;update OAM
	sta PPU_OAM_DMA

	lda <PAL_UPDATE		;update palette if needed
	bne @updPal
	jmp @updVRAM

@updPal:

	ldx #0
	stx <PAL_UPDATE

	lda #$3f
	sta PPU_ADDR
	stx PPU_ADDR

	ldy PAL_BUF				;background color, remember it in X
	lda (PAL_BG_PTR),y
	sta PPU_DATA
	tax
	
	.repeat 3,I
	ldy PAL_BUF+1+I
	lda (PAL_BG_PTR),y
	sta PPU_DATA
	.endrepeat

	.repeat 3,J		
	stx PPU_DATA			;background color
	.repeat 3,I
	ldy PAL_BUF+5+(J*4)+I
	lda (PAL_BG_PTR),y
	sta PPU_DATA
	.endrepeat
	.endrepeat

	.repeat 4,J		
	stx PPU_DATA			;background color
	.repeat 3,I
	ldy PAL_BUF+17+(J*4)+I
	lda (PAL_SPR_PTR),y
	sta PPU_DATA
	.endrepeat
	.endrepeat

@updVRAM:
	
	lda <NAME_UPD_ENABLE
	beq @skipUpd

	jsr _flush_vram_update2

@skipUpd:

	lda #0
	sta PPU_ADDR
	sta PPU_ADDR

	lda <SCROLL_X
	sta PPU_SCROLL
	lda <SCROLL_Y
	sta PPU_SCROLL

	lda <PPU_CTRL_VAR
	sta PPU_CTRL

	jsr irq_parser ; needs to happen inside v-blank... 
                   ; so goes before the music
            ; but, if screen is off this should be skipped

@skipAll:

	lda <PPU_MASK_VAR
	sta PPU_MASK

	inc <FRAME_CNT1
	inc <FRAME_CNT2

	lda auto_fs_updates
	beq :+
	jsr _music_update
	:

	pla
	tay
	pla
	tax
	pla
	rti
