# buildroot_portal
This repositor has setup to create bootable image for Fleet Portal


Setup requies following steps:

(1) Make a clone of buildroot repo.

      git clone <buildroot repo>


(2) Make a clone of this repo.

      git clone <buildroot_portal repo>


(3) If buildroot was already being used to create another type of image, it will be useful to run following command in buildroot folder to get a clean setup,

       make clean


(4) Inside buildroot folder run following commands,

       make BR2_EXTERNAL=../buildroot_portal raspberrypi3_defconfig

       make


