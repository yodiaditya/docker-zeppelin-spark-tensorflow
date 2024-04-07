# Docker Zeppelin + Spark + Tensorflow and TFX
Repository to create spark/zeppelin development environment. Works with NVIDIA GPU attached.
This will running Spark Master and Node to replicate near production environment.

You can extend this with Zeppelin, Spark, Flink, DuckDB, Parquet, Tensorflow, PyTorch and many more.
This already tested with local PC and laptop running on Ubuntu 23.10 and RTX 4090

## Quickstart 
Assuming you already have NVIDIA GPU works with Cuda 11.8, Use the pre-built image.
Modify the `docker-compose.yaml` and enable `dockerfile: Dockerfile_hub` eg:

```
build: 
      context: zeppelin
      # dockerfile: Dockerfile        # Use this line if want to build from scratch
      dockerfile: Dockerfile_hub  # Use this line if you want to use the pre-built image from Docker Hub
```

After modify the file, you can run it:

```
docker-compose up -d --build
```

To access services use:
- Spark master: <http://localhost:8080>
- Zeppelin: <http://localhost:9999>


## Docker Access
Root Login (For apt install and other root permission)
```
docker exec -u 0 -it zeppelin bash
```

User Login (For pip installation etc)
```
docker exec -it zeppelin bash
```

You can login and do `nvtop` to see whether GPU is detected.

# Build from Scratch 

## 1. Features 

Several key features in this repository to help you learning :

- Re-use `pip cache` for Docker build instead re-downloading python modules
- Copy your Zeppelin or IPYNB in `notebook` folder and linked into Zeppelin in docker
- Easy to add new packages in `requirements.txt` and TFX support on `tfx_requirements.txt`
- Zeppelin configuration located at `zeppelin/conf` 
- CUDA and CUDNN installed and integrated with Zeppelin Docker (you can disable this)
- Auto Conda activate environment when login via `docker exec -it zeppelin bash` (setup on `~/.bashrc`)
- Login root using `docker exec -u 0 -it zeppelin bash` for any `apt` or other root access

## 2. Getting Started

### 2.1. Clone this project

`git clone https://github.com/yodiaditya/docker-zeppelin-spark-torch.git`

### 2.2. Docker Installation on Ubuntu

Follow this Docker CE installation : <https://docs.docker.com/engine/install/ubuntu/>. 
Don't use `snap` because NVIDIA Toolkit only works with Docker CE

If you received weird NVIDIA errors when running the dockers,
Suggested to uninstall everything and re-install Docker CE. Here are the steps:

```
sudo snap remove --purge docker
sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl restart docker

```
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
You can enable another DNS at `/etc/docker/daemon.json` and add your local DNS or Google DNS

```
{ "dns" : [ "114.114.114.114" , "8.8.8.8" ] } 
```

## 3. Configure Zeppelin

Add packages you want to install like Tensorflow, Jupyter, etc into `zeppelin/requirements.txt` in the project folder.

Python packages download stored into `pip-cache` folder both in `zeppelin` project and host `/opt/zeppelin`.
To avoid re-download everything, copy it back to our host, which can be re-used later.

1. Get the docker container ID with `docker ps`
2. Copy `pip-cache` from `/opt/zeppelin` inside docker to `zeppelin` folder in project. 

```
docker ps 
docker cp REPLACE_THIS_WITH_CONTAINER_ID_NUMBER:/opt/zeppelin/pip-cache zeppelin/
```

Now, everytime `docker compose up --build`, pip will use `pip-cache` folder in main project.

## 4. Using Login Shiro
Create `shiro.ini` and copy into `/opt/zeppelin/conf` via Dockerfile.

## 5. Docker GPU Installation 
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

Run this to test whether its works. 

```
sudo docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi
```

This will enabled in `docker-compose.yaml` on zeppelin section:

```
deploy:
  resources:
    reservations:
      devices:
      - driver: nvidia
        device_ids: ['0']
        capabilities: [gpu]
```

You can read details at <https://docs.docker.com/compose/gpu-support/>


If not, running the docker and go inside it `docker exec -it zeppelin bash`

```
wget -c https://us.download.nvidia.com/XFree86/Linux-x86_64/550.67/NVIDIA-Linux-x86_64-550.67.run --accept-license --ui=none --no-kernel-module --no-questions 
```

## 6. CUDA and CUDNN Installation in Docker Zeppelin
I'm using CUDA 11.8 and RTX 3060 / 4090 for this example. We need to download the installation

Start from main project folder
```
cd zeppelin
mkdir cuda && cd cuda
wget https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda_11.8.0_520.61.05_linux.run
```

Next, download CUDNN 8.9.7 and extract it as folder `cudnn`

```
wget https://developer.nvidia.com/downloads/compute/cudnn/secure/8.9.7/local_installers/11.x/cudnn-linux-x86_64-8.9.7.29_cuda11-archive.tar.xz
tar -xvvf cudnn-linux-x86_64-8.9.7.29_cuda11-archive.tar.xz
mv cudnn-linux-x86_64-8.9.7.29_cuda11-archive cudnn
```

You can see in `zeppelin/Dockerfile` there is operation to copy this into Docker and set installation

## 7. TFX Installation

For Recommendation System and using TFX, the separated requirements located at `zeppelin/tfx_requirements.txt`


## 8. Notes
You can modify and doing installation inside the Docker:

`pip install --cache-dir pip-cache -r requirements.txt`

For any APT installs, you can use the following command: 
`docker exec -u 0 -it zeppelin bash -c "apt-get update && apt-get install -yqq --no-install-recommends <package-name>`

or login with -u 0 to run as root


## 9. Voila!
You can run both TFX or Training Tensorflow models on Zeppelin + Spark

![Zeppelin Docker Tensorflow](ss.png?raw=true "Docker Zeppelin Tensorflow")


## 10. Push the modification into Hub and reduce the Docker image size 

Install slim <https://github.com/slimtoolkit/slim> and then you can follow these steps:

```
slim build zeppelin-zeppelin
docker login
docker images 
docker image tag <REPLACE_WITH_IMAGE_ID> yodiaditya/zeppelin-tensorflow-tfx:latest
