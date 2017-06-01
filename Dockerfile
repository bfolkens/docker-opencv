FROM nvidia/cuda:8.0-cudnn6-devel-ubuntu16.04

# Install some dep packages

ENV OPENCV_VERSION 3.2.0
ENV OPENCV_PACKAGES libswscale-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev
ENV FFMPEG_DEV_PACKAGES libavcodec-dev libavfilter-dev libavformat-dev libavresample-dev libavutil-dev libpostproc-dev libswresample-dev libswscale-dev

RUN apt-get update && \
    apt-get install -y git wget build-essential unzip $OPENCV_PACKAGES $FFMPEG_DEV_PACKAGES && \
    apt-get remove -y cmake && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

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
