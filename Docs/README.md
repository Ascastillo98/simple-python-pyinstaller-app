# Práctica Jenkins: Configuraciones
## Paso 1: Creación del Contenedor de Jenkins
Además del contenido que se nos ofrece en el guión de la práctica, debemos añadir los comandos para instalar python, ya que crearemos una aplicación con este lenguaje:
```
# 1. Update the package list.
# 2. Install necessary dependencies including Python, python3-venv and several Python-related packages.
RUN apt-get update && apt-get install -y --no-install-recommends \
    binutils ca-certificates curl git python3 python3-venv python3-pip python3-setuptools python3-wheel python3-dev wget \
    && rm -rf /var/lib/apt/lists/*

# Create an alias for python3 as python.
RUN ln -s /usr/bin/python3 /usr/bin/python

# Create a Python virtual environment in /opt/venv.
RUN python3 -m venv /opt/venv

# Activate the virtual environment by adding its bin directory to the PATH.
# This ensures that the virtual environment is activated for all subsequent RUN commands in the Dockerfile.
ENV PATH="/opt/venv/bin:$PATH"

# Install required Python packages in the virtual environment.
RUN pip install docker-py feedparser nosexcover prometheus_client pycobertura pylint pytest pytest-cov requests setuptools sphinx pyinstaller
```
Es importante que los comandos que se muestran en este fragmento se ejecuten de user Root, de lo contrario no funcionarán. En el archivo Dockerfile de muestra el código completo.

## Paso 2: Creación del contenedor de Docker Dind
Podemos usar la imagen de docker:Dind en Dockerhub, y dado que utilizamos terraform, no hay que realizar ninguna acción extra.

## Paso 3: Creación del archivo config.tf para Terraform
Debemos, como siempre, escribir el comando Terraform init antes de empezar. Una vez hecho, el contenido de config.tf es el siguiente:

* Indicamos los proveedores como en la práctica anterior:

```
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}
provider "docker" {}

```
* Creamos la red y los contenedores que utilizarán los dockers. Como extra, saber que si los contenedores son creados mediante terraform, se borrarán en el momento en el que se ejecute un Terraform destroy.
* Sería adecuado crear un volumen aparte e indicarlo en el recurso de contenedor jenkins.
  
```
# Creación de la red y contenedores
resource "docker_network" "jenkins" {
  name = "RedJenkins"
}

resource "docker_volume" "jenkins-docker-certs" {
  name = "jenkins-docker-certs"
}

resource "docker_volume" "jenkins-data" {
  name = "jenkins-data"
}
```
* Creamos el contenedor de docker Dind. Añadimos en el terraform los comandos que se mostraron en el run del guión de la práctica, así como los volúmenes y la network a la que se conecta:
```
resource "docker_container" "dockerdind" {
  image        = "docker:dind"
  name         = "contenedorDockerDind"
  command      = ["--storage-driver overlay2"]
  privileged   = true
  network_mode = "jenkins"
  restart      = "always"

  ports {
    internal = 2376
    external = 2376
  }

  env = [
    "DOCKER_TLS_CERTDIR=/certs"
  ]

  volumes {
    volume_name       = docker_volume.jenkins-docker-certs.name
    container_path = "/certs/client"
  }

  volumes {
    volume_name       = docker_volume.jenkins-data.name
    container_path = "/var/jenkins_home"
  }

  networks_advanced {
    name = docker_network.jenkins.name
  }
}
```
* Creamos el contenedor de Jenkins personalizado, que usará la imagen de Jenkins que hemos creado anteriormente:
```
#Contenedor 2 (Jenkins con imagen personalizada)
resource "docker_image" "myjenkinspython" {
  name         = "myjenkinspython"
  keep_locally = false
  build {
    context    = "/myjenkins"
    dockerfile = "/myjenkins/Dockerfile"
  }
}

resource "docker_container" "myjenkinspython" {
  name  = "contenedorJenkins"
  image = docker_image.myjenkinspython.image_id
  ports {
    internal = 8080
    external = 8080
  }
}
```
* Tras esto, ejecutamos terraform validate para comprobar que el formato es correcto, y terraform apply para levantar el servicio.






  
