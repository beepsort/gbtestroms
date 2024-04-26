
INCLUDE "hardware.inc/hardware.inc"
	rev_Check_hardware_inc 4.0

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
MapInit:
    ld HL, _SCRN0
    ld A, $00
    ld B, $01
    ld C, $02
    ld D, 32
MapInitLoop:
    ld E, 8
MapInitLoopInner:
    ld A, $00
    ld [HL+], A
    ld [HL], B
    inc HL
    ld [HL], C
    inc HL
    ld A, $03
    ld [HL+], A
    dec E
    jr NZ, MapInitLoopInner
    dec D
    jr NZ, MapInitLoop
    ; enable PPU
    ld A, $91
    ld [rLCDC], A
	jr @
