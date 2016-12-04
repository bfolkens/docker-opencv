FROM nvidia/cuda:7.0-cudnn4-devel

# Install some dep packages

ENV OPENCV_VERSION 2.4.12

RUN apt-get update && \
    apt-get install -y git wget build-essential unzip python2.7 python2.7-dev python-numpy python-scipy && \
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
    wget -O opencv-$OPENCV_VERSION.zip https://github.com/Itseez/opencv/archive/$OPENCV_VERSION.zip && \
    unzip opencv-$OPENCV_VERSION.zip && \
    cd opencv-$OPENCV_VERSION && \
    mkdir build && \
    cd build && \
    cmake -D CMAKE_BUILD_TYPE=Release \
          -D CMAKE_INSTALL_PREFIX=/usr \
          -D BUILD_opencv_python=on \
          -D BUILD_EXAMPLES=OFF \
          -D CUDA_GENERATION=Auto \
          -D WITH_TBB=ON -D WITH_V4L=ON -D WITH_VTK=ON -D WITH_OPENGL=OFF -D WITH_QT=OFF .. && \
    make -j$(nproc) && \
    make install && \
    cp lib/cv2.so /usr/local/lib/python2.7/dist-packages/ && \
    rm -rf /usr/local/src/opencv-$OPENCV_VERSION.zip /usr/local/src/opencv-$OPENCV_VERSION

