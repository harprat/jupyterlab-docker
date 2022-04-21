# Choose your desired base image
FROM jupyter/all-spark-notebook:latest

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

RUN apt-get update --yes && \
	apt-get install --yes --no-install-recommends \
	autoconf \
	autoconf-archive \
    	automake \
	checkinstall \
	cmake \
	g++ \
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
	wget \
	xzgv \
	zlib1g-dev \
    software-properties-common

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

USER ${NB_UID}

RUN mamba install --quiet --yes \
    'xlsxwriter' \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# name your environment and choose the python version
ARG conda_env1=scrapper
ARG conda_env2=ocr
ARG py_ver=3.9

# you can add additional libraries you want mamba to install by listing them below the first line and ending with "&& \"
RUN mamba create --quiet --yes -p "${CONDA_DIR}/envs/${conda_env1}" python=${py_ver} ipython ipykernel && \
    jupyter beautifulsoup4 requests selenium schedule tqdm && \
    mamba clean --all -f -y

RUN mamba create --quiet --yes -p "${CONDA_DIR}/envs/${conda_env2}" python=${py_ver} ipython ipykernel && \
    jupyter pdfminer.six pdfplumber pytesseract && \
    mamba clean --all -f -y

# create Python kernel and link it to jupyter
RUN "${CONDA_DIR}/envs/${conda_env1}/bin/python" -m ipykernel install --user --name="${conda_env1}" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

RUN "${CONDA_DIR}/envs/${conda_env2}/bin/python" -m ipykernel install --user --name="${conda_env2}" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Install the Dask dashboard
RUN "${CONDA_DIR}/envs/${conda_env}/bin/pip" install --quiet --no-cache-dir dask-labextension && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Dask Scheduler & Bokeh ports
EXPOSE 8787
EXPOSE 8786

# Switch back to jovyan to avoid accidental container runs as root
USER ${NB_UID}

WORKDIR "${HOME}"
