# docker-for-ML
Docker image build recipe with various machine learning libraries, including tensorflow, pytorch and opencv. This repository is tested on ubuntu 18.04 with NVIDIA Geforce 1080TI and NVIDIA RTX 2080TI, and NVIDA driver>=430.50.

# How to build an image using this repo?
1. Install docker according to the [docker docs](https://docs.docker.com/install/).
2. Install nvidia-docker according to the [nvidia-docker github](https://github.com/NVIDIA/nvidia-docker).
3. Clone this repository and enter into the directory.
~~~
git clone https://github.com/hslyu/docker-for-ML
cd ./docker-for-ML
~~~
4. Download bazel linux installer from [here](https://github.com/bazelbuild/bazel/releases).
5. Rename the downloaded installer "bazel-<bazel-version>-installer-<os>-<arch>.sh" as **installer.sh**, and then move the installer into docker-for-ML.
  ~~~
  mv bazel-<bazel-version>-installer-<os>-<arch>.sh <path to docker-for-ML>/installer.sh
  ~~~
6. Build the docker image.
  ~~~
  docker build -t <image name>:<tag> --build-arg USE_PYTHON_3_NOT_2=1 .
  ~~~
  * USE_PYTHON_3_NOT_2 will install python3 as default. If you want to install python2, remove the option.

# How to build an image using this repo?
The file pip.conf and sources.list may change the pip and the apt from default server to mirror server, which is faster than default specifically in Korea. If you don't need this option, comment out below lines in Dockerfile
~~~
ADD pip.conf /root/.pip/pip.conf
ADD sources.list /etc/apt/sources.list
~~~

# What should I do after building the image?
The built image is the base of ML developing environment. After running a container from this image, install/build tensorflow, pytorch, opencv, and any other libraries whatever you want.

For novice,
~~~
pip install tensorflow-gpu==<version you want to install, optional>
~~~

# If you want to build opencv from the image
You can build using the **cv2.Dockerfile**.
To use the dockerfile, **you should clone [my opencv forked repo](https://github.com/hslyu/opencv)".** I resolved several errors that might happen caused by opencv and cuda10 compatibility(opencv 3.4 version is made before CUDA10 is developed.).
I have changed opencv/cmake/FindCUDA.cmake, and modules\cudev\include\opencv2\cudev\common.hpp. You can check it from [here](https://github.com/hslyu/opencv/commit/42b112baa2d140b50e1cfb86aa232e6f9b8eb39d#diff-ded5d5561a9adad3248a896150d8aa73) and [here](https://github.com/hslyu/opencv/commit/7467c781713d284ba1e149842c1904cd93ac85e8#diff-72639e256fec58f913bce6c5a43cd122)
~~~
In the docker-for-ML directory,
git clone https://github.com/hslyu/opencv
cd opencv
git checkout 3.4
cd ..
docker build <options you want> -f cv2.Dockerfile .
~~~
