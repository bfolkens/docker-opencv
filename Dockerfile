FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04

# Install some dep packages

ENV OPENCV_VERSION 3.4.6
ENV OPENCV_PACKAGES libswscale-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev

ENV FFMPEG_VERSION 3.4.6
ENV FFMPEG_DEV_PACKAGES libavcodec-dev libavfilter-dev libavformat-dev libavresample-dev libavutil-dev libpostproc-dev libswresample-dev libswscale-dev libass-dev libwebp-dev libvorbis-dev zlib1g-dev libx264-dev libxvidcore-dev
ENV BUILD_PACKAGES build-essential yasm autoconf automake libtool pkg-config git wget unzip texinfo sudo cmake

# Ubuntu 18+ doesn't include libjasper-dev or libpng12-dev
RUN apt-get update && \
    apt-get install -y $BUILD_PACKAGES $OPENCV_PACKAGES $FFMPEG_DEV_PACKAGES && \
    wget http://security.ubuntu.com/ubuntu/pool/main/j/jasper/libjasper-dev_1.900.1-debian1-2.4ubuntu1.2_amd64.deb && \
    wget http://security.ubuntu.com/ubuntu/pool/main/j/jasper/libjasper1_1.900.1-debian1-2.4ubuntu1.2_amd64.deb && \
    apt-get install ./libjasper-dev_1.900.1-debian1-2.4ubuntu1.2_amd64.deb ./libjasper1_1.900.1-debian1-2.4ubuntu1.2_amd64.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /*.deb

# Install custom, accelerated FFMPEG

RUN cd /usr/local/src && \
    git clone https://github.com/FFmpeg/FFmpeg.git ffmpeg && \
    cd /usr/local/src/ffmpeg && \
    git checkout n$FFMPEG_VERSION && \
    ./configure \
      --build-suffix=-ffmpeg --toolchain=hardened --libdir=/usr/lib/x86_64-linux-gnu --incdir=/usr/include/x86_64-linux-gnu --cc=cc --cxx=g++ \
      --enable-gpl --enable-shared --disable-stripping --enable-avresample \
      --enable-avisynth --enable-libass --enable-libvorbis \
      --enable-libwebp --enable-libxvid \
      --enable-libdc1394 --enable-libx264 --enable-nonfree \
      --enable-cuda --enable-cuvid --enable-nvenc --enable-nonfree --enable-libnpp \
      --extra-cflags=-I/usr/local/cuda/include --extra-ldflags=-L/usr/local/cuda/lib64 && \
    make -j $(nproc) && \
    make install && \
    rm -rf /usr/local/src/ffmpeg*

# Install OpenCV

# Get source of OpenCV modules like CUDA...
RUN cd /usr/local/src && \
    git clone https://github.com/opencv/opencv_contrib.git && \
    cd opencv_contrib && \
    git checkout $OPENCV_VERSION

RUN cd /usr/local/src && \
    wget -O opencv-$OPENCV_VERSION.zip https://github.com/opencv/opencv/archive/$OPENCV_VERSION.zip && \
    unzip opencv-$OPENCV_VERSION.zip && \
    cd opencv-$OPENCV_VERSION && \
    mkdir build && \
    cd build && \
    cmake -D CMAKE_BUILD_TYPE=Release \
          -D CMAKE_INSTALL_PREFIX=/usr \
          -D BUILD_EXAMPLES=OFF -D BUILD_DOCS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_TESTS=OFF \
          -D CUDA_GENERATION=Auto \
          -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
          -D ENABLE_FAST_MATH=1 -D CUDA_FAST_MATH=1 -D WITH_CUBLAS=1 \
          -D WITH_CUDA=ON -D WITH_FFMPEG=ON -D WITH_IPP=OFF -D WITH_TBB=ON -D WITH_V4L=OFF -D WITH_VTK=OFF -D WITH_OPENGL=OFF -D WITH_QT=OFF .. && \
    make && make install && \
    rm -rf /usr/local/src/opencv*
