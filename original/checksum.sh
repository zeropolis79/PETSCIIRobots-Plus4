#!/bin/sh
#
#
#
#
LIST="gfxfont.prg level-a level-b level-c level-d level-e level-f level-g level-h level-i level-j level-k level-l loader.prg music.ted plus4gfx.prg tileset.gfx titlegfx.prg"

#LIST=$(ls *-64x)

status=0

for f in $LIST
do
    NEWSUM=$(md5sum $f)
    OLDSUM=$(grep " ${f}\$" original/checksums.txt)
    if [ "$NEWSUM" != "$OLDSUM" ]; then
        echo ERROR: $f MISMATCH:
        echo NEWSUM=$NEWSUM
        echo OLDSUM=$OLDSUM
        status=1
    else
        echo $f ok...
    fi
done
exit $status
