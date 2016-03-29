;APS000000FD000000FD000000FD00001F2E000000FD000000FD000000FD000000FD000000FD000000FD
; ----------------------------------------------------------
;                         Kim Pong Il
;                    Written 2012 - 2014
;           By Patrik Axelsson and David Eriksson
; ----------------------------------------------------------


	incdir	"src:"
	include "hwstartup.asm"
	incdir	"ndk:Include/include_i/"
	include "hardware/custom.i"
	include "hardware/intbits.i"
	include	"hardware/blit.i"
	include "hardware/dmabits.i"
	include "devices/inputevent.i"
	incdir	"src:"

_main:	
	move.l	4.w,a6
	move.l	#10240, d0
	move.l	#MEMF_CHIP|MEMF_CLEAR, d1
	jsr	_LVOAllocMem(a6)

	tst.l	d0
	beq.w	NotEnoughMemExit

	move.l	d0, bitPlane0


	lea	VBlankServer(pc), a1
	moveq.l	#INTB_VERTB, d0
	jsr	_LVOAddIntServer(a6)

	move.l	bitPlane0, d0
	move.w	d0, bplpt1l
	swap	d0
	move.w	d0, bplpt1h
	swap	d0

	move.l	d0, a0
	add.l	#1360, a0
	move.l	#40-1, d0

; Draw Background Bitmap mega loops!!!! omg!
drawUpperBorder:	
	move.l	#$ffffffff, (a0)+
	dbeq	d0, drawUpperBorder

	move.l	#17-1, d0
	add.l	#160+18, a0
draw17Squares:
	move.l	#6-1, d1
.innerLoop:
	move.l	#$0007e000, (a0)
	add.l	#40, a0
	dbeq	d1, .innerLoop

	add.l	#160, a0
	dbeq	d0, draw17Squares

	sub.l	#18, a0
	move.l	#40-1, d0
drawLowerBorder:	
	move.l	#$ffffffff, (a0)+
	dbeq	d0, drawLowerBorder

	


; Set positions for sprites in chip mem

	move.l	#sprite0, d0
	move.w	d0, sprite0l
	swap	d0
	move.w	d0, sprite0h

	move.l	#sprite1, d0
	move.w	d0, sprite1l
	swap	d0
	move.w	d0, sprite1h

	move.l	#sprite2, d0
	move.w	d0, sprite2l
	swap	d0
	move.w	d0, sprite2h

	move.l	#dummySprite, d0
	move.w	d0, sprite3l
	move.w	d0, sprite4l
	move.w	d0, sprite5l
	move.w	d0, sprite6l
	move.w	d0, sprite7l
	swap	d0
	move.w	d0, sprite3h
	move.w	d0, sprite4h
	move.w	d0, sprite5h
	move.w	d0, sprite6h
	move.w	d0, sprite7h

	jsr	WaitVbl
	jsr	WaitVbl
		
	lea	$dff000, a5
	move.l	#copperList, cop1lc(a5)
	move.w	copjmp1(a5), d0

	jsr	InitPlayers
	jsr	DrawScoreBoard

.MainLoop:
	jsr	WaitVbl
	jsr	CheckSound
	move.w	joy1dat(a5), d0
	
	move.w	d0, d1
	asr.w	#1,d1
	eor.w	d0, d1 ; Merge up/down status into single bits
	
	btst	#8, d1 ; Up?
	beq.b	.DoneUp0
	cmp	#upperBorder, player0+posY
	bmi.b	.DoneUp0
	add.w	#-1, player0+posY
.DoneUp0:
	btst	#0, d1 ; Down?
	beq.b	.DoneDown0
	cmp	#lowerBorder-playerHeight, player0+posY
	bpl.b	.DoneDown0
	add.w	#1, player0+posY
.DoneDown0:
	move.w	#player0X, d0
	move.w	player0+posY, d1
	move.w	#playerHeight,d2
	move.l	#sprite0, a0
	jsr	SetSpritePos


	move.w	joy0dat(a5), d0
	
	move.w	d0, d1
	asr.w	#1,d1
	eor.w	d0, d1 ; Merge up/down status into single bits
	
	btst	#8, d1 ; Up?
	beq.b	.DoneUp1
	cmp	#upperBorder, player1+posY
	bmi.b	.DoneUp1
	add.w	#-1, player1+posY
.DoneUp1:
	btst	#0, d1 ; Down?
	beq.b	.DoneDown1
	cmp	#lowerBorder-playerHeight, player1+posY
	bpl.b	.DoneDown1
	add.w	#1, player1+posY
.DoneDown1:
	move.w	#player1X, d0
	move.w	player1+posY, d1
	move.w	#playerHeight,d2
	move.l	#sprite1, a0
	jsr	SetSpritePos

	jsr	MoveBall

	tst.w	quitGameF
	beq.w	.MainLoop



Exit:
	jsr	SoundEngineShutDown
	move.l	4.w,a6
	move.l	bitPlane0, a1
	move.l	#10240, d0
	jsr	_LVOFreeMem(a6)
	lea	VBlankServer(pc), a1
	moveq.l	#INTB_VERTB, d0
	jsr	_LVORemIntServer(a6)
NotEnoughMemExit:
	moveq	#RETURN_OK,d0
	rts

quitGameF:	dc.w	0

player0X = 16
player1X = 298
playerHeight = 32
playerWidth = 6
ballSize = 6
upperBorder = 40
lowerBorder = 211
screenWidth = 320

player0:	dc.w	0,0 ; not used, set in initgame
player1:	dc.w	0,0 ; not used
ball:		dc.w	156,122,-2,0 ; x=156=mitten=yay
score=0
posX=0
posY=2
speedX=4
speedY=6


hitCounter:	dc.w	0

		dcb.w	2, -1
SpeedTable:	dcb.w	3, 3
		dcb.w	9, 2
		dcb.w	9, 1
		dc.w	0
		dc.w	0
		dcb.w	9, -1
		dcb.w	9, -2
		dcb.w	3, -3
		dcb.w	2, 1

FontTable:	dc.l	font0,font1,font2,font3,font4,font5,font6,font7,font8,font9,font0,font0,font0,font0,font0,font0


****************************************

	; d0 = ball x position
	; d1 = ball y position
	; d2 = temp

Player0col:
	; d2 = player y
	cmp.w	#0, ball+speedX		; If ball moves right skip check
	bpl.b	.noCol
	cmp.w	#player0X-ballSize, d0
	bmi.b	.noCol
	move.w	player0+posY, d2
	sub.w	d1, d2			; d2 - d1 -> d2
	; d2 = player y - ball y

	cmp.w	#ballSize, d2
	bpl.b	.noCol

	cmp.w	#-(playerHeight-1), d2
	bmi.b	.noCol

	;Collision
	move.w	#1000, d0
	move.w	#10, d1
	jsr	SoundEngine


	;move.w	#$0000, $dff000+color
	jsr	IncHitCounter
	add.w	#playerHeight+(ballSize/2), d2 ; Offset in middle
	asl.w	#1, d2
	move.l	#SpeedTable, a0
	adda.w	d2, a0
	move.w	(a0), ball+speedY
	move.w	ball+speedX, d2
	muls.w	#-1, d2
	move.w	d2, ball+speedX
.noCol:
	jmp	CheckY


Player1col:
	; d2 = player y
	cmp.w	#0, ball+speedX		; If ball moves left skip check
	bmi.b	.noCol
	cmp.w	#player1X+playerWidth+ballSize, d0
	bpl.b	.noCol
	move.w	player1+posY, d2
	sub.w	d1, d2			; d2 - d1 -> d2
	; d2 = player y - ball y

	cmp.w	#ballSize, d2
	bpl.b	.noCol

	cmp.w	#-(playerHeight-1), d2
	bmi.b	.noCol

	;Collision
	;move.w	#$0000, $dff000+color
	move.w	#800, d0
	move.w	#10, d1
	jsr	SoundEngine

	jsr	IncHitCounter
	add.w	#playerHeight+(ballSize/2), d2 ; Offset in middle
	asl.w	#1, d2
	move.l	#SpeedTable, a0
	adda.w	d2, a0
	move.w	(a0), ball+speedY
	move.w	ball+speedX, d2
	muls.w	#-1, d2
	move.w	d2, ball+speedX
.noCol:
	jmp	CheckY


CheckForScore:
	move.w	ball+posX, d0
	cmp.w	#0-ballSize, d0
	bpl.b	.NoScorePlayer1
	move.w	#1, d1
	move.w	player1+score, d2	
	andi.b	#$ef, ccr
	abcd	d1, d2
	move.w	d2, player1+score
	cmp.w	#$15, d2
	beq.b	.Victory
	jsr	ResetBall
	rts
.NoScorePlayer1:
	cmp.w	#screenWidth, d0
	bmi.b	.NoScorePlayer0
	move.w	#1, d1
	move.w	player0+score, d2
	andi.b	#$ef, ccr
	abcd	d1, d2
	move.w	d2, player0+score
	cmp.w	#$15, d2
	beq.b	.Victory
	jsr	ResetBall
	
.NoScorePlayer0:
	rts

.Victory:
	jsr	VictoryDanceWithReset
	rts
	


VictoryDanceWithReset:
	jsr	DrawScoreBoard

	move.w	#(428*8), d0
	jsr	SoundEngine
	move.l	#15, d0
	jsr	WaitVblNum

	move.w	#(339*8), d0
	jsr	SoundEngine
	move.l	#15, d0
	jsr	WaitVblNum

	move.w	#(285*8), d0
	jsr	SoundEngine
	move.l	#15, d0
	jsr	WaitVblNum

	move.w	#(214*8), d0
	jsr	SoundEngine
	move.l	#30, d0
	jsr	WaitVblNum

	jsr	SoundEngineShutDown

.WaitLoop:
	btst	#6, $bfe001                ; check first joybutton
	beq.b	.done
	btst	#7, $bfe001                ; check second joybutton
	beq.b	.done
	tst.w	quitGameF
	bne.b	.done
	bra.b	.WaitLoop

.done
	jsr	InitPlayers
	jsr	ResetBall
	rts

IncHitCounter:
	add.w	#1, hitCounter
	cmp	#3, hitCounter
	beq.b	.IncBallSpeed
	cmp	#7, hitCounter
	beq.b	.IncBallSpeed
	cmp	#12, hitCounter
	beq.b	.IncBallSpeed
	rts
.IncBallSpeed:
	cmp.w	#0, ball+speedX
	bpl.b	.AddPositiveSpeed
	add.w	#-1, ball+speedX
	rts
.AddPositiveSpeed
	add.w	#1, ball+speedX
	rts


InitPlayers:
	move.l	#108, player0 ; As score is first longword, it is zeroed
	move.l	#108, player1
	rts

ResetBall:
	exg	d0, d4
	exg	d1, d5
	move.w	#2000, d0
	move.w	#20, d1
	jsr	SoundEngine
	exg	d0, d4
	exg	d1, d5
	
	jsr	DrawScoreBoard
	move.w	#0, hitCounter
	move.w	#156, ball+posX
	move.w	#122, ball+posY
	cmp.w	#0, ball+speedX
	bpl.b	.SetPositiveSpeed
	move.w	#-1, ball+speedX
	rts
.SetPositiveSpeed
	move.w	#1, ball+speedX
	rts

DrawScoreBoard:	
	move.l	_GfxBase, a6
	jsr	_LVOOwnBlitter(a6)

	move.l	#FontTable, a1
	move.l	#0, d1
	
	move.w	player0+score, d2
	asr.w	#4, d2
	and.l	#$f, d2
	move.l	#(screenWidth/2)-(64+16), d0
	jsr	.drawNumber

	move.w	player0+score, d2
	and.l	#$f, d2
	move.l	#(screenWidth/2)-(32+16), d0
	jsr	.drawNumber

	move.w	player1+score, d2
	asr.w	#4, d2
	and.l	#$f, d2
	move.l	#(screenWidth/2)+(16), d0
	jsr	.drawNumber

	move.w	player1+score, d2
	and.l	#$f, d2
	move.l	#(screenWidth/2)+(32+16), d0
	jsr	.drawNumber

	jsr	_LVODisownBlitter(a6)

	rts

.drawNumber:
	asl.w	#2, d2
	move.l	0(a1,d2.w), a0
	jsr	Blit32px

;****************************************
	; a0 - Address to blitterdata!!
	; d0 - x pos 
	; d1 - y pos
Blit32px:
	jsr	waitblit
	asr.w	#3, d0
	add.l	bitPlane0, d0
	muls.w	#screenWidth/8, d1
	add.l	d1, d0
	move.l	d0, $dff000+bltdpt ; Set dest
	move.w	#(screenWidth-32)/8, $dff000+bltdmod ; Dest modulo

	move.l	#-1, $dff000+bltafwm

	move.l	a0, $dff000+bltapt ; Set source A
	move.w	#0, $dff000+bltamod ; 32/8 source modulo A

	move.w	#(0<<ASHIFTSHIFT)|$f0|DEST|SRCA, $dff000+bltcon0
	move.w	#0, $dff000+bltcon1

	move.w	#(32<<6)+(32/16), $dff000+bltsize
	rts


MoveBall:
	move.w	ball+posX, d0
	move.w	ball+posY, d1
	add.w	ball+speedX, d0
	move.w	d0, ball+posX
	cmp	#player0X+playerWidth, d0
	bmi.w	Player0col
	cmp	#player1X-ballSize, d0
	bpl.w	Player1col

CheckY:
	move.w	ball+posX, d0
	move.w	ball+posY, d1
	add.w	ball+speedY, d1
	move.w	d1, ball+posY
	cmp.w	#lowerBorder-ballSize, d1
	bpl.b	.invertY
	cmp.w	#upperBorder, d1
	bpl.b	.updateBall

.invertY:
	exg	d0, d4
	exg	d1, d5
	move.w	#1600, d0
	move.w	#6, d1
	jsr	SoundEngine
	exg	d0, d4
	exg	d1, d5

	move.w	ball+speedY, d2
	muls.w	#-1, d2
	move.w	d2, ball+speedY

.updateBall:
	move.w	#ballSize, d2
	move.l	#sprite2, a0
	jsr	SetSpritePos

	jsr	CheckForScore

	rts




;****************************************
	; a0 - spriteAddr
	; d0 - x pos
	; d1 - y pos
	; d2 - height

	; pos (d3)
	;	15-8: start vertical (y)
	;	 7-0: start horizontal (x)
	; ctl (d4)
	;	15-8: stop vertical (y)
	;	   7: attach control bit
	;	   2: start vertical high bit (y)
	;	   1: stop vertical high bit (y)
	;	   0: start horizontal low bit (x)  
SetSpritePos:
	add.w	#$81, d0 ; Add sprite offset to match screen, see
	add.w	#$2c, d1 ; diwstrt in copperlist
	and.w	#%111111111, d0 ; Unnecessary :)
	move.w	d0, d4 ; Also clears :) :(
	and.w	#1, d4 ; Only keep horizontal low bit
	
	asr.w	#1, d0 ; Throw away horizontal low bit
	move.w	d0, d3 ; Store horizontal high bits

	asl.l	#8, d1 ; Move lower bits to correct position, move.w at the
		       ; end will ignore high bit
	btst	#16, d1; Check high bit
	beq.b	.DontSetHighVerticalStartBit
	or.w	#%100, d4
.DontSetHighVerticalStartBit:
	or.w	d1, d3 ; Combine horizontal and vertical start

	asl.l	#8, d2
	add.l	d2, d1 ; add the height to the vertical pos
	or.w	d1, d4

	btst	#16, d1; Check high bit
	beq.b	.DontSetHighVerticalStopBit
	or.w	#%10, d4
.DontSetHighVerticalStopBit:

	move.w	d3, (a0)
	move.w	d4, 2(a0)
	
	rts


soundTimer:	dc.w	0

;*****************************************
	; super mega complex sound engine 2000

	; d0	sample period length or something
	; d1	play sample for d1 frames

SoundEngine:
	move.l	#squareWave, $dff000+aud0+ac_ptr
	move.l	#squareWave, $dff000+aud1+ac_ptr
	move.w	#2, $dff000+aud0+ac_len
	move.w	#2, $dff000+aud1+ac_len
	move.w	#64, $dff000+aud0+ac_vol
	move.w	#64, $dff000+aud1+ac_vol
	move.w	d0, $dff000+aud0+ac_per	; ska vara d0
	move.w	d0, $dff000+aud1+ac_per	; ska vara d0
	move.w	#(DMAF_SETCLR|DMAF_AUD0|DMAF_AUD1), $dff000+dmacon
	move.w	d1, soundTimer	; ska vara d1
	rts

SoundEngineShutDown:
	move.w	#(DMAF_AUD0|DMAF_AUD1), $dff000+dmacon
	rts

CheckSound:
	sub.w	#1, soundTimer
	beq.b	SoundEngineShutDown
	rts

;****************************************

waitblit:
	btst.b	#DMAB_BLTDONE-8, $dff000+dmaconr
waitblit2:
	btst.b	#DMAB_BLTDONE-8, $dff000+dmaconr
	bne.b	waitblit2
	rts

;****************************************

VBlankInterrupt:
	move.w	#1, VBlankFlag
	rts

VBlankServer:
	dc.l	0, 0	; ln_succ, ln_pred
	dc.b	2, 127	; ln_type, ln_pri
	dc.l	.name ; ln_name
	dc.l	0, VBlankInterrupt ; is_data, is_code
.name:
	dc.b "VBlank interrupt", 0
	even

VBlankFlag:
	dc.w	0

WaitVbl:
 	tst.w	VBlankFlag
	beq.b	WaitVbl
	move.w	#0, VBlankFlag
	rts

WaitVblNum:
	jsr	WaitVbl
	dbne	d0, WaitVblNum
 	rts


_keyboardHandler:
	move.w	ie_Code(a0), d1
	cmp.w	#$45, d1
	bne.b	.done
	move.w	#1, quitGameF
.done:
	rts


bitPlane0:
		dc.l	0

	section chipmemstuff, data_c
even

font0:		inciff	"graphics/0.iff"
font1:		inciff	"graphics/1.iff"
font2:		inciff	"graphics/2.iff"
font3:		inciff	"graphics/3.iff"
font4:		inciff	"graphics/4.iff"
font5:		inciff	"graphics/5.iff"
font6:		inciff	"graphics/6.iff"
font7:		inciff	"graphics/7.iff"
font8:		inciff	"graphics/8.iff"
font9:		inciff	"graphics/9.iff"

sprite0:
		dc.w	$0000,$0000
		inciff	"graphics/pong_player_2bpp.iff"

sprite1:
		dc.w	$0000,$0000
		inciff	"graphics/pong_player_2bpp.iff"

sprite2:
		dc.w	$0000,$0000
		inciff	"graphics/pong_ball_2bpp.iff"

dummySprite:	dc.w	$0000,$0000


squareWave:	dc.w	$7f7f
		dc.w	$8080

copperList:	dc.w    bplcon0,$1200      ; otherwise no display!
		dc.w	bplcon1,$0000
		dc.w	bplcon2,$0000
		dc.w	bplcon3,$0000
		dc.w	bplcon4,$0000
                dc.w	diwstrt,$2c81
                dc.w	diwstop,$2cc1
                dc.w	ddfstrt,$0038
                dc.w	ddfstop,$00d0
                dc.w	bpl1mod,$0000
                dc.w	bpl2mod,$0000
                dc.w	bplpt
bplpt1h:        dc.w	$0000
                dc.w	bplpt+2
bplpt1l:        dc.w	$0000

		dc.w	sprpt
sprite0h:	dc.w	$0000
		dc.w	sprpt+2
sprite0l:	dc.w	$0000

		dc.w	sprpt+4
sprite1h:	dc.w	$0000
		dc.w	sprpt+6
sprite1l:	dc.w	$0000

		dc.w	sprpt+8
sprite2h:	dc.w	$0000
		dc.w	sprpt+10
sprite2l:	dc.w	$0000

		dc.w	sprpt+12
sprite3h:	dc.w	$0000
		dc.w	sprpt+14
sprite3l:	dc.w	$0000

		dc.w	sprpt+16
sprite4h:	dc.w	$0000
		dc.w	sprpt+18
sprite4l:	dc.w	$0000

		dc.w	sprpt+20
sprite5h:	dc.w	$0000
		dc.w	sprpt+22
sprite5l:	dc.w	$0000

		dc.w	sprpt+24
sprite6h:	dc.w	$0000
		dc.w	sprpt+26
sprite6l:	dc.w	$0000

		dc.w	sprpt+28
sprite7h:	dc.w	$0000
		dc.w	sprpt+30
sprite7l:	dc.w	$0000

                dc.w    color,$0000
                dc.w	color+2,$0aaa
                dc.w	color+34,$0aaa ; sprite color
                dc.w	color+42,$0aaa ; sprite color
                dc.w    $ffff,$fffe
                dc.w    $ffff,$fffe

	ENDC
