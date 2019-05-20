FROM nvidia/cuda:10.0-devel-ubuntu16.04

LABEL maintainer="Hyeonsu Lyu <hslyu@unist.ac.kr>"

# Change ubuntu repo into daumkakao mirror
ADD sources.list /sources.list
RUN mv /etc/apt/sources.list /etc/apt/sources.list.old && \
	mv /sources.list /etc/apt/sources.list

# Pick up some dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
# apt-utils install
		sudo \
		apt-utils \
        build-essential \
        cuda-command-line-tools-10-0 \
        cuda-cublas-10-0 \
        cuda-cufft-10-0 \
        cuda-curand-10-0 \
        cuda-cusolver-10-0 \
        cuda-cusparse-10-0 \
        curl \
        libcudnn7=7.4.2.24-1+cuda10.0 \
#        libnccl2=2.3.7-1+cuda10.0 \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        python \
        python-dev \
        rsync \
        software-properties-common \
        unzip \
# vim install
		vim \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install cudnn
ADD ./cuda /cuda
RUN mv /cuda/include/cudnn.h /usr/local/cuda/include/ && \
	mv /cuda/lib64/* /usr/local/cuda/lib64/ && \
	rm -r /cuda

RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
#    python get-pip.py && \
    python3 get-pip.py && \
# Change basic pip into python2
    rm get-pip.py \
	   /usr/local/bin/pip && \
	cp /usr/local/bin/pip3 /usr/local/bin/pip


############## python2 will be deprecated from 2020 ################
# Install python2 ML modules
#RUN pip --no-cache-dir install \
#        Pillow \
#        h5py \
#        ipykernel \
#        jupyter \
#        keras_applications \
#        keras_preprocessing \
#        matplotlib \
#        numpy \
#        pandas \
#        scipy \
#        sklearn \
#        && \
#    python -m ipykernel.kernelspec

# Install python3 ML modules
RUN pip3 --no-cache-dir install \
        Pillow \
        h5py \
#        keras_applications \
#        keras_preprocessing \
        matplotlib \
        numpy \
        pandas \
#        scipy \
#        sklearn 

RUN apt-get update && apt-get install -y --no-install-recommends \
        libgirepository1.0-dev \
        gcc \
        libcairo2-dev \
        pkg-config \
        python3-dev \
        gir1.2-gtk-3.0 \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 

# From here Opencv
RUN apt-get update && apt-get install -y --no-install-recommends \
		libopencv-dev \
		checkinstall \
		cmake \
		pkg-config \
		yasm \
		libtiff5-dev \
		libjpeg-dev \
		libjasper-dev \
		libavcodec-dev \
		libavformat-dev \
		libswscale-dev \
		libdc1394-22-dev \
		libxine2-dev \
		libgstreamer0.10-dev \
		libgstreamer-plugins-base0.10-dev \
		qt5-default \
		libv4l-dev \
		libtbb-dev \
		libgtk2.0-dev \
		libfaac-dev \  
		libmp3lame-dev \
		libopencore-amrnb-dev \
		libopencore-amrwb-dev \
		libtheora-dev \
		libvorbis-dev \
		libxvidcore-dev \
		x264 \
		v4l-utils \
		ffmpeg \
		frei0r-plugins \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Opencv3.4 by compiling
ADD ./opencv /opencv
RUN	mkdir /opencv/build && \
	cd /opencv && \
	cd /opencv/build && \
	cmake -D CMAKE_BUILD_TYPE=RELEASE \
# Build python3 cv2
		-D BUILD_NEW_PYTHON_SUPPORT=ON \
		-D BUILD_opencv_python3=ON \
		-D HAVE_opencv_python3=ON \
#		-D PYTHON2_EXECUTABLE=/usr/bin/python \
#		-D PYTHON2_INCLUDE_DIR=/usr/include/python2.7 \
#		-D PYTHON2_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython2.7.so \
#		-D PYTHON2_NUMPY_INCLUDE_DIRS=/usr/local/lib/python2.7/dist-packages/numpy/core/include \
		-D PYTHON3_EXECUTABLE=/usr/bin/python3 \
		-D PYTHON3_INCLUDE_DIR=/usr/include/python3.5 \
		-D PYTHON3_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.5m.so \
		-D PYTHON3_NUMPY_INCLUDE_DIRS=/usr/local/lib/python3.5/dist-packages/numpy/core/include \
#		-D PYTHON_DEFAULT_EXECUTABLE=/usr/bin/python2.7 \
    	-D PYTHON_DEFAULT_EXECUTABLE=/usr/bin/python3.5 \
# Not build java
        -D BUILD_opencv_java=OFF \
		-D WITH_TBB=ON \
		-D WITH_V4L=ON \
		-D INSTALL_PYTHON_EXAMPLES=ON \
		-D ENABLE_FAST_MATH=ON \
		-D WITH_OPENCL=OFF \
		-D WITH_OPENGL=ON \
# CUDA Settings
		-D WITH_CUDA=ON \
		-D CUDA_FAST_MATH=ON \
		-D WITH_CUBLAS=ON \
		-D CUDA_ARCH_BIN=7.5 \
		-D CUDA_TOOLKIT_ROOT_DIR:PATH=/usr/local/cuda-10.0 \
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

# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos '' --shell /bin/bash aislab
RUN echo "aislab ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-aislab
USER aislab
