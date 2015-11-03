-e There is nothing to do here
Memetest86+ is located on the bootsector of this CD

-e Just boot from this CD and Memetest86+ will launch


http://memetest.org

Built with:
xorriso -as mkisofs -o memetest.iso -isohybrid-mbr /usr/lib/syslinux/isohdpfx.bin -b boot/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table memetest-root/

