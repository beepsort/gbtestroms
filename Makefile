RGBASM  := rgbasm
RGBLINK := rgblink
RGBFIX  := rgbfix

PADVALUE := 0xFF
GAMEID := PRNT
TITLE := PRINT
LICENSEE := HB
OLDLIC := 0x33
MBC := 0x00
SRAMSIZE := 0x00
ROMNAME := print
ROMEXT  := gb
ROM = bin/${ROMNAME}.gb

ASFLAGS  = -p ${PADVALUE} -I include/ -Wall -Wextra
LDFLAGS  = -p ${PADVALUE}
FIXFLAGS = -p ${PADVALUE} -i "${GAMEID}" -k "${LICENSEE}" -l ${OLDLIC} -m ${MBC} -r ${SRAMSIZE} -t ${TITLE}

SRCS := src/print.asm
OBJS := $(addprefix obj/, $(addsuffix .o, $(notdir $(basename $(SRCS)))))

all: ${ROM}
.PHONY: all

clean:
	rm -rf bin obj
.PHONY: clean

${ROM}: ${OBJS}
	rgblink -o ${ROM} ${OBJS}
	rgbfix ${FIXFLAGS} $@

obj/%.o: src/%.asm
	rgbasm ${ASFLAGS} -o $@ $<
