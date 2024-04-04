FROM apache/zeppelin:0.10.1

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

# Install GCC
# RUN apt update && apt install -y gcc git

# RUN conda init bash
RUN conda init bash
SHELL ["/bin/bash", "-c", "source /opt/zeppelin/.bashrc"]

RUN conda activate python_3_with_R

# # Activate the conda environment use for Zeppelin (python_3_with_R)
RUN pip install --cache-dir pip-cache -r requirements.txt
