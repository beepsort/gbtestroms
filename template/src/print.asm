INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]

	jp EntryPoint

	ds $150 - @, 0 ; Make room for the header

EntryPoint:
    ld BC, StartStr
    call SerialWriteStr
    jp Done

; Param: BC
; Overwrites: BC, HL, A
SerialWriteStr:
    ld A, [BC]
    cp A, 0
    jr z, SerialWriteStrEnd
    call SerialWriteChar
    inc BC
    jr SerialWriteStr
SerialWriteStrEnd:
    ld A, "\n"
    call SerialWriteChar
    ret

; Param: A
; Overwrites: A, HL
SerialWriteChar:
    ld HL, $FF01
    ld [HL], A
    ld HL, $FF02
    ld A, $81
    ld [HL], A
    ret

Done:
    ld BC, DoneStr
    call SerialWriteStr
DoneLoop:
	jp DoneLoop

SECTION "Strings", ROM0
StartStr:
    db "START",0
DoneStr:
    db "DONE",0
