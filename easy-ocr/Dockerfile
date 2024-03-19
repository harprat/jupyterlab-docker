# Choose your desired base image
ARG REGISTRY=quay.io
ARG OWNER=jupyter
ARG BASE_CONTAINER=$REGISTRY/$OWNER/scipy-notebook
FROM $BASE_CONTAINER

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# install tesseract dependencies
RUN apt-get update --yes && \
	apt-get install --yes --no-install-recommends \
	autoconf \
	autoconf-archive \
	automake \
	checkinstall \
	cmake \
	curl \
	g++ \
	gnupg2 \
	libcairo2-dev \
	libicu-dev \
	libjpeg-dev \
	libpango1.0-dev \
	libgif-dev \
	libwebp-dev \
	libopenjp2-7-dev \
	libpng-dev \
	libtiff-dev \
	libtool \
	pkg-config \
	xzgv \
	zlib1g-dev \
	# to make apt add repository available
	software-properties-common && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:alex-p/tesseract-ocr5

# Install tesseract
RUN apt install -y tesseract-ocr

# To prevent apt-key output warning 
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

# name your environment and choose the python version
ARG py_ver=3.11

# you can add additional libraries you want mamba to install by listing them below the first line and ending with "&& \"
# Install in default env
  # Install PyTorch with pip (https://pytorch.org/get-started/locally/)
  # hadolint ignore=DL3013
RUN pip install --no-cache-dir --index-url 'https://download.pytorch.org/whl/cpu' \
    'torch' \
    'torchvision' \
    'torchaudio'  && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

RUN mamba install --yes \
    'polars' \
    'pytesseract' \
    'ocl-icd-system' \
    'easyocr' \
    'pdfminer.six' \
    'pdfplumber' \
    'imutils' \
    'mdutils' && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# any additional pip installs can be added by uncommenting the following line
RUN pip install --quiet --no-cache-dir opencv-contrib-python-headless

# Switch back to jovyan to avoid accidental container runs as root
USER ${NB_UID}

WORKDIR "${HOME}"
