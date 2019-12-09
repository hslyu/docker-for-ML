FROM hslyu/tf:1.12-py3-base as base

LABEL maintainer="Hyeonsu Lyu <hslyu@unist.ac.kr>"

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=ASIA/seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Opencv prerequisite
RUN apt-get update && apt-get install -y --no-install-recommends \
	build-essential \
	cmake \
	pkg-config \
	libopencv-dev \
# For still images
	libjpeg-dev \
	libtiff5-dev \
#	libjasper-dev \
	libpng-dev \
# For videos
	libavcodec-dev \
	libavformat-dev \
	libswscale-dev \
	libdc1394-22-dev \
	libxvidcore-dev \
	libx264-dev \
	x264 \
	libxine2-dev \
	libv4l-dev \
	v4l-utils \
	libgstreamer1.0-dev \
	libgstreamer-plugins-base1.0-dev \
# GUI
	libgtk-3-dev \
# Optimization, Python3
	libatlas-base-dev \
	libeigen3-dev \
	gfortran \
	python3-dev \
	python3-numpy \
	libtbb2 \
	libtbb-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Opencv3.4 by compiling
RUN git clone https://github.com/hslyu/opencv /opencv && \
	cd /opencv && \
	git checkout 3.4
RUN	mkdir /opencv/build && \
	cd /opencv/build && \
	cmake -D CMAKE_BUILD_TYPE=RELEASE \
		-D BUILD_opencv_python3=ON \
		-D BUILD_opencv_python2=OFF \
		-D PYTHON_DEFAULT_EXECUTABLE=/usr/bin/python \
        -D BUILD_opencv_java=OFF \
		-D WITH_TBB=ON \
		-D WITH_V4L=ON \
		-D ENABLE_FAST_MATH=ON \
		-D WITH_OPENCL=OFF \
		-D WITH_OPENGL=ON \
		-D WITH_CUDA=ON \
		-D CUDA_FAST_MATH=ON \
		-D WITH_CUBLAS=ON \
		-D CUDA_ARCH_BIN=6.1 \
		-D CUDA_TOOLKIT_ROOT_DIR:PATH=/usr/local/cuda \
		.. && \
	export NUMPROC=$(nproc --all) && \
	make -j$NUMPROC && \
	make install && \
	cd ../ && \
# Remove mounted directory
	rm /opencv -r 

# For CUDA profiling, TensorFlow requires CUPTI.
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH
ENV PATH /usr/local/cuda/bin:$PATH
