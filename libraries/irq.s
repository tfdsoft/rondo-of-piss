irq:
        pha
        txa
        pha
        tya
        pha
        
        sta $e000    ; disable mmc3 irq
                    ; any value will do
        
        jsr irq_parser
        
        pla
        tay
        pla
        tax
        pla

        rti
        
        
    ;format
    ;value < 0xf0, it's a scanline count
    ;zero is valid, it triggers an IRQ at the end of the current line

    ;if >= 0xf0...
    ;f0 = 2000 write, next byte is write value
    ;f1 = 2001 write, next byte is write value
    ;f2-f4 unused - future TODO ?
    ;f5 = 2005 write, next byte is H Scroll value
    ;f6 = 2006 write, next 2 bytes are write values


    ;f7 = change CHR mode 0, next byte is write value
    ;f8 = change CHR mode 1, next byte is write value
    ;f9 = change CHR mode 2, next byte is write value
    ;fa = change CHR mode 3, next byte is write value
    ;fb = change CHR mode 4, next byte is write value
    ;fc = change CHR mode 5, next byte is write value

    ;fd = very short wait, no following byte 
    ;fe = short wait, next byte is quick loop value
    ;(for fine tuning timing of things)

    ;ff = end of data set

        
    irq_parser:
        ldy mmc3IRQTableIndex
    ;    ldx #0
    @loop:
        lda (mmc3IRQTablePtr), y ; get value from array
        iny
        cmp #$fd ;very short wait
        beq @loop
        
        cmp #$fe ;fe-ff wait or exit
        bcs @wait
        
        cmp #$f0
        bcs @1
        jmp @scanline ;below f0
    @1:    
        
        cmp #$f7
        bcs @chr_change
    ;f0-f6    
        tax
        lda (mmc3IRQTablePtr), y ; get value from array
        iny
        cpx #$f0
        bne @2
        sta $2000 ; f0
        jmp @loop
    @2:
        cpx #$f1
        bne @3
        sta $2001 ; f1
        jmp @loop
    @3:
        cpx #$f5 
        bne @4
        ldx #4
    @better_timing: ; don't change till near the end of the line
        dex
        bne @better_timing
        
        sta $2005 ; f5
        sta $2005 ; second value doesn't matter
        jmp @loop
    @4:
        sta $2006 ; f6
        lda (mmc3IRQTablePtr), y ; get 2nd value from array
        iny    
        sta $2006
        jmp @loop
        
    @wait: ; fe-ff wait or exit
        cmp #$ff
        beq @exit    
        lda (mmc3IRQTablePtr), y ; get value from array
        iny
        tax
        beq @loop ; if zero, just exit
    @wait_loop: ; the timing of this wait could change if this crosses a page boundary
        dex
        bne @wait_loop        
        jmp @loop    

    @chr_change:
    ;f7-fc change a CHR set
        sec
        sbc #$f7 ;should result in 0-5
        ora #$80 ;A12_INVERT
        sta $8000
        lda (mmc3IRQTablePtr), y ; get next value
        iny
        sta $8001

        lda mmc3_8000 ;restore the MMC3 bank select register
        sta $8000     ;in case we interrupted something
        jmp @loop
        
    @scanline:
        nop ;trying to improve stability
        nop
        nop
        nop
        jsr set_scanline_count ;this terminates the set
        sty mmc3IRQTableIndex
        rts
        
    @exit:
        sta mmc3IRQJoever ;value 0xff
        dey ; undo the previous iny, keep it pointed to ff
        sty mmc3IRQTableIndex
        rts