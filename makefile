CC65 = cc65
CA65 = ca65
LD65 = ld65
DEL = rm
MKDIR = mkdir
PYTHON = python3

define cc65IncDir
-I $(1)
endef
define ca65IncDir
-I $(1) --bin-include-dir $(1)
endef
define ld65IncDir
-L $(1) --obj-path $(1)
endef

NAME = rondo
CFG = config/mmc3.cfg
OUTDIR = BUILD
TMPDIR = TMP

.PHONY: default clean

default: $(OUTDIR)/$(NAME).nes


#target: dependencies

$(OUTDIR):
	$(MKDIR) $(OUTDIR)

$(TMPDIR):
	$(MKDIR) $(TMPDIR)

$(OUTDIR)/$(NAME).nes: $(OUTDIR) $(TMPDIR)/$(NAME).o $(TMPDIR)/startup.o $(CFG)
	$(LD65) -C $(CFG) -o $(OUTDIR)/$(NAME).nes $(call ld65IncDir,$(TMPDIR)) $(call ld65IncDir,LIB) startup.o $(NAME).o nes.lib --dbgfile $(OUTDIR)/famidash.dbg
	@echo $(NAME).nes created
# rm -rf $(TMPDIR)

$(TMPDIR)/startup.o: graphics/*.chr libraries/*.s musics/*.s musics/music_bank*.dmc #levels/*.s levels/metatiles/*.s levels/metatiles/*.inc 
	$(CA65) libraries/startup.s --cpu 6502X -g $(call ca65IncDir,.) $(call ca65IncDir,musics) $(call ca65IncDir,$(TMPDIR)) -o $(TMPDIR)/startup.o

$(TMPDIR)/$(NAME).o: $(TMPDIR)/$(NAME).s
	$(CA65) --cpu 6502X $(call ca65IncDir,libraries) $(TMPDIR)/$(NAME).s -g 

#$(TMPDIR)/BUILD_FLAGS.s: BUILD_FLAGS.h defines_to_asm.py
#	$(PYTHON) defines_to_asm.py

$(TMPDIR)/$(NAME).s: $(TMPDIR) source/$(NAME).c source/*.h # levels/metatiles/metatiles.h LEVELS/*.h LIB/headers/*.h MUSIC/EXPORTS/musicDefines.h 
	$(CC65) -Osir -g --eagerly-inline-funcs source/$(NAME).c $(call cc65IncDir,libraries) $(call cc65IncDir,.) -E --add-source -o $(TMPDIR)/$(NAME).c
	$(CC65) -Osir -g --eagerly-inline-funcs source/$(NAME).c $(call cc65IncDir,libraries) $(call cc65IncDir,.) --add-source -o $(TMPDIR)/$(NAME).s

clean:
	rm -rf $(TMPDIR)