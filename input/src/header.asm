
INCLUDE "hardware.inc/hardware.inc"
	rev_Check_hardware_inc 4.0

SECTION "VBlank", ROM0[$40]
    jp VBlankHandler

SECTION "Header", ROM0[$100]

	; This is your ROM's entry point
	; You have 4 bytes of code to do... something
	di
	jp EntryPoint

	; Make sure to allocate some space for the header, so no important
	; code gets put there and later overwritten by RGBFIX.
	; RGBFIX is designed to operate over a zero-filled header, so make
	; sure to put zeros regardless of the padding value. (This feature
	; was introduced in RGBDS 0.4.0, but the -MG etc flags were also
	; introduced in that version.)
	ds $150 - @, 0

SECTION "Entry point", ROM0

EntryPoint:
    ; disable interrupts via flags
    ld A, $00
    ld [rIF], A
    ; disable PPU
    ld A, $00
    ld [rLCDC], A
    ; set bg palette
    ld A, $E4
    ld [rBGP], A
    ; set BG scroll
    ld A, $00
    ld [rSCY], A
    ld [rSCX], A
    ; make tiles
    ; 0: all white
Tile0:
    ld HL, _VRAM
    ld A, $00
    ld B, 16
Tile0Loop:
    ld [HL+], A
    dec B
    jr NZ, Tile0Loop
    ; 1: all black
Tile1:
    ld A, $FF
    ld B, 16
Tile1Loop:
    ld [HL+], A
    dec B
    jr NZ, Tile1Loop
Tile2:
    ld A, $00
    ld C, $FF
    ld B, 8
Tile2Loop:
    ld [HL+], A
    ld [HL], C
    inc HL
    dec B
    jr NZ, Tile2Loop
Tile3:
    ld A, $FF
    ld C, $00
    ld B, 8
Tile3Loop:
    ld [HL+], A
    ld [HL], C
    inc HL
    dec B
    jr NZ, Tile3Loop
    ; make screen all white
MapInit:
    ld HL, _SCRN0
    ld A, $00
    ld D, 32
MapInitLoop:
    ld E, 32
MapInitLoopInner:
    ld [HL+], A
    dec E
    jr NZ, MapInitLoopInner
    dec D
    jr NZ, MapInitLoop
    ; enable vblank interrupt
    inc A ; A = 1
    ld [rIE], A
    ei
    ; enable PPU
    ld A, $91
    ld [rLCDC], A
	jr @


VBlankHandler:
    push AF
    push BC
    push DE
    push HL
    ld HL, rP1 ; JOYP addr
    ld C, $00 ; result
    ; dpad
    ld C, $20
    ld [HL], C
    ld A, [HL]
    ld A, [HL]
    ; right
    ld A, [HL]
    ld B, $01
    and B
    ld DE, $9907
    call ButtonDisplay
    ; left
    ld A, [HL]
    ld B, $02
    and B
    ld DE, $9905
    call ButtonDisplay
    ; up
    ld A, [HL]
    ld B, $04
    and B
    ld DE, $9901
    call ButtonDisplay
    ; down
    ld A, [HL]
    ld B, $08
    and B
    ld DE, $9903
    call ButtonDisplay
    ; buttons
    ld C, $10
    ld [HL], C
    ld A, [HL]
    ld A, [HL]
    ; button A
    ld A, [HL]
    ld B, $01
    and B
    ld DE, $990C
    call ButtonDisplay
    ; button B
    ld A, [HL]
    ld B, $02
    and B
    ld DE, $990E
    call ButtonDisplay
    ; select
    ld A, [HL]
    ld B, $04
    and B
    ld DE, $9912
    call ButtonDisplay
    ; start
    ld A, [HL]
    ld B, $08
    and B
    ld DE, $9910
    call ButtonDisplay
    ; clear JOYP
    ld E, $30
    ld [HL], E
    pop HL
    pop DE
    pop BC
    pop AF
    reti

; params: Z flag
; - DE (Tile map start)
ButtonDisplay:
    push AF
    jr Z, ButtonPressed
    ld A, $03
    jr ButtonDisplayStore
ButtonPressed:
    ld A, $02
ButtonDisplayStore:
    ld [DE], A
    pop AF
    ret
    
