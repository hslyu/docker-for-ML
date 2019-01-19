FROM nvidia/cuda:9.0-devel-ubuntu16.04

LABEL maintainer="Hyeonsu Lyu <hslyu@unist.ac.kr>"

# Change ubuntu repo into daumkakao mirror
ADD sources.list /sources.list
RUN mv /etc/apt/sources.list /etc/apt/sources.list.old && \
	mv /sources.list /etc/apt/sources.list

# Pick up some TF dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
# apt-utils install
		apt-utils \
        build-essential \
        cuda-command-line-tools-9-0 \
        cuda-cublas-9-0 \
        cuda-cufft-9-0 \
        cuda-curand-9-0 \
        cuda-cusolver-9-0 \
        cuda-cusparse-9-0 \
        curl \
        libcudnn7=7.0.5.15-1+cuda9.0 \
        libnccl2=2.3.7-1+cuda9.0 \
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

RUN apt-get update && \
        apt-get install nvinfer-runtime-trt-repo-ubuntu1604-4.0.1-ga-cuda9.0 && \
        apt-get update && \
        apt-get install libnvinfer4=4.1.2-1+cuda9.0

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

RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    python3 get-pip.py && \
# Change basic pip into python2
    rm get-pip.py \
	   /usr/local/bin/pip && \
	cp /usr/local/bin/pip2 /usr/local/bin/pip

# Install python2 ML modules
RUN pip --no-cache-dir install \
        Pillow \
        h5py \
        ipykernel \
        jupyter \
        keras_applications \
        keras_preprocessing \
        matplotlib \
        numpy==1.14.5 \
        pandas \
        scipy \
        sklearn \
        && \
    python -m ipykernel.kernelspec

# Install python3 ML modules
RUN pip3 --no-cache-dir install \
        Pillow \
        h5py \
        keras_applications \
        keras_preprocessing \
        matplotlib \
        numpy \
        pandas \
        scipy \
        sklearn 

# Install Opencv3.4 by compiling
ADD ./opencv /opencv
RUN	mkdir /opencv/build && \
	cd /opencv && \
	cd /opencv/build && \
	cmake -D CMAKE_BUILD_TYPE=RELEASE \
# Build python3 cv2
#		-D BUILD_NEW_PYTHON_SUPPORT=ON \
#		-D BUILD_opencv_python3=ON \
#		-D HAVE_opencv_python3=ON \
		-D PYTHON2_EXECUTABLE=/usr/bin/python \
		-D PYTHON2_INCLUDE_DIR=/usr/include/python2.7 \
		-D PYTHON2_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython2.7.so \
		-D PYTHON2_NUMPY_INCLUDE_DIRS=/usr/local/lib/python2.7/dist-packages/numpy/core/include \
#		-D PYTHON3_EXECUTABLE=/usr/bin/python3 \
#		-D PYTHON3_INCLUDE_DIR=/usr/include/python3.5 \
#		-D PYTHON3_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.5m.so \
#		-D PYTHON3_NUMPY_INCLUDE_DIRS=/usr/local/lib/python3.5/dist-packages/numpy/core/include \
#		-D PYTHON_DEFAULT_EXECUTABLE=/usr/bin/python2.7 \
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
		-D CUDA_ARCH_BIN=6.1 7.5 \
		-D CUDA_TOOLKIT_ROOT_DIR:PATH=/usr/local/cuda-9.0 \
		.. && \
	export NUMPROC=$(nproc --all) && \
	make -j$NUMPROC && \
	make install && \
	cd ../ && \
# Remove mounted directory
	rm /opencv -r 

# Install TensorFlow GPU version.
ADD ./cuda9.0-cudnn7.0-nccl2.2-arch6.1/ /tmp/
RUN pip3 --no-cache-dir install /tmp/tensorflow-1.12.0-cp35-cp35m-linux_x86_64.whl && \
    pip --no-cache-dir install /tmp/tensorflow-1.12.0-cp27-cp27mu-linux_x86_64.whl && \
    rm -rf /tmp

# RUN ln -s -f /usr/bin/python3 /usr/bin/python#

# Set up our notebook config.
COPY jupyter_notebook_config.py /root/.jupyter/

# Copy sample notebooks.
COPY notebooks /notebooks

# Jupyter has issues with being run directly:
#   https://github.com/ipython/ipython/issues/7062
# We just add a little wrapper script.
COPY run_jupyter.sh /

# For CUDA profiling, TensorFlow requires CUPTI.
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH

# TensorBoard
EXPOSE 6006
# IPython
EXPOSE 8888

#WORKDIR "/notebooks"

#CMD ["/run_jupyter.sh", "--allow-root"]
