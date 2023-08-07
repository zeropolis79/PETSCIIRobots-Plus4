;List of sound fx. The larger the number value, the higher the priority for playback
SOUND_WALK			= $00
SOUND_WALK2			= $01
SOUND_MENU_BEEP		= $02
SOUND_MENU_EXEC		= $03
SOUND_BEEP			= $04
SOUND_DOOR			= $05
SOUND_CYCLE_ITEM	= $06
SOUND_CYCLE_WEAPON	= $06
SOUND_ERROR			= $07
SOUND_ITEM_FOUND	= $08
SOUND_PISTOL		= $09
SOUND_PLASMA		= $0a
SOUND_MOVEOBJ		= $0b
SOUND_SHOCK			= $0c
SOUND_MAGNET		= $0d
SOUND_EMP			= $0e
SOUND_MEDKIT		= $0f
SOUND_EXPLOSION		= $10
SOUND_TELEPORT		= $11

SOUND_PLAYING		!BYTE	$FF		;The sound being played. $FF = no sound playing
SOUND_TIMER			!BYTE	$00		;A countdown timer until the next note is played
SOUND_TIMER_RESTART	!BYTE	$00		;The value to refill the countdown timer with, once a new step has started
SOUND_STEP			!BYTE	$00		;How much to 'step' the sound (increase/decrease frequency) when SOUND_TIMER reaches 0. Bit 7 is negative flag, for decreasing step
SOUND_STEP_TIMER	!BYTE	$00		;How many times to 'step' the sound. If value is $FF, then set SOUND_FADEOUT to non-0
SOUND_FADEOUT		!BYTE	$00		;If non-0, then each call to play the sound will decrease the volume, until the volume is shut off. At that point, the sound will stop playing. The current volume is stored in this variable as well.
SOUND_FREQ_L		!BYTE	$00		;Stores last value saved in $FF0F so we can step up or down from this frequency
SOUND_FREQ_H		!BYTE	$00		;Stores last value saved in $FF10 for frequency as well

;Call PLAY_SOUND with register X=sound to play. The IRQ_PLAY_SOUND routine will then start playing it
PLAY_SOUND:
	LDA SOUND_PLAYING
	CMP #$FF
	BEQ PS2				;No sound is playing, go ahead and play the next one
	CPX SOUND_PLAYING
	BCS	PS2				;Play sound, because it has equal or higher priority than the one playing
	RTS
PS2:
	SEI					;Make sure we aren't interrupted while setting up the new sound to play
	STX SOUND_PLAYING	;Store the sound we are about to play
	LDA SOUND_FX_L,X
	STA SOUND_POS_L
	LDA SOUND_FX_H,X
	STA SOUND_POS_H		;Store 16-bit position of the sound location in memory
	LDA #0
	STA SOUND_TIMER
	STA SOUND_STEP
	STA SOUND_STEP_TIMER
	STA SOUND_FADEOUT
	CLI
	RTS

;IRQ Routine to play sound. Call once a frame. Only call if SOUND_PLAYING != #$FF
IRQ_PLAY_SOUND:
	LDX SOUND_FADEOUT	;Decrease TED volume if flagged to
	CPX #0
	BEQ IRQSOUND1
	DEX
	STX $FF11			;Decrease TED volume
	STX SOUND_FADEOUT
	TXA
	AND #%00001111
	BNE IRQSOUND1		;Volume not completely faded yet, keep going
	LDA #$FF
	STA SOUND_PLAYING	;Stop playing since the volume has fully faded out
	RTS
IRQSOUND1:
	LDA SOUND_TIMER
	CMP #0
	BEQ IRQSOUND2		;Not time to play next note yet, skip
	DEC SOUND_TIMER
	RTS
IRQSOUND2:
	LDX SOUND_STEP_TIMER
	CPX #0
	BEQ IRQSOUND3		;No steps to do, or at least none left to do
	DEC SOUND_STEP_TIMER
	LDA SOUND_TIMER_RESTART
	STA SOUND_TIMER		;Reset sound timer for this step
	LDA SOUND_STEP
	CMP #$80
	BCS IRQSOUND2A		;Branch if bit 7 is set (decrease frequency)
	LDA SOUND_FREQ_L	;Increase frequency of note by SOUND_STEP value
	CLC
	ADC SOUND_STEP
	STA SOUND_FREQ_L
	STA $FF0F
	LDA SOUND_FREQ_H
	ADC #0
	STA SOUND_FREQ_H
	STA $FF10
	RTS
IRQSOUND2A:
	AND #%01111111
	STA ZIRQ0			;Save amount to decrease frequency, without bit 7 set
	LDA SOUND_FREQ_L	;Decrease frequency of note by SOUND_STEP value
	SEC
	SBC ZIRQ0
	STA SOUND_FREQ_L
	STA $FF0F
	LDA SOUND_FREQ_H
	SBC #0
	STA SOUND_FREQ_H
	STA $FF10
	RTS
IRQSOUND3:				;Load next note, store information about it, and play it
	LDY #0
	LDA (SOUND_POS_L),Y	;FREQ_L
	STA $FF0F
	STA SOUND_FREQ_L
	INY
	LDA (SOUND_POS_L),Y	;FREQ_H
	STA SOUND_FREQ_H
	STA $FF10
	INY
	LDA (SOUND_POS_L),Y	;Waveform/Volume
	STA $FF11
	CMP #0
	BNE IRQSOUND4
	LDA #$FF
	STA SOUND_PLAYING	;Stop playing sound, we have reached the end of the sound data
	RTS
IRQSOUND4:
	INY
	LDA (SOUND_POS_L),Y	;Timer for how long to play this note
	TAX
	AND #%01111111		;Clear off bit 7 before saving, which indicates that we should fetch STEP data
	STA SOUND_TIMER
	STA SOUND_TIMER_RESTART
	TXA
	AND #%10000000
	BNE IRQSOUND5
	LDA #0				;No step flag. Clear current step settings
	STA SOUND_STEP
	STA SOUND_STEP_TIMER
	JMP IRQSOUND6
IRQSOUND5:				;Fetch step/fadeout info
	INY
	LDA (SOUND_POS_L),Y	;The 'step' amount to increase/decrease the sound after the sound timer expires, if SOUND_STEP_TIMER is not 0
	STA SOUND_STEP
	INY
	LDA (SOUND_POS_L),Y	;The number of times to 'step'
	STA SOUND_STEP_TIMER
	CMP #$FF
	BNE IRQSOUND6
	LDA $FF11
	STA SOUND_FADEOUT	;Flag to fade the sound out. Store the current volume in SOUND_FADEOUT
IRQSOUND6:
	INY					;Increase the pointer that we are at within the sound data
	STY ZIRQ0
	LDA SOUND_POS_L
	CLC
	ADC ZIRQ0
	STA SOUND_POS_L
	LDA SOUND_POS_H
	ADC #0
	STA SOUND_POS_H
	RTS

SOUND_FX_L:	
	!BYTE <SOUND_DATA_WALK
	!BYTE <SOUND_DATA_WALK2
	!BYTE <SOUND_DATA_MENU_BEEP
	!BYTE <SOUND_DATA_MENU_EXEC
	!BYTE <SOUND_DATA_BEEP
	!BYTE <SOUND_DATA_DOOR
	!BYTE <SOUND_DATA_CYCLE_ITEM
	!BYTE <SOUND_DATA_ERROR
	!BYTE <SOUND_DATA_ITEM_FOUND
	!BYTE <SOUND_DATA_PISTOL
	!BYTE <SOUND_DATA_PLASMA
	!BYTE <SOUND_DATA_MOVEOBJ
	!BYTE <SOUND_DATA_SHOCK
	!BYTE <SOUND_DATA_MAGNET
	!BYTE <SOUND_DATA_EMP
	!BYTE <SOUND_DATA_MEDKIT
	!BYTE <SOUND_DATA_EXPLOSION
	!BYTE <SOUND_DATA_TELEPORT
SOUND_FX_H:	
	!BYTE >SOUND_DATA_WALK
	!BYTE >SOUND_DATA_WALK2
	!BYTE >SOUND_DATA_MENU_BEEP
	!BYTE >SOUND_DATA_MENU_EXEC
	!BYTE >SOUND_DATA_BEEP
	!BYTE >SOUND_DATA_DOOR
	!BYTE >SOUND_DATA_CYCLE_ITEM
	!BYTE >SOUND_DATA_ERROR
	!BYTE >SOUND_DATA_ITEM_FOUND
	!BYTE >SOUND_DATA_PISTOL
	!BYTE >SOUND_DATA_PLASMA
	!BYTE >SOUND_DATA_MOVEOBJ
	!BYTE >SOUND_DATA_SHOCK
	!BYTE >SOUND_DATA_MAGNET
	!BYTE >SOUND_DATA_EMP
	!BYTE >SOUND_DATA_MEDKIT
	!BYTE >SOUND_DATA_EXPLOSION
	!BYTE >SOUND_DATA_TELEPORT

;SOUND DATA: FREQ_L, FREQ_H, VOL/WAVETYPE ($FF11), WAIT_TIMER, STEP, NUM_STEPS...
;
;FREQ_L gets stored in TED sound register $FF0F
;FREQ_H gets stored in TED sound register $FF10
;VOL/WAVETYPE gets stored in TED sound register $FF11. If VOL/WAVETYPE == $00, then end playback
;WAIT_TIMER is how many cycles to wait before playing next note. Bit 7 indicates the 'STEP' byte is present
;STEP repeats previous WAIT_TIMER, but increases/decreases the note by a specific number (bit 7 indicates negative).
;NUM_STEPS is how many times to STEP, repeating previous WAIT_TIMER. $ff indicates to step until volume fades out, then end playback
;
SOUND_DATA_EXPLOSION:
	!BYTE	$73,$c3,$4f,$0b
	!BYTE	$64,$c3,$4f,$80,$8e,$1f
	!BYTE	$84,$c1,$00
SOUND_DATA_MEDKIT:
	!BYTE	$58,$c2,$2f,$01
	!BYTE	$b0,$c2,$2f,$01
	!BYTE	$2c,$c3,$2f,$02
	!BYTE	$2c,$c3,$00
SOUND_DATA_EMP:
	!BYTE	$cb,$c3,$4f,$03
	!BYTE	$cd,$c3,$4f,$80,$02,$19
	!BYTE	$01,$c0,$4f,$00
	!BYTE	$03,$c0,$00
SOUND_DATA_MAGNET:
	!BYTE	$ca,$c1,$2f,$01
	!BYTE	$20,$c3,$2f,$01
	!BYTE	$c3,$c2,$2f,$01
	!BYTE	$20,$c3,$2f,$01
	!BYTE	$85,$c1,$2f,$01
	!BYTE	$20,$c3,$2f,$01
	!BYTE	$e0,$c0,$2f,$01
	!BYTE	$85,$c1,$2f,$01
	!BYTE	$f5,$c2,$2f,$01
	!BYTE	$87,$c2,$2f,$01
	!BYTE	$9c,$c2,$2f,$01
	!BYTE	$58,$c2,$2f,$00
	!BYTE	$58,$c2,$00
SOUND_DATA_MOVEOBJ:
	!BYTE	$dd,$c3,$4f,$01
	!BYTE	$ce,$c3,$4f,$00
	!BYTE	$bf,$c3,$00
SOUND_DATA_SHOCK:
	!BYTE	$ee,$c3,$4f,$01
	!BYTE	$ec,$c3,$4f,$80,$82,$0c
	!BYTE	$d2,$c3,$4f,$80,$03,$0f
	!BYTE	$02,$c0,$00
SOUND_DATA_PLASMA:
	!BYTE	$b1,$c0,$2f,$02
	!BYTE	$ca,$c1,$2f,$05
	!BYTE	$b1,$c0,$2f,$02
	!BYTE	$85,$c1,$2f,$04
	!BYTE	$85,$c1,$00
SOUND_DATA_PISTOL:
	!BYTE	$f8,$c3,$4f,$01
	!BYTE	$f5,$c3,$4d,$80,$83,$ff
SOUND_DATA_MENU_EXEC:
	!BYTE	$e5,$c2,$2f,$01
	!BYTE	$73,$c3,$2f,$02
	!BYTE	$73,$c3,$00
SOUND_DATA_MENU_BEEP:
	!BYTE	$e5,$c1,$2f,$02
	!BYTE	$73,$c2,$2f,$01
	!BYTE	$73,$c3,$00
SOUND_DATA_BEEP:
	!BYTE	$e5,$c2,$2f,$02
	!BYTE	$73,$c3,$2f,$04
	!BYTE	$73,$c3,$00
SOUND_DATA_ITEM_FOUND:
	!BYTE	$58,$c2,$2f,$02
	!BYTE	$c3,$c2,$2f,$02
	!BYTE	$e5,$c2,$2f,$02
	!BYTE	$58,$c2,$2f,$02
	!BYTE	$c3,$c2,$2f,$02
	!BYTE	$e5,$c2,$2f,$02
	!BYTE	$58,$c2,$2f,$02
	!BYTE	$c3,$c2,$2f,$02
	!BYTE	$e5,$c2,$2f,$0a
	!BYTE	$e5,$c2,$00
SOUND_DATA_CYCLE_ITEM:
	!BYTE	$e5,$c2,$26,$01
	!BYTE	$73,$c3,$26,$01
	!BYTE	$e5,$c2,$26,$01
	!BYTE	$e5,$c2,$00
SOUND_DATA_ERROR:
	!BYTE	$f4,$c3,$4f,$01
	!BYTE	$f4,$c3,$40,$03
	!BYTE	$f4,$c3,$4f,$80,$00,$ff
SOUND_DATA_DOOR:
	!BYTE	$cb,$c3,$4f,$01
	!BYTE	$d1,$c3,$4f,$01
	!BYTE	$d6,$c3,$4f,$01
	!BYTE	$dd,$c3,$4f,$80,$00,$ff
SOUND_DATA_WALK:
	!BYTE	$F0,$c2,$41,$00
	!BYTE	$20,$c0,$00
SOUND_DATA_WALK2:
	!BYTE	$D0,$c2,$41,$00
	!BYTE	$00,$c0,$00
SOUND_DATA_TELEPORT:
	!BYTE	$00,$c0,$2f,$80,$08,$06
	!BYTE	$80,$c0,$4f,$80,$88,$04
	!BYTE	$80,$c0,$2f,$80,$10,$06
	!BYTE	$00,$c1,$4f,$80,$90,$04
	!BYTE	$00,$c1,$2f,$80,$18,$06
	!BYTE	$80,$c1,$4f,$80,$98,$04
	!BYTE	$80,$c1,$2f,$80,$20,$06
	!BYTE	$00,$c2,$4f,$80,$a0,$04
	!BYTE	$00,$c2,$2f,$80,$28,$06
	!BYTE	$80,$c2,$4f,$80,$a8,$ff
	!BYTE	$00,$00,$20,$FF,$01,$80				;Add a delay with no sound to prevent repeat when winning the game
	!BYTE	$00,$00,$00
