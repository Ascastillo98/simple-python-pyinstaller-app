terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}
provider "docker" {}

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



#Contenedor 1 (Hay que añadir todo lo que en el ejemplo metíamos en el comando run)

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


