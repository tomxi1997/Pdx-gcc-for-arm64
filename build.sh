 #!/usr/bin/env bash
rm -rf ../pdx-gcc-*
./build-gcc-64.sh -a arm64
./build-gcc-32.sh -a arm
cd ..
#tar -I pixz -cf pdx-gcc-`date +'%Y%m%d'`.tar.xz pdx-gcc-`date +'%Y%m%d'`
XZ_OPT="-9" tar --warning=no-file-changed -cJf pdx-gcc-`date +'%Y%m%d'`.tar.xz pdx-gcc-`date +'%Y%m%d'`
echo "Compression packaging GCC!"

