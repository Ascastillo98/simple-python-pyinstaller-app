#Práctica Jenkins: Configuraciones
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
