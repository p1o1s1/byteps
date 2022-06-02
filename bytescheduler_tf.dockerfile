FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install -y wget

#ENV USE_BYTESCHEDULER=1
ENV PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python

RUN apt install linux-libc-dev 
RUN apt-get -f install
RUN apt install -y gcc-4.8 

RUN apt-get update && apt-get install -y \
        software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update && apt-get install -y \
        python3.7 \
        python3-pip
RUN python3.7 -m pip install pip
RUN apt-get update && apt-get install -y \
        python3-distutils \
        python3-setuptools
RUN python3.7 -m pip install pip --upgrade pip

WORKDIR /usr/bin
RUN ln -s python3.7 python

RUN apt-get install -y python3.7-dev

WORKDIR /
RUN apt-get install -y pkg-config zip g++ zlib1g-dev unzip; \
	wget https://github.com/bazelbuild/bazel/releases/download/0.19.2/bazel-0.19.2-installer-linux-x86_64.sh; \
	chmod +x bazel-0.19.2-installer-linux-x86_64.sh; \
	./bazel-0.19.2-installer-linux-x86_64.sh; \
	bazel

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git

RUN git clone --branch bytescheduler --recursive https://github.com/bytedance/byteps.git

RUN pip install pip 'numpy<1.19.0' wheel packaging requests opt_einsum
RUN pip install keras_preprocessing --no-deps
RUN git clone https://github.com/tensorflow/tensorflow.git
WORKDIR /tensorflow
RUN git checkout r1.13

#RUN cp /byteps/bytescheduler/bytescheduler/tensorflow/tf.patch /tensorflow/tf.patch
#RUN patch -p1 < ./tf.patch
RUN wget https://raw.githubusercontent.com/p1o1s1/byteps/master/Add-grpc-fix-for-gettid.patch
RUN patch -f -p1 <Add-grpc-fix-for-gettid.patch
RUN wget https://nomeroff.net.ua/tf/Rename-gettid-functions.patch
RUN cp ./Rename-gettid-functions.patch ./third_party/Rename-gettid-functions.patch

RUN bazel build //tensorflow/tools/pip_package:build_pip_package

RUN ./bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
RUN pip install /tmp/tensorflow_pkg/tensorflow-1.13.2-cp37-cp37m-linux_x86_64.whl

WORKDIR /byteps/bytescheduler/bytescheduler/tensorflow
RUN rm Makefile
RUN wget https://raw.githubusercontent.com/p1o1s1/byteps/master/Makefile
RUN make

RUN pip install cmake
RUN apt-get -y install libopenmpi-dev
RUN pip install mpi4py
RUN HOROVOD_WITH_TENSORFLOW=1 pip install horovod[tensorflow]==0.19.0
