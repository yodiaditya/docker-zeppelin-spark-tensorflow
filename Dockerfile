FROM apache/zeppelin:0.10.1

ARG PYTHON_VERSION=3.9.5
ARG conda_dir=/opt/conda

# Zeppelin home location inside docker
ENV ZEPPELIN_HOME=/opt/zeppelin

# Add launch script and zeppling server parameters
# Modify login shiro, interpreter and zeppelin-site.xml at `zeppelin/conf` folder
COPY zeppelin ${ZEPPELIN_HOME}
COPY requirements.txt ${ZEPPELIN_HOME}

# Need to use root because default user don't have permission to use --cache-dir
USER root
WORKDIR ${ZEPPELIN_HOME}

COPY pip-cache ${ZEPPELIN_HOME}/pip-cache

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install gcc git libarchive13 -y && \
    conda update --all && \
    conda install mamba -c conda-forge && \
    mamba env update -f ${ZEPPELIN_HOME}/conf/env_python_3_with_R.yml --prune && \
    # Cleanup based on https://github.com/ContinuumIO/docker-images/commit/cac3352bf21a26fa0b97925b578fb24a0fe8c383
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    mamba clean -ay
    # Allow to modify conda packages. This allows malicious code to be injected into other interpreter sessions, therefore it is disabled by default
    # chmod -R ug+rwX /opt/conda

ENV PATH=/opt/conda/envs/python_3_with_R/bin:$PATH

# Install GCC
# RUN apt update && apt install -y gcc git

# RUN conda init bash
RUN conda init bash
SHELL ["/bin/bash", "-c", "source /opt/zeppelin/.bashrc"]

RUN conda activate python_3_with_R

# # Activate the conda environment use for Zeppelin (python_3_with_R)
RUN pip install --cache-dir pip-cache -r requirements.txt
