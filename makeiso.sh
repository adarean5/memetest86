#!/bin/sh

# check to see if the correct tools are installed
for X in wc genisoimage
do
	if [ "$(which $X)" = "" ]; then
		echo "makeiso.sh error: $X is not in your path." >&2
		exit 1
	elif [ ! -x $(which $X) ]; then
		echo "makeiso.sh error: $X is not executable." >&2
		exit 1
	fi 
done

#check to see if memetest.bin is present
if [ ! -w memetest.bin ]; then 
	echo "makeiso.sh error: cannot find memetest.bin, did you compile it?" >&2 
	exit 1
fi


# enlarge the size of memetest.bin
SIZE=$(wc -c memetest.bin | awk '{print $1}')
FILL=$((1474560 - $SIZE))
dd if=/dev/zero of=fill.tmp bs=$FILL count=1
cat memetest.bin fill.tmp > memetest.img
rm -f fill.tmp

echo "Generating iso image ..."

mkdir "cd"
mkdir "cd/boot"
mv memetest.img cd/boot
cd cd

# Create the cd.README
echo -e "There is nothing to do here\r\r\nMemetest86+ is located on the bootsector of this CD\r\r\n" > README.TXT
echo -e "Just boot from this CD and Memetest86+ will launch" >> README.TXT

genisoimage -A "MKISOFS 1.1.2" -p "Memetest86+ 5.01" -publisher "Samuel D. <sdemeule@memetest.org>" -b boot/memetest.img -c boot/boot.catalog -V "MT501" -o memetest.iso .
mv memetest.iso ../mt501.iso
cd ..
rm -rf cd

echo "Done! Memetest86+ 5.01 ISO is mt501.iso"
