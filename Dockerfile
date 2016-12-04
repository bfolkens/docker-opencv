FROM nvidia/cuda:7.5-cudnn5-devel

# Install some dep packages

ENV OPENCV_VERSION 3.1.0
ENV OPENCV_PACKAGES libswscale-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev python2.7 python2.7-dev python-numpy python-scipy

RUN apt-get update && \
    apt-get install -y git wget build-essential unzip $OPENCV_PACKAGES && \
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
          -D BUILD_opencv_python=on \
          -D CUDA_GENERATION=Auto \
          -D WITH_IPP=OFF -D WITH_TBB=ON \
          -D WITH_FFMPEG=OFF -D WITH_V4L=OFF \
          -D ENABLE_FAST_MATH=1 -D CUDA_FAST_MATH=1 -D WITH_CUBLAS=1 \
          -D WITH_VTK=OFF -D WITH_OPENGL=OFF -D WITH_QT=OFF .. && \
    make -j$(nproc) && \
    make install && \
    cp lib/cv2.so /usr/local/lib/python2.7/dist-packages/ && \
    rm -rf /usr/local/src/opencv-$OPENCV_VERSION.zip /usr/local/src/opencv-$OPENCV_VERSION

