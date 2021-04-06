# Copyright Zapata Computing, Inc. All rights reserved.

# Dockerfile for the base QE docker image
FROM zapatacomputing/qe-tools-base:nightly
WORKDIR /app
USER root

# Install basic packages and dependecies for QVM
RUN apt-get clean && \
    apt-get update -y && \
    apt-get install -y \
        wget \
        vim \
        htop \
        sbcl \
        clang-7 \
        libzmq3-dev \
        libz-dev \
        libblas-dev \
        liblapack-dev && \
    apt-get clean

# Install ML Libraries
# pytorch installation will OOM fail without --no-cache-dir
# https://stackoverflow.com/questions/59800318/how-to-install-torch-in-python
RUN pip3 install --no-cache-dir \
    scipy \
    scikit-learn \
    theano \
    keras \
    torch \
    gym \
    jax \
    jaxlib \
    autograd \
    tensorflow \
    tensorboard \
    tensorflow-estimator \
    tensornetwork \
    pennylane \
    pennylane-qiskit \
    pennylane-cirq \
    pennylane-forest \
    pennylane-qsharp \
    qiskit \
    pyquil \
    tensorflow \
    tensorflow-quantum \
    gpyopt \
    cvxopt

# Install Rigetti QVM
# TODO figure out nightly build installation
WORKDIR /root
RUN curl -O https://beta.quicklisp.org/quicklisp.lisp && \
    echo '(quicklisp-quickstart:install)'  | sbcl --load quicklisp.lisp
RUN git clone https://github.com/rigetti/quilc.git && \
    cd quilc && \
    git fetch && \
    git checkout v1.23.0 && \
    git submodule init && \
    git submodule update --init && \
    make && \
    mv quilc /usr/local/bin
RUN git clone https://github.com/rigetti/qvm.git && \
    cd qvm && \
    git fetch && \
    git checkout v1.17.1 && \
    make QVM_WORKSPACE=10240 qvm && \
    mv qvm /usr/local/bin

#TODO using legacy version to avoid pip install dependency hell
RUN pip3 install pip==20.2.4

WORKDIR /app
ENTRYPOINT bash
