; Memory Map. Changing most of these values moves the item in memory and updates the references to them
LOAD				=$0200;-$027F	;Load routine, must be set below $8000
BACKUP_DATA			=$0280;-$077F	;Used as temporary storage when mini-map is being displayed. $0500-$057F & $0780-$07FF should be avoided, since the keyboard & I/O data goes there. Some values, like jump vectors, need to be restored when done.
BITMAP_COLOR_0		=$0800;-$0FFF	;1 of 4 bitmap color locations
COLOR_RAM			=$0800;-$0BFF	;Color RAM for text mode.
SCREEN_RAM			=$0C00;-$0FFF	;Screen RAM for text mode. SCREEN_RAM must be $0400 above COLOR_RAM
GAMECODE			=$1000;-$5BFF	;Main game code. Must be set below $8000
TILESET_RAM			=$5C00;-$6FFF	;Location of the map tileset
CHAR_RAM			=$7000;-$77FF	;Location of the character set
TITLE_COLOR_RAM		=$7800;-$7FFF	;Location of the title screen bitmap color data.
BITMAP_COLOR_1		=$7800;-$7FFF	;2 of 4 bitmap color locations. Need to back up part of the title screen color data before using.
TITLE_RAM			=$8000;-$9FFF	;Location of the title screen bitmap
BITMAP_RAM			=$A000;-$BFFF	;Location of bitmap. Used to display the map.
BITMAP_COLOR_2		=$B800;-$BFFF	;3 of 4 bitmap color locations. It overlaps the bottom of BITMAP_RAM, but the map shouldn't be visable in this area.
MUSIC				=$C000;-$D1CF	;Location TED music should load into
BITMAP_COLOR_3		=$D000;-$D7FF	;4 of 4 bitmap color locations. Since MUSIC collides a bit with this, we must back that up before using, and then restore when done.
MAP_DATA			=$D800;-$FAFF	;Location of level map
VARIABLES			=$FB00;-$FBFF	;Location for storage of variables, like unit timers, etc
UNUSABLE			=$FC00;-$FFFF	;Most of this area is unusable as RAM

DESTRUCT_PATH	=TILESET_RAM		;Destruct path array (256 bytes)
TILE_ATTRIB		=TILESET_RAM+$0100	;Tile attrib array (256 bytes)
TILE_DATA_TL	=TILESET_RAM+$0200	;Tile character top-left (256 bytes)
TILE_DATA_TM	=TILESET_RAM+$0300	;Tile character top-middle (256 bytes)
TILE_DATA_TR	=TILESET_RAM+$0400	;Tile character top-right (256 bytes)
TILE_DATA_ML	=TILESET_RAM+$0500	;Tile character middle-left (256 bytes)
TILE_DATA_MM	=TILESET_RAM+$0600	;Tile character middle-middle (256 bytes)
TILE_DATA_MR	=TILESET_RAM+$0700	;Tile character middle-right (256 bytes)
TILE_DATA_BL	=TILESET_RAM+$0800	;Tile character bottom-left (256 bytes)
TILE_DATA_BM	=TILESET_RAM+$0900	;Tile character bottom-middle (256 bytes)
TILE_DATA_BR	=TILESET_RAM+$0A00	;Tile character bottom-right (256 bytes)
TILE_COLOR_TL	=TILESET_RAM+$0B00	;Tile character top-left (256 bytes) (C64/VIC/TED VERSION ONLY)
TILE_COLOR_TM	=TILESET_RAM+$0C00	;Tile character top-middle (256 bytes) (C64/VIC/TED VERSION ONLY)
TILE_COLOR_TR	=TILESET_RAM+$0D00	;Tile character top-right (256 bytes) (C64/VIC/TED VERSION ONLY)
TILE_COLOR_ML	=TILESET_RAM+$0E00	;Tile character middle-left (256 bytes) (C64/VIC/TED VERSION ONLY)
TILE_COLOR_MM	=TILESET_RAM+$0F00	;Tile character middle-middle (256 bytes) (C64/VIC/TED VERSION ONLY)
TILE_COLOR_MR	=TILESET_RAM+$1000	;Tile character middle-right (256 bytes) (C64/VIC/TED VERSION ONLY)
TILE_COLOR_BL	=TILESET_RAM+$1100	;Tile character bottom-left (256 bytes) (C64/VIC/TED VERSION ONLY)
TILE_COLOR_BM	=TILESET_RAM+$1200	;Tile character bottom-middle (256 bytes) (C64/VIC/TED VERSION ONLY)
TILE_COLOR_BR	=TILESET_RAM+$1300	;Tile character bottom-right (256 bytes) (C64/VIC/TED VERSION ONLY)

SCANKEY					=$DB11	;Kernal routine for scanning the keyboard and queueing the result
USER_PORT				=$FD10
BACKGROUND_COLOR		=$FF15
BACKGROUND_COLOR_2		=$FF16
BORDER_COLOR			=$FF19
KEYBOARD_QUEUE_LENGTH	=$053F	;0 disables keyboard input
KEYBOARD_KEY_PRESSED	=$07F6	;Keyboard matrix value of last key pressed, 64 = No key pressed
KEYBOARD_REPEAT_TIMER	=$0541
KEYBOARD_CHARS_IN_QUEUE	=$EF	;Number of characters currently held in the keyboard queue
UPDATE_FREQ				=60		;60 for ntsc or 50 for pal

;***These arrays can go anywhere in RAM***
UNIT_TIMER_A	=VARIABLES			;Primary timer for units (64 bytes)
UNIT_TIMER_B	=VARIABLES+$0040	;Secondary timer for units (64 bytes)
UNIT_TILE		=VARIABLES+$0080	;Current tile assigned to unit (32 bytes)
EXP_BUFFER		=VARIABLES+$00A0	;Explosion Buffer (16 bytes)
MAP_PRECALC		=VARIABLES+$00B0	;Stores pre-calculated objects for map window (77 bytes)
MUSIC_STATE		=VARIABLES+$00FD	;0 = MUSIC OFF

;***MAP FILES CONSIST OF EVERYTHING FROM THIS POINT ON***
UNIT_TYPE	=MAP_DATA		;Unit type 0=none (64 bytes)	
UNIT_LOC_X	=MAP_DATA+$0040	;Unit X location (64 bytes)
UNIT_LOC_Y	=MAP_DATA+$0080	;Unit Y location (64 bytes)
UNIT_A		=MAP_DATA+$00C0	
UNIT_B		=MAP_DATA+$0100
UNIT_C		=MAP_DATA+$0140
UNIT_D		=MAP_DATA+$0180
UNIT_HEALTH	=MAP_DATA+$01C0	;Unit health (0 to 11) (64 bytes)
;MAP_ROW_BG	=MAP_DATA+$0200	;Color of background #2 on the mini-map for each row of the map (64 bytes). Unpacked version gets saved here, since this appears to be an unused area of the map data.
UNIT_MAP_A	=MAP_DATA+$0200 ;Flag if the unit is drawn on the map. 0=no, 1=yes
UNIT_MAP_BG	=MAP_DATA+$0240	;Color underneath the unit
UNIT_MAP_L	=MAP_DATA+$0280	;Last position we plotted the unit on the map
UNIT_MAP_H	=MAP_DATA+$02C0	;Last position we plotted the unit on the map
MAP			=MAP_DATA+$0300	;Location of MAP (8K)
;***END OF MAP FILE***

;*** Zero Page locations used ***
;The following addresses are used to store the current 
;state of the SNES buttons.
SNES_B				=$02
SNES_Y				=$03
SNES_SELECT			=$04
SNES_START			=$05
SNES_UP				=$06
SNES_DOWN			=$07
SNES_LEFT			=$08
SNES_RIGHT			=$09
SNES_A				=$0A
SNES_X				=$0B
SNES_BACK_L			=$0C
SNES_BACK_R			=$0D
;The following addresses are used to store the last
;state of the SNES buttons so that we can determine
;if a button was released.
LAST_B				=$0E
LAST_Y				=$0F
LAST_SELECT			=$10
LAST_START			=$11
LAST_UP				=$12
LAST_DOWN			=$13
LAST_LEFT			=$14
LAST_RIGHT			=$15
LAST_A				=$16
LAST_X				=$17
LAST_BACK_L			=$18
LAST_BACK_R			=$19

;The following addresses are used to store new
;presses of the SNES buttons.  Once they are set
;as a 1, it requires the game to reset them to
;0 when it is ready to be read again.
NEW_B				=$1A
NEW_Y				=$1B
NEW_SELECT			=$1C
NEW_START			=$1D
NEW_UP				=$1E
NEW_DOWN			=$1F
NEW_LEFT			=$20
NEW_RIGHT			=$21
NEW_A				=$22
NEW_X				=$23
NEW_BACK_L			=$24
NEW_BACK_R			=$25

;The following are the locations where the current
;key controls are stored.  These must be set before
;the game can start.
KEY_MOVE_UP			=$26
KEY_MOVE_DOWN		=$27
KEY_MOVE_LEFT		=$28
KEY_MOVE_RIGHT		=$29
KEY_FIRE_UP			=$2A
KEY_FIRE_DOWN		=$2B
KEY_FIRE_LEFT		=$2C
KEY_FIRE_RIGHT		=$2D
KEY_CYCLE_WEAPONS	=$2E
KEY_CYCLE_ITEMS		=$2F
KEY_USE				=$30
KEY_SEARCH			=$31
KEY_MOVE			=$32

TILE				=$33	;The tile number to be plotted
TEMP_X				=$34	;Temporarily used for loops
TEMP_Y				=$35	;Temporarily used for loops
MAP_X				=$36	;Current X location on map
MAP_Y				=$37	;Current Y location on map
MAP_WINDOW_X		=$38	;Top left location of what is displayed in map window
MAP_WINDOW_Y		=$39	;Top left location of what is displayed in map window
DECNUM				=$3A	;a decimal number to be displayed onscreen as 3 digits.
ATTRIB				=$3B	;Tile attribute value
UNIT				=$3C	;Current unit being processed
ANIM_COLOR			=$3D	;Current cursor color
;GOAT_ZERO1			=$3E	;used by goat-tracker
;GOAT_ZERO2			=$3F	;used by goat-tracker
TEMP_A				=$40	;used within some routines
TEMP_B				=$41	;used within some routines
TEMP_C				=$42	;used within some routines
TEMP_D				=$43	;used within some routines
CURSOR_X			=$44	;For on-screen cursor
CURSOR_Y			=$45	;For on-screen cursor
CURSOR_ON			=$46	;Is cursor active or not? 1=yes 0=no
REDRAW_WINDOW		=$47	;1=yes 0=no
MOVE_RESULT			=$48	;1=Move request success, 0=fail.
UNIT_FIND			=$49	;255=no unit present.
MOVE_TYPE			=$4A	;%00000001=WALK %00000010=HOVER
SCREEN_SHAKE 		=$4B	;0=NO 1=YES
PRECALC_COUNT		=$4C	;part of screen draw routine
ZP0					=$4D	;Zero Page temporary variables for looping and such
ZP1					=$4E
ZP2					=$4F
ZP3					=$50
ZP4					=$51
ZP5					=$52
ZP6					=$53
ZP7					=$54
ZP8					=$55
ZP9					=$56
ZPA					=$57
ZPB					=$58
ZIRQ0				=$59	;Zero Page temporary variables used during IRQs
ZIRQ1				=$5A
ZIRQ2				=$5B
SOUND_POS_L			=$5C	;Position within the data that a played sound currently is at. Used during IRQs
SOUND_POS_H			=$5D
TILECOLOR0			=$5E	;Temporary data for creating the mini-map
TILECOLOR1			=$5F
TILECOLOR2			=$60
TILECOLOR3			=$61
PRIORITY0			=$62
PRIORITY1			=$63
PRIORITY2			=$64
PRIORITY3			=$65
GREENFOUND			=$66
REDFOUND			=$67
ORANGEFOUND			=$68
COLOR0				=$69
COLOR1				=$6A
COLOR2				=$6B
COLOR3				=$6C
MAP_TIMER			=$6D
MAP_TIMER_PLAYER	=$6E
MAP_SHOW_ROBOTS		=$6F
MAP_CHECK_KEY		=$70
;ZEDTRACKER			=$A9
;ZEDTRACKER			=$E5
;ZEDTRACKER			=$E6
;ZEDTRACKER			=$E7

;Zero Page to avoid:
;$83
;$90-$9A
;$A3-$A6
;$BA
;$C6
;$EF
;$F0
;$F9
;$FB