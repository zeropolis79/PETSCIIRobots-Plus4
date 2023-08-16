ACME=acme

PROGS	= loader plus4gfx

all: $(PROGS) cksum

loader: loader.asm
	$(ACME) $<

plus4gfx: PLUS4GFX.ASM
	$(ACME) -DRELEASED=1 $<

clean:
	rm -f loader.prg plus4gfx.prg

cksum:
	@echo ""
	@echo "Verifying checksums....(you should look for errors below)"
	@./original/checksum.sh

