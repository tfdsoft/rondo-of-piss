// For more than 16 bits use extra macros and shit
// Naming convention: crossPRGBankJump<bitsIn>
#define crossPRGBankJump0(sym, args) (__asm__("lda #<%v \n ldx #>%v \n ldy #<.bank(%v) \n jsr crossPRGBankJump ", sym, sym, sym), __asm__("lda ptr3 \n ldx ptr3+1"), __AX__)
#define crossPRGBankJump8(sym, args) (__A__ = args, __asm__("sta ptr3 "), crossPRGBankJump0(sym, args))
#define crossPRGBankJump16(sym, args) (__AX__ = args, __asm__("sta ptr3 \n stx ptr3+1"),crossPRGBankJump0(sym, args))