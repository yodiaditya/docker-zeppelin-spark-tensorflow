# Docker Zeppelin Spark Torch Tensorflow 

This repo contains Dockerfiles, configuration and scripts to run Zeppelin on locally or server 
with simple approach (non-distribution) and customized with Spark, Flink and many others 
ML python packages.

You can extend this with Zeppelin, Spark, Flink, DuckDB, Parquet, Tensorflow, PyTorch and many more.
This already tested with local PC and laptop running on Ubuntu 23.10. 

This is integrated Docker Nvidia GPU.

## 1. Features 

Several key features in this repository to help you learning :

- Re-use `pip cache` for Docker build instead re-downloading python modules
- Copy your Zeppelin or IPYNB in `notebook` folder and linked into Zeppelin in docker
- Works with latest version of Zeppelin 0.11.0, Spark 3.5, Hadoop
- Simple DockerFile and docker-compose-yaml configuration 
- Enable health status of docker 
- Easy to add new packages in `requirements.txt`
- Zeppelin configuration located at `zeppelin/conf` 
- Add more softwares and modify `docker-compose.yaml`
- Integrated with your NVIDIA GPU (single or all!)

## 2. Getting Started

### 2.1. Clone this project

`git clone https://github.com/yodiaditya/docker-zeppelin-spark-torch.git`

### 2.2. Download Latest Spark (3.1.2) 

Download the at <https://archive.apache.org/dist/spark/spark-3.1.2/> and extract the archive file into main project folder. 
Why using this version instead of 3.3/3.4/3.5? Because there is incompatibility issues with scala. 

### 2.3. Download Latest Flink (3.5.1) 
Download at here: <https://www.apache.org/dyn/closer.lua/flink/flink-1.18.1/flink-1.18.1-bin-scala_2.12.tgz> and extract.
```sh
tar xvf flink-1.18.1-bin-scala_2.12.tgz
```

### 2.4. Docker Installation on Ubuntu

Follow this Docker CE installation : <https://docs.docker.com/engine/install/ubuntu/>. 
Don't use `snap` because NVIDIA Toolkit only works with Docker CE

#### Running docker without `root` permission

```
sudo groupadd docker
sudo usermod -aG docker $USER
```

## Docker config for Zeppelin

Docker Configuration <https://zeppelin.apache.org/docs/latest/quickstart/docker.html>

Because DockerInterpreterProcess communicates via docker's tcp interface.
By default, docker provides an interface as a sock file, so you need to modify the configuration file to open the tcp interface remotely.

To listen on both - socket and tcp:

create folder: /etc/systemd/system/docker.socket.d
create file 10-tcp.conf inside the folder with the content:

```
[Socket]
ListenStream=0.0.0.0:2375
```

restart everything:

```
systemctl daemon-reload
systemctl stop docker.socket
systemctl stop docker.service
systemctl start docker
```

Plus are: it us user space systemd drop-in, i.e. would not disappear after upgrade of the docker
would allow to use both - socket and tcp connection


#### If there is DNS issue when download 
You can enable another DNS at `/etc/default/docker` and un-comment this part

```
#DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4"
```

## 3. Build the Docker

Add packages you want to install like Tensorflow, Jupyter, etc into `requirements.txt` in the project folder 

#### Build

```
docker compose up --build
```

#### Install Python Packages from inside Docker 

```
docker exec -u root -it zeppelin bash
```

You can install any required packages 

```
apt update && apt install gcc git
```

Then to install python packages

```
conda activate python_3_with_R
pip install --cache-dir pip-cache -r requirements.txt
```

Python packages download stored into `pip-cache` folder. 
To avoid re-download everything, we copy it back to our host, which can be re-used later.

## 4. Cache Pip Python Package  

Since the packages in `requirements.txt` is more than 2GB, it will takes times to download every build. We can cache it and here are the step. While the docker is running, open new tab and go to project folder. 

1. Get the docker container ID with `docker ps`
2. Copy `pip-cache` from `/opt/zeppelin` inside docker to host (main project folder) 

```
docker ps 
docker cp REPLACE_THIS_WITH_CONTAINER_ID_NUMBER:/opt/zeppelin/pip-cache .
```

Now, everytime `docker compose up --build`, pip will use `pip-cache` folder in main project.
You only need to do pip installation inside docker only one time. 

## 5. Running Zeppelin

Run the docker with :

```sh
docker-compose up
```

Visit <http://localhost:9999> to open the Zeppelin.


## 6. Using Login Shiro
Rename the file `default-shiro.ini` into `shiro.ini` and restart docker.

Use login `admin` : `password` (change this in `zeppelin/conf/shiro.ini`) 
If you are using VS Code Zeppelin extension, you can use this login auth account.


## 7. Docker GPU Installation 
This steps required to enable GPU in the docker
<https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#installing-with-apt>

Or you for Ubuntu 23.10 Docker GPU Nvidia you can follow this: 

```
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
```

Then configure it

```
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

## 8. Test 

Run this to test whether its works. 

```
sudo docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi
```

If not, running the docker and go inside it `docker exec -it zeppelin bash`

```
wget -c https://us.download.nvidia.com/XFree86/Linux-x86_64/550.67/NVIDIA-Linux-x86_64-550.67.run --accept-license --ui=none --no-kernel-module --no-questions 
```

## 9. Install
Change the `docker-compose.yaml` and un-comment this

```
    # deploy:
    #   resources:
    #     reservations:
    #       devices:
    #       - driver: nvidia
    #         device_ids: ['0']
    #         capabilities: [gpu]
```

You can read details at <https://docs.docker.com/compose/gpu-support/>


