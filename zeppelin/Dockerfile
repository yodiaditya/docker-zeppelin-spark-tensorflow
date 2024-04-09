FROM apache/zeppelin:0.10.1

ENV SPARK_HOME /opt/bitnami/spark

ENV TZ=UTC \
    DEBIAN_FRONTEND=noninteractive

ENV ZEPPELIN_INTERPRETER_DEP_MVNREPO="https://repo1.maven.org/maven2"
ENV ZEPPELIN_HOME=/opt/zeppelin
ENV ZEPPELIN_NOTEBOOK_DIR /notebooks
ENV ZEPPELIN_ADDR 0.0.0.0

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
COPY ./conf/zeppelin-env.sh ${ZEPPELIN_HOME}/conf/zeppelin-env.sh
COPY ./requirements.txt ${ZEPPELIN_HOME}/requirements.txt
COPY ./tfx_requirements.txt ${ZEPPELIN_HOME}/tfx_requirements.txt

################## INSTALL MAMBA AND PYTHON 3.9 #################
### UNCOMMENT THIS TO UPGRADE TO PYTHON 3.9 or OTHERS VERSION
### When you did this, `shell interpreter` in zeppelin to install any python package since !pip not working anymore.
### eg: %sh
###     pip install rankfm
###
#####################################################################

# COPY ./env_python_3_with_R.yml ${ZEPPELIN_HOME}/env_python_3_with_R.yml

# ARG miniforge_version="23.1.0-1"
# ARG miniforge_sha256="cba9a744454039944480871ed30d89e4e51a944a579b461dd9af60ea96560886"

# RUN set -ex && rm -rf /opt/conda && \
#     wget -nv https://github.com/conda-forge/miniforge/releases/download/${miniforge_version}/Mambaforge-${miniforge_version}-Linux-x86_64.sh -O miniforge.sh && \
#     echo "${miniforge_sha256} miniforge.sh" > miniforge.sha256 && \
#     bash miniforge.sh -b -p /opt/conda && \
#     export PATH=/opt/conda/bin:$PATH && \
#     conda update --yes -n base -c defaults conda && \
#     conda config --set always_yes yes --set changeps1 no && \
#     conda info -a && \
#     conda install mamba -c conda-forge

# RUN set -ex && \
#     export PATH=/opt/conda/bin:$PATH && \
#     mamba env update -f env_python_3_with_R.yml --prune && \
#     # Cleanup
#     rm -v miniforge.sh miniforge.sha256  && \
#     \
#     mamba init bash && \
#     echo mamba activate python_3_with_R >> ${ZEPPELIN_HOME}/.bashrc && \
#     echo mamba activate python_3_with_R >> /root/.bashrc && \
#     \
#     # Cleanup
#     find /opt/conda/ -follow -type f -name '*.a' -delete && \
#     find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
#     mamba clean -ay

ENV PATH="/opt/conda/envs/python_3_with_R/bin:/opt/conda/conda/bin:$PATH"

# RUN set -ex && pip install -q -r requirements.txt
ENV PATH=/opt/zeppelin/.local/bin:$PATH

###################### END MAMBA AND PYTHON 3.9 ######################

################# CUDA INSTALLATION #################
### UNCOMMENT THIS FOR CUDA INSTALLATION
### ENSURE TO COPY THE cuda_11.8.0_520.61.05_linux.run and cudnn INTO `zeppelin/cuda`

# Copy from host `/zeppelin/cuda` to Docker `/opt/zeppelin/cuda`
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

## Copy pip-cache folder from host to Docker
## Instead of project folder, it using zeppelin folder as parent directory (Docker: context . )

# COPY ./pip-cache ${ZEPPELIN_HOME}/pip-cache
# RUN chown -R 1000:1000 ${ZEPPELIN_HOME}/pip-cache

# Change the user back to zeppelin
USER 1000

# Install the required packages. You can modify the requirements.txt file to include the packages you need.

# # UN-COMMENT THIS FOR FIRST TIME PIP INSTALL
# RUN mkdir -p ${ZEPPELIN_HOME}/pip-cache

# # the pip-cache can be copied from Docker to the zeppelin folder with name `pip-cache`
# RUN pip install --cache-dir pip-cache -r requirements.txt

################## Install TFX #################
## COMMENT THIS LINE UNTIL END INSTALLATION IF YOU DON'T NEED TO USE TFX 

# ## Install TFX
# RUN pip install --cache-dir pip-cache -r tfx_requirements.txt
# RUN pip uninstall shapely -y
# RUN rm -rf pip-cache
################## END TFX Installation #################
