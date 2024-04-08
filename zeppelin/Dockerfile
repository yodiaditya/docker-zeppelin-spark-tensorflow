FROM apache/zeppelin:0.10.1

ENV ZEPPELIN_HOME=/opt/zeppelin
ENV ZEPPELIN_NOTEBOOK_DIR /notebooks
ENV SPARK_HOME /opt/bitnami/spark

ENV TZ=UTC \
    DEBIAN_FRONTEND=noninteractive
ENV ZEPPELIN_LOG_DIR=opt/zeppeli/logs

USER root

# You can change the apt source to a faster mirror. 
# This is an example for Indonesian mirror
# RUN rm -rf /etc/apt/sources.list
# RUN echo "deb http://kartolo.sby.datautama.net.id/ubuntu/ focal main restricted universe multiverse" > /etc/apt/sources.list
# RUN echo "deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-security main restricted universe multiverse" >> /etc/apt/sources.list

RUN rm -f /etc/apt/apt.conf.d/docker-clean
RUN --mount=type=cache,target=/var/cache/apt \
        	apt-get update && \
	        apt-get install -yqq --no-install-recommends \
            libnss-wrapper gcc git wget vim build-essential libxml2 nvtop rsync tini libarchive13

RUN  mkdir -p ${ZEPPELIN_HOME}/logs \
    && mkdir -p ${ZEPPELIN_HOME}/run

# Add libnss_wrapper.so to the common lib directory to avoid errors when running Zepplin as non-root user
RUN mkdir -p /opt/bitnami/common/lib/
RUN ln -s /usr/lib/libnss_wrapper.so /opt/bitnami/common/lib/libnss_wrapper.so
ENV LD_PRELOAD=/usr/lib/libnss_wrapper.so

# Create the notebooks directory with proper permissions
RUN mkdir -p ${ZEPPELIN_NOTEBOOK_DIR}
RUN chown -R 1000:1000 ${ZEPPELIN_NOTEBOOK_DIR}
RUN chmod -R 777 ${ZEPPELIN_NOTEBOOK_DIR}

# Copy the configuration files and requirements.txt
COPY ./conf ${ZEPPELIN_HOME}/conf
COPY ./requirements.txt ${ZEPPELIN_HOME}/requirements.txt
COPY ./tfx_requirements.txt ${ZEPPELIN_HOME}/tfx_requirements.txt

################# CUDA INSTALLATION #################
# COMMENT THIS LINE UNTIL END INSTALLATION IF YOU DON'T NEED TO USE CUDA 

# # ENSURE TO COPY THE cuda_11.8.0_520.61.05_linux.run and cudnn INTO THE zeppelin/cuda FOLDER

# # CUDA Installation
# COPY ./cuda ${ZEPPELIN_HOME}/cuda
# RUN chmod a+x cuda/cuda_11.8.0_520.61.05_linux.run
# RUN cuda/cuda_11.8.0_520.61.05_linux.run --silent --toolkit

# # copy CUDNN following files into the cuda toolkit directory.
# RUN cp -P cuda/cudnn/include/cudnn.h /usr/local/cuda/include
# RUN cp -P cuda/cudnn/lib/libcudnn* /usr/local/cuda/lib64/
# RUN chmod a+r /usr/local/cuda-11.8/lib64/libcudnn*
# RUN rm -rf cuda

# # Ensure cuda is added to the PATH, since ~./bashrc is not loaded
# ENV PATH /usr/local/cuda/bin:${PATH}
# ENV LD_LIBRARY_PATH /usr/local/cuda/lib:/usr/local/cuda/lib64

# # Export the path
# RUN echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ${ZEPPELIN_HOME}/.bashrc
# RUN echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ${ZEPPELIN_HOME}/.bashrc
# RUN ldconfig

################# End Install CUDA #################

################## INSTALL MAMBA AND PYTHON 3.9 #################

COPY ./env_python_3_with_R.yml ${ZEPPELIN_HOME}/env_python_3_with_R.yml

RUN conda update --all && \
    conda install mamba -c conda-forge && \
    mamba remove -n python_3_with_R --all -y && \
    mamba env update -f ${ZEPPELIN_HOME}/env_python_3_with_R.yml --prune && \
    # Cleanup based on https://github.com/ContinuumIO/docker-images/commit/cac3352bf21a26fa0b97925b578fb24a0fe8c383
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    mamba clean -ay
    # Allow to modify conda packages. This allows malicious code to be injected into other interpreter sessions, therefore it is disabled by default
    # chmod -R ug+rwX /opt/conda

ENV PATH /opt/conda/envs/python_3_with_R/bin:/opt/conda/bin:$PATH
ENV PATH=/opt/zeppelin/.local/bin:$PATH
###################### END MAMBA AND PYTHON 3.9 ######################

# Setup conda and auto load environment `python_3_with_R` whenever login 
COPY ./bashrc ${ZEPPELIN_HOME}/.bashrc
RUN chown 1000:1000 ${ZEPPELIN_HOME}/.bashrc

# Copy pip-cache folder from host to Docker
# Instead of project folder, it using zeppelin folder as parent directory (Docker: context . )
# COPY ./pip-cache ${ZEPPELIN_HOME}/pip-cache
# RUN chown -R 1000:1000 ${ZEPPELIN_HOME}/pip-cache

# Change the user back to zeppelin
USER 1000

# Install the required packages. You can modify the requirements.txt file to include the packages you need.
# At first run, you can run the following command to install the packages
# the pip-cache can be copied from Docker to the zeppelin folder with name `pip-cache`

RUN mkdir -p ${ZEPPELIN_HOME}/pip-cache
RUN pip install --cache-dir pip-cache -r requirements.txt

################## Install TFX #################
## COMMENT THIS LINE UNTIL END INSTALLATION IF YOU DON'T NEED TO USE TFX 

# # Install TFX
# RUN pip install --cache-dir pip-cache -r tfx_requirements.txt
# RUN pip uninstall shapely -y
# RUN rm -rf pip-cache
################## END TFX Installation #################
