INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]

	jp EntryPoint

	ds $150 - @, 0 ; Make room for the header

EntryPoint:
    ld A, "a"
    call SerialWrite
    jp Done

; Param: A
; Overwrites: A
SerialWrite:
    ld HL, $FF01
    ld [HL], A
    ld HL, $FF02
    ld A, $81
    ld [HL], A
    ret

Done:
	jp Done

