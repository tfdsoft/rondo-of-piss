;
; File generated by cc65 v 2.19 - Git 0541b65aa
;
	.fopt		compiler,"cc65 v 2.19 - Git 0541b65aa"
	.setcpu		"6502"
	.smart		on
	.autoimport	on
	.case		on
	.debuginfo	on
	.importzp	sp, sreg, regsave, regbank
	.importzp	tmp1, tmp2, tmp3, tmp4, ptr1, ptr2, ptr3, ptr4
	.macpack	longbranch
	.dbg		file, "source/rondo.c", 73, 1725420335
	.dbg		file, "source/include.h", 0, 1724894876
	.forceimport	__STARTUP__
	.export		_main

; ---------------------------------------------------------------
; void __near__ main (void)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_main: near

	.dbg	func, "main", "00", static, "_main"

.segment	"CODE"

;
; while (1) {
;
	.dbg	line, "source/rondo.c", 6
L0005:	jmp     L0005

	.dbg	line
.endproc

