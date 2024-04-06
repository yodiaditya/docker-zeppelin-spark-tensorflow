FROM apache/zeppelin:0.10.1

ENV ZEPPELIN_HOME=/opt/zeppelin
ENV ZEPPELIN_NOTEBOOK_DIR /notebooks
ENV ZEPPELIN_INTERPRETER_DEP_MVNREPO https://repo1.maven.org/maven2/
ENV ZEPPELIN_ADDR 0.0.0.0
ENV SPARK_HOME /opt/bitnami/spark

USER root

# Create the notebooks directory with proper permissions
RUN mkdir -p ${ZEPPELIN_NOTEBOOK_DIR}
RUN chown -R 1000:1000 ${ZEPPELIN_NOTEBOOK_DIR}
RUN chmod -R 755 ${ZEPPELIN_NOTEBOOK_DIR}

# Update package lists
RUN apt-get update

# Install libnss-wrapper
RUN apt-get install -y libnss-wrapper gcc git wget sudo
RUN mkdir -p /opt/bitnami/common/lib/
RUN ln -s /usr/lib/libnss_wrapper.so /opt/bitnami/common/lib/libnss_wrapper.so
ENV LD_PRELOAD=/usr/lib/libnss_wrapper.so

RUN rm -rf /var/lib/apt/lists/*

COPY zeppelin-env.sh ${ZEPPELIN_HOME}/conf/zeppelin-env.sh
COPY requirements.txt ${ZEPPELIN_HOME}/requirements.txt
COPY pip-cache ${ZEPPELIN_HOME}/pip-cache

RUN chown -R 1000:1000 ${ZEPPELIN_HOME}/pip-cache

USER 1000

# RUN conda init bash
RUN conda init bash
SHELL ["/bin/bash", "-c", "source /opt/zeppelin/.bashrc"]

RUN conda activate python_3_with_R && pip install --cache-dir pip-cache -r requirements.txt

