#!/bin/bash --debugger
set -e

# -i update the file
# substitute string1 for string2 globally
sudo sed -i 's/CONF_SWAPSIZE=100/CONF_SWAPSIZE=2048/g' /etc/dphys-swapfile

sudo /etc/init.d/dphys-swapfile stop
sudo /etc/init.d/dphys-swapfile start

# -i update the file
# $ regex for end of the file
# a append
# then the text to append.
# sudo sed -i '$a gpu_mem=128' /boot/config.txt

BRANCH="1.16"
RPI="1"
echo "RPI BUILD!"

BUILD_PYTHON_BINDINGS="0"

# Create a log file of the build as well as displaying the build on the tty as it runs
exec > >(tee build_gstreamer.log)
exec 2>&1

# Update and Upgrade the Pi, otherwise the build may fail due to inconsistencies
sudo apt-get update && sudo apt-get upgrade -y 

# Get the required libraries
sudo apt-get install -y git screen build-essential autotools-dev automake autoconf \
                                    libtool autopoint libxml2-dev zlib1g-dev libglib2.0-dev \
                                    pkg-config bison flex python3 git gtk-doc-tools libasound2-dev \
                                    libgudev-1.0-dev libxt-dev libvorbis-dev libcdparanoia-dev \
                                    libpango1.0-dev libtheora-dev libvisual-0.4-dev iso-codes \
                                    libgtk-3-dev libraw1394-dev libiec61883-dev libavc1394-dev \
                                    libv4l-dev libcairo2-dev libcaca-dev libspeex-dev libpng-dev \
                                    libshout3-dev libjpeg-dev libaa1-dev libflac-dev libdv4-dev \
                                    libtag1-dev libwavpack-dev libpulse-dev libsoup2.4-dev libbz2-dev \
                                    libcdaudio-dev libdc1394-22-dev ladspa-sdk libass-dev \
                                    libcurl4-gnutls-dev libdca-dev libdvdnav-dev \
                                    libexempi-dev libexif-dev libfaad-dev libgme-dev libgsm1-dev \
                                    libiptcdata0-dev libkate-dev libmimic-dev libmms-dev \
                                    libmodplug-dev libmpcdec-dev libofa0-dev libopus-dev \
                                    librsvg2-dev librtmp-dev libschroedinger-dev libslv2-dev \
                                    libsndfile1-dev libsoundtouch-dev libspandsp-dev libx11-dev \
                                    libxvidcore-dev libzbar-dev libzvbi-dev liba52-0.7.4-dev \
                                    libcdio-dev libdvdread-dev libmad0-dev libmp3lame-dev \
                                    libmpeg2-4-dev libopencore-amrnb-dev libopencore-amrwb-dev \
                                    libsidplay1-dev libtwolame-dev libx264-dev libusb-1.0 \
                                    python-gi-dev yasm python3-dev python-dev libgirepository1.0-dev gettext \
				    tclsh cmake libssl-dev build-essential


				    

# get the repos if they're not already there
cd $HOME
[ ! -d gstreamer-src ] && mkdir gstreamer-src
cd gstreamer-src
[ ! -d gstreamer ] && mkdir gstreamer
cd gstreamer

# get repos if they are not there yet
[ ! -d srt ] && git clone https://github.com/Haivision/srt
[ ! -d gstreamer ] && git clone git://anongit.freedesktop.org/git/gstreamer/gstreamer
[ ! -d gst-plugins-base ] && git clone git://anongit.freedesktop.org/git/gstreamer/gst-plugins-base
[ ! -d gst-plugins-good ] && git clone git://anongit.freedesktop.org/git/gstreamer/gst-plugins-good
[ ! -d gst-plugins-bad ] && git clone git://anongit.freedesktop.org/git/gstreamer/gst-plugins-bad
[ ! -d gst-plugins-ugly ] && git clone git://anongit.freedesktop.org/git/gstreamer/gst-plugins-ugly
[ ! -d gst-libav ] && git clone git://anongit.freedesktop.org/git/gstreamer/gst-libav
[ ! -d gst-python ] && git clone git://anongit.freedesktop.org/git/gstreamer/gst-python
[ ! -d gst-rtsp-server] && git clone git://anongit.freedesktop.org/gstreamer/gst-rtsp-server


export LD_LIBRARY_PATH=/usr/local/lib/
# Get SRT Source and Compile
cd srt
sudo make uninstall || true
make clean
./configure
make
sudo make install
cd ..

# Get gst-rtsp-server Source and Compile
#cd gst-rtsp-server
#sudo make uninstall || true
#make clean
#./configure
#make
#sudo make install
#cd ..


# checkout branch (default=master) and build & install
cd gstreamer
git checkout -t origin/$BRANCH || true
make clean
sudo make uninstall || true
git pull
./autogen.sh --disable-gtk-doc
make CFLAGS="-Wno-error" -j4
sudo make install
cd ..

cd gst-plugins-base
git checkout -t origin/$BRANCH || true
make clean
sudo make uninstall || true
git pull
./autogen.sh --disable-gtk-doc
make CFLAGS+="-Wno-error" -j4
sudo make install
cd ..

cd gst-plugins-good
git checkout -t origin/$BRANCH || true
make clean
sudo make uninstall || true
git pull
./autogen.sh --disable-gtk-doc
make CFLAGS+="-Wno-error" -j4
sudo make install
cd ..

cd gst-plugins-ugly
git checkout -t origin/$BRANCH || true
sudo make uninstall || true
make clean
git pull
./autogen.sh --disable-gtk-doc
make CFLAGS+="-Wno-error" -j4
sudo make install
cd ..

#cd gst-libav
#git checkout -t origin/$BRANCH || true
#sudo make uninstall || true
#git pull
#./autogen.sh --disable-gtk-doc
#make CFLAGS+="-Wno-error" -j4
#sudo make install
#cd ..

cd gst-plugins-bad
git checkout -t origin/$BRANCH || true
sudo make uninstall || true
make clean
git pull
# some extra flags on rpi

    export LDFLAGS='-L/opt/vc/lib' \
    CFLAGS='-I/opt/vc/include -I/opt/vc/include/interface/vcos/pthreads -I/opt/vc/include/interface/vmcs_host/linux' \
    CPPFLAGS='-I/opt/vc/include -I/opt/vc/include/interface/vcos/pthreads -I/opt/vc/include/interface/vmcs_host/linux'
    ./autogen.sh --disable-gtk-doc --disable-examples --disable-x11 --disable-glx --disable-glx --disable-opengl 
    make -j4 CFLAGS+="-Wno-error -Wno-redundant-decls -I/opt/vc/include -I/opt/vc/include/interface/vcos/pthreads -I/opt/vc/include/interface/vmcs_host/linux" \
      CPPFLAGS+="-Wno-error -Wno-redundant-decls -I/opt/vc/include -I/opt/vc/include/interface/vcos/pthreads -I/opt/vc/include/interface/vmcs_host/linux" \
      CXXFLAGS+="-Wno-redundant-decls" LDFLAGS+="-L/opt/vc/lib"

sudo make install
cd ..

if [[ $BUILD_PYTHON_BINDINGS -eq 1 ]]; then
	#python bindings
	#python bindings
	cd gst-python
	git checkout -t origin/$BRANCH || true
	export LD_LIBRARY_PATH=/usr/local/lib/ 
	sudo make uninstall || true
	git pull
	PYTHON=/usr/bin/python3
	./autogen.sh
	make
	sudo make install
	cd ..
fi

sudo cp -r /usr/local/include/gstreamer-1.0 /usr/include/
echo 'include /usr/local/lib' | sudo tee -a /etc/apt/sources.list
sudo ldconfig

echo "Done! Could you belive it?"
