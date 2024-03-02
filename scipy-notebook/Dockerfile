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

# install google chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
RUN apt-get -y update
RUN apt-get install -y google-chrome-stable

# install chromedriver
RUN apt-get install -yqq unzip
RUN wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`/chromedriver_linux64.zip
RUN unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/


# name your environment and choose the python version
ARG conda_env1=scrapper
ARG conda_env2=ocr
#ARG conda_env3=multi_process
ARG py_ver=3.11

# you can add additional libraries you want mamba to install by listing them below the first line and ending with "&& \"
# Install in default env
RUN mamba install --yes \
    'polars' \
    'mdutils' && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# env_1
RUN mamba create --quiet --yes -p "${CONDA_DIR}/envs/${conda_env1}" python=${py_ver} ipython ipykernel \
    jupyter beautifulsoup4 requests selenium schedule tqdm polars && \
    mamba clean --all -f -y

# env_2
RUN mamba create --quiet --yes -p "${CONDA_DIR}/envs/${conda_env2}" python=${py_ver} ipython ipykernel \
    jupyter pdfminer.six pdfplumber pytesseract imutils polars && \
    mamba clean --all -f -y

# env_3
#RUN mamba create --quiet --yes -p "${CONDA_DIR}/envs/${conda_env3}" python=${py_ver} dask && \
#    mamba clean --all -f -y

# any additional pip installs can be added by uncommenting the following line
RUN "${CONDA_DIR}/envs/${conda_env2}/bin/pip" install --quiet --no-cache-dir opencv-contrib-python-headless

# create Python kernel and link it to jupyter
# env_1
RUN "${CONDA_DIR}/envs/${conda_env1}/bin/python" -m ipykernel install --user --name="${conda_env1}" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# env_2
RUN "${CONDA_DIR}/envs/${conda_env2}/bin/python" -m ipykernel install --user --name="${conda_env2}" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# env_3
#RUN "${CONDA_DIR}/envs/${conda_env3}/bin/python" -m ipykernel install --user --name="${conda_env3}" && \
#    fix-permissions "${CONDA_DIR}" && \
#    fix-permissions "/home/${NB_USER}"

# Switch back to jovyan to avoid accidental container runs as root
USER ${NB_UID}

WORKDIR "${HOME}"
