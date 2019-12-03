# docker-recipe-for-ML
Docker image build recipe with various machine learning libraries, including tensorflow, pytorch and opencv. This repository is tested on ubuntu 18.04 with NVIDIA Geforce 1080TI and NVIDIA RTX 2080TI.

# What you need to do first
1. Install docker according to the [docker docs](https://docs.docker.com/install/).
2. Install nvidia-docker according to the [nvidia-docker github](https://github.com/NVIDIA/nvidia-docker).
3. Clone this repository and enter into the directory.
~~~
cd ./docker-recipe-for-ML
~~~
4. In the **docker-recipe-for-ML** directory, clone [tensorflow github](https://github.com/tensorflow/tensorflow) and [opencv github](https://github.com/opencv/opencv).
5. Go to the tensorflow directory and checkout to the version you want to build.
6. Go to the opencv directory and checkout to the version you want to build.
