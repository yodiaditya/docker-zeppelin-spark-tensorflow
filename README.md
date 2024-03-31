# Docker Zeppelin Spark Torch Tensorflow 

This repo contains Dockerfiles, configuration and scripts to run Zeppelin on locally or server 
with simple approach (non-distribution) and customized with Spark, Flink and many others 
ML python packages.

You can extend this with Zeppelin, Spark, Flink, DuckDB, Parquet, Tensorflow, PyTorch and many more.
This already tested with local PC and laptop running on Ubuntu 23.10. 

## I. Features 

Several key features in this repository to help you learning :

- Re-use `pip cache` for Docker build instead re-downloading python modules
- Copy your Zeppelin or IPYNB in `notebook` folder and linked into Zeppelin in docker
- Works with latest version of Zeppelin 0.11.0, Spark 3.5, Hadoop
- Simple DockerFile and docker-compose-yaml configuration 
- Enable health status of docker 
- Easy to add new packages in `requirements.txt`
- Zeppelin configuration located at `zeppelin/conf` 
- Add more softwares and modify `docker-compose.yaml`

## II. Getting Started

### 1. Clone this project

`git clone https://github.com/yodiaditya/docker-zeppelin-spark-torch.git`

### 2. Download Latest Spark (3.1.2) 

Download the at <https://archive.apache.org/dist/spark/spark-3.1.2/> and extract the archive file into main project folder. 
Why using this version instead of 3.3/3.4/3.5? Because there is incompatibility issues with scala. 

### 3. Download Latest Flink (3.5.1) 
Download at here: <https://www.apache.org/dyn/closer.lua/flink/flink-1.18.1/flink-1.18.1-bin-scala_2.12.tgz> and extract.
```sh
tar xvf flink-1.18.1-bin-scala_2.12.tgz
```

### 4. Docker Installation on Ubuntu

Follow this Docker CE installation : <https://docs.docker.com/engine/install/ubuntu/>

#### Running docker without `root`

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
Add `1.1.1.1` or your local DNS in `/etc/docker/daemon.json`

```
{
  "dns": ["192.168.18.1", "1.1.1.1"]
}
```

## III. Build the Docker

Add packages you want to install like Tensorflow, Jupyter, etc into `requirements.txt` in the project folder 

#### Build

```
docker compose up --build
```

#### Install Python Packages
```
docker exec -u root -it zeppelin /bin/bash
conda activate python_3_with_R
pip install --cache-dir pip-cache -r requirements.txt
```

## IV. Cache Pip Python Package  

Since the packages in `requirements.txt` is more than 2GB, it will takes times to download every build. We can cache it and here are the step. While the docker is running, open new tab and go to project folder. 

1. Get the docker container ID with `docker ps`
2. Copy `pip-cache` from `/opt/zeppelin` inside docker to host (main project folder) 

```
docker ps 
docker cp REPLACE_THIS_WITH_CONTAINER_ID_NUMBER:/opt/zeppelin/pip-cache .
```

Now, everytime `docker compose up --build`, pip will use `pip-cache` folder in main project.

## V. Running Zeppelin

Run the docker with :

```sh
docker-compose up
```

Visit <http://localhost:9999> to open the Zeppelin.


## VI. Using Login Shiro
Rename the file `default-shiro.ini` into `shiro.ini` and restart docker.

Use login `admin` : `password` (change this in `zeppelin/conf/shiro.ini`) 
If you are using VS Code Zeppelin extension, you can use this login auth account.

