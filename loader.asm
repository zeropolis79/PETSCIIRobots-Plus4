;PETSCII ROBOTS (Plus4 GFX version)
;by David Murray 2020
;dfwgreencars@gmail.com

!to "loader.prg",cbm

*=$1001				;START ADDRESS IS $1001

!SOURCE "DEFINITIONS.ASM"

BASIC:	!BYTE $0B,$08,$01,$00,$9E,$34,$31,$30,$39,$00,$00,$00	;Adds BASIC line:  1 SYS 4109

	LDA	#$80
	STA	$0547	;Disable character set switching
	LDA	#$40
	STA	$0540	;set all keys to NON-repeat mode ($40 NO REPEAT, $80 REPEAT)

	; Modify/Disable function keys to act more like a C64
	LDA #0
	STA $76		;$76 contains which function key is being modified (0-7)
	STA $23
	LDA #ZP0
	STA $22		;$22-$23 contains the address (ZP0) to fetch what string is printed when you press a function key
MODIFY_FUNCTION_KEYS:
	LDX $76
	LDA FUNCTION_KEYS,X
	CMP #0
	BEQ MFK1	;Function key string has a length of 0 characters
	STA ZP0
	LDA #1		;Function key string has a length of 1 character
MFK1:	
	JSR $FF49	;Modify function key. A register contains the length of the string
	INC $76
	LDA $76
	CMP #8
	BNE MODIFY_FUNCTION_KEYS
	
	;Set background/border color
	LDA	#$00	;black
	STA	BACKGROUND_COLOR
	LDA	#$06	;blue
	STA	BORDER_COLOR

	;Clear screen
	LDX #0
	LDA #32
CS1:
	STA SCREEN_RAM,X
	STA SCREEN_RAM+$0100,X
	STA SCREEN_RAM+$0200,X
	STA SCREEN_RAM+$0300,X
	INX
	BNE CS1

	;Display loading message
	LDX #0
DLM1:
	LDA LOADMSG,X
	STA SCREEN_RAM+12*40+8,X
	LDA #$71
	STA COLOR_RAM+12*40+8,X
	INX
	CPX #24
	BNE DLM1
	
	;Move the loader to LOAD address.
	LDX #0
LM1:
	LDA LOADER,X
	STA LOAD,X
	INX
	CPX #LOADER_END-LOADER
	BNE LM1

	;Load bitmap title screen
	LDA #<TITLE_COLOR_RAM
	STA ZP0
	LDA #>TITLE_COLOR_RAM
	STA ZP1
	LDA	#FILENAME_TITLE_END-FILENAME_TITLE
	LDX	#<FILENAME_TITLE
	LDY	#>FILENAME_TITLE
	JSR LOAD

	;Switch into bitmap mode to display title screen
	LDA #$3B
	STA $FF06
	LDA #>TITLE_COLOR_RAM
	STA $FF14
	LDA #$20
	STA $FF12
	
	;Change periods in 'map' text area to be the color black until we load more data
	LDX #8
TMP1:
	LDA #$00
	STA $7D19,x
	INX
	CPX #16
	BNE TMP1
	
	;Set the text in the upper boxes on the bitmap title screen to be black on black
	LDX #0
SETBLACK:
	LDA #$10
	STA TITLE_COLOR_RAM+$042c,x
	STA TITLE_COLOR_RAM+$0454,x
	STA TITLE_COLOR_RAM+$047c,x
	STA TITLE_COLOR_RAM+$04a4,x
	INX
	CPX #10
	BNE SETBLACK
	
	;Load the tileset
	LDA #<TILESET_RAM
	STA ZP0
	LDA #>TILESET_RAM
	STA ZP1
	LDA	#FILENAME_TILESET_END-FILENAME_TILESET
	LDX	#<FILENAME_TILESET
	LDY	#>FILENAME_TILESET
	JSR	LOAD
	
	;Add a dot after Loading...
	LDA #$10
	STA $7D21
	STA $7D22

	;Load the character set
	LDA #<CHAR_RAM
	STA ZP0
	LDA #>CHAR_RAM
	STA ZP1
	LDA	#FILENAME_CHARSET_END-FILENAME_CHARSET
	LDX	#<FILENAME_CHARSET
	LDY	#>FILENAME_CHARSET
	JSR	LOAD

	;Add a dot after Loading...
	LDA #$10
	STA $7D23
	STA $7D24

	;Load the TED music
	LDA #<MUSIC
	STA ZP0
	LDA #>MUSIC
	STA ZP1
	LDA	#FILENAME_TEDMUSIC_END-FILENAME_TEDMUSIC
	LDX	#<FILENAME_TEDMUSIC
	LDY	#>FILENAME_TEDMUSIC
	JSR	LOAD
	
	;Add a dot after Loading...
	LDA #$10
	STA $7D25
	STA $7D26

	LDA $FF12
	AND #$FB
	STA $FF12			;Enable TED reading underlying character RAM
	LDA $FF07
	ORA #%10000000
	STA $FF07			;Disable reverse character set, so we have all 256 characters
	LDA #>CHAR_RAM
	STA $FF13			;Move Character Set pointer to CHAR_RAM
	LDA	#1
	STA	KEYBOARD_QUEUE_LENGTH
	
	LDA	#0
	STA	SCREEN_SHAKE
	STA	MUSIC_STATE

	;Jump to routine to load the game code (which overwrites this program) and then calls to execute the game
	LDA #<GAMECODE
	STA ZP0
	LDA #>GAMECODE
	STA ZP1
	LDA	#FILENAME_GAME_END-FILENAME_GAME
	LDX	#<FILENAME_GAME
	LDY	#>FILENAME_GAME
	
	JMP LOAD+GAMELOAD-LOADER
	
LOADER:
	;Call routine with filename info already within A,X,Y registers
	;Store address to load the file into within ZP0/ZP1
	JSR	$FFBD	;SETNAM A=FILE NAME LENGTH X/Y=POINTER TO FILENAME
	LDA	#$02
	LDX	#$08
	LDY	#$00
	JSR	$FFBA	;SETFLS A=LOGICAL NUMBER X=DEVICE NUMBER Y=SECONDARY
	LDX	ZP0
	LDY	ZP1		;load into address
	LDA	#$00
	JSR	$FFD5	;LOAD FILE A=0 FOR LOAD X/Y=LOAD ADDRESS
	LDA	#$02
	JSR	$FFC3	;CLOSE FILE
	RTS
GAMELOAD:
	JSR LOAD
	;Set the text in the upper boxes on the bitmap title screen to be green on black
	LDX #0
GL2:
	LDA #$50
	STA TITLE_COLOR_RAM+$0454,x
	STA TITLE_COLOR_RAM+$047c,x
	STA TITLE_COLOR_RAM+$04a4,x
	INX
	CPX #10
	BNE GL2
	;Change the text in the map area to be green on black
	LDX #0
GL3:
	LDA #$06
	STA $7919,x
	LDA #$50
	STA $7D19,x
	INX
	CPX #16
	BNE GL3
	;Execute Main Game Code
	JMP GAMECODE

LOADER_END:

FILENAME_TILESET:	!PET"tileset.gfx"
FILENAME_TILESET_END:

FILENAME_CHARSET:	!PET"gfxfont.prg"
FILENAME_CHARSET_END:

FILENAME_TEDMUSIC:	!PET"music.ted"
FILENAME_TEDMUSIC_END:

FILENAME_TITLE:		!PET"titlegfx"
FILENAME_TITLE_END:

FILENAME_GAME:		!PET"plus4gfx"
FILENAME_GAME_END:

LOADMSG:			!SCR "waking up the robots ..."

FUNCTION_KEYS: 		!BYTE	133, 134, 0, 0, 0, 0, 0, 224

