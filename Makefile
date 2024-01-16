all:
	acme loader.asm
	acme PLUS4GFX.ASM

plus4gfx.d64:
	c1541 -format "petscii robots,p4" d64 $@ \
	-write loader.prg loader \
	-write plus4gfx.prg plus4gfx \
	-write gfxfont.prg \
	-write titlegfx.prg titlegfx \
	-write tileset.gfx \
	-write music.ted \
	-write level-a \
	-write level-b \
	-write level-c \
	-write level-d \
	-write level-e \
	-write level-f \
	-write level-g \
	-write level-h \
	-write level-i \
	-write level-j \
	-write level-k \
	-write level-l
