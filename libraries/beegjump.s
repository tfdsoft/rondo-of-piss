.segment "CODE_2"

.export crossPRGBankJump
.proc crossPRGBankJump
	; AX = address of function
	; Y = bank of function
	STA ptr4
	STX ptr4+1
	LDA mmc3PRG1Bank
	PHA
	TYA
	JSR mmc3_set_prg_bank_1
	LDA ptr3
	LDX ptr3+1
	JSR callptr4
	STA ptr3
	STX ptr3+1
	PLA
	JMP mmc3_set_prg_bank_1
.endproc