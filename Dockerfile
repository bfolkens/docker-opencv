FROM nvidia/cuda:8.0-cudnn7-devel-ubuntu16.04

# Install some dep packages

ENV OPENCV_VERSION 3.4.3
ENV OPENCV_PACKAGES libswscale-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev

ENV FFMPEG_VERSION 3.3.2
ENV FFMPEG_DEV_PACKAGES libavcodec-dev libavfilter-dev libavformat-dev libavresample-dev libavutil-dev libpostproc-dev libswresample-dev libswscale-dev libass-dev libwebp-dev libvorbis-dev zlib1g-dev libx264-dev libxvidcore-dev
ENV BUILD_PACKAGES build-essential yasm autoconf automake libtool pkg-config git wget unzip texinfo

RUN apt-get update && \
    apt-get install -y $BUILD_PACKAGES $OPENCV_PACKAGES $FFMPEG_DEV_PACKAGES && \
    apt-get remove -y cmake && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

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

# Upgrade CMake

RUN cd /usr/local/src && \
    wget http://www.cmake.org/files/v3.5/cmake-3.5.1.tar.gz && \
    tar xf cmake-3.5.1.tar.gz && \
    cd cmake-3.5.1 && \
    ./configure --prefix=/usr && \
    make && \
    make install && \
    rm -rf /usr/local/src/cmake*

# Install OpenCV

RUN cd /usr/local/src && \
    git clone https://github.com/opencv/opencv.git && \
    cd opencv && \
    git checkout $OPENCV_VERSION && \
    mkdir build && \
    cd build && \
    cmake -D CMAKE_BUILD_TYPE=Release \
          -D CMAKE_INSTALL_PREFIX=/usr \
          -D BUILD_EXAMPLES=OFF \
          -D CUDA_GENERATION=Auto \
          -D WITH_IPP=OFF -D WITH_TBB=ON \
          -D WITH_FFMPEG=ON -D WITH_V4L=OFF \
          -D ENABLE_FAST_MATH=1 -D CUDA_FAST_MATH=1 -D WITH_CUBLAS=1 \
          -D WITH_VTK=OFF -D WITH_OPENGL=OFF -D WITH_QT=OFF .. && \
    make && make install && \
    rm -rf /usr/local/src/opencv*
