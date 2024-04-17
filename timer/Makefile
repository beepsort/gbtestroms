RGBASM  := rgbasm
RGBLINK := rgblink
RGBFIX  := rgbfix

PADVALUE := 0xFF
GAMEID := TMR
TITLE := TIMER
LICENSEE := HB
OLDLIC := 0x33
MBC := 0x00
SRAMSIZE := 0x00
ROMNAME := timer
ROMEXT  := gb
ROM = bin/${ROMNAME}.gb

ASFLAGS  = -p ${PADVALUE} -I include/ -Wall -Wextra
LDFLAGS  = -p ${PADVALUE}
FIXFLAGS = -p ${PADVALUE} -i "${GAMEID}" -k "${LICENSEE}" -l ${OLDLIC} -m ${MBC} -r ${SRAMSIZE} -t ${TITLE}

SRCS := src/timer.asm
OBJS := $(addprefix obj/, $(addsuffix .o, $(notdir $(basename $(SRCS)))))

default: makedir all

all: ${ROM}
.PHONY: all

clean:
	rm -rf bin obj
.PHONY: clean

makedir:
	mkdir -p obj bin
.PHONY: makedir

${ROM}: ${OBJS}
	rgblink -o ${ROM} ${OBJS}
	rgbfix ${FIXFLAGS} $@

obj/%.o: src/%.asm
	rgbasm ${ASFLAGS} -o $@ $<
