; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's speed as he rolls
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_RollSpeed:			; XREF: Obj01_MdRoll
		move.w	(v_sonspeedmax).w,d6
		asl.w	#1,d6
		move.w	(v_sonspeedacc).w,d5
		asr.w	#1,d5
		move.w	(v_sonspeeddec).w,d4
		asr.w	#2,d4
		tst.b	(f_jumponly).w
		bne.w	loc_131CC
		tst.w	obLRLock(a0)	;Mercury Constants
		bne.s	@notright
		btst	#bitL,(v_jpadhold2).w ; is left being pressed?
		beq.s	@notleft	; if not, branch
		bsr.w	Sonic_RollLeft

	@notleft:
		btst	#bitR,(v_jpadhold2).w ; is right being pressed?
		beq.s	@notright	; if not, branch
		bsr.w	Sonic_RollRight

	@notright:
		move.w	obInertia(a0),d0
		beq.s	loc_131AA
		bmi.s	loc_1319E
		sub.w	d5,d0
		bcc.s	loc_13198
		move.w	#0,d0

loc_13198:
		move.w	d0,obInertia(a0)
		bra.s	loc_131AA
; ===========================================================================

loc_1319E:				; XREF: Sonic_RollSpeed
		add.w	d5,d0
		bcc.s	loc_131A6
		move.w	#0,d0

loc_131A6:
		move.w	d0,obInertia(a0)

loc_131AA:
		tst.w	obInertia(a0)	; is Sonic moving?
		bne.s	loc_131CC	; if yes, branch
		bclr	#staSpin,obStatus(a0)	;Mercury Constants
		move.b	#$13,obHeight(a0)
		move.b	#9,obWidth(a0)
		move.b	#id_Wait,obAnim(a0) ; use "standing" animation
		subq.w	#5,obY(a0)

loc_131CC:

	;Mercury Screen Scroll While Rolling Fix
		cmp.w	#$60,(v_lookshift).w
		beq.s	@cont2
		bcc.s	@cont1
		addq.w	#4,(v_lookshift).w

	@cont1:
		subq.w	#2,(v_lookshift).w

	@cont2:
	;end Screen Scroll While Rolling Fix

		move.b	obAngle(a0),d0
		jsr	(CalcSine).l
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		cmpi.w	#$1000,d1
		ble.s	loc_131F0
		move.w	#$1000,d1

loc_131F0:
		cmpi.w	#-$1000,d1
		bge.s	loc_131FA
		move.w	#-$1000,d1

loc_131FA:
		move.w	d1,obVelX(a0)
		bra.w	loc_1300C
; End of function Sonic_RollSpeed


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_RollLeft:				; XREF: Sonic_RollSpeed
		move.w	obInertia(a0),d0
		beq.s	loc_1320A
		bpl.s	loc_13218

loc_1320A:
		bset	#staFacing,obStatus(a0)	;Mercury Constants
		move.b	#id_Roll,obAnim(a0) ; use "rolling" animation
		rts	
; ===========================================================================

loc_13218:
		sub.w	d4,d0
		bcc.s	loc_13220
		
	if RollingTurnAroundFix=1	;Mercury Rolling Turn Around Fix
		move.w	#0,d0
	else
		move.w	#-$80,d0
	endc	;end Rolling Turn Around Fix

loc_13220:
		move.w	d0,obInertia(a0)
		rts	
; End of function Sonic_RollLeft


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_RollRight:			; XREF: Sonic_RollSpeed
		move.w	obInertia(a0),d0
		bmi.s	loc_1323A
		bclr	#staFacing,obStatus(a0)	;Mercury Constants
		move.b	#id_Roll,obAnim(a0) ; use "rolling" animation
		rts	
; ===========================================================================

loc_1323A:
		add.w	d4,d0
		bcc.s	loc_13242
		
	if RollingTurnAroundFix=1	;Mercury Rolling Turn Around Fix
		move.w	#0,d0
	else
		move.w	#$80,d0
	endc	;end Rolling Turn Around Fix
		

loc_13242:
		move.w	d0,obInertia(a0)
		rts	
; End of function Sonic_RollRight