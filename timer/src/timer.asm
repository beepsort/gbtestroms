INCLUDE "hardware.inc"

SECTION "TimerHandler", ROM0[$50]
    jp TimerHandler

SECTION "Header", ROM0[$100]

	jp EntryPoint

	ds $150 - @, 0 ; Make room for the header

EntryPoint:
    ld BC, StartStr
    call SerialWriteStr
    xor A, A
    ld [$C000], A ;; write 0 to C000 in prep
    ld A, $04
    ld [$FFFF], A  ;; enable timer interrupts
    ei
    ld A, $00
    ld [$FF06], A ;; Set TMA
    ld [$FF05], A ;; Write to TIMA to reset to TMA
    ld A, $05 ;; TAC enable & 4M clock select
    ld [$FF07], A ;; write to TAC
    ld E, $FF
TimerLoop:
    ld A, [$C000] ;4
    call SerialWriteNum ; 6
    dec E
    jp NZ,TimerLoop
    ld A, [$C000] ;; load count of timer interrupts
    call SerialWriteNum
    jp Done

TimerHandler:
    push AF
    ld A, [$C000]
    inc A
    ld [$C000], A
    pop AF
    reti

; Param: A
; Return: A: tens and ones digits, B: hundreds digit
bcd8bit:
    swap A ; 2
    ld B, A ; 3
    and $0F ; 5
    or A ; reset half carry ; 6
    daa ; A=0-21 ; 7
    sla B ; 9
    adc A
    daa
    sla B
    adc A
    daa ; A=0-99
    rl B
    adc A
    daa
    rl B
    adc A
    daa
    rl B
    ret

; Param A
; Overwrites: A, B, C, HL
SerialWriteNum:
    call bcd8bit ; 6
    ld C,A ; store ones and tens in C for later
    ld A,B
    and $03 ; only display bits 1 & 0
    add A,"0" ; convert to ascii
    call SerialWriteChar
    ld A,C ; load ones and tens
    and $F0 ; filter out tens
    swap A ; move digit to lsb
    add A,"0" ; convert to ascii
    call SerialWriteChar
    ld A,C ; load ones and tens
    and $0F ; filter out ones
    add A,"0" ; convert to ascii
    call SerialWriteChar
    ld A,"\n"
    call SerialWriteChar
    ret


; Param: BC
; Overwrites: BC, HL, A
SerialWriteStr:
    ld A, [BC]
    cp A, 0
    jr Z, SerialWriteStrEnd
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
